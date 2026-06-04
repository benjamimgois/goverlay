unit UnitConsole;
{$ifdef fpc}
 {$mode delphi}
{$else}
 {$IFDEF CONDITIONALEXPRESSIONS}
  {$IF CompilerVersion >= 23.0}
   {$WARN IMPLICIT_STRING_CAST_LOSS OFF}
   {$WARN IMPLICIT_STRING_CAST OFF}
   {$WARN SUSPICIOUS_TYPECAST OFF}
  {$ifend}
 {$endif}
{$endif}
{$j+}

interface

uses SysUtils,Classes,dglOpenGL,UnitFontPNG,UnitOpenGLSpriteBatch,UnitOpenGLFrameBufferObject,UnitOpenGLImagePNG,UnitSDL2;

const Black=0;
      Blue=1;
      Green=2;
      Cyan=3;
      Red=4;
      Magenta=5;
      Brown=6;
      LightGray=7;
      DarkGray=8;
      LightBlue=9;
      LightGreen=10;
      LightCyan=11;
      LightRed=12;
      LightMagenta=13;
      Yellow=14;
      White=15;
      Blink=128;

      NormalBufferSize=8000;

type TPoint=record
      x,y:longint;
     end;

     TConsoleCommand=procedure(const aCommandLine:RawByteString);

     TCursorInfo=record
      CursorShape:byte;
      CurPos:TPoint;
      Color:byte;
     end;

     TConsoleBuffer=array of byte;

     TCustomConsole=class
      private
       SpriteBatchTexture:TSpriteBatchTexture;
       SpriteBatchWhiteTexture:TSpriteBatchTexture;
       SpriteBatchBackgroundTexture:TSpriteBatchTexture;
       SpriteBatchFrameBufferObjectTexture:TSpriteBatchTexture;
       OldBlink:boolean;
       procedure CheckXY;
       procedure DrawBuffer(const Buffer:TConsoleBuffer);
      public
       SpriteBatch:TSpriteBatch;
       ScrollBuffer,RawBuffer:TConsoleBuffer;
       chrCols,chrRows,chrWidth,chrHeight,WrapTop,WrapBottom:byte;
       BlinkOn,Blinking,ScrollLock,CursorBlinkOn,CursorOn,ActualBlinking,
       DestructiveBS,Scrolling,ForcedReDraw,Uploaded:boolean;
       WindMin,WindMax,FPS:word;
       BufSize:longint;
       Cursor:TCursorInfo;
       TexHandle:longword;
       BackgroundTexHandle:longword;
       ClearAlpha:single;
       BackgroundAlpha:single;
       BackAlpha:single;
       TextAlpha:single;
       FrameBufferObject:TFrameBufferObject;
       InternalWidth:longint;
       InternalHeight:longint;
       constructor Create; reintroduce; virtual;
       destructor Destroy; override;
       procedure Upload; virtual;
       procedure Dispose; virtual;
       procedure UpdateScreen; virtual;
       procedure ScrollOn;
       procedure ScrollTo(Position:longint;Buffer:TStringList);
       procedure ScrollOff;
       procedure SetChrDim(cols,rows:longint);
       procedure SetResolution(w,h:longint);
       procedure CLRSCR(CB:byte);
       procedure GotoXY(x,y:longint);
       function WhereX:longint;
       function WhereY:longint;
       procedure Write(st:ansistring);
       procedure WriteLn(st:ansistring);
       procedure SetTextColor(fg,bg:longint;blink:boolean);
       procedure InsLine;
       procedure DelLine;
       procedure ClrEOL;
       procedure TextColor(fg:byte);
       procedure TextBackground(bg:byte);
       function InvertColor:byte;
       procedure InvertText(x1,y1,x2,y2:longint);
       procedure Blit(x1,y1,x2,y2:single;w,h:longint;Alpha:single);
     end;

     TConsole=class(TCustomConsole)
      public
       BackgroundUploaded:boolean;
       BackgroundTextureGLTexture:longword;
       Lines:TStringList;
       History:TStringList;
       HistoryPosition:longint;
       Line:ansistring;
       LinePosition:longint;
       LineFirstPosition:longint;
       Focus:longbool;
       FocusFactor:single;
       constructor Create; override;
       destructor Destroy; override;
       procedure Upload; override;
       procedure Dispose; override;
       procedure UpdateScreen; override;
       procedure LinePositionClip;
       procedure KeyLeft;
       procedure KeyRight;
       procedure KeyUp;
       procedure KeyDown;
       procedure KeyEnter;
       procedure KeyEscape;
       procedure KeyBegin;
       procedure KeyEnd;
       procedure KeyDelete;
       procedure KeyBackspace;
       procedure KeyChar(c:ansichar);
       procedure Draw(DeltaTime:double;ViewPortX,ViewPortY,ViewPortWidth,ViewPortHeight:longint);
     end;

var ConsoleInstance:TConsole;
    ConsoleInstanceLast,ConsoleInstanceNow:int64;
    ConsoleCommandHook:TConsoleCommand=nil;
    
implementation

const VGARGB:array[0..15,0..3] of single=((0/63,0/63,0/63,1),
                                          (0/63,0/63,42/63,1),
                                          (0/63,42/63,0/63,1),
                                          (0/63,42/63,42/63,1),
                                          (42/63,0/63,0/63,1),
                                          (42/63,0/63,42/63,1),
                                          (42/63,21/63,0/63,1),
                                          (42/63,42/63,42/63,1),
                                          (21/63,21/63,21/63,1),
                                          (21/63,21/63,63/63,1),
                                          (21/63,63/63,21/63,1),
                                          (21/63,63/63,63/63,1),
                                          (63/63,21/63,21/63,1),
                                          (63/63,21/63,63/63,1),
                                          (63/63,63/63,21/63,1),
                                          (63/63,63/63,63/63,1));

constructor TCustomConsole.Create;
begin
 inherited Create;

 SpriteBatch:=nil;

 chrWidth:=8;
 chrHeight:=16;
 chrCols:=0;
 chrRows:=0;

 SetChrDim(80,25);

{CursorTimer:=TTimer.Create(self);
 CursorTimer.Interval:=333;
 CursorTimer.OnTimer:=CursorThreadTimer;
 CursorTimer.Enabled:=true;}

 Cursor.CurPos.x:=1;
 Cursor.CurPos.y:=1;
 Cursor.color:=$07;

 BlinkOn:=true;
 ActualBlinking:=false;

 DestructiveBS:=true;

 Uploaded:=false;

 CursorOn:=false;

 ClearAlpha:=1;
 BackgroundAlpha:=1;
 BackAlpha:=1;
 TextAlpha:=1;

 BackgroundTexHandle:=0;

 FrameBufferObject:=nil;

end;

destructor TCustomConsole.Destroy;
begin
 Dispose;
 inherited Destroy;
end;

procedure TCustomConsole.Upload;
const WhiteTexData:longword=$ffffffff;
var Data,NewData:pointer;
    TexWidth,TexHeight,fx,fy,x,y,fw,fh:longint;
    lw:longword;
begin
 begin
  try
   if not Uploaded then begin
    if not assigned(SpriteBatch) then begin
     SpriteBatch:=TSpriteBatch.Create;
     SpriteBatch.Setup;
    end;
    glGenTextures(1,@SpriteBatchWhiteTexture.ID);
    glBindTexture(GL_TEXTURE_2D,SpriteBatchWhiteTexture.ID);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE);
    glTexImage2D(GL_TEXTURE_2D,0,GL_RGBA,1,1,0,GL_RGBA,GL_UNSIGNED_BYTE,@WhiteTexData);
    SpriteBatchWhiteTexture.Width:=1;
    SpriteBatchWhiteTexture.Height:=1;
    SpriteBatchBackgroundTexture.Width:=1;
    SpriteBatchBackgroundTexture.Height:=1;
    glGenTextures(1,@TexHandle);
    glBindTexture(GL_TEXTURE_2D,TexHandle);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE);
    if LoadPNGImage(@UnitFontPNG.FontData[0],UnitFontPNG.FontSize,Data,TexWidth,TexHeight,false) then begin
     SpriteBatchTexture.Width:=1;
     SpriteBatchTexture.Height:=1;
     fw:=TexWidth shr 4;
     fh:=TexHeight shr 4;
     chrWidth:=fw;
     chrHeight:=fh;
     GetMem(NewData,((TexWidth*2)*(TexHeight*2))*4);
     FillChar(NewData^,((TexWidth*2)*(TexHeight*2))*4,#0);
     for fy:=0 to 15 do begin
      for fx:=0 to 15 do begin
       for y:=0 to fh-1 do begin
        for x:=0 to fw-1 do begin
         lw:=longword(pointer(@pansichar(Data)[((((fy*fh)+y)*TexWidth)+((fx*fw)+x))*4])^);
         if (lw and $00ffffff)=0 then begin
          lw:=0;
         end;
         longword(pointer(@pansichar(NewData)[((((fy*(fh*2))+y)*(TexWidth*2))+((fx*(fw*2))+x))*4])^):=lw;
        end;
       end;
      end;
     end;
     SpriteBatchTexture.ID:=TexHandle;
     glTexImage2D(GL_TEXTURE_2D,0,GL_RGBA,TexWidth*2,TexHeight*2,0,GL_RGBA,GL_UNSIGNED_BYTE,NewData);
     FreeMem(Data);
     FreeMem(NewData);
    end else begin
     glTexImage2D(GL_TEXTURE_2D,0,GL_RGBA,256,256,0,GL_RGBA,GL_UNSIGNED_BYTE,nil);
    end;
    Uploaded:=true;
   end;
  except
   Uploaded:=false;
  end;
 end;
end;

procedure TCustomConsole.Dispose;
begin
 begin
  try
   if Uploaded then begin
    if SpriteBatchWhiteTexture.ID<>0 then begin
     glDeleteTextures(1,@SpriteBatchWhiteTexture.ID);
     SpriteBatchWhiteTexture.ID:=0;
    end;
    if TexHandle<>0 then begin
     glDeleteTextures(1,@TexHandle);
     TexHandle:=0;
    end;
    Uploaded:=false;
   end;
   if assigned(FrameBufferObject) then begin
    FreeAndNil(FrameBufferObject);
   end;
   if assigned(SpriteBatch) then begin
    FreeAndNil(SpriteBatch);
   end;
  except
   Uploaded:=false;
  end;
 end;
end;

procedure TCustomConsole.UpdateScreen;
var Time:int64;
begin
 Time:=(SDL_GetPerformanceCounter*1000) div SDL_GetPerformanceFrequency;
 CursorBlinkOn:=(Time and 256)<>0;
 Blinking:=(Time and 1024)<>0;
 begin
  DrawBuffer(RawBuffer);
 end;
 OldBlink:=Blinking;
end;

procedure TCustomConsole.DrawBuffer(const Buffer:TConsoleBuffer);
var r,i,xPos,yPos,x,y,c:longint;
    Dest,Src:TSpriteBatchRect;
    Color:TSpriteBatchColor;
    t,a:single;
begin
 begin
  if not Uploaded then begin
   Upload;
  end;
  if Uploaded then begin
   t:=(SDL_GetPerformanceCounter mod (SDL_GetPerformanceCounter*86400))/SDL_GetPerformanceFrequency;
   if assigned(FrameBufferObject) and ((FrameBufferObject.Width<>InternalWidth) or (FrameBufferObject.Height<>InternalHeight)) then begin
    FreeAndNil(FrameBufferObject);
   end;
   if not assigned(FrameBufferObject) then begin
    FrameBufferObject:=TFrameBufferObject.Create(InternalWidth,InternalHeight,1,false,true,true,false,false,false);
   end;
   SpriteBatchBackgroundTexture.ID:=BackgroundTexHandle;
   FrameBufferObject.Bind;
   glViewPort(0,0,InternalWidth,InternalHeight);
   glClearColor(0,0,0,ClearAlpha);
   glClear(GL_COLOR_BUFFER_BIT);
   glDisable(GL_DEPTH_TEST);
   glDisable(GL_STENCIL_TEST);
   glDisable(GL_CULL_FACE);
   SpriteBatch.Width:=chrCols;
   SpriteBatch.Height:=chrRows;
   SpriteBatch.Start;
   SpriteBatchBackgroundTexture.ID:=BackgroundTexHandle;
   if SpriteBatchBackgroundTexture.ID>0 then begin
    SpriteBatchBackgroundTexture.Width:=1;
    SpriteBatchBackgroundTexture.Height:=1;
    SpriteBatch.SetBlending(false,false);
    Dest.Left:=0-((chrCols*2)+(cos((t*0.01)*2*pi)*chrCols));
    Dest.Right:=Dest.Left+(chrCols*4);
    Dest.Top:=0-((chrRows*2)+(sin((t*0.009)*2*pi)*chrRows));
    Dest.Bottom:=Dest.Top+(chrRows*4);
    Src.Left:=-2;
    Src.Right:=2;
    Src.Top:=-2;
    Src.Bottom:=2;
    a:=((0.5*cos(((t+173)*0.07)*2*pi))+0.5);
    Color.r:=0.33333*a;
    Color.g:=0.33333*(1-a);
    Color.b:=0.33333*((0.5*cos(((t+67)*0.03)*2*pi))+0.5);
    Color.a:=BackgroundAlpha;
    SpriteBatch.Draw(SpriteBatchBackgroundTexture,Dest,Src,Color);
    SpriteBatch.SetBlending(true,true);
    Dest.Left:=0-((chrCols*2)+(cos(((t+173)*0.01)*2*pi)*chrCols));
    Dest.Right:=Dest.Left+(chrCols*4);
    Dest.Top:=0-((chrRows*2)+(sin(((t+213)*0.009)*2*pi)*chrRows));
    Dest.Bottom:=Dest.Top+(chrRows*4);
    Src.Left:=-2;
    Src.Right:=2;
    Src.Top:=-2;
    Src.Bottom:=2;
    SpriteBatch.Draw(SpriteBatchBackgroundTexture,Dest,Src,Color);
    Dest.Left:=0-((chrCols*2)+(cos(((t+317)*0.01)*2*pi)*chrCols));
    Dest.Right:=Dest.Left+(chrCols*4);
    Dest.Top:=0-((chrRows*2)+(sin((((t+97)*0.009)+sin((t+47)*0.01))*2*pi)*chrRows));
    Dest.Bottom:=Dest.Top+(chrRows*4);
    Src.Left:=-2;
    Src.Right:=2;
    Src.Top:=-2;
    Src.Bottom:=2;
    SpriteBatch.Draw(SpriteBatchBackgroundTexture,Dest,Src,Color);
   end;
   SpriteBatch.SetBlending((BackAlpha<1) and (SpriteBatchBackgroundTexture.ID>0),false);
   for i:=0 to (BufSize shr 1)-1 do begin
    r:=i shl 1;
    yPos:=r div (chrCols shl 1);
    xPos:=(r mod (chrCols shl 1)) shr 1;
    c:=Buffer[r+1] shr 4;
    if BlinkOn and (c>7) then begin
     c:=c-8;
    end;
    if c<>0 then begin
     Dest.Left:=xPos+0;
     Dest.Right:=xPos+1;
     Dest.Top:=yPos+0;
     Dest.Bottom:=yPos+1;
     Src.Left:=0;
     Src.Right:=0;
     Src.Top:=1;
     Src.Bottom:=1;
     Color.r:=VGARGB[c and $f,0];
     Color.g:=VGARGB[c and $f,1];
     Color.b:=VGARGB[c and $f,2];
     Color.a:=BackAlpha;
     SpriteBatch.Draw(SpriteBatchWhiteTexture,Dest,Src,Color);
    end;
   end;
   SpriteBatch.Stop;
   SpriteBatch.Start;
   SpriteBatch.SetBlending(true,false);
   for i:=0 to (BufSize shr 1)-1 do begin
    r:=i shl 1;
    yPos:=r div (chrCols shl 1);
    xPos:=(r mod (chrCols shl 1)) shr 1;
    if (Buffer[r]<>0) and ((Buffer[r+1]<$80) or Blinking) then begin
     x:=Buffer[r] and $f;
     y:=Buffer[r] shr 4;
     Dest.Left:=xPos+0;
     Dest.Right:=xPos+1;
     Dest.Top:=yPos+0;
     Dest.Bottom:=yPos+1;
     Src.Left:=x*0.0625;
     Src.Right:=(x+0.5)*0.0625;
     Src.Top:=y*0.0625;
     Src.Bottom:=(y+0.5)*0.0625;
     Color.r:=VGARGB[Buffer[r+1] and $f,0];
     Color.g:=VGARGB[Buffer[r+1] and $f,1];
     Color.b:=VGARGB[Buffer[r+1] and $f,2];
     Color.a:=TextAlpha;
     SpriteBatch.Draw(SpriteBatchTexture,Dest,Src,Color);
    end;
   end;
   if CursorBlinkOn and CursorOn then begin
    SpriteBatch.Stop;
    SpriteBatch.Start;
    r:=(Cursor.CurPos.x-1+(Cursor.CurPos.y-1)*chrCols) shl 1;
    yPos:=r div (chrCols shl 1);
    xPos:=(r mod (chrCols shl 1)) shr 1;
    Dest.Left:=xPos+0;
    Dest.Right:=xPos+1;
    Dest.Top:=yPos+0;
    Dest.Bottom:=yPos+1;
    Src.Left:=0;
    Src.Right:=0;
    Src.Top:=1;
    Src.Bottom:=1;
    Color.r:=VGARGB[$f,0];
    Color.g:=VGARGB[$f,1];
    Color.b:=VGARGB[$f,2];
    Color.a:=TextAlpha;
    SpriteBatch.Draw(SpriteBatchWhiteTexture,Dest,Src,Color);
   end;
   SpriteBatch.Stop;
   FrameBufferObject.Unbind;
  end;
 end;
end;

procedure TCustomConsole.SetChrDim(cols,rows:longint);
 procedure ResizeBuf(fw,fh,tw,th:longint;var Buf:TConsoleBuffer);
 var x,y,Size:longint;
     OldBuf:TConsoleBuffer;
 begin
  Size:=(tw*th) shl 1;
  OldBuf:=copy(Buf);
  SetLength(Buf,Size);
  if Size>0 then begin
   FillChar(Buf[0],Size,#0);
   for y:=0 to th-1 do begin
    if y>=fh then begin
     break;
    end;
    for x:=0 to tw-1 do begin
     if x>=fw then begin
      break;
     end;
     word(pointer(@Buf[((y*tw)+x) shl 1])^):=word(pointer(@OldBuf[((y*fw)+x) shl 1])^);
    end;
   end;
  end;
  SetLength(OldBuf,0);
 end;
begin
 ResizeBuf(chrCols,chrRows,cols,rows,RawBuffer);
 ResizeBuf(chrCols,chrRows,cols,rows,ScrollBuffer);
 BufSize:=(Cols*Rows) shl 1;
 chrCols:=cols;
 chrRows:=rows;
 InternalWidth:=chrCols*chrWidth;
 InternalHeight:=chrRows*chrHeight;
 WindMin:=0;
 WindMax:=(chrCols-1) or ((chrRows-1) shl 8);
 WrapTop:=1;
 WrapBottom:=ChrRows;
 CheckXY;
end;

procedure TCustomConsole.SetResolution(w,h:longint);
begin
 SetChrDim(w div chrWidth,h div chrHeight);
end;

procedure TCustomConsole.CheckXY;
begin
 if Cursor.CurPos.x>ChrCols then begin
  Cursor.CurPos.x:=1;
  inc(Cursor.CurPos.y);
 end;
 if Cursor.CurPos.y>WrapBottom then begin
  if ScrollLock then begin
   Cursor.CurPos.x:=1;
   Cursor.CurPos.y:=WrapTop;
  end else begin
   if Cursor.CurPos.y>ChrRows then begin
    Cursor.CurPos.y:=ChrRows;
   end;
   InsLine;
   Cursor.CurPos.x:=1;
   Cursor.CurPos.y:=WrapBottom;
  end;
 end;
end;

procedure TCustomConsole.CLRSCR(CB:byte);
var i:longint;
begin
 Cursor.CurPos.x:=1;
 Cursor.CurPos.y:=1;
 for i:=0 to (BufSize shr 1)-1 do begin
  RawBuffer[i shl 1]:=0;
  RawBuffer[i shl 1+1]:=CB;
 end;
 ActualBlinking:=false;
end;

procedure TCustomConsole.GotoXY(x,y:longint);
begin
 if x<1 then begin
  Cursor.CurPos.x:=1;
 end else if x>=chrCols then begin
  Cursor.CurPos.x:=chrCols;
 end else begin
  Cursor.CurPos.x:=x;
 end;
 if y<1 then begin
  Cursor.CurPos.y:=1;
 end else if y>=chrRows then begin
  Cursor.CurPos.y:=chrRows;
 end else begin
  Cursor.CurPos.y:=y;
 end;
end;

function TCustomConsole.WhereX:longint;
begin
 WhereX:=Cursor.CurPos.x;
end;

function TCustomConsole.WhereY:longint;
begin
 WhereY:=Cursor.CurPos.y;
end;

procedure TCustomConsole.Write(st:ansistring);
var i,j:longint;
    MemBufPos:longint;
    c:ansichar;
begin
 for i:=1 to length(st) do begin
  c:=st[i];
  case c of
   #0:begin
   end;
   #7:begin
   // BEEP;
   end;
   #8:begin
    if DestructiveBS then begin
     dec(Cursor.CurPos.x);
     if Cursor.CurPos.x<1 then begin
      Cursor.CurPos.x:=1;
     end;
     MemBufPos:=(((Cursor.CurPos.y-1)*chrCols)+Cursor.CurPos.x-1) shl 1;
     RawBuffer[MemBufPos]:=32;
     RawBuffer[MemBufPos+1]:=Cursor.Color;
    end else begin
     dec(Cursor.CurPos.x);
     if Cursor.CurPos.x<1 then begin
      Cursor.CurPos.x:=1;
     end;
    end;
   end;
   #9:begin
    for j:=1 to (((Cursor.CurPos.x+8) and not 7)-Cursor.CurPos.x)+1 do begin
     MemBufPos:=(((Cursor.CurPos.y-1)*chrCols)+Cursor.CurPos.x-1) shl 1;
     RawBuffer[MemBufPos]:=32;
     RawBuffer[MemBufPos+1]:=Cursor.Color;
     inc(Cursor.CurPos.x);
     CheckXY;
    end;
   end;
   #10:begin
    inc(Cursor.CurPos.y);
    CheckXY;
   end;
   #12:begin
    CLRSCR(0);
   end;
   #13:begin
    Cursor.CurPos.x:=1;
   end;
   #255:begin
   end;
   else begin
    MemBufPos:=(((Cursor.CurPos.y-1)*chrCols)+Cursor.CurPos.x-1) shl 1;
    RawBuffer[MemBufPos]:=byte(c);
    RawBuffer[MemBufPos+1]:=Cursor.Color;
    inc(Cursor.CurPos.x);
    CheckXY;
   end;
  end;
 end;
end;

procedure TCustomConsole.WriteLn(st:ansistring);
begin
 Write(st+#13#10);
end;

procedure TCustomConsole.SetTextColor(fg,bg:longint;blink:boolean);
begin
 if (bg<8) and (fg<16) then begin
  Cursor.Color:=(bg shl 4) or fg;
  if blink then begin
   Cursor.Color:=Cursor.Color or 128;
  end;
 end;
end;

procedure TCustomConsole.InsLine;
var i,LineLen,StartI,EndI:longint;
begin
 linelen:=chrCols shl 1;
 StartI:=((WrapTop-1)*ChrCols) shl 1;
 if Cursor.CurPos.y>ChrRows then begin
  EndI:=(ChrCols*ChrRows) shl 1;
 end else begin
  EndI:=(ChrCols*Cursor.CurPos.y) shl 1;
 end;
 for i:=StartI to EndI-1 do begin
  if i<(EndI-linelen) then begin
   RawBuffer[i]:=RawBuffer[i+linelen];
  end else begin
   RawBuffer[i]:=0;
  end;
 end;
end;

procedure TCustomConsole.DelLine;
var i,linelen,endI:longint;
begin
 linelen:=chrCols shl 1;
 endI:=(WrapBottom*ChrCols shl 1)-1;
 for i:=(chrCols*(Cursor.CurPos.y-1) shl 1) to EndI do begin
  if (i<BufSize-linelen) then begin
   RawBuffer[i]:=RawBuffer[i+linelen];
  end else begin
   RawBuffer[i]:=0;
  end;
 end;
end;

procedure TCustomConsole.ClrEOL;
var i,MemBufPos,EndPos:longint;
begin
 MemBufPos:=(((Cursor.CurPos.y-1)*chrCols)+Cursor.CurPos.x-1) shl 1;
 EndPos:=(((Cursor.CurPos.y-1)*chrCols)+ChrCols-1) shl 1;
 for i:=MemBufPos to EndPos do begin
  RawBuffer[i]:=0;
 end;
end;

procedure TCustomConsole.TextColor(fg:byte);
var bClr:byte;
begin
 bClr:=fg;
 if fg>15 then begin
  bClr:=($0f and fg)+128;
 end;
 Cursor.Color:=($70 and Cursor.color)+bClr;
end;

procedure TCustomConsole.TextBackground(bg:byte);
begin
 Cursor.Color:=($8f and Cursor.color)+(bg shl 4);
end;

procedure TCustomConsole.ScrollOn;
begin
 Scrolling:=true;
end;

procedure TCustomConsole.ScrollOff;
begin
 Scrolling:=false;
end;

procedure TCustomConsole.ScrollTo(Position:longint;Buffer:TStringList);
var StartLine,EndLine,ScrollPos,i,x,y,Z:longint;
    S:AnsiString;
begin
 if Scrolling then begin
  FILLCHAR(ScrollBuffer[0],length(Scrollbuffer),0);
  StartLine:=Position;
  EndLine:=StartLine+ChrRows-1;
  if EndLine>buffer.count-1 then begin
   StartLine:=Buffer.Count-ChrRows;
   EndLine:=Buffer.Count-1;
  end;
  if StartLine<0 then begin
   EndLine:=Buffer.Count-1;
   StartLine:=0;
  end;
  Z:=-1;
  for i:=StartLine to EndLine do begin
   inc(Z);
   ScrollPos:=(Z*ChrCols) shl 1;
   S:=Buffer[i];
   x:=length(S);
   if x>ChrCols then begin
    x:=ChrCols;
   end;
   for y:=1 to x do begin
    if not (S[y] in [#10,#13,' ']) then begin
     ScrollBuffer[ScrollPos]:=byte(S[y]);
    end;
    ScrollBuffer[ScrollPos+1]:=15;
    inc(ScrollPos,2);
   end;
  end;
  DrawBuffer(ScrollBuffer);
 end;
end;

function TCustomConsole.InvertColor:byte;
var valRet,valFG,valBG:byte;
begin
 valBG:=(Cursor.Color and $07) shl 4;
 valFG:=(Cursor.Color and $70) shr 4;
 valRet:=(Cursor.Color and $88)+valBG+valFG;
 result:=valRet;
end;

procedure TCustomConsole.InvertText(x1,y1,x2,y2:longint);
var startPos,endPos,curPos,memPos:longint;
    valRet,valFG,valBG:byte;
begin
 startPos:=((y1-1)*chrCols)+(x1-1);
 endPos:=((y2-1)*chrCols)+(x2-1);
 if endPos>startPos then begin
  for curPos:=startPos to endPos do begin
   memPos:=(curPos shl 1) or 1;
   valFG:=(RawBuffer[memPos] and $07) shl 4;
   valBG:=(RawBuffer[memPos] and $70) shr 4;
   valRet:=(RawBuffer[memPos] and $88)+(valBG+valFG);
   RawBuffer[memPos]:=valRet;
  end;
 end;
 DrawBuffer(RawBuffer);
end;

procedure TCustomConsole.Blit(x1,y1,x2,y2:single;w,h:longint;Alpha:single);
var Dest,Src:TSpriteBatchRect;
    Color:TSpriteBatchColor;
begin
 if assigned(FrameBufferObject) then begin
  SpriteBatchFrameBufferObjectTexture.ID:=FrameBufferObject.TextureHandles[0];
  SpriteBatchFrameBufferObjectTexture.Width:=1;
  SpriteBatchFrameBufferObjectTexture.Height:=1;
  SpriteBatch.Width:=w;
  SpriteBatch.Height:=h;
  SpriteBatch.Start;
  SpriteBatch.SetBlending((ClearAlpha<1) or (Alpha<1),false);
  Dest.Left:=x1;
  Dest.Right:=x2;
  Dest.Top:=y1;
  Dest.Bottom:=y2;
  Src.Left:=0;
  Src.Right:=1;
  Src.Top:=1;
  Src.Bottom:=0;
  Color.r:=1;
  Color.g:=1;
  Color.b:=1;
  Color.a:=Alpha;
  SpriteBatch.Draw(SpriteBatchFrameBufferObjectTexture,Dest,Src,Color);
  SpriteBatch.Stop;
 end;
end;

constructor TConsole.Create;
begin
 inherited Create;

 BackgroundUploaded:=false;

 BackgroundTextureGLTexture:=0;

 Lines:=TStringList.Create;

 History:=TStringList.Create;
 HistoryPosition:=-1;

 Line:='';
 LinePosition:=1;
 LineFirstPosition:=1;

 Focus:=false;
 FocusFactor:=0;
end;

destructor TConsole.Destroy;
begin
 Lines.Free;
 History.Free;
 inherited Destroy;
end;

procedure TConsole.Upload;
var Data:pointer;
    TexWidth,TexHeight:longint;
begin
 inherited Upload;
 begin
  try
   if not BackgroundUploaded then begin
    glGenTextures(1,@BackgroundTextureGLTexture);
    glBindTexture(GL_TEXTURE_2D,BackgroundTextureGLTexture);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_REPEAT);
{   if LoadPNGImage(@CommandConsoleBackground.CommandConsoleBackgroundData[0],CommandConsoleBackground.CommandConsoleBackgroundSize,Data,TexWidth,TexHeight,false) then begin
     glTexImage2D(GL_TEXTURE_2D,0,GL_RGBA,TexWidth,TexHeight,0,GL_RGBA,GL_UNSIGNED_BYTE,Data);
     BackgroundTexHandle:=BackgroundTextureGLTexture;
    end else}begin
     glTexImage2D(GL_TEXTURE_2D,0,GL_RGBA,256,256,0,GL_RGBA,GL_UNSIGNED_BYTE,nil);
     BackgroundTexHandle:=0;
    end;
    BackgroundUploaded:=true;
   end;
  except
   BackgroundUploaded:=false;
  end;
 end;
end;

procedure TConsole.Dispose;
begin
 begin
  try
   if BackgroundUploaded then begin
    if BackgroundTextureGLTexture<>0 then begin
     glDeleteTextures(1,@BackgroundTextureGLTexture);
     BackgroundTextureGLTexture:=0;
    end;
    BackgroundUploaded:=false;
   end;
  except
   BackgroundUploaded:=false;
  end;
 end;
 inherited Dispose;
end;

procedure TConsole.UpdateScreen;
var i,j,k,x,y,c,o,t:longint;
    s:ansistring;
begin
 for i:=0 to (BufSize shr 1)-1 do begin
  RawBuffer[i shl 1]:=0;
  RawBuffer[(i shl 1) or 1]:=0;
 end;
 c:=7;
 for i:=0 to ChrRows-2 do begin
  y:=i;
  j:=(Lines.Count-(chrRows-1))+i;
  if j>=0 then begin
   s:=Lines[j];
   x:=0;
   k:=1;
   while k<=length(s) do begin
    case s[k] of
     #0:begin
      inc(k);
      if k<=length(s) then begin
       c:=byte(ansichar(s[k]));
       inc(k);
      end;
     end;
     #9:begin
      for t:=1 to 4 do begin
       if x<chrCols then begin
        o:=(y*chrCols)+x;
        RawBuffer[o shl 1]:=32;
        RawBuffer[(o shl 1) or 1]:=c;
       end;
       inc(x);
      end;
      inc(k);
     end;
     else begin
      if x<chrCols then begin
       o:=(y*chrCols)+x;
       if s[k] in [#0..#32] then begin
        RawBuffer[o shl 1]:=32;
       end else begin
        RawBuffer[o shl 1]:=byte(ansichar(s[k]));
       end;
       RawBuffer[(o shl 1) or 1]:=c;
      end;
      inc(x);
      inc(k);
     end;
    end;
   end;
  end;
 end;
 c:=15;
 y:=chrRows-1;
 x:=0;
 o:=(y*chrCols)+x;
 RawBuffer[o shl 1]:=byte(ansichar(']'));
 RawBuffer[(o shl 1) or 1]:=c;
 if LinePosition<LineFirstPosition then begin
  LineFirstPosition:=LinePosition;
 end else if (LineFirstPosition+(chrCols-2))<=LinePosition then begin
  LineFirstPosition:=LinePosition-(chrCols-2);
  if LineFirstPosition>length(Line) then begin
   LineFirstPosition:=length(Line);
  end;
  if LineFirstPosition<1 then begin
   LineFirstPosition:=1;
  end;
 end;
 if LineFirstPosition<=length(Line) then begin
  for i:=LineFirstPosition to length(Line) do begin
   j:=2+(i-LineFirstPosition);
   if j<=chrCols then begin
    o:=(y*chrCols)+(j-1);
    if Line[i] in [#0..#32] then begin
     RawBuffer[o shl 1]:=32;
    end else begin
     RawBuffer[o shl 1]:=byte(ansichar(Line[i]));
    end;
    RawBuffer[(o shl 1) or 1]:=c;
   end;
  end;
 end else begin
  LineFirstPosition:=1;
 end;
 CursorOn:=true;
 j:=2+(LinePosition-LineFirstPosition);
 if j>chrCols then begin
  j:=chrCols;
  CursorOn:=false;
 end;
 Cursor.CurPos.x:=j;
 Cursor.CurPos.y:=chrRows;
 inherited UpdateScreen;
end;

procedure TConsole.LinePositionClip;
begin
 if LinePosition>length(Line) then begin
  LinePosition:=length(Line)+1;
 end;
 if LinePosition<1 then begin
  LinePosition:=1;
 end;
end;

procedure TConsole.KeyLeft;
begin
 LinePositionClip;
 dec(LinePosition);
 LinePositionClip;
end;

procedure TConsole.KeyRight;
begin
 LinePositionClip;
 inc(LinePosition);
 LinePositionClip;
end;

procedure TConsole.KeyUp;
begin
 if HistoryPosition>0 then begin
  dec(HistoryPosition);
 end;
 if (HistoryPosition>=0) and (HistoryPosition<History.Count) then begin
  Line:=History.Strings[HistoryPosition];
  LinePosition:=length(Line)+1;
  LineFirstPosition:=1;
 end else begin
  Line:='';
  LinePosition:=1;
  LineFirstPosition:=1;
 end;
end;

procedure TConsole.KeyDown;
begin
 if (HistoryPosition>=0) and (HistoryPosition<History.Count) then begin
  inc(HistoryPosition);
 end;
 if (HistoryPosition>=0) and (HistoryPosition<History.Count) then begin
  Line:=History.Strings[HistoryPosition];
  LinePosition:=length(Line)+1;
  LineFirstPosition:=1;
 end else begin
  Line:='';
  LinePosition:=1;
  LineFirstPosition:=1;
 end;
end;

procedure TConsole.KeyEnter;
var OK:boolean;
//    Event:PSystemEvent;
begin
 OK:=length(trim(Line))>0;
 if OK then begin
  History.Add(Line);
  HistoryPosition:=History.Count;
 end;
 Lines.Add(#0#15+'>'+Line);
 if OK and assigned(ConsoleCommandHook) then begin
  ConsoleCommandHook(Line);
 end;
 LinePosition:=1;
 LineFirstPosition:=1;
 Line:='';
end;

procedure TConsole.KeyEscape;
begin
 LinePosition:=1;
 LineFirstPosition:=1;
 Line:='';
 HistoryPosition:=History.Count;
end;

procedure TConsole.KeyBegin;
begin
 LinePosition:=1;
 LineFirstPosition:=1;
end;

procedure TConsole.KeyEnd;
begin
 LinePosition:=length(Line)+1;
end;

procedure TConsole.KeyDelete;
begin
 LinePositionClip;
 if (LinePosition>=1) and (LinePosition<=length(Line)) then begin
  Delete(Line,LinePosition,1);
  LinePositionClip;
 end;
 HistoryPosition:=History.Count;
end;

procedure TConsole.KeyBackspace;
begin
 LinePositionClip;
 if LinePosition>length(Line) then begin
  Line:=copy(Line,1,length(Line)-1);
  LinePosition:=length(Line)+1;
 end else begin
  dec(LinePosition);
  Delete(Line,LinePosition,1);
  LinePositionClip;
 end;
 HistoryPosition:=History.Count;
end;

procedure TConsole.KeyChar(c:ansichar);
begin
 LinePositionClip;
 if LinePosition>length(Line) then begin
  Line:=Line+c;
  LinePosition:=length(Line)+1;
 end else begin
  Insert(c,Line,LinePosition);
  inc(LinePosition);
 end;
 HistoryPosition:=History.Count;
end;

procedure TConsole.Draw(DeltaTime:double;ViewPortX,ViewPortY,ViewPortWidth,ViewPortHeight:longint);
var Delta,x,y:single;
begin
 Delta:=DeltaTime;
 if abs(Delta)>0.25 then begin
  Delta:=0.25;
 end;
 if Focus then begin
  if FocusFactor<1 then begin
   FocusFactor:=FocusFactor+(Delta*2);
   if FocusFactor>=1 then begin
    FocusFactor:=1;
   end;
  end;
 end else begin
  if FocusFactor>0 then begin
   FocusFactor:=FocusFactor-(Delta*2);
   if FocusFactor<=0 then begin
    FocusFactor:=0;
   end;
  end;
 end;
 if FocusFactor>0.01 then begin
  ClearAlpha:=1;
  BackgroundAlpha:=1;
  BackAlpha:=1;
  UpdateScreen;
  glViewPort(ViewPortX,ViewPortY,ViewPortWidth,ViewPortHeight);
  x:=ViewPortHeight-(FocusFactor*ViewPortHeight);
  y:=0.9;
  Blit(0,-x,ViewPortWidth,ViewPortHeight-x,ViewPortWidth,ViewPortHeight,sqr(1.0-sqr(1.0-FocusFactor))*y);
  glBindTexture(GL_TEXTURE_2D,0);
 end;
end;

end.

