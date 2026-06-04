program dae2mdl; // Copyright (C) 2013-2017, Benjamin Rosseaux - License: zlib
{$ifdef fpc}
 {$mode delphi}
{$endif}
{$ifdef win32}
 {$define windows}
{$endif}
{$ifdef win64}
 {$define windows}
{$endif}
{$ifdef windows}
 {$apptype console}
{$endif}
{$j+}

uses
  SysUtils,
  Classes,
  SyncObjs,
  Math,
  PasMP in '..\..\..\..\..\..\externals\pasmp\src\PasMP.pas',
  PasDblStrUtils in '..\..\..\..\..\..\externals\pasdblstrutils\src\PasDblStrUtils.pas',
  PUCU in '..\..\..\..\..\..\externals\pucu\src\PUCU.pas',
  kraft in '..\..\..\..\..\..\externals\kraft\src\kraft.pas',
  UnitMath3D in 'UnitMath3D.pas',
  UnitXML in 'UnitXML.pas',
  UnitStringHashMap in 'UnitStringHashMap.pas',
  UnitStaticDAELoader in 'UnitStaticDAELoader.pas',
  UnitVertexCacheOptimizer in 'UnitVertexCacheOptimizer.pas';

var InputFileName:ansistring;
    OutputFileName:ansistring;

type PVertex=^TVertex;
     TVertex=record
      Position:TVector3;
      Normal:TVector3;
      Tangent:TVector3;
      Bitangent:TVector3;
      TexCoord:TVector2;
      Color:TVector4;
      Material:longint;
     end;

     PVertices=^TVertices;
     TVertices=array[0..2] of TVertex;

     PTriangleIndices=^TTriangleIndices;
     TTriangleIndices=array[0..2] of longint;

     PTriangle=^TTriangle;
     TTriangle=record
      Vertices:TVertices;
      Indices:TTriangleIndices;
      Normal:TVector3;
      MaterialIndex:longint;
      ObjectIndex:longint;
      MeshIndex:longint;
     end;

     TTriangles=array of TTriangle;

     TVertexBufferVertices=array of TVertex;

     TVertexBufferIndices=array of longint;

     PVertexBuffer=^TVertexBuffer;
     TVertexBuffer=record
      MaterialIndex:longint;
      Triangles:TTriangles;
      CountTriangles:longint;
      StartIndex:longint;
      CountIndices:longint;
     end;

     TVertexBuffers=array of TVertexBuffer;

     PBufferPart=^TBufferPart;
     TBufferPart=record
      Index:longint;
      Offset:longint;
      Count:longint;
     end;

     TBufferParts=array of TBufferPart;

     PMaterial=^TMaterial;
     TMaterial=record
      Name:ansistring;
      Texture:ansistring;
      Ambient:TVector3;
      Diffuse:TVector3;
      Emission:TVector3;
      Specular:TVector3;
      Shininess:single;
      BufferParts:TBufferParts;
      CountBufferParts:longint;
     end;

     TMaterials=array of TMaterial;

     PMesh=^TMesh;
     TMesh=record
      MaterialIndex:longint;
      Triangles:TTriangles;
      Sphere:TSphere;
      AABB:TAABB;
     end;

     TMeshs=array of TMesh;

     PModelObject=^TModelObject;
     TModelObject=record
      Name:ansistring;
      Collision:boolean;
      Meshs:TMeshs;
      Sphere:TSphere;
      AABB:TAABB;
     end;

     TModelObjects=array of TModelObject;

var Materials:TMaterials;
    ModelObjects:TModelObjects;
    Sphere:TSphere;
    AABB:TAABB;
    VertexBuffers:TVertexBuffers;

procedure LoadFinalize;
var ObjectIndex,MeshIndex,TriangleIndex,VertexIndex,GlobalCount,ObjectCount,MeshCount:longint;
    Radius:single;
    FirstMesh,FirstObject,FirstGlobal:boolean;
    v,Normal:TVector3;
    AObject:PModelObject;
    Mesh:PMesh;
    Triangle:PTriangle;
    Vertex:PVertex;
    TempVertex:TVertex;
    Center:TVector3;
begin
 try
  AABB.Min:=Vector3Origin;
  AABB.Max:=Vector3Origin;
  FirstGlobal:=true;
  for ObjectIndex:=0 to length(ModelObjects)-1 do begin
   AObject:=@ModelObjects[ObjectIndex];
   AObject^.Collision:=pos('collision',LowerCase(AObject^.Name))<>0;
   for MeshIndex:=0 to length(AObject^.Meshs)-1 do begin
    Mesh:=@AObject^.Meshs[MeshIndex];
    for TriangleIndex:=0 to length(Mesh^.Triangles)-1 do begin
     Triangle:=@Mesh^.Triangles[TriangleIndex];
     Triangle^.MaterialIndex:=Mesh^.MaterialIndex;
     Triangle^.ObjectIndex:=ObjectIndex;
     Triangle^.MeshIndex:=MeshIndex;
     for VertexIndex:=0 to 2 do begin
      Vertex:=@Triangle^.Vertices[VertexIndex];
      v:=Vertex^.Position;
      if not AObject^.Collision then begin
       if FirstGlobal then begin
        FirstGlobal:=false;
        AABB.Min:=v;
        AABB.Max:=v;
       end else begin
        AABB:=AABBCombineVector3(AABB,v);
       end;
      end;
     end;
    end;
   end;
  end;
  Center:=Vector3Avg(AABB.Min,AABB.Max);
  for ObjectIndex:=0 to length(ModelObjects)-1 do begin
   AObject:=@ModelObjects[ObjectIndex];
   for MeshIndex:=0 to length(AObject^.Meshs)-1 do begin
    Mesh:=@AObject^.Meshs[MeshIndex];
    for TriangleIndex:=0 to length(Mesh^.Triangles)-1 do begin
     Triangle:=@Mesh^.Triangles[TriangleIndex];
     Triangle^.MaterialIndex:=Mesh^.MaterialIndex;
     Triangle^.ObjectIndex:=ObjectIndex;
     Triangle^.MeshIndex:=MeshIndex;
     for VertexIndex:=0 to 2 do begin
      Vertex:=@Triangle^.Vertices[VertexIndex];
      Vertex^.Position:=Vector3Sub(Vertex^.Position,Center);
     end;
    end;
   end;
  end;
  Sphere.Center.x:=0.0;
  Sphere.Center.y:=0.0;
  Sphere.Center.z:=0.0;
  Sphere.Radius:=0.0;
  AABB.Min:=Vector3Origin;
  AABB.Max:=Vector3Origin;
  FirstGlobal:=true;
  GlobalCount:=0;
  for ObjectIndex:=0 to length(ModelObjects)-1 do begin
   AObject:=@ModelObjects[ObjectIndex];
   for MeshIndex:=0 to length(AObject^.Meshs)-1 do begin
    Mesh:=@AObject^.Meshs[MeshIndex];
    Mesh^.Sphere.Center:=Vector3Origin;
    Mesh^.Sphere.Radius:=0.0;
    Mesh^.AABB.Min:=Vector3Origin;
    Mesh^.AABB.Max:=Vector3Origin;
    for TriangleIndex:=0 to length(Mesh^.Triangles)-1 do begin
     Triangle:=@Mesh^.Triangles[TriangleIndex];
     Normal.x:=(Triangle^.Vertices[0].Normal.x+Triangle^.Vertices[1].Normal.x+Triangle^.Vertices[2].Normal.x)/3.0;
     Normal.y:=(Triangle^.Vertices[0].Normal.y+Triangle^.Vertices[1].Normal.y+Triangle^.Vertices[2].Normal.y)/3.0;
     Normal.z:=(Triangle^.Vertices[0].Normal.z+Triangle^.Vertices[1].Normal.z+Triangle^.Vertices[2].Normal.z)/3.0;
     if Vector3Dot(Vector3Norm(Vector3Cross(Vector3Sub(Triangle^.Vertices[1].Position,
                                                       Triangle^.Vertices[0].Position),
                                            Vector3Sub(Triangle^.Vertices[2].Position,
                                                       Triangle^.Vertices[0].Position))),
                                                       Normal)<0.0 then begin
      TempVertex:=Triangle^.Vertices[0];
      Triangle^.Vertices[0]:=Triangle^.Vertices[2];
      Triangle^.Vertices[2]:=TempVertex;
     end;
    end;
   end;
  end;
  for ObjectIndex:=0 to length(ModelObjects)-1 do begin
   AObject:=@ModelObjects[ObjectIndex];
   AObject^.Collision:=pos('collision',LowerCase(AObject^.Name))<>0;
   AObject^.Sphere.Center.x:=0.0;
   AObject^.Sphere.Center.y:=0.0;
   AObject^.Sphere.Center.z:=0.0;
   AObject^.Sphere.Radius:=0.0;
   AObject^.AABB.Min:=Vector3Origin;
   AObject^.AABB.Max:=Vector3Origin;
   FirstObject:=true;
   ObjectCount:=0;
   for MeshIndex:=0 to length(AObject^.Meshs)-1 do begin
    Mesh:=@AObject^.Meshs[MeshIndex];
    Mesh^.Sphere.Center:=Vector3Origin;
    Mesh^.Sphere.Radius:=0.0;
    Mesh^.AABB.Min:=Vector3Origin;
    Mesh^.AABB.Max:=Vector3Origin;
    FirstMesh:=true;
    MeshCount:=0;
    for TriangleIndex:=0 to length(Mesh^.Triangles)-1 do begin
     Triangle:=@Mesh^.Triangles[TriangleIndex];
     Triangle^.MaterialIndex:=Mesh^.MaterialIndex;
     Triangle^.ObjectIndex:=ObjectIndex;
     Triangle^.MeshIndex:=MeshIndex;
     for VertexIndex:=0 to 2 do begin
      Vertex:=@Triangle^.Vertices[VertexIndex];
      v:=Vertex^.Position;
      if not AObject^.Collision then begin
       if FirstGlobal then begin
        FirstGlobal:=false;
        AABB.Min:=v;
        AABB.Max:=v;
       end else begin
        AABB:=AABBCombineVector3(AABB,v);
       end;
       Sphere.Center.x:=Sphere.Center.x+v.x;
       Sphere.Center.y:=Sphere.Center.y+v.y;
       Sphere.Center.z:=Sphere.Center.z+v.z;
       inc(GlobalCount);
      end;
      begin
       if FirstObject then begin
        FirstObject:=false;
        AObject^.AABB.Min:=v;
        AObject^.AABB.Max:=v;
       end else begin
        AObject^.AABB:=AABBCombineVector3(AObject^.AABB,v);
       end;
       AObject^.Sphere.Center.x:=AObject^.Sphere.Center.x+v.x;
       AObject^.Sphere.Center.y:=AObject^.Sphere.Center.y+v.y;
       AObject^.Sphere.Center.z:=AObject^.Sphere.Center.z+v.z;
       inc(ObjectCount);
      end;
      begin
       if FirstMesh then begin
        FirstMesh:=false;
        Mesh^.AABB.Min:=v;
        Mesh^.AABB.Max:=v;
       end else begin
        Mesh^.AABB:=AABBCombineVector3(Mesh^.AABB,v);
       end;
       Mesh^.Sphere.Center.x:=Mesh^.Sphere.Center.x+v.x;
       Mesh^.Sphere.Center.y:=Mesh^.Sphere.Center.y+v.y;
       Mesh^.Sphere.Center.z:=Mesh^.Sphere.Center.z+v.z;
       inc(MeshCount);
      end;
     end;
    end;
    if MeshCount>0 then begin
     Mesh^.Sphere.Center.x:=Mesh^.Sphere.Center.x/MeshCount;
     Mesh^.Sphere.Center.y:=Mesh^.Sphere.Center.y/MeshCount;
     Mesh^.Sphere.Center.z:=Mesh^.Sphere.Center.z/MeshCount;
    end;
   end;
   if ObjectCount>0 then begin
    AObject^.Sphere.Center.x:=AObject^.Sphere.Center.x/ObjectCount;
    AObject^.Sphere.Center.y:=AObject^.Sphere.Center.y/ObjectCount;
    AObject^.Sphere.Center.z:=AObject^.Sphere.Center.z/ObjectCount;
   end;
  end;
  if GlobalCount>0 then begin
   Sphere.Center.x:=Sphere.Center.x/GlobalCount;
   Sphere.Center.y:=Sphere.Center.y/GlobalCount;
   Sphere.Center.z:=Sphere.Center.z/GlobalCount;
  end;
  Sphere.Radius:=0.0;
  for ObjectIndex:=0 to length(ModelObjects)-1 do begin
   AObject:=@ModelObjects[ObjectIndex];
   AObject^.Sphere.Radius:=0.0;
   for MeshIndex:=0 to length(AObject^.Meshs)-1 do begin
    Mesh:=@AObject^.Meshs[MeshIndex];
    Mesh^.Sphere.Radius:=0.0;
    for TriangleIndex:=0 to length(Mesh^.Triangles)-1 do begin
     Triangle:=@Mesh^.Triangles[TriangleIndex];
     for VertexIndex:=0 to 2 do begin
      Vertex:=@Triangle^.Vertices[VertexIndex];
      v:=Vertex^.Position;
      if not AObject^.Collision then begin
       Radius:=sqr(Sphere.Center.x-v.x)+sqr(Sphere.Center.y-v.y)+sqr(Sphere.Center.z-v.z);
       if Sphere.Radius<Radius then begin
        Sphere.Radius:=Radius;
       end;
      end;
      Radius:=sqr(Mesh^.Sphere.Center.x-v.x)+sqr(Mesh^.Sphere.Center.y-v.y)+sqr(Mesh^.Sphere.Center.z-v.z);
      if Mesh^.Sphere.Radius<Radius then begin
       Mesh^.Sphere.Radius:=Radius;
      end;
      Radius:=sqr(AObject^.Sphere.Center.x-v.x)+sqr(AObject^.Sphere.Center.y-v.y)+sqr(AObject^.Sphere.Center.z-v.z);
      if AObject^.Sphere.Radius<Radius then begin
       AObject^.Sphere.Radius:=Radius;
      end;
     end;
    end;
    if abs(Mesh^.Sphere.Radius)>1e-12 then begin
     Mesh^.Sphere.Radius:=sqrt(Mesh^.Sphere.Radius);
    end;
   end;
   if abs(AObject^.Sphere.Radius)>1e-12 then begin
    AObject^.Sphere.Radius:=sqrt(AObject^.Sphere.Radius);
   end;
  end;
  if abs(Sphere.Radius)>1e-12 then begin
   Sphere.Radius:=sqrt(Sphere.Radius);
  end;
 finally
 end;
end;

function LoadDAE:boolean;
var FileName:ansistring;
    fs:TFileStream;
    ms:TMemoryStream;
    DAE:TDAELoader;
    MaterialIndex,GeometryIndex,MeshIndex,CountIndices,IndicesIndex,TriangleIndex,VertexIndex,
    GeometryCount,MeshCount:longint;
    DAEMaterial:PDAEMaterial;
    Material:PMaterial;
    DAEGeometry:TDAEGeometry;
    AObject:PModelObject;
    DAEMesh:TDAEMesh;
    Mesh:PMesh;
    DAEVertex:PDAEVertex;
    Triangle:PTriangle;
    Vertex:PVertex;
begin
 result:=false;
 FileName:=InputFileName;
 if FileExists(FileName) then begin
  fs:=TFileStream.Create(FileName,fmOpenRead);
  try
   ms:=TMemoryStream.Create;
   try
    fs.Seek(0,soBeginning);
    ms.CopyFrom(fs,fs.Size);
    ms.Seek(0,soBeginning);
    DAE:=TDAELoader.Create;
    try
     if DAE.Load(ms) then begin
      SetLength(Materials,DAE.CountMaterials);
      for MaterialIndex:=0 to DAE.CountMaterials-1 do begin
       DAEMaterial:=@DAE.Materials[MaterialIndex];
       Material:=@Materials[MaterialIndex];
       FillChar(Material^,SizeOf(TMaterial),AnsiChar(#0));
       Material^.Name:=DAEMaterial^.Name;
       Material^.Texture:=ExtractFileName(DAEMaterial^.Diffuse.Texture);
       Material^.Ambient.x:=DAEMaterial^.Ambient.Color.x;
       Material^.Ambient.y:=DAEMaterial^.Ambient.Color.y;
       Material^.Ambient.z:=DAEMaterial^.Ambient.Color.z;
       Material^.Diffuse.x:=DAEMaterial^.Diffuse.Color.x;
       Material^.Diffuse.y:=DAEMaterial^.Diffuse.Color.y;
       Material^.Diffuse.z:=DAEMaterial^.Diffuse.Color.z;
       Material^.Emission.x:=DAEMaterial^.Emission.Color.x;
       Material^.Emission.y:=DAEMaterial^.Emission.Color.y;
       Material^.Emission.z:=DAEMaterial^.Emission.Color.z;
       Material^.Specular.x:=DAEMaterial^.Specular.Color.x;
       Material^.Specular.y:=DAEMaterial^.Specular.Color.y;
       Material^.Specular.z:=DAEMaterial^.Specular.Color.z;
       Material^.Shininess:=DAEMaterial^.Shininess;
       Material^.BufferParts:=nil;
       Material^.CountBufferParts:=0;
      end;
      SetLength(ModelObjects,DAE.Geometries.Count);
      GeometryCount:=0;
      for GeometryIndex:=0 to DAE.Geometries.Count-1 do begin
       AObject:=@ModelObjects[GeometryCount];
       FillChar(AObject^,SizeOf(TModelObject),AnsiChar(#0));
       DAEGeometry:=DAE.Geometries[GeometryIndex];
       AObject^.Name:=DAEGeometry.Name;
       SetLength(AObject^.Meshs,DAEGeometry.Count);
       MeshCount:=0;
       for MeshIndex:=0 to DAEGeometry.Count-1 do begin
        Mesh:=@AObject^.Meshs[MeshCount];
        FillChar(Mesh^,SizeOf(TMesh),AnsiChar(#0));
        DAEMesh:=DAEGeometry.Items[MeshIndex];
        Mesh^.MaterialIndex:=DAEMesh.MaterialIndex;
        case DAEMesh.MeshType of
         dlmtTRIANGLES:begin
          CountIndices:=length(DAEMesh.Indices);
          SetLength(Mesh^.Triangles,length(DAEMesh.Indices));
          TriangleIndex:=0;
          IndicesIndex:=0;
          while (IndicesIndex+2)<CountIndices do begin
           Triangle:=@Mesh^.Triangles[TriangleIndex];
           Triangle^.MaterialIndex:=Mesh^.MaterialIndex;
           Triangle^.ObjectIndex:=GeometryCount;
           Triangle^.MeshIndex:=MeshCount;
           for VertexIndex:=0 to 2 do begin
            Vertex:=@Triangle^.Vertices[VertexIndex];
            DAEVertex:=@DAEMesh.Vertices[DAEMesh.Indices[IndicesIndex+VertexIndex]];
            Vertex^.Position:=Vector3ScalarMul(DAEVertex^.Position,DAE.UnitMeter);
            Vertex^.Normal:=DAEVertex^.Normal;
            Vertex^.Tangent:=DAEVertex^.Tangent;
            Vertex^.Bitangent:=DAEVertex^.Bitangent;
            Vertex^.TexCoord:=DAEVertex^.TexCoords[0];
            Vertex^.Color.r:=DAEVertex^.Color.r;
            Vertex^.Color.g:=DAEVertex^.Color.g;
            Vertex^.Color.b:=DAEVertex^.Color.b;
            Vertex^.Color.a:=1.0;
            Vertex^.Material:=Triangle^.MaterialIndex;
           end;
           Triangle^.Normal:=Vector3Norm(Vector3Cross(Vector3Sub(Triangle^.Vertices[1].Position,Triangle.Vertices[0].Position),Vector3Sub(Triangle^.Vertices[2].Position,Triangle^.Vertices[0].Position)));
           if Vector3Dot(Triangle^.Normal,UnitMath3D.Vector3((Triangle^.Vertices[0].Normal.x+Triangle^.Vertices[1].Normal.x+Triangle^.Vertices[2].Normal.x)/3,
                                                             (Triangle^.Vertices[0].Normal.y+Triangle^.Vertices[1].Normal.y+Triangle^.Vertices[2].Normal.y)/3,
                                                             (Triangle^.Vertices[0].Normal.z+Triangle^.Vertices[1].Normal.z+Triangle^.Vertices[2].Normal.z)/3))<0.0 then begin
            Triangle^.Normal:=Vector3Neg(Triangle^.Normal);
           end;
           inc(TriangleIndex);
           inc(IndicesIndex,3);
          end;
          SetLength(Mesh^.Triangles,TriangleIndex);
          inc(MeshCount);
         end;
         dlmtLINESTRIP:begin
         end;
        end;
       end;
       SetLength(AObject^.Meshs,MeshCount);
       if MeshCount>0 then begin
        inc(GeometryCount);
       end;
      end;
      SetLength(ModelObjects,GeometryCount);
      LoadFinalize;
      result:=true;
     end;
    finally
     DAE.Free;
    end;
   finally
    ms.Free;
   end;
  finally
   fs.Free;
  end;
 end;
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

procedure ReallocateMemory(var p;Size:longint); 
begin
 if assigned(pointer(p)) then begin
  if Size=0 then begin
   FreeMem(pointer(p));
   pointer(p):=nil;
  end else begin
   ReallocMem(pointer(p),Size);
  end;
 end else if Size<>0 then begin
  GetMem(pointer(p),Size);
 end;
end;

function RoundUpToPowerOfTwo(x:longword):longword;
begin
 dec(x);
 x:=x or (x shr 1);
 x:=x or (x shr 2);
 x:=x or (x shr 4);
 x:=x or (x shr 8);
 x:=x or (x shr 16);
 result:=x+1;
end;

function IntLog2(x:longword):longword; {$ifdef cpu386}register;
asm
 test eax,eax
 jz @Done
 bsr eax,eax
 @Done:
end;
{$else}
begin
 x:=x or (x shr 1);
 x:=x or (x shr 2);
 x:=x or (x shr 4);
 x:=x or (x shr 8);
 x:=x or (x shr 16);
 x:=x shr 1;
 x:=x-((x shr 1) and $55555555);
 x:=((x shr 2) and $33333333)+(x and $33333333);
 x:=((x shr 4)+x) and $0f0f0f0f;
 x:=x+(x shr 8);
 x:=x+(x shr 16);
 result:=x and $3f;
end;
{$endif}

function TriangleOptimizerCompare(const a,b:pointer):longint;
begin
 result:=PTriangle(a)^.MaterialIndex-PTriangle(b)^.MaterialIndex;
 if result=0 then begin
  result:=PTriangle(a)^.ObjectIndex-PTriangle(b)^.ObjectIndex;
  if result=0 then begin
   result:=PTriangle(a)^.MeshIndex-PTriangle(b)^.MeshIndex;
  end;
 end;
end;

type TSortCompareFunction=function(const a,b:pointer):longint;

procedure MemorySwap(a,b:pointer;Size:longint);
var Temp:longint;
begin
 while Size>=SizeOf(longint) do begin
  Temp:=longword(a^);
  longword(a^):=longword(b^);
  longword(b^):=Temp;
  inc(PByte(a),SizeOf(longword));
  inc(PByte(b),SizeOf(longword));
  dec(Size,SizeOf(longword));
 end;
 while Size>=SizeOf(byte) do begin
  Temp:=byte(a^);
  byte(a^):=byte(b^);
  byte(b^):=Temp;
  inc(PByte(a),SizeOf(byte));
  inc(PByte(b),SizeOf(byte));
  dec(Size,SizeOf(byte));
 end;
end;

procedure DirectIntroSort(Items:pointer;Left,Right,ElementSize:longint;CompareFunc:TSortCompareFunction);
type PByteArray=^TByteArray;
     TByteArray=array[0..$3fffffff] of byte;
     PStackItem=^TStackItem;
     TStackItem=record
      Left,Right,Depth:longint;
     end;
     TPtrUInt={$if defined(fpc)}PtrUInt{$elseif declared(NativeUInt)}NativeUInt{$elseif defined(cpu64)}UInt64{$else}longword{$ifend};
var Depth,i,j,Middle,Size,Parent,Child,Pivot,iA,iB,iC:longint;
    StackItem:PStackItem;
    Stack:array[0..31] of TStackItem;
begin
 if Left<Right then begin
  StackItem:=@Stack[0];
  StackItem^.Left:=Left;
  StackItem^.Right:=Right;
  StackItem^.Depth:=IntLog2((Right-Left)+1) shl 1;
  inc(StackItem);
  while TPtrUInt(pointer(StackItem))>TPtrUInt(pointer(@Stack[0])) do begin
   dec(StackItem);
   Left:=StackItem^.Left;
   Right:=StackItem^.Right;
   Depth:=StackItem^.Depth;
   Size:=(Right-Left)+1;
   if Size<16 then begin
    // Insertion sort
    iA:=Left;
    iB:=iA+1;
    while iB<=Right do begin
     iC:=iB;
     while (iA>=Left) and
           (iC>=Left) and
           (CompareFunc(pointer(@PByteArray(Items)^[iA*ElementSize]),pointer(@PByteArray(Items)^[iC*ElementSize]))>0) do begin
      MemorySwap(@PByteArray(Items)^[iA*ElementSize],@PByteArray(Items)^[iC*ElementSize],ElementSize);
      dec(iA);
      dec(iC);
     end;
     iA:=iB;
     inc(iB);
    end;
   end else begin
    if (Depth=0) or (TPtrUInt(pointer(StackItem))>=TPtrUInt(pointer(@Stack[high(Stack)-1]))) then begin
     // Heap sort
     i:=Size div 2;
     repeat
      if i>0 then begin
       dec(i);
      end else begin
       dec(Size);
       if Size>0 then begin
        MemorySwap(@PByteArray(Items)^[(Left+Size)*ElementSize],@PByteArray(Items)^[Left*ElementSize],ElementSize);
       end else begin
        break;
       end;
      end;
      Parent:=i;
      repeat
       Child:=(Parent*2)+1;
       if Child<Size then begin
        if (Child<(Size-1)) and (CompareFunc(pointer(@PByteArray(Items)^[(Left+Child)*ElementSize]),pointer(@PByteArray(Items)^[(Left+Child+1)*ElementSize]))<0) then begin
         inc(Child);
        end;
        if CompareFunc(pointer(@PByteArray(Items)^[(Left+Parent)*ElementSize]),pointer(@PByteArray(Items)^[(Left+Child)*ElementSize]))<0 then begin
         MemorySwap(@PByteArray(Items)^[(Left+Parent)*ElementSize],@PByteArray(Items)^[(Left+Child)*ElementSize],ElementSize);
         Parent:=Child;
         continue;
        end;
       end;
       break;
      until false;
     until false;
    end else begin
     // Quick sort width median-of-three optimization
     Middle:=Left+((Right-Left) shr 1);
     if (Right-Left)>3 then begin
      if CompareFunc(pointer(@PByteArray(Items)^[Left*ElementSize]),pointer(@PByteArray(Items)^[Middle*ElementSize]))>0 then begin
       MemorySwap(@PByteArray(Items)^[Left*ElementSize],@PByteArray(Items)^[Middle*ElementSize],ElementSize);
      end;
      if CompareFunc(pointer(@PByteArray(Items)^[Left*ElementSize]),pointer(@PByteArray(Items)^[Right*ElementSize]))>0 then begin
       MemorySwap(@PByteArray(Items)^[Left*ElementSize],@PByteArray(Items)^[Right*ElementSize],ElementSize);
      end;
      if CompareFunc(pointer(@PByteArray(Items)^[Middle*ElementSize]),pointer(@PByteArray(Items)^[Right*ElementSize]))>0 then begin
       MemorySwap(@PByteArray(Items)^[Middle*ElementSize],@PByteArray(Items)^[Right*ElementSize],ElementSize);
      end;
     end;
     Pivot:=Middle;
     i:=Left;
     j:=Right;
     repeat
      while (i<Right) and (CompareFunc(pointer(@PByteArray(Items)^[i*ElementSize]),pointer(@PByteArray(Items)^[Pivot*ElementSize]))<0) do begin
       inc(i);
      end;
      while (j>=i) and (CompareFunc(pointer(@PByteArray(Items)^[j*ElementSize]),pointer(@PByteArray(Items)^[Pivot*ElementSize]))>0) do begin
       dec(j);
      end;
      if i>j then begin
       break;
      end else begin
       if i<>j then begin
        MemorySwap(@PByteArray(Items)^[i*ElementSize],@PByteArray(Items)^[j*ElementSize],ElementSize);
        if Pivot=i then begin
         Pivot:=j;
        end else if Pivot=j then begin
         Pivot:=i;
        end;
       end;
       inc(i);
       dec(j);
      end;
     until false;
     if i<Right then begin
      StackItem^.Left:=i;
      StackItem^.Right:=Right;
      StackItem^.Depth:=Depth-1;
      inc(StackItem);
     end;
     if Left<j then begin
      StackItem^.Left:=Left;
      StackItem^.Right:=j;
      StackItem^.Depth:=Depth-1;
      inc(StackItem);
     end;
    end;
   end;
  end;
 end;
end;

procedure OptimizeModelForVertexCache;
const HashBits=16;
      HashSize=1 shl HashBits;
      HashMask=HashSize-1;
type PHashItem=^THashItem;
     THashItem=record
      Next:longint;
      Hash:longword;
      VertexIndex:longint;
      Dummy:longint;
     end;
     THashItems=array of THashItem;
     PHashTable=^THashTable;
     THashTable=array[0..HashSize-1] of longint;
var LightMapIndex,MaterialIndex,ObjectIndex,MeshIndex,TriangleIndex,TempTriangleIndex,TrianglesToDo,BufferPartIndex,
    TrianglesCount,VertexBufferIndex,CountVertexBuffers,VertexIndex,IndicesIndex,CountHashItems,HashItemIndex,
    {CountIndexMapItems,}CountHashVertices:longint;
    Material:PMaterial;
    AObject:PModelObject;
    Mesh:PMesh;
    HashItem:PHashItem;
    HashItems:THashItems;
    HashTable:THashTable;
    Hash:longword;
    InIndices,OutIndices,OutTriangles:TVertexCacheOptimizerIndices;
    HashVertices:array of TVertex;
    OldTriangles:TTriangles;
 function HashVector2(const v:TVector2):longword;
 begin
  result:=(round(v.x)*73856093) xor (round(v.y)*19349663);
 end;
 function HashVector3(const v:TVector3):longword;
 begin
  result:=(round(v.x)*73856093) xor (round(v.y)*19349663) xor (round(v.z)*83492791);
 end;
 function HashVector4(const v:TVector4):longword;
 begin
  result:=(round(v.x)*73856093) xor (round(v.y)*19349663) xor (round(v.z)*83492791) xor (round(v.w)*29475827);
 end;
 function HashVertex(const v:TVertex):longword;
 begin
  result:=HashVector3(v.Position);
  result:=((result shr 13) or (result shl 19)) xor HashVector3(Vector3ScalarMul(v.Normal,256.0));
  result:=((result shl 7) or (result shr 25)) xor HashVector3(Vector3ScalarMul(v.Tangent,256.0));
  result:=((result shr 3) or (result shl 29)) xor HashVector3(Vector3ScalarMul(v.Bitangent,256.0));
  result:=((result shl 5) or (result shr 27)) xor HashVector2(Vector2ScalarMul(v.TexCoord,256.0));
  result:=((result shl 11) or (result shr 21)) xor HashVector4(Vector4ScalarMul(v.Color,256.0));
 end;
 function CompareVertex(const a,b:TVertex):boolean;
 const Threshold=1e-8;
 begin
  result:=Vector3CompareEx(a.Position,b.Position,Threshold) and
          Vector3CompareEx(a.Normal,b.Normal,Threshold) and
          Vector3CompareEx(a.Tangent,b.Tangent,Threshold) and
          Vector3CompareEx(a.Bitangent,b.Bitangent,Threshold) and
          Vector2CompareEx(a.TexCoord,b.TexCoord,Threshold) and
          Vector4CompareEx(a.Color,b.Color,Threshold);
 end;
begin
 HashItems:=nil;
 HashVertices:=nil;
 InIndices:=nil;
 OutIndices:=nil;
 OutTriangles:=nil;
 OldTriangles:=nil;
 try
  for MaterialIndex:=0 to length(Materials)-1 do begin
   Material:=@Materials[MaterialIndex];
   for ObjectIndex:=0 to length(ModelObjects)-1 do begin
    AObject:=@ModelObjects[ObjectIndex];
    if not AObject^.Collision then begin
     for MeshIndex:=0 to length(AObject^.Meshs)-1 do begin
      Mesh:=@AObject^.Meshs[MeshIndex];
      if length(Mesh^.Triangles)>0 then begin
       if length(Mesh^.Triangles)>1 then begin
        DirectIntroSort(@Mesh^.Triangles[0],0,length(Mesh^.Triangles)-1,SizeOf(TTriangle),TriangleOptimizerCompare);
       end;
       SetLength(OldTriangles,0);
       OldTriangles:=copy(Mesh^.Triangles);
       TriangleIndex:=0;
       while TriangleIndex<length(Mesh^.Triangles) do begin
        TempTriangleIndex:=TriangleIndex;
        TrianglesToDo:=0;
        while (TempTriangleIndex<length(Mesh^.Triangles)) and
              ((Mesh^.Triangles[TriangleIndex].MaterialIndex=Mesh^.Triangles[TempTriangleIndex].MaterialIndex) and
               (Mesh^.Triangles[TriangleIndex].ObjectIndex=Mesh^.Triangles[TempTriangleIndex].ObjectIndex) and
               (Mesh^.Triangles[TriangleIndex].MeshIndex=Mesh^.Triangles[TempTriangleIndex].MeshIndex)) do begin
         inc(TrianglesToDo);
         inc(TempTriangleIndex);
        end;
        SetLength(InIndices,TrianglesToDo*3);
        SetLength(OutIndices,TrianglesToDo*3);
        SetLength(OutTriangles,TrianglesToDo);
        CountHashItems:=0;
//      CountIndexMapItems:=0;
        CountHashVertices:=0;
        FillChar(HashTable,SizeOf(THashTable),AnsiChar(#$ff));
        for TempTriangleIndex:=0 to TrianglesToDo-1 do begin
         for VertexIndex:=0 to 2 do begin
          Hash:=HashVertex(Mesh^.Triangles[TriangleIndex+TempTriangleIndex].Vertices[VertexIndex]);
          HashItemIndex:=HashTable[Hash and HashMask];
          while HashItemIndex>=0 do begin
           HashItem:=@HashItems[HashItemIndex];
           if (HashItem^.Hash=Hash) and CompareVertex(HashVertices[HashItem^.VertexIndex],Mesh^.Triangles[TriangleIndex+TempTriangleIndex].Vertices[VertexIndex]) then begin
            break;
           end else begin
            HashItemIndex:=HashItem^.Next;
           end;
          end;
          if HashItemIndex<0 then begin
           if length(HashItems)<(CountHashItems+1) then begin
            SetLength(HashItems,(CountHashItems+1)*2);
           end;
           HashItem:=@HashItems[CountHashItems];
           HashItem^.Next:=HashTable[Hash and HashMask];
           HashTable[Hash and HashMask]:=CountHashItems;
           HashItem^.Hash:=Hash;
           inc(CountHashItems);
           if length(HashVertices)<(CountHashVertices+1) then begin
            SetLength(HashVertices,(CountHAshVertices+1)*2);
           end;
           HashVertices[CountHashVertices]:=Mesh^.Triangles[TriangleIndex+TempTriangleIndex].Vertices[VertexIndex];
           HashItem^.VertexIndex:=CountHashVertices;
           inc(CountHashVertices);
          end;
          Mesh^.Triangles[TriangleIndex+TempTriangleIndex].Indices[VertexIndex]:=HashItem^.VertexIndex;
          InIndices[(TempTriangleIndex*3)+VertexIndex]:=HashItem^.VertexIndex;
         end;
        end;
        if OptimizeForVertexCache(InIndices,TrianglesToDo,TrianglesToDo*3,OutIndices,OutTriangles) then begin
         for TempTriangleIndex:=0 to TrianglesToDo-1 do begin
          Mesh^.Triangles[TriangleIndex+TempTriangleIndex]:=OldTriangles[TriangleIndex+OutTriangles[TempTriangleIndex]];
          Mesh^.Triangles[TriangleIndex+TempTriangleIndex].Vertices[0].Material:=Mesh^.MaterialIndex;
          Mesh^.Triangles[TriangleIndex+TempTriangleIndex].Vertices[1].Material:=Mesh^.MaterialIndex;
          Mesh^.Triangles[TriangleIndex+TempTriangleIndex].Vertices[2].Material:=Mesh^.MaterialIndex;
         end;
        end;
        inc(TriangleIndex,TrianglesToDo);
       end;
      end;
     end;
    end;
   end;
  end;
 finally
  SetLength(HashItems,0);
  SetLength(HashVertices,0);
  SetLength(InIndices,0);
  SetLength(OutIndices,0);
  SetLength(OutTriangles,0);
  SetLength(OldTriangles,0);
 end;
end;

var VBOVertices:array of TVertex;
    IBOIndices:array of longword;
    CountVBOVertices:longint=0;
    CountIBOIndices:longint=0;
            
procedure BuildVertexAndIndexBuffers;
const HashBits=16;
      HashSize=1 shl HashBits;
      HashMask=HashSize-1;
type PHashItem=^THashItem;
     THashItem=record
      Next:longint;
      Hash:longword;
      VertexIndex:longint;
      Dummy:longint;
     end;
     THashItems=array of THashItem;
     PHashTable=^THashTable;
     THashTable=array[0..HashSize-1] of longint;
var MaterialIndex,ObjectIndex,MeshIndex,TriangleIndex,TrianglesToDo,BufferPartIndex,
    TrianglesCount,VertexBufferIndex,CountVertexBuffers,CountTriangles,VertexIndex,
    IndicesIndex,CountHashItems,HashItemIndex:longint;
    Material:PMaterial;
    AObject:PModelObject;
    Mesh:PMesh;
    VertexBuffer:PVertexBuffer;
    BufferPart:PBufferPart;
    HashItem:PHashItem;
    HashItems:THashItems;
    HashTable:THashTable;
    Hash:longword;
    NeedNewBuffer:boolean;
 function HashVector2(const v:TVector2):longword;
 begin
  result:=(round(v.x)*73856093) xor (round(v.y)*19349663);
 end;
 function HashVector3(const v:TVector3):longword;
 begin
  result:=(round(v.x)*73856093) xor (round(v.y)*19349663) xor (round(v.z)*83492791);
 end;
 function HashVector4(const v:TVector4):longword;
 begin
  result:=(round(v.x)*73856093) xor (round(v.y)*19349663) xor (round(v.z)*83492791) xor (round(v.w)*29475827);
 end;
 function HashVertex(const v:TVertex):longword;
 begin
  result:=HashVector3(v.Position);
  result:=((result shr 13) or (result shl 19)) xor HashVector3(Vector3ScalarMul(v.Normal,256.0));
  result:=((result shl 7) or (result shr 25)) xor HashVector3(Vector3ScalarMul(v.Tangent,256.0));
  result:=((result shr 3) or (result shl 29)) xor HashVector3(Vector3ScalarMul(v.Bitangent,256.0));
  result:=((result shl 5) or (result shr 27)) xor HashVector2(Vector2ScalarMul(v.TexCoord,256.0));
  result:=((result shl 11) or (result shr 21)) xor HashVector4(Vector4ScalarMul(v.Color,256.0));
 end;
 function CompareVertex(const a,b:TVertex):boolean;
 const Threshold=1e-8;
 begin
  result:=Vector3CompareEx(a.Position,b.Position,Threshold) and
          Vector3CompareEx(a.Normal,b.Normal,Threshold) and
          Vector3CompareEx(a.Tangent,b.Tangent,Threshold) and
          Vector3CompareEx(a.Bitangent,b.Bitangent,Threshold) and
          Vector2CompareEx(a.TexCoord,b.TexCoord,Threshold) and
          Vector4CompareEx(a.Color,b.Color,Threshold);
 end;
begin
 HashItems:=nil;
 try
  SetLength(VertexBuffers,0);
  VertexBuffers:=nil;
  CountVertexBuffers:=0;
  for MaterialIndex:=0 to length(Materials)-1 do begin
   NeedNewBuffer:=true;
   Material:=@Materials[MaterialIndex];
   for ObjectIndex:=0 to length(ModelObjects)-1 do begin
    AObject:=@ModelObjects[ObjectIndex];
    if not AObject^.Collision then begin
     for MeshIndex:=0 to length(AObject^.Meshs)-1 do begin
      Mesh:=@AObject^.Meshs[MeshIndex];
      if MaterialIndex=Mesh^.MaterialIndex then begin
       TriangleIndex:=0;
       CountTriangles:=length(Mesh^.Triangles);
       while TriangleIndex<CountTriangles do begin
        TrianglesToDo:=CountTriangles-TriangleIndex;
        if TrianglesToDo>0 then begin
         VertexBufferIndex:=CountVertexBuffers-1;
         if (VertexBufferIndex<0) or NeedNewBuffer then begin
          VertexBufferIndex:=CountVertexBuffers;
          inc(CountVertexBuffers);
          if CountVertexBuffers>length(VertexBuffers) then begin
           SetLength(VertexBuffers,CountVertexBuffers*2);
          end;
          VertexBuffer:=@VertexBuffers[VertexBufferIndex];
          VertexBuffer^.MaterialIndex:=MaterialIndex;
          VertexBuffer^.Triangles:=nil;
          VertexBuffer^.CountTriangles:=0;
          VertexBuffer^.StartIndex:=0;
          VertexBuffer^.CountIndices:=0;
         end else begin
          VertexBuffer:=@VertexBuffers[VertexBufferIndex];
         end;
         NeedNewBuffer:=false;
         BufferPartIndex:=Material^.CountBufferParts-1;
         if (BufferPartIndex>=0) and
            ((Material^.BufferParts[BufferPartIndex].Index=VertexBufferIndex) and
             ((Material^.BufferParts[BufferPartIndex].Offset+Material^.BufferParts[BufferPartIndex].Count)=VertexBuffer^.CountTriangles)) then begin
          BufferPart:=@Material^.BufferParts[BufferPartIndex];
         end else begin
          BufferPartIndex:=Material^.CountBufferParts;
          inc(Material^.CountBufferParts);
          if Material^.CountBufferParts>length(Material^.BufferParts) then begin
           SetLength(Material^.BufferParts,Material^.CountBufferParts*2);
          end;
          BufferPart:=@Material^.BufferParts[BufferPartIndex];
          BufferPart^.Index:=VertexBufferIndex;
          BufferPart^.Offset:=VertexBuffer^.CountTriangles;
          BufferPart^.Count:=0;
         end;
         if length(VertexBuffer^.Triangles)<longint(RoundUpToPowerOfTwo(VertexBuffer^.CountTriangles+TrianglesToDo)) then begin
          SetLength(VertexBuffer^.Triangles,RoundUpToPowerOfTwo(VertexBuffer^.CountTriangles+TrianglesToDo));
         end;
         Move(Mesh^.Triangles[TriangleIndex],VertexBuffer^.Triangles[BufferPart^.Offset+BufferPart^.Count],TrianglesToDo*SizeOf(TTriangle));
         inc(TriangleIndex,TrianglesToDo);
         inc(VertexBuffer^.CountTriangles,TrianglesToDo);
         inc(BufferPart^.Count,TrianglesToDo);
        end else begin
         break;
        end;
       end;
      end;
     end;
    end;
   end;
  end;
  VBOVertices:=nil;
  IBOIndices:=nil;
  CountVBOVertices:=0;
  CountIBOIndices:=0;
  SetLength(VertexBuffers,CountVertexBuffers);
  for VertexBufferIndex:=0 to CountVertexBuffers-1 do begin
   VertexBuffer^.StartIndex:=CountIBOIndices;
   VertexBuffer^.CountIndices:=0; 
   CountHashItems:=0;
   FillChar(HashTable,SizeOf(THashTable),AnsiChar(#$ff));
   VertexBuffer:=@VertexBuffers[VertexBufferIndex];
   for TriangleIndex:=0 to VertexBuffer^.CountTriangles-1 do begin
    for VertexIndex:=0 to 2 do begin
     Hash:=HashVertex(VertexBuffer^.Triangles[TriangleIndex].Vertices[VertexIndex]);
     HashItemIndex:=HashTable[Hash and HashMask];
     while HashItemIndex>=0 do begin
      HashItem:=@HashItems[HashItemIndex];
      if (HashItem^.Hash=Hash) and CompareVertex(VBOVertices[HashItem^.VertexIndex],VertexBuffer^.Triangles[TriangleIndex].Vertices[VertexIndex]) then begin
       break;
      end else begin
       HashItemIndex:=HashItem^.Next;
      end;
     end;
     if HashItemIndex<0 then begin
      if length(HashItems)<(CountHashItems+1) then begin
       SetLength(HashItems,(CountHashItems+1)*2);
      end;
      HashItem:=@HashItems[CountHashItems];
      HashItem^.Next:=HashTable[Hash and HashMask];
      HashTable[Hash and HashMask]:=CountHashItems;
      HashItem^.Hash:=Hash;
      inc(CountHashItems);
      if length(VBOVertices)<(CountVBOVertices+1) then begin
       SetLength(VBOVertices,(CountVBOVertices+1)*2);
      end;
      VBOVertices[CountVBOVertices]:=VertexBuffer^.Triangles[TriangleIndex].Vertices[VertexIndex];
      HashItem^.VertexIndex:=CountVBOVertices;
      inc(CountVBOVertices);
     end;
     if length(IBOIndices)<(CountIBOIndices+1) then begin
      SetLength(IBOIndices,(CountIBOIndices+1)*2);
     end;
     IBOIndices[CountIBOIndices]:=HashItem^.VertexIndex;
     inc(CountIBOIndices);
     VertexBuffer^.Triangles[TriangleIndex].Indices[VertexIndex]:=HashItem^.VertexIndex;
     inc(VertexBuffer^.CountIndices);
    end;
   end;
  end;
 finally
  SetLength(HashItems,0);
 end;
end;

var ConvexHullStream:TMemoryStream;

procedure BuildConvexHull;
var i:longint;
    KraftInstance:TKraft;
    ConvexHull:TKraftConvexHull;
begin
 KraftInstance:=TKraft.Create;
 try
  ConvexHull:=TKraftConvexHull.Create(KraftInstance);
  try
   for i:=0 to CountVBOVertices-1 do begin
    ConvexHull.AddVertex(PKraftVector3(pointer(@VBOVertices[i].Position))^);
   end;
   ConvexHull.Build(16);
   ConvexHull.Finish;
   ConvexHull.SaveToStream(ConvexHullStream);
   ConvexHullStream.Seek(0,soBeginning);
  finally
   ConvexHull.Free;
  end;
 finally
  KraftInstance.Free;
 end;
end;

procedure RobustOrthoNormalize(var Tangent,Bitangent,Normal:TVector3;const Tolerance:single=1e-3);
var Bisector,Axis:TVector3;
begin
 begin
  if Vector3Length(Normal)<Tolerance then begin
   // Degenerate case, compute new normal
   Normal:=Vector3Cross(Tangent,Bitangent);
   if Vector3Length(Normal)<Tolerance then begin
    Tangent:=Vector3XAxis;
    Bitangent:=Vector3YAxis;
    Normal:=Vector3ZAxis;
    exit;
   end;
  end;
  Normal:=Vector3Norm(Normal);
 end;
 begin
  // Project tangent and bitangent onto the normal orthogonal plane
  Tangent:=Vector3Sub(Tangent,Vector3ScalarMul(Normal,Vector3Dot(Tangent,Normal)));
  Bitangent:=Vector3Sub(Bitangent,Vector3ScalarMul(Normal,Vector3Dot(Bitangent,Normal)));
 end;
 begin
  // Check for several degenerate cases
  if Vector3Length(Tangent)<Tolerance then begin
   if Vector3Length(Bitangent)<Tolerance then begin
    Tangent:=Vector3Norm(Normal);
    if (Tangent.x<=Tangent.y) and (Tangent.x<=Tangent.z) then begin
     Tangent:=Vector3XAxis;
    end else if (Tangent.y<=Tangent.x) and (Tangent.y<=Tangent.z) then begin
     Tangent:=Vector3YAxis;
    end else begin
     Tangent:=Vector3ZAxis;
    end;
    Tangent:=Vector3Sub(Tangent,Vector3ScalarMul(Normal,Vector3Dot(Tangent,Normal)));
    Bitangent:=Vector3Norm(Vector3Cross(Normal,Tangent));
   end else begin
    Tangent:=Vector3Norm(Vector3Cross(Bitangent,Normal));
   end;
  end else begin
   Tangent:=Vector3Norm(Tangent);
   if Vector3Length(Bitangent)<Tolerance then begin
    Bitangent:=Vector3Norm(Vector3Cross(Normal,Tangent));
   end else begin
    Bitangent:=Vector3Norm(Bitangent);
    Bisector:=Vector3Add(Tangent,Bitangent);
    if Vector3Length(Bisector)<Tolerance then begin
     Bisector:=Tangent;
    end else begin
     Bisector:=Vector3Norm(Bisector);
    end;
    Axis:=Vector3Norm(Vector3Cross(Bisector,Normal));
    if Vector3Dot(Axis,Tangent)>0.0 then begin
     Tangent:=Vector3Norm(Vector3Add(Bisector,Axis));
     Bitangent:=Vector3Norm(Vector3Sub(Bisector,Axis));
    end else begin
     Tangent:=Vector3Norm(Vector3Sub(Bisector,Axis));
     Bitangent:=Vector3Norm(Vector3Add(Bisector,Axis));
    end;
   end;
  end;
 end;
 Bitangent:=Vector3Norm(Vector3Cross(Normal,Tangent));
 Tangent:=Vector3Norm(Vector3Cross(Bitangent,Normal));
 Normal:=Vector3Norm(Vector3Cross(Tangent,Bitangent));
end;

function Matrix3x3ToQTangent(RawComponents:TMatrix3x3):TQuaternion;
const Threshold=1.0/32767.0;
var Scale,t,s,Renormalization:single;
begin
 RobustOrthoNormalize(PVector3(@RawComponents[0,0])^,
                      PVector3(@RawComponents[1,0])^,
                      PVector3(@RawComponents[2,0])^);
 if ((((((RawComponents[0,0]*RawComponents[1,1]*RawComponents[2,2])+
         (RawComponents[0,1]*RawComponents[1,2]*RawComponents[2,0])
        )+
        (RawComponents[0,2]*RawComponents[1,0]*RawComponents[2,1])
       )-
       (RawComponents[0,2]*RawComponents[1,1]*RawComponents[2,0])
      )-
      (RawComponents[0,1]*RawComponents[1,0]*RawComponents[2,2])
     )-
     (RawComponents[0,0]*RawComponents[1,2]*RawComponents[2,1])
    )<0.0 then begin
  // Reflection matrix, so flip y axis in case the tangent frame encodes a reflection
  Scale:=-1.0;
  RawComponents[2,0]:=-RawComponents[2,0];
  RawComponents[2,1]:=-RawComponents[2,1];
  RawComponents[2,2]:=-RawComponents[2,2];
 end else begin
  // Rotation matrix, so nothing is doing to do
  Scale:=1.0;
 end;
 begin
  // Convert to quaternion
  t:=RawComponents[0,0]+(RawComponents[1,1]+RawComponents[2,2]);
  if t>2.9999999 then begin
   result.x:=0.0;
   result.y:=0.0;
   result.z:=0.0;
   result.w:=1.0;
  end else if t>0.0000001 then begin
   s:=sqrt(1.0+t)*2.0;
   result.x:=(RawComponents[1,2]-RawComponents[2,1])/s;
   result.y:=(RawComponents[2,0]-RawComponents[0,2])/s;
   result.z:=(RawComponents[0,1]-RawComponents[1,0])/s;
   result.w:=s*0.25;
  end else if (RawComponents[0,0]>RawComponents[1,1]) and (RawComponents[0,0]>RawComponents[2,2]) then begin
   s:=sqrt(1.0+(RawComponents[0,0]-(RawComponents[1,1]+RawComponents[2,2])))*2.0;
   result.x:=s*0.25;
   result.y:=(RawComponents[1,0]+RawComponents[0,1])/s;
   result.z:=(RawComponents[2,0]+RawComponents[0,2])/s;
   result.w:=(RawComponents[1,2]-RawComponents[2,1])/s;
  end else if RawComponents[1,1]>RawComponents[2,2] then begin
   s:=sqrt(1.0+(RawComponents[1,1]-(RawComponents[0,0]+RawComponents[2,2])))*2.0;
   result.x:=(RawComponents[1,0]+RawComponents[0,1])/s;
   result.y:=s*0.25;
   result.z:=(RawComponents[2,1]+RawComponents[1,2])/s;
   result.w:=(RawComponents[2,0]-RawComponents[0,2])/s;
  end else begin
   s:=sqrt(1.0+(RawComponents[2,2]-(RawComponents[0,0]+RawComponents[1,1])))*2.0;
   result.x:=(RawComponents[2,0]+RawComponents[0,2])/s;
   result.y:=(RawComponents[2,1]+RawComponents[1,2])/s;
   result.z:=s*0.25;
   result.w:=(RawComponents[0,1]-RawComponents[1,0])/s;
  end;
  QuaternionNormalize(result);
 end;
 begin
  // Make sure, that we don't end up with 0 as w component
  if abs(result.w)<=Threshold then begin
   Renormalization:=sqrt(1.0-sqr(Threshold));
   result.x:=result.x*Renormalization;
   result.y:=result.y*Renormalization;
   result.z:=result.z*Renormalization;
   if result.w>0.0 then begin
    result.w:=Threshold;
   end else begin
    result.w:=-Threshold;
   end;
  end;
 end;
 if ((Scale<0.0) and (result.w>=0.0)) or ((Scale>=0.0) and (result.w<0.0)) then begin
  // Encode reflection into quaternion's w element by making sign of w negative,
  // if y axis needs to be flipped, otherwise it stays positive
  result.x:=-result.x;
  result.y:=-result.y;
  result.z:=-result.z;
  result.w:=-result.w;
 end;
end;

procedure SaveMDL;
const HashSize=65536;
      HashMask=HashSize-1;
      HashShift=16;
type PSignature=^TSignature;
     TSignature=array[0..3] of ansichar;
     PCacheVector2=^TCacheVector2;
     TCacheVector2=record
      Next:longint;
      Vector:TVector2;
     end;
     PWriteVector3=^TWriteVector3;
     TWriteVector3=record
      Next:longint;
      Vector:TVector3;
     end;
     PCacheVertex=^TCacheVertex;
     TCacheVertex=record
      Next:longint;
      Vertex:TVertex;
     end;
     PChunk=^TChunk;
     TChunk=packed record
      Signature:TSignature;
      Offset:longint;
      Size:longint;
      Reserved:longword;
     end;
     TChunks=array of TChunk;
const Signature:TSignature=('m','d','l',#0);
var Chunks:TChunks;
    CountChunks:longint;
    fs,ms:TStream;
    {Index,}BufferPartIndex,VertexBufferIndex,ObjectIndex,MeshIndex,TriangleIndex,VertexIndex,
    MaterialIndex,i32:longint;
    ui32:longword;
{   ui16:word;
    b8:byte;}
    VertexBuffer:PVertexBuffer;
    Material:PMaterial;
    AObject:PModelObject;
    Mesh:PMesh;
//  Triangle:PTriangle;
//  Vertex:PVertex;
    ChunkOffset,OldOffset,NewOffset:int64;
{   Matrix3x3:TMatrix3x3;
    Quaternion:TQuaternion;}
 function StartChunk(const ChunkSignature:TSignature):int64;
 var Dummy:longint;
 begin
  Dummy:=0;
  ms.Write(ChunkSignature,SizeOf(TSignature));
  result:=ms.Position;
  ms.Write(Dummy,SizeOf(longint));
  if (CountChunks+1)>length(Chunks) then begin
   SetLength(Chunks,(CountChunks+1)*2);
  end;
  Chunks[CountChunks].Signature:=ChunkSignature;
  Chunks[CountChunks].Offset:=ms.Position;
  Chunks[CountChunks].Size:=0;
  Chunks[CountChunks].Reserved:=0;
  inc(CountChunks);
 end;
 procedure EndChunk(Offset:int64);
 var Last:int64;
     Len:longint;
 begin
  Last:=ms.Position;
  Len:=Last-(Offset+SizeOf(longint));
  ms.Seek(Offset,soBeginning);
  ms.Write(Len,SizeOf(longint));
  ms.Seek(Last,soBeginning);
  Chunks[CountChunks-1].Size:=Len;
 end;
 procedure WriteString(const s:ansistring);
 var Len:longint;
 begin
  Len:=length(s);
  ms.Write(Len,SizeOf(longint));
  if Len>0 then begin
   ms.Write(s[1],Len*SizeOf(AnsiChar));
  end;
 end;
 procedure WriteVector2(const v:TVector2);
 begin
  ms.Write(v.x,SizeOf(single));
  ms.Write(v.y,SizeOf(single));
 end;
 procedure WriteVector3(const v:TVector3);
 begin
  ms.Write(v.x,SizeOf(single));
  ms.Write(v.y,SizeOf(single));
  ms.Write(v.z,SizeOf(single));
 end;
 procedure WriteVector4(const v:TVector4);
 begin
  ms.Write(v.x,SizeOf(single));
  ms.Write(v.y,SizeOf(single));
  ms.Write(v.z,SizeOf(single));
  ms.Write(v.w,SizeOf(single));
 end;
 procedure WriteQuaternion(const v:TQuaternion);
 var w:smallint;
 begin
  w:=Min(Max(round(Min(Max(v.x,-1.0),1.0)*32767),-32767),32767);
  ms.Write(w,SizeOf(smallint));
  w:=Min(Max(round(Min(Max(v.y,-1.0),1.0)*32767),-32767),32767);
  ms.Write(w,SizeOf(smallint));
  w:=Min(Max(round(Min(Max(v.z,-1.0),1.0)*32767),-32767),32767);
  ms.Write(w,SizeOf(smallint));
  w:=Min(Max(round(Min(Max(v.w,-1.0),1.0)*32767),-32767),32767);
  ms.Write(w,SizeOf(smallint));
 end;
 procedure WritePlane(const p:TPlane);
 begin
  ms.Write(p.a,SizeOf(single));
  ms.Write(p.b,SizeOf(single));
  ms.Write(p.c,SizeOf(single));
  ms.Write(p.d,SizeOf(single));
 end;
 procedure WriteFloat(const v:single);
 begin
  ms.Write(v,SizeOf(single));
 end;
 procedure WriteInteger(const v:longint);
 begin
  ms.Write(v,SizeOf(longint));
 end;
 procedure WriteVertex(const Vertex:TVertex);
 var c:array[0..3] of byte;
     lw:longword;
     m:TMatrix3x3;
     q:TQuaternion;
 begin
  m[0,0]:=Vertex.Tangent.x;
  m[0,1]:=Vertex.Tangent.y;
  m[0,2]:=Vertex.Tangent.z;
  m[1,0]:=Vertex.Bitangent.x;
  m[1,1]:=Vertex.Bitangent.y;
  m[1,2]:=Vertex.Bitangent.z;
  m[2,0]:=Vertex.Normal.x;
  m[2,1]:=Vertex.Normal.y;
  m[2,2]:=Vertex.Normal.z;
  q:=Matrix3x3ToQTangent(m);
  WriteVector3(Vertex.Position);   // 12 bytes
  WriteQuaternion(q);              // 8 bytes
  WriteVector2(Vertex.TexCoord);   // 8 bytes
  WriteInteger(Vertex.Material);   // 4 bytes
 end;                              // 32 bytes in sum
begin
 Chunks:=nil;
 CountChunks:=0;
 try
  ms:=TMemoryStream.Create;
  try
   begin
    ms.Write(Signature,SizeOf(TSignature));
    ui32:=0;
    ms.Write(ui32,SizeOf(longword));
    i32:=0;
    ms.Write(i32,SizeOf(longint));
    i32:=0;
    ms.Write(i32,SizeOf(longint));
    begin
     ChunkOffset:=StartChunk('BOVO');

     WriteVector3(Sphere.Center);

     ms.Write(Sphere.Radius,SizeOf(single));

     WriteVector3(AABB.Min);

     WriteVector3(AABB.Max);

     EndChunk(ChunkOffset);
    end;
    begin
     ChunkOffset:=StartChunk('MATE');
     i32:=length(Materials);
     ms.Write(i32,SizeOf(longint));
     for MaterialIndex:=0 to length(Materials)-1 do begin
      Material:=@Materials[MaterialIndex];
      WriteString(Material^.Name);
      WriteString(Material^.Texture);
      WriteVector3(Material^.Ambient);
      WriteVector3(Material^.Diffuse);
      WriteVector3(Material^.Emission);
      WriteVector3(Material^.Specular);
      WriteFloat(Material^.Shininess);
     end;
     EndChunk(ChunkOffset);
    end;
    begin
     ChunkOffset:=StartChunk('VBOS');

     OldOffset:=ms.Position;
     i32:=CountVBOVertices;
     ms.Write(i32,SizeOf(longint));

     for VertexIndex:=0 to CountVBOVertices-1 do begin
      WriteVertex(VBOVertices[VertexIndex]);
     end;

     EndChunk(ChunkOffset);
    end;
    begin
     ChunkOffset:=StartChunk('IBOS');

     OldOffset:=ms.Position;
     i32:=CountIBOIndices;
     ms.Write(i32,SizeOf(longint));

     ms.Write(IBOIndices[0],CountIBOIndices*SizeOf(longword));

     EndChunk(ChunkOffset);
    end;
    begin
     ChunkOffset:=StartChunk('PART');

     i32:=length(VertexBuffers);
     ms.Write(i32,SizeOf(longint));

     for VertexBufferIndex:=0 to length(VertexBuffers)-1 do begin
      VertexBuffer:=@VertexBuffers[VertexBufferIndex];

      i32:=VertexBuffer^.MaterialIndex;
      ms.Write(i32,SizeOf(longint));

      i32:=VertexBuffer^.StartIndex;
      ms.Write(i32,SizeOf(longint));

      i32:=VertexBuffer^.CountIndices;
      ms.Write(i32,SizeOf(longint));

     end;

     EndChunk(ChunkOffset);
    end;
    begin
     ChunkOffset:=StartChunk('OBJS');
     i32:=length(ModelObjects);
     ms.Write(i32,SizeOf(longint));
     for ObjectIndex:=0 to length(ModelObjects)-1 do begin
      AObject:=@ModelObjects[ObjectIndex];

      WriteString(AObject^.Name);

      WriteVector3(AObject^.Sphere.Center);

      ms.Write(AObject^.Sphere.Radius,SizeOf(single));

      WriteVector3(AObject^.AABB.Min);

      WriteVector3(AObject^.AABB.Max);

     end;
     EndChunk(ChunkOffset);
    end;
    begin
     ChunkOffset:=StartChunk('COHU');
     ConvexHullStream.Seek(0,soBeginning);
     ms.CopyFrom(ConvexHullStream,ConvexHullStream.Size);
     EndChunk(ChunkOffset);
    end;
    begin
     if CountChunks>0 then begin
      ms.Seek(SizeOf(TSignature)+SizeOf(longword),soBeginning);
      i32:=CountChunks;
      ms.Write(i32,SizeOf(longint));
      i32:=ms.Size;
      ms.Write(i32,SizeOf(longint));
      ms.Seek(ms.Size,soBeginning);
      ms.Write(Chunks[0],CountChunks*SizeOf(TChunk));
     end;
    end;
   end;
   fs:=TFileStream.Create(OutputFileName,fmCreate);
   try
    ms.Seek(0,soBeginning);
    fs.CopyFrom(ms,ms.Size);
   finally
    fs.Free;
   end;
  finally
   ms.Free;
  end;
 finally
  SetLength(Chunks,0);
 end;
end;

function DoubleToStr(v:double):ansistring;
begin
 result:=ConvertDoubleToString(v,omSTANDARD,0);
end;

begin
 Materials:=nil;
 ModelObjects:=nil;
 VBOVertices:=nil;
 IBOIndices:=nil;
 CountVBOVertices:=0;
 CountIBOIndices:=0;
 ConvexHullStream:=TMemoryStream.Create;
 try
  if ParamCount>=2 then begin
   InputFileName:=ParamStr(1);
   OutputFileName:=ParamStr(2);

   write('Loading COLLADA .DAE file... ');
   LoadDAE;
   writeln('done!');

   writeln('Model AABB: (',DoubleToStr(AABB.Min.x),',',DoubleToStr(AABB.Min.y),',',DoubleToStr(AABB.Min.z),'),(',DoubleToStr(AABB.Max.x),',',DoubleToStr(AABB.Max.y),',',DoubleToStr(AABB.Max.z),')');
   writeln('Model AABB size: (',DoubleToStr(AABB.Max.x-AABB.Min.x),',',DoubleToStr(AABB.Max.y-AABB.Min.y),',',DoubleToStr(AABB.Max.z-AABB.Min.z),')');

   write('Optimizing model for vertex cache... ');
   OptimizeModelForVertexCache;
   writeln('done!');

   write('Building vertex and index buffers... ');
   BuildVertexAndIndexBuffers;
   writeln('done!');

   write('Building collision convex hull... ');
   BuildConvexHull;
   writeln('done!');

   write('Writing .MDL file... ');
   SaveMDL;
   writeln('done!');

  end;
 finally
  ConvexHullStream.Free;
  Materials:=nil;
  ModelObjects:=nil;
  VBOVertices:=nil;
  IBOIndices:=nil;
 end;
end.
