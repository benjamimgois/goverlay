unit UnitOpenGLFrameBufferObject;
{$ifdef fpc}
 {$mode delphi}
{$endif}

interface

uses SysUtils,Classes,Math,{$ifdef fpcgl}gl,glext,{$else}dglOpenGL{$endif};

const CubeMapTexs:array[0..5] of longword=(GL_TEXTURE_CUBE_MAP_POSITIVE_X,
                                           GL_TEXTURE_CUBE_MAP_NEGATIVE_X,
                                           GL_TEXTURE_CUBE_MAP_POSITIVE_Y,
                                           GL_TEXTURE_CUBE_MAP_NEGATIVE_Y,
                                           GL_TEXTURE_CUBE_MAP_POSITIVE_Z,
                                           GL_TEXTURE_CUBE_MAP_NEGATIVE_Z);

      CubeMapDirs:array[0..5,0..2] of single=((1,0,0),
                                              (-1,0,0),
                                              (0,1,0),
                                              (0,-1,0),
                                              (0,0,1),
                                              (0,0,-1));

      CubeMapUps:array[0..5,0..2] of single=((0,-1,0),
                                             (0,-1,0),
                                             (0,0,1),
                                             (0,0,-1),
                                             (0,-1,0),
                                             (0,-1,0));

{     CubeMapMatrices:array[0..5] of TMatrix4x4=
       (((0.0,0.0,-1.0,0.0),(0.0,-1.0,0.0,0.0),(-1.0,0.0,0.0,0.0),(0,0,0,1.0)),  // pos x
        ((0.0,0.0,1.0,0.0),(0.0,-1.0,0.0,0.0),(1.0,0.0,0.0,0.0),(0,0,0,1.0)),    // neg x
        ((1.0,0.0,0.0,0.0),(0.0,0.0,-1.0,0.0),(0.0,1.0,0.0,0.0),(0,0,0,1.0)),    // pos y
        ((1.0,0.0,0.0,0.0),(0.0,0.0,1.0,0.0),(0.0,-1.0,0.0,0.0),(0,0,0,1.0)),    // neg y
        ((1.0,0.0,0.0,0.0),(0.0,-1.0,0.0,0.0),(0.0,0.0,-1.0,0.0),(0,0,0,1.0)),   // pos z
        ((-1.0,0.0,0.0,0.0),(0.0,-1.0,0.0,0.0),(0.0,0.0,1.0,0.0),(0,0,0,1.0)));  // neg z
 }
{$ifdef gles20}
      GL_COLOR_ATTACHMENT0=$8CE0;
      GL_COLOR_ATTACHMENT1=$8CE1;
      GL_COLOR_ATTACHMENT2=$8CE2;
      GL_COLOR_ATTACHMENT3=$8CE3;
      GL_COLOR_ATTACHMENT4=$8CE4;
      GL_COLOR_ATTACHMENT5=$8CE5;
      GL_COLOR_ATTACHMENT6=$8CE6;
      GL_COLOR_ATTACHMENT7=$8CE7;
      GL_COLOR_ATTACHMENT8=$8CE8;
      GL_COLOR_ATTACHMENT9=$8CE9;
      GL_COLOR_ATTACHMENT10=$8CEA;
      GL_COLOR_ATTACHMENT11=$8CEB;
      GL_COLOR_ATTACHMENT12=$8CEC;
      GL_COLOR_ATTACHMENT13=$8CED;
      GL_COLOR_ATTACHMENT14=$8CEE;
      GL_COLOR_ATTACHMENT15=$8CEF;
{$endif}

      DrawBuffers:array[0..15] of TGlEnum=
       (GL_COLOR_ATTACHMENT0,
        GL_COLOR_ATTACHMENT1,
        GL_COLOR_ATTACHMENT2,
        GL_COLOR_ATTACHMENT3,
        GL_COLOR_ATTACHMENT4,
        GL_COLOR_ATTACHMENT5,
        GL_COLOR_ATTACHMENT6,
        GL_COLOR_ATTACHMENT7,
        GL_COLOR_ATTACHMENT8,
        GL_COLOR_ATTACHMENT9,
        GL_COLOR_ATTACHMENT10,
        GL_COLOR_ATTACHMENT11,
        GL_COLOR_ATTACHMENT12,
        GL_COLOR_ATTACHMENT13,
        GL_COLOR_ATTACHMENT14,
        GL_COLOR_ATTACHMENT15);

      GL_TEXTURE_DEFAULT=-1;
      GL_TEXTURE_RGBA8UB=0;
      GL_TEXTURE_RGBA16US=1;
      GL_TEXTURE_RGBA32UI=2;
      GL_TEXTURE_RGBA16F=3;
      GL_TEXTURE_RGBA32F=4;
      GL_TEXTURE_RGB8UB=5;
      GL_TEXTURE_RGB16US=6;
      GL_TEXTURE_RGB32UI=7;
      GL_TEXTURE_R11G11B10F=8;
      GL_TEXTURE_RGB16F=9;
      GL_TEXTURE_RGB32F=10;
      GL_TEXTURE_R5G6B5=11;
      GL_TEXTURE_RG8UB=12;
      GL_TEXTURE_RG16US=13;
      GL_TEXTURE_RG32UI=14;
      GL_TEXTURE_RG16F=15;
      GL_TEXTURE_RG32F=16;
      GL_TEXTURE_R8UB=17;
      GL_TEXTURE_R16US=18;
      GL_TEXTURE_R32UI=19;
      GL_TEXTURE_R32UINS=20;
      GL_TEXTURE_R16F=21;
      GL_TEXTURE_R32F=22;
      GL_TEXTURE_D16US=23;
      GL_TEXTURE_D24UI=24;
      GL_TEXTURE_D32UI=25;
      GL_TEXTURE_D16F=26;
      GL_TEXTURE_D24F=27;
      GL_TEXTURE_D32F=28;

      FBOFlagRepeat=1 shl 0;
      FBOFlagMipMap=1 shl 1;
      FBOFlagDepthBuffer=1 shl 2;
      FBOFlagMipMapLevelWiseFill=1 shl 3;
      FBOFlagReverseMipMap=1 shl 4;
      FBOFlagDepthBufferTexture=1 shl 5;
      FBOFlagCubeMap=1 shl 6;
      FBOFlagArray=1 shl 7;

      wmGL_CLAMP=0;
      wmGL_CLAMP_TO_BORDER=1;
      wmGL_CLAMP_TO_EDGE=2;
      wmGL_MIRRORED_REPEAT=3;
      wmGL_REPEAT=4;

      WrapModes:array[0..4] of GLint=(GL_CLAMP,
                                      GL_CLAMP_TO_BORDER,
                                      GL_CLAMP_TO_EDGE,
                                      GL_MIRRORED_REPEAT,
                                      GL_REPEAT);

      WrapModeNames:array[0..4] of ansistring=('GL_CLAMP',
                                               'GL_CLAMP_TO_BORDER',
                                               'GL_CLAMP_TO_EDGE',
                                               'GL_MIRRORED_REPEAT',
                                               'GL_REPEAT');

      fmGL_NEAREST=0;
      fmGL_LINEAR=1;
      fmGL_NEAREST_MIPMAP_NEAREST=2;
      fmGL_LINEAR_MIPMAP_NEAREST=3;
      fmGL_NEAREST_MIPMAP_LINEAR=4;
      fmGL_LINEAR_MIPMAP_LINEAR=5;

      FilterModes:array[0..5] of GLint=(GL_NEAREST,
                                        GL_LINEAR,
                                        GL_NEAREST_MIPMAP_NEAREST,
                                        GL_LINEAR_MIPMAP_NEAREST,
                                        GL_NEAREST_MIPMAP_LINEAR,
                                        GL_LINEAR_MIPMAP_LINEAR);

      FilterNames:array[0..5] of ansistring=('GL_NEAREST',
                                             'GL_LINEAR',
                                             'GL_NEAREST_MIPMAP_NEAREST',
                                             'GL_LINEAR_MIPMAP_NEAREST',
                                             'GL_NEAREST_MIPMAP_LINEAR',
                                             'GL_LINEAR_MIPMAP_LINEAR');

type TFrameBufferObject=class
      public
       FrameBuffer:glUInt;
       DepthBuffer:glUInt;
       Width:longint;
       Height:longint;
       Textures:longint;
       TextureHandles:array[0..15] of gluInt;
       HasDepthBuffer:boolean;
       HasDepthTexture:boolean;
       constructor Create(AWidth,AHeight,ATextures:longint;ACubeMap,AClamping,AMirroring,AInterpolation,ADepthBuffer,AHasDepthTexture:boolean);
       destructor Destroy; override;
       procedure Bind;
       procedure Unbind;
     end;

     TFBOData=array of byte;

     PFBOTextureFormats=^TFBOTextureFormats;
     TFBOTextureFormats=array[0..7] of longint;

     PFBO=^TFBO;
     TFBO=record
      ID:word;
      Name:UTF8String;
      Data:TFBOData;
      DataOffset:int64;
      ExternalStorage:longbool;
      Compressed:longbool;
      Resize:longbool;
      Width:longint;
      Height:longint;
      Depth:longint;
      Format:longint;
      SWrapMode:longint;
      TWrapMode:longint;
      RWrapMode:longint;
      MinFilterMode:longint;
      MagFilterMode:longint;
      Textures:longint;
      ExportWidth:longint;
      ExportHeight:longint;
      ExportDepth:longint;
      ExportData:TFBOData;
      WorkWidth:longint;
      WorkHeight:longint;
      WorkDepth:longint;
      WorkColorTextures:longint;
      WorkTextures:longint;
      WorkFormat:longint;
      WorkFormats:TFBOTextureFormats;
      WorkRealFormats:TFBOTextureFormats;
      WorkSWrapMode:longint;
      WorkTWrapMode:longint;
      WorkRWrapMode:longint;
      WorkMinFilterMode:longint;
      WorkMagFilterMode:longint;
      WorkMaxLevel:longint;
      DivFactor:word;
      Flags:longword;
      FBOs:array[0..31] of glUInt;
      DepthBuffer:glUInt;
      TextureHandles:array[0..16] of gluInt;
      TextureFormats:TFBOTextureFormats;
      Active:longbool;
      Dirty:longbool;
      HasNewData:longbool;
     end;

     PTextureFormat=^TTextureFormat;
     TTextureFormat=record
      Name:ansistring;
      ImageInternalFormat:GLint;
      InternalFormat:GLint;
      Format:GLenum;
      Type_:GLenum;
      BitsPerPixel:GLint;
     end;

     PTextureFormats=^TTextureFormats;
     TTextureFormats=array[GL_TEXTURE_RGBA8UB..GL_TEXTURE_D32F] of TTextureFormat;

procedure CreateFrameBuffer(var FBO:TFBO);
procedure DestroyFrameBuffer(var FBO:TFBO);

implementation

const GL_HALF_FLOAT=$140b;

const Targets:array[0..7] of glenum=(GL_COLOR_ATTACHMENT0,
                                     GL_COLOR_ATTACHMENT1,
                                     GL_COLOR_ATTACHMENT2,
                                     GL_COLOR_ATTACHMENT3,
                                     GL_COLOR_ATTACHMENT4,
                                     GL_COLOR_ATTACHMENT5,
                                     GL_COLOR_ATTACHMENT6,
                                     GL_COLOR_ATTACHMENT7);

      TextureFormats:TTextureFormats=(
       (Name:'RGBA8UB';ImageInternalFormat:GL_RGBA8{UI};InternalFormat:GL_RGBA;Format:GL_RGBA;Type_:GL_UNSIGNED_BYTE;BitsPerPixel:32),
       (Name:'RGBA16US';ImageInternalFormat:GL_RGBA16{UI};InternalFormat:GL_RGBA;Format:GL_RGBA;Type_:GL_UNSIGNED_SHORT;BitsPerPixel:64),
       (Name:'RGBA32UI';ImageInternalFormat:GL_RGBA32UI;InternalFormat:GL_RGBA;Format:GL_RGBA;Type_:GL_UNSIGNED_INT;BitsPerPixel:128),
       (Name:'RGBA16F';ImageInternalFormat:GL_RGBA16F;InternalFormat:GL_RGBA16F;Format:GL_RGBA;Type_:GL_HALF_FLOAT;BitsPerPixel:64),
       (Name:'RGBA32F';ImageInternalFormat:GL_RGBA32F;InternalFormat:GL_RGBA32F;Format:GL_RGBA;Type_:GL_FLOAT;BitsPerPixel:128),
       (Name:'RGB8UB';ImageInternalFormat:GL_RGB8{UI};InternalFormat:GL_RGB;Format:GL_RGB;Type_:GL_UNSIGNED_BYTE;BitsPerPixel:24),
       (Name:'RGB16US';ImageInternalFormat:GL_RGB16{UI};InternalFormat:GL_RGB;Format:GL_RGB;Type_:GL_UNSIGNED_SHORT;BitsPerPixel:48),
       (Name:'RGB32UI';ImageInternalFormat:GL_RGB32UI;InternalFormat:GL_RGB;Format:GL_RGB;Type_:GL_UNSIGNED_INT;BitsPerPixel:96),
       (Name:'R11G11B10F';ImageInternalFormat:GL_R11F_G11F_B10F;InternalFormat:GL_R11F_G11F_B10F;Format:GL_RGB;Type_:GL_FLOAT;BitsPerPixel:32),
       (Name:'RGB16F';ImageInternalFormat:GL_RGB16F;InternalFormat:GL_RGB16F;Format:GL_RGB;Type_:GL_HALF_FLOAT;BitsPerPixel:48),
       (Name:'RGB32F';ImageInternalFormat:GL_RGB32F;InternalFormat:GL_RGB32F;Format:GL_RGB;Type_:GL_FLOAT;BitsPerPixel:96),
       (Name:'R5G6B5';ImageInternalFormat:GL_R16UI;InternalFormat:GL_RGB;Format:GL_RGB;Type_:GL_UNSIGNED_SHORT_5_6_5;BitsPerPixel:16),
       (Name:'RG8UB';ImageInternalFormat:GL_RG8{UI};InternalFormat:GL_RG;Format:GL_RG;Type_:GL_UNSIGNED_BYTE;BitsPerPixel:16),
       (Name:'RG16US';ImageInternalFormat:GL_RG16{UI};InternalFormat:GL_RG;Format:GL_RG;Type_:GL_UNSIGNED_SHORT;BitsPerPixel:32),
       (Name:'RG32UI';ImageInternalFormat:GL_RG32UI;InternalFormat:GL_RG;Format:GL_RG;Type_:GL_UNSIGNED_INT;BitsPerPixel:64),
       (Name:'RG16F';ImageInternalFormat:GL_RG16F;InternalFormat:GL_RG16F;Format:GL_RG;Type_:GL_HALF_FLOAT;BitsPerPixel:32),
       (Name:'RG32F';ImageInternalFormat:GL_RG32F;InternalFormat:GL_RG32F;Format:GL_RG;Type_:GL_FLOAT;BitsPerPixel:64),
       (Name:'R8UB';ImageInternalFormat:GL_R8{UI};InternalFormat:GL_RED;Format:GL_RED;Type_:GL_UNSIGNED_BYTE;BitsPerPixel:8),
       (Name:'R16US';ImageInternalFormat:GL_R16{UI};InternalFormat:GL_RED;Format:GL_RED;Type_:GL_UNSIGNED_SHORT;BitsPerPixel:16),
       (Name:'R32UI';ImageInternalFormat:GL_R32UI;InternalFormat:GL_RED;Format:GL_RED;Type_:GL_UNSIGNED_INT;BitsPerPixel:32),
       (Name:'R32UINS';ImageInternalFormat:GL_R32UI;InternalFormat:GL_R32UI;Format:GL_RED_INTEGER;Type_:GL_UNSIGNED_INT;BitsPerPixel:32),
       (Name:'R16F';ImageInternalFormat:GL_R16F;InternalFormat:GL_R16F;Format:GL_RED;Type_:GL_HALF_FLOAT;BitsPerPixel:16),
       (Name:'R32F';ImageInternalFormat:GL_R32F;InternalFormat:GL_R32F;Format:GL_RED;Type_:GL_FLOAT;BitsPerPixel:32),
       (Name:'D16US';ImageInternalFormat:GL_R16{GL_DEPTH_COMPONENT16};InternalFormat:GL_DEPTH_COMPONENT16;Format:GL_DEPTH_COMPONENT;Type_:GL_UNSIGNED_SHORT;BitsPerPixel:16),
       (Name:'D24UI';ImageInternalFormat:GL_R32UI{GL_DEPTH_COMPONENT24};InternalFormat:GL_DEPTH_COMPONENT24;Format:GL_DEPTH_COMPONENT;Type_:GL_UNSIGNED_INT;BitsPerPixel:24),
       (Name:'D32UI';ImageInternalFormat:GL_R32UI{GL_DEPTH_COMPONENT32};InternalFormat:GL_DEPTH_COMPONENT24;Format:GL_DEPTH_COMPONENT;Type_:GL_UNSIGNED_INT;BitsPerPixel:32),
       (Name:'D16F';ImageInternalFormat:GL_R16F{GL_DEPTH_COMPONENT16};InternalFormat:GL_DEPTH_COMPONENT16;Format:GL_DEPTH_COMPONENT;Type_:GL_FLOAT;BitsPerPixel:16),
       (Name:'D24F';ImageInternalFormat:GL_R32UI{GL_DEPTH_COMPONENT24};InternalFormat:GL_DEPTH_COMPONENT24;Format:GL_DEPTH_COMPONENT;Type_:GL_FLOAT;BitsPerPixel:24),
       (Name:'D32F';ImageInternalFormat:GL_R32F{GL_DEPTH_COMPONENT32};InternalFormat:GL_DEPTH_COMPONENT24;Format:GL_DEPTH_COMPONENT;Type_:GL_FLOAT;BitsPerPixel:32)
      );

procedure ResizeRGBA32(Src:pointer;SrcWidth,SrcHeight:longint;Dst:pointer;DstWidth,DstHeight:longint);
type PLongwords=^TLongwords;
     TLongwords=array[0..65535] of longword;
var DstX,DstY,SrcX,SrcY:longint;
    r,g,b,a,w,Pixel,SrcR,SrcG,SrcB,SrcA,Weight,xUL,xUR,xLL,xLR,
    RedBlue,GreenAlpha,RedBlueRemainder,GreenAlphaRemainder,WeightX,WeightY:longword;
//  SrcPtr,DstPtr:pansichar;
    TempSrc,TempDst:PLongwords;
    UpsampleX,UpsampleY:longbool;
    WeightShift,xa,xb,xc,xd,ya,yb,yc,yd:longint;
    SourceTexelsPerOutPixel,WeightPerPixel,AccumlatorPerPixel,WeightDivider,fw,fh:single;
    XCache:array of longint;
begin
 XCache:=nil;
 if (SrcWidth=(DstWidth*2)) and (SrcHeight=(DstHeight*2)) then begin
  RedBlueRemainder:=0;
  GreenAlphaRemainder:=0;
  TempDst:=pointer(Dst);
  for DstY:=0 to DstHeight-1 do begin
   SrcY:=DstY*2;
   TempSrc:=pointer(@pansichar(Src)[(SrcY*SrcWidth) shl 2]);
   for DstX:=0 to DstWidth-1 do begin
    xUL:=TempSrc^[0];
    xUR:=TempSrc^[1];
    xLL:=TempSrc^[SrcWidth];
    xLR:=TempSrc^[SrcWidth+1];
    RedBlue:=(xUL and $00ff00ff)+(xUR and $00ff00ff)+(xLL and $00ff00ff)+(xLR and $00ff00ff)+(RedBlueRemainder and $00ff00ff);
    GreenAlpha:=((xUL shr 8) and $00ff00ff)+((xUR shr 8) and $00ff00ff)+((xLL shr 8) and $00ff00ff)+((xLR shr 8) and $00ff00ff)+(GreenAlphaRemainder and $00ff00ff);
    RedBlueRemainder:=RedBlue and $00030003;
    GreenAlphaRemainder:=GreenAlpha and $00030003;
    TempDst[0]:=((RedBlue and $03fc03fc) shr 2) or (((GreenAlpha and $03fc03fc) shr 2) shl 8);
    TempDst:=pointer(@TempDst^[1]);
    TempSrc:=pointer(@TempSrc^[2]);
   end;
  end;
 end else begin
  UpsampleX:=SrcWidth<DstWidth;
  UpsampleY:=DstHeight<DstHeight;
  WeightShift:=0;
  SourceTexelsPerOutPixel:=((SrcWidth/DstWidth)+1)*((SrcHeight/DstHeight)+1);
  WeightPerPixel:=SourceTexelsPerOutPixel*65536;
  AccumlatorPerPixel:=WeightPerPixel*256;
  WeightDivider:=AccumlatorPerPixel/4294967000.0;
  if WeightDivider>1.0 then begin
   WeightShift:=trunc(ceil(ln(WeightDivider)/ln(2.0)));
  end;
  WeightShift:=min(WeightShift,15);
  fw:=(256*SrcWidth)/DstWidth;
  fh:=(256*SrcHeight)/DstHeight;
  if UpsampleX and UpsampleY then begin
   if length(XCache)<longint(DstWidth) then begin
    SetLength(XCache,longint(DstWidth));
   end;
   for DstX:=0 to DstWidth-1 do begin
    XCache[DstX]:=min(trunc(DstX*fw),(256*(SrcWidth-1))-1);
   end;
   for DstY:=0 to DstHeight-1 do begin
    ya:=min(trunc(DstY*fh),(256*(SrcHeight-1))-1);
    yc:=ya shr 8;
    TempDst:=pointer(@pansichar(Dst)[(DstY*DstWidth) shl 2]);
    for DstX:=0 to DstWidth-1 do begin
     xa:=XCache[DstX];
     xc:=xa shr 8;
     TempSrc:=pointer(@pansichar(Src)[((yc*SrcWidth)+xc) shl 2]);
     r:=0;
     g:=0;
     b:=0;
     a:=0;
     WeightX:=longword(longint(256-(xa and $ff)));
     WeightY:=longword(longint(256-(ya and $ff)));
     for SrcY:=0 to 1 do begin
      for SrcX:=0 to 1 do begin
       Pixel:=TempSrc^[(SrcY*SrcWidth)+SrcX];
       SrcR:=(Pixel shr 0) and $ff;
       SrcG:=(Pixel shr 8) and $ff;
       SrcB:=(Pixel shr 16) and $ff;
       SrcA:=(Pixel shr 24) and $ff;
       Weight:=(WeightX*WeightY) shr WeightShift;
       inc(r,SrcR*Weight);
       inc(g,SrcG*Weight);
       inc(b,SrcB*Weight);
       inc(a,SrcA*Weight);
       WeightX:=256-WeightX;
      end;
      WeightY:=256-WeightY;
     end;
     TempDst^[0]:=((r shr 16) and $ff) or ((g shr 8) and $ff00) or (b and $ff0000) or ((a shl 8) and $ff000000);
     TempDst:=pointer(@TempDst^[1]);
    end;
   end;
  end else begin
   if length(XCache)<(longint(DstWidth)*2) then begin
    SetLength(XCache,longint(DstWidth)*2);
   end;
   for DstX:=0 to DstWidth-1 do begin
    xa:=trunc(DstX*fw);
    if UpsampleX then begin
     xb:=xa+256;
    end else begin
     xb:=trunc((DstX+1)*fw);
    end;
    XCache[(DstX shl 1) or 0]:=min(xa,(256*SrcWidth)-1);
    XCache[(DstX shl 1) or 1]:=min(xb,(256*SrcWidth)-1);
   end;
   for DstY:=0 to DstHeight-1 do begin
    ya:=trunc(DstY*fh);
    if UpsampleY then begin
     yb:=ya+256;
    end else begin
     yb:=trunc((DstY+1)*fh);
    end;
    TempDst:=pointer(@pansichar(Dst)[(DstY*DstWidth) shl 2]);
    yc:=ya shr 8;
    yd:=yb shr 8;
    for DstX:=0 to DstWidth-1 do begin
     xa:=XCache[(DstX shl 1) or 0];
     xb:=XCache[(DstX shl 1) or 1];
     xc:=xa shr 8;
     xd:=xb shr 8;
     r:=0;
     g:=0;
     b:=0;
     a:=0;
     w:=0;
     for SrcY:=yc to yd do begin
      if (SrcY<0) or (SrcY>=SrcHeight) then begin
       continue;
      end;
      WeightY:=256;
      if yc<>yd then begin
       if SrcY=yc then begin
        WeightY:=256-(ya and $ff);
       end else if SrcY=yd then begin
        WeightY:=yb and $ff;
       end;
      end;
      TempSrc:=pointer(@pansichar(Src)[((SrcY*SrcWidth)+xc) shl 2]);
      for SrcX:=xc to xd do begin
       if (SrcX<0) or (SrcX>=SrcWidth) then begin
        continue;
       end;
       WeightX:=256;
       if xc<>xd then begin
        if SrcX=xc then begin
         WeightX:=256-(xa and $ff);
        end else if SrcX=xd then begin
         WeightX:=xb and $ff;
        end;
       end;
       Pixel:=TempSrc^[0];
       inc(PAnsiChar(TempSrc),SizeOf(longword));
       SrcR:=(Pixel shr 0) and $ff;
       SrcG:=(Pixel shr 8) and $ff;
       SrcB:=(Pixel shr 16) and $ff;
       SrcA:=(Pixel shr 24) and $ff;
       Weight:=(WeightX*WeightY) shr WeightShift;
       inc(r,SrcR*Weight);
       inc(g,SrcG*Weight);
       inc(b,SrcB*Weight);
       inc(a,SrcA*Weight);
       inc(w,Weight);
      end;
     end;
     if w>0 then begin
      TempDst^[0]:=((r div w) and $ff) or (((g div w) shl 8) and $ff00) or (((b div w) shl 16) and $ff0000) or (((a div w) shl 24) and $ff000000);
     end else begin
      TempDst^[0]:=0;
     end;
     TempDst:=pointer(@TempDst^[1]);
    end;
   end;
  end;
 end;
 SetLength(XCache,0);
end;

procedure CreateFrameBuffer(var FBO:TFBO);
var i,j,k,l,bp,Width,Height,Depth,Textures,MaxLevel:longint;
    MirrorRepeating,MipMapping,DepthBuffer,MipMapLevelWiseFill,
    DepthBufferTexture,CubeMap,ArrayFBO:boolean;
    Formats:TFBOTextureFormats;
    FBOData:TFBOData;
    pa,pb:^byte;
begin
 Width:=FBO.Width;
 Height:=FBO.Height;
 Depth:=FBO.Depth;
 Textures:=FBO.Textures;
 MirrorRepeating:=(FBO.Flags and FBOFlagRepeat)<>0;
 MipMapping:=(FBO.Flags and FBOFlagMipMap)<>0;
 DepthBuffer:=(FBO.Flags and FBOFlagDepthBuffer)<>0;
 MipMapLevelWiseFill:=(FBO.Flags and FBOFlagMipMapLevelWiseFill)<>0;
 DepthBufferTexture:=(FBO.Flags and FBOFlagDepthBufferTexture)<>0;
 CubeMap:=(FBO.Flags and FBOFlagCubeMap)<>0;
 ArrayFBO:=(FBO.Flags and FBOFlagArray)<>0;
 if MipMapping and MipMapLevelWiseFill then begin
  if (Depth<1) or ArrayFBO then begin
   MaxLevel:=trunc(log2(Min(Width,Height)));
  end else begin
   MaxLevel:=trunc(log2(Min(Min(Width,Height),Depth)));
  end;
 end else begin
  MaxLevel:=0;
 end;
 FBO.WorkWidth:=Width;
 FBO.WorkHeight:=Height;
 FBO.WorkDepth:=Depth;
 FBO.WorkColorTextures:=Textures;
 FBO.WorkTextures:=Textures;
 FBO.WorkFormat:=FBO.Format;
 FBO.WorkFormats:=FBO.TextureFormats;
 FBO.WorkSWrapMode:=FBO.SWrapMode;
 FBO.WorkTWrapMode:=FBO.TWrapMode;
 FBO.WorkRWrapMode:=FBO.RWrapMode;
 FBO.WorkMinFilterMode:=FBO.MinFilterMode;
 FBO.WorkMagFilterMode:=FBO.MagFilterMode;
 FBO.WorkMaxLevel:=MaxLevel;
 FBO.DepthBuffer:=0;

 Formats:=FBO.TextureFormats;
 for i:=low(Formats) to high(Formats) do begin
  if Formats[i]<0 then begin
   Formats[i]:=FBO.Format;
  end;
 end;

 FBO.WorkRealFormats:=Formats;

 if length(FBO.Data)>0 then begin
  glPixelStorei(GL_UNPACK_ALIGNMENT,(TextureFormats[Formats[0]].BitsPerPixel+7) shr 3);
 end else begin
  glPixelStorei(GL_UNPACK_ALIGNMENT,1);
 end;

 if DepthBuffer then begin
  if DepthBufferTexture then begin
   FBO.WorkTextures:=FBO.WorkColorTextures+1;
   glGenTextures(1,@FBO.TextureHandles[FBO.WorkTextures-1]);
   if CubeMap then begin
    if ArrayFBO then begin
     glBindTexture(GL_TEXTURE_CUBE_MAP_ARRAY,FBO.TextureHandles[FBO.WorkTextures-1]);
     glTexParameteri(GL_TEXTURE_CUBE_MAP_ARRAY,GL_TEXTURE_MAG_FILTER,FilterModes[FBO.MagFilterMode]);
     glTexParameteri(GL_TEXTURE_CUBE_MAP_ARRAY,GL_TEXTURE_MIN_FILTER,FilterModes[FBO.MinFilterMode]);
     if MirrorRepeating then begin
      glTexParameteri(GL_TEXTURE_CUBE_MAP_ARRAY,GL_TEXTURE_WRAP_S,GL_MIRRORED_REPEAT);
      glTexParameteri(GL_TEXTURE_CUBE_MAP_ARRAY,GL_TEXTURE_WRAP_T,GL_MIRRORED_REPEAT);
      glTexParameteri(GL_TEXTURE_CUBE_MAP_ARRAY,GL_TEXTURE_WRAP_R,GL_MIRRORED_REPEAT);
     end else begin
      glTexParameteri(GL_TEXTURE_CUBE_MAP_ARRAY,GL_TEXTURE_WRAP_S,WrapModes[FBO.SWrapMode]);
      glTexParameteri(GL_TEXTURE_CUBE_MAP_ARRAY,GL_TEXTURE_WRAP_T,WrapModes[FBO.TWrapMode]);
      glTexParameteri(GL_TEXTURE_CUBE_MAP_ARRAY,GL_TEXTURE_WRAP_R,WrapModes[FBO.TWrapMode]);
     end;
     glTexParameteri(GL_TEXTURE_CUBE_MAP_ARRAY,GL_DEPTH_TEXTURE_MODE,GL_LUMINANCE);
     glTexParameteri(GL_TEXTURE_CUBE_MAP_ARRAY,GL_TEXTURE_COMPARE_MODE,GL_NONE);
     glTexParameteri(GL_TEXTURE_CUBE_MAP_ARRAY,GL_TEXTURE_COMPARE_FUNC,GL_ALWAYS);
     if MipMapping and MipMapLevelWiseFill then begin
      glTexParameteri(GL_TEXTURE_CUBE_MAP_ARRAY,GL_TEXTURE_BASE_LEVEL,0);
      glTexParameteri(GL_TEXTURE_CUBE_MAP_ARRAY,GL_TEXTURE_MAX_LEVEL,MaxLevel);
      glTexParameteri(GL_TEXTURE_CUBE_MAP_ARRAY,GL_GENERATE_MIPMAP,0);
      for j:=0 to MaxLevel do begin
       for i:=low(CubeMapTexs) to high(CubeMapTexs) do begin
        glTexImage3D(CubeMapTexs[i],0,GL_DEPTH_COMPONENT32F,FBO.WorkWidth shr j,FBO.WorkHeight shr j,FBO.WorkDepth,0,GL_DEPTH_COMPONENT,GL_FLOAT,nil);
       end;
      end;
     end else begin
      for i:=low(CubeMapTexs) to high(CubeMapTexs) do begin
       glTexImage3D(CubeMapTexs[i],0,GL_DEPTH_COMPONENT32F,FBO.WorkWidth,FBO.WorkHeight,FBO.WorkDepth,0,GL_DEPTH_COMPONENT,GL_FLOAT,nil);
      end;
      if MipMapping then begin
       glGenerateMipmap(GL_TEXTURE_CUBE_MAP_ARRAY);
      end;
     end;
    end else begin
     glBindTexture(GL_TEXTURE_CUBE_MAP,FBO.TextureHandles[FBO.WorkTextures-1]);
     glTexParameteri(GL_TEXTURE_CUBE_MAP,GL_TEXTURE_MAG_FILTER,FilterModes[FBO.MagFilterMode]);
     glTexParameteri(GL_TEXTURE_CUBE_MAP,GL_TEXTURE_MIN_FILTER,FilterModes[FBO.MinFilterMode]);
     if MirrorRepeating then begin
      glTexParameteri(GL_TEXTURE_CUBE_MAP,GL_TEXTURE_WRAP_S,GL_MIRRORED_REPEAT);
      glTexParameteri(GL_TEXTURE_CUBE_MAP,GL_TEXTURE_WRAP_T,GL_MIRRORED_REPEAT);
      glTexParameteri(GL_TEXTURE_CUBE_MAP,GL_TEXTURE_WRAP_R,GL_MIRRORED_REPEAT);
     end else begin
      glTexParameteri(GL_TEXTURE_CUBE_MAP,GL_TEXTURE_WRAP_S,WrapModes[FBO.SWrapMode]);
      glTexParameteri(GL_TEXTURE_CUBE_MAP,GL_TEXTURE_WRAP_T,WrapModes[FBO.TWrapMode]);
      glTexParameteri(GL_TEXTURE_CUBE_MAP,GL_TEXTURE_WRAP_R,WrapModes[FBO.TWrapMode]);
     end;
     glTexParameteri(GL_TEXTURE_CUBE_MAP,GL_DEPTH_TEXTURE_MODE,GL_LUMINANCE);
     glTexParameteri(GL_TEXTURE_CUBE_MAP,GL_TEXTURE_COMPARE_MODE,GL_NONE);
     glTexParameteri(GL_TEXTURE_CUBE_MAP,GL_TEXTURE_COMPARE_FUNC,GL_ALWAYS);
     if MipMapping and MipMapLevelWiseFill then begin
      glTexParameteri(GL_TEXTURE_CUBE_MAP,GL_TEXTURE_BASE_LEVEL,0);
      glTexParameteri(GL_TEXTURE_CUBE_MAP,GL_TEXTURE_MAX_LEVEL,MaxLevel);
      glTexParameteri(GL_TEXTURE_CUBE_MAP,GL_GENERATE_MIPMAP,0);
      for j:=0 to MaxLevel do begin
       for i:=low(CubeMapTexs) to high(CubeMapTexs) do begin
        glTexImage2D(CubeMapTexs[i],0,GL_DEPTH_COMPONENT32F,FBO.WorkWidth shr j,FBO.WorkHeight shr j,0,GL_DEPTH_COMPONENT,GL_FLOAT,nil);
       end;
      end;
     end else begin
      for i:=low(CubeMapTexs) to high(CubeMapTexs) do begin
       glTexImage2D(CubeMapTexs[i],0,GL_DEPTH_COMPONENT32F,FBO.WorkWidth,FBO.WorkHeight,0,GL_DEPTH_COMPONENT,GL_FLOAT,nil);
      end;
      if MipMapping then begin
       glGenerateMipmap(GL_TEXTURE_CUBE_MAP);
      end;
     end;
    end;
   end else begin
    if ArrayFBO then begin
     glBindTexture(GL_TEXTURE_2D_ARRAY,FBO.TextureHandles[FBO.WorkTextures-1]);
     glTexParameteri(GL_TEXTURE_2D_ARRAY,GL_TEXTURE_MAG_FILTER,FilterModes[FBO.MagFilterMode]);
     glTexParameteri(GL_TEXTURE_2D_ARRAY,GL_TEXTURE_MIN_FILTER,FilterModes[FBO.MinFilterMode]);
     if MirrorRepeating then begin
      glTexParameteri(GL_TEXTURE_2D_ARRAY,GL_TEXTURE_WRAP_S,GL_MIRRORED_REPEAT);
      glTexParameteri(GL_TEXTURE_2D_ARRAY,GL_TEXTURE_WRAP_T,GL_MIRRORED_REPEAT);
      glTexParameteri(GL_TEXTURE_2D_ARRAY,GL_TEXTURE_WRAP_R,GL_MIRRORED_REPEAT);
     end else begin
      glTexParameteri(GL_TEXTURE_2D_ARRAY,GL_TEXTURE_WRAP_S,WrapModes[FBO.SWrapMode]);
      glTexParameteri(GL_TEXTURE_2D_ARRAY,GL_TEXTURE_WRAP_T,WrapModes[FBO.TWrapMode]);
      glTexParameteri(GL_TEXTURE_2D_ARRAY,GL_TEXTURE_WRAP_R,WrapModes[FBO.RWrapMode]);
     end;
     glTexParameteri(GL_TEXTURE_2D_ARRAY,GL_DEPTH_TEXTURE_MODE,GL_LUMINANCE);
     glTexParameteri(GL_TEXTURE_2D_ARRAY,GL_TEXTURE_COMPARE_MODE,GL_NONE);
     glTexParameteri(GL_TEXTURE_2D_ARRAY,GL_TEXTURE_COMPARE_FUNC,GL_ALWAYS);
     if MipMapping and MipMapLevelWiseFill then begin
      glTexParameteri(GL_TEXTURE_2D_ARRAY,GL_TEXTURE_BASE_LEVEL,0);
      glTexParameteri(GL_TEXTURE_2D_ARRAY,GL_TEXTURE_MAX_LEVEL,MaxLevel);
      glTexParameteri(GL_TEXTURE_2D_ARRAY,GL_GENERATE_MIPMAP,0);
      for j:=0 to MaxLevel do begin
       glTexImage3D(GL_TEXTURE_2D_ARRAY,j,GL_DEPTH_COMPONENT32F,FBO.WorkWidth shr j,FBO.WorkHeight shr j,FBO.WorkDepth,0,GL_DEPTH_COMPONENT,GL_FLOAT,nil);
      end;
     end else begin
      glTexImage3D(GL_TEXTURE_2D_ARRAY,0,GL_DEPTH_COMPONENT32F,FBO.WorkWidth,FBO.WorkHeight,FBO.WorkDepth,0,GL_DEPTH_COMPONENT,GL_FLOAT,nil);
      if MipMapping then begin
       glGenerateMipmap(GL_TEXTURE_2D_ARRAY);
      end;
     end;
    end else begin
     glBindTexture(GL_TEXTURE_2D,FBO.TextureHandles[FBO.WorkTextures-1]);
     glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,FilterModes[FBO.MagFilterMode]);
     glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,FilterModes[FBO.MinFilterMode]);
     if MirrorRepeating then begin
      glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_MIRRORED_REPEAT);
      glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_MIRRORED_REPEAT);
     end else begin
      glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,WrapModes[FBO.SWrapMode]);
      glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,WrapModes[FBO.TWrapMode]);
     end;
     glTexParameteri(GL_TEXTURE_2D,GL_DEPTH_TEXTURE_MODE,GL_LUMINANCE);
     glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_COMPARE_MODE,GL_NONE);
     glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_COMPARE_FUNC,GL_ALWAYS);
     if MipMapping and MipMapLevelWiseFill then begin
      glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_BASE_LEVEL,0);
      glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAX_LEVEL,MaxLevel);
      glTexParameteri(GL_TEXTURE_2D,GL_GENERATE_MIPMAP,0);
      for j:=0 to MaxLevel do begin
       glTexImage2D(GL_TEXTURE_2D,j,GL_DEPTH_COMPONENT32F,FBO.WorkWidth shr j,FBO.WorkHeight shr j,0,GL_DEPTH_COMPONENT,GL_FLOAT,nil);
      end;
     end else begin
      glTexImage2D(GL_TEXTURE_2D,0,GL_DEPTH_COMPONENT32F,FBO.WorkWidth,FBO.WorkHeight,0,GL_DEPTH_COMPONENT,GL_FLOAT,nil);
      if MipMapping then begin
       glGenerateMipmap(GL_TEXTURE_2D);
      end;
     end;
    end;
   end;
  end else begin
   glGenRenderbuffers(1,@FBO.DepthBuffer);
   glBindRenderbuffer(GL_RENDERBUFFER,FBO.DepthBuffer);
   glRenderbufferStorage(GL_RENDERBUFFER,GL_DEPTH_COMPONENT32F,FBO.WorkWidth,FBO.WorkHeight);
  end;
 end;

 FBOData:=nil;
 try

  if FBO.Resize and (length(FBO.Data)>0) then begin
   if CubeMap then begin
    l:=6;
   end else begin
    l:=Max(1,FBO.WorkDepth);
   end;
   if (Formats[0]=GL_TEXTURE_RGBA8UB) and
      ((FBO.Width*FBO.Height*Max(1,IfThen((FBO.Flags and FBOFlagCubeMap)<>0,6,FBO.Depth))*4)<=length(FBO.Data)) then begin
    SetLength(FBOData,FBO.WorkWidth*FBO.WorkHeight*l*4);
    for i:=0 to l-1 do begin
     pa:=@FBO.Data[i*(FBO.Width*FBO.Height*4)];
     pb:=@FBOData[i*(FBO.WorkWidth*FBO.WorkHeight*4)];
     ResizeRGBA32(pa,FBO.Width,FBO.Height,pb,FBO.WorkWidth,FBO.WorkHeight);
    end;
   end else begin
    FBOData:=FBO.Data;
   end;
  end else begin
   FBOData:=FBO.Data;
  end;

  for i:=0 to FBO.WorkColorTextures-1 do begin
   glGenTextures(1,@FBO.TextureHandles[i]);
   if CubeMap then begin
    if ArrayFBO then begin
     glBindTexture(GL_TEXTURE_CUBE_MAP_ARRAY,FBO.TextureHandles[i]);
     glTexParameteri(GL_TEXTURE_CUBE_MAP_ARRAY,GL_TEXTURE_MAG_FILTER,FilterModes[FBO.MagFilterMode]);
     glTexParameteri(GL_TEXTURE_CUBE_MAP_ARRAY,GL_TEXTURE_MIN_FILTER,FilterModes[FBO.MinFilterMode]);
     if MirrorRepeating then begin
      glTexParameteri(GL_TEXTURE_CUBE_MAP_ARRAY,GL_TEXTURE_WRAP_S,GL_MIRRORED_REPEAT);
      glTexParameteri(GL_TEXTURE_CUBE_MAP_ARRAY,GL_TEXTURE_WRAP_T,GL_MIRRORED_REPEAT);
      glTexParameteri(GL_TEXTURE_CUBE_MAP_ARRAY,GL_TEXTURE_WRAP_R,GL_MIRRORED_REPEAT);
     end else begin
      glTexParameteri(GL_TEXTURE_CUBE_MAP_ARRAY,GL_TEXTURE_WRAP_S,WrapModes[FBO.SWrapMode]);
      glTexParameteri(GL_TEXTURE_CUBE_MAP_ARRAY,GL_TEXTURE_WRAP_T,WrapModes[FBO.TWrapMode]);
      glTexParameteri(GL_TEXTURE_CUBE_MAP_ARRAY,GL_TEXTURE_WRAP_R,WrapModes[FBO.RWrapMode]);
     end;
     if MipMapping and MipMapLevelWiseFill then begin
      glTexParameteri(GL_TEXTURE_CUBE_MAP_ARRAY,GL_TEXTURE_BASE_LEVEL,0);
      glTexParameteri(GL_TEXTURE_CUBE_MAP_ARRAY,GL_TEXTURE_MAX_LEVEL,MaxLevel);
//    glTexParameteri(GL_TEXTURE_CUBE_MAP_ARRAY,GL_GENERATE_MIPMAP,0);
      for j:=0 to MaxLevel do begin
       for k:=low(CubeMapTexs) to high(CubeMapTexs) do begin
        glTexImage3D(CubeMapTexs[k],j,TextureFormats[Formats[i]].InternalFormat,FBO.WorkWidth shr j,FBO.WorkHeight shr j,FBO.WorkDepth,0,TextureFormats[Formats[i]].Format,TextureFormats[Formats[i]].Type_,nil);
       end
      end;
     end else begin
      for j:=low(CubeMapTexs) to high(CubeMapTexs) do begin
       if (i=0) and (length(FBOData)>0) and ((FBO.WorkWidth*FBO.WorkHeight*FBO.WorkDepth*TextureFormats[Formats[i]].BitsPerPixel*6)<=(length(FBOData) shl 3)) then begin
        glTexImage3D(CubeMapTexs[j],0,TextureFormats[Formats[i]].InternalFormat,FBO.WorkWidth,FBO.WorkHeight,FBO.WorkDepth,0,TextureFormats[Formats[i]].Format,TextureFormats[Formats[i]].Type_,@FBOData[j*((FBO.WorkWidth*FBO.WorkHeight*FBO.WorkDepth*TextureFormats[Formats[i]].BitsPerPixel) shr 3)]);
       end else begin
        glTexImage3D(CubeMapTexs[j],0,TextureFormats[Formats[i]].InternalFormat,FBO.WorkWidth,FBO.WorkHeight,FBO.WorkDepth,0,TextureFormats[Formats[i]].Format,TextureFormats[Formats[i]].Type_,nil);
       end;
      end;
      if MipMapping then begin
       glGenerateMipmap(GL_TEXTURE_CUBE_MAP_ARRAY);
      end;
     end;
    end else begin
     glBindTexture(GL_TEXTURE_CUBE_MAP,FBO.TextureHandles[i]);
     glTexParameteri(GL_TEXTURE_CUBE_MAP,GL_TEXTURE_MAG_FILTER,FilterModes[FBO.MagFilterMode]);
     glTexParameteri(GL_TEXTURE_CUBE_MAP,GL_TEXTURE_MIN_FILTER,FilterModes[FBO.MinFilterMode]);
     if MirrorRepeating then begin
      glTexParameteri(GL_TEXTURE_CUBE_MAP,GL_TEXTURE_WRAP_S,GL_MIRRORED_REPEAT);
      glTexParameteri(GL_TEXTURE_CUBE_MAP,GL_TEXTURE_WRAP_T,GL_MIRRORED_REPEAT);
      glTexParameteri(GL_TEXTURE_CUBE_MAP,GL_TEXTURE_WRAP_R,GL_MIRRORED_REPEAT);
     end else begin
      glTexParameteri(GL_TEXTURE_CUBE_MAP,GL_TEXTURE_WRAP_S,WrapModes[FBO.SWrapMode]);
      glTexParameteri(GL_TEXTURE_CUBE_MAP,GL_TEXTURE_WRAP_T,WrapModes[FBO.TWrapMode]);
      glTexParameteri(GL_TEXTURE_CUBE_MAP,GL_TEXTURE_WRAP_R,WrapModes[FBO.RWrapMode]);
     end;
     if MipMapping and MipMapLevelWiseFill then begin
      glTexParameteri(GL_TEXTURE_CUBE_MAP,GL_TEXTURE_BASE_LEVEL,0);
      glTexParameteri(GL_TEXTURE_CUBE_MAP,GL_TEXTURE_MAX_LEVEL,MaxLevel);
//    glTexParameteri(GL_TEXTURE_CUBE_MAP,GL_GENERATE_MIPMAP,0);
      for j:=0 to MaxLevel do begin
       for k:=low(CubeMapTexs) to high(CubeMapTexs) do begin
        glTexImage2D(CubeMapTexs[k],j,TextureFormats[Formats[i]].InternalFormat,FBO.WorkWidth shr j,FBO.WorkHeight shr j,0,TextureFormats[Formats[i]].Format,TextureFormats[Formats[i]].Type_,nil);
       end;
      end;
     end else begin
      for j:=low(CubeMapTexs) to high(CubeMapTexs) do begin
       if (i=0) and (length(FBOData)>0) and ((FBO.WorkWidth*FBO.WorkHeight*TextureFormats[Formats[i]].BitsPerPixel*6)<=(length(FBOData) shl 3)) then begin
        glTexImage2D(CubeMapTexs[j],0,TextureFormats[Formats[i]].InternalFormat,FBO.WorkWidth,FBO.WorkHeight,0,TextureFormats[Formats[i]].Format,TextureFormats[Formats[i]].Type_,@FBOData[j*((FBO.WorkWidth*FBO.WorkHeight*TextureFormats[Formats[i]].BitsPerPixel) shr 3)]);
       end else begin
        glTexImage2D(CubeMapTexs[j],0,TextureFormats[Formats[i]].InternalFormat,FBO.WorkWidth,FBO.WorkHeight,0,TextureFormats[Formats[i]].Format,TextureFormats[Formats[i]].Type_,nil);
       end;
      end;
      if MipMapping then begin
       glGenerateMipmap(GL_TEXTURE_CUBE_MAP);
      end;
     end;
    end;
   end else begin
    if ArrayFBO then begin
     glBindTexture(GL_TEXTURE_2D_ARRAY,FBO.TextureHandles[i]);
     glTexParameteri(GL_TEXTURE_2D_ARRAY,GL_TEXTURE_MAG_FILTER,FilterModes[FBO.MagFilterMode]);
     glTexParameteri(GL_TEXTURE_2D_ARRAY,GL_TEXTURE_MIN_FILTER,FilterModes[FBO.MinFilterMode]);
     if MirrorRepeating then begin
      glTexParameteri(GL_TEXTURE_2D_ARRAY,GL_TEXTURE_WRAP_S,GL_MIRRORED_REPEAT);
      glTexParameteri(GL_TEXTURE_2D_ARRAY,GL_TEXTURE_WRAP_T,GL_MIRRORED_REPEAT);
      glTexParameteri(GL_TEXTURE_2D_ARRAY,GL_TEXTURE_WRAP_R,GL_MIRRORED_REPEAT);
     end else begin
      glTexParameteri(GL_TEXTURE_2D_ARRAY,GL_TEXTURE_WRAP_S,WrapModes[FBO.SWrapMode]);
      glTexParameteri(GL_TEXTURE_2D_ARRAY,GL_TEXTURE_WRAP_T,WrapModes[FBO.TWrapMode]);
      glTexParameteri(GL_TEXTURE_2D_ARRAY,GL_TEXTURE_WRAP_R,WrapModes[FBO.RWrapMode]);
     end;
     if MipMapping and MipMapLevelWiseFill then begin
      glTexParameteri(GL_TEXTURE_2D_ARRAY,GL_TEXTURE_BASE_LEVEL,0);
      glTexParameteri(GL_TEXTURE_2D_ARRAY,GL_TEXTURE_MAX_LEVEL,MaxLevel);
//    glTexParameteri(GL_TEXTURE_2D_ARRAY,GL_GENERATE_MIPMAP,0);
      for j:=0 to MaxLevel do begin
       glTexImage3D(GL_TEXTURE_2D_ARRAY,j,TextureFormats[Formats[i]].InternalFormat,FBO.WorkWidth shr j,FBO.WorkHeight shr j,FBO.WorkDepth shr j,0,TextureFormats[Formats[i]].Format,TextureFormats[Formats[i]].Type_,nil);
      end;
     end else begin
      if (i=0) and (length(FBOData)>0) and ((FBO.WorkWidth*FBO.WorkHeight*FBO.WorkDepth*TextureFormats[Formats[i]].BitsPerPixel)<=(length(FBOData) shl 3)) then begin
       glTexImage3D(GL_TEXTURE_2D_ARRAY,0,TextureFormats[Formats[i]].InternalFormat,FBO.WorkWidth,FBO.WorkHeight,FBO.WorkDepth,0,TextureFormats[Formats[i]].Format,TextureFormats[Formats[i]].Type_,@FBOData[0]);
      end else begin
       glTexImage3D(GL_TEXTURE_2D_ARRAY,0,TextureFormats[Formats[i]].InternalFormat,FBO.WorkWidth,FBO.WorkHeight,FBO.WorkDepth,0,TextureFormats[Formats[i]].Format,TextureFormats[Formats[i]].Type_,nil);
      end;
      if MipMapping then begin
       glGenerateMipmap(GL_TEXTURE_2D_ARRAY);
      end;
     end;
    end else if FBO.WorkDepth<1 then begin
     glBindTexture(GL_TEXTURE_2D,FBO.TextureHandles[i]);
     glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,FilterModes[FBO.MagFilterMode]);
     glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,FilterModes[FBO.MinFilterMode]);
     if MirrorRepeating then begin
      glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_MIRRORED_REPEAT);
      glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_MIRRORED_REPEAT);
     end else begin
      glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,WrapModes[FBO.SWrapMode]);
      glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,WrapModes[FBO.TWrapMode]);
     end;
     if MipMapping and MipMapLevelWiseFill then begin
      glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_BASE_LEVEL,0);
      glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAX_LEVEL,MaxLevel);
//    glTexParameteri(GL_TEXTURE_2D,GL_GENERATE_MIPMAP,0);
      for j:=0 to MaxLevel do begin
       glTexImage2D(GL_TEXTURE_2D,j,TextureFormats[Formats[i]].InternalFormat,FBO.WorkWidth shr j,FBO.WorkHeight shr j,0,TextureFormats[Formats[i]].Format,TextureFormats[Formats[i]].Type_,nil);
      end;
     end else begin
      if (i=0) and (length(FBOData)>0) and ((FBO.WorkWidth*FBO.WorkHeight*TextureFormats[Formats[i]].BitsPerPixel)<=(length(FBOData) shl 3)) then begin
       glTexImage2D(GL_TEXTURE_2D,0,TextureFormats[Formats[i]].InternalFormat,FBO.WorkWidth,FBO.WorkHeight,0,TextureFormats[Formats[i]].Format,TextureFormats[Formats[i]].Type_,@FBOData[0]);
      end else begin
       glTexImage2D(GL_TEXTURE_2D,0,TextureFormats[Formats[i]].InternalFormat,FBO.WorkWidth,FBO.WorkHeight,0,TextureFormats[Formats[i]].Format,TextureFormats[Formats[i]].Type_,nil);
      end;
      if MipMapping then begin
       glGenerateMipmap(GL_TEXTURE_2D);
      end;
     end;
    end else begin
     glBindTexture(GL_TEXTURE_3D,FBO.TextureHandles[i]);
     glTexParameteri(GL_TEXTURE_3D,GL_TEXTURE_MAG_FILTER,FilterModes[FBO.MagFilterMode]);
     glTexParameteri(GL_TEXTURE_3D,GL_TEXTURE_MIN_FILTER,FilterModes[FBO.MinFilterMode]);
     if MirrorRepeating then begin
      glTexParameteri(GL_TEXTURE_3D,GL_TEXTURE_WRAP_S,GL_MIRRORED_REPEAT);
      glTexParameteri(GL_TEXTURE_3D,GL_TEXTURE_WRAP_T,GL_MIRRORED_REPEAT);
      glTexParameteri(GL_TEXTURE_3D,GL_TEXTURE_WRAP_R,GL_MIRRORED_REPEAT);
     end else begin
      glTexParameteri(GL_TEXTURE_3D,GL_TEXTURE_WRAP_S,WrapModes[FBO.SWrapMode]);
      glTexParameteri(GL_TEXTURE_3D,GL_TEXTURE_WRAP_T,WrapModes[FBO.TWrapMode]);
      glTexParameteri(GL_TEXTURE_3D,GL_TEXTURE_WRAP_R,WrapModes[FBO.RWrapMode]);
     end;
     if MipMapping and MipMapLevelWiseFill then begin
      glTexParameteri(GL_TEXTURE_3D,GL_TEXTURE_BASE_LEVEL,0);
      glTexParameteri(GL_TEXTURE_3D,GL_TEXTURE_MAX_LEVEL,MaxLevel);
//    glTexParameteri(GL_TEXTURE_3D,GL_GENERATE_MIPMAP,0);
      for j:=0 to MaxLevel do begin
       glTexImage3D(GL_TEXTURE_3D,j,TextureFormats[Formats[i]].InternalFormat,FBO.WorkWidth shr j,FBO.WorkHeight shr j,FBO.WorkDepth shr j,0,TextureFormats[Formats[i]].Format,TextureFormats[Formats[i]].Type_,nil);
      end;
     end else begin
      if (i=0) and (length(FBOData)>0) and ((FBO.WorkWidth*FBO.WorkHeight*FBO.WorkDepth*TextureFormats[Formats[i]].BitsPerPixel)<=(length(FBOData) shl 3)) then begin
       glTexImage3D(GL_TEXTURE_3D,0,TextureFormats[Formats[i]].InternalFormat,FBO.WorkWidth,FBO.WorkHeight,FBO.WorkDepth,0,TextureFormats[Formats[i]].Format,TextureFormats[Formats[i]].Type_,@FBOData[0]);
      end else begin
       glTexImage3D(GL_TEXTURE_3D,0,TextureFormats[Formats[i]].InternalFormat,FBO.WorkWidth,FBO.WorkHeight,FBO.WorkDepth,0,TextureFormats[Formats[i]].Format,TextureFormats[Formats[i]].Type_,nil);
      end;
      if MipMapping then begin
       glGenerateMipmap(GL_TEXTURE_3D);
      end;
     end;
    end;
   end;
  end;

  for j:=0 to MaxLevel do begin
   glGenFramebuffers(1,@FBO.fbos[j]);
   glBindFramebuffer(GL_FRAMEBUFFER,FBO.fbos[j]);
   if DepthBuffer then begin
    if DepthBufferTexture then begin
     if CubeMap or ArrayFBO then begin
      glFramebufferTexture(GL_FRAMEBUFFER,GL_DEPTH_ATTACHMENT,FBO.TextureHandles[FBO.WorkTextures-1],j);
     end else begin
      glFramebufferTexture2D(GL_FRAMEBUFFER,GL_DEPTH_ATTACHMENT,GL_TEXTURE_2D,FBO.TextureHandles[FBO.WorkTextures-1],j);
     end;
    end else begin
     glFramebufferRenderbuffer(GL_FRAMEBUFFER,GL_DEPTH_ATTACHMENT,GL_RENDERBUFFER,FBO.DepthBuffer);
    end;
   end;
   for i:=0 to FBO.WorkColorTextures-1 do begin
    if (FBO.WorkDepth<1) and not (CubeMap or ArrayFBO) then begin
     glFramebufferTexture2D(GL_FRAMEBUFFER,GL_COLOR_ATTACHMENT0+i,GL_TEXTURE_2D,FBO.TextureHandles[i],j);
    end else begin
     glFramebufferTexture(GL_FRAMEBUFFER,GL_COLOR_ATTACHMENT0+i,FBO.TextureHandles[i],j);
 //  glFramebufferTexture3D(GL_FRAMEBUFFER,GL_COLOR_ATTACHMENT0+i,GL_TEXTURE_3D,FBO.TextureHandles[i],j,0);
    end;
   end;
  end;

 finally
  FBOData:=nil;
 end;

 glBindFramebuffer(GL_FRAMEBUFFER,0);
end;

procedure DestroyFrameBuffer(var FBO:TFBO);
var i:longint;
begin
 glBindFrameBuffer(GL_FRAMEBUFFER,0);
 if (FBO.Flags and FBOFlagDepthBuffer)<>0 then begin
  glDeleteRenderbuffers(1,@FBO.DepthBuffer);
 end;
 for i:=0 to FBO.WorkMaxLevel do begin
  glDeleteFrameBuffers(1,@FBO.FBOs[i]);
 end;
 for i:=0 to FBO.WorkTextures-1 do begin
  glDeleteTextures(1,@FBO.TextureHandles[i]);
 end;
end;

constructor TFrameBufferObject.Create(AWidth,AHeight,ATextures:longint;ACubeMap,AClamping,AMirroring,AInterpolation,ADepthBuffer,AHasDepthTexture:boolean);
var Counter:longint;
begin
 inherited Create;
 Width:=AWidth;
 Height:=AHeight;
{Width:=1;
 while Width<AWidth do begin
  inc(Width,Width);
 end;
 Height:=1;
 while Height<AHeight do begin
  inc(Height,Height);
 end;}
 HasDepthBuffer:=ADepthBuffer;
 HasDepthTexture:=AHasDepthTexture;
 if ACubeMap then begin
{$ifndef gles20}
  Textures:=1;
  glGenTextures(1,@TextureHandles[0]);
  glBindTexture(GL_TEXTURE_CUBE_MAP,TextureHandles[0]);
  if AInterpolation then begin
   glTexParameteri(GL_TEXTURE_CUBE_MAP,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
   glTexParameteri(GL_TEXTURE_CUBE_MAP,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
  end else begin
   glTexParameteri(GL_TEXTURE_CUBE_MAP,GL_TEXTURE_MAG_FILTER,GL_NEAREST);
   glTexParameteri(GL_TEXTURE_CUBE_MAP,GL_TEXTURE_MIN_FILTER,GL_NEAREST);
  end;
  if AClamping then begin
   glTexParameteri(GL_TEXTURE_CUBE_MAP,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE);
   glTexParameteri(GL_TEXTURE_CUBE_MAP,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE);
   glTexParameteri(GL_TEXTURE_CUBE_MAP,GL_TEXTURE_WRAP_R,GL_CLAMP_TO_EDGE);
  end else begin
   if AMirroring then begin
    glTexParameteri(GL_TEXTURE_CUBE_MAP,GL_TEXTURE_WRAP_S,GL_MIRRORED_REPEAT);
    glTexParameteri(GL_TEXTURE_CUBE_MAP,GL_TEXTURE_WRAP_T,GL_MIRRORED_REPEAT);
    glTexParameteri(GL_TEXTURE_CUBE_MAP,GL_TEXTURE_WRAP_R,GL_MIRRORED_REPEAT);
   end else begin
    glTexParameteri(GL_TEXTURE_CUBE_MAP,GL_TEXTURE_WRAP_S,GL_REPEAT);
    glTexParameteri(GL_TEXTURE_CUBE_MAP,GL_TEXTURE_WRAP_T,GL_REPEAT);
    glTexParameteri(GL_TEXTURE_CUBE_MAP,GL_TEXTURE_WRAP_R,GL_REPEAT);
   end;
  end;
//glTexParameteri(GL_TEXTURE_2D,GL_GENERATE_MIPMAP,0);
  for Counter:=low(CubeMapTexs) to high(CubeMapTexs) do begin
   glTexImage2D(CubeMapTexs[Counter],0,GL_RGBA16F,Width,Height,0,GL_RGBA,GL_HALF_FLOAT,nil);
  end;
  glGenFramebuffers(1,@FrameBuffer);
  glBindFramebuffer(GL_FRAMEBUFFER,FrameBuffer);
  if HasDepthBuffer then begin
   glGenRenderbuffers(1,@DepthBuffer);
   glBindRenderbuffer(GL_RENDERBUFFER,DepthBuffer);
   glRenderbufferStorage(GL_RENDERBUFFER,GL_DEPTH_COMPONENT32F,Width,Height);
   glFramebufferRenderbuffer(GL_FRAMEBUFFER,GL_DEPTH_ATTACHMENT,GL_RENDERBUFFER,DepthBuffer);
  end;
  glFramebufferTexture2D(GL_FRAMEBUFFER,GL_COLOR_ATTACHMENT0,GL_TEXTURE_2D,GL_TEXTURE_CUBE_MAP_POSITIVE_X,0);
{$endif}
 end else begin
  Textures:=ATextures;
  glGenFramebuffers(1,@FrameBuffer);
  glBindFramebuffer(GL_FRAMEBUFFER,FrameBuffer);
  if HasDepthTexture then begin
   Counter:=Textures;
   glGenTextures(1,@TextureHandles[Counter]);
   glBindTexture(GL_TEXTURE_2D,TextureHandles[Counter]);
   if AInterpolation then begin
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
   end else begin
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST);
   end;
   if AClamping then begin
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE);
   end else begin
    if AMirroring then begin
     glTexParameteri(GL_TEXTURE_CUBE_MAP,GL_TEXTURE_WRAP_S,GL_MIRRORED_REPEAT);
     glTexParameteri(GL_TEXTURE_CUBE_MAP,GL_TEXTURE_WRAP_T,GL_MIRRORED_REPEAT);
    end else begin
     glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_REPEAT);
     glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_REPEAT);
    end;
   end;
{$ifdef gles20}
   glTexImage2D(GL_TEXTURE_2D,0,GL_DEPTH_COMPONENT32F,Width,Height,0,GL_DEPTH_COMPONENT,GL_UNSIGNED_SHORT,nil);
{$else}
// glTexParameteri(GL_TEXTURE_2D,GL_GENERATE_MIPMAP,0);
   glTexParameteri(GL_TEXTURE_2D,GL_DEPTH_TEXTURE_MODE,GL_LUMINANCE);
   glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_COMPARE_MODE,GL_NONE);
   glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_COMPARE_FUNC,GL_ALWAYS);
   glTexImage2D(GL_TEXTURE_2D,0,GL_DEPTH_COMPONENT32F,Width,Height,0,GL_DEPTH_COMPONENT,GL_UNSIGNED_BYTE,nil);
{$endif}
   glBindTexture(GL_TEXTURE_2D,0);
   glFramebufferTexture2D(GL_FRAMEBUFFER,GL_DEPTH_ATTACHMENT,GL_TEXTURE_2D,TextureHandles[Counter],0);
   HasDepthBuffer:=false;
  end else if HasDepthBuffer then begin
   glGenRenderbuffers(1,@DepthBuffer);
   glBindRenderbuffer(GL_RENDERBUFFER,DepthBuffer);
{$ifdef gles20}
   glRenderbufferStorage(GL_RENDERBUFFER,GL_DEPTH_COMPONENT16,Width,Height);
{$else}
   glRenderbufferStorage(GL_RENDERBUFFER,GL_DEPTH_COMPONENT32F,Width,Height);
{$endif}
   glFramebufferRenderbuffer(GL_FRAMEBUFFER,GL_DEPTH_ATTACHMENT,GL_RENDERBUFFER,DepthBuffer);
  end;
  for Counter:=0 to Textures-1 do begin
   glGenTextures(1,@TextureHandles[Counter]);
   glBindTexture(GL_TEXTURE_2D,TextureHandles[Counter]);
   if AInterpolation then begin
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
   end else begin
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST);
   end;
   if AClamping then begin
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE);
   end else begin
    if AMirroring then begin
     glTexParameteri(GL_TEXTURE_CUBE_MAP,GL_TEXTURE_WRAP_S,GL_MIRRORED_REPEAT);
     glTexParameteri(GL_TEXTURE_CUBE_MAP,GL_TEXTURE_WRAP_T,GL_MIRRORED_REPEAT);
    end else begin
     glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_REPEAT);
     glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_REPEAT);
    end;
   end;
{$ifndef gles20}
// glTexParameteri(GL_TEXTURE_2D,GL_GENERATE_MIPMAP,0);
{$endif}
   glTexImage2D(GL_TEXTURE_2D,0,{$ifdef gles20}GL_RGBA{$else}GL_RGBA16F{$endif},Width,Height,0,{$ifdef gles20}GL_RGBA,GL_UNSIGNED_BYTE{$else}GL_RGBA,GL_HALF_FLOAT{$endif},nil);
   glBindTexture(GL_TEXTURE_2D,0);
   glFramebufferTexture2D(GL_FRAMEBUFFER,GL_COLOR_ATTACHMENT0+Counter,GL_TEXTURE_2D,TextureHandles[Counter],0);
  end;
 end;
 case glCheckFramebufferStatus(GL_FRAMEBUFFER) of
  GL_FRAMEBUFFER_COMPLETE:begin
  end;
  GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT:begin
   raise Exception.Create('Framebuffer incomplete: Attachment is NOT complete');
  end;
  GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT:begin
   raise Exception.Create('Framebuffer incomplete: No image is attached to FBO');
  end;
{$ifdef gles20}
  GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS:begin
   raise Exception.Create('Framebuffer incomplete: Attached images have different dimensions');
  end;
{$endif}
  GL_FRAMEBUFFER_UNSUPPORTED:begin
   raise Exception.Create('Framebuffer incomplete: Unsupported by FBO implementation');
  end;
  else begin
   raise Exception.Create('Framebuffer incomplete: Unknown error');
  end;
 end;
 glBindFrameBuffer(GL_FRAMEBUFFER,0);
end;

destructor TFrameBufferObject.Destroy;
var Counter:longint;
begin
 glBindFrameBuffer(GL_FRAMEBUFFER,0);
 if HasDepthBuffer then begin
  glDeleteRenderbuffers(1,@DepthBuffer);
 end;
 glDeleteFrameBuffers(1,@FrameBuffer);
 for Counter:=0 to Textures-1 do begin
  glDeleteTextures(1,@TextureHandles[Counter]);
 end;
 if HasDepthTexture then begin
  glDeleteTextures(1,@TextureHandles[Textures]);
 end;
 inherited Destroy;
end;

procedure TFrameBufferObject.Bind;
const Targets:array[0..7] of glenum=(GL_COLOR_ATTACHMENT0,
                                     GL_COLOR_ATTACHMENT1,
                                     GL_COLOR_ATTACHMENT2,
                                     GL_COLOR_ATTACHMENT3,
                                     GL_COLOR_ATTACHMENT4,
                                     GL_COLOR_ATTACHMENT5,
                                     GL_COLOR_ATTACHMENT6,
                                     GL_COLOR_ATTACHMENT7);
begin
 glBindFrameBuffer(GL_FRAMEBUFFER,Framebuffer);
 glDrawBuffers(Textures,@Targets[0]);
// glDrawBuffer(GL_COLOR_ATTACHMENT0);
 //glViewPort(0,0,Width,Height);
{glClearColor(0,0,0,0);
 glClear(GL_COLOR_BUFFER_BIT); //or GL_DEPTH_BUFFER_BIT}
end;

procedure TFrameBufferObject.Unbind;
begin
 glDrawBuffer(GL_COLOR_ATTACHMENT0);
 glBindFrameBuffer(GL_FRAMEBUFFER,0);
end;

end.
