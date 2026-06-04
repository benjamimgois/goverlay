program brdflookuptexturegenerator;
{$ifdef fpc}
 {$mode delphi}
{$endif}
{$apptype console}

uses SysUtils,
     Classes,
     Math,
     PasMP in '..\..\..\externals\pasmp\src\PasMP.pas',
     PUCU in '..\..\..\externals\pucu\src\PUCU.pas',
     Vulkan in '..\..\Vulkan.pas',
     PasVulkan.CPU.Info in '..\..\PasVulkan.CPU.Info.pas',
     PasVulkan.Types in '..\..\PasVulkan.Types.pas',
     PasVulkan.Math in '..\..\PasVulkan.Math.pas',
     PasVulkan.Compression.Deflate in '..\..\PasVulkan.Compression.Deflate.pas',
     PasVulkan.Image.PNG in '..\..\PasVulkan.Image.PNG.pas';

const NumSamples=4096;

      Width=512;
      Height=512;

type PFloat=^TFloat;
     TFloat=double;

     PTexel=^TTexel;
     TTexel=packed record
      r,g:TFloat;
     end;

     PVector2=^TVector2;
     TVector2=record
      x,y,z:TFloat;
     end;

     PVector3=^TVector3;
     TVector3=record
      x,y,z:TFloat;
     end;

function Hammersley(const Index,NumSamples:Int32):TVector2;
const fDiv4294967296=1.0/4294967296; // 2.3283064365386963e-10
var ReversedIndex:longword;
begin
 ReversedIndex:=Index;
 ReversedIndex:=(ReversedIndex shl 16) or (ReversedIndex shr 16);
 ReversedIndex:=((ReversedIndex and $00ff00ff) shl 8) or ((ReversedIndex and $ff00ff00) shr 8);
 ReversedIndex:=((ReversedIndex and $0f0f0f0f) shl 4) or ((ReversedIndex and $f0f0f0f0) shr 4);
 ReversedIndex:=((ReversedIndex and $33333333) shl 2) or ((ReversedIndex and $cccccccc) shr 2);
 ReversedIndex:=((ReversedIndex and $55555555) shl 1) or ((ReversedIndex and $aaaaaaaa) shr 1);
 result.x:=Index/NumSamples;
 result.y:=ReversedIndex*fDiv4294967296;
end;

function ImportanceSampleGGX(const e:TVector2;const Roughness:TFloat):TVector3;
var m,m2,phi,cosTheta,sinTheta:TFloat;
begin
 m:=sqr(Roughness);
 m2:=sqr(m);
 phi:=(2.0*3.1415926535897932384626433832795)*e.x;
 cosTheta:=sqrt((1.0-e.y)/(1.0+((m2-1.0)*e.y)));
 sinTheta:=sqrt(1.0-sqr(cosTheta));
 result.x:=sinTheta*cos(phi);
 result.y:=sinTheta*sin(phi);
 result.z:=cosTheta;
end;

function GVisSchlick(const Roughness,nDotV,nDotL:TFloat):TFloat;
var k:TFloat;
begin
 k:=sqr(Roughness)*0.5;
 result:=0.25/(((nDotV*(1.0-k))+k)*((nDotL*(1.0-k))+k));
end;

function GVisSmith(const Roughness,nDotV,nDotL:TFloat):TFloat;
var a,a2:TFloat;
begin
 a:=sqr(Roughness);
 a2:=sqr(a);
 result:=1.0/((nDotV+sqrt((nDotV*(nDotV-(nDotV*a2)))+a2))*
              (nDotL+sqrt((nDotL*(nDotL-(nDotL*a2)))+a2)));
end;

var RGBA:array[0..Height-1,0..Width-1,0..3] of byte;

procedure SaveAsTGA;
type TTGAFileHeader=packed record
      Type_:byte;
      ColorMapType:byte;
      ImageType:byte;
      ColorMapSpec:array[0..4] of byte;
      OrigX:word;
      OrigY:word;
      Width:word;
      Height:word;
      Bpp:byte;
      ImageDes:byte;
     end;
var w,h,s,i:Int32;
    TGAFileHeader:TTGAFileHeader;
    FileStream:TFileStream;
    p:pointer;
    pl:plongword;
begin
 w:=Width;
 h:=Height;
 s:=(w*h)*SizeOf(longword);
 if s>0 then begin
  GetMem(p,s);
  try
   FileStream:=TFileStream.Create('enviblbrdf.tga',fmCreate);
   try
    FillChar(TGAFileHeader,SizeOf(TTGAFileHeader),AnsiChar(#0));
    TGAFileHeader.ImageType:=2;
    TGAFileHeader.Width:=w;
    TGAFileHeader.Height:=h;
    TGAFileHeader.Bpp:=32;
    Move(RGBA,p^,s);
    pl:=p;
    for i:=1 to w*h do begin
     pl^:=(((pl^ and $000000ff) shl 16) or
           ((pl^ and $00ff0000) shr 16)) or
          (pl^ and $ff00ff00);
     inc(pl);
    end;
    FileStream.Write(TGAFileHeader,sizeof(TTGAFileHeader));
    FileStream.Write(p^,s);
   finally
    FileStream.Free;
   end;
  finally
   FreeMem(p);
  end;
 end;
end;

var RGBA16:array[0..Height-1,0..Width-1,0..3] of word;

procedure SaveAsPNG;
begin
 SavePNGImageAsFile(@RGBA16,Width,Height,'enviblbrdf16.png',TpvPNGPixelFormat.R16G16B16A16,false);
 SavePNGImageAsFile(@RGBA,Width,Height,'enviblbrdf8.png',TpvPNGPixelFormat.R8G8B8A8,false);
end;

{var RG:array[0..Height-1,0..Width-1,0..1] of word;
    M:array[0..Height-1,0..Width-1] of byte;

procedure SaveAsBIN;
type TBINFileHeader=packed record
      Width:word;
      Height:word;
     end;
var BINFileHeader:TBINFileHeader;
    Stream,FileStream:TStream;
    i,j,x,y:Int32;
    l,n:byte;
begin
 Stream:=TMemoryStream.Create;
 try
  FileStream:=TFileStream.Create('enviblbrdf.bin',fmCreate);
  try
   FillChar(BINFileHeader,SizeOf(TBINFileHeader),AnsiChar(#0));
   BINFileHeader.Width:=Width;
   BINFileHeader.Height:=Height;
   Stream.Write(BINFileHeader,sizeof(TBINFileHeader));
   for i:=0 to 1 do begin
    for j:=0 to 1 do begin
     l:=0;
     for y:=0 to Height-1 do begin
      for x:=0 to Width-1 do begin
       n:=(RG[y,x,i] shr (j shl 3)) and $ff;
       M[y,x]:=n-l;
       l:=n;
      end;
     end;
     Stream.Write(M,SizeOf(M));
    end;
   end;
   Stream.Seek(0,soBeginning);
   CompressLZMA(Stream,FileStream,LZMACompressionLevelUltra,nil);
  finally
   FileStream.Free;
  end;
 finally
  Stream.Free;
 end;
end;           }

var BRDF:array[0..Height-1,0..Width-1] of TTexel;
    Process:Int32=0;

procedure ParallelForJobFunction(const Job:PPasMPJob;const ThreadIndex:longint;const Data:pointer;const FromIndex,ToIndex:TPasMPNativeInt);
var Index,x,y,SampleIndex:TPasMPNativeInt;
    Roughness,nDotV,vDotH,vDotHTwo,nDotL,nDotH,GVis,nDotLGVisPDF,Fc:TFloat;
    CurrentTexel:PTexel;
    E:TVector2;
    V,H,L:TVector3;
begin
 SetExceptionMask([exInvalidOp,exDenormalized,exZeroDivide,exOverflow,exUnderflow,exPrecision]);
 SetPrecisionMode(pmDOUBLE);
 SetRoundMode(rmNEAREST);
 for Index:=FromIndex to ToIndex do begin
  y:=Index div Width;
  x:=Index-(y*Width);
  nDotV:=(y+0.375)/(Height-0.625);
  V.x:=sqrt(1.0-sqr(nDotV));
  V.y:=0.0;
  V.z:=nDotV;
  Roughness:=(x+0.375)/(Width-0.625);
  CurrentTexel:=@BRDF[y,x];
  CurrentTexel^.r:=0;
  CurrentTexel^.g:=0;
  for SampleIndex:=0 to NumSamples-1 do begin
   E:=Hammersley(SampleIndex,NumSamples);
   H:=ImportanceSampleGGX(E,Roughness);
   vDotH:=(V.x*H.x)+(V.y*H.y)+(V.z*H.z);
   vDotHTwo:=vDotH*2.0;
   L.x:=(vDotHTwo*H.x)-V.x;
   L.y:=(vDotHTwo*H.y)-V.y;
   L.z:=(vDotHTwo*H.z)-V.z;
   nDotL:=L.z;
   if nDotL>0.0 then begin
    if nDotL<0.0 then begin
     nDotL:=0.0;
    end else if nDotL>1.0 then begin
     nDotL:=1.0;
    end;
    if vDotH<0.0 then begin
     vDotH:=0.0;
    end else if vDotH>1.0 then begin
     vDotH:=1.0;
    end;
    nDotH:=H.z;
    if nDotH<0.0 then begin
     nDotH:=0.0;
    end else if nDotH>1.0 then begin
     nDotH:=1.0;
    end;
//   GVis:=GVisSchlick(Roughness,nDotV,nDotL);
    GVis:=GVisSmith(Roughness,nDotV,nDotL);
    nDotLGVisPDF:=nDotL*GVis*((4.0*vDotH)/nDotH);
    Fc:=power(1.0-vDotH,5.0);
    CurrentTexel^.r:=CurrentTexel^.r+((1.0-Fc)*nDotLGVisPDF);
    CurrentTexel^.g:=CurrentTexel^.g+(Fc*nDotLGVisPDF);
   end;
  end;
  CurrentTexel^.r:=Min(Max(CurrentTexel^.r/NumSamples,0.0),1.0);
  CurrentTexel^.g:=Min(Max(CurrentTexel^.g/NumSamples,0.0),1.0);
  RGBA[y,x,0]:=Min(Max(round(CurrentTexel^.r*255.0),0),255);
  RGBA[y,x,1]:=Min(Max(round(CurrentTexel^.g*255.0),0),255);
  RGBA[y,x,2]:=0;
  RGBA[y,x,3]:=255;
  RGBA16[y,x,0]:=Min(Max(round(CurrentTexel^.r*65535.0),0),65535);
  RGBA16[y,x,1]:=Min(Max(round(CurrentTexel^.g*65535.0),0),65535);
  RGBA16[y,x,2]:=0;
  RGBA16[y,x,3]:=65535;
{  RG[y,x,0]:=Min(Max(round(CurrentTexel^.r*65535.0),0),65535);
  RG[y,x,1]:=Min(Max(round(CurrentTexel^.g*65535.0),0),65535);}
  TPasMPInterlocked.Increment(Process);
 end;
end;

var MaxProcess:Int32;
    Job:PPasMPJob;
begin
 SetExceptionMask([exInvalidOp,exDenormalized,exZeroDivide,exOverflow,exUnderflow,exPrecision]);
 SetPrecisionMode(pmDOUBLE);
 SetRoundMode(rmNEAREST);
 write('Calculating... ');
 TPasMP.CreateGlobalInstance;
 Job:=GlobalPasMP.ParallelFor(nil,0,(Width*Height)-1,ParallelForJobFunction,16,8);
 Process:=0;
 MaxProcess:=Width*Height;
 GlobalPasMP.Run(Job);
 while Process<MaxProcess do begin
  write(#13'Calculating... ',((Process*100)/MaxProcess):7:2,'%');
  Sleep(100);
 end;
 GlobalPasMP.WaitRelease(Job);
 write(#13'Calculating... saving...   ');
 SaveAsTGA;
 SaveAsPNG;
 writeln(#13'Calculating... done!       ');
end.


