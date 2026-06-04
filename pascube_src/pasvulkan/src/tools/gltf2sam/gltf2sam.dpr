program gltf2sam;
{$ifdef fpc}
 {$mode delphi}
{$endif}

uses Classes,
     SysUtils,
     Math,
     PUCU in '../../../externals/pucu/src/PUCU.pas',
     PasMP in '../../../externals/pasmp/src/PasMP.pas',
     PasDblStrUtils in '../../../externals/pasdblstrutils/src/PasDblStrUtils.pas',
     PasJSON in '../../../externals/pasjson/src/PasJSON.pas',
     PasGLTF in '../../../externals/pasgltf/src/PasGLTF.pas',
     Vulkan in '../../Vulkan.pas',
     PasVulkan.Types in '../../PasVulkan.Types.pas',
     PasVulkan.Utils in '../../PasVulkan.Utils.pas',
     PasVulkan.Math in '../../PasVulkan.Math.pas',
     PasVulkan.Collections in '../../PasVulkan.Collections.pas',
     PasVulkan.FileFormats.GLTF in '../../PasVulkan.FileFormats.GLTF.pas',
     PasVulkan.FileFormats.SAM in '../../PasVulkan.FileFormats.SAM.pas';

var SAM:TpvSAM.TModel;
    
    CountUsedVertices:TpvSizeInt;
    CountUsedIndices:TpvSizeInt;

    FrameRate:TpvDouble=10.0;

    GLTF:TpvGLTF;
    GLTFInstance:TpvGLTF.TInstance;

    FileHeader:TpvSAM.TFileHeader;

    BoundingBox:TpvAABB;

    BoundingSphere:TpvSphere;

    BaseColorTextureData:TBytes;
    NormalTextureData:TBytes;
    MetallicRoughnessTextureData:TBytes;
    OcclusionTextureData:TBytes;
    EmissiveTextureData:TBytes;
    
function CompareFramesByTime(const a,b:TpvSAM.TFrame):TpvInt32;
begin
 result:=Sign(a.Time-b.Time);
end;

function OptimizeFrames(var aTimeFrames:TpvSAM.TFrames;out aFrames:TpvSAM.TFrames;const aFrameRate:TpvDouble):boolean;
var FrameIndex,CurrentFrameIndex,NextFrameIndex,OutFrameIndex,VertexIndex,
    CountTargetFrames:TpvSizeInt;
    StartTime,EndTime,Time,TimeStep,InterpolationFactor:TpvDouble;
    CurrentFrame,NextFrame:TpvSAM.PFrame;
    CurrentVertex,NextVertex,InterpolatedVertex:TpvSAM.PFullVertex;
    CurrentTangent,CurrentBitangent,CurrentNormal,
    NextTangent,NextBitangent,NextNormal,
    InterpolatedTangent,InterpolatedBitangent,InterpolatedNormal:TpvVector3;
    CurrentTangentSpace,NextTangentSpace,InterpolatedTangentSpace:TpvMatrix3x3;
begin

 if length(aTimeFrames)=0 then begin
  result:=false;
  exit;
 end;

 // Sort time frames
 TpvTypedSort<TpvSAM.TFrame>.IntroSort(@aTimeFrames[0],0,length(aTimeFrames)-1,CompareFramesByTime);

 // Find start and end time
 StartTime:=aTimeFrames[0].Time;
 EndTime:=aTimeFrames[length(aTimeFrames)-1].Time;

 // Calculate time step
 TimeStep:=1.0/aFrameRate;

 // Calculate count of frames
 CountTargetFrames:=Ceil((EndTime-StartTime)/TimeStep);

 // Normalize time frames
 aFrames:=nil;
 SetLength(aFrames,CountTargetFrames);
 Time:=StartTime;
 FrameIndex:=0;
 OutFrameIndex:=0;
 while (Time<(EndTime+TimeStep)) and (OutFrameIndex<CountTargetFrames) do begin

  aFrames[OutFrameIndex].Time:=Time;
  aFrames[OutFrameIndex].Vertices:=nil;
  aFrames[OutFrameIndex].FullVertices:=nil;
  SetLength(aFrames[OutFrameIndex].Vertices,CountUsedVertices);
  SetLength(aFrames[OutFrameIndex].FullVertices,CountUsedVertices);

  // Advance to next frame
  while (FrameIndex<length(aTimeFrames)) and (aTimeFrames[FrameIndex].Time<Time) do begin
   inc(FrameIndex);
  end;

  // Get current and next frame indices
  CurrentFrameIndex:=FrameIndex; 
  NextFrameIndex:=Min(CurrentFrameIndex+1,length(aTimeFrames)-1);

  // Get current and next frame pointers  
  CurrentFrame:=@aTimeFrames[CurrentFrameIndex];
  NextFrame:=@aTimeFrames[NextFrameIndex];

  // Interpolate between current and next frame
  InterpolationFactor:=(Time-aTimeFrames[CurrentFrameIndex].Time)/(aTimeFrames[NextFrameIndex].Time-aTimeFrames[CurrentFrameIndex].Time);
  for VertexIndex:=0 to CountUsedVertices-1 do begin
   
   CurrentVertex:=@CurrentFrame^.FullVertices[VertexIndex];
   NextVertex:=@NextFrame^.FullVertices[VertexIndex];

   InterpolatedVertex:=@aFrames[OutFrameIndex].FullVertices[VertexIndex];
   
   InterpolatedVertex^.Position:=CurrentVertex^.Position.Lerp(NextVertex^.Position,InterpolationFactor);

{  InterpolatedVertex^.TexCoordU:=Min(Max(round((CurrentVertex^.TexCoordU*(1.0-InterpolationFactor))+(NextVertex^.TexCoordU*InterpolationFactor)),0),65535);
   InterpolatedVertex^.TexCoordV:=Min(Max(round((CurrentVertex^.TexCoordV*(1.0-InterpolationFactor))+(NextVertex^.TexCoordV*InterpolationFactor)),0),65535);}

   CurrentTangentSpace:=TpvMatrix3x3.Create(CurrentVertex^.Tangent,CurrentVertex^.Bitangent,CurrentVertex^.Normal);
   
   NextTangentSpace:=TpvMatrix3x3.Create(NextVertex^.Tangent,NextVertex^.Bitangent,NextVertex^.Normal);

   InterpolatedTangentSpace:=CurrentTangentSpace.Slerp(NextTangentSpace,InterpolationFactor);

   InterpolatedVertex^.Tangent:=InterpolatedTangentSpace.Tangent;
   InterpolatedVertex^.Bitangent:=InterpolatedTangentSpace.Bitangent;
   InterpolatedVertex^.Normal:=InterpolatedTangentSpace.Normal;

  end; 

  Time:=Time+TimeStep; 

  inc(OutFrameIndex);

 end;

end;

function GetAnimation(const aAnimationIndex:TpvSizeInt):TpvSAM.TAnimation;
var FrameIndex,VertexIndex,CountFrames:TpvSizeInt;
    KeyTimes:TPasGLTFDoubleDynamicArray;
    GLTFBakedVertexIndexedMesh:TpvGLTF.TBakedVertexIndexedMesh;
    GLTFBakedVertexIndexedMeshVertex:TpvGLTF.PVertex;
    Vertex:TpvSAM.PFullVertex;
    Frames:TpvSAM.TFrames;
begin

 result.Name:='';
 result.StartTime:=0.0;
 result.EndTime:=0.0;
 result.Frames:=nil;

 if aAnimationIndex<0 then begin

  SetLength(result.Frames,1);

  GLTFInstance.Animation:=-1;

  GLTFInstance.AnimationTime:=0.0;

  GLTFInstance.Update;

  FrameIndex:=0;

  result.Frames[FrameIndex].Time:=0.0;

  GLTFBakedVertexIndexedMesh:=GLTFInstance.GetBakedVertexIndexedMesh(false,true,-1,[TPasGLTF.TMaterial.TAlphaMode.Opaque,TPasGLTF.TMaterial.TAlphaMode.Blend,TPasGLTF.TMaterial.TAlphaMode.Mask]);
  if assigned(GLTFBakedVertexIndexedMesh) then begin

   try

    if length(result.Frames[FrameIndex].Vertices)<>GLTFBakedVertexIndexedMesh.Vertices.Count then begin
     SetLength(result.Frames[FrameIndex].Vertices,GLTFBakedVertexIndexedMesh.Vertices.Count);
    end;

    if length(result.Frames[FrameIndex].FullVertices)<>GLTFBakedVertexIndexedMesh.Vertices.Count then begin
     SetLength(result.Frames[FrameIndex].FullVertices,GLTFBakedVertexIndexedMesh.Vertices.Count);
    end;

    for VertexIndex:=0 to GLTFBakedVertexIndexedMesh.Vertices.Count-1 do begin

     GLTFBakedVertexIndexedMeshVertex:=@GLTFBakedVertexIndexedMesh.Vertices.ItemArray[VertexIndex];

     Vertex:=@result.Frames[FrameIndex].FullVertices[VertexIndex];

     Vertex^.Position:=TpvVector3.Create(GLTFBakedVertexIndexedMeshVertex^.Position[0],GLTFBakedVertexIndexedMeshVertex^.Position[1],GLTFBakedVertexIndexedMeshVertex^.Position[2]);

{    Vertex^.TexCoordU:=Min(Max(round(GLTFBakedVertexIndexedMeshVertex^.TexCoord0[0]*16384.0),0),65535);
     Vertex^.TexCoordV:=Min(Max(round(GLTFBakedVertexIndexedMeshVertex^.TexCoord0[1]*16384.0),0),65535);}

     Vertex^.Tangent:=TpvVector3.Create(GLTFBakedVertexIndexedMeshVertex^.Tangent[0],GLTFBakedVertexIndexedMeshVertex^.Tangent[1],GLTFBakedVertexIndexedMeshVertex^.Tangent[2]);
     Vertex^.Bitangent:=(TpvVector3.Create(GLTFBakedVertexIndexedMeshVertex^.Normal[0],GLTFBakedVertexIndexedMeshVertex^.Normal[1],GLTFBakedVertexIndexedMeshVertex^.Normal[2]).Cross(TpvVector3.Create(GLTFBakedVertexIndexedMeshVertex^.Tangent[0],GLTFBakedVertexIndexedMeshVertex^.Tangent[1],GLTFBakedVertexIndexedMeshVertex^.Tangent[2])))*GLTFBakedVertexIndexedMeshVertex^.Tangent[3];
     Vertex^.Normal:=TpvVector3.Create(GLTFBakedVertexIndexedMeshVertex^.Normal[0],GLTFBakedVertexIndexedMeshVertex^.Normal[1],GLTFBakedVertexIndexedMeshVertex^.Normal[2]);

    end;

   finally
    FreeAndNil(GLTFBakedVertexIndexedMesh);
   end;
  end;

 end else if (aAnimationIndex>=0) and (aAnimationIndex<length(GLTF.Animations)) then begin

  Frames:=nil;
  try

   result.Name:=GLTF.Animations[aAnimationIndex].Name;

   KeyTimes:=GLTF.GetAnimationTimes(aAnimationIndex);
   if length(KeyTimes)>0 then begin

    try

     CountFrames:=length(KeyTimes);

     result.StartTime:=KeyTimes[0];
     result.EndTime:=KeyTimes[length(KeyTimes)-1];

     SetLength(Frames,CountFrames);

     for FrameIndex:=0 to CountFrames-1 do begin

      GLTFInstance.Animation:=aAnimationIndex;

      GLTFInstance.AnimationTime:=KeyTimes[FrameIndex];

      GLTFInstance.Update;

      Frames[FrameIndex].Time:=GLTFInstance.AnimationTime;

      GLTFBakedVertexIndexedMesh:=GLTFInstance.GetBakedVertexIndexedMesh(false,true,-1,[TPasGLTF.TMaterial.TAlphaMode.Opaque,TPasGLTF.TMaterial.TAlphaMode.Blend,TPasGLTF.TMaterial.TAlphaMode.Mask]);
      if assigned(GLTFBakedVertexIndexedMesh) then begin

       try

        if length(Frames[FrameIndex].Vertices)<>GLTFBakedVertexIndexedMesh.Vertices.Count then begin
         SetLength(Frames[FrameIndex].Vertices,GLTFBakedVertexIndexedMesh.Vertices.Count);
        end;

        if length(Frames[FrameIndex].FullVertices)<>GLTFBakedVertexIndexedMesh.Vertices.Count then begin
         SetLength(Frames[FrameIndex].FullVertices,GLTFBakedVertexIndexedMesh.Vertices.Count);
        end;

        for VertexIndex:=0 to GLTFBakedVertexIndexedMesh.Vertices.Count-1 do begin

         GLTFBakedVertexIndexedMeshVertex:=@GLTFBakedVertexIndexedMesh.Vertices.ItemArray[VertexIndex];

         Vertex:=@Frames[FrameIndex].FullVertices[VertexIndex];

         Vertex^.Position:=TpvVector3.Create(GLTFBakedVertexIndexedMeshVertex^.Position[0],GLTFBakedVertexIndexedMeshVertex^.Position[1],GLTFBakedVertexIndexedMeshVertex^.Position[2]);

 {       Vertex^.TexCoordU:=Min(Max(round(GLTFBakedVertexIndexedMeshVertex^.TexCoord0[0]*16384.0),0),65535);
         Vertex^.TexCoordV:=Min(Max(round(GLTFBakedVertexIndexedMeshVertex^.TexCoord0[1]*16384.0),0),65535);}

         Vertex^.Tangent:=TpvVector3.Create(GLTFBakedVertexIndexedMeshVertex^.Tangent[0],GLTFBakedVertexIndexedMeshVertex^.Tangent[1],GLTFBakedVertexIndexedMeshVertex^.Tangent[2]);
         Vertex^.Bitangent:=(TpvVector3.Create(GLTFBakedVertexIndexedMeshVertex^.Normal[0],GLTFBakedVertexIndexedMeshVertex^.Normal[1],GLTFBakedVertexIndexedMeshVertex^.Normal[2]).Cross(TpvVector3.Create(GLTFBakedVertexIndexedMeshVertex^.Tangent[0],GLTFBakedVertexIndexedMeshVertex^.Tangent[1],GLTFBakedVertexIndexedMeshVertex^.Tangent[2])))*GLTFBakedVertexIndexedMeshVertex^.Tangent[3];
         Vertex^.Normal:=TpvVector3.Create(GLTFBakedVertexIndexedMeshVertex^.Normal[0],GLTFBakedVertexIndexedMeshVertex^.Normal[1],GLTFBakedVertexIndexedMeshVertex^.Normal[2]);

        end;

       finally
        FreeAndNil(GLTFBakedVertexIndexedMesh);
       end;
      end;

     end;

    finally
     KeyTimes:=nil;
    end;

   end;

   OptimizeFrames(Frames,result.Frames,FrameRate);

  finally
   Frames:=nil;
  end;

 end;    

end;

function ConvertModel(const aInputFileName,aOutputFileName:String):boolean;
var Index,FrameIndex,VertexIndex,BaseColorTextureIndex,NormalTextureIndex,
    MetallicRoughnessTextureIndex,OcclusionTextureIndex,EmissiveTextureIndex,
    ImageIndex,MaterialIndex:TpvSizeInt;
    CountFrames,ui32:TpvUInt32;
    GLTFBakedVertexIndexedMesh:TpvGLTF.TBakedVertexIndexedMesh;
    GLTFMaterial:TpvGLTF.PMaterial;
    SAMMaterial:TpvSAM.TMaterial;
    Stream:TMemoryStream;
    BaseColorFactor:TpvVector4;
    MetallicRoughnessFactor:TpvVector2;
    NormalScale,OcclusionStrength,AlphaCutOff:TpvFloat;
    EmissiveFactor:TpvVector4;
    First:boolean;
    GLTFBakedVertexIndexedMeshVertex:TpvGLTF.PVertex;
begin

 result:=true;

{$if declared(SetExceptionMask)}
 SetExceptionMask([exInvalidOp,exDenormalized,exZeroDivide,exOverflow,exUnderflow,exPrecision]);
{$ifend}

 SAM:=TpvSAM.TModel.Create;
 try
 
  GLTF:=TpvGLTF.Create;
  try

   GLTF.LoadFromFile(aInputFileName);

   GLTF.Upload;

   GLTFInstance:=GLTF.AcquireInstance;
   try

    GLTFInstance.Upload;

    if length(GLTF.Animations)>0 then begin

     // Get indices for all animations once for all in advance
     begin

      GLTFInstance.Animation:=-1;
      GLTFInstance.AnimationTime:=0;
      GLTFInstance.Update;

      GLTFBakedVertexIndexedMesh:=GLTFInstance.GetBakedVertexIndexedMesh(false,true,-1,[TPasGLTF.TMaterial.TAlphaMode.Opaque,TPasGLTF.TMaterial.TAlphaMode.Blend,TPasGLTF.TMaterial.TAlphaMode.Mask]);
      if assigned(GLTFBakedVertexIndexedMesh) then begin

       try

        CountUsedVertices:=GLTFBakedVertexIndexedMesh.Vertices.Count;
        SetLength(SAM.VertexTexCoords,CountUsedVertices);
        SetLength(SAM.VertexMaterials,CountUsedVertices);
        for VertexIndex:=0 to GLTFBakedVertexIndexedMesh.Vertices.Count-1 do begin
         GLTFBakedVertexIndexedMeshVertex:=@GLTFBakedVertexIndexedMesh.Vertices.ItemArray[VertexIndex];
         SAM.VertexTexCoords[VertexIndex].x:=Min(Max(round(GLTFBakedVertexIndexedMeshVertex^.TexCoord0[0]*16384.0),0),65535);
         SAM.VertexTexCoords[VertexIndex].y:=Min(Max(round(GLTFBakedVertexIndexedMeshVertex^.TexCoord0[1]*16384.0),0),65535);
         SAM.VertexMaterials[VertexIndex]:=GLTFBakedVertexIndexedMesh.Materials.ItemArray[VertexIndex];
        end;

        CountUsedIndices:=GLTFBakedVertexIndexedMesh.Indices.Count;
        SetLength(SAM.Indices,GLTFBakedVertexIndexedMesh.Indices.Count);
        for Index:=0 to GLTFBakedVertexIndexedMesh.Indices.Count-1 do begin
         SAM.Indices[Index]:=GLTFBakedVertexIndexedMesh.Indices.ItemArray[Index];
        end;

       finally
        FreeAndNil(GLTFBakedVertexIndexedMesh);
       end;

      end else begin
       WriteLn('Error: No vertex indexed mesh found!');
       result:=false;
      end;

     end;

     if result then begin
     
      // Get materials
      for MaterialIndex:=0 to length(GLTF.Materials)-1 do begin
       SAMMaterial:=TpvSAM.TMaterial.Create;
       try

        SAMMaterial.Name:=GLTF.Materials[MaterialIndex].Name;

        BaseColorTextureIndex:=-1;
        NormalTextureIndex:=-1;
        MetallicRoughnessTextureIndex:=-1;
        OcclusionTextureIndex:=-1;
        EmissiveTextureIndex:=-1;
        BaseColorFactor:=TpvVector4.Create(1.0,1.0,1.0,1.0);
        MetallicRoughnessFactor:=TpvVector2.Create(1.0,1.0);
        NormalScale:=1.0;
        OcclusionStrength:=1.0;
        AlphaCutOff:=1.0;
        EmissiveFactor:=TpvVector4.Create(0.0,0.0,0.0,1.0);

        GLTFMaterial:=@GLTF.Materials[MaterialIndex];

        BaseColorFactor:=TpvVector4(Pointer(@GLTFMaterial^.PBRMetallicRoughness.BaseColorFactor)^);
        BaseColorTextureIndex:=GLTFMaterial^.PBRMetallicRoughness.BaseColorTexture.Index;
        NormalTextureIndex:=GLTFMaterial^.NormalTexture.Index;
        MetallicRoughnessFactor:=TpvVector2.Create(GLTFMaterial^.PBRMetallicRoughness.MetallicFactor,GLTFMaterial^.PBRMetallicRoughness.RoughnessFactor);
        MetallicRoughnessTextureIndex:=GLTFMaterial^.PBRMetallicRoughness.MetallicRoughnessTexture.Index;
        OcclusionTextureIndex:=GLTFMaterial^.OcclusionTexture.Index;
        NormalScale:=GLTFMaterial^.NormalTextureScale;
        OcclusionStrength:=GLTFMaterial^.OcclusionTextureStrength;
        AlphaCutOff:=GLTFMaterial^.AlphaCutOff;
        EmissiveTextureIndex:=GLTFMaterial^.EmissiveTexture.Index;
        EmissiveFactor:=TpvVector4(Pointer(@GLTFMaterial^.EmissiveFactor)^);

        SAMMaterial.MaterialHeader.BaseColorTextureSize:=0;
        if BaseColorTextureIndex>=0 then begin
         ImageIndex:=GLTF.Textures[BaseColorTextureIndex].Image;
         if ImageIndex>=0 then begin
          BaseColorTextureData:=GLTF.Images[ImageIndex].Data;
          SAMMaterial.BaseColorTextureStream.Clear;
          SAMMaterial.BaseColorTextureStream.WriteBuffer(BaseColorTextureData[0],length(BaseColorTextureData));
          SAMMaterial.MaterialHeader.BaseColorTextureSize:=length(BaseColorTextureData);
         end;
        end;

        SAMMaterial.MaterialHeader.NormalTextureSize:=0;
        if NormalTextureIndex>=0 then begin
         ImageIndex:=GLTF.Textures[NormalTextureIndex].Image;
         if ImageIndex>=0 then begin
          NormalTextureData:=GLTF.Images[ImageIndex].Data;
          SAMMaterial.NormalTextureStream.Clear;
          SAMMaterial.NormalTextureStream.WriteBuffer(NormalTextureData[0],length(NormalTextureData));
          SAMMaterial.MaterialHeader.NormalTextureSize:=length(NormalTextureData);
         end;
        end;

        SAMMaterial.MaterialHeader.MetallicRoughnessTextureSize:=0;
        if MetallicRoughnessTextureIndex>=0 then begin
         ImageIndex:=GLTF.Textures[MetallicRoughnessTextureIndex].Image;
         if ImageIndex>=0 then begin
          MetallicRoughnessTextureData:=GLTF.Images[ImageIndex].Data;
          SAMMaterial.MetallicRoughnessTextureStream.Clear;
          SAMMaterial.MetallicRoughnessTextureStream.WriteBuffer(MetallicRoughnessTextureData[0],length(MetallicRoughnessTextureData));
          SAMMaterial.MaterialHeader.MetallicRoughnessTextureSize:=length(MetallicRoughnessTextureData);
         end;
        end;

        SAMMaterial.MaterialHeader.OcclusionTextureSize:=0;
        if OcclusionTextureIndex>=0 then begin
         ImageIndex:=GLTF.Textures[OcclusionTextureIndex].Image;
         if ImageIndex>=0 then begin
          OcclusionTextureData:=GLTF.Images[ImageIndex].Data;
          SAMMaterial.OcclusionTextureStream.Clear;
          SAMMaterial.OcclusionTextureStream.WriteBuffer(OcclusionTextureData[0],length(OcclusionTextureData));
          SAMMaterial.MaterialHeader.OcclusionTextureSize:=length(OcclusionTextureData);
         end;
        end;

        SAMMaterial.MaterialHeader.EmissiveTextureSize:=0;
        if EmissiveTextureIndex>=0 then begin
         ImageIndex:=GLTF.Textures[EmissiveTextureIndex].Image;
         if ImageIndex>=0 then begin
          EmissiveTextureData:=GLTF.Images[ImageIndex].Data;
          SAMMaterial.EmissiveTextureStream.Clear;
          SAMMaterial.EmissiveTextureStream.WriteBuffer(EmissiveTextureData[0],length(EmissiveTextureData));
          SAMMaterial.MaterialHeader.EmissiveTextureSize:=length(EmissiveTextureData);
         end;
        end;

        case GLTFMaterial^.ShadingModel of
         TpvGLTF.TMaterial.TShadingModel.PBRMetallicRoughness:begin
          SAMMaterial.MaterialHeader.MaterialType:=TpvSAM.TMaterialHeader.MaterialTypeMetallicRoughness;
         end;
         else begin
          SAMMaterial.MaterialHeader.MaterialType:=TpvSAM.TMaterialHeader.MaterialTypeUnlit;
         end;
        end;

        case GLTFMaterial^.AlphaMode of
         TPasGLTF.TMaterial.TAlphaMode.Mask:begin
          SAMMaterial.MaterialHeader.AlphaModeFlags:=TpvSAM.TMaterialHeader.AlphaModeMask;
         end;
         TPasGLTF.TMaterial.TAlphaMode.Blend:begin
          SAMMaterial.MaterialHeader.AlphaModeFlags:=TpvSAM.TMaterialHeader.AlphaModeBlend;
         end;
         else begin
          SAMMaterial.MaterialHeader.AlphaModeFlags:=TpvSAM.TMaterialHeader.AlphaModeOpaque;
         end;
        end;

        if GLTFMaterial^.DoubleSided then begin
         SAMMaterial.MaterialHeader.AlphaModeFlags:=SAMMaterial.MaterialHeader.AlphaModeFlags or TpvSAM.TMaterialHeader.FlagDoubleSided;
        end;

        SAMMaterial.MaterialHeader.BaseColorFactor:=BaseColorFactor;
        SAMMaterial.MaterialHeader.EmissiveFactor:=TpvVector4.Create(EmissiveFactor.x,EmissiveFactor.y,EmissiveFactor.z,EmissiveFactor.w);
        SAMMaterial.MaterialHeader.OcclusionStrength:=OcclusionStrength;
        SAMMaterial.MaterialHeader.MetallicFactor:=MetallicRoughnessFactor.x;
        SAMMaterial.MaterialHeader.RoughnessFactor:=MetallicRoughnessFactor.y;
        SAMMaterial.MaterialHeader.NormalScale:=NormalScale;
        SAMMaterial.MaterialHeader.AlphaCutOff:=AlphaCutOff;

       finally
        SAM.Materials.Add(SAMMaterial);
       end;
      end;

      if SAM.Materials.Count=0 then begin
       WriteLn('Error: No materials found!');
       result:=false;
      end;

     end; 

     if result then begin

      // Get all animations
      SetLength(SAM.Animations,length(GLTF.Animations)+1);
      SAM.Animations[0]:=GetAnimation(-1);
      for Index:=0 to length(GLTF.Animations)-1 do begin
       SAM.Animations[Index+1]:=GetAnimation(Index);
      end;

      // Get bounding box
      First:=true;
      for Index:=0 to length(SAM.Animations)-1 do begin
       for FrameIndex:=0 to length(SAM.Animations[Index].Frames)-1 do begin
        for VertexIndex:=0 to CountUsedVertices-1 do begin
         if First then begin
          First:=false;
          BoundingBox.Min:=SAM.Animations[Index].Frames[FrameIndex].FullVertices[VertexIndex].Position;
          BoundingBox.Max:=SAM.Animations[Index].Frames[FrameIndex].FullVertices[VertexIndex].Position;
         end else begin
          BoundingBox.DirectCombineVector3(SAM.Animations[Index].Frames[FrameIndex].FullVertices[VertexIndex].Position);
         end;
        end;
       end;
      end;

      // Pack animations
      for Index:=0 to length(SAM.Animations)-1 do begin
       for FrameIndex:=0 to length(SAM.Animations[Index].Frames)-1 do begin
        SAM.Animations[Index].Frames[FrameIndex].Pack;
       end;
      end;

      // Get bounding sphere
      BoundingSphere:=TpvSphere.CreateFromAABB(BoundingBox);

      // Save
      Stream:=TMemoryStream.Create;
      try

       SAM.FileHeader.Signature:=TpvSAM.Signature;
       SAM.FileHeader.Version:=TpvSAM.Version;
       SAM.FileHeader.CountVertices:=CountUsedVertices;
       SAM.FileHeader.CountIndices:=CountUsedIndices;
       SAM.FileHeader.CountAnimations:=length(SAM.Animations);
       SAM.FileHeader.FrameRate:=FrameRate;

       SAM.FileHeader.BoundingBoxMin:=BoundingBox.Min;
       SAM.FileHeader.BoundingBoxMax:=BoundingBox.Max;
       SAM.FileHeader.BoundingSphere:=TpvVector4.InlineableCreate(BoundingSphere.Center,BoundingSphere.Radius);

       SAM.SaveToStream(Stream);

       // Save to file
       Stream.SaveToFile(aOutputFileName);

       // Done!

      finally
       FreeAndNil(Stream);
      end;

     end;
    
    end;

   finally
    FreeAndNil(GLTFInstance);
   end;

  finally
   FreeAndNil(GLTF);
  end;

 finally
  FreeAndNil(SAM);
 end; 

end;

var Index:TpvSizeInt;
    Parameter,InputFileName,OutputFileName:String;
    OK:TPasDblStrUtilsBoolean;
{   m0,m1:TpvMatrix3x3;
    u0:TpvUInt32;//}
begin

{m0:=TpvMatrix3x3.Create(TpvVector3.InlineableCreate(0.707,0.707,0.0).Normalize,
                         TpvVector3.InlineableCreate(0.707,-0.707,0.0).Normalize,
                         TpvVector3.InlineableCreate(0.0,0.0,1.0).Normalize);

 u0:=EncodeTangentSpaceAsRGB10A2SNorm(m0);
 
 DecodeTangentSpaceFromRGB10A2SNorm(u0,m1);

 WriteLn('m0 Tangent: ',m0.Tangent.x:7:4,' ',m0.Tangent.y:7:4,' ',m0.Tangent.z:7:4);
 WriteLn('m0 Bitangent: ',m0.Bitangent.x:7:4,' ',m0.Bitangent.y:7:4,' ',m0.Bitangent.z:7:4);
 WriteLn('m0 Normal: ',m0.Normal.x:7:4,' ',m0.Normal.y:7:4,' ',m0.Normal.z:7:4);
 WriteLn;
 WriteLn('u0: ',u0);
 WriteLn;
 WriteLn('m1 Tangent: ',m1.Tangent.x:7:4,' ',m1.Tangent.y:7:4,' ',m1.Tangent.z:7:4);
 WriteLn('m1 Bitangent: ',m1.Bitangent.x:7:4,' ',m1.Bitangent.y:7:4,' ',m1.Bitangent.z:7:4);
 WriteLn('m1 Normal: ',m1.Normal.x:7:4,' ',m1.Normal.y:7:4,' ',m1.Normal.z:7:4);

 exit;//}

 if ParamCount=0 then begin
  writeln('Usage: ',ExtractFileName(ParamStr(0)),' <input file name> <output file name>');
  halt(1);
 end;

 InputFileName:='';
 OutputFileName:='';

 Index:=1;
 while Index<=ParamCount do begin
  Parameter:=ParamStr(Index);
  inc(Index);
  if length(Parameter)>0 then begin
   case Parameter[1] of
    '-','/':begin
     if (Parameter[1]='-') and ((length(Parameter)>1) and (Parameter[2]='-')) then begin
      Delete(Parameter,1,2);
     end else begin
      Delete(Parameter,1,1);
     end;
     if (Parameter='framerate') or (Parameter='fps') then begin
      Parameter:=ParamStr(Index);
      inc(Index);
      FrameRate:=ConvertStringToDouble(Parameter,rmNearest,@OK,-1);
      if not OK then begin
       FrameRate:=10;
      end;
     end;
    end;
    else begin
     if length(InputFileName)=0 then begin
      InputFileName:=Parameter;
     end else if length(OutputFileName)=0 then begin
      OutputFileName:=Parameter;
     end;
    end;
   end;
  end;
 end;

 if (length(InputFileName)=0) or not FileExists(InputFileName) then begin
  writeln('Error: No input file name specified or input file name not found!');
  halt(1);
 end;

 if length(OutputFileName)=0 then begin
  writeln('Error: No output file name specified!');
  halt(1);
 end;

 BaseColorTextureData:=nil;
 NormalTextureData:=nil;
 MetallicRoughnessTextureData:=nil;
 OcclusionTextureData:=nil;
 EmissiveTextureData:=nil;
 
 ConvertModel(InputFileName,OutputFileName);

 WriteLn('Done!');

 BaseColorTextureData:=nil;
 NormalTextureData:=nil;
 MetallicRoughnessTextureData:=nil;
 OcclusionTextureData:=nil;
 EmissiveTextureData:=nil;

end.


