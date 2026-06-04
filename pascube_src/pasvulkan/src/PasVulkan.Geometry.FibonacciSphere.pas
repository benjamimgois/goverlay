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
unit PasVulkan.Geometry.FibonacciSphere;
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

uses Classes,SysUtils,Math,PasMP,PasDblStrUtils,PasVulkan.Types,PasVulkan.Math,PasVulkan.Collections,PasVulkan.Utils;

type { TpvFibonacciSphere }
     TpvFibonacciSphere=class
      public             
       const GoldenRatio=1.61803398874989485; // (1.0+sqrt(5.0))/2.0 (golden ratio)
             GoldenRatioMinusOne=0.61803398874989485; // ((1.0+sqrt(5.0))/2.0)-1.0
             NegGoldenRatioMinusOne=-0.61803398874989485; // -(((1.0+sqrt(5.0))/2.0)-1.0)
             GoldenAngle=2.39996322972865332; // PI*(3.0-sqrt(5.0)) (golden angle)
             Sqrt5=2.236067977499789696; // sqrt(5.0)
             OneOverSqrt5=0.447213595499957939; // 1.0/sqrt(5.0)
             PImulSqrt5=7.024814731040726393; // PI*sqrt(5.0)
             PImul20=62.831853071795864769; // PI*20.0
             PImul20overSqrt5=28.099258924162905573; // (PI*20.0)/sqrt(5.0)
             HalfPI=1.570796326794896619; // PI/2.0
             TwoPI=6.283185307179586477; // PI*2.0
             LogGoldenRatio=0.481211825059603447; // ln((1.0+sqrt(5.0))/2.0) (log of golden ratio)
             OneOverLogGoldenRatio=2.0780869212350275376; // 1.0/ln((1.0+sqrt(5.0))/2.0) (1.0/log of golden ratio)
       type TTextureProjectionMapping=
             (
              Equirectangular,            // Equirectangular projection mapping
              CylindricalEqualArea,       // Lambert cylindrical equal-area projection mapping
              Octahedral,                 // Octahedral projection mapping
              WebMercator,                // Web Mercator projection
              Spherical,                  // The GL_SPHERE_MAP projection from old OpenGL times 
              HEALPix,                    // Hierarchical Equal Area isoLatitude Pixelization of a sphere
              CassiniSoldner              // Cassini Soldner projection mapping
             );
            { TVector }
            TVector=record
             x:TpvDouble;
             y:TpvDouble;
             z:TpvDouble;
             constructor Create(const aX,aY,aZ:TpvDouble); 
             class function InlineableCreate(const aX,aY,aZ:TpvDouble):TVector; static; inline;
             class operator Add(const a,b:TVector):TVector;
             class operator Subtract(const a,b:TVector):TVector;
             class operator Multiply(const a:TVector;const b:TpvDouble):TVector;
             class operator Multiply(const a,b:TVector):TVector;
             class operator Divide(const a:TVector;const b:TpvDouble):TVector;
             function Length:TpvDouble;
             function SquaredLength:TpvDouble;
             function Normalize:TVector;
             function Distance(const aVector:TVector):TpvDouble;
             function SquaredDistance(const aVector:TVector):TpvDouble;
             function Dot(const aVector:TVector):TpvDouble;
             function Cross(const aVector:TVector):TVector;
            end; 
            PVector=^TVector;
            TVectors=array of TpvFibonacciSphere.TVector;
            TVertex=record
             Position:TpvVector3;
             Normal:TpvVector3;
             Tangent:TpvVector3;
             Bitangent:TpvVector3;
             TexCoord:TpvVector2;
             Index:TpvInt32; // <- For pointing to the original vertex index, since vertices can be duplicated for texture coordinate seam fixing   
            end;
            PVertex=^TVertex;
            TVertices=TpvDynamicArrayList<TpvFibonacciSphere.TVertex>;
            TIndices=TpvDynamicArrayList<TpvUInt32>;
      private
       fCountPoints:TpvSizeInt;
       fRadius:TpvDouble;
       fTextureProjectionMapping:TTextureProjectionMapping;
       fVertices:TVertices;
       fIndices:TIndices;
       fUseGoldenRatio:Boolean;
       fFixTextureCoordinateSeams:Boolean;
       fPoints:TVectors;
       fPhis:TpvDoubleDynamicArray;
       fWrappedIndices:TpvSizeIntDynamicArray;
       fCountIndices:TPasMPInt32;
       fWrappedIndicesLock:TPasMPInt32;
       procedure GenerateVerticesParallelForJob(const aJob:PPasMPJob;const aThreadIndex:TPasMPInt32;const aData:pointer;const aFromIndex,aToIndex:TPasMPNativeInt);
       procedure GenerateIndicesParallelForJob(const aJob:PPasMPJob;const aThreadIndex:TPasMPInt32;const aData:pointer;const aFromIndex,aToIndex:TPasMPNativeInt);
      public
       constructor Create(const aCountPoints:TpvSizeInt;const aRadius:TpvDouble=1.0;const aTextureProjectionMapping:TTextureProjectionMapping=TTextureProjectionMapping.Equirectangular);
       destructor Destroy; override;
       procedure Generate(const aUseGoldenRatio:Boolean=true;const aFixTextureCoordinateSeams:Boolean=true;const aPasMPInstance:TPasMP=nil);
       procedure ExportToOBJ(const aStream:TStream); overload;
       procedure ExportToOBJ(const aFileName:TpvUTF8String); overload;
      published 
       property CountPoints:TpvSizeInt read fCountPoints;
       property Radius:TpvDouble read fRadius;
       property TextureProjectionMapping:TTextureProjectionMapping read fTextureProjectionMapping write fTextureProjectionMapping;
       property Vertices:TVertices read fVertices;
       property Indices:TIndices read fIndices;
     end;

procedure GenerateFibonacciSphere(const aCountPoints:TpvSizeInt;out aVertices:TpvVector3DynamicArray;out aTexCoords:TpvVector2DynamicArray;out aIndices:TpvUInt32DynamicArray;const aRadius:TpvFloat=1.0);

implementation

uses PasVulkan.Geometry.Utils;

function DirectionToHEALPix(const aDirection:TpvVector3):TpvVector2;
const Phi0=0.729727656226966363; // ArcSin(2.0/3.0)
      PImul3Over8=1.178097245096172464; // PI*3.0/8.0
      OneOverPI=0.3183098861837906715; // 1.0/PI
      HalfPI=1.570796326794896619; // PI/2.0
      FORTPI=0.7853981633974483096; // PI/4.0                   
var LongitudeLatitude:TpvVector2;
    Lam,Phi,LamC,Sigma:TpvDouble;
    CN:TpvInt32;
begin
 LongitudeLatitude.x:=ArcTan2(aDirection.z,aDirection.x);
 LongitudeLatitude.y:=ArcSin(aDirection.y);
 Lam:=LongitudeLatitude.x;
 Phi:=LongitudeLatitude.y;
 if abs(Phi)<=Phi0 then begin
  result.x:=Lam;
  result.y:=PImul3Over8*sin(Phi);
 end else begin
  Sigma:=sqrt((1.0-abs(sin(Phi)))*3.0);
  CN:=Min(Floor(((Lam*2.0)*OneOverPI)+2.0),3);
  LamC:=((-3.0)*FORTPI)+(CN*HalfPI);    
  result.x:=(LamC*(1.0-Sigma))+(Lam*Sigma);
  result.y:=Sign(Phi)*FORTPI*(2.0-Sigma);
 end;
end;                

{ TpvFibonacciSphere.TVector }

constructor TpvFibonacciSphere.TVector.Create(const aX,aY,aZ:TpvDouble);
begin
 x:=aX;
 y:=aY;
 z:=aZ;
end;

class function TpvFibonacciSphere.TVector.InlineableCreate(const aX,aY,aZ:TpvDouble):TVector;
begin
 result.x:=aX;
 result.y:=aY;
 result.z:=aZ;
end;

class operator TpvFibonacciSphere.TVector.Add(const a,b:TVector):TVector;
begin
 result.x:=a.x+b.x;
 result.y:=a.y+b.y;
 result.z:=a.z+b.z;
end;

class operator TpvFibonacciSphere.TVector.Subtract(const a,b:TVector):TVector;
begin
 result.x:=a.x-b.x;
 result.y:=a.y-b.y;
 result.z:=a.z-b.z;
end;

class operator TpvFibonacciSphere.TVector.Multiply(const a:TVector;const b:TpvDouble):TVector;
begin
 result.x:=a.x*b;
 result.y:=a.y*b;
 result.z:=a.z*b;
end;

class operator TpvFibonacciSphere.TVector.Multiply(const a,b:TVector):TVector;
begin
 result.x:=a.x*b.x;
 result.y:=a.y*b.y;
 result.z:=a.z*b.z;
end;

class operator TpvFibonacciSphere.TVector.Divide(const a:TVector;const b:TpvDouble):TVector;
begin
 result.x:=a.x/b;
 result.y:=a.y/b;
 result.z:=a.z/b;
end;

function TpvFibonacciSphere.TVector.Length:TpvDouble;
begin
 result:=sqrt(sqr(x)+sqr(y)+sqr(z));
end;

function TpvFibonacciSphere.TVector.SquaredLength:TpvDouble;
begin
 result:=sqr(x)+sqr(y)+sqr(z);
end;

function TpvFibonacciSphere.TVector.Normalize:TVector;
var l:TpvDouble;
begin
 l:=Length;
 if l>0.0 then begin
  result.x:=x/l;
  result.y:=y/l;
  result.z:=z/l;
 end else begin
  result.x:=x;
  result.y:=y;
  result.z:=z;
 end;
end;

function TpvFibonacciSphere.TVector.Distance(const aVector:TVector):TpvDouble;
begin
 result:=sqrt(sqr(x-aVector.x)+sqr(y-aVector.y)+sqr(z-aVector.z));
end;

function TpvFibonacciSphere.TVector.SquaredDistance(const aVector:TVector):TpvDouble;
begin
 result:=sqr(x-aVector.x)+sqr(y-aVector.y)+sqr(z-aVector.z);
end;

function TpvFibonacciSphere.TVector.Dot(const aVector:TVector):TpvDouble;
begin
 result:=(x*aVector.x)+(y*aVector.y)+(z*aVector.z);
end;

function TpvFibonacciSphere.TVector.Cross(const aVector:TVector):TVector;
begin
 result.x:=(y*aVector.z)-(z*aVector.y);
 result.y:=(z*aVector.x)-(x*aVector.z);
 result.z:=(x*aVector.y)-(y*aVector.x);
end;

{ TpvFibonacciSphere }

constructor TpvFibonacciSphere.Create(const aCountPoints:TpvSizeInt;const aRadius:TpvDouble;const aTextureProjectionMapping:TTextureProjectionMapping);
begin
 inherited Create;
 fCountPoints:=Max(32,aCountPoints);
 fRadius:=aRadius;
 fTextureProjectionMapping:=aTextureProjectionMapping;
 fVertices:=TVertices.Create;
 fIndices:=TIndices.Create;
 fPoints:=nil;
 fPhis:=nil;
 fWrappedIndices:=nil;
 fWrappedIndicesLock:=0;
end;

destructor TpvFibonacciSphere.Destroy;
begin
 FreeAndNil(fVertices);
 FreeAndNil(fIndices);
 fPoints:=nil;
 fPhis:=nil;
 fWrappedIndices:=nil;
 inherited Destroy;
end;

procedure TpvFibonacciSphere.GenerateVerticesParallelForJob(const aJob:PPasMPJob;const aThreadIndex:TPasMPInt32;const aData:pointer;const aFromIndex,aToIndex:TPasMPNativeInt);
var Index:TPasMPNativeInt;
    Phi,Theta,Z,SinTheta,PhiSinus,PhiCosinus:TpvDouble;
    Vertex:PVertex;
    Vector,Normal,Tangent,Bitangent:TpvFibonacciSphere.TVector;
    TemporaryVector:TpvVector3;
begin

 for Index:=aFromIndex to aToIndex do begin

  // Advance Phi
  if fUseGoldenRatio then begin
   Phi:=frac(Index*GoldenRatioMinusOne)*TwoPI;
  end else begin
   Phi:=Modulo(PI-(GoldenAngle*Index),TwoPI)-PI;
  end;

  // Wrap Phi into the -pi .. +pi range (as it is also needed by the calculation of the texture
  // coordinates later)
  if Phi<=-PI then begin
   Phi:=Phi+TwoPI;
  end else if Phi>=PI then begin
   Phi:=Phi-TwoPI;
  end;

  // Calculate the actual fibonacci sphere point sample vector
  Z:=1.0-(((Index shl 1) or 1)/fCountPoints); // Z:=1.0-(((Index+0.5)*2.0)/fCountPoints);
  SinTheta:=sqrt(1.0-sqr(Z));
  SinCos(Phi,PhiSinus,PhiCosinus);
  Vector:=TpvFibonacciSphere.TVector.InlineableCreate(PhiCosinus*SinTheta,z,PhiSinus*SinTheta).Normalize;

  // Store the vector in an temporary point array later for the generation of the triangle indices
  fPoints[Index]:=Vector;
  fPhis[Index]:=Phi;

  // Generate the tangent space vector
  Normal:=Vector;
  Tangent:=TpvFibonacciSphere.TVector.InlineableCreate(-Normal.z,0.0,Normal.x).Normalize;
  Bitangent:=Normal.Cross(Tangent).Normalize;

  // Add it as a mesh vertex
  Vertex:=@fVertices.ItemArray[Index];

  Vertex^.Position:=TpvVector3.InlineableCreate(Vector.x,Vector.y,Vector.z)*fRadius;

  Vertex^.Normal:=TpvVector3.InlineableCreate(Normal.x,Normal.y,Normal.z);

  Vertex^.Tangent:=TpvVector3.InlineableCreate(Tangent.x,Tangent.y,Tangent.z);

  Vertex^.Bitangent:=TpvVector3.InlineableCreate(Bitangent.x,Bitangent.y,Bitangent.z);

  // Calculate the texture coordinates, where we've already the Phi value, so avoid recalculate it
  // by Phi:=ArcTan2(Vector.z,Vector.x) here
  case fTextureProjectionMapping of

   TpvFibonacciSphere.TTextureProjectionMapping.Equirectangular:begin
    // Equirectangular projection mapping
    Vertex^.TexCoord:=TpvVector2.InlineableCreate(
                       (Phi/TwoPI)+0.5,
                       (ArcSin(Vector.y)/PI)+0.5 // or 1.0-(ArcCos(Vector.y)/PI) or something as this like
                      );
   end;

   TpvFibonacciSphere.TTextureProjectionMapping.CylindricalEqualArea:begin
    // Lambert cylindrical equal-area projection mapping
    Vertex^.TexCoord:=TpvVector2.InlineableCreate(
                       (Phi/TwoPI)+0.5,
                       (Vector.y*0.5)+0.5
                      );
   end;

   TpvFibonacciSphere.TTextureProjectionMapping.Octahedral:begin
    // Octahedral projection mapping
    TemporaryVector:=Vertex^.Normal;
    Vertex^.TexCoord:=TemporaryVector.xy/(abs(TemporaryVector.x)+
                                          abs(TemporaryVector.y)+
                                          abs(TemporaryVector.z));
    if TemporaryVector.z<0.0 then begin
     Vertex^.TexCoord:=(TpvVector2.InlineableCreate(1.0,1.0)-Vertex^.TexCoord.yx.Abs)*
                        TpvVector2.InlineableCreate(SignNonZero(Vertex^.TexCoord.x),SignNonZero(Vertex^.TexCoord.y));
    end;
    Vertex^.TexCoord:=(Vertex^.TexCoord*0.5)+TpvVector2.InlineableCreate(0.5,0.5);
   end;

   TpvFibonacciSphere.TTextureProjectionMapping.WebMercator:begin
    // Web Mercator projection
    Vertex^.TexCoord:=TpvVector2.Create(
                       (Phi/TwoPI)+0.5,
                       (Ln(
                         Tan(
                          (
                           ArcTan2(
                            Vector.y,
                            sqrt(sqr(Vector.x)+sqr(Vector.z))
                           )*0.5
                          )+
                          (PI*0.25)
                         )
                        )+PI
                       )/TwoPI
                      );
   end;

   TpvFibonacciSphere.TTextureProjectionMapping.Spherical:begin
    // The GL_SPHERE_MAP projection from old OpenGL times
    Vertex^.TexCoord:=(
                       TpvVector2.InlineableCreate(Vector.x,Vector.z)/
                       (TpvVector3.InlineableCreate(Vector.x,Vector.y+1.0,Vector.z).Length*2.0)
                      )+TpvVector2.InlineableCreate(0.5,0.5);
   end;

   TpvFibonacciSphere.TTextureProjectionMapping.HEALPix:begin
    // Hierarchical Equal Area isoLatitude Pixelization of a sphere
    Vertex^.TexCoord:=DirectionToHEALPix(TpvVector3.InlineableCreate(Vector.x,Vector.y,Vector.z));
   end;

   TpvFibonacciSphere.TTextureProjectionMapping.CassiniSoldner:begin
    // Cassini Soldner projection mapping
    Theta:=ArcSin(SinTheta);
    Vertex^.TexCoord:=TpvVector2.InlineableCreate(
                       (ArcSin((Cos(Phi)*Sin(Theta)))/PI)+0.5,
                       ((ArcTan2(Sin(Phi),Cos(Phi)*Cos(Theta)))/TwoPI)+0.5
                      );
   end;

   else begin
    // No projection mapping (should never happen)
    Vertex^.TexCoord:=TpvVector2.InlineableCreate(0.0,0.0);
   end;

  end;

  // Store the vertex index
  Vertex^.Index:=Index;

 end;

end;

procedure TpvFibonacciSphere.GenerateIndicesParallelForJob(const aJob:PPasMPJob;const aThreadIndex:TPasMPInt32;const aData:pointer;const aFromIndex,aToIndex:TPasMPNativeInt);
var Index:TPasMPNativeInt;
    OtherIndex,CountNearestSamples,CountAdjacentVertices,r,c,k,PreviousK,NextK,
    TriangleIndex:TpvSizeInt;
    IndicesIndex:TpvInt32;
    Z,CosTheta:TpvDouble;
    Vertex:PVertex;
    NearestSamples,AdjacentVertices:array[0..11] of TpvSizeInt;
    v0,v1,v2:TpvFibonacciSphere.PVector;
    WrapX,WrapY:boolean;
    TriangleIndices:array[0..2] of TpvSizeInt;
begin

 for Index:=aFromIndex to aToIndex do begin

  // Get the nearest sample points
  begin

   CosTheta:=1.0-(((Index shl 1) or 1)/fCountPoints);

   z:=Max(0.0,round(0.5*Ln(fCountPoints*PImulSqrt5*(1.0-sqr(CosTheta)))*OneOverLogGoldenRatio));

   CountNearestSamples:=0;

   for OtherIndex:=0 to 11 do begin
    r:=OtherIndex-(((OtherIndex*$56) shr 9)*6); // OtherIndex mod 6
    c:=(5-abs(5-(r shl 1)))+
       (($38 shr r) and 1); // ((r*$56) shr 8); // (r div 3);
    k:=(Round(Pow(GoldenRatio,(z+c)-2)*OneOverSqrt5)*
        (1-((($fc0 shr OtherIndex) and 1) shl 1)) // IfThen(OtherIndex<6,1,-1)
       )+Index;
    if (k>=0) and (k<fCountPoints) and ((fPoints[k]-fPoints[Index]).SquaredLength<=(PImul20overSqrt5/fCountPoints)) then begin
     NearestSamples[CountNearestSamples]:=k;
     inc(CountNearestSamples);
    end;
   end;

  end;

  // Get the adjacent vertices
  begin

   CountAdjacentVertices:=0;

   for OtherIndex:=0 to CountNearestSamples-1 do begin

    k:=NearestSamples[OtherIndex];

    if OtherIndex>0 then begin
     PreviousK:=NearestSamples[OtherIndex-1];
    end else begin
     PreviousK:=NearestSamples[CountNearestSamples-1];
    end;

    if (OtherIndex+1)<CountNearestSamples then begin
     NextK:=NearestSamples[OtherIndex+1];
    end else begin
     NextK:=NearestSamples[0];
    end;

    if fPoints[PreviousK].SquaredDistance(fPoints[NextK])>fPoints[k].SquaredDistance(fPoints[Index]) then begin
     AdjacentVertices[CountAdjacentVertices]:=k;
     inc(CountAdjacentVertices);
    end;

   end;

{  if (Index=0) and (CountAdjacentVertices>0) then begin
    dec(CountAdjacentVertices); // Special case for the pole
   end;}

  end;

  // Generate and add triangle indices from the adjacent neighbours
  begin

   for OtherIndex:=0 to CountAdjacentVertices-1 do begin

    TriangleIndices[0]:=Index;

    TriangleIndices[1]:=AdjacentVertices[OtherIndex];

    if (OtherIndex+1)<CountAdjacentVertices then begin
     TriangleIndices[2]:=AdjacentVertices[OtherIndex+1];
    end else begin
     TriangleIndices[2]:=AdjacentVertices[0];
    end;

    // Avoid duplicate triangles, so only add triangles with vertices in ascending positive order
    if (TriangleIndices[1]>TriangleIndices[0]) and (TriangleIndices[2]>TriangleIndices[0]) then begin

     v0:=@fPoints[TriangleIndices[0]];
     v1:=@fPoints[TriangleIndices[1]];
     v2:=@fPoints[TriangleIndices[2]];

     if fFixTextureCoordinateSeams then begin
      // Check for if the texture x coordinates have a large jump (indicating a wrap around the seam).
      // If so, the vertices of that triangle will be duplicated and its texture coordinates adjusted for
      // a repeating texture sampler.
      WrapX:=(abs(fVertices.ItemArray[TriangleIndices[1]].TexCoord.x-fVertices.ItemArray[TriangleIndices[0]].TexCoord.x)>0.5) or
             (abs(fVertices.ItemArray[TriangleIndices[2]].TexCoord.x-fVertices.ItemArray[TriangleIndices[1]].TexCoord.x)>0.5) or
             (abs(fVertices.ItemArray[TriangleIndices[0]].TexCoord.x-fVertices.ItemArray[TriangleIndices[2]].TexCoord.x)>0.5);
      WrapY:=(abs(fVertices.ItemArray[TriangleIndices[1]].TexCoord.y-fVertices.ItemArray[TriangleIndices[0]].TexCoord.y)>0.5) or
             (abs(fVertices.ItemArray[TriangleIndices[2]].TexCoord.y-fVertices.ItemArray[TriangleIndices[1]].TexCoord.y)>0.5) or
             (abs(fVertices.ItemArray[TriangleIndices[0]].TexCoord.y-fVertices.ItemArray[TriangleIndices[2]].TexCoord.y)>0.5);
      if WrapX or WrapY then begin
       for TriangleIndex:=0 to 2 do begin
        if (WrapX and (fVertices.ItemArray[TriangleIndices[TriangleIndex]].TexCoord.x>0.5)) or
           (WrapY and (fVertices.ItemArray[TriangleIndices[TriangleIndex]].TexCoord.y>0.5)) then begin
         TPasMPMultipleReaderSingleWriterSpinLock.AcquireWrite(fWrappedIndicesLock);
         try
          if fWrappedIndices[TriangleIndices[TriangleIndex]]<0 then begin
           fWrappedIndices[TriangleIndices[TriangleIndex]]:=fVertices.AddNewIndex;
           Vertex:=@fVertices.ItemArray[fWrappedIndices[TriangleIndices[TriangleIndex]]];
           Vertex^:=fVertices.ItemArray[TriangleIndices[TriangleIndex]];
           if WrapX and (fVertices.ItemArray[TriangleIndices[TriangleIndex]].TexCoord.x>0.5) then begin
            Vertex^.TexCoord.x:=Vertex^.TexCoord.x-1.0;
           end;
           if WrapY and (fVertices.ItemArray[TriangleIndices[TriangleIndex]].TexCoord.y>0.5) then begin
            Vertex^.TexCoord.y:=Vertex^.TexCoord.y-1.0;
           end;
          end;
          TriangleIndices[TriangleIndex]:=fWrappedIndices[TriangleIndices[TriangleIndex]];
         finally
          TPasMPMultipleReaderSingleWriterSpinLock.ReleaseWrite(fWrappedIndicesLock);
         end;
        end;
       end;
      end;
     end;

     // Only add triangles with vertices in counter-clockwise order
     if ((v1^-v0^).Cross(v2^-v0^)).Dot(v0^)<0.0 then begin
      TpvSwap<TpvSizeInt>.Swap(TriangleIndices[1],TriangleIndices[2]);
     end;

     IndicesIndex:=TPasMPInterlocked.Add(fCountIndices,3);
     fIndices.ItemArray[IndicesIndex+0]:=TriangleIndices[0];
     fIndices.ItemArray[IndicesIndex+1]:=TriangleIndices[1];
     fIndices.ItemArray[IndicesIndex+2]:=TriangleIndices[2];

    end;

   end;

  end;

 end;

end;

procedure TpvFibonacciSphere.Generate(const aUseGoldenRatio:Boolean;const aFixTextureCoordinateSeams:Boolean;const aPasMPInstance:TPasMP);
begin
 
 fPoints:=nil;
 fPhis:=nil;
 fWrappedIndices:=nil;
 try

  SetLength(fPoints,fCountPoints);
  SetLength(fPhis,fCountPoints);
  SetLength(fWrappedIndices,fCountPoints);

  FillChar(fWrappedIndices[0],fCountPoints*SizeOf(TpvSizeInt),#$ff); // fill with -1 values

  // Generate vertices (the comparatively yet easy part)
  begin

   fVertices.Resize(fCountPoints);

   fUseGoldenRatio:=aUseGoldenRatio;

   if assigned(aPasMPInstance) then begin
    aPasMPInstance.Invoke(aPasMPInstance.ParallelFor(nil,0,fCountPoints-1,GenerateVerticesParallelForJob,1,PasMPDefaultDepth,nil));
   end else begin
    GenerateVerticesParallelForJob(nil,0,nil,0,fCountPoints-1);
   end;

  end;

  // Generate indices (the not so easy part) 
  begin 

   fIndices.Resize(fCountPoints*36);

   fFixTextureCoordinateSeams:=aFixTextureCoordinateSeams;

   fCountIndices:=0;

   fWrappedIndicesLock:=0;

   if assigned(aPasMPInstance) then begin
    aPasMPInstance.Invoke(aPasMPInstance.ParallelFor(nil,0,fCountPoints-1,GenerateIndicesParallelForJob,1,PasMPDefaultDepth,nil));
   end else begin
    GenerateIndicesParallelForJob(nil,0,nil,0,fCountPoints-1);
   end;

   fIndices.Resize(fCountIndices);

  end;

  fVertices.Finish;
  fIndices.Finish;

 finally
  fPoints:=nil;
  fPhis:=nil;
  fWrappedIndices:=nil;
 end; 

end;

procedure TpvFibonacciSphere.ExportToOBJ(const aStream:TStream);
const NewLine:TpvUTF8String={$ifdef Windows}#13#10{$else}#10{$endif};
 procedure WriteString(const aString:TpvUTF8String);
 begin
  aStream.WriteBuffer(aString[1],Length(aString));
 end;
var Index:TpvSizeInt;
    Vertex:PVertex;
    s:TpvUTF8String;
begin

 WriteString('# This OBJ file was generated by PasVulkan.Geometry.FibonacciSphere'+NewLine);
 WriteString('o FibonacciSphere'+NewLine);
 for Index:=0 to fVertices.Count-1 do begin
  Vertex:=@fVertices.ItemArray[Index];
  s:='v '+ConvertDoubleToString(Vertex^.Position.x)+' '+ConvertDoubleToString(Vertex^.Position.y)+' '+ConvertDoubleToString(Vertex^.Position.z)+NewLine;
  WriteString(s);
 end;
 for Index:=0 to fVertices.Count-1 do begin
  Vertex:=@fVertices.ItemArray[Index];
  s:='vn '+ConvertDoubleToString(Vertex^.Normal.x)+' '+ConvertDoubleToString(Vertex^.Normal.y)+' '+ConvertDoubleToString(Vertex^.Normal.z)+NewLine;
  WriteString(s);
 end;
 for Index:=0 to fVertices.Count-1 do begin
  Vertex:=@fVertices.ItemArray[Index];
  s:='vt '+ConvertDoubleToString(Vertex^.TexCoord.x)+' '+ConvertDoubleToString(Vertex^.TexCoord.y)+NewLine;
  WriteString(s);
 end;

 for Index:=0 to (fIndices.Count div 3)-1 do begin
  s:='f '+IntToStr(fIndices[(Index*3)+0]+1)+'/'+IntToStr(fIndices[(Index*3)+0]+1)+'/'+IntToStr(fIndices[(Index*3)+0]+1)+' '+
          IntToStr(fIndices[(Index*3)+1]+1)+'/'+IntToStr(fIndices[(Index*3)+1]+1)+'/'+IntToStr(fIndices[(Index*3)+1]+1)+' '+
          IntToStr(fIndices[(Index*3)+2]+1)+'/'+IntToStr(fIndices[(Index*3)+2]+1)+'/'+IntToStr(fIndices[(Index*3)+2]+1)+NewLine;
  WriteString(s);
 end; 
 
end;

procedure TpvFibonacciSphere.ExportToOBJ(const aFileName:TpvUTF8String);
var Stream:TFileStream;
begin
 Stream:=TFileStream.Create(aFileName,fmCreate);
 try
  ExportToOBJ(Stream);
 finally
  FreeAndNil(Stream);
 end;
end; 

procedure GenerateFibonacciSphere(const aCountPoints:TpvSizeInt;out aVertices:TpvVector3DynamicArray;out aTexCoords:TpvVector2DynamicArray;out aIndices:TpvUInt32DynamicArray;const aRadius:TpvFloat=1.0);
var FibonacciSphere:TpvFibonacciSphere;
    Index:TpvSizeInt;
    Vertex:TpvFibonacciSphere.PVertex;
begin

 FibonacciSphere:=TpvFibonacciSphere.Create(aCountPoints,aRadius,TpvFibonacciSphere.TTextureProjectionMapping.Equirectangular);
 try
  
  FibonacciSphere.Generate;
  
  SetLength(aVertices,FibonacciSphere.Vertices.Count);
  SetLength(aTexCoords,FibonacciSphere.Vertices.Count);
  SetLength(aIndices,FibonacciSphere.Indices.Count);
  
  for Index:=0 to FibonacciSphere.Vertices.Count-1 do begin
   Vertex:=@FibonacciSphere.Vertices.ItemArray[Index];
   aVertices[Index]:=TpvVector3.InlineableCreate(Vertex^.Position.x,Vertex^.Position.y,Vertex^.Position.z);
   aTexCoords[Index]:=TpvVector2.InlineableCreate(Vertex^.TexCoord.x,Vertex^.TexCoord.y);
  end;
  
  for Index:=0 to FibonacciSphere.Indices.Count-1 do begin
   aIndices[Index]:=FibonacciSphere.Indices.ItemArray[Index];
  end;

 finally
  FreeAndNil(FibonacciSphere);
 end;

 FixWrapAroundUVs(aVertices,aTexCoords,aIndices);

end;

end.
