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
unit PasVulkan.Image.Utils;
{$i PasVulkan.inc}
{$ifndef fpc}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=24.0}
   {$legacyifend on}
  {$ifend}
 {$endif}
{$endif}
{$if defined(fpc) and defined(Android) and defined(cpuarm)}
 {$define UsePNGExternalLibrary}
{$else}
 {$undef UsePNGExternalLibrary}
{$ifend}

interface

uses SysUtils,
     Classes,
     Math,
     PasVulkan.Types;

procedure ResizeMonoByte2D(const aInData:Pointer;const aInWidth,aInHeight:TpvSizeInt;const aOutData:Pointer;const aOutWidth,aOutHeight:TpvSizeInt);
procedure ResizeMonoFloat2D(const aInData:Pointer;const aInWidth,aInHeight:TpvSizeInt;const aOutData:Pointer;const aOutWidth,aOutHeight:TpvSizeInt);
procedure ResizeRGBAFloat2D(const aInData:Pointer;const aInWidth,aInHeight:TpvSizeInt;const aOutData:Pointer;const aOutWidth,aOutHeight:TpvSizeInt);

procedure ResizeR8(const aSrc:pointer;const aSrcWidth,aSrcHeight:TpvInt32;const aDst:pointer;const aDstWidth,aDstHeight:TpvInt32);

procedure ResizeRGBA32(const aSrc:pointer;const aSrcWidth,aSrcHeight:TpvSizeInt;const aDst:pointer;const aDstWidth,aDstHeight:TpvSizeInt);

procedure RGBAAlphaBleeding(const aData:Pointer;const aWidth,aHeight:TpvSizeInt;const a16Bit:Boolean=false);

implementation

uses PasVulkan.Utils;

procedure ResizeMonoByte2D(const aInData:Pointer;const aInWidth,aInHeight:TpvSizeInt;const aOutData:Pointer;const aOutWidth,aOutHeight:TpvSizeInt);
var x,y,ix,iy,nx,ny,iwm,ihm,owm,ohm:TpvSizeInt;
    wf,hf,fx,fy:TpvDouble;
    InData,OutData:PpvUInt8Array;
begin

 InData:=aInData;
 OutData:=aOutData;

 if (aInWidth=aOutWidth) and (aInHeight=aOutHeight) then begin
 
  // Nothing to do, just copy the data, when the sizes are equal

  Move(InData^,OutData^,aInWidth*aInHeight*SizeOf(TpvUInt8));

 end else begin

  // Use bilinear interpolation to resize the image when the sizes are not equal

  iwm:=aInWidth-1;
  ihm:=aInHeight-1;

  owm:=aOutWidth-1;
  ohm:=aOutHeight-1;

  wf:=iwm/aOutWidth;
  hf:=ihm/aOutHeight;

  for y:=0 to ohm do begin
   fy:=y*hf;
   iy:=Trunc(fy);
   fy:=fy-iy;
   ny:=iy+1;
   if ny>=aInHeight then begin
    ny:=iy;
   end;
   for x:=0 to owm do begin
    fx:=x*wf;
    ix:=Trunc(fx);
    fx:=fx-ix;
    nx:=ix+1;
    if nx>=aInWidth then begin
     nx:=ix;
    end;
    OutData^[x+(y*aOutWidth)]:=Min(Max(Round((((InData^[ix+(iy*aInWidth)]*(1.0-fx))+(InData^[nx+(iy*aInWidth)]*fx))*(1.0-fy))+
                                             (((InData^[ix+(ny*aInWidth)]*(1.0-fx))+(InData^[nx+(ny*aInWidth)]*fx))*fy)),0),255);
   end;
  end;

 end; 

end;

procedure ResizeMonoFloat2D(const aInData:Pointer;const aInWidth,aInHeight:TpvSizeInt;const aOutData:Pointer;const aOutWidth,aOutHeight:TpvSizeInt);
var x,y,ix,iy,nx,ny,iwm,ihm,owm,ohm:TpvSizeInt;
    wf,hf,fx,fy:TpvDouble;
    InData,OutData:PpvFloatArray;
begin

 InData:=aInData;
 OutData:=aOutData;

 if (aInWidth=aOutWidth) and (aInHeight=aOutHeight) then begin
 
  // Nothing to do, just copy the data, when the sizes are equal

  Move(InData^,OutData^,aInWidth*aInHeight*SizeOf(TpvFloat));

 end else begin

  // Use bilinear interpolation to resize the image when the sizes are not equal

  iwm:=aInWidth-1;
  ihm:=aInHeight-1;

  owm:=aOutWidth-1;
  ohm:=aOutHeight-1;

  wf:=iwm/aOutWidth;
  hf:=ihm/aOutHeight;

  for y:=0 to ohm do begin
   fy:=y*hf;
   iy:=Trunc(fy);
   fy:=fy-iy;
   ny:=iy+1;
   if ny>=aInHeight then begin
    ny:=iy;
   end;
   for x:=0 to owm do begin
    fx:=x*wf;
    ix:=Trunc(fx);
    fx:=fx-ix;
    nx:=ix+1;
    if nx>=aInWidth then begin
     nx:=ix;
    end;
    OutData^[x+(y*aOutWidth)]:=(((InData^[ix+(iy*aInWidth)]*(1.0-fx))+(InData^[nx+(iy*aInWidth)]*fx))*(1.0-fy))+
                               (((InData^[ix+(ny*aInWidth)]*(1.0-fx))+(InData^[nx+(ny*aInWidth)]*fx))*fy);
   end;
  end;

 end; 

end;

procedure ResizeRGBAFloat2D(const aInData:Pointer;const aInWidth,aInHeight:TpvSizeInt;const aOutData:Pointer;const aOutWidth,aOutHeight:TpvSizeInt);
var x,y,ix,iy,nx,ny,iwm,ihm,owm,ohm:TpvSizeInt;
    wf,hf,fx,fy:TpvDouble;
    InData,OutData:PpvFloatArray;
begin

 InData:=aInData;
 OutData:=aOutData;

 if (aInWidth=aOutWidth) and (aInHeight=aOutHeight) then begin
 
  // Nothing to do, just copy the data, when the sizes are equal

  Move(InData^,OutData^,aInWidth*aInHeight*SizeOf(TpvFloat)*4);

 end else begin

  // Use bilinear interpolation to resize the image when the sizes are not equal

  iwm:=aInWidth-1;
  ihm:=aInHeight-1;

  owm:=aOutWidth-1;
  ohm:=aOutHeight-1;

  wf:=iwm/aOutWidth;
  hf:=ihm/aOutHeight;

  for y:=0 to ohm do begin
   fy:=y*hf;
   iy:=Trunc(fy);
   fy:=fy-iy;
   ny:=iy+1;
   if ny>=aInHeight then begin
    ny:=iy;
   end;
   for x:=0 to owm do begin
    fx:=x*wf;
    ix:=Trunc(fx);
    fx:=fx-ix;
    nx:=ix+1;
    if nx>=aInWidth then begin
     nx:=ix;
    end;
    OutData^[x+(y*aOutWidth)*4+0]:=(((InData^[((ix+(iy*aInWidth))*4)+0]*(1.0-fx))+(InData^[((nx+(iy*aInWidth))*4)+0]*fx))*(1.0-fy))+
                                   (((InData^[((ix+(ny*aInWidth))*4)+0]*(1.0-fx))+(InData^[((nx+(ny*aInWidth))*4)+0]*fx))*fy);
    OutData^[x+(y*aOutWidth)*4+1]:=(((InData^[((ix+(iy*aInWidth))*4)+1]*(1.0-fx))+(InData^[((nx+(iy*aInWidth))*4)+1]*fx))*(1.0-fy))+
                                   (((InData^[((ix+(ny*aInWidth))*4)+1]*(1.0-fx))+(InData^[((nx+(ny*aInWidth))*4)+1]*fx))*fy);
    OutData^[x+(y*aOutWidth)*4+2]:=(((InData^[((ix+(iy*aInWidth))*4)+2]*(1.0-fx))+(InData^[((nx+(iy*aInWidth))*4)+2]*fx))*(1.0-fy))+
                                   (((InData^[((ix+(ny*aInWidth))*4)+2]*(1.0-fx))+(InData^[((nx+(ny*aInWidth))*4)+2]*fx))*fy);
    OutData^[x+(y*aOutWidth)*4+3]:=(((InData^[((ix+(iy*aInWidth))*4)+3]*(1.0-fx))+(InData^[((nx+(iy*aInWidth))*4)+3]*fx))*(1.0-fy))+
                                   (((InData^[((ix+(ny*aInWidth))*4)+3]*(1.0-fx))+(InData^[((nx+(ny*aInWidth))*4)+3]*fx))*fy);
   end;
  end;
 end;
end;

procedure ResizeR8(const aSrc:pointer;const aSrcWidth,aSrcHeight:TpvInt32;const aDst:pointer;const aDstWidth,aDstHeight:TpvInt32);
type PPixels=^TPixels;
     TPixels=array[0..65535] of TpvUInt8;
var DstX,DstY,SrcX,SrcY:TpvInt32;
    Sum,w,Pixel,Weight,xUL,xUR,xLL,xLR,
    Red,Remainder,WeightX,WeightY:TpvUInt32;
    TempSrc,TempDst:PPixels;
    UpsampleX,UpsampleY:longbool;
    WeightShift,xa,xb,xc,xd,ya,yb,yc,yd:TpvInt32;
    SourceTexelsPerOutPixel,WeightPerPixel,AccumlatorPerPixel,WeightDivider,fw,fh:TpvFloat;
    XCache:array of TpvSizeInt;
begin
 XCache:=nil;
 try
  if (aSrcWidth=(aDstWidth*2)) and (aSrcHeight=(aDstHeight*2)) then begin
   Remainder:=0;
   TempDst:=pointer(aDst);
   for DstY:=0 to aDstHeight-1 do begin
    SrcY:=DstY*2;
    TempSrc:=pointer(@pansichar(aSrc)[(SrcY*aSrcWidth) shl 2]);
    for DstX:=0 to aDstWidth-1 do begin
     xUL:=TempSrc^[0];
     xUR:=TempSrc^[1];
     xLL:=TempSrc^[aSrcWidth];
     xLR:=TempSrc^[aSrcWidth+1];
     Red:=(xUL+xUR+xLL+xLR)+(Remainder and $ff);
     Remainder:=Red and $03;
     TempDst[0]:=(Red and $03fc) shr 2;
     TempDst:=pointer(@TempDst^[1]);
     TempSrc:=pointer(@TempSrc^[2]);
    end;
   end;
  end else begin
   UpsampleX:=aSrcWidth<aDstWidth;
   UpsampleY:=aDstHeight<aDstHeight;
   WeightShift:=0;
   SourceTexelsPerOutPixel:=((aSrcWidth/aDstWidth)+1)*((aSrcHeight/aDstHeight)+1);
   WeightPerPixel:=SourceTexelsPerOutPixel*65536;
   AccumlatorPerPixel:=WeightPerPixel*256;
   WeightDivider:=AccumlatorPerPixel/4294967000.0;
   if WeightDivider>1.0 then begin
    WeightShift:=trunc(ceil(ln(WeightDivider)/ln(2.0)));
   end;
   WeightShift:=min(WeightShift,15);
   fw:=(256*aSrcWidth)/aDstWidth;
   fh:=(256*aSrcHeight)/aDstHeight;
   if UpsampleX and UpsampleY then begin
    if length(XCache)<TpvInt32(aDstWidth) then begin
     SetLength(XCache,TpvInt32(aDstWidth));
    end;
    for DstX:=0 to aDstWidth-1 do begin
     XCache[DstX]:=min(trunc(DstX*fw),(256*(aSrcWidth-1))-1);
    end;
    for DstY:=0 to aDstHeight-1 do begin
     ya:=min(trunc(DstY*fh),(256*(aSrcHeight-1))-1);
     yc:=ya shr 8;
     TempDst:=pointer(@pansichar(aDst)[DstY*aDstWidth]);
     for DstX:=0 to aDstWidth-1 do begin
      xa:=XCache[DstX];
      xc:=xa shr 8;
      TempSrc:=pointer(@pansichar(aSrc)[(yc*aSrcWidth)+xc]);
      Sum:=0;
      WeightX:=TpvUInt32(TpvInt32(256-(xa and $ff)));
      WeightY:=TpvUInt32(TpvInt32(256-(ya and $ff)));
      for SrcY:=0 to 1 do begin
       for SrcX:=0 to 1 do begin
        Pixel:=TempSrc^[(SrcY*aSrcWidth)+SrcX];
        Weight:=(WeightX*WeightY) shr WeightShift;
        inc(Sum,Pixel*Weight);
        WeightX:=256-WeightX;
       end;
       WeightY:=256-WeightY;
      end;
      TempDst^[0]:=(Sum shr 16) and $ff;
      TempDst:=pointer(@TempDst^[1]);
     end;
    end;
   end else begin
    if length(XCache)<(TpvInt32(aDstWidth)*2) then begin
     SetLength(XCache,TpvInt32(aDstWidth)*2);
    end;
    for DstX:=0 to aDstWidth-1 do begin
     xa:=trunc(DstX*fw);
     if UpsampleX then begin
      xb:=xa+256;
     end else begin
      xb:=trunc((DstX+1)*fw);
     end;
     XCache[(DstX shl 1) or 0]:=min(xa,(256*aSrcWidth)-1);
     XCache[(DstX shl 1) or 1]:=min(xb,(256*aSrcWidth)-1);
    end;
    for DstY:=0 to aDstHeight-1 do begin
     ya:=trunc(DstY*fh);
     if UpsampleY then begin
      yb:=ya+256;
     end else begin
      yb:=trunc((DstY+1)*fh);
     end;
     TempDst:=pointer(@pansichar(aDst)[DstY*aDstWidth]);
     yc:=ya shr 8;
     yd:=yb shr 8;
     for DstX:=0 to aDstWidth-1 do begin
      xa:=XCache[(DstX shl 1) or 0];
      xb:=XCache[(DstX shl 1) or 1];
      xc:=xa shr 8;
      xd:=xb shr 8;
      Sum:=0;
      w:=0;
      for SrcY:=yc to yd do begin
       if (SrcY<0) or (SrcY>=aSrcHeight) then begin
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
       TempSrc:=pointer(@pansichar(aSrc)[(SrcY*aSrcWidth)+xc]);
       for SrcX:=xc to xd do begin
        if (SrcX<0) or (SrcX>=aSrcWidth) then begin
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
        inc(PAnsiChar(TempSrc),SizeOf(TpvUInt8));
        Weight:=(WeightX*WeightY) shr WeightShift;
        inc(Sum,Pixel*Weight);
        inc(w,Weight);
       end;
      end;
      if w>0 then begin
       TempDst^[0]:=Sum div w;
      end else begin
       TempDst^[0]:=0;
      end;
      TempDst:=pointer(@TempDst^[1]);
     end;
    end;
   end;
  end;
 finally
  XCache:=nil;
 end;
end;

procedure ResizeRGBA32(const aSrc:pointer;const aSrcWidth,aSrcHeight:TpvSizeInt;const aDst:pointer;const aDstWidth,aDstHeight:TpvSizeInt);
type PLongwords=^TLongwords;
     TLongwords=array[0..65535] of TpvUInt32;
var DstX,DstY,SrcX,SrcY:TpvSizeInt;
    r,g,b,a,w,Pixel,SrcR,SrcG,SrcB,SrcA,Weight,xUL,xUR,xLL,xLR,
    RedBlue,GreenAlpha,RedBlueRemainder,GreenAlphaRemainder,WeightX,WeightY:TpvUInt32;
//  SrcPtr,DstPtr:pansichar;
    TempSrc,TempDst:PLongwords;
    UpsampleX,UpsampleY:longbool;
    WeightShift,xa,xb,xc,xd,ya,yb,yc,yd:TpvSizeInt;
    SourceTexelsPerOutPixel,WeightPerPixel,AccumlatorPerPixel,WeightDivider,fw,fh:TpvFloat;
    XCache:array of TpvSizeInt;
begin
 XCache:=nil;
 if (aSrcWidth=(aDstWidth*2)) and (aSrcHeight=(aDstHeight*2)) then begin
  RedBlueRemainder:=0;
  GreenAlphaRemainder:=0;
  TempDst:=pointer(aDst);
  for DstY:=0 to aDstHeight-1 do begin
   SrcY:=DstY*2;
   TempSrc:=pointer(@pansichar(aSrc)[(SrcY*aSrcWidth) shl 2]);
   for DstX:=0 to aDstWidth-1 do begin
    xUL:=TempSrc^[0];
    xUR:=TempSrc^[1];
    xLL:=TempSrc^[aSrcWidth];
    xLR:=TempSrc^[aSrcWidth+1];
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
  UpsampleX:=aSrcWidth<aDstWidth;
  UpsampleY:=aDstHeight<aDstHeight;
  WeightShift:=0;
  SourceTexelsPerOutPixel:=((aSrcWidth/aDstWidth)+1)*((aSrcHeight/aDstHeight)+1);
  WeightPerPixel:=SourceTexelsPerOutPixel*65536;
  AccumlatorPerPixel:=WeightPerPixel*256;
  WeightDivider:=AccumlatorPerPixel/4294967000.0;
  if WeightDivider>1.0 then begin
   WeightShift:=trunc(ceil(ln(WeightDivider)/ln(2.0)));
  end;
  WeightShift:=min(WeightShift,15);
  fw:=(256*aSrcWidth)/aDstWidth;
  fh:=(256*aSrcHeight)/aDstHeight;
  if UpsampleX and UpsampleY then begin
   if length(XCache)<TpvSizeInt(aDstWidth) then begin
    SetLength(XCache,TpvSizeInt(aDstWidth));
   end;
   for DstX:=0 to aDstWidth-1 do begin
    XCache[DstX]:=min(trunc(DstX*fw),(256*(aSrcWidth-1))-1);
   end;
   for DstY:=0 to aDstHeight-1 do begin
    ya:=min(trunc(DstY*fh),(256*(aSrcHeight-1))-1);
    yc:=ya shr 8;
    TempDst:=pointer(@pansichar(aDst)[(DstY*aDstWidth) shl 2]);
    for DstX:=0 to aDstWidth-1 do begin
     xa:=XCache[DstX];
     xc:=xa shr 8;
     TempSrc:=pointer(@pansichar(aSrc)[((yc*aSrcWidth)+xc) shl 2]);
     r:=0;
     g:=0;
     b:=0;
     a:=0;
     WeightX:=TpvUInt32(TpvSizeInt(256-(xa and $ff)));
     WeightY:=TpvUInt32(TpvSizeInt(256-(ya and $ff)));
     for SrcY:=0 to 1 do begin
      for SrcX:=0 to 1 do begin
       Pixel:=TempSrc^[(SrcY*aSrcWidth)+SrcX];
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
   if length(XCache)<(TpvSizeInt(aDstWidth)*2) then begin
    SetLength(XCache,TpvSizeInt(aDstWidth)*2);
   end;
   for DstX:=0 to aDstWidth-1 do begin
    xa:=trunc(DstX*fw);
    if UpsampleX then begin
     xb:=xa+256;
    end else begin
     xb:=trunc((DstX+1)*fw);
    end;
    XCache[(DstX shl 1) or 0]:=min(xa,(256*aSrcWidth)-1);
    XCache[(DstX shl 1) or 1]:=min(xb,(256*aSrcWidth)-1);
   end;
   for DstY:=0 to aDstHeight-1 do begin
    ya:=trunc(DstY*fh);
    if UpsampleY then begin
     yb:=ya+256;
    end else begin
     yb:=trunc((DstY+1)*fh);
    end;
    TempDst:=pointer(@pansichar(aDst)[(DstY*aDstWidth) shl 2]);
    yc:=ya shr 8;
    yd:=yb shr 8;
    for DstX:=0 to aDstWidth-1 do begin
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
      if (SrcY<0) or (SrcY>=aSrcHeight) then begin
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
      TempSrc:=pointer(@pansichar(aSrc)[((SrcY*aSrcWidth)+xc) shl 2]);
      for SrcX:=xc to xd do begin
       if (SrcX<0) or (SrcX>=aSrcWidth) then begin
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
       inc(PAnsiChar(TempSrc),SizeOf(TpvUInt32));
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

procedure RGBAAlphaBleeding(const aData:Pointer;const aWidth,aHeight:TpvSizeInt;const a16Bit:Boolean);
const Offsets:array[0..8,0..1] of TpvInt32=((-1,-1),(0,-1),(1,-1),(-1,0),(0,0),(1,0),(-1,1),(0,1),(1,1));
type TpvSizeIntArray=array of TpvSizeInt;
var Size,i,j,k,Index,x,y,s,t,CountPending,CountNextPending,p,Count:TpvSizeInt;
    r,g,b:TpvInt32;
    Opaque:array of TpvUInt8;
    Loose:array of Boolean;
    Pending,NextPending:TpvSizeIntArray;
    IsLoose:boolean;
begin

 Opaque:=nil;
 Loose:=nil;
 Pending:=nil;
 NextPending:=nil;

 try

  Size:=aWidth*aHeight;

  SetLength(Opaque,Size);
  SetLength(Loose,Size);
  SetLength(Pending,Size);
  SetLength(NextPending,Size);

  FillChar(Opaque[0],Size*SizeOf(TpvUInt8),#0);
  FillChar(Loose[0],Size*SizeOf(Boolean),#0);
  FillChar(Pending[0],Size*SizeOf(TpvSizeInt),#0);
  FillChar(NextPending[0],Size*SizeOf(TpvSizeInt),#0);

  CountPending:=0;

  j:=3;
  for i:=0 to Size-1 do begin
   if ((not a16Bit) and (PpvUInt8Array(aData)^[j]=0)) or (a16Bit and (PpvUInt16Array(aData)^[j]=0)) then begin
    IsLoose:=true;
    y:=i div aWidth;
    x:=i-(y*aWidth);
    for k:=Low(Offsets) to High(Offsets) do begin
     s:=Offsets[k,0];
     t:=Offsets[k,1];
     if ((x+s)>=0) and ((x+s)<aWidth) and ((y+t)>=0) and ((y+t)<aHeight) then begin
      Index:=j+((s+(t*aWidth)) shl 2);
      if ((not a16Bit) and (PpvUInt8Array(aData)^[Index]<>0)) or (a16Bit and (PpvUInt16Array(aData)^[Index]<>0)) then begin
       IsLoose:=false;
       break;
      end;
     end;
    end;
    if IsLoose then begin
     Loose[i]:=true;
    end else begin
     Pending[CountPending]:=i;
     inc(CountPending);
    end;
   end else begin
    Opaque[i]:=$ff;
   end;
   inc(j,4);
  end;

  while CountPending>0 do begin

   CountNextPending:=0;

   for p:=0 to CountPending-1 do begin

    j:=Pending[p];
    i:=j shl 2;

    y:=j div aWidth;
    x:=j-(y*aWidth);

    r:=0;
    g:=0;
    b:=0;

    Count:=0;

    for k:=Low(Offsets) to High(Offsets) do begin
     s:=Offsets[k,0];
     t:=Offsets[k,1];
     if ((x+s)>=0) and ((x+s)<aWidth) and ((y+t)>=0) and ((y+t)<aHeight) then begin
      Index:=j+(s+(t*aWidth));
      if (Opaque[Index] and 1)<>0 then begin
       Index:=Index shl 2;
       if a16Bit then begin
        inc(r,PpvUInt16Array(aData)^[Index+0]);
        inc(g,PpvUInt16Array(aData)^[Index+1]);
        inc(b,PpvUInt16Array(aData)^[Index+2]);
       end else begin
        inc(r,PpvUInt8Array(aData)^[Index+0]);
        inc(g,PpvUInt8Array(aData)^[Index+1]);
        inc(b,PpvUInt8Array(aData)^[Index+2]);
       end;
       inc(Count);
      end;
     end;
    end;

    if Count>0 then begin
     if a16Bit then begin
      PpvUInt16Array(aData)^[i+0]:=r div Count;
      PpvUInt16Array(aData)^[i+1]:=g div Count;
      PpvUInt16Array(aData)^[i+2]:=b div Count;
     end else begin
      PpvUInt8Array(aData)^[i+0]:=r div Count;
      PpvUInt8Array(aData)^[i+1]:=g div Count;
      PpvUInt8Array(aData)^[i+2]:=b div Count;
     end;
     Opaque[j]:=$fe;
     for k:=Low(Offsets) to High(Offsets) do begin
      s:=Offsets[k,0];
      t:=Offsets[k,1];
      if ((x+s)>=0) and ((x+s)<aWidth) and ((y+t)>=0) and ((y+t)<aHeight) then begin
       Index:=j+(s+(t*aWidth));
       if Loose[Index] then begin
        Loose[Index]:=false;
        NextPending[CountNextPending]:=Index;
        inc(CountNextPending);
       end;
      end;
     end;
    end else begin
     NextPending[CountNextPending]:=j;
     inc(CountNextPending);
    end;

   end;

   if CountNextPending>0 then begin
    for p:=0 to CountPending-1 do begin
     Opaque[Pending[p]]:=Opaque[Pending[p]] shr 1;
    end;
   end;

   TpvSwap<TpvSizeIntArray>.Swap(Pending,NextPending);
   CountPending:=CountNextPending;

  end;

 finally
  Opaque:=nil;
  Loose:=nil;
  Pending:=nil;
  NextPending:=nil;
 end;

end;

end.
