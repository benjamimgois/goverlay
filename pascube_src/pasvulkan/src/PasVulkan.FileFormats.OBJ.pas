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
unit PasVulkan.FileFormats.OBJ; // Based on decades older code from me, so the code is a bit messy, but it works still for its purpose.
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

uses SysUtils,Classes,Math,PasJSON,PasVulkan.Types,PasVulkan.Math,PasVulkan.Collections,
     PasGLTF,PasDblStrUtils;

type EpvOBJModel=class(Exception);
     
     PpvOBJColor=^TpvOBJColor;
     TpvOBJColor=TpvVector3;

     PpvOBJVector3=^TpvOBJVector3;
     TpvOBJVector3=TpvVector3;

     PpvOBJVector4=^TpvOBJVector4;
     TpvOBJVector4=TpvVector4;

     PpvOBJTexCoord=^TpvOBJTexCoord;
     TpvOBJTexCoord=TpvVector2;

     PpvOBJTriangleVertex=^TpvOBJTriangleVertex;
     TpvOBJTriangleVertex=record
      Vertex:TpvOBJVector3;
      Normal:TpvOBJVector3;
      Tangent:TpvOBJVector3;
      Bitangent:TpvOBJVector3;
      TexCoord:TpvOBJTexCoord;
      VertexIndex:TpvSizeInt;
      NormalIndex:TpvSizeInt;
      TangentIndex:TpvSizeInt;
      BitangentIndex:TpvSizeInt;
      TexCoordIndex:TpvSizeInt;
     end;

     PpvOBJTriangleVertexForHashing=^TpvOBJTriangleVertexForHashing;
     TpvOBJTriangleVertexForHashing=record
      Vertex:TpvOBJVector3;
      Normal:TpvOBJVector3;
      Tangent:TpvOBJVector3;
      Bitangent:TpvOBJVector3;
      TexCoord:TpvOBJTexCoord;
     end;

     PpvOBJMaterial=^TpvOBJMaterial;
     TpvOBJMaterial=record
      Name:TpvRawByteString;
      Ambient:TpvOBJColor;
      Diffuse:TpvOBJColor;
      Specular:TpvOBJColor;
      Emissive:TpvOBJColor;
      Shininess:TpvFloat;
      Metallic:TpvFloat;
      Roughness:TpvFloat;
      Sheen:TpvFloat;
      ClearcoatThickness:TpvFloat;
      ClearcoatRoughness:TpvFloat;
      Anisotropy:TpvFloat;
      AnisotropyRotation:TpvFloat;
      MetallicTextureFileName:TpvRawByteString;
      RoughnessTextureFileName:TpvRawByteString;
      SheenTextureFileName:TpvRawByteString;
      EmissiveTextureFileName:TpvRawByteString;
      NormalTextureFileName:TpvRawByteString;
      RoughnessMetallicAmbientOcclusionTextureFileName:TpvRawByteString;
      OcclusionRoughnessMetallicTextureFileName:TpvRawByteString;
      TextureFileName:TpvRawByteString;
      PBR:longbool;
     end;

     TpvOBJIndices=array of TpvInt32;

     PpvOBJFace=^TpvOBJFace;
     TpvOBJFace=record
      Count:TpvSizeInt;
      VertexIndices:TpvOBJIndices;
      TexCoordIndices:TpvOBJIndices;
      NormalIndices:TpvOBJIndices;
      TangentIndices:TpvOBJIndices;
      BitangentIndices:TpvOBJIndices;
      FaceNormal:TpvOBJVector3;
     end;

     PpvOBJLine=^TpvOBJLine;
     TpvOBJLine=record
      Count:TpvSizeInt;
      VertexIndices:TpvOBJIndices;
     end;

     TpvOBJEdgeTriangle=record
      v,n,t:array[0..2] of TpvOBJVector3;
      uv:array[0..2] of TpvOBJTexCoord;
     end;

     TpvOBJEdgeTriangleVertices=array of TpvOBJEdgeTriangle;

     TpvOBJEdgeLine=record
      p1,p2,p3:TpvSizeInt;
     end;

     TpvOBJEdgeLines=array of TpvOBJEdgeLine;

     PpvOBJPart=^TpvOBJPart;
     TpvOBJPart=record
      Indices:array of TpvUInt32;
      Faces:array of TpvOBJFace;
      Lines:array of TpvOBJLine;
      CountIndices:TpvSizeInt;
      CountFaces:TpvSizeInt;
      CountLines:TpvSizeInt;
      MaterialIndex:TpvSizeInt;
     end;

     PpvOBJObject=^TpvOBJObject; 
     TpvOBJObject=record
      Name:TpvRawByteString;
      Draw:longbool;
      Parts:array of TpvOBJPart;
      CountParts:TpvSizeInt;
     end;

     PpvOBJGroup=^TpvOBJGroup;
     TpvOBJGroup=record
      Name:TpvRawByteString;
      Draw:longbool;
      Objects:array of TpvOBJObject;
      CountObjects:TpvSizeInt;
     end;

     TpvOBJModel=class
      private
       function GetToken(var InputString:TpvRawByteString;const Divider:ansichar):TpvRawByteString;
       procedure Clear;
       function ParseXYZ(s:TpvRawByteString):TpvOBJVector3;
       function ParseUV(s:TpvRawByteString):TpvOBJTexCoord;
       procedure ParseVertices(s:TpvRawByteString);
       procedure ParseFaces(v:TpvRawByteString);
       procedure ParseLines(v:TpvRawByteString);
       procedure GetMaterialName(s:TpvRawByteString);
       procedure CreateMaterial(s:TpvRawByteString);
       procedure ParseMaterial(s:TpvRawByteString);
       procedure ParsePBRMaterial(s:TpvRawByteString);
       procedure ParseShininess(s:TpvRawByteString);
       procedure ParseTexture(s:TpvRawByteString);
       function LoadMaterials(s:TpvRawByteString):boolean;
       procedure FixUpVerticesNormals;
       procedure FixUpParts;
      public
       MaterialIndex,VertexCount,NormalCount,TangentCount,BitangentCount,TexCoordCount,
       GroupCount,MaterialCount,CurrentGroup:TpvSizeInt;
       Name,Path,MaterialFile:TpvRawByteString;
       Vertices:array of TpvOBJVector3;
       Normals:array of TpvOBJVector3;
       Tangents:array of TpvOBJVector3;
       Bitangents:array of TpvOBJVector3;
       TexCoords:array of TpvOBJTexCoord;
       Groups:array of TpvOBJGroup;
       Materials:array of TpvOBJMaterial;
       TriangleVertices:array of TpvOBJTriangleVertex;
       CountTriangleVertices:TpvSizeInt;
       Scale:TpvFloat;
       ScaleToOne:boolean;
       EdgeTriangleVertices:TpvOBJEdgeTriangleVertices;
       CalculateNormals:boolean;
       constructor Create;
       destructor Destroy; override;
       function LoadFromStream(Stream:TStream;const FileName:TpvRawByteString=''):boolean;
       function LoadModel(FileName:TpvRawByteString):boolean;
     end;

implementation

uses PasVulkan.Application;

const MemoryThreshold=16;

      HashSize=65536;
      HashMask=65535;

      EPSILON=1e-8;

procedure FillStreamWithFile(Stream:TMemoryStream;const FileName:TpvRawByteString);
var TemporaryStream:TStream;
begin
 if FileExists(FileName) then begin
  Stream.LoadFromFile(FileName);
 end else if assigned(pvApplication) and pvApplication.Assets.ExistAsset(FileName) then begin
  Stream.Clear;
  TemporaryStream:=pvApplication.Assets.GetAssetStream(FileName);
  try
   Stream.CopyFrom(TemporaryStream,0);
  finally
   TemporaryStream.Free;
  end;
 end else begin
  Stream.Clear;
  //raise EpvOBJModel.Create('File not found "'+FileName+'"');
 end; 
end; 

function NextPowerOfTwo(i,MinThreshold:TpvInt32):TpvInt32;
begin
 result:=(i or MinThreshold)-1;
 result:=result or (result shr 1);
 result:=result or (result shr 2);
 result:=result or (result shr 4);
 result:=result or (result shr 8);
 result:=result or (result shr 16);
 inc(result);
end;

function CompareBytes(a,b:pointer;Count:TpvInt32):boolean;
var pa,pb:pansichar;
begin
 pa:=a;
 pb:=b;
 result:=true;
 while Count>7 do begin
  if TpvUInt64(pointer(pa)^)<>TpvUInt64(pointer(pb)^) then begin
   result:=false;
   exit;
  end;
  inc(pa,8);
  inc(pb,8);
  dec(Count,8);
 end;
 while Count>3 do begin
  if TpvUInt32(pointer(pa)^)<>TpvUInt32(pointer(pb)^) then begin
   result:=false;
   exit;
  end;
  inc(pa,4);
  inc(pb,4);
  dec(Count,4);
 end;
 while Count>1 do begin
  if TpvUInt16(pointer(pa)^)<>TpvUInt16(pointer(pb)^) then begin
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

function HashBytes(const a:pointer;Count:TpvInt32):TpvUInt32;
{$ifdef cpuarm}
var b:pansichar;
    len,h,i:TpvUInt32;
begin
 result:=2166136261;
 len:=Count;
 h:=len;
 if len>0 then begin
  b:=a;
  while len>3 do begin
   i:=TpvUInt32(pointer(b)^);
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
   i:=TpvUInt16(pointer(b)^);
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
const m=TpvUInt32($57559429);
      n=TpvUInt32($5052acdb);
var b:pansichar;
    h,k,len:TpvUInt32;
    p:TpvUInt64;
begin
 len:=Count;
 h:=len;
 k:=h+n+1;
 if len>0 then begin
  b:=a;
  while len>7 do begin
   begin
    p:=TpvUInt32(pointer(b)^)*TpvUInt64(n);
    h:=h xor TpvUInt32(p and $ffffffff);
    k:=k xor TpvUInt32(p shr 32);
    inc(b,4);
   end;
   begin
    p:=TpvUInt32(pointer(b)^)*TpvUInt64(m);
    k:=k xor TpvUInt32(p and $ffffffff);
    h:=h xor TpvUInt32(p shr 32);
    inc(b,4);
   end;
   dec(len,8);
  end;
  if len>3 then begin
   p:=TpvUInt32(pointer(b)^)*TpvUInt64(n);
   h:=h xor TpvUInt32(p and $ffffffff);
   k:=k xor TpvUInt32(p shr 32);
   inc(b,4);
   dec(len,4);
  end;
  if len>0 then begin
   if len>1 then begin
    p:=TpvUInt16(pointer(b)^);
    inc(b,2);
    dec(len,2);
   end else begin
    p:=0;
   end;
   if len>0 then begin
    p:=p or (byte(b^) shl 16);
   end;
   p:=p*TpvUInt64(m);
   k:=k xor TpvUInt32(p and $ffffffff);
   h:=h xor TpvUInt32(p shr 32);
  end;
 end;
 begin
  p:=(h xor (k+n))*TpvUInt64(n);
  h:=h xor TpvUInt32(p and $ffffffff);
  k:=k xor TpvUInt32(p shr 32);
 end;
 result:=k xor h;
 if result=0 then begin
  result:=$ffffffff;
 end;
end;
{$endif}

function StrToFloat(s:TpvRawByteString):double;
begin
 result:=ConvertStringToDouble(s,rmNearest);
end;

function FloatToStr(v:double):TpvRawByteString;
begin
 result:=ConvertDoubleToString(v,omSTANDARD,-1);
end;

function ReadLine(Stream:TStream):TpvRawByteString;
var c:ansichar;
    l:TpvSizeInt;
begin
 result:='';
 l:=0;
 while Stream.Position<Stream.Size do begin
  Stream.Read(c,sizeof(ansichar));
  case c of
   #10:begin
    if Stream.Position<Stream.Size then begin
     Stream.Read(c,sizeof(ansichar));
     if c<>#13 then begin
      Stream.Seek(-sizeof(ansichar),soFromCurrent);
     end;
    end;
    break;
   end;
   #13:begin
    if Stream.Position<Stream.Size then begin
     Stream.Read(c,sizeof(ansichar));
     if c<>#10 then begin
      Stream.Seek(-sizeof(ansichar),soFromCurrent);
     end;
    end;
    break;
   end;
   else begin
    inc(l);
    if l>=length(result) then begin
     SetLength(result,NextPowerOfTwo(l+1,16));
    end;
    result[l]:=c;
   end;
  end;
 end;
 SetLength(result,l);
end;

function TexCoordAdd(V1,V2:TpvOBJTexCoord):TpvOBJTexCoord;
begin
 result.u:=V1.u+V2.u;
 result.v:=V1.v+V2.v;
end;

function TexCoordDiv(V1:TpvOBJTexCoord;D:TpvFloat):TpvOBJTexCoord;
begin
 result.u:=V1.u/D;
 result.v:=V1.v/D;
end;

function TexCoordMul(V1:TpvOBJTexCoord;f:TpvFloat):TpvOBJTexCoord;
begin
 result.u:=V1.u*f;
 result.v:=V1.v*f;
end;

function TexCoordLength(v:TpvOBJTexCoord):TpvFloat;
begin
 result:=sqrt(sqr(v.u)+sqr(v.v));
end;

function TexCoordNorm(v:TpvOBJTexCoord):TpvOBJTexCoord;
var l:TpvFloat;
begin
 l:=TexCoordLength(v);
 if l=0 then begin
  l:=1;
 end;
 l:=1/l;
 result.u:=v.u*l;
 result.v:=v.v*l;
end;

function VectorAdd(V1,V2:TpvOBJVector3):TpvOBJVector3;
begin
 result.x:=V1.x+V2.x;
 result.y:=V1.y+V2.y;
 result.z:=V1.z+V2.z;
end;

function VectorSub(V1,V2:TpvOBJVector3):TpvOBJVector3;
begin
 result.x:=V1.x-V2.x;
 result.y:=V1.y-V2.y;
 result.z:=V1.z-V2.z;
end;

function VectorDiv(V1:TpvOBJVector3;D:TpvFloat):TpvOBJVector3;
begin
 result.x:=V1.x/D;
 result.y:=V1.y/D;
 result.z:=V1.z/D;
end;

function VectorMul(V1:TpvOBJVector3;f:TpvFloat):TpvOBJVector3;
begin
 result.x:=V1.x*f;
 result.y:=V1.y*f;
 result.z:=V1.z*f;
end;

function VectorCrossProduct(V1,V2:TpvOBJVector3):TpvOBJVector3;
var Temp:TpvOBJVector3;
begin
 Temp.x:=V1.y*V2.z-V1.z*V2.y;
 Temp.y:=V1.z*V2.x-V1.x*V2.z;
 Temp.z:=V1.x*V2.y-V1.y*V2.x;
 result:=Temp;
end;

function VectorDot(V1,V2:TpvOBJVector3):TpvFloat;
begin
 result:=(v1.x*v2.x)+(v1.y*v2.y)+(v1.z*v2.z);
end;

function VectorLength(v:TpvOBJVector3):TpvFloat;
begin
 result:=sqrt(sqr(v.x)+sqr(v.y)+sqr(v.z));
end;

function VectorNorm(v:TpvOBJVector3):TpvOBJVector3;
var l:TpvFloat;
begin
 l:=VectorLength(v);
 if l=0 then begin
  l:=1;
 end;
 l:=1/l;
 result.x:=v.x*l;
 result.y:=v.y*l;
 result.z:=v.z*l;
end;

function GetFaceNormal(V1,V2,V3:TpvOBJVector3):TpvOBJVector3;
begin
 result:=VectorNorm(VectorCrossProduct(VectorSub(V1,V2),VectorSub(V3,V2)));
end;

constructor TpvOBJModel.Create;
begin
 inherited Create;
 ScaleToOne:=false;
 CalculateNormals:=false;
 Clear;
end;

destructor TpvOBJModel.Destroy;
begin
 Clear;
 inherited Destroy;
end;

function TpvOBJModel.GetToken(var InputString:TpvRawByteString;const Divider:ansichar):TpvRawByteString;
var i:TpvSizeInt;
begin
 i:=1;
 while (i<=length(InputString)) and not (InputString[i]=Divider) do begin
  inc(i);
 end;
 result:=Copy(InputString,1,i-1);
 Delete(InputString,1,i);
end;

procedure TpvOBJModel.Clear;
begin
 Name:='';
 Path:='';
 MaterialFile:='';
 SetLength(Vertices,0);
 SetLength(Normals,0);
 SetLength(Tangents,0);
 SetLength(Bitangents,0);
 SetLength(TexCoords,0);
 SetLength(Groups,0);
 SetLength(Materials,0);
 VertexCount:=0;
 NormalCount:=0;
 TangentCount:=0;
 BitangentCount:=0;
 TexCoordCount:=0;
 GroupCount:=0;
 MaterialCount:=0;
end;

function TpvOBJModel.ParseXYZ(s:TpvRawByteString):TpvOBJVector3;
var c:TpvOBJVector3;
begin
 s:=Trim(Copy(s,3,length(s)));
 c.x:=StrToFloat(GetToken(s,' '));
 c.y:=StrToFloat(GetToken(s,' '));
 c.z:=StrToFloat(GetToken(s,' '));
 result:=c;
end;

function TpvOBJModel.ParseUV(s:TpvRawByteString):TpvOBJTexCoord;
var t:TpvOBJTexCoord;
begin
 s:=Trim(Copy(s,3,length(s)));
 t.u:=StrToFloat(GetToken(s,' '));
 t.v:=StrToFloat(GetToken(s,' '));
 result:=t;
end;

procedure TpvOBJModel.ParseVertices(s:TpvRawByteString);
var c:TpvOBJVector3;
    t:TpvOBJTexCoord;
begin
 if length(s)>1 then begin
  case upcase(s[2]) of
   ' ':begin
    c:=ParseXYZ(s);
    if VertexCount>=length(Vertices) then begin
     SetLength(Vertices,NextPowerOfTwo(VertexCount+1,MemoryThreshold));
    end;
    Vertices[VertexCount]:=c;
    inc(VertexCount);
   end;
   'N':begin
    c:=ParseXYZ(s);
    if NormalCount>=length(Normals) then begin
     SetLength(Normals,NextPowerOfTwo(NormalCount+1,MemoryThreshold));
    end;
    Normals[NormalCount]:=c;
    inc(NormalCount);
   end;
   'T':begin
    t:=ParseUV(s);
    if TexCoordCount>=length(TexCoords) then begin
     SetLength(TexCoords,NextPowerOfTwo(TexCoordCount+1,MemoryThreshold));
    end;
    TexCoords[TexCoordCount]:=t;
    inc(TexCoordCount);
   end;
  end;
 end;
end;

procedure TpvOBJModel.ParseFaces(v:TpvRawByteString);
var Counter,GroupIndex,ObjectIndex,PartIndex,FaceIndex,SecondFaceIndex,ForMaterialIndex,p:TpvSizeInt;
    f:TpvOBJFace;
    s,a,l:TpvRawByteString;
begin
 p:=pos(' ',v);
 s:=Trim(Copy(v,p+1,length(v)));

 GroupIndex:=CurrentGroup;
 if GroupIndex>=length(Groups) then begin
  SetLength(Groups,NextPowerOfTwo(GroupIndex+1,MemoryThreshold));
  inc(CurrentGroup);
 end;
 if Groups[GroupIndex].CountObjects=0 then begin
  Groups[GroupIndex].CountObjects:=1;
  SetLength(Groups[GroupIndex].Objects,NextPowerOfTwo(Groups[GroupIndex].CountObjects+1,MemoryThreshold));
  ObjectIndex:=Groups[GroupIndex].CountObjects-1;
  Groups[GroupIndex].Objects[ObjectIndex].Name:='';
  Groups[GroupIndex].Objects[ObjectIndex].Draw:=true;
  Groups[GroupIndex].Objects[ObjectIndex].Parts:=nil;
  Groups[GroupIndex].Objects[ObjectIndex].CountParts:=0;
 end;
 ObjectIndex:=Groups[GroupIndex].CountObjects-1;
 if Groups[GroupIndex].Objects[ObjectIndex].CountParts=0 then begin
  Groups[GroupIndex].Objects[ObjectIndex].CountParts:=1;
  SetLength(Groups[GroupIndex].Objects[ObjectIndex].Parts,NextPowerOfTwo(Groups[GroupIndex].Objects[ObjectIndex].CountParts+1,MemoryThreshold));
  PartIndex:=Groups[GroupIndex].Objects[ObjectIndex].CountParts-1;
  Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].CountFaces:=0;
  Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].CountLines:=0;
  Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].MaterialIndex:=0;
 end;
 PartIndex:=Groups[GroupIndex].Objects[ObjectIndex].CountParts-1;
 if Groups[GroupIndex].Objects[ObjectIndex].CountParts>=length(Groups[GroupIndex].Objects[ObjectIndex].Parts) then begin
  SetLength(Groups[GroupIndex].Objects[ObjectIndex].Parts,NextPowerOfTwo(Groups[GroupIndex].Objects[ObjectIndex].CountParts+1,MemoryThreshold));
 end;
 if Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].CountFaces>=length(Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].Faces) then begin
  SetLength(Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].Faces,NextPowerOfTwo(Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].CountFaces+1,MemoryThreshold));
 end;
 FaceIndex:=Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].CountFaces;
 inc(Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].CountFaces);

 SetLength(f.VertexIndices,0);
 SetLength(f.TexCoordIndices,0);
 SetLength(f.NormalIndices,0);
 SetLength(f.TangentIndices,0);
 SetLength(f.BitangentIndices,0);

 f.Count:=0;
 while length(s)>0 do begin
  a:=GetToken(s,' ');

  if length(a)>0 then begin
   inc(f.Count);

   l:=GetToken(a,'/');
   SetLength(f.VertexIndices,f.Count);
   f.VertexIndices[f.Count-1]:=StrToInt(l)-1;

   l:=GetToken(a,'/');
   if length(l)>0 then begin
    SetLength(f.TexCoordIndices,f.Count);
    f.TexCoordIndices[f.Count-1]:=StrToInt(l)-1;
   end;

   l:=GetToken(a,'/');
   if length(l)>0 then begin
    SetLength(f.NormalIndices,f.Count);
    f.NormalIndices[f.Count-1]:=StrToInt(l)-1;
   end;
  end;
 end;

 // Copy face & rotate indices
 Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].Faces[FaceIndex].Count:=f.Count;
 Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].Faces[FaceIndex].FaceNormal:=f.FaceNormal;
 SetLength(Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].Faces[FaceIndex].VertexIndices,length(f.VertexIndices));
 SetLength(Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].Faces[FaceIndex].TexCoordIndices,length(f.TexCoordIndices));
 SetLength(Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].Faces[FaceIndex].NormalIndices,length(f.NormalIndices));
 for Counter:=0 to f.Count-1 do begin
  Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].Faces[FaceIndex].VertexIndices[Counter]:=f.VertexIndices[f.Count-(Counter+1)];
  if length(Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].Faces[FaceIndex].TexCoordIndices)=f.Count then begin
   Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].Faces[FaceIndex].TexCoordIndices[Counter]:=f.TexCoordIndices[f.Count-(Counter+1)];
  end;
  if length(Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].Faces[FaceIndex].NormalIndices)=f.Count then begin
   Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].Faces[FaceIndex].NormalIndices[Counter]:=f.NormalIndices[f.Count-(Counter+1)];
  end;
 end;

 // Split quads into triangles
 if Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].Faces[FaceIndex].Count=4 then begin
  if Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].CountFaces>=length(Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].Faces) then begin
   SetLength(Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].Faces,NextPowerOfTwo(Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].CountFaces+1,MemoryThreshold));
  end;
  SecondFaceIndex:=Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].CountFaces;
  inc(Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].CountFaces);
  Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].Faces[SecondFaceIndex].Count:=3;
  SetLength(Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].Faces[SecondFaceIndex].VertexIndices,3);
  if length(Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].Faces[FaceIndex].TexCoordIndices)=4 then begin
   SetLength(Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].Faces[SecondFaceIndex].TexCoordIndices,3);
  end else begin
   SetLength(Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].Faces[SecondFaceIndex].TexCoordIndices,0);
  end;
  if length(Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].Faces[FaceIndex].NormalIndices)=4 then begin
   SetLength(Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].Faces[SecondFaceIndex].NormalIndices,3);
  end else begin
   SetLength(Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].Faces[SecondFaceIndex].NormalIndices,0);
  end;
  for Counter:=0 to 2 do begin
   ForMaterialIndex:=(Counter+2) mod 4;
   Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].Faces[SecondFaceIndex].VertexIndices[Counter]:=Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].Faces[FaceIndex].VertexIndices[ForMaterialIndex];
   if Counter<length(Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].Faces[FaceIndex].TexCoordIndices) then begin
    Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].Faces[SecondFaceIndex].TexCoordIndices[Counter]:=Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].Faces[FaceIndex].TexCoordIndices[ForMaterialIndex];
   end;
   if Counter<length(Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].Faces[FaceIndex].NormalIndices) then begin
    Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].Faces[SecondFaceIndex].NormalIndices[Counter]:=Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].Faces[FaceIndex].NormalIndices[ForMaterialIndex];
   end;
  end;
  Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].Faces[FaceIndex].Count:=3;
  SetLength(Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].Faces[FaceIndex].VertexIndices,3);
  if length(Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].Faces[FaceIndex].TexCoordIndices)=4 then begin
   SetLength(Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].Faces[FaceIndex].TexCoordIndices,3);
  end;
  if length(Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].Faces[FaceIndex].NormalIndices)=4 then begin
   SetLength(Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].Faces[FaceIndex].NormalIndices,3);
  end;
 end;
end;

procedure TpvOBJModel.ParseLines(v:TpvRawByteString);
var Counter,GroupIndex,ObjectIndex,PartIndex,LineIndex,SecondFaceIndex,ForMaterialIndex,p:TpvSizeInt;
    l:TpvOBJLine;
    s,a,b:TpvRawByteString;
begin
 p:=pos(' ',v);
 s:=Trim(Copy(v,p+1,length(v)));

 GroupIndex:=CurrentGroup;
 if GroupIndex>=length(Groups) then begin
  SetLength(Groups,NextPowerOfTwo(GroupIndex+1,MemoryThreshold));
  inc(CurrentGroup);
 end;
 if Groups[GroupIndex].CountObjects=0 then begin
  Groups[GroupIndex].CountObjects:=1;
  SetLength(Groups[GroupIndex].Objects,NextPowerOfTwo(Groups[GroupIndex].CountObjects+1,MemoryThreshold));
  ObjectIndex:=Groups[GroupIndex].CountObjects-1;
  Groups[GroupIndex].Objects[ObjectIndex].Name:='';
  Groups[GroupIndex].Objects[ObjectIndex].Draw:=true;
  Groups[GroupIndex].Objects[ObjectIndex].Parts:=nil;
  Groups[GroupIndex].Objects[ObjectIndex].CountParts:=0;
 end;
 ObjectIndex:=Groups[GroupIndex].CountObjects-1;
 if Groups[GroupIndex].Objects[ObjectIndex].CountParts=0 then begin
  Groups[GroupIndex].Objects[ObjectIndex].CountParts:=1;
  SetLength(Groups[GroupIndex].Objects[ObjectIndex].Parts,NextPowerOfTwo(Groups[GroupIndex].Objects[ObjectIndex].CountParts+1,MemoryThreshold));
  PartIndex:=Groups[GroupIndex].Objects[ObjectIndex].CountParts-1;
  Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].CountFaces:=0;
  Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].CountLines:=0;
  Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].MaterialIndex:=0;
 end;
 PartIndex:=Groups[GroupIndex].Objects[ObjectIndex].CountParts-1;
 if Groups[GroupIndex].Objects[ObjectIndex].CountParts>=length(Groups[GroupIndex].Objects[ObjectIndex].Parts) then begin
  SetLength(Groups[GroupIndex].Objects[ObjectIndex].Parts,NextPowerOfTwo(Groups[GroupIndex].Objects[ObjectIndex].CountParts+1,MemoryThreshold));
 end;
 if Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].CountLines>=length(Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].Lines) then begin
  SetLength(Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].Lines,NextPowerOfTwo(Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].CountLines+1,MemoryThreshold));
 end;
 LineIndex:=Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].CountLines;
 inc(Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].CountLines);

 SetLength(l.VertexIndices,0);

 l.Count:=0;
 while length(s)>0 do begin
  a:=GetToken(s,' ');

  if length(a)>0 then begin
   inc(l.Count);

   if l.Count>length(l.VertexIndices) then begin
    SetLength(l.VertexIndices,l.Count*2);
   end;

   l.VertexIndices[l.Count-1]:=StrToInt(a)-1;

  end;
 end;

 // Copy line
 Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].Lines[LineIndex].Count:=l.Count;
 SetLength(Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].Lines[LineIndex].VertexIndices,length(l.VertexIndices));
 for Counter:=0 to l.Count-1 do begin
  Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].Lines[LineIndex].VertexIndices[Counter]:=l.VertexIndices[Counter];
 end;

end;

procedure TpvOBJModel.GetMaterialName(s:TpvRawByteString);
var GroupIndex,ObjectIndex,PartIndex,OldMaterialIndex,Counter:TpvSizeInt;
begin
 OldMaterialIndex:=MaterialIndex;
 GroupIndex:=CurrentGroup;
 s:=Trim(s);
 if Copy(s,1,6)<>'USEMTL' then exit;
 Delete(s,1,pos(' ',s));
 for Counter:=0 to length(Materials)-1 do begin
  if Materials[Counter].Name=s then begin
   MaterialIndex:=Counter;
   break;
  end;
 end;
 if OldMaterialIndex<>MaterialIndex then begin
  ObjectIndex:=Groups[GroupIndex].CountObjects-1;
  inc(Groups[GroupIndex].Objects[ObjectIndex].CountParts);
  if Groups[GroupIndex].Objects[ObjectIndex].CountParts>=length(Groups[GroupIndex].Objects[ObjectIndex].Parts) then begin
   SetLength(Groups[GroupIndex].Objects[ObjectIndex].Parts,NextPowerOfTwo(Groups[GroupIndex].Objects[ObjectIndex].CountParts+1,MemoryThreshold));
  end;
  PartIndex:=Groups[GroupIndex].Objects[ObjectIndex].CountParts-1;
  SetLength(Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].Faces,0);
  Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].CountFaces:=0;
  SetLength(Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].Lines,0);
  Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].CountLines:=0;
  Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].MaterialIndex:=MaterialIndex;
 end;
end;

procedure TpvOBJModel.CreateMaterial(s:TpvRawByteString);
var Index:TpvSizeInt;
begin
 if Copy(uppercase(s),1,6)<>'NEWMTL' then begin
  exit;
 end;
 Index:=length(Materials);
 SetLength(Materials,Index+1);
 s:=Trim(Copy(s,7,length(s)));
 FillChar(Materials[Index].Ambient,sizeof(TpvOBJColor),#0);
 FillChar(Materials[Index].Diffuse,sizeof(TpvOBJColor),#0);
 FillChar(Materials[Index].Specular,sizeof(TpvOBJColor),#0);
 FillChar(Materials[Index].Emissive,sizeof(TpvOBJColor),#0);
 Materials[Index].Shininess:=60;
 Materials[Index].PBR:=false;
 Materials[Index].Metallic:=0.0;
 Materials[Index].Roughness:=0.5;
 Materials[Index].Sheen:=0.0;
 Materials[Index].ClearcoatThickness:=0.0;
 Materials[Index].ClearcoatRoughness:=0.0;
 Materials[Index].Anisotropy:=0.0;
 Materials[Index].AnisotropyRotation:=0.0;
 Materials[Index].MetallicTextureFileName:='';
 Materials[Index].RoughnessTextureFileName:='';
 Materials[Index].SheenTextureFileName:='';
 Materials[Index].EmissiveTextureFileName:='';
 Materials[Index].NormalTextureFileName:='';
 Materials[Index].RoughnessMetallicAmbientOcclusionTextureFileName:='';
 Materials[Index].OcclusionRoughnessMetallicTextureFileName:='';
 Materials[Index].TextureFileName:='';
 Materials[Index].Name:=s;
end;

procedure TpvOBJModel.ParseMaterial(s:TpvRawByteString);
var Index:TpvSizeInt;
    c:TpvOBJColor;
    AChar:ansichar;
begin
 AChar:=Upcase(s[2]);
 s:=Trim(Copy(s,3,length(s)));

 c.r:=StrToFloat(GetToken(s,' '));
 c.g:=StrToFloat(GetToken(s,' '));
 c.b:=StrToFloat(GetToken(s,' '));

 Index:=length(Materials);
 if Index>0 then begin
  dec(Index);
  case AChar of
   'A':begin
    Materials[Index].Ambient:=c;
   end;
   'D':begin
    Materials[Index].Diffuse:=c;
   end;
   'S':begin
    Materials[Index].Specular:=c;
   end;
   'E':begin
    Materials[Index].Emissive:=c;
    Materials[Index].PBR:=true;
   end;
  end;
 end;
end;

procedure TpvOBJModel.ParsePBRMaterial(s:TpvRawByteString);
var Index:TpvSizeInt;
    c:TpvFloat;
    AChar,AChar2:ansichar;
begin
 AChar:=Upcase(s[2]);
 if (AChar='C') and ((length(s)>3) and (Upcase(s[3])='R')) then begin
  Delete(s,3,1);
  AChar2:='R';
 end else begin
  AChar2:=#0;
 end;
 s:=Trim(Copy(s,3,length(s)));

 c:=StrToFloat(GetToken(s,' '));

 Index:=length(Materials);
 if Index>0 then begin
  dec(Index);
  case AChar of
   'M':begin
    Materials[Index].Metallic:=c;
    Materials[Index].PBR:=true;
   end;
   'R':begin
    Materials[Index].Roughness:=c;
    Materials[Index].PBR:=true;
   end;
   'S':begin
    Materials[Index].Sheen:=c;
    Materials[Index].PBR:=true;
   end;
   'C':begin
    if AChar2='R' then begin
     Materials[Index].ClearcoatRoughness:=c;
    end else begin
     Materials[Index].ClearcoatThickness:=c;
    end;
    Materials[Index].PBR:=true;
   end;
  end;
 end;
end;

procedure TpvOBJModel.ParseShininess(s:TpvRawByteString);
var Index:TpvSizeInt;
begin
 Index:=length(Materials);
 if Index>0 then begin
  Materials[Index-1].Shininess:=StrToFloat(Trim(Copy(s,3,length(s))));
 end;
end;

procedure TpvOBJModel.ParseTexture(s:TpvRawByteString);
var Index:TpvSizeInt;
    t:TpvRawByteString;
begin
 Index:=length(Materials);
 if Index>0 then begin
  t:=UpperCase(GetToken(s,' '));
  if t='MAP_PR' then begin
   // Roughness
   Materials[Index-1].RoughnessTextureFileName:=s;
  end else if t='MAP_PM' then begin
   // Metallic
   Materials[Index-1].MetallicTextureFileName:=s;
  end else if t='MAP_PS' then begin
   // Sheen
   Materials[Index-1].SheenTextureFileName:=s;
  end else if t='MAP_KE' then begin
   // Emissive
   Materials[Index-1].EmissiveTextureFileName:=s;
  end else if t='NORM' then begin
   // Normal map
   Materials[Index-1].NormalTextureFileName:=s;
  end else if t='MAP_RMA' then begin
   // Roughness, metalness, ambient occlusion
   Materials[Index-1].RoughnessMetallicAmbientOcclusionTextureFileName:=s;
  end else if t='MAP_ORM' then begin
   // Occlusion, Roughness, metalness
   Materials[Index-1].OcclusionRoughnessMetallicTextureFileName:=s;
  end else begin
   Materials[Index-1].TextureFileName:=S;
  end;
 end;
end;

function TpvOBJModel.LoadMaterials(s:TpvRawByteString):boolean;
var Stream:TMemoryStream;
begin
 result:=false;
 s:=Trim(s);
 if Copy(uppercase(s),1,6)<>'MTLLIB' then begin
  exit;
 end;
 Delete(s,1,pos(' ',s));
 MaterialFile:=Path+'/'+Trim(S);
 Stream:=TMemoryStream.Create;
 try
  FillStreamWithFile(Stream,MaterialFile);
  Stream.Seek(0,soFromBeginning);
  while Stream.Position<Stream.Size do begin
   s:=Trim(ReadLine(Stream));
   if (length(s)<>0) and (s[1]<>'#') then begin
    s[1]:=upcase(s[1]);
    case s[1] of
     'N':begin
      if length(s)>1 then begin
       s[2]:=upcase(s[2]);
       case s[2] of
        'S':begin
         ParseShininess(s);
        end;
        'E':begin
         CreateMaterial(s);
        end;
        'O':begin // norm
         ParseTexture(s);
        end;
       end;
      end;
     end;
     'K':begin
      ParseMaterial(s);
     end;
     'P':begin
      ParsePBRMaterial(s);
     end;
     'M':begin
      ParseTexture(s);
     end;
    end;
   end;
  end;
  result:=true;
 finally
  FreeAndNil(Stream);
 end;
end;

procedure TpvOBJModel.FixUpVerticesNormals;
const f1d3=1.0/3.0;
var Counter,GroupIndex,ObjectIndex,PartIndex,FaceIndex,VertexIndex,VertexCount:TpvSizeInt;
    Min,Max,Center,Size,Normal,Tangent,Bitangent:TpvOBJVector3;
    stv:array[0..1] of TpvOBJVector3;
    Scale,t1,t2,t3,t4,f:TpvFloat;
    VerticesCounts:array of TpvSizeInt;
    VerticesNormals,VerticesTangents,VerticesBitangents:array of TpvOBJVector3;
    DoCalculateNormals:boolean;
begin
 FillChar(Min,sizeof(TpvOBJVector3),#0);
 FillChar(Max,sizeof(TpvOBJVector3),#0);
 for Counter:=0 to length(Vertices)-1 do begin
  if Counter=0 then begin
   Min.x:=Vertices[Counter].x;
   Min.y:=Vertices[Counter].y;
   Min.z:=Vertices[Counter].z;
   Max.x:=Vertices[Counter].x;
   Max.y:=Vertices[Counter].y;
   Max.z:=Vertices[Counter].z;
  end;
  if Vertices[Counter].x<Min.x then begin
   Min.x:=Vertices[Counter].x;
  end else if Vertices[Counter].x>Max.x then begin
   Max.x:=Vertices[Counter].x;
  end;
  if Vertices[Counter].y<Min.y then begin
   Min.y:=Vertices[Counter].y;
  end else if Vertices[Counter].y>Max.y then begin
   Max.y:=Vertices[Counter].y;
  end;
  if Vertices[Counter].z<Min.z then begin
   Min.z:=Vertices[Counter].z;
  end else if Vertices[Counter].z>Max.z then begin
   Max.z:=Vertices[Counter].z;
  end;
 end;
 Size.x:=abs(Max.x-Min.x);
 Size.y:=abs(Max.y-Min.y);
 Size.z:=abs(Max.z-Min.z);
 if Size.x<Size.y then begin
  if Size.y<Size.z then begin
   Scale:=Size.z;
  end else begin
   Scale:=Size.y;
  end;
 end else begin
  if Size.x<Size.z then begin
   Scale:=Size.z;
  end else begin
   Scale:=Size.x;
  end;
 end;
//Scale:=sqrt(sqr(Size.x)+sqr(Size.y)+sqr(Size.z));
 if Scale<>0 then begin
  Scale:=1.0/Scale;
 end;
 Center.x:=(Min.x+Max.x)*0.5;
 Center.y:=(Min.y+Max.y)*0.5;
 Center.z:=(Min.z+Max.z)*0.5;
 if ScaleToOne then begin
  for Counter:=0 to length(Vertices)-1 do begin
   Vertices[Counter].x:=(Vertices[Counter].x-Center.x)*Scale;
   Vertices[Counter].y:=(Vertices[Counter].y-Center.y)*Scale;
   Vertices[Counter].z:=(Vertices[Counter].z-Center.z)*Scale;
  end;
 end;     
 DoCalculateNormals:=CalculateNormals or (length(Normals)=0);
 begin
  NormalCount:=length(Vertices);
  if DoCalculateNormals then begin
   SetLength(Normals,length(Vertices));
  end;
  SetLength(Tangents,length(Vertices));
  SetLength(Bitangents,length(Vertices));
  SetLength(VerticesCounts,length(Vertices));
  SetLength(VerticesNormals,length(Vertices));
  SetLength(VerticesTangents,length(Vertices));
  SetLength(VerticesBitangents,length(Vertices));
  for Counter:=0 to length(Vertices)-1 do begin
   VerticesCounts[Counter]:=0;
   FillChar(VerticesNormals[Counter],sizeof(TpvOBJVector3),#0);
   FillChar(VerticesTangents[Counter],sizeof(TpvOBJVector3),#0);
   FillChar(VerticesBitangents[Counter],sizeof(TpvOBJVector3),#0);
  end;
  for GroupIndex:=0 to length(Groups)-1 do begin
   for ObjectIndex:=0 to length(Groups[GroupIndex].Objects)-1 do begin
    for PartIndex:=0 to length(Groups[GroupIndex].Objects[ObjectIndex].Parts)-1 do begin
     for FaceIndex:=0 to length(Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].Faces)-1 do begin
      with Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].Faces[FaceIndex] do begin
       if DoCalculateNormals then begin
        SetLength(NormalIndices,length(VertexIndices));
       end;
       SetLength(TangentIndices,length(VertexIndices));
       SetLength(BitangentIndices,length(VertexIndices));
       if Count=3 then begin
        FaceNormal:=VectorNorm(VectorCrossProduct(VectorSub(Vertices[VertexIndices[2]],Vertices[VertexIndices[0]]),
                                                  VectorSub(Vertices[VertexIndices[1]],Vertices[VertexIndices[0]])));
        if not DoCalculateNormals then begin
         Normal.x:=(Normals[NormalIndices[0]].x+Normals[NormalIndices[1]].x+Normals[NormalIndices[2]].x)*f1d3;
         Normal.y:=(Normals[NormalIndices[0]].y+Normals[NormalIndices[1]].y+Normals[NormalIndices[2]].y)*f1d3;
         Normal.z:=(Normals[NormalIndices[0]].z+Normals[NormalIndices[1]].z+Normals[NormalIndices[2]].z)*f1d3;
         if ((FaceNormal.x*Normal.x)+(FaceNormal.y*Normal.y)+(FaceNormal.z*Normal.z))<0.0 then begin
          FaceNormal.x:=-FaceNormal.x;
          FaceNormal.y:=-FaceNormal.y;
          FaceNormal.z:=-FaceNormal.z;
         end;
        end;
        if (length(TexCoordIndices)=3) and
           (((TexCoordIndices[0]>=0) and (TexCoordIndices[0]<length(TexCoords))) and
            ((TexCoordIndices[1]>=0) and (TexCoordIndices[1]<length(TexCoords))) and
            ((TexCoordIndices[2]>=0) and (TexCoordIndices[2]<length(TexCoords)))) then begin
         t1:=TexCoords[TexCoordIndices[1]].v-TexCoords[TexCoordIndices[0]].v;
         t2:=TexCoords[TexCoordIndices[2]].v-TexCoords[TexCoordIndices[0]].v;
         t3:=TexCoords[TexCoordIndices[1]].u-TexCoords[TexCoordIndices[0]].u;
         t4:=TexCoords[TexCoordIndices[2]].u-TexCoords[TexCoordIndices[0]].u;
        end else begin
         t1:=0;
         t2:=0;
         t3:=0;
         t4:=0;
        end;
        stv[0].x:=(t1*(Vertices[VertexIndices[2]].x-Vertices[VertexIndices[0]].x))-(t2*(Vertices[VertexIndices[1]].x-Vertices[VertexIndices[0]].x));
        stv[0].y:=(t1*(Vertices[VertexIndices[2]].y-Vertices[VertexIndices[0]].y))-(t2*(Vertices[VertexIndices[1]].y-Vertices[VertexIndices[0]].y));
        stv[0].z:=(t1*(Vertices[VertexIndices[2]].z-Vertices[VertexIndices[0]].z))-(t2*(Vertices[VertexIndices[1]].z-Vertices[VertexIndices[0]].z));
        stv[1].x:=(t3*(Vertices[VertexIndices[2]].x-Vertices[VertexIndices[0]].x))-(t4*(Vertices[VertexIndices[1]].x-Vertices[VertexIndices[0]].x));
        stv[1].y:=(t3*(Vertices[VertexIndices[2]].y-Vertices[VertexIndices[0]].y))-(t4*(Vertices[VertexIndices[1]].y-Vertices[VertexIndices[0]].y));
        stv[1].z:=(t3*(Vertices[VertexIndices[2]].z-Vertices[VertexIndices[0]].z))-(t4*(Vertices[VertexIndices[1]].z-Vertices[VertexIndices[0]].z));
        stv[0]:=VectorNorm(VectorAdd(stv[0],VectorMul(FaceNormal,-VectorDot(stv[0],FaceNormal))));
        stv[1]:=VectorNorm(VectorAdd(stv[1],VectorMul(FaceNormal,-VectorDot(stv[1],FaceNormal))));
        if VectorDot(VectorCrossProduct(stv[1],stv[0]),FaceNormal)<0 then begin
         stv[0].x:=-stv[0].x;
         stv[0].y:=-stv[0].y;
         stv[0].z:=-stv[0].z;
         stv[1].x:=-stv[1].x;
         stv[1].y:=-stv[1].y;
         stv[1].z:=-stv[1].z;
        end;
        for VertexIndex:=0 to Count-1 do begin
         if DoCalculateNormals then begin
          NormalIndices[VertexIndex]:=VertexIndices[VertexIndex];
         end;
         TangentIndices[VertexIndex]:=VertexIndices[VertexIndex];
         BitangentIndices[VertexIndex]:=VertexIndices[VertexIndex];
         VerticesNormals[VertexIndices[VertexIndex]]:=VectorAdd(VerticesNormals[VertexIndices[VertexIndex]],FaceNormal);
         VerticesTangents[VertexIndices[VertexIndex]]:=VectorAdd(VerticesTangents[VertexIndices[VertexIndex]],stv[0]);
         VerticesBitangents[VertexIndices[VertexIndex]]:=VectorAdd(VerticesBitangents[VertexIndices[VertexIndex]],stv[1]);
         inc(VerticesCounts[VertexIndices[VertexIndex]]);
        end;
       end;
      end;
     end;
    end;
   end;
   for VertexIndex:=0 to length(Vertices)-1 do begin
    if VerticesCounts[VertexIndex]>0 then begin
     f:=1/VerticesCounts[VertexIndex];
     Normal:=VectorNorm(VectorMul(VerticesNormals[VertexIndex],f));
     if DoCalculateNormals then begin
      Normals[VertexIndex]:=Normal;
     end;
     Tangent:=VectorNorm(VectorMul(VerticesTangents[VertexIndex],f));
     Bitangent:=VectorNorm(VectorMul(VerticesBitangents[VertexIndex],f));
    end else begin
     Normal:=VectorNorm(VerticesNormals[VertexIndex]);
     if DoCalculateNormals then begin
      Normals[VertexIndex]:=Normal;
     end;
     Tangent:=VectorNorm(VerticesTangents[VertexIndex]);
     Bitangent:=VectorNorm(VerticesBitangents[VertexIndex]);
    end; 
    Tangents[VertexIndex].x:=Tangent.x;
    Tangents[VertexIndex].y:=Tangent.y;
    Tangents[VertexIndex].z:=Tangent.z;
    Bitangents[VertexIndex].x:=Bitangent.x;
    Bitangents[VertexIndex].y:=Bitangent.y;
    Bitangents[VertexIndex].z:=Bitangent.z;
   end;
  end;
  SetLength(VerticesCounts,0);
  SetLength(VerticesNormals,0);
  SetLength(VerticesTangents,0);
  SetLength(VerticesBitangents,0);
 end;
end;

procedure TpvOBJModel.FixUpParts;
var GroupIndex,ObjectIndex,PartIndex,FaceIndex,SrcIndex,DstIndex,TriangleVertexIndex:TpvSizeInt;
    TriangleVertex:TpvOBJTriangleVertex;
    Hash:TpvUInt32;
    TriangleHashNextIndices,TriangleHashBuckets:array of TpvSizeInt;
begin
 TriangleHashNextIndices:=nil;
 TriangleHashBuckets:=nil;
 TriangleVertices:=nil;
 try
  SetLength(TriangleHashBuckets,HashSize);
  for SrcIndex:=0 to HashMask do begin
   TriangleHashBuckets[SrcIndex]:=-1;
  end;
  CountTriangleVertices:=0;
  for GroupIndex:=0 to length(Groups)-1 do begin
   for ObjectIndex:=0 to length(Groups[GroupIndex].Objects)-1 do begin
    for PartIndex:=0 to length(Groups[GroupIndex].Objects[ObjectIndex].Parts)-1 do begin
     Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].Indices:=nil;
     Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].CountIndices:=0;
     for FaceIndex:=0 to length(Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].Faces)-1 do begin
      if Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].Faces[FaceIndex].Count=3 then begin
       for SrcIndex:=0 to Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].Faces[FaceIndex].Count-1 do begin
        inc(CountTriangleVertices);
        inc(Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].CountIndices);
       end;
      end;
     end;
     SetLength(Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].Indices,Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].CountIndices);
     Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].CountIndices:=0;
    end;
   end;
  end;
  SetLength(TriangleVertices,CountTriangleVertices);
  SetLength(TriangleHashNextIndices,CountTriangleVertices);
  for TriangleVertexIndex:=0 to CountTriangleVertices-1 do begin
   TriangleHashNextIndices[TriangleVertexIndex]:=-1;
  end;
  CountTriangleVertices:=0;
  for GroupIndex:=0 to length(Groups)-1 do begin
   for ObjectIndex:=0 to length(Groups[GroupIndex].Objects)-1 do begin
    FillChar(TriangleVertex,sizeof(TpvOBJTriangleVertex),#0);
    for PartIndex:=0 to length(Groups[GroupIndex].Objects[ObjectIndex].Parts)-1 do begin
     Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].CountIndices:=0;
     for FaceIndex:=0 to length(Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].Faces)-1 do begin
      if Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].Faces[FaceIndex].Count=3 then begin
       for SrcIndex:=0 to Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].Faces[FaceIndex].Count-1 do begin
        if (SrcIndex>=0) and (SrcIndex<length(Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].Faces[FaceIndex].VertexIndices)) then begin
         DstIndex:=Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].Faces[FaceIndex].VertexIndices[SrcIndex];
         if (DstIndex>=0) and (DstIndex<length(Vertices)) then begin
          TriangleVertex.Vertex:=Vertices[DstIndex];
          TriangleVertex.VertexIndex:=DstIndex;
         end;
        end;
        if (SrcIndex>=0) and (SrcIndex<length(Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].Faces[FaceIndex].NormalIndices)) then begin
         DstIndex:=Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].Faces[FaceIndex].NormalIndices[SrcIndex];
         if (DstIndex>=0) and (DstIndex<length(Normals)) then begin
          TriangleVertex.Normal:=Normals[DstIndex];
          TriangleVertex.NormalIndex:=DstIndex;
         end;
        end;
        if (SrcIndex>=0) and (SrcIndex<length(Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].Faces[FaceIndex].TangentIndices)) then begin
         DstIndex:=Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].Faces[FaceIndex].TangentIndices[SrcIndex];
         if (DstIndex>=0) and (DstIndex<length(Tangents)) then begin
          TriangleVertex.Tangent:=Tangents[DstIndex];
          TriangleVertex.TangentIndex:=DstIndex;
         end;
        end;
        if (SrcIndex>=0) and (SrcIndex<length(Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].Faces[FaceIndex].BitangentIndices)) then begin
         DstIndex:=Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].Faces[FaceIndex].BitangentIndices[SrcIndex];
         if (DstIndex>=0) and (DstIndex<length(Bitangents)) then begin
          TriangleVertex.Bitangent:=Bitangents[DstIndex];
          TriangleVertex.BitangentIndex:=DstIndex;
         end;
        end;
        if (SrcIndex>=0) and (SrcIndex<length(Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].Faces[FaceIndex].TexCoordIndices)) then begin
         DstIndex:=Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].Faces[FaceIndex].TexCoordIndices[SrcIndex];
         if (DstIndex>=0) and (DstIndex<length(TexCoords)) then begin
          TriangleVertex.TexCoord:=TexCoords[DstIndex];
          TriangleVertex.TexCoordIndex:=DstIndex;
         end;
        end;
        DstIndex:=-1;
        Hash:=HashBytes(@TriangleVertex,sizeof(TpvOBJTriangleVertexForHashing)) and HashMask;
        TriangleVertexIndex:=TriangleHashBuckets[Hash];
        while (TriangleVertexIndex>=0) and (TriangleVertexIndex<length(TriangleHashNextIndices)) do begin
         if CompareBytes(@TriangleVertex,@TriangleVertices[TriangleVertexIndex],sizeof(TpvOBJTriangleVertexForHashing)) then begin
          DstIndex:=TriangleVertexIndex;
          break;
         end else begin
          TriangleVertexIndex:=TriangleHashNextIndices[TriangleVertexIndex];
         end;
        end;
        if DstIndex<0 then begin
         if CountTriangleVertices>=length(TriangleVertices) then begin
          SetLength(TriangleVertices,NextPowerOfTwo(CountTriangleVertices+1,MemoryThreshold));
         end;
         if CountTriangleVertices>=length(TriangleHashNextIndices) then begin
          SetLength(TriangleHashNextIndices,NextPowerOfTwo(CountTriangleVertices+1,MemoryThreshold));
         end;
         DstIndex:=CountTriangleVertices;
         TriangleVertices[DstIndex]:=TriangleVertex;
         TriangleHashNextIndices[DstIndex]:=TriangleHashBuckets[Hash];
         TriangleHashBuckets[Hash]:=DstIndex;
         inc(CountTriangleVertices);
        end;
        if Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].CountIndices>=length(Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].Indices) then begin
         SetLength(Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].Indices,NextPowerOfTwo(Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].CountIndices+1,MemoryThreshold));
        end;
        Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].Indices[Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].CountIndices]:=DstIndex;
        inc(Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].CountIndices);
       end;
      end;
     end;
     SetLength(Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].Indices,Groups[GroupIndex].Objects[ObjectIndex].Parts[PartIndex].CountIndices);
    end;
   end;
  end;
 finally
  SetLength(TriangleVertices,CountTriangleVertices);
  SetLength(TriangleHashNextIndices,0);
  SetLength(TriangleHashBuckets,0);
 end;
end;

function TpvOBJModel.LoadFromStream(Stream:TStream;const FileName:TpvRawByteString=''):boolean;
var s:TpvRawByteString;
    ObjectIndex,Index,SubIndex,SubSubIndex:TpvSizeInt;
begin
 result:=false;
 Clear;
 MaterialIndex:=-1;
 Name:=ChangeFileExt(FileName,'');
 if assigned(Stream) then begin
  if GroupCount>=length(Groups) then begin
   SetLength(Groups,NextPowerOfTwo(GroupCount+1,MemoryThreshold));
  end;
  Index:=GroupCount;
  CurrentGroup:=GroupCount;
  inc(GroupCount);
  FillChar(Groups[Index],sizeof(TpvOBJGroup),#0);
  Groups[Index].Name:='';
  Groups[Index].Draw:=true;
  Stream.Seek(0,soBeginning);
  while Stream.Position<Stream.Size do begin
   s:=Trim(ReadLine(Stream));
   if (length(s)<>0) and (s[1]<>'#') then begin
    s[1]:=upcase(s[1]);
    case s[1] of 
     'G':begin
      if (length(Groups[CurrentGroup].Name)=0) and (length(Groups[CurrentGroup].Objects)=0) then begin
       Index:=CurrentGroup;
      end else begin
       if GroupCount>=length(Groups) then begin
        SetLength(Groups,NextPowerOfTwo(GroupCount+1,MemoryThreshold));
       end;
       Index:=GroupCount;
       CurrentGroup:=GroupCount;
       inc(GroupCount);
      end;
      FillChar(Groups[Index],sizeof(TpvOBJGroup),#0);
      Groups[Index].Name:=Trim(Copy(s,2,length(s)));
      Groups[Index].Draw:=true;
     end;
     'O':begin
      if Groups[Index].CountObjects>=length(Groups[Index].Objects) then begin
       SetLength(Groups[Index].Objects,NextPowerOfTwo(Groups[Index].CountObjects+1,MemoryThreshold));
      end;
      ObjectIndex:=Groups[Index].CountObjects;
      inc(Groups[Index].CountObjects);
      FillChar(Groups[Index].Objects[ObjectIndex],sizeof(TpvOBJObject),#0);
      Groups[Index].Objects[ObjectIndex].Name:=Trim(Copy(s,2,length(s)));
      Groups[Index].Objects[ObjectIndex].Draw:=true;
     end;
     'V':begin
      ParseVertices(s);
     end;
     'F':begin
      ParseFaces(s);
     end;
     'L':begin
      ParseLines(s);
     end;
     'U':begin
      if Copy(uppercase(s),1,6)='USEMTL' then begin
       GetMaterialName(s);
      end;
     end;
     'M':begin
      if Copy(uppercase(s),1,6)='MTLLIB' then begin
       LoadMaterials(s);
      end;
     end;
    end;
   end;
  end;
  SetLength(Groups,GroupCount);
  for Index:=0 to length(Groups)-1 do begin
   SetLength(Groups[Index].Objects,Groups[Index].CountObjects);
   for SubIndex:=0 to length(Groups[Index].Objects)-1 do begin
    SetLength(Groups[Index].Objects[SubIndex].Parts,Groups[Index].Objects[SubIndex].CountParts);
    for SubSubIndex:=0 to length(Groups[Index].Objects[SubIndex].Parts)-1 do begin
     SetLength(Groups[Index].Objects[SubIndex].Parts[SubSubIndex].Faces,Groups[Index].Objects[SubIndex].Parts[SubSubIndex].CountFaces);
     SetLength(Groups[Index].Objects[SubIndex].Parts[SubSubIndex].Lines,Groups[Index].Objects[SubIndex].Parts[SubSubIndex].CountLines);
    end;
   end;
  end;
  SetLength(Vertices,VertexCount);
  SetLength(Normals,NormalCount);
  SetLength(TexCoords,TexCoordCount);
  FixUpVerticesNormals;
  FixUpParts;
  result:=true;
 end;
end;

function TpvOBJModel.LoadModel(FileName:TpvRawByteString):boolean;
var Stream:TMemoryStream;
begin
 Clear;
 MaterialIndex:=-1;
 Name:=ChangeFileExt(FileName,'');
 Path:=ExtractFilePath(FileName);
 Stream:=TMemoryStream.Create;
 try
  FillStreamWithFile(Stream,FileName);
  Stream.Seek(0,soBeginning);
  result:=LoadFromStream(Stream,FileName);
 finally
  FreeAndNil(Stream);
 end;
end;

end.
