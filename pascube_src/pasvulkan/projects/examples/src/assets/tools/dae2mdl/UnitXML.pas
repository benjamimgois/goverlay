unit UnitXML; // Copyright (C) 2006-2017, Benjamin Rosseaux - License: zlib
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
 {$ifdef fpc_little_endian}
  {$define little_endian}
 {$else}
  {$ifdef fpc_big_endian}
   {$define big_endian}
  {$endif}
 {$endif}
 {$ifdef fpc_has_internal_sar}
  {$define HasSAR}
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
{$else}
 {$realcompatibility off}
 {$localsymbols on}
 {$define little_endian}
 {$ifndef cpu64}
  {$define cpu32}
 {$endif}
 {$define delphi} 
 {$undef HasSAR}
 {$define UseDIV}
 {$define HAS_TYPE_EXTENDED}
 {$define HAS_TYPE_DOUBLE}
 {$define HAS_TYPE_SINGLE}
{$endif}
{$ifdef cpu386}
 {$define cpux86}
{$endif}
{$ifdef cpuamd64}
 {$define cpux86}
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
 {$define win}
{$endif}
{$ifdef sdl20}
 {$define sdl}
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
{$ifndef HAS_TYPE_DOUBLE}
 {$error No double floating point precision}
{$endif}
{$ifdef fpc}
 {$define caninline}
{$else}
 {$undef caninline}
 {$ifdef ver180}
  {$define caninline}
 {$else}
  {$ifdef conditionalexpressions}
   {$if compilerversion>=18}
    {$define caninline}
   {$ifend}
  {$endif}
 {$endif}
{$endif}

interface

uses SysUtils,Classes;

type TXMLClass=class
      public
       Previous,Next:TXMLClass;
       Core:pointer;
       constructor Create; overload; virtual;
       destructor Destroy; override;
     end;

const MaxListSize=2147483647 div SizeOf(TXMLClass);

type PEngineListClasses=^TXMLClasses;
     TXMLClasses=array[0..MaxListSize-1] of TXMLClass;

     TXMLClassList=class(TXMLClass)
      private
       InternalList:PEngineListClasses;
       InternalCount,InternalCapacity:longint;
       function GetItem(Index:longint):TXMLClass;
       procedure SetItem(Index:longint;Value:TXMLClass);
       function GetItemPointer(Index:longint):TXMLClass;
      public
       ClearWithContentDestroying:boolean;
       CapacityMinimium:longint;
       constructor Create; override;
       destructor Destroy; override;
       procedure Clear;
       procedure ClearNoFree;
       procedure ClearWithFree;
       function Add(Item:TXMLClass):longint;
       function Append(Item:TXMLClass):longint;
       function AddList(List:TXMLClassList):longint;
       function AppendList(List:TXMLClassList):longint;
       function NewClass:TXMLClass;
       procedure Insert(Index:longint;Item:TXMLClass);
       procedure Delete(Index:longint);
       procedure DeleteClass(Index:longint);
       function Remove(Item:TXMLClass):longint;
       function RemoveClass(Item:TXMLClass):longint;
       function Find(Item:TXMLClass):longint;
       function IndexOf(Item:TXMLClass):longint;
       procedure Exchange(Index1,Index2:longint);
       procedure SetCapacity(NewCapacity:longint);
       procedure SetOptimalCapacity(TargetCapacity:longint);
       procedure SetCount(NewCount:longint);
       function Push(Item:TXMLClass):longint;
       function Pop(var Item:TXMLClass):boolean; overload;
       function Pop:TXMLClass; overload;
       function Last:TXMLClass;
       property Count:longint read InternalCount; 
       property Capacity:longint read InternalCapacity write SetCapacity;
       property Item[Index:longint]:TXMLClass read GetItem write SetItem; default;
       property Items[Index:longint]:TXMLClass read GetItem write SetItem;
       property PItems[Index:longint]:TXMLClass read GetItemPointer;
     end;

     TXMLClassLinkedList=class(TXMLClass)
      public
       ClearWithContentDestroying:boolean;
       First,Last:TXMLClass;
       constructor Create; override;
       destructor Destroy; override;
       procedure Clear;
       procedure ClearNoFree;
       procedure ClearWithFree;
       procedure Add(Item:TXMLClass);
       procedure Append(Item:TXMLClass);
       procedure AddLinkedList(List:TXMLClassLinkedList);
       procedure AppendLinkedList(List:TXMLClassLinkedList);
       procedure Remove(Item:TXMLClass);
       procedure RemoveClass(Item:TXMLClass);
       procedure Push(Item:TXMLClass);
       function Pop(var Item:TXMLClass):boolean; overload;
       function Pop:TXMLClass; overload;
       function Count:longint;
     end;

     TXMLPtrInt={$if defined(fpc)}PtrInt{$elseif declared(NativeInt)}NativeInt{$elseif defined(cpu64)}Int64{$else}longint{$ifend};
     
     TXMLStringTreeData=TXMLPtrInt;

     PXMLStringTreeNode=^TXMLStringTreeNode;
     TXMLStringTreeNode=record
      TheChar:ansichar;
      Data:TXMLStringTreeData;
      DataExist:boolean;
      Prevoius,Next,Up,Down:PXMLStringTreeNode;
     end;

     TXMLStringTree=class
      private
       Root:PXMLStringTreeNode;
       function CreateStringTreeNode(AChar:ansichar):PXMLStringTreeNode;
       procedure DestroyStringTreeNode(Node:PXMLStringTreeNode);
      public
       constructor Create;
       destructor Destroy; override;
       procedure Clear;
       procedure DumpTree;
       procedure DumpList;
       procedure AppendTo(DestStringTree:TXMLStringTree);
       procedure Optimize(DestStringTree:TXMLStringTree);
       function Add(Content:ansistring;Data:TXMLStringTreeData;Replace:boolean=false):boolean;
       function Delete(Content:ansistring):boolean;
       function Find(Content:ansistring;var Data:TXMLStringTreeData):boolean;
       function FindEx(Content:ansistring;var Data:TXMLStringTreeData;var Len:longint):boolean;
     end;

     TXMLString={$ifdef UNICODE}widestring{$else}ansistring{$endif};
     TXMLChar={$ifdef UNICODE}widechar{$else}ansichar{$endif};

     TXMLParameter=class(TXMLClass)
      public
       Name:ansistring;
       Value:TXMLString;
       constructor Create; override;
       destructor Destroy; override;
       procedure Assign(From:TXMLParameter); virtual;
     end;

     TXMLItemList=class;

     TXMLTag=class;

     TXMLItem=class(TXMLClass)
      public
       Items:TXMLItemList;
       constructor Create; override;
       destructor Destroy; override;
       procedure Clear; virtual;
       procedure Add(Item:TXMLItem);
       procedure Assign(From:TXMLItem); virtual;
       function FindTag(const TagName:ansistring):TXMLTag;
     end;

     TXMLItemList=class(TXMLClassList)
      private
       function GetItem(Index:longint):TXMLItem;
       procedure SetItem(Index:longint;Value:TXMLItem);
      public
       constructor Create; override;
       destructor Destroy; override;
       function NewClass:TXMLItem;
       function FindTag(const TagName:ansistring):TXMLTag;
       property Item[Index:longint]:TXMLItem read GetItem write SetItem; default;
       property Items[Index:longint]:TXMLItem read GetItem write SetItem;
     end;

     TXMLText=class(TXMLItem)
      public
       Text:TXMLString;
       constructor Create; override;
       destructor Destroy; override;
       procedure Assign(From:TXMLItem); override;
       procedure SetText(AText:ansistring);
     end;

     TXMLCommentTag=class(TXMLItem)
      public
       Text:ansistring;
       constructor Create; override;
       destructor Destroy; override;
       procedure Assign(From:TXMLItem); override;
       procedure SetText(AText:ansistring);
     end;

     TXMLTag=class(TXMLItem)
      public
       Name:ansistring;
       Parameter:array of TXMLParameter;
       IsAloneTag:boolean;
       constructor Create; override;
       destructor Destroy; override;
       procedure Clear; override;
       procedure Assign(From:TXMLItem); override;
       function FindParameter(ParameterName:ansistring):TXMLParameter;
       function GetParameter(ParameterName:ansistring;default:ansistring=''):ansistring;
       function AddParameter(AParameter:TXMLParameter):boolean; overload;
       function AddParameter(Name:ansistring;Value:TXMLString):boolean; overload;
       function RemoveParameter(AParameter:TXMLParameter):boolean; overload;
       function RemoveParameter(ParameterName:ansistring):boolean; overload;
     end;

     TXMLProcessTag=class(TXMLTag)
      public
       constructor Create; override;
       destructor Destroy; override;
       procedure Assign(From:TXMLItem); override;
     end;

     TXMLScriptTag=class(TXMLItem)
      public
       Text:ansistring;
       constructor Create; override;
       destructor Destroy; override;
       procedure Assign(From:TXMLItem); override;
       procedure SetText(AText:ansistring);
     end;

     TXMLCDataTag=class(TXMLItem)
      public
       Text:ansistring;
       constructor Create; override;
       destructor Destroy; override;
       procedure Assign(From:TXMLItem); override;
       procedure SetText(AText:ansistring);
     end;

     TXMLDOCTYPETag=class(TXMLItem)
      public
       Text:ansistring;
       constructor Create; override;
       destructor Destroy; override;
       procedure Assign(From:TXMLItem); override;
       procedure SetText(AText:ansistring);
     end;

     TXMLExtraTag=class(TXMLItem)
      public
       Text:ansistring;
       constructor Create; override;
       destructor Destroy; override;
       procedure Assign(From:TXMLItem); override;
       procedure SetText(AText:ansistring);
     end;

     TXML=class(TXMLClass)
      private
       function ReadXMLText:ansistring;
       procedure WriteXMLText(Text:ansistring);
      public
       Root:TXMLItem;
       AutomaticAloneTagDetection:boolean;
       FormatIndent:boolean;
       FormatIndentText:boolean;
       constructor Create; override;
       destructor Destroy; override;
       procedure Assign(From:TXML);
       function Parse(Stream:TStream):boolean;
       function Read(Stream:TStream):boolean;
       function Write(Stream:TStream;IdentSize:longint=2):boolean;
       property Text:ansistring read ReadXMLText write WriteXMLText;
     end;

implementation

function UTF32CharToUTF8(CharValue:longword):ansistring;
var Data:array[0..{$ifdef strictutf8}3{$else}5{$endif}] of ansichar;
    ResultLen:longint;
begin
 if CharValue=0 then begin
  result:=#0;
 end else begin
  if CharValue<=$7f then begin
   Data[0]:=ansichar(byte(CharValue));
   ResultLen:=1;
  end else if CharValue<=$7ff then begin
   Data[0]:=ansichar(byte($c0 or ((CharValue shr 6) and $1f)));
   Data[1]:=ansichar(byte($80 or (CharValue and $3f)));
   ResultLen:=2;
{$ifdef strictutf8}
  end else if CharValue<=$d7ff then begin
   Data[0]:=ansichar(byte($e0 or ((CharValue shr 12) and $0f)));
   Data[1]:=ansichar(byte($80 or ((CharValue shr 6) and $3f)));
   Data[2]:=ansichar(byte($80 or (CharValue and $3f)));
   ResultLen:=3;
  end else if CharValue<=$dfff then begin
   Data[0]:=#$ef; // $fffd
   Data[1]:=#$bf;
   Data[2]:=#$bd;
   ResultLen:=3;
{$endif}
  end else if CharValue<=$ffff then begin
   Data[0]:=ansichar(byte($e0 or ((CharValue shr 12) and $0f)));
   Data[1]:=ansichar(byte($80 or ((CharValue shr 6) and $3f)));
   Data[2]:=ansichar(byte($80 or (CharValue and $3f)));
   ResultLen:=3;
  end else if CharValue<=$1fffff then begin
   Data[0]:=ansichar(byte($f0 or ((CharValue shr 18) and $07)));
   Data[1]:=ansichar(byte($80 or ((CharValue shr 12) and $3f)));
   Data[2]:=ansichar(byte($80 or ((CharValue shr 6) and $3f)));
   Data[3]:=ansichar(byte($80 or (CharValue and $3f)));
   ResultLen:=4;
{$ifndef strictutf8}
  end else if CharValue<=$3ffffff then begin
   Data[0]:=ansichar(byte($f8 or ((CharValue shr 24) and $03)));
   Data[1]:=ansichar(byte($80 or ((CharValue shr 18) and $3f)));
   Data[2]:=ansichar(byte($80 or ((CharValue shr 12) and $3f)));
   Data[3]:=ansichar(byte($80 or ((CharValue shr 6) and $3f)));
   Data[4]:=ansichar(byte($80 or (CharValue and $3f)));
   ResultLen:=5;
  end else if CharValue<=$7fffffff then begin
   Data[0]:=ansichar(byte($fc or ((CharValue shr 30) and $01)));
   Data[1]:=ansichar(byte($80 or ((CharValue shr 24) and $3f)));
   Data[2]:=ansichar(byte($80 or ((CharValue shr 18) and $3f)));
   Data[3]:=ansichar(byte($80 or ((CharValue shr 12) and $3f)));
   Data[4]:=ansichar(byte($80 or ((CharValue shr 6) and $3f)));
   Data[5]:=ansichar(byte($80 or (CharValue and $3f)));
   ResultLen:=6;
{$endif}
  end else begin
   Data[0]:=#$ef; // $fffd
   Data[1]:=#$bf;
   Data[2]:=#$bd;
   ResultLen:=3;
  end;
  SetString(result,pansichar(@Data[0]),ResultLen);
 end;
end;

function NextPowerOfTwo(Value:longint;const MinThreshold:longint=0):longint;
begin
 result:=(Value or MinThreshold)-1;
 result:=result or (result shr 1);
 result:=result or (result shr 2);
 result:=result or (result shr 4);
 result:=result or (result shr 8);
 result:=result or (result shr 16);
 inc(result);
end;

const EntityChars:array[1..102,1..2] of TXMLString=(('&quot;',#34),('&amp;',#38),('&apos;',''''),
                                                    ('&lt;',#60),('&gt;',#62),('&euro;',#128),('&nbsp;',#160),('&iexcl;',#161),
                                                    ('&cent;',#162),('&pound;',#163),('&curren;',#164),('&yen;',#165),
                                                    ('&brvbar;',#166),('&sect;',#167),('&uml;',#168),('&copy;',#169),
                                                    ('&ordf;',#170),('&laquo;',#171),('&not;',#172),('&shy;',#173),
                                                    ('&reg;',#174),('&macr;',#175),('&deg;',#176),('&plusmn;',#177),
                                                    ('&sup2;',#178),('&sup3;',#179),('&acute;',#180),('&micro;',#181),
                                                    ('&para;',#182),('&middot;',#183),('&cedil;',#184),('&sup1;',#185),
                                                    ('&ordm;',#186),('&raquo;',#187),('&frac14;',#188),('&frac12;',#189),
                                                    ('&frac34;',#190),('&iquest;',#191),('&Agrave;',#192),('&Aacute;',#193),
                                                    ('&Acirc;',#194),('&Atilde;',#195),('&Auml;',#196),('&Aring;',#197),
                                                    ('&AElig;',#198),('&Ccedil;',#199),('&Egrave;',#200),('&Eacute;',#201),
                                                    ('&Ecirc;',#202),('&Euml;',#203),('&Igrave;',#204),('&Iacute;',#205),
                                                    ('&Icirc;',#206),('&Iuml;',#207),('&ETH;',#208),('&Ntilde;',#209),
                                                    ('&Ograve;',#210),('&Oacute;',#211),('&Ocirc;',#212),('&Otilde;',#213),
                                                    ('&Ouml;',#214),('&times;',#215),('&Oslash;',#216),('&Ugrave;',#217),
                                                    ('&Uacute;',#218),('&Ucirc;',#219),('&Uuml;',#220),('&Yacute;',#221),
                                                    ('&THORN;',#222),('&szlig;',#223),('&agrave;',#224),('&aacute;',#225),
                                                    ('&acirc;',#226),('&atilde;',#227),('&auml;',#228),('&aring;',#229),
                                                    ('&aelig;',#230),('&ccedil;',#231),('&egrave;',#232),('&eacute;',#233),
                                                    ('&ecirc;',#234),('&euml;',#235),('&igrave;',#236),('&iacute;',#237),
                                                    ('&icirc;',#238),('&iuml;',#239),('&eth;',#240),('&ntilde;',#241),
                                                    ('&ograve;',#242),('&oacute;',#243),('&ocirc;',#244),('&otilde;',#245),
                                                    ('&ouml;',#246),('&divide;',#247),('&oslash;',#248),('&ugrave;',#249),
                                                    ('&uacute;',#250),('&ucirc;',#251),('&uuml;',#252),('&yacute;',#253),
                                                    ('&thorn;',#254),('&yuml;',#255));

type TEntitiesCharLookUpItem=record
      IsEntity:boolean;
      Entity:ansistring;
     end;

     TEntitiesCharLookUpTable=array[0..{$ifdef UNICODE}65535{$else}255{$endif}] of TEntitiesCharLookUpItem;

var EntitiesCharLookUp:TEntitiesCharLookUpTable;
    EntityStringTree:TXMLStringTree;

const EntityInitialized:boolean=false;

procedure InitializeEntites;
var EntityCounter:longint;
begin
 if not EntityInitialized then begin
  EntityInitialized:=true;
  EntityStringTree:=TXMLStringTree.Create;
  FillChar(EntitiesCharLookUp,SizeOf(TEntitiesCharLookUpTable),#0);
  for EntityCounter:=low(EntityChars) to high(EntityChars) do begin
   EntityStringTree.Add(EntityChars[EntityCounter,1],EntityCounter,true);
   with EntitiesCharLookUp[ord(EntityChars[EntityCounter,2][1])] do begin
    IsEntity:=true;
    Entity:=EntityChars[EntityCounter,1];
   end;
  end;
 end;
end;

procedure FinalizeEntites;
begin
 if assigned(EntityStringTree) then begin
  EntityStringTree.Destroy;
  EntityStringTree:=nil;
 end;
 EntityInitialized:=false;
end;

function ConvertToEntities(AString:TXMLString;IdentLevel:longint=0):ansistring;
var Counter,IdentCounter:longint;
    c:TXMLChar;
begin
 result:='';
 for Counter:=1 to length(AString) do begin
  c:=AString[Counter];
  if c=#13 then begin
   if ((Counter+1)<=length(AString)) and (AString[Counter+1]=#10) then begin
    continue;
   end;
   c:=#10;
  end;
  if EntitiesCharLookUp[ord(c)].IsEntity then begin
   result:=result+EntitiesCharLookUp[ord(c)].Entity;
  end else if (c=#9) or (c=#10) or (c=#13) or ((c>=#32) and (c<=#127)) then begin
   result:=result+c;
   if c=#10 then begin
    for IdentCounter:=1 to IdentLevel do begin
     result:=result+' ';
    end;
   end;
  end else begin
{$ifdef UNICODE}
   if c<#255 then begin
    result:=result+'&#'+INTTOSTR(ord(c))+';';
   end else begin
    result:=result+'&#x'+IntToHex(ord(c),4)+';';
   end;
{$else}
   result:=result+'&#'+INTTOSTR(byte(c))+';';
{$endif}
  end;
 end;
end;

constructor TXMLClass.Create;
begin
 inherited Create;
 Previous:=nil;
 Next:=nil;
 Core:=nil;
end;

destructor TXMLClass.Destroy;
begin
 inherited Destroy;
end;

constructor TXMLClassList.Create;
begin
 inherited Create;
 ClearWithContentDestroying:=false;
 InternalCount:=0;
 InternalCapacity:=0;
 InternalList:=nil;
 CapacityMinimium:=0;
 Clear;
end;

destructor TXMLClassList.Destroy;
begin
 Clear;
 if assigned(InternalList) and (InternalCapacity<>0) then begin
  FreeMem(InternalList);
 end;
 inherited Destroy;
end;

procedure TXMLClassList.Clear;
begin
 if ClearWithContentDestroying then begin
  ClearWithFree;
 end else begin
  ClearNoFree;
 end;
end;

procedure TXMLClassList.ClearNoFree;
begin
 SetCount(0);
end;

procedure TXMLClassList.ClearWithFree;
var Counter:longint;
begin
 for Counter:=0 to InternalCount-1 do begin
  if assigned(InternalList^[Counter]) then begin
   try
    InternalList^[Counter].Destroy;
   except
   end;
  end;
 end;
 SetCount(0);
end;

procedure TXMLClassList.SetCapacity(NewCapacity:longint);
begin
 if (InternalCapacity<>NewCapacity) and
    ((NewCapacity>=0) and (NewCapacity<MaxListSize)) then begin
  ReallocMem(InternalList,NewCapacity*SizeOf(TXMLClass));
  if InternalCapacity<NewCapacity then begin
   FillChar(InternalList^[InternalCapacity],(NewCapacity-InternalCapacity)*SizeOf(TXMLClass),#0);
  end;
  InternalCapacity:=NewCapacity;
 end;
end;

procedure TXMLClassList.SetOptimalCapacity(TargetCapacity:longint);
var CapacityMask:longint;
begin
 if (TargetCapacity>=0) and (TargetCapacity<MaxListSize) then begin
  if TargetCapacity<256 then begin
   CapacityMask:=15;
  end else if TargetCapacity<1024 then begin
   CapacityMask:=255;
  end else if TargetCapacity<4096 then begin
   CapacityMask:=1023;
  end else if TargetCapacity<16384 then begin
   CapacityMask:=4095;
  end else if TargetCapacity<65536 then begin
   CapacityMask:=16383;
  end else begin
   CapacityMask:=65535;
  end;
  SetCapacity((TargetCapacity+CapacityMask+CapacityMinimium) and not CapacityMask);
 end;
end;

procedure TXMLClassList.SetCount(NewCount:longint);
begin
 if (NewCount>=0) and (NewCount<MaxListSize) then begin
  SetOptimalCapacity(NewCount);
  if InternalCount<NewCount then begin
   FillChar(InternalList^[InternalCount],(NewCount-InternalCount)*SizeOf(TXMLClass),#0);
  end;
  InternalCount:=NewCount;
 end;
end;

function TXMLClassList.Add(Item:TXMLClass):longint;
begin
 result:=InternalCount;
 SetCount(result+1);
 InternalList^[result]:=Item;
end;

function TXMLClassList.Append(Item:TXMLClass):longint;
begin
 result:=Add(Item);
end;

function TXMLClassList.AddList(List:TXMLClassList):longint;
var Counter,Index:longint;
begin
 result:=-1;
 for Counter:=0 to List.Count-1 do begin
  Index:=Add(List[Counter]);
  if Counter=0 then begin
   result:=Index;
  end;
 end;
end;

function TXMLClassList.AppendList(List:TXMLClassList):longint;
begin
 result:=AddList(List);
end;

function TXMLClassList.NewClass:TXMLClass;
var Item:TXMLClass;
begin
 Item:=TXMLClass.Create;
 Add(Item);
 result:=Item;
end;

procedure TXMLClassList.Insert(Index:longint;Item:TXMLClass);
var Counter:longint;
begin
 if (Index>=0) and (Index<InternalCount) then begin
  SetCount(InternalCount+1);
  for Counter:=InternalCount-1 downto Index do begin
   InternalList^[Counter+1]:=InternalList^[Counter];
  end;
  InternalList^[Index]:=Item;
 end else if Index=InternalCount then begin
  Add(Item);
 end else if Index>InternalCount then begin
  SetCount(Index);
  Add(Item);
 end;
end;

procedure TXMLClassList.Delete(Index:longint);
var i,j:longint;
begin
 if (Index>=0) and (Index<InternalCount) then begin
  j:=InternalCount-1;
  i:=Index;
  Move(InternalList^[i+1],InternalList^[i],(j-i)*SizeOf(TXMLClass));
  SetCount(j);
 end;
end;

procedure TXMLClassList.DeleteClass(Index:longint);
var i,j:longint;
begin
 if (Index>=0) and (Index<InternalCount) then begin
  j:=InternalCount-1;
  i:=Index;
  if assigned(InternalList^[i]) then begin
   InternalList^[i].Free;
   InternalList^[i]:=nil;
  end;
  Move(InternalList^[i+1],InternalList^[i],(j-i)*SizeOf(TXMLClass));
  SetCount(j);
 end;
end;

function TXMLClassList.Remove(Item:TXMLClass):longint;
var i,j,k:longint;
begin
 result:=-1;
 k:=InternalCount;
 j:=-1;
 for i:=0 to k-1 do begin
  if InternalList^[i]=Item then begin
   j:=i;
   break;
  end;
 end;
 if j>=0 then begin
  dec(k);
  Move(InternalList^[j+1],InternalList^[j],(k-j)*SizeOf(TXMLClass));
  SetCount(k);
  result:=j;
 end;
end;

function TXMLClassList.RemoveClass(Item:TXMLClass):longint;
var i,j,k:longint;
begin
 result:=-1;
 k:=InternalCount;
 j:=-1;
 for i:=0 to k-1 do begin
  if InternalList^[i]=Item then begin
   j:=i;
   break;
  end;
 end;
 if j>=0 then begin
  dec(k);
  Move(InternalList^[j+1],InternalList^[j],(k-j)*SizeOf(TXMLClass));
  SetCount(k);
  Item.Free;
  result:=j;
 end;
end;

function TXMLClassList.Find(Item:TXMLClass):longint;
var i:longint;
begin
 result:=-1;
 for i:=0 to InternalCount-1 do begin
  if InternalList^[i]=Item then begin
   result:=i;
   exit;
  end;
 end;
end;

function TXMLClassList.IndexOf(Item:TXMLClass):longint;
var i:longint;
begin
 result:=-1;
 for i:=0 to InternalCount-1 do begin
  if InternalList^[i]=Item then begin
   result:=i;
   exit;
  end;
 end;
end;

procedure TXMLClassList.Exchange(Index1,Index2:longint);
var TempPointer:TXMLClass;
begin
 if (Index1>=0) and (Index1<InternalCount) and (Index2>=0) and (Index2<InternalCount) then begin
  TempPointer:=InternalList^[Index1];
  InternalList^[Index1]:=InternalList^[Index2];
  InternalList^[Index2]:=TempPointer;
 end;
end;

function TXMLClassList.Push(Item:TXMLClass):longint;
begin
 result:=Add(Item);
end;

function TXMLClassList.Pop(var Item:TXMLClass):boolean;
begin
 result:=InternalCount>0;
 if result then begin
  Item:=InternalList^[InternalCount-1];
  Delete(InternalCount-1);
 end;
end;

function TXMLClassList.Pop:TXMLClass;
begin
 if InternalCount>0 then begin
  result:=InternalList^[InternalCount-1];
  Delete(InternalCount-1);
 end else begin
  result:=nil;
 end;
end;

function TXMLClassList.Last:TXMLClass;
begin
 if InternalCount>0 then begin
  result:=InternalList^[InternalCount-1];
 end else begin
  result:=nil;
 end;
end;

function TXMLClassList.GetItem(Index:longint):TXMLClass;
begin
 if (Index>=0) and (Index<InternalCount) then begin
  result:=InternalList^[Index];
 end else begin
  result:=nil;
 end;
end;

procedure TXMLClassList.SetItem(Index:longint;Value:TXMLClass);
begin
 if (Index>=0) and (Index<InternalCount) then begin
  InternalList^[Index]:=Value;
 end;
end;

function TXMLClassList.GetItemPointer(Index:longint):TXMLClass;
begin
 if (Index>=0) and (Index<InternalCount) then begin
  result:=@InternalList^[Index];
 end else begin
  result:=nil;
 end;
end;

constructor TXMLClassLinkedList.Create;
begin
 inherited Create;
 ClearWithContentDestroying:=false;
 ClearNoFree;
end;

destructor TXMLClassLinkedList.Destroy;
begin
 Clear;
 inherited Destroy;
end;

procedure TXMLClassLinkedList.Clear;
begin
 if ClearWithContentDestroying then begin
  ClearWithFree;
 end else begin
  ClearNoFree;
 end;
end;

procedure TXMLClassLinkedList.ClearNoFree;
var Current,Next:TXMLClass;
begin
 Current:=First;
 while assigned(Current) do begin
  Next:=Current.Next;
  Remove(Current);
  Current:=Next;
 end;
 First:=nil;
 Last:=nil;
end;

procedure TXMLClassLinkedList.ClearWithFree;
var Current,Next:TXMLClass;
begin
 Current:=First;
 while assigned(Current) do begin
  Next:=Current.Next;
  RemoveClass(Current);
  Current:=Next;
 end;
 First:=nil;
 Last:=nil;
end;

procedure TXMLClassLinkedList.Add(Item:TXMLClass);
begin
 Item.Next:=nil;
 if assigned(Last) then begin
  Last.Next:=Item;
  Item.Previous:=Last;
 end else begin
  Item.Previous:=nil;
  First:=Item;
 end;
 Last:=Item;
end;

procedure TXMLClassLinkedList.Append(Item:TXMLClass);
begin
 Add(Item);
end;

procedure TXMLClassLinkedList.AddLinkedList(List:TXMLClassLinkedList);
begin
 Last.Next:=List.First;
 if assigned(List.First) then begin
  List.First.Previous:=Last;
 end;
 Last:=List.Last;
 List.First:=nil;
 List.Last:=nil;
end;

procedure TXMLClassLinkedList.AppendLinkedList(List:TXMLClassLinkedList);
begin
 AddLinkedList(List);
end;

procedure TXMLClassLinkedList.Remove(Item:TXMLClass);
begin
 if assigned(Item) then begin
  if assigned(Item.Next) then begin
   Item.Next.Previous:=Item.Previous;
  end else if Last=Item then begin
   Last:=Item.Previous;
  end;
  if assigned(Item.Previous) then begin
   Item.Previous.Next:=Item.Next;
  end else if First=Item then begin
   First:=Item.Next;
  end;
  Item.Previous:=nil;
  Item.Next:=nil;
 end;
end;

procedure TXMLClassLinkedList.RemoveClass(Item:TXMLClass);
begin
 if assigned(Item) then begin
  Remove(Item);
  Item.Destroy;
 end;
end;

procedure TXMLClassLinkedList.Push(Item:TXMLClass);
begin
 Add(Item);
end;

function TXMLClassLinkedList.Pop(var Item:TXMLClass):boolean;
begin
 result:=assigned(Last);
 if result then begin
  Item:=Last;
  Remove(Last);
 end;
end;

function TXMLClassLinkedList.Pop:TXMLClass;
begin
 result:=Last;
 if assigned(Last) then begin
  Remove(Last);
 end;
end;

function TXMLClassLinkedList.Count:longint;
var Current:TXMLClass;
begin
 result:=0;
 Current:=First;
 while assigned(Current) do begin
  inc(result);
  Current:=Current.Next;
 end;
end;

constructor TXMLStringTree.Create;
begin
 inherited Create;
 Root:=nil;
 Clear;
end;

destructor TXMLStringTree.Destroy;
begin
 Clear;
 inherited Destroy;
end;

function TXMLStringTree.CreateStringTreeNode(AChar:ansichar):PXMLStringTreeNode;
begin
 GetMem(result,SizeOf(TXMLStringTreeNode));
 result^.TheChar:=AChar;
 result^.Data:=0;
 result^.DataExist:=false;
 result^.Prevoius:=nil;
 result^.Next:=nil;
 result^.Up:=nil;
 result^.Down:=nil;
end;

procedure TXMLStringTree.DestroyStringTreeNode(Node:PXMLStringTreeNode);
begin
 if assigned(Node) then begin
  DestroyStringTreeNode(Node^.Next);
  DestroyStringTreeNode(Node^.Down);
  FreeMem(Node);
 end;
end;

procedure TXMLStringTree.Clear;
begin
 DestroyStringTreeNode(Root);
 Root:=nil;
end;

procedure TXMLStringTree.DumpTree;
var Ident:longint;
 procedure DumpNode(Node:PXMLStringTreeNode);
 var SubNode:PXMLStringTreeNode;
     IdentCounter,IdentOld:longint;
 begin
  for IdentCounter:=1 to Ident do begin
   write(' ');
  end;
  write(Node^.TheChar);
  IdentOld:=Ident;
  SubNode:=Node^.Next;
  while assigned(SubNode) do begin
   write(SubNode.TheChar);
   if not assigned(SubNode^.Next) then begin
    break;
   end;
   inc(Ident);
   SubNode:=SubNode^.Next;
  end;
  writeln;
  inc(Ident);
  while assigned(SubNode) and (SubNode<>Node) do begin
   if assigned(SubNode^.Down) then begin
    DumpNode(SubNode^.Down);
   end;
   SubNode:=SubNode^.Prevoius;
   dec(Ident);
  end;
  Ident:=IdentOld;
  if assigned(Node^.Down) then begin
   DumpNode(Node^.Down);
  end;
 end;
begin
 Ident:=0;
 DumpNode(Root);
end;

procedure TXMLStringTree.DumpList;
 procedure DumpNode(Node:PXMLStringTreeNode;ParentStr:ansistring);
 begin
  if assigned(Node) then begin
   ParentStr:=ParentStr;
   if Node^.DataExist then begin
    writeln(ParentStr+Node^.TheChar);
   end;
   if assigned(Node^.Next) then begin
    DumpNode(Node^.Next,ParentStr+Node^.TheChar);
   end;
   if assigned(Node^.Down) then begin
    DumpNode(Node^.Down,ParentStr);
   end;
  end;
 end;
begin
 if assigned(Root) then begin
  DumpNode(Root,'');
 end;
end;

procedure TXMLStringTree.AppendTo(DestStringTree:TXMLStringTree);
 procedure DumpNode(Node:PXMLStringTreeNode;ParentStr:ansistring);
 begin
  if assigned(Node) then begin
   ParentStr:=ParentStr;
   if Node^.DataExist then begin
    DestStringTree.Add(ParentStr+Node^.TheChar,Node^.Data);
   end;
   if assigned(Node^.Next) then begin
    DumpNode(Node^.Next,ParentStr+Node^.TheChar);
   end;
   if assigned(Node^.Down) then begin
    DumpNode(Node^.Down,ParentStr);
   end;
  end;
 end;
begin
 if assigned(DestStringTree) and assigned(Root) then begin
  DumpNode(Root,'');
 end;
end;

procedure TXMLStringTree.Optimize(DestStringTree:TXMLStringTree);
 procedure DumpNode(Node:PXMLStringTreeNode;ParentStr:ansistring);
 begin
  if assigned(Node) then begin
   ParentStr:=ParentStr;
   if Node^.DataExist then begin
    DestStringTree.Add(ParentStr+Node^.TheChar,Node^.Data);
   end;
   if assigned(Node^.Next) then begin
    DumpNode(Node^.Next,ParentStr+Node^.TheChar);
   end;
   if assigned(Node^.Down) then begin
    DumpNode(Node^.Down,ParentStr);
   end;
  end;
 end;
begin
 if assigned(DestStringTree) then begin
  DestStringTree.Clear;
  if assigned(Root) then begin
   DumpNode(Root,'');
  end;
 end;
end;

function TXMLStringTree.Add(Content:ansistring;Data:TXMLStringTreeData;Replace:boolean=false):boolean;
var StringLength,Position,PositionCounter:longint;
    NewNode,LastNode,Node:PXMLStringTreeNode;
    StringChar,NodeChar:ansichar;
begin
 result:=false;
 StringLength:=length(Content);
 if StringLength>0 then begin
  LastNode:=nil;
  Node:=Root;
  for Position:=1 to StringLength do begin
   StringChar:=Content[Position];
   if assigned(Node) then begin
    NodeChar:=Node^.TheChar;
    if NodeChar=StringChar then begin
     LastNode:=Node;
     Node:=Node^.Next;
    end else begin
     while (NodeChar<StringChar) and assigned(Node^.Down) do begin
      Node:=Node^.Down;
      NodeChar:=Node^.TheChar;
     end;
     if NodeChar=StringChar then begin
      LastNode:=Node;
      Node:=Node^.Next;
     end else begin
      NewNode:=CreateStringTreeNode(StringChar);
      if NodeChar<StringChar then begin
       NewNode^.Down:=Node^.Down;
       NewNode^.Up:=Node;
       if assigned(NewNode^.Down) then begin
        NewNode^.Down^.Up:=NewNode;
       end;
       NewNode^.Prevoius:=Node^.Prevoius;
       Node^.Down:=NewNode;
      end else if NodeChar>StringChar then begin
       NewNode^.Down:=Node;
       NewNode^.Up:=Node^.Up;
       if assigned(NewNode^.Up) then begin
        NewNode^.Up^.Down:=NewNode;
       end;
       NewNode^.Prevoius:=Node^.Prevoius;
       if not assigned(NewNode^.Up) then begin
        if assigned(NewNode^.Prevoius) then begin
         NewNode^.Prevoius^.Next:=NewNode;
        end else begin
         Root:=NewNode;
        end;
       end;
       Node^.Up:=NewNode;
      end;
      LastNode:=NewNode;
      Node:=LastNode^.Next;
     end;
    end;
   end else begin
    for PositionCounter:=Position to StringLength do begin
     NewNode:=CreateStringTreeNode(Content[PositionCounter]);
     if assigned(LastNode) then begin
      NewNode^.Prevoius:=LastNode;
      LastNode^.Next:=NewNode;
      LastNode:=LastNode^.Next;
     end else begin
      if not assigned(Root) then begin
       Root:=NewNode;
       LastNode:=Root;
      end;
     end;
    end;
    break;
   end;
  end;
  if assigned(LastNode) then begin
   if Replace or not LastNode^.DataExist then begin
    LastNode^.Data:=Data;
    LastNode^.DataExist:=true;
    result:=true;
   end;
  end;
 end;
end;

function TXMLStringTree.Delete(Content:ansistring):boolean;
var StringLength,Position:longint;
    Node:PXMLStringTreeNode;
    StringChar,NodeChar:ansichar;
begin
 result:=false;
 StringLength:=length(Content);
 if StringLength>0 then begin
  Node:=Root;
  for Position:=1 to StringLength do begin
   StringChar:=Content[Position];
   if assigned(Node) then begin
    NodeChar:=Node^.TheChar;
    while (NodeChar<>StringChar) and assigned(Node^.Down) do begin
     Node:=Node^.Down;
     NodeChar:=Node^.TheChar;
    end;
    if NodeChar=StringChar then begin
     if (Position=StringLength) and Node^.DataExist then begin
      Node^.DataExist:=false;
      result:=true;
      exit;
     end;
     Node:=Node^.Next;
    end else begin
     break;
    end;
   end else begin
    break;
   end;
  end;
 end;
end;

function TXMLStringTree.Find(Content:ansistring;var Data:TXMLStringTreeData):boolean;
var StringLength,Position:longint;
    Node:PXMLStringTreeNode;
    StringChar,NodeChar:ansichar;
begin
 result:=false;
 StringLength:=length(Content);
 if StringLength>0 then begin
  Node:=Root;
  for Position:=1 to StringLength do begin
   StringChar:=Content[Position];
   if assigned(Node) then begin
    NodeChar:=Node^.TheChar;
    while (NodeChar<>StringChar) and assigned(Node^.Down) do begin
     Node:=Node^.Down;
     NodeChar:=Node^.TheChar;
    end;
    if NodeChar=StringChar then begin
     if (Position=StringLength) and Node^.DataExist then begin
      Data:=Node^.Data;
      result:=true;
      exit;
     end;
     Node:=Node^.Next;
    end else begin
     break;
    end;
   end else begin
    break;
   end;
  end;
 end;
end;

function TXMLStringTree.FindEx(Content:ansistring;var Data:TXMLStringTreeData;var Len:longint):boolean;
var StringLength,Position:longint;
    Node:PXMLStringTreeNode;
    StringChar,NodeChar:ansichar;
begin
 result:=false;
 Len:=0;
 StringLength:=length(Content);
 if StringLength>0 then begin
  Node:=Root;
  for Position:=1 to StringLength do begin
   StringChar:=Content[Position];
   if assigned(Node) then begin
    NodeChar:=Node^.TheChar;
    while (NodeChar<>StringChar) and assigned(Node^.Down) do begin
     Node:=Node^.Down;
     NodeChar:=Node^.TheChar;
    end;
    if NodeChar=StringChar then begin
     if Node^.DataExist then begin
      Len:=Position;
      Data:=Node^.Data;
      result:=true;
     end;
     Node:=Node^.Next;
    end else begin
     break;
    end;
   end else begin
    break;
   end;
  end;
 end;
end;

constructor TXMLItem.Create;
begin
 inherited Create;
 Items:=TXMLItemList.Create;
end;

destructor TXMLItem.Destroy;
begin
 Items.Destroy;
 inherited Destroy;
end;

procedure TXMLItem.Clear;
begin
 Items.Clear;
end;

procedure TXMLItem.Add(Item:TXMLItem);
begin
 Items.Add(Item);
end;

procedure TXMLItem.Assign(From:TXMLItem);
var i:longint;
    NewItem:TXMLItem;
begin
 Items.ClearWithFree;
 NewItem:=nil;
 for i:=0 to Items.Count-1 do begin
  if Items[i] is TXMLTag then begin
   NewItem:=TXMLTag.Create;
  end else if Items[i] is TXMLCommentTag then begin
   NewItem:=TXMLCommentTag.Create;
  end else if Items[i] is TXMLScriptTag then begin
   NewItem:=TXMLScriptTag.Create;
  end else if Items[i] is TXMLProcessTag then begin
   NewItem:=TXMLProcessTag.Create;
  end else if Items[i] is TXMLCDATATag then begin
   NewItem:=TXMLCDATATag.Create;
  end else if Items[i] is TXMLDOCTYPETag then begin
   NewItem:=TXMLDOCTYPETag.Create;
  end else if Items[i] is TXMLExtraTag then begin
   NewItem:=TXMLExtraTag.Create;
  end else if Items[i] is TXMLText then begin
   NewItem:=TXMLText.Create;
  end else if Items[i] is TXMLItem then begin
   NewItem:=Items[i].Create;
  end else begin
   continue;
  end;
  NewItem.Assign(Items[i]);
  Items.Add(NewItem);
 end;
end;

function TXMLItem.FindTag(const TagName:ansistring):TXMLTag;
begin
 result:=Items.FindTag(TagName);
end;

constructor TXMLItemList.Create;
begin
 inherited Create;
 ClearWithContentDestroying:=true;
//CapacityMask:=$f;
 CapacityMinimium:=0;
end;

destructor TXMLItemList.Destroy;
begin
 ClearWithFree;
 inherited Destroy;
end;

function TXMLItemList.NewClass:TXMLItem;
begin
 result:=TXMLItem.Create;
 Add(result);
end;

function TXMLItemList.GetItem(Index:longint):TXMLItem;
begin
 result:=TXMLItem(inherited Items[Index]);
end;

procedure TXMLItemList.SetItem(Index:longint;Value:TXMLItem);
begin
 inherited Items[Index]:=Value;
end;

function TXMLItemList.FindTag(const TagName:ansistring):TXMLTag;
var i:longint;
    Item:TXMLItem;
begin
 result:=nil;
 for i:=0 to Count-1 do begin
  Item:=TXMLItem(inherited Items[i]);
  if (assigned(Item) and (Item is TXMLTag)) and (TXMLTag(Item).Name=TagName) then begin
   result:=TXMLTag(Item);
   break;
  end;
 end;
end;

constructor TXMLParameter.Create;
begin
 inherited Create;
 Name:='';
 Value:='';
end;

destructor TXMLParameter.Destroy;
begin
 Name:='';
 Value:='';
 inherited Destroy;
end;

procedure TXMLParameter.Assign(From:TXMLParameter);
begin
 Name:=From.Name;
 Value:=From.Value;
end;

constructor TXMLText.Create;
begin
 inherited Create;
 Text:='';
end;

destructor TXMLText.Destroy;
begin
 Text:='';
 inherited Destroy;
end;

procedure TXMLText.Assign(From:TXMLItem);
begin
 inherited Assign(From);
 if From is TXMLText then begin
  Text:=TXMLText(From).Text;
 end;
end;

procedure TXMLText.SetText(AText:ansistring);
begin
 Text:=AText;
end;

constructor TXMLCommentTag.Create;
begin
 inherited Create;
 Text:='';
end;

destructor TXMLCommentTag.Destroy;
begin
 Text:='';
 inherited Destroy;
end;

procedure TXMLCommentTag.Assign(From:TXMLItem);
begin
 inherited Assign(From);
 if From is TXMLCommentTag then begin
  Text:=TXMLCommentTag(From).Text;
 end;
end;

procedure TXMLCommentTag.SetText(AText:ansistring);
begin
 Text:=AText;
end;

constructor TXMLTag.Create;
begin
 inherited Create;
 Name:='';
 Parameter:=nil;
end;

destructor TXMLTag.Destroy;
begin
 Clear;
 inherited Destroy;
end;

procedure TXMLTag.Clear;
var Counter:longint;
begin
 inherited Clear;
 for Counter:=0 to length(Parameter)-1 do begin
  Parameter[Counter].Free;
 end;
 SetLength(Parameter,0);
 Name:='';
end;

procedure TXMLTag.Assign(From:TXMLItem);
var Counter:longint;
begin
 inherited Assign(From);
 if From is TXMLTag then begin
  for Counter:=0 to length(Parameter)-1 do begin
   Parameter[Counter].Free;
  end;
  SetLength(Parameter,0);
  Name:=TXMLTag(From).Name;
  for Counter:=0 to length(TXMLTag(From).Parameter)-1 do begin
   AddParameter(TXMLTag(From).Parameter[Counter].Name,TXMLTag(From).Parameter[Counter].Value);
  end;
 end;
end;

function TXMLTag.FindParameter(ParameterName:ansistring):TXMLParameter;
var i:longint;
begin
 for i:=0 to length(Parameter)-1 do begin
  if Parameter[i].Name=ParameterName then begin
   result:=Parameter[i];
   exit;
  end;
 end;
 result:=nil;
end;

function TXMLTag.GetParameter(ParameterName:ansistring;default:ansistring=''):ansistring;
var i:longint;
begin
 for i:=0 to length(Parameter)-1 do begin
  if Parameter[i].Name=ParameterName then begin
   result:=Parameter[i].Value;
   exit;
  end;
 end;
 result:=default;
end;

function TXMLTag.AddParameter(AParameter:TXMLParameter):boolean;
var Index:longint;
begin
 try
  Index:=length(Parameter);
  SetLength(Parameter,Index+1);
  Parameter[Index]:=AParameter;
  result:=true;
 except
  result:=false;
 end;
end;

function TXMLTag.AddParameter(Name:ansistring;Value:TXMLString):boolean;
var AParameter:TXMLParameter;
begin
 AParameter:=TXMLParameter.Create;
 AParameter.Name:=Name;
 AParameter.Value:=Value;
 result:=AddParameter(AParameter);
end;

function TXMLTag.RemoveParameter(AParameter:TXMLParameter):boolean;
var Found,Counter:longint;
begin
 result:=false;
 try
  Found:=-1;
  for Counter:=0 to length(Parameter)-1 do begin
   if Parameter[Counter]=AParameter then begin
    Found:=Counter;
    break;
   end;
  end;
  if Found>=0 then begin
   for Counter:=Found to length(Parameter)-2 do begin
    Parameter[Counter]:=Parameter[Counter+1];
   end;
   SetLength(Parameter,length(Parameter)-1);
   AParameter.Destroy;
   result:=true;
  end;
 except
 end;
end;

function TXMLTag.RemoveParameter(ParameterName:ansistring):boolean;
begin
 result:=RemoveParameter(FindParameter(ParameterName));
end;

constructor TXMLProcessTag.Create;
begin
 inherited Create;
end;

destructor TXMLProcessTag.Destroy;
begin
 inherited Destroy;
end;

procedure TXMLProcessTag.Assign(From:TXMLItem);
begin
 inherited Assign(From);
end;

constructor TXMLScriptTag.Create;
begin
 inherited Create;
 Text:='';
end;

destructor TXMLScriptTag.Destroy;
begin
 Text:='';
 inherited Destroy;
end;

procedure TXMLScriptTag.Assign(From:TXMLItem);
begin
 inherited Assign(From);
 if From is TXMLScriptTag then begin
  Text:=TXMLScriptTag(From).Text;
 end;
end;

procedure TXMLScriptTag.SetText(AText:ansistring);
begin
 Text:=AText;
end;

constructor TXMLCDataTag.Create;
begin
 inherited Create;
 Text:='';
end;

destructor TXMLCDataTag.Destroy;
begin
 Text:='';
 inherited Destroy;
end;

procedure TXMLCDataTag.Assign(From:TXMLItem);
begin
 inherited Assign(From);
 if From is TXMLCDataTag then begin
  Text:=TXMLCDataTag(From).Text;
 end;
end;

procedure TXMLCDataTag.SetText(AText:ansistring);
begin
 Text:=AText;
end;

constructor TXMLDOCTYPETag.Create;
begin
 inherited Create;
 Text:='';
end;

destructor TXMLDOCTYPETag.Destroy;
begin
 Text:='';
 inherited Destroy;
end;

procedure TXMLDOCTYPETag.Assign(From:TXMLItem);
begin
 inherited Assign(From);
 if From is TXMLDOCTYPETag then begin
  Text:=TXMLDOCTYPETag(From).Text;
 end;
end;

procedure TXMLDOCTYPETag.SetText(AText:ansistring);
begin
 Text:=AText;
end;

constructor TXMLExtraTag.Create;
begin
 inherited Create;
 Text:='';
end;

destructor TXMLExtraTag.Destroy;
begin
 Text:='';
 inherited Destroy;
end;

procedure TXMLExtraTag.Assign(From:TXMLItem);
begin
 inherited Assign(From);
 if From is TXMLExtraTag then begin
  Text:=TXMLExtraTag(From).Text;
 end;
end;

procedure TXMLExtraTag.SetText(AText:ansistring);
begin
 Text:=AText;
end;

constructor TXML.Create;
begin
 inherited Create;
 InitializeEntites;
 Root:=TXMLItem.Create;
 AutomaticAloneTagDetection:=true;
 FormatIndent:=true;
 FormatIndentText:=false;
end;

destructor TXML.Destroy;
begin
 Root.Free;
 inherited Destroy;
end;

procedure TXML.Assign(From:TXML);
begin
 Root.Assign(From.Root);
 AutomaticAloneTagDetection:=From.AutomaticAloneTagDetection;
 FormatIndent:=From.FormatIndent;
 FormatIndentText:=From.FormatIndentText;
end;

function TXML.Parse(Stream:TStream):boolean;
const NameCanBeginWithCharSet:set of ansichar=['A'..'Z','a'..'z','_'];
      NameCanContainCharSet:set of ansichar=['A'..'Z','a'..'z','0'..'9','.',':','_','-'];
      BlankCharSet:set of ansichar=[#0..#$20];//[#$9,#$A,#$D,#$20];
type TEncoding=(etASCII,etUTF8,etUTF16);
var Errors:boolean;
    CurrentChar:ansichar;
    StreamEOF:boolean;
    Encoding:TEncoding;

 function IsEOF:boolean;
 begin
  result:=StreamEOF or (Stream.Position>Stream.Size);
 end;

 function IsEOFOrErrors:boolean;
 begin
  result:=IsEOF or Errors;
 end;

 function NextChar:ansichar;
 begin
  if Stream.Read(CurrentChar,SizeOf(ansichar))<>SizeOf(ansichar) then begin
   StreamEOF:=true;
   CurrentChar:=#0;
  end;
  result:=CurrentChar;
//system.Write(result);
 end;

 procedure SkipBlank;
 begin
  while (CurrentChar in BlankCharSet) and not IsEOFOrErrors do begin
   NextChar;
  end;
 end;

 function GetName:ansistring;
 var i:longint;
 begin
  result:='';
  i:=0;
  if (CurrentChar in NameCanBeginWithCharSet) and not IsEOFOrErrors then begin
   while (CurrentChar in NameCanContainCharSet) and not IsEOFOrErrors do begin
    inc(i);
    if (i+1)>length(result) then begin
     SetLength(result,NextPowerOfTwo(i+1));
    end;
    result[i]:=CurrentChar;
    NextChar;
   end;
  end;
  SetLength(result,i);
 end;

 function ExpectToken(const S:ansistring):boolean; overload;
 var i:longint;
 begin
  result:=true;
  for i:=1 to length(S) do begin
   if S[i]<>CurrentChar then begin
    result:=false;
    break;
   end;
   NextChar;
  end;
 end;

 function ExpectToken(const c:ansichar):boolean; overload;
 begin
  result:=false;
  if c=CurrentChar then begin
   result:=true;
   NextChar;
  end;
 end;

 function GetUntil(var Content:ansistring;const TerminateToken:ansistring):boolean;
 var i,j,OldPosition:longint;
     OldEOF:boolean;
     OldChar:ansichar;
 begin
  result:=false;
  j:=0;
  Content:='';
  while not IsEOFOrErrors do begin
   if (length(TerminateToken)>0) and (TerminateToken[1]=CurrentChar) and (((Stream.Size-Stream.Position)+1)>=length(TerminateToken)) then begin
    OldPosition:=Stream.Position;
    OldEOF:=StreamEOF;
    OldChar:=CurrentChar;
    for i:=1 to length(TerminateToken) do begin
     if TerminateToken[i]=CurrentChar then begin
      if i=length(TerminateToken) then begin
       NextChar;
       SetLength(Content,j);
       result:=true;
       exit;
      end;
     end else begin
      break;
     end;
     NextChar;
    end;
    Stream.Seek(OldPosition,soFromBeginning);
    StreamEOF:=OldEOF;
    CurrentChar:=OldChar;
   end;
   inc(j);
   if (j+1)>length(Content) then begin
    SetLength(Content,NextPowerOfTwo(j+1));
   end;
   Content[j]:=CurrentChar;
   NextChar;
  end;
  SetLength(Content,j);
 end;

 function GetDecimalValue:longint;
 var Negitive:boolean;
 begin
  Negitive:=CurrentChar='-';
  if Negitive then begin
   NextChar;
  end else if CurrentChar='+' then begin
   NextChar;
  end;
  result:=0;
  while (CurrentChar in ['0'..'9']) and not IsEOFOrErrors do begin
   result:=(result*10)+(ord(CurrentChar)-ord('0'));
   NextChar;
  end;
  if Negitive then begin
   result:=-result;
  end;
 end;

 function GetHeximalValue:longint;
 var Negitive:boolean;
     Value:longint;
 begin
  Negitive:=CurrentChar='-';
  if Negitive then begin
   NextChar;
  end else if CurrentChar='+' then begin
   NextChar;
  end;
  result:=0;
  Value:=0;
  while not IsEOFOrErrors do begin
   case CurrentChar of
    '0'..'9':begin
     Value:=byte(CurrentChar)-ord('0');
    end;
    'A'..'F':begin
     Value:=byte(CurrentChar)-ord('A')+$a;
    end;
    'a'..'f':begin
     Value:=byte(CurrentChar)-ord('a')+$a;
    end;
    else begin
     break;
    end;
   end;
   result:=(result*16)+Value;
   NextChar;
  end;
  if Negitive then begin
   result:=-result;
  end;
 end;

 function GetEntity:TXMLString;
 var Value:longint;
     Entity:ansistring;
     c:TXMLChar;
     EntityLink:TXMLStringTreeData;
 begin
  result:='';
  if CurrentChar='&' then begin
   NextChar;
   if not IsEOF then begin
    if CurrentChar='#' then begin
     NextChar;
     if IsEOF then begin
      Errors:=true;
     end else begin
      if CurrentChar='x' then begin
       NextChar;
       Value:=GetHeximalValue;
      end else begin
       Value:=GetDecimalValue;
      end;
      if CurrentChar=';' then begin
       NextChar;
{$ifdef UNICODE}
       c:=widechar(word(Value));
{$else}
       c:=ansichar(byte(Value));
{$endif}
       result:=c;
      end else begin
       Errors:=true;
      end;
     end;
    end else begin
     Entity:='&';
     while (CurrentChar in ['a'..'z','A'..'Z','0'..'9','_']) and not IsEOFOrErrors do begin
      Entity:=Entity+CurrentChar;
      NextChar;
     end;
     if CurrentChar=';' then begin
      Entity:=Entity+CurrentChar;
      NextChar;
      if EntityStringTree.Find(Entity,EntityLink) then begin
       result:=EntityChars[EntityLink,2];
      end else begin
       result:=Entity;
      end;
     end else begin
      Errors:=true;
     end;
    end;
   end;
  end;
 end;

 function ParseTagParameterValue(TerminateChar:ansichar):TXMLString;
 var i,wc,c:longint;
 begin
  result:='';
  SkipBlank;
  i:=0;
  while (CurrentChar<>TerminateChar) and not IsEOFOrErrors do begin
   if (Encoding=etUTF8) and (ord(CurrentChar)>=$80) then begin
    wc:=ord(CurrentChar) and $3f;
    if (wc and $20)<>0 then begin
     NextChar;
     c:=ord(CurrentChar);
     if (c and $c0)<>$80 then begin
      break;
     end;
     wc:=(wc shl 6) or (c and $3f);
    end;
    NextChar;
    c:=ord(CurrentChar);
    if (c and $c0)<>$80 then begin
     break;
    end;
    wc:=(wc shl 6) or (c and $3f);
    NextChar;
    inc(i);
    if (i+1)>length(result) then begin
     SetLength(result,NextPowerOfTwo(i+1));
    end;
{$ifdef UNICODE}
    result[i]:=widechar(wc);
{$else}
    result[i]:=ansichar(wc);
{$endif}
   end else if CurrentChar='&' then begin
    SetLength(result,i);
    result:=result+GetEntity;
    i:=length(result);
   end else begin
    inc(i);
    if (i+1)>length(result) then begin
     SetLength(result,NextPowerOfTwo(i+1));
    end;
{$ifdef UNICODE}
    result[i]:=widechar(word(byte(CurrentChar)+0));
{$else}
    result[i]:=CurrentChar;
{$endif}
    NextChar;
   end;
  end;
  SetLength(result,i);
  NextChar;
 end;

 procedure ParseTagParameter(XMLTag:TXMLTag);
 var ParameterName,ParameterValue:ansistring;
     TerminateChar:ansichar;
 begin
  SkipBlank;
  while (CurrentChar in NameCanBeginWithCharSet) and not IsEOFOrErrors do begin
   ParameterName:=GetName;
   SkipBlank;
   if CurrentChar='=' then begin
    NextChar;
    if IsEOFOrErrors then begin
     Errors:=true;
     break;
    end;
   end else begin
    Errors:=true;
    break;
   end;
   SkipBlank;
   if CurrentChar in ['''','"'] then begin
    TerminateChar:=CurrentChar;
    NextChar;
    if IsEOFOrErrors then begin
     Errors:=true;
     break;
    end;
    ParameterValue:=ParseTagParameterValue(TerminateChar);
    if Errors then begin
     break;
    end else begin
     XMLTag.AddParameter(ParameterName,ParameterValue);
     SkipBlank;
    end;
   end else begin
    Errors:=true;
    break;
   end;
  end;
 end;

 procedure Process(ParentItem:TXMLItem;Closed:boolean);
 var FinishLevel:boolean;

  procedure ParseText;
  var Text:TXMLString;
      XMLText:TXMLText;
      i,wc,c:longint;
{$ifndef UNICODE}
      w:ansistring;
{$endif}
  begin
   SkipBlank;
   if CurrentChar='<' then begin
    exit;
   end;
   i:=0;
   Text:='';
   SetLength(Text,16);
   while (CurrentChar<>'<') and not IsEOFOrErrors do begin
    if (Encoding=etUTF8) and (ord(CurrentChar)>=$80) then begin
     wc:=ord(CurrentChar) and $3f;
     if (wc and $20)<>0 then begin
      NextChar;
      c:=ord(CurrentChar);
      if (c and $c0)<>$80 then begin
       break;
      end;
      wc:=(wc shl 6) or (c and $3f);
     end;
     NextChar;
     c:=ord(CurrentChar);
     if (c and $c0)<>$80 then begin
      break;
     end;
     wc:=(wc shl 6) or (c and $3f);
     NextChar;
{$ifdef UNICODE}
     if wc<=$d7ff then begin
      inc(i);
      if (i+1)>length(Text) then begin
       SetLength(Text,NextPowerOfTwo(i+1));
      end;
      Text[i]:=widechar(word(wc));
     end else if wc<=$dfff then begin
      inc(i);
      if (i+1)>length(Text) then begin
       SetLength(Text,NextPowerOfTwo(i+1));
      end;
      Text[i]:=#$fffd;
     end else if wc<=$fffd then begin
      inc(i);
      if (i+1)>length(Text) then begin
       SetLength(Text,NextPowerOfTwo(i+1));
      end;
      Text[i]:=widechar(word(wc));
     end else if wc<=$ffff then begin
      inc(i);
      if (i+1)>length(Text) then begin
       SetLength(Text,NextPowerOfTwo(i+1));
      end;
      Text[i]:=#$fffd;
     end else if wc<=$10ffff then begin
      dec(wc,$10000);
      inc(i);
      if (i+1)>length(Text) then begin
       SetLength(Text,NextPowerOfTwo(i+1));
      end;
      Text[i]:=widechar(word((wc shr 10) or $d800));
      inc(i);
      if (i+1)>length(Text) then begin
       SetLength(Text,NextPowerOfTwo(i+1));
      end;
      Text[i]:=widechar(word((wc and $3ff) or $dc00));
     end else begin
      inc(i);
      if (i+1)>length(Text) then begin
       SetLength(Text,NextPowerOfTwo(i+1));
      end;
      Text[i]:=#$fffd;
     end;
{$else}
     if wc<$80 then begin
      inc(i);
      if (i+1)>length(Text) then begin
       SetLength(Text,NextPowerOfTwo(i+1));
      end;
      Text[i]:=ansichar(byte(wc));
     end else begin
      w:=UTF32CharToUTF8(wc);
      if length(w)>0 then begin
       inc(i);
       if (i+length(w)+1)>length(Text) then begin
        SetLength(Text,NextPowerOfTwo(i+length(w)+1));
       end;
       Move(w[1],Text[i],length(w));
       inc(i,length(w)-1);
      end;
     end;
{$endif}
    end else if CurrentChar='&' then begin
     SetLength(Text,i);
     Text:=Text+GetEntity;
     i:=length(Text);
    end else if CurrentChar in BlankCharSet then begin
{$ifdef UNICODE}
     inc(i);
     if (i+1)>length(Text) then begin
      SetLength(Text,NextPowerOfTwo(i+1));
     end;
     Text[i]:=widechar(word(byte(CurrentChar)+0));
{$else}
     wc:=ord(CurrentChar);
     if wc<$80 then begin
      inc(i);
      if (i+1)>length(Text) then begin
       SetLength(Text,NextPowerOfTwo(i+1));
      end;
      Text[i]:=ansichar(byte(wc));
     end else begin
      w:=UTF32CharToUTF8(wc);
      if length(w)>0 then begin
       inc(i);
       if (i+length(w)+1)>length(Text) then begin
        SetLength(Text,NextPowerOfTwo(i+length(w)+1));
       end;
       Move(w[1],Text[i],length(w));
       inc(i,length(w)-1);
      end;
     end;
{$endif}
     SkipBlank;
    end else begin
{$ifdef UNICODE}
     inc(i);
     if (i+1)>length(Text) then begin
      SetLength(Text,NextPowerOfTwo(i+1));
     end;
     Text[i]:=widechar(word(byte(CurrentChar)+0));
{$else}
     wc:=ord(CurrentChar);
     if wc<$80 then begin
      inc(i);
      if (i+1)>length(Text) then begin
       SetLength(Text,NextPowerOfTwo(i+1));
      end;
      Text[i]:=ansichar(byte(wc));
     end else begin
      w:=UTF32CharToUTF8(wc);
      if length(w)>0 then begin
       inc(i);
       if (i+length(w)+1)>length(Text) then begin
        SetLength(Text,NextPowerOfTwo(i+length(w)+1));
       end;
       Move(w[1],Text[i],length(w));
       inc(i,length(w)-1);
      end;
     end;
{$endif}
     NextChar;
    end;
   end;
   SetLength(Text,i);
   if length(Text)<>0 then begin
    XMLText:=TXMLText.Create;
    XMLText.Text:=Text;
    ParentItem.Add(XMLText);
   end;
  end;

  procedure ParseProcessTag;
  var TagName,EncodingName:ansistring;
      XMLProcessTag:TXMLProcessTag;
  begin
   if not ExpectToken('?') then begin
    Errors:=true;
    exit;
   end;
   TagName:=GetName;
   if IsEOF or Errors then begin
    Errors:=true;
    exit;
   end;
   XMLProcessTag:=TXMLProcessTag.Create;
   XMLProcessTag.Name:=TagName;
   ParentItem.Add(XMLProcessTag);
   ParseTagParameter(XMLProcessTag);
   if not ExpectToken('?>') then begin
    Errors:=true;
    exit;
   end;
   if XMLProcessTag.Name='xml' then begin
    EncodingName:=UPPERCASE(XMLProcessTag.GetParameter('encoding','ascii'));
    if EncodingName='UTF-8' then begin
     Encoding:=etUTF8;
    end else if EncodingName='UTF-16' then begin
     Encoding:=etUTF16;
    end else begin
     Encoding:=etASCII;
    end;
   end;
  end;

  procedure ParseScriptTag;
  var XMLScriptTag:TXMLScriptTag;
  begin
   if not ExpectToken('%') then begin
    Errors:=true;
    exit;
   end;
   if IsEOFOrErrors then begin
    Errors:=true;
    exit;
   end;
   XMLScriptTag:=TXMLScriptTag.Create;
   ParentItem.Add(XMLScriptTag);
   if not GetUntil(XMLScriptTag.Text,'%>') then begin
    Errors:=true;
   end;
  end;

  procedure ParseCommentTag;
  var XMLCommentTag:TXMLCommentTag;
  begin
   if not ExpectToken('--') then begin
    Errors:=true;
    exit;
   end;
   if IsEOFOrErrors then begin
    Errors:=true;
    exit;
   end;
   XMLCommentTag:=TXMLCommentTag.Create;
   ParentItem.Add(XMLCommentTag);
   if not GetUntil(XMLCommentTag.Text,'-->') then begin
    Errors:=true;
   end;
  end;

  procedure ParseCDATATag;
  var XMLCDataTag:TXMLCDataTag;
  begin
   if not ExpectToken('[CDATA[') then begin
    Errors:=true;
    exit;
   end;
   if IsEOFOrErrors then begin
    Errors:=true;
    exit;
   end;
   XMLCDataTag:=TXMLCDataTag.Create;
   ParentItem.Add(XMLCDataTag);
   if not GetUntil(XMLCDataTag.Text,']]>') then begin
    Errors:=true;
   end;
  end;

  procedure ParseDOCTYPEOrExtraTag;
  var Content:ansistring;
      XMLDOCTYPETag:TXMLDOCTYPETag;
      XMLExtraTag:TXMLExtraTag;
  begin
   Content:='';
   if not GetUntil(Content,'>') then begin
    Errors:=true;
    exit;
   end;
   if POS('DOCTYPE',Content)=1 then begin
    XMLDOCTYPETag:=TXMLDOCTYPETag.Create;
    ParentItem.Add(XMLDOCTYPETag);
    XMLDOCTYPETag.Text:=TRIMLEFT(COPY(Content,8,length(Content)-7));
   end else begin
    XMLExtraTag:=TXMLExtraTag.Create;
    ParentItem.Add(XMLExtraTag);
    XMLExtraTag.Text:=Content;
   end;
  end;

  procedure ParseTag;
  var TagName:ansistring;
      XMLTag:TXMLTag;
      IsAloneTag:boolean;
  begin
   if CurrentChar='/' then begin
    NextChar;
    if IsEOFOrErrors then begin
     Errors:=true;
     exit;
    end;
    TagName:='/'+GetName;
   end else begin
    TagName:=GetName;
   end;
   if IsEOFOrErrors then begin
    Errors:=true;
    exit;
   end;

   XMLTag:=TXMLTag.Create;
   XMLTag.Name:=TagName;
   ParseTagParameter(XMLTag);

   IsAloneTag:=CurrentChar='/';
   if IsAloneTag then begin
    NextChar;
    if IsEOFOrErrors then begin
     Errors:=true;
     exit;
    end;
   end;

   if CurrentChar<>'>' then begin
    Errors:=true;
    exit;
   end;
   NextChar;

   if (ParentItem<>Root) and (ParentItem is TXMLTag) and (XMLTag.Name='/'+TXMLTag(ParentItem).Name) then begin
    XMLTag.Destroy;
    FinishLevel:=true;
    Closed:=true;
   end else begin
    ParentItem.Add(XMLTag);
    if not IsAloneTag then begin
     Process(XMLTag,false);
    end;
   end;
// IsAloneTag:=false;
  end;

 begin
  FinishLevel:=false;
  while not (IsEOFOrErrors or FinishLevel) do begin
   ParseText;
   if CurrentChar='<' then begin
    NextChar;
    if not IsEOFOrErrors then begin
     if CurrentChar='/' then begin
      ParseTag;
     end else if CurrentChar='?' then begin
      ParseProcessTag;
     end else if CurrentChar='%' then begin
      ParseScriptTag;
     end else if CurrentChar='!' then begin
      NextChar;
      if not IsEOFOrErrors then begin
       if CurrentChar='-' then begin
        ParseCommentTag;
       end else if CurrentChar='[' then begin
        ParseCDATATag;
       end else begin
        ParseDOCTYPEOrExtraTag;
       end;
      end;
     end else begin
      ParseTag;
     end;
    end;
   end;
  end;
  if not Closed then begin
   Errors:=true;
  end;
 end;
begin
 Encoding:=etASCII;
 Errors:=false;
 CurrentChar:=#0;
 Root.Clear;
 StreamEOF:=false;
 Stream.Seek(0,soFromBeginning);
 NextChar;
 Process(Root,true);
 if Errors then begin
  Root.Clear;
 end;
 result:=not Errors;
end;

function TXML.Read(Stream:TStream):boolean;
begin
 result:=Parse(Stream);
end;

function TXML.Write(Stream:TStream;IdentSize:longint=2):boolean;
var IdentLevel:longint;
    Errors:boolean;
 procedure Process(Item:TXMLItem;DoIndent:boolean);
 var Line:ansistring;
     Counter:longint;
     TagWithSingleLineText,ItemsText:boolean;
  procedure WriteLineEx(Line:ansistring);
  begin
   if length(Line)>0 then begin
    if Stream.Write(Line[1],length(Line))<>length(Line) then begin
     Errors:=true;
    end;
   end;
  end;
  procedure WriteLine(Line:ansistring);
  begin
   if FormatIndent and DoIndent then begin
    Line:=Line+#10;
   end;
   if length(Line)>0 then begin
    if Stream.Write(Line[1],length(Line))<>length(Line) then begin
     Errors:=true;
    end;
   end;
  end;
 begin
  if not Errors then begin
   if assigned(Item) then begin
    inc(IdentLevel,IdentSize);
    Line:='';
    if FormatIndent and DoIndent then begin
     for Counter:=1 to IdentLevel do begin
      Line:=Line+' ';
     end;
    end;
    if Item is TXMLText then begin
     if FormatIndentText then begin
      Line:=Line+ConvertToEntities(TXMLText(Item).Text,IdentLevel);
     end else begin
      Line:=ConvertToEntities(TXMLText(Item).Text);
     end;
     WriteLine(Line);
     for Counter:=0 to Item.Items.Count-1 do begin
      Process(Item.Items[Counter],DoIndent);
     end;
    end else if Item is TXMLCommentTag then begin
     Line:=Line+'<!--'+TXMLCommentTag(Item).Text+'-->';
     WriteLine(Line);
     for Counter:=0 to Item.Items.Count-1 do begin
      Process(Item.Items[Counter],DoIndent);
     end;
    end else if Item is TXMLProcessTag then begin
     Line:=Line+'<?'+TXMLProcessTag(Item).Name;
     for Counter:=0 to length(TXMLProcessTag(Item).Parameter)-1 do begin
      if assigned(TXMLProcessTag(Item).Parameter[Counter]) then begin
       Line:=Line+' '+TXMLProcessTag(Item).Parameter[Counter].Name+'="'+ConvertToEntities(TXMLProcessTag(Item).Parameter[Counter].Value)+'"';
      end;
     end;
     Line:=Line+'?>';
     WriteLine(Line);
     for Counter:=0 to Item.Items.Count-1 do begin
      Process(Item.Items[Counter],DoIndent);
     end;
    end else if Item is TXMLScriptTag then begin
     Line:=Line+'<%'+TXMLScriptTag(Item).Text+'%>';
     WriteLine(Line);
     for Counter:=0 to Item.Items.Count-1 do begin
      Process(Item.Items[Counter],DoIndent);
     end;
    end else if Item is TXMLCDataTag then begin
     Line:=Line+'<![CDATA['+TXMLCDataTag(Item).Text+']]>';
     WriteLine(Line);
     for Counter:=0 to Item.Items.Count-1 do begin
      Process(Item.Items[Counter],DoIndent);
     end;
    end else if Item is TXMLDOCTYPETag then begin
     Line:=Line+'<!DOCTYPE '+TXMLDOCTYPETag(Item).Text+'>';
     WriteLine(Line);
     for Counter:=0 to Item.Items.Count-1 do begin
      Process(Item.Items[Counter],DoIndent);
     end;
    end else if Item is TXMLExtraTag then begin
     Line:=Line+'<!'+TXMLExtraTag(Item).Text+'>';
     WriteLine(Line);
     for Counter:=0 to Item.Items.Count-1 do begin
      Process(Item.Items[Counter],DoIndent);
     end;
    end else if Item is TXMLTag then begin
     if AutomaticAloneTagDetection then begin
      TXMLTag(Item).IsAloneTag:=TXMLTag(Item).Items.Count=0;
     end;
     Line:=Line+'<'+TXMLTag(Item).Name;
     for Counter:=0 to length(TXMLTag(Item).Parameter)-1 do begin
      if assigned(TXMLTag(Item).Parameter[Counter]) then begin
       Line:=Line+' '+TXMLTag(Item).Parameter[Counter].Name+'="'+ConvertToEntities(TXMLTag(Item).Parameter[Counter].Value)+'"';
      end;
     end;
     if TXMLTag(Item).IsAloneTag then begin
      Line:=Line+' />';
      WriteLine(Line);
     end else begin
      TagWithSingleLineText:=false;
      if Item.Items.Count=1 then begin
       if assigned(Item.Items[0]) then begin
        if Item.Items[0] is TXMLText then begin
         if ((POS(#13,TXMLText(Item.Items[0]).Text)=0) and
             (POS(#10,TXMLText(Item.Items[0]).Text)=0)) or not FormatIndentText then begin
          TagWithSingleLineText:=true;
         end;
        end;
       end;
      end;
      ItemsText:=false;
      for Counter:=0 to Item.Items.Count-1 do begin
       if assigned(Item.Items[Counter]) then begin
        if Item.Items[Counter] is TXMLText then begin
         ItemsText:=true;
        end;
       end;
      end;
      if TagWithSingleLineText then begin
       Line:=Line+'>'+ConvertToEntities(TXMLText(Item.Items[0]).Text)+'</'+TXMLTag(Item).Name+'>';
       WriteLine(Line);
      end else if Item.Items.Count<>0 then begin
       Line:=Line+'>';
       if assigned(Item.Items[0]) and (Item.Items[0] is TXMLText) and not FormatIndentText then begin
        WriteLineEx(Line);
       end else begin
        WriteLine(Line);
       end;
       for Counter:=0 to Item.Items.Count-1 do begin
        Process(Item.Items[Counter],DoIndent and ((not ItemsText) or (FormatIndent and FormatIndentText)));
       end;
       Line:='';
       if DoIndent and ((not ItemsText) or (FormatIndent and FormatIndentText)) then begin
        for Counter:=1 to IdentLevel do begin
         Line:=Line+' ';
        end;
       end;
       Line:=Line+'</'+TXMLTag(Item).Name+'>';
       WriteLine(Line);
      end else begin
       Line:=Line+'></'+TXMLTag(Item).Name+'>';
       WriteLine(Line);
      end;
     end;
    end else begin
     for Counter:=0 to Item.Items.Count-1 do begin
      Process(Item.Items[Counter],DoIndent);
     end;
    end;
    dec(IdentLevel,IdentSize);
   end;
  end;
 end;
begin
 IdentLevel:=-(2*IdentSize);
 if Stream is TMemoryStream then begin
  TMemoryStream(Stream).Clear;
 end;
 Errors:=false;
 Process(Root,FormatIndent);
 result:=not Errors;
end;

function TXML.ReadXMLText:ansistring;
var Stream:TMemoryStream;
begin
 Stream:=TMemoryStream.Create;
 Write(Stream);
 if Stream.Size>0 then begin
  SetLength(result,Stream.Size);
  Stream.Seek(0,soFromBeginning);
  Stream.Read(result[1],Stream.Size);
 end else begin
  result:='';
 end;
 Stream.Destroy;
end;

procedure TXML.WriteXMLText(Text:ansistring);
var Stream:TMemoryStream;
begin
 Stream:=TMemoryStream.Create;
 if length(Text)>0 then begin
  Stream.Write(Text[1],length(Text));
  Stream.Seek(0,soFromBeginning);
 end;
 Parse(Stream);
 Stream.Destroy;
end;

function ParseText(ParentItem:TXMLItem):ansistring;
var XMLItemIndex:longint;
    XMLItem:TXMLItem;
begin
 result:='';
 if assigned(ParentItem) then begin
  for XMLItemIndex:=0 to ParentItem.Items.Count-1 do begin
   XMLItem:=ParentItem.Items[XMLItemIndex];
   if assigned(XMLItem) then begin
    if XMLItem is TXMLText then begin
     result:=result+TXMLText(XMLItem).Text;
    end else if XMLItem is TXMLTag then begin
     if TXMLTag(XMLItem).Name='br' then begin
      result:=result+#13#10;
     end;
     result:=result+ParseText(XMLItem)+' ';
    end;
   end;
  end;
 end;
end;

end.
