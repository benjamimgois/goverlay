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
unit PasVulkan.FileFormats.SAM;
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

uses SysUtils,Classes,Math,PasJSON,PasVulkan.Types,PasVulkan.Math,PasVulkan.Collections;

type EpvSAM=class(Exception);

     { TpvSAM }
     TpvSAM=class
      public
       const CountPresetAnimations=4;
             Version=1;
       type TVertex=packed record
             Position:TpvVector3; // 12 bytes (must be non-quantized and non-compressed for direct use with hardware raytracing)
             TangentSpace:TpvUInt32; // 4 bytes (special-encoded QTangent)
            end; // 12+4 = 16 bytes
            PVertex=^TVertex;
            TVertices=array of TVertex;
            TFullVertex=record
             Position:TpvVector3;
             Tangent:TpvVector3; 
             Bitangent:TpvVector3;
             Normal:TpvVector3;
            end; // 12+12+12+12 = 48 bytes
            PFullVertex=^TFullVertex;
            TFullVertices=array of TFullVertex;
            TTexCoords=array of TpvUInt16Vector2;
            TVertexMaterials=array of TpvUInt32;
            TIndex=TpvUInt32;
            PIndex=^TIndex;
            TIndices=array of TIndex;
            TMaterialHeader=packed record
             public
              const MaterialTypeUnlit=0;
                    MaterialTypeMetallicRoughness=1;
                    AlphaModeOpaque=0;
                    AlphaModeMask=1;
                    AlphaModeBlend=2;
                    FlagAlphaModeMask=3;
                    FlagDoubleSided=1 shl 3;
             public
              MaterialType:TpvUInt32;
              AlphaModeFlags:TpvUInt32; // 2 bits Alpha mode, 1 bit double side
              BaseColorFactor:TpvVector4;
              EmissiveFactor:TpvVector4; // xyz = EmissiveFactor, w = OcclusionStrength
              OcclusionStrength:TpvFloat;
              MetallicFactor:TpvFloat;
              RoughnessFactor:TpvFloat;
              NormalScale:TpvFloat;
              AlphaCutOff:TpvFloat;
              BaseColorTextureSize:TpvUInt32;
              NormalTextureSize:TpvUInt32;
              MetallicRoughnessTextureSize:TpvUInt32;
              OcclusionTextureSize:TpvUInt32;
              EmissiveTextureSize:TpvUInt32;
            end;
            PMaterialHeader=^TMaterialHeader;
            { TMaterial }
            TMaterial=class
             private
              fName:TpvUTF8String;
              fMaterialHeader:TMaterialHeader;
              fPointerToMaterialHeader:PMaterialHeader;
              fBaseColorTextureStream:TMemoryStream;
              fNormalTextureStream:TMemoryStream;
              fMetallicRoughnessTextureStream:TMemoryStream;
              fOcclusionTextureStream:TMemoryStream;
              fEmissiveTextureStream:TMemoryStream;
             public
              constructor Create;
              destructor Destroy; override;
             public 
              property MaterialHeader:PMaterialHeader read fPointerToMaterialHeader;
             published 
              property Name:TpvUTF8String read fName write fName;
              property BaseColorTextureStream:TMemoryStream read fBaseColorTextureStream;
              property NormalTextureStream:TMemoryStream read fNormalTextureStream;
              property MetallicRoughnessTextureStream:TMemoryStream read fMetallicRoughnessTextureStream;
              property OcclusionTextureStream:TMemoryStream read fOcclusionTextureStream;
              property EmissiveTextureStream:TMemoryStream read fEmissiveTextureStream;
            end;
            TMaterials=TpvObjectGenericList<TMaterial>;
            { TFrame }
            TFrame=record
             Time:TpvDouble;
             Vertices:TVertices;
             FullVertices:TFullVertices;
             procedure Pack;
             procedure Unpack;
            end;
            PFrame=^TFrame;
            TFrames=array of TFrame;
            TAnimation=record
             Name:TpvUTF8String;
             StartTime:TpvDouble;
             EndTime:TpvDouble;
             Frames:TFrames;
            end;
            PAnimation=^TAnimation;
            TAnimations=array of TAnimation;
            TSignature=array[0..3] of AnsiChar;
            TFileHeader=packed record
             Signature:TSignature;
             Version:TpvUInt32;
             CountMaterials:TpvUInt32;
             CountVertices:TpvUInt32;
             CountIndices:TpvUInt32;
             CountAnimations:TpvUInt32;
             FrameRate:TpvDouble;
             BoundingBoxMin:TpvVector3;
             BoundingBoxMax:TpvVector3;
             BoundingSphere:TpvVector4;
            end;
            PFileHeader=^TFileHeader;            
       const Signature:TSignature=('S','A','M','F'); // Simple Animated Model File
       type { TModel }
            TModel=class
             public
              FileHeader:TFileHeader;
              VertexTexCoords:TTexCoords;
              VertexMaterials:TVertexMaterials;
              Indices:TIndices;
              Animations:TAnimations;
              Materials:TMaterials;
             public
              constructor Create; reintroduce;
              destructor Destroy; override;
              procedure LoadFromStream(const aStream:TStream);
              procedure LoadFromFile(const aFileName:TpvUTF8String);
              procedure SaveToStream(const aStream:TStream);
              procedure SaveToFile(const aFileName:TpvUTF8String);
            end;
      private
 
    end;

implementation

{ TpvSAM.TMaterial }

constructor TpvSAM.TMaterial.Create;
begin
 inherited Create;
 fName:='';
 FillChar(fMaterialHeader,SizeOf(TMaterialHeader),#0);
 fPointerToMaterialHeader:=@fMaterialHeader;
 fBaseColorTextureStream:=TMemoryStream.Create;
 fNormalTextureStream:=TMemoryStream.Create;
 fMetallicRoughnessTextureStream:=TMemoryStream.Create;
 fOcclusionTextureStream:=TMemoryStream.Create;
 fEmissiveTextureStream:=TMemoryStream.Create;
end;

destructor TpvSAM.TMaterial.Destroy;
begin
 FreeAndNil(fEmissiveTextureStream);
 FreeAndNil(fOcclusionTextureStream);
 FreeAndNil(fMetallicRoughnessTextureStream);
 FreeAndNil(fNormalTextureStream);
 FreeAndNil(fBaseColorTextureStream);
 fName:='';
 inherited Destroy;
end;

{ TpvSAM.TFrame }

procedure TpvSAM.TFrame.Pack;
var Index:TpvSizeInt;
    FullVertex:PFullVertex;
    Vertex:PVertex;
begin
 if length(Vertices)<>length(FullVertices) then begin
  SetLength(Vertices,length(FullVertices));
 end;
 for Index:=0 to length(Vertices)-1 do begin
  Vertex:=@Vertices[Index];
  FullVertex:=@FullVertices[Index];
  Vertex^.Position:=FullVertex^.Position;
  Vertex^.TangentSpace:=EncodeQTangentUI32(FullVertex^.Tangent,FullVertex^.Bitangent,FullVertex^.Normal);
 end;
end;

procedure TpvSAM.TFrame.Unpack;
var Index:TpvSizeInt;
    FullVertex:PFullVertex;
    Vertex:PVertex;
begin
 if length(FullVertices)<>length(Vertices) then begin
  SetLength(FullVertices,length(Vertices));
 end;
 for Index:=0 to length(FullVertices)-1 do begin
  Vertex:=@Vertices[Index];
  FullVertex:=@FullVertices[Index];
  FullVertex^.Position:=Vertex^.Position;
  DecodeQTangentUI32Vectors(Vertex^.TangentSpace,FullVertex^.Tangent,FullVertex^.Bitangent,FullVertex^.Normal);
 end;
end;

{ TpvSAM.TModel }

constructor TpvSAM.TModel.Create;
begin
 inherited Create;
 FillChar(FileHeader,SizeOf(TpvSAM.TFileHeader),#0);
 VertexTexCoords:=nil;
 VertexMaterials:=nil;
 Indices:=nil;
 Animations:=nil;
 Materials:=TMaterials.Create;
end;

destructor TpvSAM.TModel.Destroy;
begin
 VertexTexCoords:=nil;
 VertexMaterials:=nil;
 Indices:=nil;
 Animations:=nil;
 FreeAndNil(Materials);
 inherited Destroy;
end;

procedure TpvSAM.TModel.LoadFromStream(const aStream:TStream);
var MaterialIndex,AnimationIndex,FramesIndex:TpvSizeInt;
    CountFrames:TpvInt32;
    ui32:TpvUInt32;
    Material:TMaterial;
begin

 VertexTexCoords:=nil;
 VertexMaterials:=nil;
 Indices:=nil;
 Animations:=nil;
 Materials.Clear;

 FillChar(FileHeader,SizeOf(TpvSAM.TFileHeader),#0);

 aStream.ReadBuffer(FileHeader,SizeOf(TpvSAM.TFileHeader));
 
 if FileHeader.Signature<>TpvSAM.Signature then begin
  raise EpvSAM.Create('Invalid SAM signature');
 end;

 if FileHeader.Version<>TpvSAM.Version then begin
  raise EpvSAM.Create('Invalid or not supported SAM version');
 end;

 if FileHeader.CountIndices>0 then begin
  SetLength(Indices,FileHeader.CountIndices);
  aStream.ReadBuffer(Indices[0],SizeOf(TpvSAM.TIndex)*FileHeader.CountIndices);
 end;

 if FileHeader.CountVertices>0 then begin
  
  SetLength(VertexTexCoords,FileHeader.CountVertices);
  aStream.ReadBuffer(VertexTexCoords[0],SizeOf(TpvUInt16Vector2)*FileHeader.CountVertices);

  SetLength(VertexMaterials,FileHeader.CountVertices);
  aStream.ReadBuffer(VertexMaterials[0],SizeOf(TpvUInt32)*FileHeader.CountVertices);
  
 end;

 SetLength(Animations,FileHeader.CountAnimations);
 for AnimationIndex:=0 to FileHeader.CountAnimations-1 do begin
  aStream.ReadBuffer(ui32,SizeOf(TpvUInt32));
  Animations[AnimationIndex].Name:='';
  if ui32>0 then begin
   SetLength(Animations[AnimationIndex].Name,ui32);
   aStream.ReadBuffer(Animations[AnimationIndex].Name[1],ui32);
  end;
  aStream.ReadBuffer(Animations[AnimationIndex].StartTime,SizeOf(TpvDouble));
  aStream.ReadBuffer(Animations[AnimationIndex].EndTime,SizeOf(TpvDouble));
  aStream.ReadBuffer(CountFrames,SizeOf(TpvInt32));
  Animations[AnimationIndex].Frames:=nil;
  if CountFrames>0 then begin
   SetLength(Animations[AnimationIndex].Frames,CountFrames);
   for FramesIndex:=0 to CountFrames-1 do begin
    aStream.ReadBuffer(Animations[AnimationIndex].Frames[FramesIndex].Time,SizeOf(TpvDouble));
    SetLength(Animations[AnimationIndex].Frames[FramesIndex].Vertices,FileHeader.CountVertices);
    if FileHeader.CountVertices>0 then begin
     aStream.ReadBuffer(Animations[AnimationIndex].Frames[FramesIndex].Vertices[0],SizeOf(TpvSAM.TVertex)*FileHeader.CountVertices);
    end;
   end;
  end;
 end;

 if FileHeader.CountMaterials>0 then begin
  for MaterialIndex:=0 to TpvSizeInt(FileHeader.CountMaterials)-1 do begin
   Material:=TMaterial.Create;
   try
    aStream.ReadBuffer(ui32,SizeOf(TpvUInt32));
    Material.Name:='';
    if ui32>0 then begin
     SetLength(Material.fName,ui32);
     aStream.ReadBuffer(Material.fName[1],ui32);
    end;
    aStream.ReadBuffer(Material.fMaterialHeader,SizeOf(TpvSAM.TMaterialHeader));
    if Material.MaterialHeader.BaseColorTextureSize>0 then begin
     Material.BaseColorTextureStream.CopyFrom(aStream,Material.MaterialHeader.BaseColorTextureSize);
    end;
    if Material.MaterialHeader.NormalTextureSize>0 then begin
     Material.NormalTextureStream.CopyFrom(aStream,Material.MaterialHeader.NormalTextureSize);
    end;
    if Material.MaterialHeader.MetallicRoughnessTextureSize>0 then begin
     Material.MetallicRoughnessTextureStream.CopyFrom(aStream,Material.MaterialHeader.MetallicRoughnessTextureSize);
    end;
    if Material.MaterialHeader.OcclusionTextureSize>0 then begin
     Material.OcclusionTextureStream.CopyFrom(aStream,Material.MaterialHeader.OcclusionTextureSize);
    end;
    if Material.MaterialHeader.EmissiveTextureSize>0 then begin
     Material.EmissiveTextureStream.CopyFrom(aStream,Material.MaterialHeader.EmissiveTextureSize);
    end;
   finally
    Materials.Add(Material);
   end;
  end;
 end;

end;

procedure TpvSAM.TModel.LoadFromFile(const aFileName:TpvUTF8String);
var Stream:TMemoryStream;
begin
 Stream:=TMemoryStream.Create;
 try
  Stream.LoadFromFile(aFileName);
  Stream.Seek(0,soBeginning);
  LoadFromStream(Stream);
 finally
  Stream.Free;
 end;
end;

procedure TpvSAM.TModel.SaveToStream(const aStream:TStream);
var MaterialIndex,AnimationIndex,FramesIndex:TpvSizeInt;
    CountFrames:TpvInt32;
    ui32:TpvUInt32;
    Material:TMaterial;
begin

 FileHeader.Signature:=TpvSAM.Signature;
 FileHeader.Version:=TpvSAM.Version;
 FileHeader.CountMaterials:=Materials.Count;
 FileHeader.CountAnimations:=length(Animations);

 aStream.WriteBuffer(FileHeader,SizeOf(TpvSAM.TFileHeader));

 aStream.WriteBuffer(Indices[0],SizeOf(TpvSAM.TIndex)*FileHeader.CountIndices);
 
 aStream.WriteBuffer(VertexTexCoords[0],SizeOf(TpvUInt16Vector2)*FileHeader.CountVertices);
 
 aStream.WriteBuffer(VertexMaterials[0],SizeOf(TpvUInt32)*FileHeader.CountVertices);
 
 for AnimationIndex:=0 to length(Animations)-1 do begin
  ui32:=length(Animations[AnimationIndex].Name);
  aStream.WriteBuffer(ui32,SizeOf(TpvUInt32));
  if ui32>0 then begin
   aStream.WriteBuffer(Animations[AnimationIndex].Name[1],ui32);
  end;
  aStream.WriteBuffer(Animations[AnimationIndex].StartTime,SizeOf(TpvDouble));
  aStream.WriteBuffer(Animations[AnimationIndex].EndTime,SizeOf(TpvDouble));
  CountFrames:=length(Animations[AnimationIndex].Frames);
  aStream.WriteBuffer(CountFrames,SizeOf(TpvInt32));
  for FramesIndex:=0 to CountFrames-1 do begin
   aStream.WriteBuffer(Animations[AnimationIndex].Frames[FramesIndex].Time,SizeOf(TpvDouble));
   aStream.WriteBuffer(Animations[AnimationIndex].Frames[FramesIndex].Vertices[0],SizeOf(TpvSAM.TVertex)*FileHeader.CountVertices);
  end;
 end;

 for MaterialIndex:=0 to Materials.Count-1 do begin
  Material:=Materials[MaterialIndex];
  ui32:=length(Material.fName);
  aStream.WriteBuffer(ui32,SizeOf(TpvUInt32));
  if ui32>0 then begin
   aStream.WriteBuffer(Material.fName[1],ui32);
  end;
  aStream.WriteBuffer(Material.fMaterialHeader,SizeOf(TpvSAM.TMaterialHeader));
  if Material.MaterialHeader.BaseColorTextureSize>0 then begin
   Material.BaseColorTextureStream.Seek(0,soBeginning);
   aStream.CopyFrom(Material.BaseColorTextureStream,Material.MaterialHeader.BaseColorTextureSize);
  end;
  if Material.MaterialHeader.NormalTextureSize>0 then begin
   Material.NormalTextureStream.Seek(0,soBeginning);
   aStream.CopyFrom(Material.NormalTextureStream,Material.MaterialHeader.NormalTextureSize);
  end;
  if Material.MaterialHeader.MetallicRoughnessTextureSize>0 then begin
   Material.MetallicRoughnessTextureStream.Seek(0,soBeginning);
   aStream.CopyFrom(Material.MetallicRoughnessTextureStream,Material.MaterialHeader.MetallicRoughnessTextureSize);
  end;
  if Material.MaterialHeader.OcclusionTextureSize>0 then begin
   Material.OcclusionTextureStream.Seek(0,soBeginning);
   aStream.CopyFrom(Material.OcclusionTextureStream,Material.MaterialHeader.OcclusionTextureSize);
  end;
  if Material.MaterialHeader.EmissiveTextureSize>0 then begin
   Material.EmissiveTextureStream.Seek(0,soBeginning);
   aStream.CopyFrom(Material.EmissiveTextureStream,Material.MaterialHeader.EmissiveTextureSize);
  end;
 end;

end;

procedure TpvSAM.TModel.SaveToFile(const aFileName:TpvUTF8String);
var Stream:TMemoryStream;
begin
 Stream:=TMemoryStream.Create;
 try
  SaveToStream(Stream);
  Stream.Seek(0,soBeginning);
  Stream.SaveToFile(aFileName);
 finally
  Stream.Free;
 end;
end;

end.
