unit UnitStaticDAELoader; // Copyright (C) 2006-2017, Benjamin Rosseaux - License: zlib
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

uses SysUtils,Classes,Math,UnitMath3D,UnitXML,UnitStringHashMap;

const dluaNONE=-1;
      dluaXUP=0;
      dluaYUP=1;
      dluaZUP=2;

      dlstCONSTANT=0;
      dlstLAMBERT=1;
      dlstBLINN=2;
      dlstPHONG=3;

      dlltAMBIENT=0;
      dlltDIRECTIONAL=1;
      dllTPOINT=2;
      dlltSPOT=3;

      dlctPERSPECTIVE=0;
      dlctORTHOGRAPHIC=1;

      dlmtTRIANGLES=0;
      dlmtLINESTRIP=1;

      dlMAXTEXCOORDSETS=8;

type PDAELight=^TDAELight;
     TDAELight=record
      Name:ansistring;
      LightType:longint;
      Position:TVector3;
      Direction:TVector3;
      Color:TVector3;
      FallOffAngle:single;
      FallOffExponent:single;
      ConstantAttenuation:single;
      LinearAttenuation:single;
      QuadraticAttenuation:single;
     end;

     TDAELights=array of TDAELight;

     PDAECamera=^TDAECamera;
     TDAECamera=record
      Name:ansistring;
      Matrix:TMatrix4x4;
      ZNear:single;
      ZFar:single;
      AspectRatio:single;
      case CameraType:longint of
       dlctPERSPECTIVE:(
        XFov:single;
        YFov:single;
       );
       dlctORTHOGRAPHIC:(
        XMag:single;
        YMag:single;
       );
     end;

     TDAECameras=array of TDAECamera;

     PDAEColorOrTexture=^TDAEColorOrTexture;
     TDAEColorOrTexture=record
      HasColor:boolean;
      HasTexture:boolean;
      Color:TVector4;
      Texture:ansistring;
      TexCoord:ansistring;
      OffsetU:single;
      OffsetV:single;
      RepeatU:single;
      RepeatV:single;
      WrapU:longint;
      WrapV:longint;
     end;

     PDAEMaterial=^TDAEMaterial;
     TDAEMaterial=record
      Name:ansistring;
      ShadingType:longint;
      Ambient:TDAEColorOrTexture;
      Diffuse:TDAEColorOrTexture;
      Emission:TDAEColorOrTexture;
      Specular:TDAEColorOrTexture;
      Transparent:TDAEColorOrTexture;
      Shininess:single;
      Reflectivity:single;
      IndexOfRefraction:single;
      Transparency:single;
     end;

     TDAEMaterials=array of TDAEMaterial;

     PDAEVertex=^TDAEVertex;
     TDAEVertex=record
      Position:TVector3;
      Normal:TVector3;
      Tangent:TVector3;
      Bitangent:TVector3;
      TexCoords:array[0..dlMAXTEXCOORDSETS-1] of TVector2;
      CountTexCoords:longint;
      Color:TVector3;
     end;

     TDAEVertices=array of TDAEVertex;

     TDAEVerticesArray=array of TDAEVertices;

     TDAEIndices=array of longint;

     PDAEMeshTexCoordSet=^TDAEMeshTexCoordSet;
     TDAEMeshTexCoordSet=record
      Semantic:ansistring;
      InputSet:longint;
     end;

     TDAEMeshTexCoordSets=array of TDAEMeshTexCoordSet;

     TDAEMesh=class
      public
       MeshType:longint;
       MaterialIndex:longint;
       TexCoordSets:TDAEMeshTexCoordSets;
       Vertices:TDAEVertices;
       Indices:TDAEIndices;
       constructor Create;
       destructor Destroy; override;
       procedure Optimize;
       procedure CalculateMissingInformations(Normals:boolean=true;Tangents:boolean=true);
     end;

     TDAEGeometry=class(TList)
      private
       function GetMesh(const Index:longint):TDAEMesh;
       procedure SetMesh(const Index:longint;Mesh:TDAEMesh);
      public
       Name:ansistring;
       constructor Create;
       destructor Destroy; override;
       procedure Clear; override;
       property Items[const Index:longint]:TDAEMesh read GetMesh write SetMesh; default;
     end;

     TDAEGeometries=class(TList)
      private
       function GetGeometry(const Index:longint):TDAEGeometry;
       procedure SetGeometry(const Index:longint;Geometry:TDAEGeometry);
      public
       constructor Create;
       destructor Destroy; override;
       procedure Clear; override;
       property Items[const Index:longint]:TDAEGeometry read GetGeometry write SetGeometry; default;
     end;

     TDAELoader=class
      private
      public
       COLLADAVersion:ansistring;
       AuthoringTool:ansistring;
       Created:TDateTime;
       Modified:TDateTime;
       UnitMeter:double;
       UnitName:ansistring;
       UpAxis:longint;
       Lights:TDAELights;
       CountLights:longint;
       Cameras:TDAECameras;
       CountCameras:longint;
       Materials:TDAEMaterials;
       CountMaterials:longint;
       Geometries:TDAEGeometries;
       constructor Create;
       destructor Destroy; override;
       function Load(Stream:TStream):boolean;
       function ExportAsOBJ(FileName:ansistring):boolean;
     end;

implementation

uses PasDblStrUtils;

function NextPowerOfTwo(i:longint;MinThreshold:longint=0):longint;
begin
 result:=(i or MinThreshold)-1;
 result:=result or (result shr 1);
 result:=result or (result shr 2);
 result:=result or (result shr 4);
 result:=result or (result shr 8);
 result:=result or (result shr 16);
 inc(result);
end;

function CompareBytes(a,b:pointer;Count:longint):boolean;
var pa,pb:pansichar;
begin
 pa:=a;
 pb:=b;
 result:=true;
 while Count>7 do begin
  if int64(pointer(pa)^)<>int64(pointer(pb)^) then begin
   result:=false;
   exit;
  end;
  inc(pa,8);
  inc(pb,8);
  dec(Count,8);
 end;
 while Count>3 do begin
  if longword(pointer(pa)^)<>longword(pointer(pb)^) then begin
   result:=false;
   exit;
  end;
  inc(pa,4);
  inc(pb,4);
  dec(Count,4);
 end;
 while Count>1 do begin
  if word(pointer(pa)^)<>word(pointer(pb)^) then begin
   result:=false;
   exit;
  end;
  inc(pa,2);
  inc(pb,2);
  dec(Count,2);
 end;
 while Count>0 do begin
  if pa^<>pb^ then begin
   result:=false;
   exit;
  end;
  inc(pa);
  inc(pb);
  dec(Count);
 end;
end;

function HashBytes(const a:pointer;Count:longint):longword;
{$ifdef cpuarm}
var b:pansichar;
    len,h,i:longword;
begin
 result:=2166136261;
 len:=Count;
 h:=len;
 if len>0 then begin
  b:=a;
  while len>3 do begin
   i:=longword(pointer(b)^);
   h:=(h xor i) xor $2e63823a;
   inc(h,(h shl 15) or (h shr (32-15)));
   dec(h,(h shl 9) or (h shr (32-9)));
   inc(h,(h shl 4) or (h shr (32-4)));
   dec(h,(h shl 1) or (h shr (32-1)));
   h:=h xor (h shl 2) or (h shr (32-2));
   result:=result xor i;
   inc(result,(result shl 1)+(result shl 4)+(result shl 7)+(result shl 8)+(result shl 24));
   inc(b,4);
   dec(len,4);
  end;
  if len>1 then begin
   i:=word(pointer(b)^);
   h:=(h xor i) xor $2e63823a;
   inc(h,(h shl 15) or (h shr (32-15)));
   dec(h,(h shl 9) or (h shr (32-9)));
   inc(h,(h shl 4) or (h shr (32-4)));
   dec(h,(h shl 1) or (h shr (32-1)));
   h:=h xor (h shl 2) or (h shr (32-2));
   result:=result xor i;
   inc(result,(result shl 1)+(result shl 4)+(result shl 7)+(result shl 8)+(result shl 24));
   inc(b,2);
   dec(len,2);
  end;
  if len>0 then begin
   i:=byte(b^);
   h:=(h xor i) xor $2e63823a;
   inc(h,(h shl 15) or (h shr (32-15)));
   dec(h,(h shl 9) or (h shr (32-9)));
   inc(h,(h shl 4) or (h shr (32-4)));
   dec(h,(h shl 1) or (h shr (32-1)));
   h:=h xor (h shl 2) or (h shr (32-2));
   result:=result xor i;
   inc(result,(result shl 1)+(result shl 4)+(result shl 7)+(result shl 8)+(result shl 24));
  end;
 end;
 result:=result xor h;
 if result=0 then begin
  result:=$ffffffff;
 end;
end;
{$else}
{$ifndef fpc}
type qword=int64;
{$endif}
const m=longword($57559429);
      n=longword($5052acdb);
var b:pansichar;
    h,k,len:longword;
    p:{$ifdef fpc}qword{$else}int64{$endif};
begin
 len:=Count;
 h:=len;
 k:=h+n+1;
 if len>0 then begin
  b:=a;
  while len>7 do begin
   begin
    p:=longword(pointer(b)^)*qword(n);
    h:=h xor longword(p and $ffffffff);
    k:=k xor longword(p shr 32);
    inc(b,4);
   end;
   begin
    p:=longword(pointer(b)^)*qword(m);
    k:=k xor longword(p and $ffffffff);
    h:=h xor longword(p shr 32);
    inc(b,4);
   end;
   dec(len,8);
  end;
  if len>3 then begin
   p:=longword(pointer(b)^)*qword(n);
   h:=h xor longword(p and $ffffffff);
   k:=k xor longword(p shr 32);
   inc(b,4);
   dec(len,4);
  end;
  if len>0 then begin
   if len>1 then begin
    p:=word(pointer(b)^);
    inc(b,2);
    dec(len,2);
   end else begin
    p:=0;
   end;
   if len>0 then begin
    p:=p or (byte(b^) shl 16);
   end;
   p:=p*qword(m);
   k:=k xor longword(p and $ffffffff);
   h:=h xor longword(p shr 32);
  end;
 end;
 begin
  p:=(h xor (k+n))*qword(n);
  h:=h xor longword(p and $ffffffff);
  k:=k xor longword(p shr 32);
 end;
 result:=k xor h;
 if result=0 then begin
  result:=$ffffffff;
 end;
end;
{$endif}

function StrToDouble(s:ansistring;const DefaultValue:double=0.0):double;
var OK:TPasDblStrUtilsBoolean;
begin
 OK:=false;
 if length(s)>0 then begin
  result:=ConvertStringToDouble(s,rmNearest,@OK);
  if not OK then begin
   result:=DefaultValue;
  end;
 end else begin
  result:=DefaultValue;
 end;
end;

function DoubleToStr(v:double):ansistring;
begin
 result:=ConvertDoubleToString(v,omStandard,0);
end;

type TCharSet=set of ansichar;

function GetToken(var InputString:ansistring;const Divider:TCharSet=[#0..#32]):ansistring;
var i:longint;
begin
 i:=1;
 while (i<=length(InputString)) and (InputString[i] in Divider) do begin
  inc(i);
 end;
 if i>1 then begin
  Delete(InputString,1,i-1);
 end;
 i:=1;
 while (i<=length(InputString)) and not (InputString[i] in Divider) do begin
  inc(i);
 end;
 result:=Copy(InputString,1,i-1);
 Delete(InputString,1,i);
end;

constructor TDAEMesh.Create;
begin
 inherited Create;
 MeshType:=dlmtTRIANGLES;
 Vertices:=nil;
 Indices:=nil;
 TexCoordSets:=nil;
end;

destructor TDAEMesh.Destroy;
begin
 SetLength(Vertices,0);
 SetLength(Indices,0);
 SetLength(TexCoordSets,0);
 inherited Destroy;
end;

procedure TDAEMesh.Optimize;
const HashBits=16;
      HashSize=1 shl HashBits;
      HashMask=HashSize-1;
type PHashTableItem=^THashTableItem;
     THashTableItem=record
      Next:PHashTableItem;
      Hash:longword;
      VertexIndex:longint;
     end;
     PHashTable=^THashTable;
     THashTable=array[0..HashSize-1] of PHashTableItem;
 function HashVector(const v:TDAEVertex):longword;
 begin
  result:=((round(v.Position.x)*73856093) xor (round(v.Position.y)*19349663) xor (round(v.Position.z)*83492791));
 end;
var NewVertices:TDAEVertices;
    NewIndices:TDAEIndices;
    NewVerticesCount,NewIndicesCount,IndicesIndex,VertexIndex,VertexCounter,FoundVertexIndex,TexCoordSetIndex,Index:longint;
    OK:boolean;
    HashTable:PHashTable;
    HashTableItem,NextHashTableItem:PHashTableItem;
    Hash:longword;
begin
 NewVertices:=nil;
 NewIndices:=nil;
 HashTable:=nil;
 try
  GetMem(HashTable,SizeOf(THashTable));
  FillChar(HashTable^,SizeOf(THashTable),AnsiChar(#0));
  NewVerticesCount:=0;
  NewIndicesCount:=0;
  SetLength(NewVertices,length(Vertices));
  SetLength(NewIndices,length(Indices));
  for IndicesIndex:=0 to length(Indices)-1 do begin
   VertexIndex:=Indices[IndicesIndex];
   FoundVertexIndex:=-1;
   Hash:=HashVector(Vertices[VertexIndex]);
   HashTableItem:=HashTable[Hash and HashMask];
   while assigned(HashTableItem) do begin
    if HashTableItem^.Hash=Hash then begin
     VertexCounter:=HashTableItem^.VertexIndex;
     if Vector3Compare(Vertices[VertexIndex].Position,NewVertices[VertexCounter].Position) and
        Vector3Compare(Vertices[VertexIndex].Normal,NewVertices[VertexCounter].Normal) and
        Vector3Compare(Vertices[VertexIndex].Tangent,NewVertices[VertexCounter].Tangent) and
        Vector3Compare(Vertices[VertexIndex].Bitangent,NewVertices[VertexCounter].Bitangent) and
        Vector3Compare(Vertices[VertexIndex].Color,NewVertices[VertexCounter].Color) then begin
      OK:=true;
      for TexCoordSetIndex:=0 to Max(Min(Vertices[VertexIndex].CountTexCoords,dlMAXTEXCOORDSETS),0)-1 do begin
       if not Vector2Compare(Vertices[VertexIndex].TexCoords[TexCoordSetIndex],NewVertices[VertexCounter].TexCoords[TexCoordSetIndex]) then begin
        OK:=false;
        break;
       end;
      end;
      if OK then begin
       FoundVertexIndex:=VertexCounter;
       break;
      end;
     end;
    end;
    HashTableItem:=HashTableItem^.Next;
   end;
   if FoundVertexIndex<0 then begin
    GetMem(HashTableItem,SizeOf(THashTableItem));
    HashTableItem^.Next:=HashTable[Hash and HashMask];
    HashTable[Hash and HashMask]:=HashTableItem;
    HashTableItem^.Hash:=Hash;
    HashTableItem^.VertexIndex:=NewVerticesCount;
    FoundVertexIndex:=NewVerticesCount;
    NewVertices[NewVerticesCount]:=Vertices[VertexIndex];
    inc(NewVerticesCount);
   end;
   NewIndices[NewIndicesCount]:=FoundVertexIndex;
   inc(NewIndicesCount);
  end;
  SetLength(NewVertices,NewVerticesCount);
  SetLength(NewIndices,NewIndicesCount);
  SetLength(Vertices,0);
  SetLength(Indices,0);
  Vertices:=NewVertices;
  Indices:=NewIndices;
  NewVertices:=nil;
  NewIndices:=nil;
 finally
  SetLength(NewVertices,0);
  SetLength(NewIndices,0);
  for Index:=low(THashTable) to high(THashTable) do begin
   HashTableItem:=HashTable[Index];
   HashTable[Index]:=nil;
   while assigned(HashTableItem) do begin
    NextHashTableItem:=HashTableItem^.Next;
    FreeMem(HashTableItem);
    HashTableItem:=NextHashTableItem;
   end;
  end;
  FreeMem(HashTable);
 end;
end;

procedure TDAEMesh.CalculateMissingInformations(Normals:boolean=true;Tangents:boolean=true);
const f1d3=1.0/3.0;
var IndicesIndex,CountIndices,VertexIndex,CountVertices,CountTriangles,Counter:longint;
    v0,v1,v2:PDAEVertex;
    VerticesCounts:array of longint;
    VerticesNormals,VerticesTangents,VerticesBitangents:array of TVector3;
    TriangleNormal,TriangleTangent,TriangleBitangent,Normal:TVector3;
    t1,t2,t3,t4,f:single;
begin
 VerticesCounts:=nil;
 VerticesNormals:=nil;
 VerticesTangents:=nil;
 VerticesBitangents:=nil;
 try
  if Normals or Tangents then begin
   case MeshType of
    dlmtTRIANGLES:begin
     CountIndices:=length(Indices);
     CountTriangles:=length(Indices) div 3;
     if CountTriangles>0 then begin
      CountVertices:=length(Vertices);
      SetLength(VerticesCounts,CountVertices);
      SetLength(VerticesNormals,CountVertices);
      SetLength(VerticesTangents,CountVertices);
      SetLength(VerticesBitangents,CountVertices);
      for VertexIndex:=0 to CountVertices-1 do begin
       VerticesCounts[VertexIndex]:=0;
       VerticesNormals[VertexIndex]:=Vector3Origin;
       VerticesTangents[VertexIndex]:=Vector3Origin;
       VerticesBitangents[VertexIndex]:=Vector3Origin;
      end;
      IndicesIndex:=0;
      while (IndicesIndex+2)<CountIndices do begin
       v0:=@Vertices[Indices[IndicesIndex+0]];
       v1:=@Vertices[Indices[IndicesIndex+1]];
       v2:=@Vertices[Indices[IndicesIndex+2]];
       TriangleNormal:=Vector3Norm(Vector3Cross(Vector3Sub(v2^.Position,v0^.Position),Vector3Sub(v1^.Position,v0^.Position)));
       if not Normals then begin
        Normal.x:=(v0^.Normal.x+v1^.Normal.x+v2^.Normal.x)*f1d3;
        Normal.y:=(v0^.Normal.y+v1^.Normal.y+v2^.Normal.y)*f1d3;
        Normal.z:=(v0^.Normal.z+v1^.Normal.z+v2^.Normal.z)*f1d3;
        if ((TriangleNormal.x*Normal.x)+(TriangleNormal.y*Normal.y)+(TriangleNormal.z*Normal.z))<0.0 then begin
         TriangleNormal.x:=-TriangleNormal.x;
         TriangleNormal.y:=-TriangleNormal.y;
         TriangleNormal.z:=-TriangleNormal.z;
        end;
       end;
       t1:=v1^.TexCoords[0].v-v0^.TexCoords[0].v;
       t2:=v2^.TexCoords[0].v-v0^.TexCoords[0].v;
       t3:=v1^.TexCoords[0].u-v0^.TexCoords[0].u;
       t4:=v2^.TexCoords[0].u-v0^.TexCoords[0].u;
       TriangleTangent.x:=(t1*(v2^.Position.x-v0^.Position.x))-(t2*(v1^.Position.x-v0^.Position.x));
       TriangleTangent.y:=(t1*(v2^.Position.y-v0^.Position.y))-(t2*(v1^.Position.y-v0^.Position.y));
       TriangleTangent.z:=(t1*(v2^.Position.z-v0^.Position.z))-(t2*(v1^.Position.z-v0^.Position.z));
       TriangleBitangent.x:=(t3*(v2^.Position.x-v0^.Position.x))-(t4*(v1^.Position.x-v0^.Position.x));
       TriangleBitangent.y:=(t3*(v2^.Position.y-v0^.Position.y))-(t4*(v1^.Position.y-v0^.Position.y));
       TriangleBitangent.z:=(t3*(v2^.Position.z-v0^.Position.z))-(t4*(v1^.Position.z-v0^.Position.z));
       TriangleTangent:=Vector3Norm(Vector3Add(TriangleTangent,Vector3ScalarMul(TriangleNormal,-Vector3Dot(TriangleTangent,TriangleNormal))));
       TriangleBitangent:=Vector3Norm(Vector3Add(TriangleBitangent,Vector3ScalarMul(TriangleNormal,-Vector3Dot(TriangleBitangent,TriangleNormal))));
       if Vector3Dot(Vector3Cross(TriangleBitangent,TriangleTangent),TriangleNormal)<0 then begin
        TriangleTangent.x:=-TriangleTangent.x;
        TriangleTangent.y:=-TriangleTangent.y;
        TriangleTangent.z:=-TriangleTangent.z;
        TriangleBitangent.x:=-TriangleBitangent.x;
        TriangleBitangent.y:=-TriangleBitangent.y;
        TriangleBitangent.z:=-TriangleBitangent.z;
       end;
       for Counter:=0 to 2 do begin
        VertexIndex:=Indices[IndicesIndex+Counter];
        inc(VerticesCounts[VertexIndex]);
        VerticesNormals[VertexIndex]:=Vector3Add(VerticesNormals[VertexIndex],TriangleNormal);
        VerticesTangents[VertexIndex]:=Vector3Add(VerticesTangents[VertexIndex],TriangleTangent);
        VerticesBitangents[VertexIndex]:=Vector3Add(VerticesBitangents[VertexIndex],TriangleBitangent);
       end;
       inc(IndicesIndex,3);
      end;
      for VertexIndex:=0 to CountVertices-1 do begin
       if VerticesCounts[VertexIndex]>0 then begin
        f:=1.0/VerticesCounts[VertexIndex];
       end else begin
        f:=0.0;
       end;
       v0:=@Vertices[VertexIndex];
       if Normals then begin
        v0^.Normal:=Vector3Norm(Vector3ScalarMul(VerticesNormals[VertexIndex],f));
       end;
       if Tangents then begin
        v0^.Tangent:=Vector3Norm(Vector3ScalarMul(VerticesTangents[VertexIndex],f));
        v0^.Bitangent:=Vector3Norm(Vector3ScalarMul(VerticesBitangents[VertexIndex],f));
       end;
      end;
     end;
    end;
   end;
  end;
 finally
  SetLength(VerticesCounts,0);
  SetLength(VerticesNormals,0);
  SetLength(VerticesTangents,0);
  SetLength(VerticesBitangents,0);
 end;
end;

constructor TDAEGeometry.Create;
begin
 inherited Create;
 Name:='';
end;

destructor TDAEGeometry.Destroy;
var i:longint;
    Mesh:TDAEMesh;
begin
 for i:=0 to Count-1 do begin
  Mesh:=Items[i];
  Mesh.Free;
  Items[i]:=nil;
 end;
 inherited Destroy;
end;

procedure TDAEGeometry.Clear;
var i:longint;
    Mesh:TDAEMesh;
begin
 for i:=0 to Count-1 do begin
  Mesh:=Items[i];
  Mesh.Free;
  Items[i]:=nil;
 end;
 Name:='';
 inherited Clear;
end;

function TDAEGeometry.GetMesh(const Index:longint):TDAEMesh;
begin
 result:=inherited Items[Index];
end;

procedure TDAEGeometry.SetMesh(const Index:longint;Mesh:TDAEMesh);
begin
 inherited Items[Index]:=Mesh;
end;

constructor TDAEGeometries.Create;
begin
 inherited Create;
end;

destructor TDAEGeometries.Destroy;
var i:longint;
    Geometry:TDAEGeometry;
begin
 for i:=0 to Count-1 do begin
  Geometry:=Items[i];
  Geometry.Free;
  Items[i]:=nil;
 end;
 inherited Destroy;
end;

procedure TDAEGeometries.Clear;
var i:longint;
    Geometry:TDAEGeometry;
begin
 for i:=0 to Count-1 do begin
  Geometry:=Items[i];
  Geometry.Free;
  Items[i]:=nil;
 end;
 inherited Clear;
end;

function TDAEGeometries.GetGeometry(const Index:longint):TDAEGeometry;
begin
 result:=inherited Items[Index];
end;

procedure TDAEGeometries.SetGeometry(const Index:longint;Geometry:TDAEGeometry);
begin
 inherited Items[Index]:=Geometry;
end;

constructor TDAELoader.Create;
begin
 inherited Create;
 COLLADAVersion:='1.5.0';
 AuthoringTool:='';
 Created:=Now;
 Modified:=Now;
 UnitMeter:=1.0;
 UnitName:='meter';
 UpAxis:=dluaYUP;
 Lights:=nil;
 CountLights:=0;
 Cameras:=nil;
 CountCameras:=0;
 Materials:=nil;
 CountMaterials:=0;
 Geometries:=TDAEGeometries.Create;
end;

destructor TDAELoader.Destroy;
begin
 SetLength(Lights,0);
 SetLength(Cameras,0);
 SetLength(Materials,0);
 Geometries.Free;
 inherited Destroy;
end;

function TDAELoader.Load(Stream:TStream):boolean;
const lstBOOL=0;
      lstINT=1;
      lstFLOAT=2;
      lstIDREF=3;
      lstNAME=4;
      aptNONE=0;
      aptIDREF=1;
      aptNAME=2;
      aptINT=3;
      aptFLOAT=4;
      aptFLOAT4x4=5;
      ltAMBIENT=0;
      ltDIRECTIONAL=1;
      ltPOINT=2;
      ltSPOT=3;
      ntNODE=0;
      ntROTATE=1;
      ntTRANSLATE=2;
      ntSCALE=3;
      ntMATRIX=4;
      ntLOOKAT=5;
      ntSKEW=6;
      ntEXTRA=7;
      ntINSTANCECAMERA=8;
      ntINSTANCELIGHT=9;
      ntINSTANCECONTROLLER=10;
      ntINSTANCEGEOMETRY=11;
      ntINSTANCENODE=12;
      mtNONE=0;
      mtTRIANGLES=1;
      mtTRIFANS=2;
      mtTRISTRIPS=3;
      mtPOLYGONS=4;
      mtPOLYLIST=5;
      mtLINES=6;
      mtLINESTRIPS=7;
type PLibraryImage=^TLibraryImage;
     TLibraryImage=record
      Next:PLibraryImage;
      ID:ansistring;
      InitFrom:ansistring;
     end;
     PLibraryEffect=^TLibraryEffect;
     PLibraryMaterial=^TLibraryMaterial;
     TLibraryMaterial=record
      Next:PLibraryMaterial;
      ID:ansistring;
      Name:ansistring;
      EffectURL:ansistring;
      Effect:PLibraryEffect;
      Index:longint;
     end;
     PLibraryEffectSurface=^TLibraryEffectSurface;
     TLibraryEffectSurface=record
      Next:PLibraryEffectSurface;
      Effect:PLibraryEffect;
      SID:ansistring;
      InitFrom:ansistring;
      Format:ansistring;
     end;
     PLibraryEffectSampler2D=^TLibraryEffectSampler2D;
     TLibraryEffectSampler2D=record
      Next:PLibraryEffectSampler2D;
      Effect:PLibraryEffect;
      SID:ansistring;
      Source:ansistring;
      WrapS:ansistring;
      WrapT:ansistring;
      MinFilter:ansistring;
      MagFilter:ansistring;
      MipFilter:ansistring;
     end;
     PLibraryEffectFloat=^TLibraryEffectFloat;
     TLibraryEffectFloat=record
      Next:PLibraryEffectFloat;
      Effect:PLibraryEffect;
      SID:ansistring;
      Value:single;
     end;
     PLibraryEffectFloat4=^TLibraryEffectFloat4;
     TLibraryEffectFloat4=record
      Next:PLibraryEffectFloat4;
      Effect:PLibraryEffect;
      SID:ansistring;
      Values:array[0..3] of single;
     end;
     TLibraryEffect=record
      Next:PLibraryEffect;
      ID:ansistring;
      Name:ansistring;
      Images:TList;
      Surfaces:PLibraryEffectSurface;
      Sampler2D:PLibraryEffectSampler2D;
      Floats:PLibraryEffectFloat;
      Float4s:PLibraryEffectFloat4;
      ShadingType:longint;
      Ambient:TDAEColorOrTexture;
      Diffuse:TDAEColorOrTexture;
      Emission:TDAEColorOrTexture;
      Specular:TDAEColorOrTexture;
      Transparent:TDAEColorOrTexture;
      Shininess:single;
      Reflectivity:single;
      IndexOfRefraction:single;
      Transparency:single;
     end;
     PLibrarySourceData=^TLibrarySourceData;
     TLibrarySourceData=record
      Next:PLibrarySourceData;
      ID:ansistring;
      SourceType:longint;
      Data:array of double;
      Strings:array of ansistring;
     end;
     PLibrarySourceAccessorParam=^TLibrarySourceAccessorParam;
     TLibrarySourceAccessorParam=record
      ParamName:ansistring;
      ParamType:longint;
     end;
     TLibrarySourceAccessorParams=array of TLibrarySourceAccessorParam;
     PLibrarySourceAccessor=^TLibrarySourceAccessor;
     TLibrarySourceAccessor=record
      Source:ansistring;
      Count:longint;
      Offset:longint;
      Stride:longint;
      Params:TLibrarySourceAccessorParams;
     end;
     PLibrarySource=^TLibrarySource;
     TLibrarySource=record
      Next:PLibrarySource;
      ID:ansistring;
      SourceDatas:TList;
      Accessor:TLibrarySourceAccessor;
     end;
     PInput=^TInput;
     TInput=record
      Semantic:ansistring;
      Source:ansistring;
      Set_:longint;
      Offset:longint;
     end;
     TInputs=array of TInput;
     PLibraryVertices=^TLibraryVertices;
     TLibraryVertices=record
      Next:PLibraryVertices;
      ID:ansistring;
      Inputs:TInputs;
     end;
     TInts=array of longint;
     PLibraryGeometryMesh=^TLibraryGeometryMesh;
     TLibraryGeometryMesh=record
      MeshType:longint;
      Count:longint;
      Material:ansistring;
      Inputs:TInputs;
      VCounts:TInts;
      Indices:array of TInts;
     end;
     TLibraryGeometryMeshs=array of TLibraryGeometryMesh;
     PLibraryGeometry=^TLibraryGeometry;
     TLibraryGeometry=record
      Next:PLibraryGeometry;
      ID:ansistring;
      Meshs:TLibraryGeometryMeshs;
      CountMeshs:longint;
     end;
     PLibraryLight=^TLibraryLight;
     TLibraryLight=record
      Next:PLibraryLight;
      ID:ansistring;
      Name:ansistring;
      LightType:longint;
      Color:TVector3;
      FallOffAngle:single;
      FallOffExponent:single;
      ConstantAttenuation:single;
      LinearAttenuation:single;
      QuadraticAttenuation:single;
     end;
     PLibraryCamera=^TLibraryCamera;
     TLibraryCamera=record
      Next:PLibraryCamera;
      ID:ansistring;
      Name:ansistring;
      Camera:TDAECamera;
      SIDZNear:ansistring;
      SIDZFar:ansistring;
      SIDAspectRatio:ansistring;
      SIDXFov:ansistring;
      SIDYFov:ansistring;
      SIDXMag:ansistring;
      SIDYMag:ansistring;
     end;
     PInstanceMaterialTexCoordSet=^TInstanceMaterialTexCoordSet;
     TInstanceMaterialTexCoordSet=record
      Semantic:ansistring;
      InputSet:longint;
     end;
     TInstanceMaterialTexCoordSets=array of TInstanceMaterialTexCoordSet;
     PInstanceMaterial=^TInstanceMaterial;
     TInstanceMaterial=record
      Symbol:ansistring;
      Target:ansistring;
      TexCoordSets:TInstanceMaterialTexCoordSets;
     end;
     TInstanceMaterials=array of TInstanceMaterial;
     PLibraryNode=^TLibraryNode;
     TLibraryNode=record
      Next:PLibraryNode;
      ID:ansistring;
      SID:ansistring;
      Name:ansistring;
      NodeType_:ansistring;
      InstanceMaterials:TInstanceMaterials;
      InstanceNode:ansistring;
      case NodeType:longint of
       ntNODE:(
        Children:TList;
       );
       ntROTATE,
       ntTRANSLATE,
       ntSCALE,
       ntMATRIX,
       ntLOOKAT,
       ntSKEW:(
        Matrix:TMatrix4x4;
       );
       ntEXTRA:(
       );
       ntINSTANCECAMERA:(
        InstanceCamera:PLibraryCamera;
       );
       ntINSTANCELIGHT:(
        InstanceLight:PLibraryLight;
       );
       ntINSTANCECONTROLLER:(
       );
       ntINSTANCEGEOMETRY:(
        InstanceGeometry:PLibraryGeometry;
       );
       ntINSTANCENODE:(
       );
     end;
     PLibraryVisualScene=^TLibraryVisualScene;
     TLibraryVisualScene=record
      Next:PLibraryVisualScene;
      ID:ansistring;
      Items:TList;
     end;
var IDStringHashMap:TStringHashMap;
    LibraryImagesIDStringHashMap:TStringHashMap;
    LibraryImages:PLibraryImage;
    LibraryMaterialsIDStringHashMap:TStringHashMap;
    LibraryMaterials:PLibraryMaterial;
    LibraryEffectsIDStringHashMap:TStringHashMap;
    LibraryEffects:PLibraryEffect;
    LibrarySourcesIDStringHashMap:TStringHashMap;
    LibrarySources:PLibrarySource;
    LibrarySourceDatasIDStringHashMap:TStringHashMap;
    LibrarySourceDatas:PLibrarySourceData;
    LibraryVerticesesIDStringHashMap:TStringHashMap;
    LibraryVerticeses:PLibraryVertices;
    LibraryGeometriesIDStringHashMap:TStringHashMap;
    LibraryGeometries:PLibraryGeometry;
    LibraryCamerasIDStringHashMap:TStringHashMap;
    LibraryCameras:PLibraryCamera;
    LibraryLightsIDStringHashMap:TStringHashMap;
    LibraryLights:PLibraryLight;
    LibraryVisualScenesIDStringHashMap:TStringHashMap;
    LibraryVisualScenes:PLibraryVisualScene;
    LibraryNodesIDStringHashMap:TStringHashMap;
    LibraryNodes:PLibraryNode;
    MainVisualScene:PLibraryVisualScene;
    AxisMatrix:TMatrix4x4;
    BadAccessor:boolean;
    FlipAngle:boolean;
    NegJoints:boolean;
 procedure CollectIDs(ParentItem:TXMLItem);
 var XMLItemIndex:longint;
     XMLItem:TXMLItem;
     ID:ansistring;
 begin
  if assigned(ParentItem) then begin
   for XMLItemIndex:=0 to ParentItem.Items.Count-1 do begin
    XMLItem:=ParentItem.Items[XMLItemIndex];
    if assigned(XMLItem) then begin
     if XMLItem is TXMLTag then begin
      ID:=TXMLTag(XMLItem).GetParameter('id','');
      if length(ID)>0 then begin
       IDStringHashMap.Add(ID,XMLItem);
      end;
     end;
     CollectIDs(XMLItem);
    end;
   end;
  end;
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
      result:=result+ParseText(XMLItem);
     end;
    end;
   end;
  end;
 end;
 function ParseContributorTag(ParentTag:TXMLTag):boolean;
 var XMLItemIndex:longint;
     XMLItem:TXMLItem;
     XMLTag:TXMLTag;
 begin
  result:=false;
  if assigned(ParentTag) then begin
   for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
    XMLItem:=ParentTag.Items[XMLItemIndex];
    if assigned(XMLItem) then begin
     if XMLItem is TXMLTag then begin
      XMLTag:=TXMLTag(XMLItem);
      if XMLTag.Name='authoring_tool' then begin
       AuthoringTool:=ParseText(XMLTag);
       if AuthoringTool='COLLADA Mixamo exporter' then begin
        BadAccessor:=true;
       end else if AuthoringTool='FBX COLLADA exporter' then begin
        BadAccessor:=true;
       end else if pos('Blender 2.5',AuthoringTool)>0 then begin
        FlipAngle:=true;
        NegJoints:=true;
       end;
      end;
     end;
    end;
   end;
   result:=true;
  end;
 end;
 function ParseAssetTag(ParentTag:TXMLTag):boolean;
 var XMLItemIndex:longint;
     XMLItem:TXMLItem;
     XMLTag:TXMLTag;
     s:ansistring;
 begin
  result:=false;
  if assigned(ParentTag) then begin
   for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
    XMLItem:=ParentTag.Items[XMLItemIndex];
    if assigned(XMLItem) then begin
     if XMLItem is TXMLTag then begin
      XMLTag:=TXMLTag(XMLItem);
      if XMLTag.Name='contributor' then begin
       ParseContributorTag(XMLTag);
      end else if XMLTag.Name='created' then begin
       s:=ParseText(XMLTag);
       if length(s)>0 then begin
       end;
      end else if XMLTag.Name='modified' then begin
       s:=ParseText(XMLTag);
       if length(s)>0 then begin
       end;
      end else if XMLTag.Name='unit' then begin
       UnitMeter:=StrToDouble(XMLTag.GetParameter('meter','1.0'),1.0);
       UnitName:=XMLTag.GetParameter('name','meter');
      end else if XMLTag.Name='up_axis' then begin
       s:=UpperCase(Trim(ParseText(XMLTag)));
       if (s='X') or (s='X_UP') then begin
        UpAxis:=dluaXUP;
       end else if (s='Y') or (s='Y_UP') then begin
        UpAxis:=dluaYUP;
       end else if (s='Z') or (s='Z_UP') then begin
        UpAxis:=dluaZUP;
       end;
      end;
     end;
    end;
   end;
   result:=true;
  end;
 end;
 function ParseImageTag(ParentTag:TXMLTag):PLibraryImage;
 var XMLItemIndex:longint;
     XMLItem:TXMLItem;
     XMLTag,XMLSubTag:TXMLTag;
     ID,InitFrom:ansistring;
     Image:PLibraryImage;
 begin
  result:=nil;
  if assigned(ParentTag) then begin
   ID:=TXMLTag(ParentTag).GetParameter('id','');
   if length(ID)>0 then begin
    InitFrom:='';
    for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
     XMLItem:=ParentTag.Items[XMLItemIndex];
     if assigned(XMLItem) then begin
      if XMLItem is TXMLTag then begin
       XMLTag:=TXMLTag(XMLItem);
       if XMLTag.Name='init_from' then begin
        XMLSubTag:=XMLTag.FindTag('ref');
        if assigned(XMLSubTag) then begin
         InitFrom:=ParseText(XMLSubTag);
        end else begin
         InitFrom:=ParseText(XMLTag);
        end;
       end;
      end;
     end;
    end;
    if length(InitFrom)>0 then begin
     GetMem(Image,SizeOf(TLibraryImage));
     FillChar(Image^,SizeOf(TLibraryImage),AnsiChar(#0));
     Image^.Next:=LibraryImages;
     LibraryImages:=Image;
     Image^.ID:=ID;
     Image^.InitFrom:=InitFrom;
     LibraryImagesIDStringHashMap.Add(ID,Image);
     result:=Image;
    end;
   end;
  end;
 end;
 function ParseLibraryImagesTag(ParentTag:TXMLTag):boolean;
 var XMLItemIndex:longint;
     XMLItem:TXMLItem;
     XMLTag:TXMLTag;
 begin
  result:=false;
  if assigned(ParentTag) then begin
   for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
    XMLItem:=ParentTag.Items[XMLItemIndex];
    if assigned(XMLItem) then begin
     if XMLItem is TXMLTag then begin
      XMLTag:=TXMLTag(XMLItem);
      if XMLTag.Name='image' then begin
       ParseImageTag(XMLTag);
      end;
     end;
    end;
   end;
   result:=true;
  end;
 end;
 function ParseMaterialTag(ParentTag:TXMLTag):boolean;
 var XMLItemIndex:longint;
     XMLItem:TXMLItem;
     XMLTag:TXMLTag;
     ID,Name,EffectURL:ansistring;
     Material:PLibraryMaterial;
 begin
  result:=false;
  if assigned(ParentTag) then begin
   ID:=TXMLTag(ParentTag).GetParameter('id','');
   Name:=TXMLTag(ParentTag).GetParameter('name','');
   if length(ID)>0 then begin
    EffectURL:='';
    for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
     XMLItem:=ParentTag.Items[XMLItemIndex];
     if assigned(XMLItem) then begin
      if XMLItem is TXMLTag then begin
       XMLTag:=TXMLTag(XMLItem);
       if XMLTag.Name='instance_effect' then begin
        EffectURL:=StringReplace(XMLTag.GetParameter('url',''),'#','',[rfReplaceAll]);
       end;
      end;
     end;
    end;
    if length(EffectURL)>0 then begin
     GetMem(Material,SizeOf(TLibraryMaterial));
     FillChar(Material^,SizeOf(TLibraryMaterial),AnsiChar(#0));
     Material^.Next:=LibraryMaterials;
     LibraryMaterials:=Material;
     Material^.ID:=ID;
     Material^.Name:=Name;
     Material^.EffectURL:=EffectURL;
     Material^.Index:=-1;
     LibraryMaterialsIDStringHashMap.Add(ID,Material);
    end;
   end;
   result:=true;
  end;
 end;
 function ParseLibraryMaterialsTag(ParentTag:TXMLTag):boolean;
 var XMLItemIndex:longint;
     XMLItem:TXMLItem;
     XMLTag:TXMLTag;
 begin
  result:=false;
  if assigned(ParentTag) then begin
   for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
    XMLItem:=ParentTag.Items[XMLItemIndex];
    if assigned(XMLItem) then begin
     if XMLItem is TXMLTag then begin
      XMLTag:=TXMLTag(XMLItem);
      if XMLTag.Name='material' then begin
       ParseMaterialTag(XMLTag);
      end;
     end;
    end;
   end;
   result:=true;
  end;
 end;
 function ParseNewParamTag(ParentTag:TXMLTag;Effect:PLibraryEffect):boolean;
 var XMLItemIndex:longint;
     XMLItem:TXMLItem;
     XMLTag,XMLSubTag,XMLSubSubTag:TXMLTag;
     SID,s:ansistring;
     Surface:PLibraryEffectSurface;
     Sampler2D:PLibraryEffectSampler2D;
     Float:PLibraryEffectFloat;
     Float4:PLibraryEffectFloat4;
     Image:PLibraryImage;
 begin
  result:=false;
  if assigned(ParentTag) then begin
   SID:=TXMLTag(ParentTag).GetParameter('sid','');
   if length(SID)>0 then begin
    for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
     XMLItem:=ParentTag.Items[XMLItemIndex];
     if assigned(XMLItem) then begin
      if XMLItem is TXMLTag then begin
       XMLTag:=TXMLTag(XMLItem);
       if XMLTag.Name='surface' then begin
        GetMem(Surface,SizeOf(TLibraryEffectSurface));
        FillChar(Surface^,SizeOf(TLibraryEffectSurface),AnsiChar(#0));
        Surface^.Next:=Effect^.Surfaces;
        Effect^.Surfaces:=Surface;
        Surface^.Effect:=Effect;
        Surface^.SID:=SID;
        XMLSubTag:=XMLTag.FindTag('init_from');
        if assigned(XMLSubTag) then begin
         XMLSubSubTag:=XMLSubTag.FindTag('ref');
         if assigned(XMLSubSubTag) then begin
          Surface^.InitFrom:=ParseText(XMLSubSubTag);
         end else begin
          Surface^.InitFrom:=ParseText(XMLSubTag);
         end;
        end else begin
         Surface^.InitFrom:='';
        end;
        Surface^.Format:=ParseText(XMLTag.FindTag('format'));
       end else if XMLTag.Name='sampler2D' then begin
        GetMem(Sampler2D,SizeOf(TLibraryEffectSampler2D));
        FillChar(Sampler2D^,SizeOf(TLibraryEffectSampler2D),AnsiChar(#0));
        Sampler2D^.Next:=Effect^.Sampler2D;
        Effect^.Sampler2D:=Sampler2D;
        Sampler2D^.Effect:=Effect;
        Sampler2D^.SID:=SID;
        Sampler2D^.Source:=ParseText(XMLTag.FindTag('source'));
        Sampler2D^.WrapS:=ParseText(XMLTag.FindTag('wrap_s'));
        Sampler2D^.WrapT:=ParseText(XMLTag.FindTag('wrap_t'));
        Sampler2D^.MinFilter:=ParseText(XMLTag.FindTag('minfilter'));
        Sampler2D^.MagFilter:=ParseText(XMLTag.FindTag('magfilter'));
        Sampler2D^.MipFilter:=ParseText(XMLTag.FindTag('mipfilter'));
        XMLSubTag:=XMLTag.FindTag('instance_image');
        if assigned(XMLSubTag) then begin
         Image:=LibraryImagesIDStringHashMap[StringReplace(XMLSubTag.GetParameter('url',''),'#','',[rfReplaceAll])];
         if assigned(Image) then begin
          Sampler2D^.Source:=Image^.InitFrom;
         end;
        end;
       end else if XMLTag.Name='float' then begin
        GetMem(Float,SizeOf(TLibraryEffectFloat));
        FillChar(Float^,SizeOf(TLibraryEffectFloat),AnsiChar(#0));
        Float^.Next:=Effect^.Floats;
        Effect^.Floats:=Float;
        Float^.Effect:=Effect;
        Float^.SID:=SID;
        Float^.Value:=StrToDouble(ParseText(XMLTag),0.0);
       end else if XMLTag.Name='float4' then begin
        GetMem(Float4,SizeOf(TLibraryEffectFloat4));
        FillChar(Float4^,SizeOf(TLibraryEffectFloat4),AnsiChar(#0));
        Float4^.Next:=Effect^.Float4s;
        Effect^.Float4s:=Float4;
        Float4^.Effect:=Effect;
        Float4^.SID:=SID;
        s:=ParseText(XMLTag);
        Float4^.Values[0]:=StrToDouble(GetToken(s),0.0);
        Float4^.Values[1]:=StrToDouble(GetToken(s),0.0);
        Float4^.Values[2]:=StrToDouble(GetToken(s),0.0);
        Float4^.Values[3]:=StrToDouble(GetToken(s),0.0);
       end else if XMLTag.Name='extra' then begin
       end;
      end;
     end;
    end;
    result:=true;
   end;
  end;
 end;
 function ParseFloat(ParentTag:TXMLTag;Effect:PLibraryEffect;const DefaultValue:single=0.0):single;
 var XMLItemIndex:longint;
     XMLItem:TXMLItem;
     XMLTag:TXMLTag;
     s:ansistring;
     Float:PLibraryEffectFloat;
 begin
  result:=DefaultValue;
  if assigned(ParentTag) then begin
   for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
    XMLItem:=ParentTag.Items[XMLItemIndex];
    if assigned(XMLItem) then begin
     if XMLItem is TXMLTag then begin
      XMLTag:=TXMLTag(XMLItem);
      if XMLTag.Name='float' then begin
       result:=StrToDouble(ParseText(XMLTag),DefaultValue);
       exit;
      end else if XMLTag.Name='param' then begin
       s:=XMLTag.GetParameter('ref');
       if length(s)>0 then begin
        Float:=Effect^.Floats;
        while assigned(Float) do begin
         if Float^.SID=s then begin
          result:=Float^.Value;
          exit;
         end;
         Float:=Float^.Next;
        end;
       end;
      end;
     end;
    end;
   end;
   result:=StrToDouble(ParseText(ParentTag),DefaultValue);
  end;
 end;
 function ParseFloat4(ParentTag:TXMLTag;Effect:PLibraryEffect;const DefaultValue:TVector4):TVector4;
 var XMLItemIndex:longint;
     XMLItem:TXMLItem;
     XMLTag:TXMLTag;
     s:ansistring;
     Float4:PLibraryEffectFloat4;
 begin
  result:=DefaultValue;
  if assigned(ParentTag) then begin
   for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
    XMLItem:=ParentTag.Items[XMLItemIndex];
    if assigned(XMLItem) then begin
     if XMLItem is TXMLTag then begin
      XMLTag:=TXMLTag(XMLItem);
      if XMLTag.Name='float' then begin
       s:=ParseText(XMLTag);
       result.x:=StrToDouble(GetToken(s),DefaultValue.x);
       result.y:=StrToDouble(GetToken(s),DefaultValue.y);
       result.z:=StrToDouble(GetToken(s),DefaultValue.z);
       result.w:=StrToDouble(GetToken(s),DefaultValue.w);
       exit;
      end else if XMLTag.Name='param' then begin
       s:=XMLTag.GetParameter('ref');
       if length(s)>0 then begin
        Float4:=Effect^.Float4s;
        while assigned(Float4) do begin
         if Float4^.SID=s then begin
          result.x:=Float4.Values[0];
          result.y:=Float4.Values[1];
          result.z:=Float4.Values[2];
          result.w:=Float4.Values[3];
          exit;
         end;
         Float4:=Float4^.Next;
        end;
       end;
      end;
     end;
    end;
   end;
   s:=ParseText(ParentTag);
   result.x:=StrToDouble(GetToken(s),DefaultValue.x);
   result.y:=StrToDouble(GetToken(s),DefaultValue.y);
   result.z:=StrToDouble(GetToken(s),DefaultValue.z);
   result.w:=StrToDouble(GetToken(s),DefaultValue.w);
  end;
 end;
 function ParseColorOrTextureTag(ParentTag:TXMLTag;Effect:PLibraryEffect;const DefaultColor:TVector4):TDAEColorOrTexture;
 var XMLTag,TempXMLTag:TXMLTag;
     s:ansistring;
     Sampler2D:PLibraryEffectSampler2D;
     Surface:PLibraryEffectSurface;
     Image:PLibraryImage;
 begin
  FillChar(result,SizeOf(TDAEColorOrTexture),AnsiChar(#0));
  if assigned(ParentTag) then begin
   begin
    XMLTag:=ParentTag.FindTag('color');
    if assigned(XMLTag) then begin
     result.HasColor:=true;
     s:=Trim(ParseText(XMLTag));
     result.Color.r:=StrToDouble(GetToken(s),DefaultColor.r);
     result.Color.g:=StrToDouble(GetToken(s),DefaultColor.g);
     result.Color.b:=StrToDouble(GetToken(s),DefaultColor.b);
     result.Color.a:=StrToDouble(GetToken(s),DefaultColor.a);
    end else begin
     XMLTag:=ParentTag.FindTag('param');
     if assigned(XMLTag) then begin
      result.HasColor:=true;
      result.Color:=ParseFloat4(XMLTag,Effect,DefaultColor);
     end else begin
      result.Color:=DefaultColor;
     end;
    end;
   end;
   begin
    XMLTag:=ParentTag.FindTag('texture');
    if assigned(XMLTag) then begin
     result.HasTexture:=true;
     s:=XMLTag.GetParameter('texture');
     result.Texture:=s;
     if length(s)>0 then begin
      Sampler2D:=Effect^.Sampler2D;
      while assigned(Sampler2D) do begin
       if Sampler2D^.SID=s then begin
        result.Texture:=Sampler2D^.Source;
        s:='';
        break;
       end;
       Sampler2D:=Sampler2D^.Next;
      end;
      if length(s)>0 then begin
       Surface:=Effect^.Surfaces;
       while assigned(Surface) do begin
        if Surface^.SID=s then begin
         result.Texture:=Surface^.InitFrom;
         s:='';
         break;
        end;
        Surface:=Surface^.Next;
       end;
      end;
      if length(s)>0 then begin
       Image:=LibraryImagesIDStringHashMap[s];
       if assigned(Image) then begin
        result.Texture:=Image^.InitFrom;
        s:='';
       end;
      end;
     end;
     result.TexCoord:=XMLTag.GetParameter('texcoord');
     result.OffsetU:=0.0;
     result.OffsetV:=0.0;
     result.RepeatU:=1.0;
     result.RepeatV:=1.0;
     result.WrapU:=1;
     result.WrapV:=1;
     XMLTag:=XMLTag.FindTag('extra');
     if assigned(XMLTag) then begin
      TempXMLTag:=XMLTag.FindTag('technique');
      if assigned(TempXMLTag) then begin
       XMLTag:=TempXMLTag;
      end;
      result.OffsetU:=StrToDouble(ParseText(XMLTag.FindTag('offsetU')),0.0);
      result.OffsetV:=StrToDouble(ParseText(XMLTag.FindTag('offsetV')),0.0);
      result.RepeatU:=StrToDouble(ParseText(XMLTag.FindTag('repeatU')),1.0);
      result.RepeatV:=StrToDouble(ParseText(XMLTag.FindTag('repeatV')),1.0);
      result.WrapU:=StrToIntDef(ParseText(XMLTag.FindTag('wrapU')),1);
      result.WrapV:=StrToIntDef(ParseText(XMLTag.FindTag('wrapV')),1);
     end;
    end;
   end;
  end;
 end;
 function ParseTechniqueTag(ParentTag:TXMLTag;Effect:PLibraryEffect):boolean;
 var XMLItemIndex:longint;
     XMLItem:TXMLItem;
     XMLTag:TXMLTag;
     ShadingType:longint;
 begin
  result:=false;
  if assigned(ParentTag) then begin
   ShadingType:=-1;
   for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
    XMLItem:=ParentTag.Items[XMLItemIndex];
    if assigned(XMLItem) then begin
     if XMLItem is TXMLTag then begin
      XMLTag:=TXMLTag(XMLItem);
      if XMLTag.Name='constant' then begin
       ShadingType:=dlstCONSTANT;
      end else if XMLTag.Name='lambert' then begin
       ShadingType:=dlstLAMBERT;
      end else if XMLTag.Name='blinn' then begin
       ShadingType:=dlstBLINN;
      end else if XMLTag.Name='phong' then begin
       ShadingType:=dlstPHONG;
      end;
      if ShadingType>=0 then begin
       Effect^.ShadingType:=ShadingType;
       Effect^.Ambient:=ParseColorOrTextureTag(XMLTag.FindTag('ambient'),Effect,Vector4(0.0,0.0,0.0,1.0));
       Effect^.Diffuse:=ParseColorOrTextureTag(XMLTag.FindTag('diffuse'),Effect,Vector4(1.0,1.0,1.0,1.0));
       Effect^.Emission:=ParseColorOrTextureTag(XMLTag.FindTag('emission'),Effect,Vector4(0.0,0.0,0.0,1.0));
       Effect^.Specular:=ParseColorOrTextureTag(XMLTag.FindTag('specular'),Effect,Vector4(0.0,0.0,0.0,1.0));
       Effect^.Transparent:=ParseColorOrTextureTag(XMLTag.FindTag('transparent'),Effect,Vector4(0.0,0.0,0.0,1.0));
       Effect^.Shininess:=ParseFloat(XMLTag.FindTag('shininess'),Effect,-Infinity);
       Effect^.Reflectivity:=ParseFloat(XMLTag.FindTag('reflectivity'),Effect,-Infinity);
       Effect^.IndexOfRefraction:=ParseFloat(XMLTag.FindTag('index_of_refraction'),Effect,-Infinity);
       Effect^.Transparency:=ParseFloat(XMLTag.FindTag('transparency'),Effect,-Infinity);
       break;
      end;
     end;
     result:=true;
    end;
   end;
  end;
 end;
 function ParseProfileCommonTag(ParentTag:TXMLTag;Effect:PLibraryEffect):TXMLTag;
 var PassIndex,XMLItemIndex:longint;
     XMLItem:TXMLItem;
     XMLTag:TXMLTag;
     Image:PLibraryImage;
 begin
  result:=nil;
  if assigned(ParentTag) then begin
   for PassIndex:=0 to 4 do begin
    for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
     XMLItem:=ParentTag.Items[XMLItemIndex];
     if assigned(XMLItem) then begin
      if XMLItem is TXMLTag then begin
       XMLTag:=TXMLTag(XMLItem);
       if (PassIndex=0) and (XMLTag.Name='profile_COMMON') then begin
        result:=ParseProfileCommonTag(XMLTag,Effect);
       end else if (PassIndex=1) and (XMLTag.Name='image') then begin
        Image:=ParseImageTag(XMLTag);
        if assigned(Image) then begin
         Effect^.Images.Add(Image);
        end;
       end else if (PassIndex=2) and (XMLTag.Name='newparam') then begin
        ParseNewParamTag(XMLTag,Effect);
       end else if (PassIndex=3) and (XMLTag.Name='technique') then begin
        result:=XMLTag;
       end else if (PassIndex=4) and (XMLTag.Name='extra') then begin
       end;
      end;
     end;
    end;
   end;
  end;
 end;
 function ParseEffectTag(ParentTag:TXMLTag):boolean;
 var XMLItemIndex:longint;
     XMLItem:TXMLItem;
     XMLTag:TXMLTag;
     ID,Name:ansistring;
     Effect:PLibraryEffect;
 begin
  result:=false;
  if assigned(ParentTag) then begin
   ID:=TXMLTag(ParentTag).GetParameter('id','');
   Name:=TXMLTag(ParentTag).GetParameter('name','');
   if length(ID)>0 then begin
    GetMem(Effect,SizeOf(TLibraryEffect));
    FillChar(Effect^,SizeOf(TLibraryEffect),AnsiChar(#0));
    Effect^.Next:=LibraryEffects;
    LibraryEffects:=Effect;
    Effect^.ID:=ID;
    Effect^.Name:=Name;
    EFfect^.Images:=TList.Create;
    Effect^.ShadingType:=-1;
    LibraryEffectsIDStringHashMap.Add(ID,Effect);
    for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
     XMLItem:=ParentTag.Items[XMLItemIndex];
     if assigned(XMLItem) then begin
      if XMLItem is TXMLTag then begin
       XMLTag:=TXMLTag(XMLItem);
       if XMLTag.Name='profile_COMMON' then begin
        ParseTechniqueTag(ParseProfileCommonTag(XMLTag,Effect),Effect);
       end;
      end;
     end;
    end;
   end;
   result:=true;
  end;
 end;
 function ParseLibraryEffectsTag(ParentTag:TXMLTag):boolean;
 var XMLItemIndex:longint;
     XMLItem:TXMLItem;
     XMLTag:TXMLTag;
 begin
  result:=false;
  if assigned(ParentTag) then begin
   for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
    XMLItem:=ParentTag.Items[XMLItemIndex];
    if assigned(XMLItem) then begin
     if XMLItem is TXMLTag then begin
      XMLTag:=TXMLTag(XMLItem);
      if XMLTag.Name='effect' then begin
       ParseEffectTag(XMLTag);
      end;
     end;
    end;
   end;
   result:=true;
  end;
 end;
 function ParseaAccessorTag(ParentTag:TXMLTag;const Accessor:PLibrarySourceAccessor):boolean;
 var XMLItemIndex,Count:longint;
     XMLItem:TXMLItem;
     XMLTag:TXMLTag;
     s:ansistring;
 begin
  result:=false;
  if assigned(ParentTag) then begin
   Accessor^.Source:=StringReplace(ParentTag.GetParameter('source',''),'#','',[rfReplaceAll]);
   Accessor^.Count:=StrToIntDef(ParentTag.GetParameter('count'),0);
   Accessor^.Offset:=StrToIntDef(ParentTag.GetParameter('offset'),0);
   Accessor^.Stride:=StrToIntDef(ParentTag.GetParameter('stride'),1);
   Count:=0;
   for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
    XMLItem:=ParentTag.Items[XMLItemIndex];
    if assigned(XMLItem) then begin
     if XMLItem is TXMLTag then begin
      XMLTag:=TXMLTag(XMLItem);
      if XMLTag.Name='param' then begin
       if (Count+1)>length(Accessor^.Params) then begin
        SetLength(Accessor^.Params,(Count+1)*2);
       end;
       Accessor^.Params[Count].ParamName:=XMLTag.GetParameter('name');
       s:=XMLTag.GetParameter('type');
       if s='IDREF' then begin
        Accessor^.Params[Count].ParamType:=aptIDREF;
       end else if (s='Name') or (s='name') then begin
        Accessor^.Params[Count].ParamType:=aptNAME;
       end else if s='int' then begin
        Accessor^.Params[Count].ParamType:=aptINT;
       end else if s='float' then begin
        Accessor^.Params[Count].ParamType:=aptFLOAT;
       end else if s='float4x4' then begin
        Accessor^.Params[Count].ParamType:=aptFLOAT4x4;
       end else begin
        Accessor^.Params[Count].ParamType:=aptNONE;
       end;
       inc(Count);
      end;
     end;
    end;
   end;
   SetLength(Accessor^.Params,Count);
   result:=true;
  end;
 end;
 function ParseSourceTag(ParentTag:TXMLTag):boolean;
 var PassIndex,XMLItemIndex,Count,i,j:longint;
     XMLItem:TXMLItem;
     XMLTag:TXMLTag;
     ID:ansistring;
     s,si:ansistring;
     Source:PLibrarySource;
     SourceData:PLibrarySourceData;
 begin
  result:=false;
  if assigned(ParentTag) then begin
   ID:=TXMLTag(ParentTag).GetParameter('id','');
   if length(ID)>0 then begin
    GetMem(Source,SizeOf(TLibrarySource));
    FillChar(Source^,SizeOf(TLibrarySource),AnsiChar(#0));
    Source^.Next:=LibrarySources;
    LibrarySources:=Source;
    Source^.ID:=ID;
    Source^.SourceDatas:=TList.Create;
    LibrarySourcesIDStringHashMap.Add(ID,Source);
    for PassIndex:=0 to 1 do begin
     for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
      XMLItem:=ParentTag.Items[XMLItemIndex];
      if assigned(XMLItem) then begin
       if XMLItem is TXMLTag then begin
        XMLTag:=TXMLTag(XMLItem);
        if (PassIndex=0) and (XMLTag.Name='bool_array') then begin
         GetMem(SourceData,SizeOf(TLibrarySourceData));
         FillChar(SourceData^,SizeOf(TLibrarySourceData),AnsiChar(#0));
         SourceData^.Next:=LibrarySourceDatas;
         LibrarySourceDatas:=SourceData;
         SourceData^.ID:=XMLTag.GetParameter('id');
         LibrarySourceDatasIDStringHashMap.Add(SourceData^.ID,SourceData);
         SourceData^.SourceType:=lstBOOL;
         Source^.SourceDatas.Add(SourceData);
         s:=ParseText(XMLTag);
         Count:=0;
         i:=1;
         while i<=length(s) do begin
          while (i<=length(s)) and (s[i] in [#0..#32]) do begin
           inc(i);
          end;
          j:=i;
          while (i<=length(s)) and not (s[i] in [#0..#32]) do begin
           inc(i);
          end;
          if j<i then begin
           si:=copy(s,j,i-j);
          end else begin
           si:='';
          end;
          while (i<=length(s)) and (s[i] in [#0..#32]) do begin
           inc(i);
          end;
          if (Count+1)>length(SourceData^.Data) then begin
           SetLength(SourceData^.Data,(Count+1)*2);
          end;
          si:=LowerCase(trim(si));
          if (si='true') or (si='yes') or (si='1') then begin
           SourceData^.Data[Count]:=1;
          end else begin
           SourceData^.Data[Count]:=0;
          end;
          inc(Count);
         end;
         SetLength(SourceData^.Data,Count);
         break;
        end else if (PassIndex=0) and (XMLTag.Name='float_array') then begin
         GetMem(SourceData,SizeOf(TLibrarySourceData));
         FillChar(SourceData^,SizeOf(TLibrarySourceData),AnsiChar(#0));
         SourceData^.Next:=LibrarySourceDatas;
         LibrarySourceDatas:=SourceData;
         SourceData^.ID:=XMLTag.GetParameter('id');
         LibrarySourceDatasIDStringHashMap.Add(SourceData^.ID,SourceData);
         SourceData^.SourceType:=lstFLOAT;
         Source^.SourceDatas.Add(SourceData);
         s:=ParseText(XMLTag);
         Count:=0;
         i:=1;
         while i<=length(s) do begin
          while (i<=length(s)) and (s[i] in [#0..#32]) do begin
           inc(i);
          end;
          j:=i;
          while (i<=length(s)) and not (s[i] in [#0..#32]) do begin
           inc(i);
          end;
          if j<i then begin
           si:=copy(s,j,i-j);
          end else begin
           si:='';
          end;
          while (i<=length(s)) and (s[i] in [#0..#32]) do begin
           inc(i);
          end;
          if (Count+1)>length(SourceData^.Data) then begin
           SetLength(SourceData^.Data,(Count+1)*2);
          end;
          SourceData^.Data[Count]:=StrToDouble(Trim(si),0.0);
          inc(Count);
         end;
         SetLength(SourceData^.Data,Count);
         break;
        end else if (PassIndex=0) and (XMLTag.Name='int_array') then begin
         GetMem(SourceData,SizeOf(TLibrarySourceData));
         FillChar(SourceData^,SizeOf(TLibrarySourceData),AnsiChar(#0));
         SourceData^.Next:=LibrarySourceDatas;
         LibrarySourceDatas:=SourceData;
         SourceData^.ID:=XMLTag.GetParameter('id');
         LibrarySourceDatasIDStringHashMap.Add(SourceData^.ID,SourceData);
         SourceData^.SourceType:=lstINT;
         Source^.SourceDatas.Add(SourceData);
         s:=ParseText(XMLTag);
         Count:=0;
         i:=1;
         while i<=length(s) do begin
          while (i<=length(s)) and (s[i] in [#0..#32]) do begin
           inc(i);
          end;
          j:=i;
          while (i<=length(s)) and not (s[i] in [#0..#32]) do begin
           inc(i);
          end;
          if j<i then begin
           si:=copy(s,j,i-j);
          end else begin
           si:='';
          end;
          while (i<=length(s)) and (s[i] in [#0..#32]) do begin
           inc(i);
          end;
          if (Count+1)>length(SourceData^.Data) then begin
           SetLength(SourceData^.Data,(Count+1)*2);
          end;
          SourceData^.Data[Count]:=StrToIntDef(Trim(si),0);
          inc(Count);
         end;
         SetLength(SourceData^.Data,Count);
         break;
        end else if (PassIndex=0) and (XMLTag.Name='IDREF_array') then begin
         GetMem(SourceData,SizeOf(TLibrarySourceData));
         FillChar(SourceData^,SizeOf(TLibrarySourceData),AnsiChar(#0));
         SourceData^.Next:=LibrarySourceDatas;
         LibrarySourceDatas:=SourceData;
         SourceData^.ID:=XMLTag.GetParameter('id');
         LibrarySourceDatasIDStringHashMap.Add(SourceData^.ID,SourceData);
         SourceData^.SourceType:=lstIDREF;
         Source^.SourceDatas.Add(SourceData);
         s:=ParseText(XMLTag);
         Count:=0;
         i:=1;
         while i<=length(s) do begin
          while (i<=length(s)) and (s[i] in [#0..#32]) do begin
           inc(i);
          end;
          j:=i;
          while (i<=length(s)) and not (s[i] in [#0..#32]) do begin
           inc(i);
          end;
          if j<i then begin
           si:=copy(s,j,i-j);
          end else begin
           si:='';
          end;
          while (i<=length(s)) and (s[i] in [#0..#32]) do begin
           inc(i);
          end;
          if (Count+1)>length(SourceData^.Strings) then begin
           SetLength(SourceData^.Strings,(Count+1)*2);
          end;
          SourceData^.Strings[Count]:=si;
          inc(Count);
         end;
         SetLength(SourceData^.Strings,Count);
         break;
        end else if (PassIndex=0) and (XMLTag.Name='Name_array') then begin
         GetMem(SourceData,SizeOf(TLibrarySourceData));
         FillChar(SourceData^,SizeOf(TLibrarySourceData),AnsiChar(#0));
         SourceData^.Next:=LibrarySourceDatas;
         LibrarySourceDatas:=SourceData;
         SourceData^.ID:=XMLTag.GetParameter('id');
         LibrarySourceDatasIDStringHashMap.Add(SourceData^.ID,SourceData);
         SourceData^.SourceType:=lstNAME;
         Source^.SourceDatas.Add(SourceData);
         s:=ParseText(XMLTag);
         Count:=0;
         i:=1;
         while i<=length(s) do begin
          while (i<=length(s)) and (s[i] in [#0..#32]) do begin
           inc(i);
          end;
          j:=i;
          while (i<=length(s)) and not (s[i] in [#0..#32]) do begin
           inc(i);
          end;
          if j<i then begin
           si:=copy(s,j,i-j);
          end else begin
           si:='';
          end;
          while (i<=length(s)) and (s[i] in [#0..#32]) do begin
           inc(i);
          end;
          if (Count+1)>length(SourceData^.Strings) then begin
           SetLength(SourceData^.Strings,(Count+1)*2);
          end;
          SourceData^.Strings[Count]:=si;
          inc(Count);
         end;
         SetLength(SourceData^.Strings,Count);
         break;
        end else if (PassIndex=1) and (XMLTag.Name='technique_common') then begin
         ParseaAccessorTag(XMLTag.FindTag('accessor'),@Source^.Accessor);
        end;
       end;
      end;
     end;
    end;
    result:=true;
   end;
  end;
 end;
 function ParseInputTag(ParentTag:TXMLTag;var Input:TInput):boolean;
 begin
  result:=false;
  if assigned(ParentTag) then begin
   Input.Semantic:=ParentTag.GetParameter('semantic');
   Input.Source:=StringReplace(ParentTag.GetParameter('source',''),'#','',[rfReplaceAll]);
   Input.Set_:=StrToIntDef(ParentTag.GetParameter('set','-1'),-1);
   Input.Offset:=StrToIntDef(ParentTag.GetParameter('offset','0'),0);
   if (Input.Semantic='TEXCOORD') and (Input.Set_<0) then begin
    Input.Set_:=0;
   end;
   result:=true;
  end;
 end;
 function ParseVerticesTag(ParentTag:TXMLTag):boolean;
 var XMLItemIndex,Count:longint;
     XMLItem:TXMLItem;
     XMLTag:TXMLTag;
     ID:ansistring;
     Vertices:PLibraryVertices;
 begin
  result:=false;
  if assigned(ParentTag) then begin
   ID:=TXMLTag(ParentTag).GetParameter('id','');
   if length(ID)>0 then begin
    GetMem(Vertices,SizeOf(TLibraryVertices));
    FillChar(Vertices^,SizeOf(TLibraryVertices),AnsiChar(#0));
    Vertices^.Next:=LibraryVerticeses;
    LibraryVerticeses:=Vertices;
    Vertices^.ID:=ID;
    LibraryVerticesesIDStringHashMap.Add(ID,Vertices);
    Count:=0;
    for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
     XMLItem:=ParentTag.Items[XMLItemIndex];
     if assigned(XMLItem) then begin
      if XMLItem is TXMLTag then begin
       XMLTag:=TXMLTag(XMLItem);
       if XMLTag.Name='input' then begin
        if (Count+1)>length(Vertices^.Inputs) then begin
         SetLength(Vertices^.Inputs,(Count+1)*2);
        end;
        ParseInputTag(XMLTag,Vertices^.Inputs[Count]);
        inc(Count);
       end;
      end;
     end;
    end;
    SetLength(Vertices^.Inputs,Count);
    result:=true;
   end;
  end;
 end;
 function ParseMeshTag(ParentTag:TXMLTag;Geometry:PLibraryGeometry):boolean;
 var PassIndex,XMLItemIndex,XMLSubItemIndex,MeshType,InputCount,IndicesCount,Count,i,j,
     TotalIndicesCount:longint;
     XMLItem,XMLSubItem:TXMLItem;
     XMLTag,XMLSubTag:TXMLTag;
     s,si:ansistring;
     Mesh:PLibraryGeometryMesh;
 begin
  result:=false;
  if assigned(ParentTag) then begin
   MeshType:=mtNONE;
   IndicesCount:=0;
   for PassIndex:=0 to 2 do begin
    for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
     XMLItem:=ParentTag.Items[XMLItemIndex];
     if assigned(XMLItem) then begin
      if XMLItem is TXMLTag then begin
       XMLTag:=TXMLTag(XMLItem);
       if (PassIndex=0) and (XMLTag.Name='source') then begin
        ParseSourceTag(XMLTag);
       end else if (PassIndex=1) and (XMLTag.Name='vertices') then begin
        ParseVerticesTag(XMLTag);
       end else if (PassIndex=2) and ((XMLTag.Name='triangles') or
                                      (XMLTag.Name='trifans') or
                                      (XMLTag.Name='tristrips') or
                                      (XMLTag.Name='polygons') or
                                      (XMLTag.Name='polylist') or
                                      (XMLTag.Name='lines') or
                                      (XMLTag.Name='linestrips')) then begin
        if XMLTag.Name='triangles' then begin
         MeshType:=mtTRIANGLES;
        end else if XMLTag.Name='trifans' then begin
         MeshType:=mtTRIFANS;
        end else if XMLTag.Name='tristrips' then begin
         MeshType:=mtTRIFANS;
        end else if XMLTag.Name='polygons' then begin
         MeshType:=mtPOLYGONS;
        end else if XMLTag.Name='polylist' then begin
         MeshType:=mtPOLYLIST;
        end else if XMLTag.Name='lines' then begin
         MeshType:=mtLINES;
        end else if XMLTag.Name='lines' then begin
         MeshType:=mtLINES;
        end else if XMLTag.Name='linestrips' then begin
         MeshType:=mtLINESTRIPS;
        end;
        if (Geometry^.CountMeshs+1)>length(Geometry^.Meshs) then begin
         SetLength(Geometry^.Meshs,(Geometry^.CountMeshs+1)*2);
        end;
        Mesh:=@Geometry^.Meshs[Geometry^.CountMeshs];
        inc(Geometry^.CountMeshs);
        Mesh^.MeshType:=MeshType;
        Mesh^.Material:=XMLTag.GetParameter('material');
        Mesh^.Count:=StrToIntDef(XMLTag.GetParameter('count'),0);
        InputCount:=0;
        TotalIndicesCount:=0;
        for XMLSubItemIndex:=0 to XMLTag.Items.Count-1 do begin
         XMLSubItem:=XMLTag.Items[XMLSubItemIndex];
         if assigned(XMLSubItem) then begin
          if XMLSubItem is TXMLTag then begin
           XMLSubTag:=TXMLTag(XMLSubItem);
           if XMLSubTag.Name='input' then begin
            if (InputCount+1)>length(Mesh^.Inputs) then begin
             SetLength(Mesh^.Inputs,(InputCount+1)*2);
            end;
            ParseInputTag(XMLSubTag,Mesh^.Inputs[InputCount]);
            inc(InputCount);
           end else if XMLSubTag.Name='vcount' then begin
            s:=ParseText(XMLSubTag);
            Count:=0;
            i:=1;
            while i<=length(s) do begin
             while (i<=length(s)) and (s[i] in [#0..#32]) do begin
              inc(i);
             end;
             j:=i;
             while (i<=length(s)) and not (s[i] in [#0..#32]) do begin
              inc(i);
             end;
             if j<i then begin
              si:=copy(s,j,i-j);
             end else begin
              si:='';
             end;
             while (i<=length(s)) and (s[i] in [#0..#32]) do begin
              inc(i);
             end;
             if (Count+1)>length(Mesh^.VCounts) then begin
              SetLength(Mesh^.VCounts,(Count+1)*2);
             end;
             Mesh^.VCounts[Count]:=StrToIntDef(Trim(si),0);
             inc(Count);
            end;
            SetLength(Mesh^.VCounts,Count);
           end else if XMLSubTag.Name='p' then begin
            if (IndicesCount+1)>length(Mesh^.Indices) then begin
             SetLength(Mesh^.Indices,(IndicesCount+1)*2);
            end;
            s:=ParseText(XMLSubTag);
            Count:=0;
            i:=1;
            while i<=length(s) do begin
             while (i<=length(s)) and (s[i] in [#0..#32]) do begin
              inc(i);
             end;
             j:=i;
             while (i<=length(s)) and not (s[i] in [#0..#32]) do begin
              inc(i);
             end;
             if j<i then begin
              si:=copy(s,j,i-j);
             end else begin
              si:='';
             end;
             while (i<=length(s)) and (s[i] in [#0..#32]) do begin
              inc(i);
             end;
             if (Count+1)>length(Mesh^.Indices[IndicesCount]) then begin
              SetLength(Mesh^.Indices[IndicesCount],(Count+1)*2);
             end;
             Mesh^.Indices[IndicesCount,Count]:=StrToIntDef(Trim(si),0);
             inc(Count);
            end;
            SetLength(Mesh^.Indices[IndicesCount],Count);
            inc(IndicesCount);
            inc(TotalIndicesCount,Count);
           end;
          end;
         end;
        end;
        if TotalIndicesCount>0 then begin
        end;
        SetLength(Mesh^.Inputs,InputCount);
        SetLength(Mesh^.Indices,IndicesCount);
       end;
      end;
     end;
    end;
   end;
   result:=true;
  end;
 end;
 function ParseGeometryTag(ParentTag:TXMLTag):boolean;
 var XMLItemIndex:longint;
     XMLItem:TXMLItem;
     XMLTag:TXMLTag;
     ID:ansistring;
     Geometry:PLibraryGeometry;
 begin
  result:=false;
  if assigned(ParentTag) then begin
   ID:=TXMLTag(ParentTag).GetParameter('id','');
   if length(ID)>0 then begin
    GetMem(Geometry,SizeOf(TLibraryGeometry));
    FillChar(Geometry^,SizeOf(TLibraryGeometry),AnsiChar(#0));
    Geometry^.Next:=LibraryGeometries;
    LibraryGeometries:=Geometry;
    Geometry^.ID:=ID;
    LibraryGeometriesIDStringHashMap.Add(ID,Geometry);
    for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
     XMLItem:=ParentTag.Items[XMLItemIndex];
     if assigned(XMLItem) then begin
      if XMLItem is TXMLTag then begin
       XMLTag:=TXMLTag(XMLItem);
       if XMLTag.Name='mesh' then begin
        ParseMeshTag(XMLTag,Geometry);
       end;
      end;
     end;
    end;
    SetLength(Geometry^.Meshs,Geometry^.CountMeshs);
    result:=true;
   end;
  end;
 end;
 function ParseLibraryGeometriesTag(ParentTag:TXMLTag):boolean;
 var XMLItemIndex:longint;
     XMLItem:TXMLItem;
     XMLTag:TXMLTag;
 begin
  result:=false;
  if assigned(ParentTag) then begin
   for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
    XMLItem:=ParentTag.Items[XMLItemIndex];
    if assigned(XMLItem) then begin
     if XMLItem is TXMLTag then begin
      XMLTag:=TXMLTag(XMLItem);
      if XMLTag.Name='geometry' then begin
       ParseGeometryTag(XMLTag);
      end;
     end;
    end;
   end;
   result:=true;
  end;
 end;
 function ParseCameraTag(ParentTag:TXMLTag):boolean;
 var XMLSubItemIndex:longint;
     XMLSubItem:TXMLItem;
     XMLTag,XMLSubTag,XMLSubSubTag:TXMLTag;
     ID,Name:ansistring;
     Camera:PLibraryCamera;
 begin
  result:=false;
  if assigned(ParentTag) then begin
   ID:=TXMLTag(ParentTag).GetParameter('id','');
   Name:=TXMLTag(ParentTag).GetParameter('name','');
   if length(ID)>0 then begin
    GetMem(Camera,SizeOf(TLibraryCamera));
    FillChar(Camera^,SizeOf(TLibraryCamera),AnsiChar(#0));
    Camera^.Next:=LibraryCameras;
    LibraryCameras:=Camera;
    Camera^.ID:=ID;
    Camera^.Name:=Name;
    Camera^.Camera.Name:=Name;
    LibraryCamerasIDStringHashMap.Add(ID,Camera);
    XMLTag:=ParentTag.FindTag('optics');
    if assigned(XMLTag) then begin
     XMLTag:=XMLTag.FindTag('technique_common');
     if assigned(XMLTag) then begin
      for XMLSubItemIndex:=0 to XMLTag.Items.Count-1 do begin
       XMLSubItem:=XMLTag.Items[XMLSubItemIndex];
       if assigned(XMLSubItem) then begin
        if XMLSubItem is TXMLTag then begin
         XMLSubTag:=TXMLTag(XMLSubItem);
         if XMLSubTag.Name='perspective' then begin
          Camera^.Camera.CameraType:=dlctPERSPECTIVE;
          Camera^.Camera.XFov:=StrToDouble(Trim(ParseText(XMLSubTag.FindTag('xfov'))),0.0);
          Camera^.Camera.YFov:=StrToDouble(Trim(ParseText(XMLSubTag.FindTag('yfov'))),0.0);
          Camera^.Camera.ZNear:=StrToDouble(Trim(ParseText(XMLSubTag.FindTag('znear'))),0.0);
          Camera^.Camera.ZFar:=StrToDouble(Trim(ParseText(XMLSubTag.FindTag('zfar'))),0.0);
          Camera^.Camera.AspectRatio:=StrToDouble(Trim(ParseText(XMLSubTag.FindTag('aspect_ratio'))),0.0);
          begin
           XMLSubSubTag:=XMLSubTag.FindTag('xfov');
           if assigned(XMLSubSubTag) then begin
            Camera^.SIDXFov:=XMLSubSubTag.GetParameter('sid','');
           end;
          end;
          begin
           XMLSubSubTag:=XMLSubTag.FindTag('yfov');
           if assigned(XMLSubSubTag) then begin
            Camera^.SIDYFov:=XMLSubSubTag.GetParameter('sid','');
           end;
          end;
          begin
           XMLSubSubTag:=XMLSubTag.FindTag('znear');
           if assigned(XMLSubSubTag) then begin
            Camera^.SIDZNear:=XMLSubSubTag.GetParameter('sid','');
           end;
          end;
          begin
           XMLSubSubTag:=XMLSubTag.FindTag('zfar');
           if assigned(XMLSubSubTag) then begin
            Camera^.SIDZFar:=XMLSubSubTag.GetParameter('sid','');
           end;
          end;
          begin
           XMLSubSubTag:=XMLSubTag.FindTag('aspect_ratio');
           if assigned(XMLSubSubTag) then begin
            Camera^.SIDAspectRatio:=XMLSubSubTag.GetParameter('sid','');
           end;
          end;
          break;
         end else if XMLSubTag.Name='orthographic' then begin
          Camera^.Camera.CameraType:=dlctORTHOGRAPHIC;
          Camera^.Camera.XMag:=StrToDouble(Trim(ParseText(XMLSubTag.FindTag('xmag'))),0.0);
          Camera^.Camera.YMag:=StrToDouble(Trim(ParseText(XMLSubTag.FindTag('ymag'))),0.0);
          Camera^.Camera.ZNear:=StrToDouble(Trim(ParseText(XMLSubTag.FindTag('znear'))),0.0);
          Camera^.Camera.ZFar:=StrToDouble(Trim(ParseText(XMLSubTag.FindTag('zfar'))),0.0);
          Camera^.Camera.AspectRatio:=StrToDouble(Trim(ParseText(XMLSubTag.FindTag('aspect_ratio'))),0.0);
          begin
           XMLSubSubTag:=XMLSubTag.FindTag('xmag');
           if assigned(XMLSubSubTag) then begin
            Camera^.SIDXMag:=XMLSubSubTag.GetParameter('sid','');
           end;
          end;
          begin
           XMLSubSubTag:=XMLSubTag.FindTag('ymag');
           if assigned(XMLSubSubTag) then begin
            Camera^.SIDYMag:=XMLSubSubTag.GetParameter('sid','');
           end;
          end;
          begin
           XMLSubSubTag:=XMLSubTag.FindTag('znear');
           if assigned(XMLSubSubTag) then begin
            Camera^.SIDZNear:=XMLSubSubTag.GetParameter('sid','');
           end;
          end;
          begin
           XMLSubSubTag:=XMLSubTag.FindTag('zfar');
           if assigned(XMLSubSubTag) then begin
            Camera^.SIDZFar:=XMLSubSubTag.GetParameter('sid','');
           end;
          end;
          begin
           XMLSubSubTag:=XMLSubTag.FindTag('aspect_ratio');
           if assigned(XMLSubSubTag) then begin
            Camera^.SIDAspectRatio:=XMLSubSubTag.GetParameter('sid','');
           end;
          end;
          break;
         end;
        end;
       end;
      end;
     end;
    end;
    result:=true;
   end;
  end;
 end;
 function ParseLibraryCamerasTag(ParentTag:TXMLTag):boolean;
 var XMLItemIndex:longint;
     XMLItem:TXMLItem;
     XMLTag:TXMLTag;
 begin
  result:=false;
  if assigned(ParentTag) then begin
   for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
    XMLItem:=ParentTag.Items[XMLItemIndex];
    if assigned(XMLItem) then begin
     if XMLItem is TXMLTag then begin
      XMLTag:=TXMLTag(XMLItem);
      if XMLTag.Name='camera' then begin
       ParseCameraTag(XMLTag);
      end;
     end;
    end;
   end;
   result:=true;
  end;
 end;
 function ParseLightTag(ParentTag:TXMLTag):boolean;
 var XMLItemIndex,XMLSubItemIndex:longint;
     XMLItem,XMLSubItem:TXMLItem;
     XMLTag,XMLSubTag:TXMLTag;
     ID,Name:ansistring;
     Light:PLibraryLight;
     s:ansistring;
 begin
  result:=false;
  if assigned(ParentTag) then begin
   ID:=TXMLTag(ParentTag).GetParameter('id','');
   Name:=TXMLTag(ParentTag).GetParameter('name','');
   if length(ID)>0 then begin
    GetMem(Light,SizeOf(TLibraryLight));
    FillChar(Light^,SizeOf(TLibraryLight),AnsiChar(#0));
    Light^.Next:=LibraryLights;
    LibraryLights:=Light;
    Light^.ID:=ID;
    Light^.Name:=Name;
    LibraryLightsIDStringHashMap.Add(ID,Light);
    for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
     XMLItem:=ParentTag.Items[XMLItemIndex];
     if assigned(XMLItem) then begin
      if XMLItem is TXMLTag then begin
       XMLTag:=TXMLTag(XMLItem);
       if XMLTag.Name='technique_common' then begin
        for XMLSubItemIndex:=0 to XMLTag.Items.Count-1 do begin
         XMLSubItem:=XMLTag.Items[XMLSubItemIndex];
         if assigned(XMLSubItem) then begin
          if XMLSubItem is TXMLTag then begin
           XMLSubTag:=TXMLTag(XMLSubItem);
           if (XMLSubTag.Name='ambient') or
              (XMLSubTag.Name='directional') or
              (XMLSubTag.Name='point') or
              (XMLSubTag.Name='spot') then begin
            if XMLSubTag.Name='ambient' then begin
             Light^.LightType:=ltAMBIENT;
            end else if XMLSubTag.Name='directional' then begin
             Light^.LightType:=ltDIRECTIONAL;
            end else if XMLSubTag.Name='point' then begin
             Light^.LightType:=ltPOINT;
            end else if XMLSubTag.Name='spot' then begin
             Light^.LightType:=ltSPOT;
            end;
            s:=Trim(ParseText(XMLSubTag.FindTag('color')));
            Light^.Color.r:=StrToDouble(GetToken(s),1.0);
            Light^.Color.g:=StrToDouble(GetToken(s),1.0);
            Light^.Color.b:=StrToDouble(GetToken(s),1.0);
            Light^.ConstantAttenuation:=StrToDouble(Trim(ParseText(XMLSubTag.FindTag('constant_attenuation'))),1.0);
            Light^.LinearAttenuation:=StrToDouble(Trim(ParseText(XMLSubTag.FindTag('linear_attenuation'))),0.0);
            Light^.QuadraticAttenuation:=StrToDouble(Trim(ParseText(XMLSubTag.FindTag('quadratic_attenuation'))),0.0);
            if Light^.LightType=ltSPOT then begin
             Light^.FallOffAngle:=StrToDouble(Trim(ParseText(XMLSubTag.FindTag('falloff_angle'))),180.0);
             Light^.FallOffExponent:=StrToDouble(Trim(ParseText(XMLSubTag.FindTag('falloff_exponent'))),0.0);
            end else begin
             Light^.FallOffAngle:=180.0;
             Light^.FallOffExponent:=0.0;
            end;
            break;
           end;
          end;
         end;
        end;
       end;
      end;
     end;
    end;
    result:=true;
   end;
  end;
 end;
 function ParseLibraryLightsTag(ParentTag:TXMLTag):boolean;
 var XMLItemIndex:longint;
     XMLItem:TXMLItem;
     XMLTag:TXMLTag;
 begin
  result:=false;
  if assigned(ParentTag) then begin
   for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
    XMLItem:=ParentTag.Items[XMLItemIndex];
    if assigned(XMLItem) then begin
     if XMLItem is TXMLTag then begin
      XMLTag:=TXMLTag(XMLItem);
      if XMLTag.Name='light' then begin
       ParseLightTag(XMLTag);
      end;
     end;
    end;
   end;
   result:=true;
  end;
 end;
 function ParseLibraryControllersTag(ParentTag:TXMLTag):boolean;
 var XMLItemIndex:longint;
     XMLItem:TXMLItem;
     XMLTag:TXMLTag;
 begin
  result:=false;
  if assigned(ParentTag) then begin
   for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
    XMLItem:=ParentTag.Items[XMLItemIndex];
    if assigned(XMLItem) then begin
     if XMLItem is TXMLTag then begin
      XMLTag:=TXMLTag(XMLItem);
      if XMLTag.Name='controller' then begin
      end;
     end;
    end;
   end;
   result:=true;
  end;
 end;
 function ParseLibraryAnimationsTag(ParentTag:TXMLTag):boolean;
 var XMLItemIndex:longint;
     XMLItem:TXMLItem;
     XMLTag:TXMLTag;
 begin
  result:=false;
  if assigned(ParentTag) then begin
   for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
    XMLItem:=ParentTag.Items[XMLItemIndex];
    if assigned(XMLItem) then begin
     if XMLItem is TXMLTag then begin
      XMLTag:=TXMLTag(XMLItem);
      if XMLTag.Name='animation' then begin
      end;
     end;
    end;
   end;
   result:=true;
  end;
 end;
 function ParseNodeTag(ParentTag:TXMLTag):PLibraryNode;
 var XMLItemIndex,XMLSubItemIndex,XMLSubSubItemIndex,Count,SubCount:longint;
     XMLItem,XMLSubItem,XMLSubSubItem:TXMLItem;
     XMLTag,XMLSubTag,XMLSubSubTag,BindMaterialTag,TechniqueCommonTag:TXMLTag;
     ID,Name,s:ansistring;
     Node,Item:PLibraryNode;
     Vector3,LookAtOrigin,LookAtDest,LookAtUp,LookAtDirection,LookAtRight,
     SkewA,SkewB,SkewN1,SkewN2,SkewA1,SkewA2:TVector3;
     Angle,SkewAngle,SkewAN1,SkewAN2,SkewRX,SkewRY,SkewAlpha:single;
  procedure CreateItem(NodeType:longint);
  begin
   GetMem(Item,SizeOf(TLibraryNode));
   FillChar(Item^,SizeOf(TLibraryNode),AnsiChar(#0));
   Item^.Next:=LibraryNodes;
   LibraryNodes:=Item;
   Item^.ID:=XMLTag.GetParameter('id','');
   Item^.SID:=XMLTag.GetParameter('sid','');
   Item^.Name:=XMLTag.GetParameter('name','');
   Item^.NodeType_:=XMLTag.GetParameter('type','');
   Item^.NodeType:=NodeType;
   LibraryNodesIDStringHashMap.Add(Item^.ID,Item);
  end;
 begin
  result:=nil;
  if assigned(ParentTag) then begin
   ID:=TXMLTag(ParentTag).GetParameter('id','');
   Name:=TXMLTag(ParentTag).GetParameter('name','');
   if length(ID)>0 then begin
    GetMem(Node,SizeOf(TLibraryNode));
    FillChar(Node^,SizeOf(TLibraryNode),AnsiChar(#0));
    Node^.Next:=LibraryNodes;
    LibraryNodes:=Node;
    Node^.ID:=ID;
    Node^.SID:=ParentTag.GetParameter('sid','');
    Node^.Name:=Name;
    Node^.NodeType_:=ParentTag.GetParameter('type','node');
    Node^.Children:=TList.Create;
    Node^.NodeType:=ntNODE;
    LibraryNodesIDStringHashMap.Add(ID,Node);
    result:=Node;
    for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
     XMLItem:=ParentTag.Items[XMLItemIndex];
     if assigned(XMLItem) then begin
      if XMLItem is TXMLTag then begin
       XMLTag:=TXMLTag(XMLItem);
       if XMLTag.Name='node' then begin
        Item:=ParseNodeTag(XMLTag);
       end else if XMLTag.Name='rotate' then begin
        CreateItem(ntROTATE);
        s:=Trim(ParseText(XMLTag));
        Vector3.x:=StrToDouble(GetToken(s),0.0);
        Vector3.y:=StrToDouble(GetToken(s),0.0);
        Vector3.z:=StrToDouble(GetToken(s),0.0);
        Angle:=StrToDouble(GetToken(s),0.0);      
        Item^.Matrix:=Matrix4x4Rotate(Angle*DEG2RAD,Vector3);
       end else if XMLTag.Name='translate' then begin
        CreateItem(ntTRANSLATE);
        s:=Trim(ParseText(XMLTag));
        Vector3.x:=StrToDouble(GetToken(s),0.0);
        Vector3.y:=StrToDouble(GetToken(s),0.0);
        Vector3.z:=StrToDouble(GetToken(s),0.0);
        Item^.Matrix:=Matrix4x4Translate(Vector3);
       end else if XMLTag.Name='scale' then begin
        CreateItem(ntSCALE);
        s:=Trim(ParseText(XMLTag));
        Vector3.x:=StrToDouble(GetToken(s),0.0);
        Vector3.y:=StrToDouble(GetToken(s),0.0);
        Vector3.z:=StrToDouble(GetToken(s),0.0);
        Item^.Matrix:=Matrix4x4Scale(Vector3);
       end else if XMLTag.Name='matrix' then begin
        CreateItem(ntMATRIX);
        s:=Trim(ParseText(XMLTag));
        Item^.Matrix[0,0]:=StrToDouble(GetToken(s),0.0);
        Item^.Matrix[1,0]:=StrToDouble(GetToken(s),0.0);
        Item^.Matrix[2,0]:=StrToDouble(GetToken(s),0.0);
        Item^.Matrix[3,0]:=StrToDouble(GetToken(s),0.0);
        Item^.Matrix[0,1]:=StrToDouble(GetToken(s),0.0);
        Item^.Matrix[1,1]:=StrToDouble(GetToken(s),0.0);
        Item^.Matrix[2,1]:=StrToDouble(GetToken(s),0.0);
        Item^.Matrix[3,1]:=StrToDouble(GetToken(s),0.0);
        Item^.Matrix[0,2]:=StrToDouble(GetToken(s),0.0);
        Item^.Matrix[1,2]:=StrToDouble(GetToken(s),0.0);
        Item^.Matrix[2,2]:=StrToDouble(GetToken(s),0.0);
        Item^.Matrix[3,2]:=StrToDouble(GetToken(s),0.0);
        Item^.Matrix[0,3]:=StrToDouble(GetToken(s),0.0);
        Item^.Matrix[1,3]:=StrToDouble(GetToken(s),0.0);
        Item^.Matrix[2,3]:=StrToDouble(GetToken(s),0.0);
        Item^.Matrix[3,3]:=StrToDouble(GetToken(s),0.0);
       end else if XMLTag.Name='lookat' then begin
        CreateItem(ntLOOKAT);
        s:=Trim(ParseText(XMLTag));
        LookAtOrigin.x:=StrToDouble(GetToken(s),0.0);
        LookAtOrigin.y:=StrToDouble(GetToken(s),0.0);
        LookAtOrigin.z:=StrToDouble(GetToken(s),0.0);
        LookAtDest.x:=StrToDouble(GetToken(s),0.0);
        LookAtDest.y:=StrToDouble(GetToken(s),0.0);
        LookAtDest.z:=StrToDouble(GetToken(s),0.0);
        LookAtUp.x:=StrToDouble(GetToken(s),0.0);
        LookAtUp.y:=StrToDouble(GetToken(s),0.0);
        LookAtUp.z:=StrToDouble(GetToken(s),0.0);
        Vector3Normalize(LookAtUp);
        LookAtDirection:=Vector3Norm(Vector3Sub(LookAtDest,LookAtOrigin));
        LookAtRight:=Vector3Norm(Vector3Cross(LookAtDirection,LookAtUp));
        Item^.Matrix[0,0]:=LookAtRight.x;
        Item^.Matrix[0,1]:=LookAtUp.x;
        Item^.Matrix[0,2]:=-LookAtDirection.x;
        Item^.Matrix[0,3]:=LookAtOrigin.x;
        Item^.Matrix[1,0]:=LookAtRight.y;
        Item^.Matrix[1,1]:=LookAtUp.y;
        Item^.Matrix[1,2]:=-LookAtDirection.y;
        Item^.Matrix[1,3]:=LookAtOrigin.y;
        Item^.Matrix[1,0]:=LookAtRight.z;
        Item^.Matrix[2,1]:=LookAtUp.z;
        Item^.Matrix[2,2]:=-LookAtDirection.z;
        Item^.Matrix[2,3]:=LookAtOrigin.z;
        Item^.Matrix[3,0]:=0.0;
        Item^.Matrix[3,1]:=0.0;
        Item^.Matrix[3,2]:=0.0;
        Item^.Matrix[3,3]:=1.0;
       end else if XMLTag.Name='skew' then begin
        CreateItem(ntSKEW);
        s:=Trim(ParseText(XMLTag));
        SkewAngle:=StrToDouble(GetToken(s),0.0);
        SkewA.x:=StrToDouble(GetToken(s),0.0);
        SkewA.y:=StrToDouble(GetToken(s),1.0);
        SkewA.z:=StrToDouble(GetToken(s),0.0);
        SkewB.x:=StrToDouble(GetToken(s),1.0);
        SkewB.y:=StrToDouble(GetToken(s),0.0);
        SkewB.z:=StrToDouble(GetToken(s),0.0);
        SkewN2:=Vector3Norm(SkewB);
        SkewA1:=Vector3ScalarMul(SkewN2,Vector3Dot(SkewA,SkewN2));
        SkewA2:=Vector3Sub(SkewA,SkewA1);
        SkewN1:=Vector3Norm(SkewA2);
        SkewAN1:=Vector3Dot(SkewA,SkewN1);
        SkewAN2:=Vector3Dot(SkewA,SkewN2);
        SkewRX:=(SkewAN1*cos(SkewAngle*DEG2RAD))-(SkewAN2*sin(SkewAngle*DEG2RAD));
        SkewRY:=(SkewAN1*sin(SkewAngle*DEG2RAD))+(SkewAN2*cos(SkewAngle*DEG2RAD));
        if SkewRX>EPSILON then begin
         if SkewAN1<EPSILON then begin
          SkewAlpha:=0.0;
         end else begin
          SkewAlpha:=(SkewRY/SkewRX)-(SkewAN2/SkewAN1);
         end;
         Item^.Matrix[0,0]:=(SkewN1.x*SkewN2.x*SkewAlpha)+1.0;
         Item^.Matrix[0,1]:=SkewN1.y*SkewN2.x*SkewAlpha;
         Item^.Matrix[0,2]:=SkewN1.z*SkewN2.x*SkewAlpha;
         Item^.Matrix[0,3]:=0.0;
         Item^.Matrix[1,0]:=SkewN1.x*SkewN2.y*SkewAlpha;
         Item^.Matrix[1,1]:=(SkewN1.y*SkewN2.y*SkewAlpha)+1.0;
         Item^.Matrix[1,2]:=SkewN1.z*SkewN2.y*SkewAlpha;
         Item^.Matrix[1,3]:=0.0;
         Item^.Matrix[2,0]:=SkewN1.x*SkewN2.z*SkewAlpha;
         Item^.Matrix[2,1]:=SkewN1.y*SkewN2.z*SkewAlpha;
         Item^.Matrix[2,2]:=(SkewN1.z*SkewN2.z*SkewAlpha)+1.0;
         Item^.Matrix[2,3]:=0.0;
         Item^.Matrix[2,3]:=0.0;
         Item^.Matrix[3,0]:=0.0;
         Item^.Matrix[3,1]:=0.0;
         Item^.Matrix[3,2]:=0.0;
         Item^.Matrix[3,3]:=1.0;
        end else begin
         Item^.Matrix:=Matrix4x4Identity;
        end;
       end else if XMLTag.Name='extra' then begin
        CreateItem(ntEXTRA);
       end else if XMLTag.Name='instance_camera' then begin
        CreateItem(ntINSTANCECAMERA);
        Item^.InstanceCamera:=LibraryCamerasIDStringHashMap.Values[StringReplace(XMLTag.GetParameter('url',''),'#','',[rfReplaceAll])];
       end else if XMLTag.Name='instance_light' then begin
        CreateItem(ntINSTANCELIGHT);
        Item^.InstanceLight:=LibraryLightsIDStringHashMap.Values[StringReplace(XMLTag.GetParameter('url',''),'#','',[rfReplaceAll])];
       end else if XMLTag.Name='instance_controller' then begin
        CreateItem(ntINSTANCECONTROLLER);
       end else if XMLTag.Name='instance_geometry' then begin
        CreateItem(ntINSTANCEGEOMETRY);
        Item^.InstanceGeometry:=LibraryGeometriesIDStringHashMap.Values[StringReplace(XMLTag.GetParameter('url',''),'#','',[rfReplaceAll])];
        BindMaterialTag:=XMLTag.FindTag('bind_material');
        if assigned(BindMaterialTag) then begin
         TechniqueCommonTag:=BindMaterialTag.FindTag('technique_common');
         if not assigned(TechniqueCommonTag) then begin
          TechniqueCommonTag:=BindMaterialTag;
         end;
         Count:=0;
         for XMLSubItemIndex:=0 to TechniqueCommonTag.Items.Count-1 do begin
          XMLSubItem:=TechniqueCommonTag.Items[XMLSubItemIndex];
          if assigned(XMLSubItem) then begin
           if XMLSubItem is TXMLTag then begin
            XMLSubTag:=TXMLTag(XMLSubItem);
            if XMLSubTag.Name='instance_material' then begin
             if (Count+1)>length(Item^.InstanceMaterials) then begin
              SetLength(Item^.InstanceMaterials,(Count+1)*2);
             end;
             Item^.InstanceMaterials[Count].Symbol:=XMLSubTag.GetParameter('symbol');
             Item^.InstanceMaterials[Count].Target:=StringReplace(XMLSubTag.GetParameter('target'),'#','',[rfReplaceAll]);
             Item^.InstanceMaterials[Count].TexCoordSets:=nil;
             SubCount:=0;
             for XMLSubSubItemIndex:=0 to XMLSubTag.Items.Count-1 do begin
              XMLSubSubItem:=TechniqueCommonTag.Items[XMLSubSubItemIndex];
              if assigned(XMLSubSubItem) then begin
               if XMLSubSubItem is TXMLTag then begin
                XMLSubSubTag:=TXMLTag(XMLSubSubItem);
                if XMLSubSubTag.Name='bind_vertex_input' then begin
                 if XMLSubSubTag.GetParameter('input_semantic')='TEXCOORD' then begin
                  if (SubCount+1)>length(Item^.InstanceMaterials[Count].TexCoordSets) then begin
                   SetLength(Item^.InstanceMaterials[Count].TexCoordSets,(SubCount+1)*2);
                  end;
                  Item^.InstanceMaterials[Count].TexCoordSets[SubCount].Semantic:=XMLSubSubTag.GetParameter('semantic');
                  Item^.InstanceMaterials[Count].TexCoordSets[SubCount].InputSet:=StrToIntDef(XMLSubSubTag.GetParameter('input_set'),0);
                  inc(SubCount);
                 end;
                end;
               end;
              end;
             end;
             if SubCount=0 then begin
              if (SubCount+1)>length(Item^.InstanceMaterials[Count].TexCoordSets) then begin
               SetLength(Item^.InstanceMaterials[Count].TexCoordSets,(SubCount+1)*2);
              end;
              Item^.InstanceMaterials[Count].TexCoordSets[SubCount].Semantic:='UVSET0';
              Item^.InstanceMaterials[Count].TexCoordSets[SubCount].InputSet:=0;
              inc(SubCount);
             end;
             SetLength(Item^.InstanceMaterials[Count].TexCoordSets,SubCount);
             inc(Count);
            end;
           end;
          end;
         end;
         SetLength(Item^.InstanceMaterials,Count);
        end;
       end else if XMLTag.Name='instance_node' then begin
        CreateItem(ntINSTANCENODE);
        Item^.InstanceNode:=StringReplace(XMLTag.GetParameter('url',''),'#','',[rfReplaceAll]);
       end else begin
        Item:=nil;
       end;
       if assigned(Item) then begin
        Node^.Children.Add(Item);
       end;
      end;
     end;
    end;
   end;
  end;
 end;
 function ParseVisualSceneTag(ParentTag:TXMLTag):boolean;
 var XMLItemIndex:longint;
     XMLItem:TXMLItem;
     XMLTag:TXMLTag;
     ID:ansistring;
     VisualScene:PLibraryVisualScene;
     Item:PLibraryNode;
 begin
  result:=false;
  if assigned(ParentTag) then begin
   ID:=TXMLTag(ParentTag).GetParameter('id','');
   if length(ID)>0 then begin
    GetMem(VisualScene,SizeOf(TLibraryVisualScene));
    FillChar(VisualScene^,SizeOf(TLibraryVisualScene),AnsiChar(#0));
    VisualScene^.Next:=LibraryVisualScenes;
    LibraryVisualScenes:=VisualScene;
    VisualScene^.ID:=ID;
    VisualScene^.Items:=TList.Create;
    LibraryVisualScenesIDStringHashMap.Add(ID,VisualScene);
    for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
     XMLItem:=ParentTag.Items[XMLItemIndex];
     if assigned(XMLItem) then begin
      if XMLItem is TXMLTag then begin
       XMLTag:=TXMLTag(XMLItem);
       if XMLTag.Name='node' then begin
        Item:=ParseNodeTag(XMLTag);
        if assigned(Item) then begin
         VisualScene^.Items.Add(Item);
        end;
       end;
      end;
     end;
    end;
    result:=true;
   end;
  end;
 end;
 function ParseLibraryVisualScenesTag(ParentTag:TXMLTag):boolean;
 var XMLItemIndex:longint;
     XMLItem:TXMLItem;
     XMLTag:TXMLTag;
 begin
  result:=false;
  if assigned(ParentTag) then begin
   for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
    XMLItem:=ParentTag.Items[XMLItemIndex];
    if assigned(XMLItem) then begin
     if XMLItem is TXMLTag then begin
      XMLTag:=TXMLTag(XMLItem);
      if XMLTag.Name='visual_scene' then begin
       ParseVisualSceneTag(XMLTag);
      end;
     end;
    end;
   end;
   result:=true;
  end;
 end;
 function ParseInstanceVisualSceneTag(ParentTag:TXMLTag):boolean;
 var URL:ansistring;
 begin
  result:=false;
  if assigned(ParentTag) then begin
   URL:=StringReplace(ParentTag.GetParameter('url','#visual_scene0'),'#','',[rfReplaceAll]);
   MainVisualScene:=LibraryVisualScenesIDStringHashMap.Values[URL];
   result:=true;
  end;
 end;
 function ParseSceneTag(ParentTag:TXMLTag):boolean;
 var XMLItemIndex:longint;
     XMLItem:TXMLItem;
     XMLTag:TXMLTag;
 begin
  result:=false;
  if assigned(ParentTag) then begin
   for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
    XMLItem:=ParentTag.Items[XMLItemIndex];
    if assigned(XMLItem) then begin
     if XMLItem is TXMLTag then begin
      XMLTag:=TXMLTag(XMLItem);
      if XMLTag.Name='instance_visual_scene' then begin
       ParseInstanceVisualSceneTag(XMLTag);
      end;
     end;
    end;
   end;
   result:=true;
  end;
 end;
 function ParseCOLLADATag(ParentTag:TXMLTag):boolean;
 var PassIndex,XMLItemIndex:longint;
     XMLItem:TXMLItem;
     XMLTag:TXMLTag;
     Material:PLibraryMaterial;
 begin
  result:=false;
  if assigned(ParentTag) then begin
   COLLADAVersion:=ParentTag.GetParameter('version',COLLADAVersion);
   for PassIndex:=0 to 10 do begin
    for XMLItemIndex:=0 to ParentTag.Items.Count-1 do begin
     XMLItem:=ParentTag.Items[XMLItemIndex];
     if assigned(XMLItem) then begin
      if XMLItem is TXMLTag then begin
       XMLTag:=TXMLTag(XMLItem);
       if (PassIndex=0) and (XMLTag.Name='asset') then begin
        ParseAssetTag(XMLTag);
       end else if (PassIndex=1) and (XMLTag.Name='library_images') then begin
        ParseLibraryImagesTag(XMLTag);
       end else if (PassIndex=2) and (XMLTag.Name='library_materials') then begin
        ParseLibraryMaterialsTag(XMLTag);
       end else if (PassIndex=3) and (XMLTag.Name='library_effects') then begin
        ParseLibraryEffectsTag(XMLTag);
       end else if (PassIndex=4) and (XMLTag.Name='library_geometries') then begin
        ParseLibraryGeometriesTag(XMLTag);
       end else if (PassIndex=5) and (XMLTag.Name='library_cameras') then begin
        ParseLibraryCamerasTag(XMLTag);
       end else if (PassIndex=6) and (XMLTag.Name='library_lights') then begin
        ParseLibraryLightsTag(XMLTag);
       end else if (PassIndex=7) and (XMLTag.Name='library_controllers') then begin
        ParseLibraryControllersTag(XMLTag);
       end else if (PassIndex=8) and (XMLTag.Name='library_animations') then begin
        ParseLibraryAnimationsTag(XMLTag);
       end else if (PassIndex=9) and (XMLTag.Name='library_visual_scenes') then begin
        ParseLibraryVisualScenesTag(XMLTag);
       end else if (PassIndex=10) and (XMLTag.Name='scene') then begin
        ParseSceneTag(XMLTag);
       end;
      end;
     end;
    end;
    case PassIndex of
     3:begin
      Material:=LibraryMaterials;
      while assigned(Material) do begin
       Material^.Effect:=LibraryEffectsIDStringHashMap.Values[Material^.EffectURL];
       Material:=Material^.Next;
      end;
     end;
    end;
   end;
   result:=true;
  end;
 end;
 function ParseRoot(ParentItem:TXMLItem):boolean;
 var XMLItemIndex:longint;
     XMLItem:TXMLItem;
     XMLTag:TXMLTag;
 begin
  result:=false;
  if assigned(ParentItem) then begin
   for XMLItemIndex:=0 to ParentItem.Items.Count-1 do begin
    XMLItem:=ParentItem.Items[XMLItemIndex];
    if assigned(XMLItem) then begin
     if XMLItem is TXMLTag then begin
      XMLTag:=TXMLTag(XMLItem);
      if XMLTag.Name='COLLADA' then begin
       ParseCOLLADATag(XMLTag);
      end;
     end;
    end;
   end;
   result:=true;
  end;
 end;
 function ConvertNode(Node:PLibraryNode;var Matrix:TMatrix4x4;Name:ansistring):boolean;
 const stPOSITION=0;
       stNORMAL=1;
       stTANGENT=2;
       stBITANGENT=3;
       stTEXCOORD=4;
       stCOLOR=5;
 type TVectorArray=record
       Vectors:array of TVector4;
       Count:longint;
      end;
  procedure ConvertVectorSource(Source:PLibrarySource;var Target:TVectorArray;SourceType:longint);
  var Index,CountParams,Offset,Stride,DataSize,DataIndex,DataCount:longint;
      Mapping:array[0..3] of longint;
      Param:PLibrarySourceAccessorParam;
      SourceData:PLibrarySourceData;
      v:PVector4;
  begin
   if assigned(Source) then begin
    Mapping[0]:=-1;
    Mapping[1]:=-1;
    Mapping[2]:=-1;
    Mapping[3]:=-1;
    CountParams:=length(Source^.Accessor.Params);
    Offset:=Source^.Accessor.Offset;
    if Offset>0 then begin
    end;                          
    Stride:=Source^.Accessor.Stride;
    if Stride>0 then begin
     if CountParams>0 then begin
      for Index:=0 to CountParams-1 do begin
       Param:=@Source^.Accessor.Params[Index];
       if Param^.ParamType in [aptINT,aptFLOAT] then begin
        if BadAccessor and (length(Param^.ParamName)=0) then begin
         if (Index>=0) and (Index<=3) then begin
          Mapping[Index]:=Index;
         end;
        end else if ((SourceType in [stPOSITION,stNORMAL,stTANGENT,stBITANGENT]) and (Param^.ParamName='X')) or
                    ((SourceType in [stTEXCOORD]) and ((Param^.ParamName='X') or (Param^.ParamName='U') or (Param^.ParamName='S'))) or
                    ((SourceType in [stCOLOR]) and ((Param^.ParamName='X') or (Param^.ParamName='R'))) then begin
         Mapping[0]:=Index;
        end else if ((SourceType in [stPOSITION,stNORMAL,stTANGENT,stBITANGENT]) and (Param^.ParamName='Y')) or
                    ((SourceType in [stTEXCOORD]) and ((Param^.ParamName='Y') or (Param^.ParamName='V') or (Param^.ParamName='T'))) or
                    ((SourceType in [stCOLOR]) and ((Param^.ParamName='Y') or (Param^.ParamName='G'))) then begin
         Mapping[1]:=Index;
        end else if ((SourceType in [stPOSITION,stNORMAL,stTANGENT,stBITANGENT]) and (Param^.ParamName='Z')) or
                    ((SourceType in [stTEXCOORD]) and ((Param^.ParamName='Z') or (Param^.ParamName='W') or (Param^.ParamName='R'))) or
                    ((SourceType in [stCOLOR]) and ((Param^.ParamName='Z') or (Param^.ParamName='B'))) then begin
         Mapping[2]:=Index;
        end else if ((SourceType in [stPOSITION,stNORMAL,stTANGENT,stBITANGENT]) and (Param^.ParamName='W')) or
                    ((SourceType in [stCOLOR]) and ((Param^.ParamName='W') or (Param^.ParamName='A'))) then begin
         Mapping[3]:=Index;
        end;
       end;
      end;
     end;
     SourceData:=LibrarySourceDatasIDStringHashMap.Values[Source^.Accessor.Source];
     if not assigned(SourceData) then begin
      if Source^.SourceDatas.Count>0 then begin
       SourceData:=Source^.SourceDatas.Items[0];
      end;
     end;
     if assigned(SourceData) and (SourceData^.SourceType in [lstBOOL,lstINT,lstFLOAT]) then begin
      DataSize:=length(SourceData^.Data);
      DataCount:=DataSize div Stride;
      SetLength(Target.Vectors,DataCount);
      DataCount:=0;
      DataIndex:=0;
      while (DataIndex+(Stride-1))<DataSize do begin
       v:=@Target.Vectors[DataCount];
       for Index:=0 to 3 do begin
        if Mapping[Index]>=0 then begin
         v.xyzw[Index]:=SourceData^.Data[DataIndex+Mapping[Index]];
        end else begin
         v.xyzw[Index]:=0.0;
        end;
       end;
       inc(DataCount);
       inc(DataIndex,Stride);
      end;
      SetLength(Target.Vectors,DataCount);
      Target.Count:=DataCount;
     end;
    end;
   end;
  end;
 var Index,InputIndex,SubInputIndex,TexcoordSetIndex:longint;
     NodeMatrix,RotationMatrix:TMatrix4x4;
     Light:PDAELight;
     RemappedMaterials,RemappedInstanceMaterials:TStringHashMap;
     InstanceMaterial:PInstanceMaterial;
     LibraryMaterial:PLibraryMaterial;
     LibraryGeometryMesh:PLibraryGeometryMesh;
     Positions,Normals,Tangents,Bitangents,Colors:TVectorArray;
     PositionOffset,NormalOffset,TangentOffset,BitangentOffset,ColorOffset,
     IndicesIndex,IndicesCount,CountOffsets,VCountIndex,
     VertexIndex,VCount,ItemIndex,IndicesMeshIndex,VerticesCount,VertexSubCount,
     ArrayIndex,BaseIndex,CountTexCoords:longint;
     TexCoords:array[0..dlMAXTEXCOORDSETS-1] of TVectorArray;
     TexCoordOffsets:array[0..dlMAXTEXCOORDSETS-1] of longint;
     Input,SubInput:PInput;
     LibraryVertices:PLibraryVertices;
     LibrarySource:PLibrarySource;
     VerticesArray:TDAEVerticesArray;
     Camera:PDAECamera;
     Geometry:TDAEGeometry;
     Mesh:TDAEMesh;
     HasNormals,HasTangents:boolean;
 begin
  result:=false;
  VerticesArray:=nil;
  Positions.Vectors:=nil;
  Positions.Count:=0;
  Normals.Vectors:=nil;
  Normals.Count:=0;
  Tangents.Vectors:=nil;
  Tangents.Count:=0;
  Bitangents.Vectors:=nil;
  Bitangents.Count:=0;
  Colors.Vectors:=nil;
  Colors.Count:=0;
  for TexCoordSetIndex:=0 to dlMAXTEXCOORDSETS-1 do begin
   TexCoords[TexCoordSetIndex].Vectors:=nil;
   TexCoords[TexCoordSetIndex].Count:=0;
  end;
  try
   if assigned(Node) then begin
    case Node^.NodeType of
     ntNODE:begin
      if length(Name)>0 then begin
       Name:=Name+'/'+Node^.Name;
      end else begin
       Name:=Node^.Name;
      end;
      NodeMatrix:=Matrix;
      for Index:=0 to Node^.Children.Count-1 do begin
       ConvertNode(Node^.Children[Index],NodeMatrix,Name);
      end;
     end;
     ntROTATE,
     ntTRANSLATE,
     ntSCALE,
     ntMATRIX,
     ntLOOKAT,
     ntSKEW:begin
      Matrix:=Matrix4x4TermMul(Node^.Matrix,Matrix);
     end;
     ntEXTRA:begin
     end;
     ntINSTANCECAMERA:begin
      if assigned(Node^.InstanceCamera) then begin
       Index:=CountCameras;
       inc(CountCameras);
       if CountCameras>=length(Cameras) then begin
        SetLength(Cameras,CountCameras*2);
       end;
       Camera:=@Cameras[Index];
       Camera^:=Node^.InstanceCamera^.Camera;
       if length(Name)<>0 then begin
        if (length(Node^.InstanceCamera^.Name)<>0) and (Name<>Node^.InstanceCamera^.Name) then begin
         Camera^.Name:=Name+'/'+Node^.InstanceCamera^.Name;
        end else begin
         Camera^.Name:=Name;
        end;
       end else begin
        Camera^.Name:=Node^.InstanceCamera^.Name;
       end;
       Camera^.Matrix:=Matrix4x4TermMul(Matrix,AxisMatrix);
      end;
     end;
     ntINSTANCELIGHT:begin
      if assigned(Node^.InstanceLight) then begin
       Index:=CountLights;
       inc(CountLights);
       if CountLights>=length(Lights) then begin
        SetLength(Lights,CountLights*2);
       end;
       Light:=@Lights[Index];
       if length(Name)<>0 then begin
        if (length(Node^.InstanceLight^.Name)<>0) and (Name<>Node^.InstanceLight^.Name) then begin
         Light^.Name:=Name+'/'+Node^.InstanceLight^.Name;
        end else begin
         Light^.Name:=Name;
        end;
       end else begin
        Light^.Name:=Node^.InstanceLight^.Name;
       end;
       case Node^.InstanceLight^.LightType of
        ltAMBIENT:begin
         Light^.LightType:=dlltAMBIENT;
         Light^.Position:=Vector3TermMatrixMul(Vector3TermMatrixMul(Vector3Origin,Matrix),AxisMatrix);
         Light^.Color:=Node^.InstanceLight^.Color;
         Light^.ConstantAttenuation:=Node^.InstanceLight^.ConstantAttenuation;
         Light^.LinearAttenuation:=Node^.InstanceLight^.LinearAttenuation;
         Light^.QuadraticAttenuation:=Node^.InstanceLight^.QuadraticAttenuation;
        end;
        ltDIRECTIONAL:begin
         Light^.LightType:=dlltDIRECTIONAL;
         Light^.Position:=Vector3TermMatrixMul(Vector3TermMatrixMul(Vector3Origin,Matrix),AxisMatrix);
         Light^.Color:=Node^.InstanceLight^.Color;
         Light^.Direction:=Vector3Norm(Vector3Sub(Vector3TermMatrixMul(Vector3TermMatrixMul(Vector3(0.0,0.0,-1.0),Matrix),AxisMatrix),Light^.Position));
         Light^.ConstantAttenuation:=Node^.InstanceLight^.ConstantAttenuation;
         Light^.LinearAttenuation:=Node^.InstanceLight^.LinearAttenuation;
         Light^.QuadraticAttenuation:=Node^.InstanceLight^.QuadraticAttenuation;
        end;
        ltPOINT:begin
         Light^.LightType:=dlltPOINT;
         Light^.Position:=Vector3TermMatrixMul(Vector3TermMatrixMul(Vector3Origin,Matrix),AxisMatrix);
         Light^.Color:=Node^.InstanceLight^.Color;
         Light^.ConstantAttenuation:=Node^.InstanceLight^.ConstantAttenuation;
         Light^.LinearAttenuation:=Node^.InstanceLight^.LinearAttenuation;
         Light^.QuadraticAttenuation:=Node^.InstanceLight^.QuadraticAttenuation;
        end;
        ltSPOT:begin
         Light^.LightType:=dlltSPOT;
         Light^.Position:=Vector3TermMatrixMul(Vector3TermMatrixMul(Vector3Origin,Matrix),AxisMatrix);
         Light^.Color:=Node^.InstanceLight^.Color;
         Light^.Direction:=Vector3Norm(Vector3Sub(Vector3TermMatrixMul(Vector3TermMatrixMul(Vector3(0.0,0.0,-1.0),Matrix),AxisMatrix),Light^.Position));
         Light^.FallOffAngle:=Node^.InstanceLight^.FallOffAngle;
         Light^.FallOffExponent:=Node^.InstanceLight^.FallOffExponent;
         Light^.ConstantAttenuation:=Node^.InstanceLight^.ConstantAttenuation;
         Light^.LinearAttenuation:=Node^.InstanceLight^.LinearAttenuation;
         Light^.QuadraticAttenuation:=Node^.InstanceLight^.QuadraticAttenuation;
        end;
       end;
      end;
     end;
     ntINSTANCECONTROLLER:begin
     end;
     ntINSTANCEGEOMETRY:begin
      if assigned(Node^.InstanceGeometry) then begin
       RotationMatrix:=Matrix4x4Rotation(Matrix);
       Geometry:=TDAEGeometry.Create;
       Geometry.Name:=Name;
       Geometries.Add(Geometry);
       RemappedMaterials:=TStringHashMap.Create;
       RemappedInstanceMaterials:=TStringHashMap.Create;
       try
        for Index:=0 to length(Node^.InstanceMaterials)-1 do begin
         LibraryMaterial:=LibraryMaterialsIDStringHashMap.Values[Node^.InstanceMaterials[Index].Target];
         if assigned(LibraryMaterial) then begin
          RemappedMaterials.Add(Node^.InstanceMaterials[Index].Symbol,LibraryMaterial);
          RemappedInstanceMaterials.Add(Node^.InstanceMaterials[Index].Symbol,@Node^.InstanceMaterials[Index]);
         end;
        end;
        for Index:=0 to length(Node^.InstanceGeometry.Meshs)-1 do begin
         LibraryGeometryMesh:=@Node^.InstanceGeometry.Meshs[Index];
         if length(LibraryGeometryMesh^.Indices)>0 then begin
          SetLength(Positions.Vectors,0);
          Positions.Count:=0;
          SetLength(Normals.Vectors,0);
          Normals.Count:=0;
          SetLength(Tangents.Vectors,0);
          Tangents.Count:=0;
          SetLength(Bitangents.Vectors,0);
          Bitangents.Count:=0;
          SetLength(Colors.Vectors,0);
          Colors.Count:=0;
          for TexCoordSetIndex:=0 to dlMAXTEXCOORDSETS-1 do begin
           SetLength(TexCoords[TexCoordSetIndex].Vectors,0);
           TexCoords[TexCoordSetIndex].Count:=0;
          end;
          PositionOffset:=-1;
          NormalOffset:=-1;
          TangentOffset:=-1;
          BitangentOffset:=-1;
          ColorOffset:=-1;
          for TexCoordSetIndex:=0 to dlMAXTEXCOORDSETS-1 do begin
           TexCoordOffsets[TexCoordSetIndex]:=-1;
          end;
          CountTexCoords:=0;
          CountOffsets:=0;
          for InputIndex:=0 to length(LibraryGeometryMesh^.Inputs)-1 do begin
           Input:=@LibraryGeometryMesh^.Inputs[InputIndex];
           CountOffsets:=Max(CountOffsets,Input^.Offset+1);
           LibrarySource:=nil;
           if Input^.Semantic='VERTEX' then begin
            LibraryVertices:=LibraryVerticesesIDStringHashMap.Values[Input^.Source];
            if assigned(LibraryVertices) then begin
             for SubInputIndex:=0 to length(LibraryVertices^.Inputs)-1 do begin
              SubInput:=@LibraryVertices^.Inputs[SubInputIndex];
              if SubInput^.Semantic='POSITION' then begin
               PositionOffset:=Input^.Offset;
               LibrarySource:=LibrarySourcesIDStringHashMap.Values[SubInput^.Source];
               if assigned(LibrarySource) then begin
                ConvertVectorSource(LibrarySource,Positions,stPOSITION);
               end;
              end else if SubInput^.Semantic='NORMAL' then begin
               NormalOffset:=Input^.Offset;
               LibrarySource:=LibrarySourcesIDStringHashMap.Values[SubInput^.Source];
               if assigned(LibrarySource) then begin
                ConvertVectorSource(LibrarySource,Normals,stNORMAL);
               end;
              end else if SubInput^.Semantic='TANGENT' then begin
               TangentOffset:=Input^.Offset;
               LibrarySource:=LibrarySourcesIDStringHashMap.Values[SubInput^.Source];
               if assigned(LibrarySource) then begin
                ConvertVectorSource(LibrarySource,Tangents,stTANGENT);
               end;
              end else if (SubInput^.Semantic='BINORMAL') or (SubInput^.Semantic='BITANGENT') then begin
               BitangentOffset:=Input^.Offset;
               LibrarySource:=LibrarySourcesIDStringHashMap.Values[SubInput^.Source];
               if assigned(LibrarySource) then begin
                ConvertVectorSource(LibrarySource,Bitangents,stBITANGENT);
               end;
              end else if SubInput^.Semantic='TEXCOORD' then begin
               if (SubInput^.Set_>=0) and (SubInput^.Set_<dlMAXTEXCOORDSETS) then begin
                CountTexCoords:=Max(CountTexCoords,SubInput^.Set_+1);
                TexCoordOffsets[SubInput^.Set_]:=Input^.Offset;
                LibrarySource:=LibrarySourcesIDStringHashMap.Values[SubInput^.Source];
                if assigned(LibrarySource) then begin
                 ConvertVectorSource(LibrarySource,TexCoords[SubInput^.Set_],stTEXCOORD);
                end;
               end;
              end else if SubInput^.Semantic='COLOR' then begin
               ColorOffset:=Input^.Offset;
               LibrarySource:=LibrarySourcesIDStringHashMap.Values[SubInput^.Source];
               if assigned(LibrarySource) then begin
                ConvertVectorSource(LibrarySource,Colors,stCOLOR);
               end;
              end;
             end;
            end;
           end else if Input^.Semantic='POSITION' then begin
            PositionOffset:=Input^.Offset;
            LibrarySource:=LibrarySourcesIDStringHashMap.Values[Input^.Source];
            if assigned(LibrarySource) then begin
             ConvertVectorSource(LibrarySource,Positions,stPOSITION);
            end;
           end else if Input^.Semantic='NORMAL' then begin
            NormalOffset:=Input^.Offset;
            LibrarySource:=LibrarySourcesIDStringHashMap.Values[Input^.Source];
            if assigned(LibrarySource) then begin
             ConvertVectorSource(LibrarySource,Normals,stNORMAL);
            end;
           end else if Input^.Semantic='TANGENT' then begin
            TangentOffset:=Input^.Offset;
            LibrarySource:=LibrarySourcesIDStringHashMap.Values[Input^.Source];
            if assigned(LibrarySource) then begin
             ConvertVectorSource(LibrarySource,Tangents,stTANGENT);
            end;
           end else if (Input^.Semantic='BINORMAL') or (Input^.Semantic='BITANGENT') then begin
            BitangentOffset:=Input^.Offset;
            LibrarySource:=LibrarySourcesIDStringHashMap.Values[Input^.Source];
            if assigned(LibrarySource) then begin
             ConvertVectorSource(LibrarySource,Bitangents,stBITANGENT);
            end;
           end else if Input^.Semantic='TEXCOORD' then begin
            if (Input^.Set_>=0) and (Input^.Set_<dlMAXTEXCOORDSETS) then begin
             CountTexCoords:=Max(CountTexCoords,Input^.Set_+1);
             TexCoordOffsets[Input^.Set_]:=Input^.Offset;
             LibrarySource:=LibrarySourcesIDStringHashMap.Values[Input^.Source];
             if assigned(LibrarySource) then begin
              ConvertVectorSource(LibrarySource,TexCoords[Input^.Set_],stTEXCOORD);
             end;
            end;
           end else if Input^.Semantic='COLOR' then begin
            ColorOffset:=Input^.Offset;
            LibrarySource:=LibrarySourcesIDStringHashMap.Values[Input^.Source];
            if assigned(LibrarySource) then begin
             ConvertVectorSource(LibrarySource,Colors,stCOLOR);
            end;
           end;
          end;
          if CountOffsets>0 then begin
           for IndicesMeshIndex:=0 to length(LibraryGeometryMesh^.Indices)-1 do begin
            if length(LibraryGeometryMesh^.Indices[IndicesMeshIndex])>0 then begin
             HasNormals:=false;
             HasTangents:=false;
             VCountIndex:=0;
             IndicesIndex:=0;
             IndicesCount:=length(LibraryGeometryMesh.Indices[IndicesMeshIndex]);
             SetLength(VerticesArray,IndicesCount);
             VerticesCount:=0;
             while IndicesIndex<IndicesCount do begin
              if (LibraryGeometryMesh^.MeshType=mtPOLYLIST) and
                 ((VCountIndex>=0) and (VCountIndex<length(LibraryGeometryMesh^.VCounts))) then begin
               VCount:=LibraryGeometryMesh^.VCounts[VCountIndex];
               inc(VCountIndex);
              end else begin
               case LibraryGeometryMesh^.MeshType of
                mtTRIANGLES:begin
                 VCount:=3;
                end;
                mtTRIFANS:begin
                 VCount:=1;
                end;
                mtTRISTRIPS:begin
                 VCount:=1;
                end;
                mtPOLYGONS:begin
                 VCount:=1;
                end;
                mtPOLYLIST:begin
                 VCount:=IndicesCount div CountOffsets;
                end;
                mtLINES:begin
                 VCount:=2;
                end;
                mtLINESTRIPS:begin
                 VCount:=IndicesCount div CountOffsets;
                end;
                else begin
                 VCount:=IndicesCount div CountOffsets;
                end;
               end;
              end;
              SetLength(VerticesArray[VerticesCount],VCount);
              FillChar(VerticesArray[VerticesCount,0],VCount*SizeOf(TDAEVertex),AnsiChar(#0));
              for VertexIndex:=0 to VCount-1 do begin
               VerticesArray[VerticesCount,VertexIndex].Position:=Vector3Origin;
               VerticesArray[VerticesCount,VertexIndex].Normal:=Vector3Origin;
               VerticesArray[VerticesCount,VertexIndex].Tangent:=Vector3Origin;
               VerticesArray[VerticesCount,VertexIndex].Bitangent:=Vector3Origin;
               for TexCoordSetIndex:=0 to dlMAXTEXCOORDSETS-1 do begin
                VerticesArray[VerticesCount,VertexIndex].TexCoords[TexCoordSetIndex]:=Vector2Origin;
               end;
               VerticesArray[VerticesCount,VertexIndex].CountTexCoords:=CountTexCoords;
               VerticesArray[VerticesCount,VertexIndex].Color.x:=1.0;
               VerticesArray[VerticesCount,VertexIndex].Color.y:=1.0;
               VerticesArray[VerticesCount,VertexIndex].Color.z:=1.0;
               BaseIndex:=IndicesIndex+(VertexIndex*CountOffsets);
               if PositionOffset>=0 then begin
                ArrayIndex:=BaseIndex+PositionOffset;
                if (ArrayIndex>=0) and (ArrayIndex<length(LibraryGeometryMesh^.Indices[IndicesMeshIndex])) then begin
                 ItemIndex:=LibraryGeometryMesh^.Indices[IndicesMeshIndex,ArrayIndex];
                 if (ItemIndex>=0) and (ItemIndex<Positions.Count) then begin
                  VerticesArray[VerticesCount,VertexIndex].Position.x:=Positions.Vectors[ItemIndex].x;
                  VerticesArray[VerticesCount,VertexIndex].Position.y:=Positions.Vectors[ItemIndex].y;
                  VerticesArray[VerticesCount,VertexIndex].Position.z:=Positions.Vectors[ItemIndex].z;
                 end;
                end;
               end;
               if NormalOffset>=0 then begin
                ArrayIndex:=BaseIndex+NormalOffset;
                if (ArrayIndex>=0) and (ArrayIndex<length(LibraryGeometryMesh^.Indices[IndicesMeshIndex])) then begin
                 ItemIndex:=LibraryGeometryMesh^.Indices[IndicesMeshIndex,ArrayIndex];
                 if (ItemIndex>=0) and (ItemIndex<Normals.Count) then begin
                  VerticesArray[VerticesCount,VertexIndex].Normal.x:=Normals.Vectors[ItemIndex].x;
                  VerticesArray[VerticesCount,VertexIndex].Normal.y:=Normals.Vectors[ItemIndex].y;
                  VerticesArray[VerticesCount,VertexIndex].Normal.z:=Normals.Vectors[ItemIndex].z;
                  HasNormals:=true;
                 end;
                end;
               end;
               if TangentOffset>=0 then begin
                ArrayIndex:=BaseIndex+TangentOffset;
                if (ArrayIndex>=0) and (ArrayIndex<length(LibraryGeometryMesh^.Indices[IndicesMeshIndex])) then begin
                 ItemIndex:=LibraryGeometryMesh^.Indices[IndicesMeshIndex,ArrayIndex];
                 if (ItemIndex>=0) and (ItemIndex<Tangents.Count) then begin
                  VerticesArray[VerticesCount,VertexIndex].Tangent.x:=Tangents.Vectors[ItemIndex].x;
                  VerticesArray[VerticesCount,VertexIndex].Tangent.y:=Tangents.Vectors[ItemIndex].y;
                  VerticesArray[VerticesCount,VertexIndex].Tangent.z:=Tangents.Vectors[ItemIndex].z;
                  HasTangents:=true;
                 end;
                end;
               end;
               if BitangentOffset>=0 then begin
                ArrayIndex:=BaseIndex+BitangentOffset;
                if (ArrayIndex>=0) and (ArrayIndex<length(LibraryGeometryMesh^.Indices[IndicesMeshIndex])) then begin
                 ItemIndex:=LibraryGeometryMesh^.Indices[IndicesMeshIndex,ArrayIndex];
                 if (ItemIndex>=0) and (ItemIndex<Bitangents.Count) then begin
                  VerticesArray[VerticesCount,VertexIndex].Bitangent.x:=Bitangents.Vectors[ItemIndex].x;
                  VerticesArray[VerticesCount,VertexIndex].Bitangent.y:=Bitangents.Vectors[ItemIndex].y;
                  VerticesArray[VerticesCount,VertexIndex].Bitangent.z:=Bitangents.Vectors[ItemIndex].z;
                  HasTangents:=true;
                 end;
                end;
               end;
               for TexCoordSetIndex:=0 to dlMAXTEXCOORDSETS-1 do begin
                if TexCoordOffsets[TexCoordSetIndex]>=0 then begin
                 ArrayIndex:=BaseIndex+TexCoordOffsets[TexCoordSetIndex];
                 if (ArrayIndex>=0) and (ArrayIndex<length(LibraryGeometryMesh^.Indices[IndicesMeshIndex])) then begin
                  ItemIndex:=LibraryGeometryMesh^.Indices[IndicesMeshIndex,ArrayIndex];
                  if (ItemIndex>=0) and (ItemIndex<TexCoords[TexCoordSetIndex].Count) then begin
                   VerticesArray[VerticesCount,VertexIndex].CountTexCoords:=Max(VerticesArray[VerticesCount,VertexIndex].CountTexCoords,TexCoordSetIndex+1);
                   VerticesArray[VerticesCount,VertexIndex].TexCoords[TexCoordSetIndex].x:=TexCoords[TexCoordSetIndex].Vectors[ItemIndex].x;
                   VerticesArray[VerticesCount,VertexIndex].TexCoords[TexCoordSetIndex].y:=1.0-TexCoords[TexCoordSetIndex].Vectors[ItemIndex].y;
                  end;
                 end;
                end;
               end;
               if ColorOffset>=0 then begin
                ArrayIndex:=BaseIndex+ColorOffset;
                if (ArrayIndex>=0) and (ArrayIndex<length(LibraryGeometryMesh^.Indices[IndicesMeshIndex])) then begin
                 ItemIndex:=LibraryGeometryMesh^.Indices[IndicesMeshIndex,ArrayIndex];
                 if (ItemIndex>=0) and (ItemIndex<Colors.Count) then begin
                  VerticesArray[VerticesCount,VertexIndex].Color.x:=Colors.Vectors[ItemIndex].x;
                  VerticesArray[VerticesCount,VertexIndex].Color.y:=Colors.Vectors[ItemIndex].y;
                  VerticesArray[VerticesCount,VertexIndex].Color.z:=Colors.Vectors[ItemIndex].z;
                 end;
                end;
               end;
               Vector3MatrixMul(VerticesArray[VerticesCount,VertexIndex].Position,Matrix);
               Vector3MatrixMul(VerticesArray[VerticesCount,VertexIndex].Normal,RotationMatrix);
               Vector3MatrixMul(VerticesArray[VerticesCount,VertexIndex].Tangent,RotationMatrix);
               Vector3MatrixMul(VerticesArray[VerticesCount,VertexIndex].Bitangent,RotationMatrix);
               Vector3MatrixMul(VerticesArray[VerticesCount,VertexIndex].Position,AxisMatrix);
               Vector3MatrixMul(VerticesArray[VerticesCount,VertexIndex].Normal,AxisMatrix);
               Vector3MatrixMul(VerticesArray[VerticesCount,VertexIndex].Tangent,AxisMatrix);
               Vector3MatrixMul(VerticesArray[VerticesCount,VertexIndex].Bitangent,AxisMatrix);
               Vector3Normalize(VerticesArray[VerticesCount,VertexIndex].Normal);
               Vector3Normalize(VerticesArray[VerticesCount,VertexIndex].Tangent);
               Vector3Normalize(VerticesArray[VerticesCount,VertexIndex].Bitangent);
              end;
              inc(VerticesCount);
              inc(IndicesIndex,CountOffsets*VCount);
             end;
             SetLength(VerticesArray,VerticesCount);
             if VerticesCount>0 then begin
              case LibraryGeometryMesh^.MeshType of
               mtTRIANGLES:begin
                Mesh:=TDAEMesh.Create;
                Geometry.Add(Mesh);
                Mesh.MeshType:=dlmtTRIANGLES;
                Mesh.TexCoordSets:=nil;
                LibraryMaterial:=RemappedMaterials.Values[LibraryGeometryMesh^.Material];
                if assigned(LibraryMaterial) then begin
                 Mesh.MaterialIndex:=LibraryMaterial^.Index;
                 InstanceMaterial:=RemappedInstanceMaterials.Values[LibraryGeometryMesh^.Material];
                 if assigned(InstanceMaterial) then begin
                  SetLength(Mesh.TexCoordSets,length(InstanceMaterial^.TexCoordSets));
                  for TexCoordSetIndex:=0 to length(InstanceMaterial^.TexCoordSets)-1 do begin
                   Mesh.TexCoordSets[TexCoordSetIndex].Semantic:=InstanceMaterial^.TexCoordSets[TexCoordSetIndex].Semantic;
                   Mesh.TexCoordSets[TexCoordSetIndex].InputSet:=InstanceMaterial^.TexCoordSets[TexCoordSetIndex].InputSet;
                  end;
                 end;
                end else begin
                 Mesh.MaterialIndex:=-1;
                end;
                SetLength(Mesh.Vertices,VerticesCount*3);
                SetLength(Mesh.Indices,VerticesCount*3);
                for BaseIndex:=0 to VerticesCount-1 do begin
                 Mesh.Vertices[(BaseIndex*3)+0]:=VerticesArray[BaseIndex,0];
                 Mesh.Vertices[(BaseIndex*3)+1]:=VerticesArray[BaseIndex,1];
                 Mesh.Vertices[(BaseIndex*3)+2]:=VerticesArray[BaseIndex,2];
                 Mesh.Indices[(BaseIndex*3)+0]:=(BaseIndex*3)+0;
                 Mesh.Indices[(BaseIndex*3)+1]:=(BaseIndex*3)+1;
                 Mesh.Indices[(BaseIndex*3)+2]:=(BaseIndex*3)+2;
                end;
                Mesh.Optimize;
                Mesh.CalculateMissingInformations(not HasNormals,not HasTangents);
                Mesh.Optimize;
               end;
               mtTRIFANS:begin
                Mesh:=TDAEMesh.Create;
                Geometry.Add(Mesh);
                LibraryMaterial:=RemappedMaterials.Values[LibraryGeometryMesh^.Material];
                Mesh.MeshType:=dlmtTRIANGLES;
                if assigned(LibraryMaterial) then begin
                 Mesh.MaterialIndex:=LibraryMaterial^.Index;
                end else begin
                 Mesh.MaterialIndex:=-1;
                end;
                SetLength(Mesh.Vertices,VerticesCount);
                for BaseIndex:=0 to VerticesCount-1 do begin
                 Mesh.Vertices[BaseIndex]:=VerticesArray[BaseIndex,0];
                end;
                SetLength(Mesh.Indices,VerticesCount*3);
                IndicesCount:=0;
                for BaseIndex:=0 to VerticesCount-3 do begin
                 Mesh.Indices[IndicesCount+0]:=0;
                 Mesh.Indices[IndicesCount+1]:=BaseIndex+1;
                 Mesh.Indices[IndicesCount+2]:=BaseIndex+2;
                 inc(IndicesCount,3);                      
                end;
                SetLength(Mesh.Indices,IndicesCount);
                Mesh.Optimize;
                Mesh.CalculateMissingInformations(not HasNormals,not HasTangents);
                Mesh.Optimize;
               end;
               mtTRISTRIPS:begin
                Mesh:=TDAEMesh.Create;
                Geometry.Add(Mesh);
                LibraryMaterial:=RemappedMaterials.Values[LibraryGeometryMesh^.Material];
                Mesh.MeshType:=dlmtTRIANGLES;
                if assigned(LibraryMaterial) then begin
                 Mesh.MaterialIndex:=LibraryMaterial^.Index;
                end else begin
                 Mesh.MaterialIndex:=-1;
                end;
                SetLength(Mesh.Vertices,VerticesCount);
                for BaseIndex:=0 to VerticesCount-1 do begin
                 Mesh.Vertices[BaseIndex]:=VerticesArray[BaseIndex,0];
                end;
                SetLength(Mesh.Indices,VerticesCount*3);
                IndicesCount:=0;
                for BaseIndex:=0 to VerticesCount-3 do begin
                 if (BaseIndex and 1)<>0 then begin
                  Mesh.Indices[IndicesCount+0]:=BaseIndex;
                  Mesh.Indices[IndicesCount+1]:=BaseIndex+2;
                  Mesh.Indices[IndicesCount+2]:=BaseIndex+1;
                 end else begin
                  Mesh.Indices[IndicesCount+0]:=BaseIndex;
                  Mesh.Indices[IndicesCount+1]:=BaseIndex+1;
                  Mesh.Indices[IndicesCount+2]:=BaseIndex+2;
                 end;
                 inc(IndicesCount,3);
                end;
                SetLength(Mesh.Indices,IndicesCount);
                Mesh.Optimize;
                Mesh.CalculateMissingInformations(not HasNormals,not HasTangents);
                Mesh.Optimize;
               end;
               mtPOLYGONS:begin
                Mesh:=TDAEMesh.Create;
                Geometry.Add(Mesh);
                LibraryMaterial:=RemappedMaterials.Values[LibraryGeometryMesh^.Material];
                Mesh.MeshType:=dlmtTRIANGLES;
                if assigned(LibraryMaterial) then begin
                 Mesh.MaterialIndex:=LibraryMaterial^.Index;
                end else begin
                 Mesh.MaterialIndex:=-1;
                end;
                SetLength(Mesh.Vertices,VerticesCount);
                for BaseIndex:=0 to VerticesCount-1 do begin
                 Mesh.Vertices[BaseIndex]:=VerticesArray[BaseIndex,0];
                end;
                SetLength(Mesh.Indices,VerticesCount*3);
                IndicesCount:=0;
                for BaseIndex:=0 to VerticesCount-3 do begin
                 Mesh.Indices[IndicesCount+0]:=0;
                 Mesh.Indices[IndicesCount+1]:=BaseIndex+1;
                 Mesh.Indices[IndicesCount+2]:=BaseIndex+2;
                 inc(IndicesCount,3);
                end;
                SetLength(Mesh.Indices,IndicesCount);
                Mesh.Optimize;
                Mesh.CalculateMissingInformations(not HasNormals,not HasTangents);
                Mesh.Optimize;
               end;
               mtPOLYLIST:begin
                Mesh:=TDAEMesh.Create;
                Geometry.Add(Mesh);
                LibraryMaterial:=RemappedMaterials.Values[LibraryGeometryMesh^.Material];
                Mesh.MeshType:=dlmtTRIANGLES;
                if assigned(LibraryMaterial) then begin
                 Mesh.MaterialIndex:=LibraryMaterial^.Index;
                end else begin
                 Mesh.MaterialIndex:=-1;
                end;
                VCount:=0;
                for BaseIndex:=0 to VerticesCount-1 do begin
                 inc(VCount,length(VerticesArray[BaseIndex]));
                end;
                SetLength(Mesh.Vertices,VCount+2);
                SetLength(Mesh.Indices,(VCount+2)*3);
                VCount:=0;
                IndicesCount:=0;
                for BaseIndex:=0 to VerticesCount-1 do begin
                 VertexSubCount:=length(VerticesArray[BaseIndex]);
                 if (VCount+VertexSubCount)>length(Mesh.Indices) then begin
                  SetLength(Mesh.Vertices,NextPowerOfTwo(VCount+VertexSubCount));
                 end;
                 for ArrayIndex:=0 to VertexSubCount-1 do begin
                  Mesh.Vertices[VCount+ArrayIndex]:=VerticesArray[BaseIndex,ArrayIndex];
                 end;
                 for ArrayIndex:=0 to VertexSubCount-3 do begin
                  if (IndicesCount+3)>length(Mesh.Indices) then begin
                   SetLength(Mesh.Indices,NextPowerOfTwo(IndicesCount+3));
                  end;
                  Mesh.Indices[IndicesCount+0]:=VCount;
                  Mesh.Indices[IndicesCount+1]:=VCount+ArrayIndex+1;
                  Mesh.Indices[IndicesCount+2]:=VCount+ArrayIndex+2;
                  inc(IndicesCount,3);
                 end;
                 inc(VCount,VertexSubCount);
                end;
                SetLength(Mesh.Vertices,VCount);
                SetLength(Mesh.Indices,IndicesCount);
                Mesh.Optimize;
                Mesh.CalculateMissingInformations(not HasNormals,not HasTangents);
                Mesh.Optimize;
               end;
               mtLINES:begin
                for BaseIndex:=0 to VerticesCount-1 do begin
                 Mesh:=TDAEMesh.Create;
                 Geometry.Add(Mesh);
                 Mesh.MeshType:=dlmtLINESTRIP;
                 LibraryMaterial:=RemappedMaterials.Values[LibraryGeometryMesh^.Material];
                 if assigned(LibraryMaterial) then begin
                  Mesh.MaterialIndex:=LibraryMaterial^.Index;
                 end else begin
                  Mesh.MaterialIndex:=-1;
                 end;
                 SetLength(Mesh.Vertices,2);
                 Mesh.Vertices[0]:=VerticesArray[BaseIndex,0];
                 Mesh.Vertices[1]:=VerticesArray[BaseIndex,1];
                 SetLength(Mesh.Indices,2);
                 Mesh.Indices[0]:=0;
                 Mesh.Indices[1]:=1;
                 Mesh.Optimize;
                 Mesh.CalculateMissingInformations(not HasNormals,not HasTangents);
                 Mesh.Optimize;
                end;
               end;
               mtLINESTRIPS:begin
                Mesh:=TDAEMesh.Create;
                Geometry.Add(Mesh);
                Mesh.MeshType:=dlmtLINESTRIP;
                LibraryMaterial:=RemappedMaterials.Values[LibraryGeometryMesh^.Material];
                if assigned(LibraryMaterial) then begin
                 Mesh.MaterialIndex:=LibraryMaterial^.Index;
                end else begin
                 Mesh.MaterialIndex:=-1;
                end;
                if length(VerticesArray)>0 then begin
                 Mesh.Vertices:=copy(VerticesArray[0],0,length(VerticesArray[0]));
                 SetLength(Mesh.Indices,length(Mesh.Vertices));
                 for ArrayIndex:=0 to length(Mesh.Indices)-1 do begin
                  Mesh.Indices[ArrayIndex]:=ArrayIndex;
                 end;
                 Mesh.Optimize;
                 Mesh.CalculateMissingInformations(not HasNormals,not HasTangents);
                 Mesh.Optimize;
                end else begin
                 Mesh.Vertices:=nil;
                 Mesh.Indices:=nil;
                end;
               end;
              end;
             end;
            end;
           end;
          end;
         end;
        end;

       finally
        RemappedMaterials.Free;
        RemappedInstanceMaterials.Free;
       end;
      end;
     end;
     ntINSTANCENODE:begin
      ConvertNode(LibraryNodesIDStringHashMap.Values[Node^.InstanceNode],Matrix,Name);
     end;
    end;
    result:=true;
   end;
  finally
   SetLength(Positions.Vectors,0);
   SetLength(Normals.Vectors,0);
   SetLength(Tangents.Vectors,0);
   SetLength(Bitangents.Vectors,0);
   SetLength(Colors.Vectors,0);
   for TexCoordSetIndex:=0 to dlMAXTEXCOORDSETS-1 do begin
    SetLength(TexCoords[TexCoordSetIndex].Vectors,0);
   end;
   SetLength(VerticesArray,0);
  end;
 end;
 procedure ConvertMaterials;
 var LibraryMaterial:PLibraryMaterial;
     Material:PDAEMaterial;
 begin
  LibraryMaterial:=LibraryMaterials;
  while assigned(LibraryMaterial) do begin
   if assigned(LibraryMaterial^.Effect) then begin
    if (CountMaterials+1)>length(Materials) then begin
     SetLength(Materials,(CountMaterials+1)*2);
    end;
    LibraryMaterial^.Index:=CountMaterials;
    Material:=@Materials[CountMaterials];
    FillChar(Material^,SizeOf(TDAEMaterial),AnsiChar(#0));
    inc(CountMaterials);
    Material^.Name:=LibraryMaterial^.Name;
    Material^.ShadingType:=LibraryMaterial^.Effect^.ShadingType;
    Material^.Ambient:=LibraryMaterial^.Effect^.Ambient;
    Material^.Diffuse:=LibraryMaterial^.Effect^.Diffuse;
    Material^.Emission:=LibraryMaterial^.Effect^.Emission;
    Material^.Specular:=LibraryMaterial^.Effect^.Specular;
    Material^.Transparent:=LibraryMaterial^.Effect^.Transparent;
    Material^.Shininess:=LibraryMaterial^.Effect^.Shininess;
    Material^.Reflectivity:=LibraryMaterial^.Effect^.Reflectivity;
    Material^.IndexOfRefraction:=LibraryMaterial^.Effect^.IndexOfRefraction;
    Material^.Transparency:=LibraryMaterial^.Effect^.Transparency;
   end;
   LibraryMaterial:=LibraryMaterial^.Next;
  end;
 end;
 function Convert:boolean;
 var Index:longint;
     NodeMatrix:TMatrix4x4;
 begin
  result:=false;
  if assigned(MainVisualScene) then begin
   case UpAxis of
    dluaXUP:begin
     AxisMatrix:=Matrix4x4(0.0,-1.0,0.0,0.0,
                           1.0,0.0,0.0,0.0,
                           0.0,0.0,1.0,0.0,
                           0.0,0.0,0.0,1.0);
    end;
    dluaZUP:begin
     AxisMatrix:=Matrix4x4(1.0,0.0,0.0,0.0,
                           0.0,0.0,1.0,0.0,
                           0.0,-1.0,0.0,0.0,
                           0.0,0.0,0.0,1.0);
    end;
    else {dluaYUP:}begin
     AxisMatrix:=Matrix4x4(1.0,0.0,0.0,0.0,
                           0.0,1.0,0.0,0.0,
                           0.0,0.0,1.0,0.0,
                           0.0,0.0,0.0,1.0);
    end;
   end;
   ConvertMaterials;
   for Index:=0 to MainVisualScene^.Items.Count-1 do begin
    NodeMatrix:=Matrix4x4Identity;
    ConvertNode(MainVisualScene^.Items[Index],NodeMatrix,'');
   end;
   result:=true;
  end;
 end;
var Index:longint;
    XML:TXML;
    Next,SubNext:pointer;
begin
 result:=false;
 XML:=TXML.Create;
 try
  IDStringHashMap:=TStringHashMap.Create;
  LibraryImagesIDStringHashMap:=TStringHashMap.Create;
  LibraryImages:=nil;
  LibraryMaterialsIDStringHashMap:=TStringHashMap.Create;
  LibraryMaterials:=nil;
  LibraryEffectsIDStringHashMap:=TStringHashMap.Create;
  LibraryEffects:=nil;
  LibrarySourcesIDStringHashMap:=TStringHashMap.Create;
  LibrarySources:=nil;
  LibrarySourceDatasIDStringHashMap:=TStringHashMap.Create;
  LibrarySourceDatas:=nil;
  LibraryVerticesesIDStringHashMap:=TStringHashMap.Create;
  LibraryVerticeses:=nil;
  LibraryGeometriesIDStringHashMap:=TStringHashMap.Create;
  LibraryGeometries:=nil;
  LibraryCamerasIDStringHashMap:=TStringHashMap.Create;
  LibraryCameras:=nil;
  LibraryLightsIDStringHashMap:=TStringHashMap.Create;
  LibraryLights:=nil;
  LibraryVisualScenesIDStringHashMap:=TStringHashMap.Create;
  LibraryVisualScenes:=nil;
  LibraryNodesIDStringHashMap:=TStringHashMap.Create;
  LibraryNodes:=nil;
  try
   if XML.Read(Stream) then begin
    COLLADAVersion:='1.5.0';
    AuthoringTool:='';
    Created:=Now;
    Modified:=Now;
    UnitMeter:=1.0;
    UnitName:='meter';
    UpAxis:=dluaYUP;
    MainVisualScene:=nil;
    SetLength(Lights,0);
    CountLights:=0;
    SetLength(Cameras,0);
    CountCameras:=0;
    SetLength(Materials,0);
    CountMaterials:=0;
    BadAccessor:=false;
    FlipAngle:=false;
    NegJoints:=false;
    CollectIDs(XML.Root);
    result:=ParseRoot(XML.Root);
    if result then begin
     result:=Convert;
    end;
    SetLength(Lights,CountLights);
    SetLength(Materials,CountMaterials);
   end;
  finally
   begin
    while assigned(LibraryNodes) do begin
     Next:=LibraryNodes^.Next;
     LibraryNodes^.ID:='';
     LibraryNodes^.Name:='';
     for Index:=0 to length(LibraryNodes^.InstanceMaterials)-1 do begin
      SetLength(LibraryNodes^.InstanceMaterials[Index].TexCoordSets,0);
     end;
     SetLength(LibraryNodes^.InstanceMaterials,0);
     LibraryNodes^.InstanceNode:='';
     if LibraryNodes^.NodeType=ntNODE then begin
      FreeAndNil(LibraryNodes^.Children);
     end;
     FreeMem(LibraryNodes);
     LibraryNodes:=Next;
    end;
    LibraryNodesIDStringHashMap.Free;
   end;
   begin
    while assigned(LibraryVisualScenes) do begin
     Next:=LibraryVisualScenes^.Next;
     LibraryVisualScenes^.ID:='';
     FreeAndNil(LibraryVisualScenes^.Items);
     FreeMem(LibraryVisualScenes);
     LibraryVisualScenes:=Next;
    end;
    LibraryVisualScenesIDStringHashMap.Free;
   end;
   begin
    while assigned(LibraryCameras) do begin
     Next:=LibraryCameras^.Next;
     LibraryCameras^.ID:='';
     LibraryCameras^.Name:='';
     LibraryCameras^.Camera.Name:='';
     Finalize(LibraryCameras^);
     FreeMem(LibraryCameras);
     LibraryCameras:=Next;
    end;
    LibraryCamerasIDStringHashMap.Free;
   end;
   begin
    while assigned(LibraryLights) do begin
     Next:=LibraryLights^.Next;
     LibraryLights^.ID:='';
     LibraryLights^.Name:='';
     FreeMem(LibraryLights);
     LibraryLights:=Next;
    end;
    LibraryLightsIDStringHashMap.Free;
   end;
   begin
    while assigned(LibraryGeometries) do begin
     Next:=LibraryGeometries^.Next;
     LibraryGeometries^.ID:='';
     SetLength(LibraryGeometries^.Meshs,0);
     Finalize(LibraryGeometries^);
     FreeMem(LibraryGeometries);
     LibraryGeometries:=Next;
    end;
    LibraryGeometriesIDStringHashMap.Free;
   end;
   begin
    while assigned(LibraryVerticeses) do begin
     Next:=LibraryVerticeses^.Next;
     LibraryVerticeses^.ID:='';
     SetLength(LibraryVerticeses^.Inputs,0);
     FreeMem(LibraryVerticeses);
     LibraryVerticeses:=Next;
    end;
    LibraryVerticesesIDStringHashMap.Free;
   end;
   begin
    while assigned(LibrarySources) do begin
     Next:=LibrarySources^.Next;
     LibrarySources^.ID:='';
     FreeAndNil(LibrarySources^.SourceDatas);
     LibrarySources^.Accessor.Source:='';
     SetLength(LibrarySources^.Accessor.Params,0);
     FreeMem(LibrarySources);
     LibrarySources:=Next;
    end;
    LibrarySourcesIDStringHashMap.Free;
   end;
   begin
    while assigned(LibrarySourceDatas) do begin
     Next:=LibrarySourceDatas^.Next;
     LibrarySourceDatas^.ID:='';
     SetLength(LibrarySourceDatas^.Data,0);
     SetLength(LibrarySourceDatas^.Strings,0);
     FreeMem(LibrarySourceDatas);
     LibrarySourceDatas:=Next;
    end;
    LibrarySourceDatasIDStringHashMap.Free;
   end;
   begin
    while assigned(LibraryEffects) do begin
     Next:=LibraryEffects^.Next;
     LibraryEffects^.ID:='';
     LibraryEffects^.Name:='';
     while assigned(LibraryEffects^.Surfaces) do begin
      SubNext:=LibraryEffects^.Surfaces^.Next;
      LibraryEffects^.Surfaces^.SID:='';
      LibraryEffects^.Surfaces^.InitFrom:='';
      LibraryEffects^.Surfaces^.Format:='';
      FreeMem(LibraryEffects^.Surfaces);
      LibraryEffects^.Surfaces:=SubNext;
     end;
     while assigned(LibraryEffects^.Sampler2D) do begin
      SubNext:=LibraryEffects^.Sampler2D^.Next;
      LibraryEffects^.Sampler2D^.SID:='';
      LibraryEffects^.Sampler2D^.Source:='';
      LibraryEffects^.Sampler2D^.WrapS:='';
      LibraryEffects^.Sampler2D^.WrapT:='';
      LibraryEffects^.Sampler2D^.MinFilter:='';
      LibraryEffects^.Sampler2D^.MagFilter:='';
      LibraryEffects^.Sampler2D^.MipFilter:='';
      Finalize(LibraryEffects^);
      FreeMem(LibraryEffects^.Sampler2D);
      LibraryEffects^.Sampler2D:=SubNext;
     end;
     while assigned(LibraryEffects^.Floats) do begin
      SubNext:=LibraryEffects^.Floats^.Next;
      LibraryEffects^.Floats^.SID:='';
      FreeMem(LibraryEffects^.Floats);
      LibraryEffects^.Floats:=SubNext;
     end;
     while assigned(LibraryEffects^.Float4s) do begin
      SubNext:=LibraryEffects^.Float4s^.Next;
      LibraryEffects^.Float4s^.SID:='';
      FreeMem(LibraryEffects^.Float4s);
      LibraryEffects^.Float4s:=SubNext;
     end;
     FreeAndNil(LibraryEffects^.Images);
     FreeMem(LibraryEffects);
     LibraryEffects:=Next;
    end;
    LibraryEffectsIDStringHashMap.Free;
   end;
   begin
    while assigned(LibraryMaterials) do begin
     Next:=LibraryMaterials^.Next;
     LibraryMaterials^.ID:='';
     LibraryMaterials^.Name:='';
     LibraryMaterials^.EffectURL:='';
     FreeMem(LibraryMaterials);
     LibraryMaterials:=Next;
    end;
    LibraryMaterialsIDStringHashMap.Free;
   end;
   begin
    while assigned(LibraryImages) do begin
     Next:=LibraryImages^.Next;
     LibraryImages^.ID:='';
     LibraryImages^.InitFrom:='';
     FreeMem(LibraryImages);
     LibraryImages:=Next;
    end;
    LibraryImagesIDStringHashMap.Free;
   end;
   IDStringHashMap.Free;
  end;
 finally
  XML.Free;
 end;
end;

function TDAELoader.ExportAsOBJ(FileName:ansistring):boolean;
var i,j,k,VertexIndex:longint;
    sl:TStringList;
    Geometry:TDAEGeometry;
    Mesh:TDAEMesh;
begin
 result:=false;
 if Geometries.Count>0 then begin
  sl:=TStringList.Create;
  try
   VertexIndex:=1;
   for i:=0 to Geometries.Count-1 do begin
    Geometry:=Geometries[i];
    for j:=0 to Geometry.Count-1 do begin
     Mesh:=Geometry[j];
     if Mesh.MeshType=dlmtTRIANGLES then begin
      if j=0 then begin
       sl.Add('o '+Geometry.Name);
      end;
      for k:=0 to length(Mesh.Vertices)-1 do begin
       sl.Add('v '+DoubleToStr(Mesh.Vertices[k].Position.x)+' '+DoubleToStr(Mesh.Vertices[k].Position.y)+' '+DoubleToStr(Mesh.Vertices[k].Position.z));
      end;
      for k:=0 to length(Mesh.Vertices)-1 do begin
       sl.Add('vn '+DoubleToStr(Mesh.Vertices[k].Normal.x)+' '+DoubleToStr(Mesh.Vertices[k].Normal.y)+' '+DoubleToStr(Mesh.Vertices[k].Normal.z));
      end;
      for k:=0 to length(Mesh.Vertices)-1 do begin
       sl.Add('vt '+DoubleToStr(Mesh.Vertices[k].TexCoords[0].x)+' '+DoubleToStr(Mesh.Vertices[k].TexCoords[0].y));
      end;
      k:=0;
      while (k+2)<length(Mesh.Indices) do begin
       sl.Add('f '+IntToStr(VertexIndex+Mesh.Indices[k])+'/'+IntToStr(VertexIndex+Mesh.Indices[k])+'/'+IntToStr(VertexIndex+Mesh.Indices[k])+' '+IntToStr(VertexIndex+Mesh.Indices[k+1])+'/'+IntToStr(VertexIndex+Mesh.Indices[k+1])+'/'+IntToStr(VertexIndex+Mesh.Indices[k+1])+' '+IntToStr(VertexIndex+Mesh.Indices[k+2])+'/'+IntToStr(VertexIndex+Mesh.Indices[k+2])+'/'+IntToStr(VertexIndex+Mesh.Indices[k+2]));
       inc(k,3);
      end;
      inc(VertexIndex,length(Mesh.Vertices));
     end;
    end;
   end;
   sl.SaveToFile(FileName);
   result:=true;
  finally
   sl.Free;
  end;
 end;
end;

end.















