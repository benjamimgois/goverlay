unit UnitOpenGLSpriteBatch;
{$ifdef fpc}
 {$mode delphi}
{$endif}

interface

uses {$ifdef fpcgl}gl,glext,{$else}dglOpenGL,{$endif}UnitOpenGLExtendedBlitRectShader;

type PSpriteBatchPoint=^TSpriteBatchPoint;
     TSpriteBatchPoint=packed record
      x,y:single;
     end;

     PSpriteBatchRect=^TSpriteBatchRect;
     TSpriteBatchRect=packed record
      Left,Top,Right,Bottom:single;
     end;

     PSpriteBatchColor=^TSpriteBatchColor;
     TSpriteBatchColor=packed record
      r,g,b,a:single;
     end;

     PSpriteBatchTexture=^TSpriteBatchTexture;
     TSpriteBatchTexture=record
      ID:GLuint;
      Width:GLint;
      Height:GLint;
     end;

     PSpriteBatchFontChar=^TSpriteBatchFontChar;
     TSpriteBatchFontChar=record
      TextureRect:TSpriteBatchRect;
      Advance:TSpriteBatchPoint;
     end;

     PSpriteBatchFontChars=^TSpriteBatchFontChars;
     TSpriteBatchFontChars=array[AnsiChar] of TSpriteBatchFontChar;

     PSpriteBatchFont=^TSpriteBatchFont;
     TSpriteBatchFont=record
      Texture:TSpriteBatchTexture;
      Chars:TSpriteBatchFontChars;
     end;

     PSpriteBatchVertex=^TSpriteBatchVertex;
     TSpriteBatchVertex=packed record
      Position:TSpriteBatchPoint;
      TextureCoord:TSpriteBatchPoint;
      Color:TSpriteBatchColor;
     end;

     TSpriteBatch=class
      private
       fReady:boolean;
       fBlending:boolean;
       fAdditiveBlending:boolean;
       fLastTextureHandle:GLuint;
       fVertexBufferObjectHandle:GLuint;
       fIndexBufferObjectHandle:GLuint;
       fVertexArrayHandle:GLuint;
       fWidthInvFactor:single;
       fHeightInvFactor:single;
       fVertexBufferUsed:GLsizei;
       fIndexBufferUsed:GLsizei;
       fClientVertex:array of TSpriteBatchVertex;
       fClientIndex:array of GLushort;
       fVertexBufferCount:GLsizei;
       fVertexBufferSize:GLsizei;
       fIndexBufferCount:GLsizei;
       fIndexBufferSize:GLsizei;
       fWidth:longint;
       fHeight:longint;
       procedure Flush;
       function RotatePoint(const PointToRotate,AroundPoint:TSpriteBatchPoint;Cosinus,Sinus:single):TSpriteBatchPoint;
       procedure SetTexture(const Texture:TSpriteBatchTexture);
      public
       constructor Create;
       destructor Destroy; override;
       procedure Setup;
       procedure SetBlending(Active,Additive:boolean);
       procedure Start;
       procedure Stop;
       procedure Draw(const Texture:TSpriteBatchTexture;const Dest,Src:TSpriteBatchRect;const Color:TSpriteBatchColor); overload;
       procedure Draw(const Texture:TSpriteBatchTexture;Dest:TSpriteBatchRect;const Color:TSpriteBatchColor); overload;
       procedure Draw(const Texture:TSpriteBatchTexture;x,y:single;const Color:TSpriteBatchColor); overload;
       procedure Draw(const Texture:TSpriteBatchTexture;dx1,dy1,dx2,dy2,sx1,sy1,sx2,sy2,Alpha:single); overload;
       procedure Draw(const Texture:TSpriteBatchTexture;Dest:TSpriteBatchRect;const Src:TSpriteBatchRect;const Origin:TSpriteBatchPoint;const Color:TSpriteBatchColor); overload;
       procedure Draw(const Texture:TSpriteBatchTexture;const Dest,Src:TSpriteBatchRect;const Origin:TSpriteBatchPoint;Rotation:single;const Color:TSpriteBatchColor); overload;
       procedure DrawText(const Font:TSpriteBatchFont;const Text:AnsiString;x,y:single;const Color:TSpriteBatchColor);
       property Width:longint read fWidth write fWidth;
       property Height:longint read fHeight write fHeight;
     end;

implementation
  
{$ifdef fpc}
 {$undef OldDelphi}
{$else}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=23.0}
   {$undef OldDelphi}
type qword=uint64;
     ptruint=NativeUInt;
     ptrint=NativeInt;
  {$else}
   {$define OldDelphi}
  {$ifend}
 {$else}
  {$define OldDelphi}
 {$endif}
{$endif}
{$ifdef OldDelphi}
type qword=int64;
{$ifdef cpu64}
     ptruint=qword;
     ptrint=int64;
{$else}
     ptruint=longword;
     ptrint=longint;
{$endif}
{$endif}

const aPositionIndex=0;
      aTexCoordIndex=1;
      aColorIndex=2;

constructor TSpriteBatch.Create;
begin
 inherited Create;
 fLastTextureHandle:=0;
 fVertexBufferObjectHandle:=0;
 fIndexBufferObjectHandle:=0;
 fVertexBufferUsed:=0;
 fIndexBufferUsed:=0;
 fReady:=false;
 fBlending:=false;
 fAdditiveBlending:=false;
 fClientVertex:=nil;
 fClientIndex:=nil;
 fVertexBufferCount:=32768;
 fVertexBufferSize:=SizeOf(TSpriteBatchVertex)*(4*fVertexBufferCount);
 fIndexBufferCount:=(fVertexBufferCount*6) div 4;
 fIndexBufferSize:=SizeOf(GLushort)*fIndexBufferCount;
 SetLength(fClientVertex,fVertexBufferCount);
 SetLength(fClientIndex,fIndexBufferCount);
 fWidth:=1;
 fHeight:=1;
end;

destructor TSpriteBatch.Destroy;
begin
 if fVertexArrayHandle<>0 then begin
  glDeleteVertexArrays(1,@fVertexArrayHandle);
 end;
 if fVertexBufferObjectHandle<>0 then begin
  glDeleteBuffers(1,@fVertexBufferObjectHandle);
 end;
 if fIndexBufferObjectHandle<>0 then begin
  glDeleteBuffers(1,@fIndexBufferObjectHandle);
 end;
 SetLength(fClientVertex,0);
 SetLength(fClientIndex,0);
 inherited Destroy;
end;

procedure TSpriteBatch.Setup;
var Index:longint;
    Vertex:TSpriteBatchVertex;
begin
 if fReady then begin
  if fVertexArrayHandle<>0 then begin
   glDeleteVertexArrays(1,@fVertexArrayHandle);
  end;
  if fVertexBufferObjectHandle<>0 then begin
   glDeleteBuffers(1,@fVertexBufferObjectHandle);
  end;
  if fIndexBufferObjectHandle<>0 then begin
   glDeleteBuffers(1,@fIndexBufferObjectHandle);
  end;
 end;
 fLastTextureHandle:=0;
 fVertexBufferObjectHandle:=0;
 fIndexBufferObjectHandle:=0;
 fVertexBufferUsed:=0;
 fIndexBufferUsed:=0;
 glGenBuffers(1,@fVertexBufferObjectHandle);
 glBindBuffer(GL_ARRAY_BUFFER,fVertexBufferObjectHandle);
 glBufferData(GL_ARRAY_BUFFER,fVertexBufferSize,nil,GL_DYNAMIC_DRAW);
 glGenBuffers(1,@fIndexBufferObjectHandle);
 glBindBuffer(GL_ELEMENT_ARRAY_BUFFER,fIndexBufferObjectHandle);
 Index:=0;
 while Index<fVertexBufferCount do begin
  fClientIndex[fIndexBufferUsed]:=Index+0;
  inc(fIndexBufferUsed);
  fClientIndex[fIndexBufferUsed]:=Index+1;
  inc(fIndexBufferUsed);
  fClientIndex[fIndexBufferUsed]:=Index+2;
  inc(fIndexBufferUsed);
  fClientIndex[fIndexBufferUsed]:=Index+0;
  inc(fIndexBufferUsed);
  fClientIndex[fIndexBufferUsed]:=Index+2;
  inc(fIndexBufferUsed);
  fClientIndex[fIndexBufferUsed]:=Index+3;
  inc(fIndexBufferUsed);
  inc(Index,4);
 end;
 glBufferData(GL_ELEMENT_ARRAY_BUFFER,fIndexBufferSize,@fClientIndex[0],GL_STATIC_DRAW);
 glGenVertexArrays(1,@fVertexArrayHandle);
 glBindVertexArray(fVertexArrayHandle);
 glBindBuffer(GL_ARRAY_BUFFER,fVertexBufferObjectHandle);
 glEnableVertexAttribArray(aPositionIndex);
 glEnableVertexAttribArray(aTexCoordIndex);
 glEnableVertexAttribArray(aColorIndex);
 glVertexAttribPointer(aPositionIndex,2,GL_FLOAT,GL_FALSE,SizeOf(TSpriteBatchVertex),pointer(ptruint(ptruint(pointer(@Vertex.Position))-ptruint(pointer(@Vertex)))));
 glVertexAttribPointer(aTexCoordIndex,2,GL_FLOAT,GL_FALSE,SizeOf(TSpriteBatchVertex),pointer(ptruint(ptruint(pointer(@Vertex.TextureCoord))-ptruint(pointer(@Vertex)))));
 glVertexAttribPointer(aColorIndex,4,GL_FLOAT,GL_FALSE,SizeOf(TSpriteBatchVertex),pointer(ptruint(ptruint(pointer(@Vertex.Color))-ptruint(pointer(@Vertex)))));
 glBindBuffer(GL_ELEMENT_ARRAY_BUFFER,fIndexBufferObjectHandle);
 glBindVertexArray(0);
 fReady:=true;
end;

function TSpriteBatch.RotatePoint(const PointToRotate,AroundPoint:TSpriteBatchPoint;Cosinus,Sinus:single):TSpriteBatchPoint;
var x,y:single;
begin
 x:=PointToRotate.x-AroundPoint.x;
 y:=PointToRotate.y-AroundPoint.y;
 result.x:=(((((x*Cosinus)-(y*Sinus))+AroundPoint.x)/fWidth)-0.5)*2;
 result.y:=-((((((x*Sinus)+(y*Cosinus))+AroundPoint.y)/fHeight)-0.5)*2);
end;

procedure TSpriteBatch.SetBlending(Active,Additive:boolean);
begin
 if (fBlending<>Active) or (fAdditiveBlending<>Additive) then begin
  Flush;
  fBlending:=Active;
  fAdditiveBlending:=Additive;
 end;
end;

procedure TSpriteBatch.Start;
begin
 fLastTextureHandle:=0;
 fVertexBufferUsed:=0;
 fIndexBufferUsed:=0;
 glDisable(GL_DEPTH_TEST);
 glDisable(GL_STENCIL_TEST);
 glDisable(GL_CULL_FACE);
 glColorMask(GL_TRUE,GL_TRUE,GL_TRUE,GL_TRUE);
 glUseProgram(ExtendedBlitRectShader.ProgramHandle);
 glUniform1i(ExtendedBlitRectShader.uTexture,2);
 glBindVertexArray(fVertexArrayHandle);
 glBindBuffer(GL_ARRAY_BUFFER,fVertexBufferObjectHandle);
 glBindBuffer(GL_ELEMENT_ARRAY_BUFFER,fIndexBufferObjectHandle);
end;

procedure TSpriteBatch.Stop;
begin
 Flush;
 glBindVertexArray(0);
 glBindBuffer(GL_ARRAY_BUFFER,0);
 glBindBuffer(GL_ELEMENT_ARRAY_BUFFER,0);
 glUseProgram(0);
end;

procedure TSpriteBatch.Flush;
begin
 if fVertexBufferUsed>0 then begin
  if fBlending then begin
   glEnable(GL_BLEND);
   glBlendEquation(GL_FUNC_ADD);
   if fAdditiveBlending then begin
    glBlendFunc(GL_ONE,GL_ONE);
   end else begin
    glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
   end;
  end else begin
   glDisable(GL_BLEND);
  end;
  glActiveTexture(GL_TEXTURE2);
  glBindTexture(GL_TEXTURE_2D,fLastTextureHandle);
  glBufferData(GL_ARRAY_BUFFER,fVertexBufferSize,nil,GL_STREAM_DRAW);
  glBufferSubData(GL_ARRAY_BUFFER,0,fVertexBufferUsed*SizeOf(TSpriteBatchVertex),@fClientVertex[0]);
  glDrawElements(GL_TRIANGLES,fIndexBufferUsed,GL_UNSIGNED_SHORT,nil);
  fVertexBufferUsed:=0;
  fIndexBufferUsed:=0;
 end;
end;

procedure TSpriteBatch.SetTexture(const Texture:TSpriteBatchTexture);
begin
 if fLastTextureHandle<>Texture.ID then begin
  Flush;
  fLastTextureHandle:=Texture.ID;
  fWidthInvFactor:=1.0/Texture.Width;
  fHeightInvFactor:=1.0/Texture.Height;
 end;
end;

procedure TSpriteBatch.Draw(const Texture:TSpriteBatchTexture;const Dest,Src:TSpriteBatchRect;const Color:TSpriteBatchColor);
var sX0,sY0,sX1,sY1:single;
begin
 SetTexture(Texture);
 sX0:=Src.Left*fWidthInvFactor;
 sY0:=Src.Top*fHeightInvFactor;
 sX1:=Src.Right*fWidthInvFactor;
 sY1:=Src.Bottom*fHeightInvFactor;
 fClientVertex[fVertexBufferUsed].Position.x:=((Dest.Left/fWidth)-0.5)*2;
 fClientVertex[fVertexBufferUsed].Position.y:=-(((Dest.Top/fHeight)-0.5)*2);
 fClientVertex[fVertexBufferUsed].TextureCoord.x:=sX0;
 fClientVertex[fVertexBufferUsed].TextureCoord.y:=sY0;
 fClientVertex[fVertexBufferUsed].Color:=Color;
 inc(fVertexBufferUsed);
 fClientVertex[fVertexBufferUsed].Position.x:=((Dest.Right/fWidth)-0.5)*2;
 fClientVertex[fVertexBufferUsed].Position.y:=-(((Dest.Top/fHeight)-0.5)*2);
 fClientVertex[fVertexBufferUsed].TextureCoord.x:=sX1;
 fClientVertex[fVertexBufferUsed].TextureCoord.y:=sY0;
 fClientVertex[fVertexBufferUsed].Color:=Color;
 inc(fVertexBufferUsed);
 fClientVertex[fVertexBufferUsed].Position.x:=((Dest.Right/fWidth)-0.5)*2;
 fClientVertex[fVertexBufferUsed].Position.y:=-(((Dest.Bottom/fHeight)-0.5)*2);
 fClientVertex[fVertexBufferUsed].TextureCoord.x:=sX1;
 fClientVertex[fVertexBufferUsed].TextureCoord.y:=sY1;
 fClientVertex[fVertexBufferUsed].Color:=Color;
 inc(fVertexBufferUsed);
 fClientVertex[fVertexBufferUsed].Position.x:=((Dest.Left/fWidth)-0.5)*2;
 fClientVertex[fVertexBufferUsed].Position.y:=-(((Dest.Bottom/fHeight)-0.5)*2);
 fClientVertex[fVertexBufferUsed].TextureCoord.x:=sX0;
 fClientVertex[fVertexBufferUsed].TextureCoord.y:=sY1;
 fClientVertex[fVertexBufferUsed].Color:=Color;
 inc(fVertexBufferUsed);
 inc(fIndexBufferUsed,6);
 if fVertexBufferUsed>=fVertexBufferCount then begin
  Flush;
 end;
end;

procedure TSpriteBatch.Draw(const Texture:TSpriteBatchTexture;Dest:TSpriteBatchRect;const Color:TSpriteBatchColor);
var Src:TSpriteBatchRect;
begin
 Dest.Right:=Texture.Width;
 Dest.Bottom:=Texture.Height;
 Src.Left:=0;
 Src.Top:=0;
 Src.Right:=Texture.Width;
 Src.Bottom:=Texture.Height;
 Draw(Texture,Dest,Src,Color);
end;

procedure TSpriteBatch.Draw(const Texture:TSpriteBatchTexture;x,y:single;const Color:TSpriteBatchColor);
var Dest,Src:TSpriteBatchRect;
begin
 Dest.Left:=x;
 Dest.Top:=y;
 Dest.Right:=x+Texture.Width;
 Dest.Bottom:=y+Texture.Height;
 Src.Left:=0;
 Src.Top:=0;
 Src.Right:=Texture.Width;
 Src.Bottom:=Texture.Height;
 Draw(Texture,Dest,Src,Color);
end;

procedure TSpriteBatch.Draw(const Texture:TSpriteBatchTexture;dx1,dy1,dx2,dy2,sx1,sy1,sx2,sy2,Alpha:single);
var Dest,Src:TSpriteBatchRect;
    Color:TSpriteBatchColor;
begin
 Dest.Left:=dx1;
 Dest.Top:=dy1;
 Dest.Right:=dx2;
 Dest.Bottom:=dy2;
 Src.Left:=sx1;
 Src.Top:=sy1;
 Src.Right:=sx2;
 Src.Bottom:=sy2;
 Color.r:=1;
 Color.g:=1;
 Color.b:=1;
 Color.a:=Alpha;
 Draw(Texture,Dest,Src,Color);
end;

procedure TSpriteBatch.Draw(const Texture:TSpriteBatchTexture;Dest:TSpriteBatchRect;const Src:TSpriteBatchRect;const Origin:TSpriteBatchPoint;const Color:TSpriteBatchColor);
begin
 Dest.Left:=Dest.Left-Origin.x;
 Dest.Top:=Dest.Top-Origin.y;
 Dest.Right:=Dest.Right-Origin.x;
 Dest.Bottom:=Dest.Bottom-Origin.y;
 Draw(Texture,Dest,Src,Color);
end;

procedure TSpriteBatch.Draw(const Texture:TSpriteBatchTexture;const Dest,Src:TSpriteBatchRect;const Origin:TSpriteBatchPoint;Rotation:single;const Color:TSpriteBatchColor);
var Cosinus,Sinus:single;
    AroundPoint:TSpriteBatchPoint;
    Points:array[0..3] of TSpriteBatchPoint;
    sX0,sY0,sX1,sY1:single;
begin
 Cosinus:=cos(Rotation);
 Sinus:=sin(Rotation);
 AroundPoint.x:=Dest.Left+Origin.x;
 AroundPoint.y:=Dest.Top+Origin.y;
 Points[0].x:=Dest.Left;
 Points[0].y:=Dest.Top;
 Points[1].x:=Dest.Right;
 Points[1].y:=Dest.Top;
 Points[2].x:=Dest.Right;
 Points[2].y:=Dest.Bottom;
 Points[3].x:=Dest.Left;
 Points[3].y:=Dest.Bottom;
 sX0:=Src.Left*fWidthInvFactor;
 sY0:=Src.Top*fHeightInvFactor;
 sX1:=Src.Right*fWidthInvFactor;
 sY1:=Src.Bottom*fHeightInvFactor;
 fClientVertex[fVertexBufferUsed].Position:=RotatePoint(Points[0],AroundPoint,Cosinus,Sinus);
 fClientVertex[fVertexBufferUsed].TextureCoord.x:=sX0;
 fClientVertex[fVertexBufferUsed].TextureCoord.y:=sY0;
 fClientVertex[fVertexBufferUsed].Color:=Color;
 inc(fVertexBufferUsed);
 fClientVertex[fVertexBufferUsed].Position:=RotatePoint(Points[1],AroundPoint,Cosinus,Sinus);
 fClientVertex[fVertexBufferUsed].TextureCoord.x:=sX1;
 fClientVertex[fVertexBufferUsed].TextureCoord.y:=sY0;
 fClientVertex[fVertexBufferUsed].Color:=Color;
 inc(fVertexBufferUsed);
 fClientVertex[fVertexBufferUsed].Position:=RotatePoint(Points[2],AroundPoint,Cosinus,Sinus);
 fClientVertex[fVertexBufferUsed].TextureCoord.x:=sX1;
 fClientVertex[fVertexBufferUsed].TextureCoord.y:=sY1;
 fClientVertex[fVertexBufferUsed].Color:=Color;
 inc(fVertexBufferUsed);
 fClientVertex[fVertexBufferUsed].Position:=RotatePoint(Points[3],AroundPoint,Cosinus,Sinus);
 fClientVertex[fVertexBufferUsed].TextureCoord.x:=sX0;
 fClientVertex[fVertexBufferUsed].TextureCoord.y:=sY1;
 fClientVertex[fVertexBufferUsed].Color:=Color;
 inc(fVertexBufferUsed);
 inc(fIndexBufferUsed,6);
 if fVertexBufferUsed>=fVertexBufferCount then begin
  Flush;
 end;
end;

procedure TSpriteBatch.DrawText(const Font:TSpriteBatchFont;const Text:AnsiString;x,y:single;const Color:TSpriteBatchColor);
var Index:longint;
    Item:PSpriteBatchFontChar;
    Dest:TSpriteBatchRect;
begin
 Dest.Left:=x;
 Dest.Top:=y;
 for Index:=1 to length(Text) do begin
  Item:=@Font.Chars[Text[Index]];
  Dest.Right:=Dest.Left+(Item^.TextureRect.Right-Item^.TextureRect.Left);
  Dest.Bottom:=Dest.Bottom+(Item^.TextureRect.Bottom-Item^.TextureRect.Top);
  Draw(Font.Texture,Dest,Item^.TextureRect,Color);
  Dest.Left:=Dest.Left+Item^.Advance.x;
  Dest.Top:=Dest.Top+Item^.Advance.y;
 end;
end;

end.
