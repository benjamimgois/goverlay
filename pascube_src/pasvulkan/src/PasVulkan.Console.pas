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
unit PasVulkan.Console;
{$i PasVulkan.inc}
{$ifndef fpc}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=24.0}
   {$legacyifend on}
  {$ifend}
 {$endif}
{$endif}
{$m+}

{$scopedenums on}

interface

uses SysUtils,
     Classes,
     Math,
     Vulkan,
     PUCU,
     PasMP,
     PasJSON,
     PasVulkan.Types,
     PasVulkan.Math,
     PasVulkan.Framework,
     PasVulkan.Application,
     PasVulkan.Audio,
     PasVulkan.Resources,
     PasVulkan.Collections,
     PasVulkan.FrameGraph,
     PasVulkan.Canvas;

type { TpvConsole }
     TpvConsole=class
      public
       type TColors=array[0..15] of TpvVector4;
            PColors=^TColors;
            TPoint=record
             Column,Row:TpvInt32;
            end;
            PPoint=^TPoint;
            TCursorInfo=record
             CursorShape:TpvUInt8;
             CurPos:TPoint;
             Color:TpvUInt8;
            end;  
            PCursorInfo=^TCursorInfo;
            TConsoleBuffer=array of TpvUInt32;
            PConsoleBuffer=^TConsoleBuffer;
            TUTF8StringList=TpvGenericList<TpvUTF8String>;
            TOnExecute=procedure(const aLine:TpvUTF8String) of object;
            TOnSetDrawColor=procedure(const aColor:TpvVector4) of object;
            TOnDrawRect=procedure(const aX0,aY0,aX1,aY1:TpvFloat) of object;
            TOnDrawCodePoint=procedure(const aCodePoint:TpvUInt32;const aX,aY:TpvFloat) of object;
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
             VGAColors:TColors=
              (
               (r:0.0000;g:0.0000;b:0.0000;a:1.0000),
               (r:0.0000;g:0.0000;b:0.6666;a:1.0000),
               (r:0.0000;g:0.6666;b:0.0000;a:1.0000),
               (r:0.0000;g:0.6666;b:0.6666;a:1.0000),
               (r:0.6666;g:0.0000;b:0.0000;a:1.0000),
               (r:0.6666;g:0.0000;b:0.6666;a:1.0000),
               (r:0.6666;g:0.3333;b:0.0000;a:1.0000),
               (r:0.6666;g:0.6666;b:0.6666;a:1.0000),
               (r:0.3333;g:0.3333;b:0.3333;a:1.0000),
               (r:0.3333;g:0.3333;b:1.0000;a:1.0000),
               (r:0.3333;g:1.0000;b:0.3333;a:1.0000),
               (r:0.3333;g:1.0000;b:1.0000;a:1.0000),
               (r:1.0000;g:0.3333;b:0.3333;a:1.0000),
               (r:1.0000;g:0.3333;b:1.0000;a:1.0000),
               (r:1.0000;g:1.0000;b:0.3333;a:1.0000),
               (r:1.0000;g:1.0000;b:1.0000;a:1.0000)
              );
      private
       fCanvas:TpvCanvas;   
       fScrollBuffer:TConsoleBuffer;
       fRawBuffer:TConsoleBuffer;                  
       fColumns:TpvSizeInt;
       fRows:TpvSizeInt;
       fCharWidth:TpvSizeInt;
       fCharHeight:TpvSizeInt;
       fWrapTop:TpvSizeInt;
       fWrapBottom:TpvSizeInt;
       fTabWidth:TpvSizeInt;
       fBlinkOn:Boolean;
       fScrollLock:Boolean;
       fCursorBlinkOn:Boolean;
       fCursorOn:Boolean;
       fActualBlinking:Boolean;
       fDestructiveBackspace:Boolean;
       fScrolling:Boolean;
       fForcedRedraw:Boolean;
       fUploaded:Boolean;
       fOverwrite:Boolean;
       fWindMin:TpvUInt32;
       fWindMax:TpvUInt32;
       fCursor:TCursorInfo;
       fInternalWidth:TpvSizeInt;
       fInternalHeight:TpvSizeInt; 
       fLines:TUTF8StringList;
       fHistory:TUTF8StringList;
       fHistoryIndex:TpvSizeInt;
       fLine:TpvUTF8String;
       fLinePosition:TpvInt32;
       fLineFirstPosition:TpvInt32;
       fBlinkTimeAccumulator:TpvDouble;
       fCursorTimeAccumulator:TpvDouble;
       fColors:PColors;
       fCurrentBuffer:PConsoleBuffer;
       fOnExecute:TOnExecute;
       fOnSetDrawColor:TOnSetDrawColor;
       fOnDrawRect:TOnDrawRect;
       fOnDrawCodePoint:TOnDrawCodePoint;
       fHistoryFileName:String;
      public
       constructor Create;
       destructor Destroy; override;
       procedure Upload;
       procedure Dispose;
       procedure UpdateScreen;
       procedure CheckXY;
       procedure ScrollOn;
       procedure ScrollTo(const aPosition:TpvSizeInt;const aBuffer:TUTF8StringList);
       procedure ScrollOff;
       procedure SetChrDim(const aCols,aRows:TpvSizeInt);
       procedure SetResolution(const aWidth,aHeight:TpvSizeInt);
       procedure CLRSCR(aCB:TpvUInt8);
       procedure GotoXY(aX,aY:TpvSizeInt);
       function WhereX:TpvSizeInt;
       function WhereY:TpvSizeInt;
       procedure Write(const aString:TpvUTF8String);
       procedure WriteLn(const aString:TpvUTF8String);
       procedure WriteLine(const aString:TpvUTF8String);
       procedure SetTextColor(const aForegroundColor,aBackgroundColor:TpvSizeInt;const aBlink:Boolean);
       procedure InsLine;
       procedure DelLine;
       procedure ClrEOL;
       procedure TextColor(const aForeground:TpvUInt8);
       procedure TextBackground(const aBackground:TpvUInt8);
       function InvertColor:TpvUInt8;
       procedure InvertText(const aX0,aY0,aX1,aY1:TpvSizeInt);
       procedure LinePositionClip;
       procedure KeyLeft;
       procedure KeyRight;
       procedure KeyUp;
       procedure KeyDown;
       procedure KeyEnter;
       procedure KeyEscape;
       procedure KeyHome;
       procedure KeyEnd;
       procedure KeyInsert;
       procedure KeyDelete;
       procedure KeyBackspace;
       procedure KeyDeletePreviousWord;
       procedure KeyCutFromCurrentToEndOfLine;
       procedure KeyCutFromLineStartToCursor;
       procedure KeyPaste;
       procedure KeyClearScreen;
       procedure KeySwapCurrentCodePointWithPreviousCodePoint;
       procedure KeyChar(const aCodePoint:TpvUInt32);
       function GetBuffer(const aColumn,aRow:TpvSizeInt;out aCodePoint:TpvUInt32;out aForegroundColor,aBackgroundColor:TpvSizeInt;out aBlink:Boolean):boolean;
       procedure Draw(const aDeltaTime:TpvDouble);
       function KeyEvent(const aKeyEvent:TpvApplicationInputKeyEvent):boolean;
       procedure LoadHistoryFromStream(const aStream:TStream);
       procedure LoadHistoryFromFileName(const aFileName:String);
       procedure SaveHistoryToStream(const aStream:TStream);
       procedure SaveHistoryToFileName(const aFileName:String);
       procedure AppendToHistoryFileName(const aFileName:String;const aLine:TpvUTF8String);
      public
       property CharWidth:TpvSizeInt read fCharWidth write fCharWidth;
       property CharHeight:TpvSizeInt read fCharHeight write fCharHeight;
       property Columns:TpvSizeInt read fColumns write fColumns;
       property Rows:TpvSizeInt read fRows write fRows;
       property TabWidth:TpvSizeInt read fTabWidth write fTabWidth;
       property CursorBlinkOn:Boolean read fCursorBlinkOn write fCursorBlinkOn;
       property CursorOn:Boolean read fCursorOn write fCursorOn;
       property Cursor:TCursorInfo read fCursor write fCursor;
       property ScrollLock:Boolean read fScrollLock write fScrollLock;
       property DestructiveBackspace:Boolean read fDestructiveBackspace write fDestructiveBackspace;
       property ForcedRedraw:Boolean read fForcedRedraw write fForcedRedraw;
       property Uploaded:Boolean read fUploaded write fUploaded;
       property Overwrite:Boolean read fOverwrite write fOverwrite;
       property WindMin:TpvUInt32 read fWindMin write fWindMin;
       property WindMax:TpvUInt32 read fWindMax write fWindMax;
       property Lines:TUTF8StringList read fLines;
       property Colors:PColors read fColors write fColors;
      published
       property OnExecute:TOnExecute read fOnExecute write fOnExecute;
       property OnSetDrawColor:TOnSetDrawColor read fOnSetDrawColor write fOnSetDrawColor;
       property OnDrawRect:TOnDrawRect read fOnDrawRect write fOnDrawRect;
       property OnDrawCodePoint:TOnDrawCodePoint read fOnDrawCodePoint write fOnDrawCodePoint;
      public
       property History:TUTF8StringList read fHistory;
       property HistoryIndex:TpvSizeInt read fHistoryIndex write fHistoryIndex;
       property HistoryFileName:String read fHistoryFileName write fHistoryFileName;
     end;

implementation

{ TpvConsole }

constructor TpvConsole.Create;
begin
 inherited Create;

 fCanvas:=nil;

 fScrollBuffer:=nil;
 fRawBuffer:=nil;
 
 fCharWidth:=8;
 fCharHeight:=16;
 fColumns:=0;
 fRows:=0;

 fWrapTop:=0;
 fWrapBottom:=0;

 fTabWidth:=2;

 SetChrDim(80,25);
 CLRSCR(7);

 fBlinkOn:=true;
 fActualBlinking:=true;

 fScrollLock:=false;

 fCursorBlinkOn:=true;
 fCursorOn:=true;

 fCursor.CurPos.Column:=1;
 fCursor.CurPos.Row:=1;
 fCursor.Color:=7;

 fColors:=@VGAColors;

 fScrolling:=true;

 fLinePosition:=1;
 fLineFirstPosition:=1;

 fLines:=TUTF8StringList.Create;

 fHistory:=TUTF8StringList.Create;

 fHistoryFileName:='';

 fLine:='';

 fBlinkTimeAccumulator:=0.0;

 fCursorTimeAccumulator:=0.0;

 fCurrentBuffer:=@fRawBuffer;

 fOnExecute:=nil;

 fOnSetDrawColor:=nil;

 fOnDrawRect:=nil;

 fOnDrawCodePoint:=nil;

end;

destructor TpvConsole.Destroy;
begin
 FreeAndNil(fCanvas);
 FreeAndNil(fHistory);
 FreeAndNil(fLines);
 fScrollBuffer:=nil;
 fRawBuffer:=nil;
 inherited Destroy;
end;

procedure TpvConsole.Upload;
begin
 if not fUploaded then begin
  fUploaded:=true;
 end;
end;

procedure TpvConsole.Dispose;
begin
 if fUploaded then begin
  fUploaded:=false;
 end;
end;

procedure TpvConsole.UpdateScreen;
var j,x,y,o:TpvSizeInt;
    i,m,k,l,LineFirstPositionCodePoint,LinePositionCodePoint:TPUCUInt32;
    s:TpvUTF8String;
    u32,c:TPUCUUInt32;
begin
 fCurrentBuffer:=@fRawBuffer;
 for i:=0 to (Length(fRawBuffer) shr 1)-1 do begin
  fRawBuffer[i shl 1]:=0;
  fRawBuffer[(i shl 1) or 1]:=15;
 end;
 c:=7;
 for i:=0 to fRows-2 do begin
  y:=i;
  j:=(fLines.Count-(fRows-1))+i;
  if j>=0 then begin
   s:=fLines[j];
   x:=0;
   k:=1;
   l:=length(s);
   while k<=l do begin
    u32:=PUCUUTF8CodeUnitGetCharAndIncFallback(s,k);
    case u32 of
     0,31:begin
      if k<=l then begin
       c:=PUCUUTF8CodeUnitGetCharAndIncFallback(s,k);
      end;
     end;
     else begin
      if x<fColumns then begin
       o:=(y*fColumns)+x;
       fRawBuffer[o shl 1]:=u32;
       fRawBuffer[(o shl 1) or 1]:=c;
      end;
      inc(x);
     end;
    end; 
   end;
  end;
 end;
 c:=15;
 y:=fRows-1;
 x:=0;
 o:=(y*fColumns)+x;
 fRawBuffer[o shl 1]:=TpvUInt8(ansichar(']'));
 fRawBuffer[(o shl 1) or 1]:=c;
 if fLinePosition<fLineFirstPosition then begin
  fLineFirstPosition:=fLinePosition;
 end else begin
  LineFirstPositionCodePoint:=PUCUUTF8GetCodePoint(fLine,fLineFirstPosition);
  LinePositionCodePoint:=PUCUUTF8GetCodePoint(fLine,fLinePosition);
  if (LineFirstPositionCodePoint+(fColumns-2))<=LinePositionCodePoint then begin
   fLineFirstPosition:=PUCUUTF8GetCodeUnit(fLine,Max(0,LinePositionCodePoint-(fColumns-2)));
   if fLineFirstPosition>length(fLine) then begin
    fLineFirstPosition:=length(fLine);
   end;
   if fLineFirstPosition<1 then begin
    fLineFirstPosition:=1;
   end;
  end;
 end;
 if fLineFirstPosition<=length(fLine) then begin
  i:=fLineFirstPosition;
  j:=2;
  while i<=length(fLine) do begin
   u32:=PUCUUTF8CodeUnitGetCharAndIncFallback(fLine,i);
   if j<=fColumns then begin
    o:=(y*fColumns)+(j-1);
    fRawBuffer[o shl 1]:=u32;
    fRawBuffer[(o shl 1) or 1]:=c;
   end;
   inc(j);
  end;
 end else begin
  fLineFirstPosition:=1;
 end;
 fCursorOn:=true;
 j:=2+(PUCUUTF8GetCodePoint(fLine,fLinePosition)-PUCUUTF8GetCodePoint(fLine,fLineFirstPosition));
 if j>fColumns then begin
  j:=fColumns;
  fCursorOn:=false;
 end;
 fCursor.CurPos.Column:=j;
 fCursor.CurPos.Row:=fRows;
end;

procedure TpvConsole.ScrollOn;
begin
 fScrolling:=true;
end;

procedure TpvConsole.ScrollTo(const aPosition:TpvSizeInt;const aBuffer:TUTF8StringList);
var StartLine,EndLine,ScrollPos,i,x,y,z,l:TpvSizeInt;
    S:TpvUTF8String;
    p:TPUCUInt32;
    c:TpvUInt32;
begin
 if fScrolling then begin
  FillChar(fScrollBuffer[0],Length(fScrollBuffer),0);
  StartLine:=aPosition;
  EndLine:=StartLine+fRows-1;
  if EndLine>aBuffer.Count-1 then begin
   StartLine:=aBuffer.Count-fRows;
   EndLine:=aBuffer.Count-1;
  end;
  if StartLine<0 then begin
   EndLine:=aBuffer.Count-1;
   StartLine:=0;
  end;
  z:=-1;
  for i:=StartLine to EndLine do begin
   inc(z);
   ScrollPos:=(z*fColumns) shl 1;
   S:=aBuffer[i];
   x:=Length(S);
   if x>fColumns then begin
    x:=fColumns;
   end;
   l:=x;
   p:=1;
   for y:=1 to x do begin
    if p>l then begin
     break;
    end else begin 
     c:=PUCUUTF8CodeUnitGetCharAndIncFallback(S,p);
     case c of
      10,13,32:begin        
       fScrollBuffer[ScrollPos]:=0;
      end;
      else begin
       fScrollBuffer[ScrollPos]:=c;
      end;
     end;
     fScrollBuffer[ScrollPos+1]:=15;
     inc(ScrollPos,2);
    end; 
   end;
  end;
  fCurrentBuffer:=@fScrollBuffer;
 end;
end;

procedure TpvConsole.ScrollOff;
begin
 fScrolling:=false;
end;

procedure TpvConsole.CheckXY;
begin
 if fCursor.CurPos.Column>fColumns then begin
  fCursor.CurPos.Column:=1;
  inc(fCursor.CurPos.Row);
 end;
 if fCursor.CurPos.Row>fWrapBottom then begin
  if fScrollLock then begin
   fCursor.CurPos.Column:=1;
   fCursor.CurPos.Row:=fWrapTop;
  end else begin
   if fCursor.CurPos.Row>fRows then begin
    fCursor.CurPos.Row:=fRows;
   end;
   InsLine;
   fCursor.CurPos.Column:=1;
   fCursor.CurPos.Row:=fWrapBottom;
  end;
 end;
end;

procedure TpvConsole.SetChrDim(const aCols,aRows:TpvSizeInt);
 procedure ResizeBuf(const aFW,aFH,aTW,aTH:TpvSizeInt;var aBuf:TConsoleBuffer);
 var x,y,Size:TpvSizeInt;
     OldBuf:TConsoleBuffer;
 begin
  Size:=(aTW*aTH) shl 1;
  OldBuf:=Copy(aBuf);
  SetLength(aBuf,Size);
  if Size>0 then begin
   FillChar(aBuf[0],Size*SizeOf(TpvUInt32),#0);
   for y:=0 to aTH-1 do begin
    if y>=aFH then begin
     break;
    end;
    for x:=0 to aTW-1 do begin
     if x>=aFW then begin
      break;
     end;
     PpvUInt64(pointer(@aBuf[((y*aTW)+x) shl 1])^):=PpvUInt64(pointer(@OldBuf[((y*aFW)+x) shl 1])^);
    end;
   end;
  end;
  SetLength(OldBuf,0);
 end;
begin
 ResizeBuf(fColumns,fRows,aCols,aRows,fRawBuffer);
 ResizeBuf(fColumns,fRows,aCols,aRows,fScrollBuffer);
 fColumns:=aCols;
 fRows:=aRows;
 fInternalWidth:=fColumns*fCharWidth;
 fInternalHeight:=fRows*fCharHeight;
 fWindMin:=0;
 fWindMax:=(fColumns-1) or ((fRows-1) shl 8);
 fWrapTop:=1;
 fWrapBottom:=fRows;
 CheckXY;
end;

procedure TpvConsole.SetResolution(const aWidth,aHeight:TpvSizeInt);
begin
 SetChrDim(aWidth div fCharWidth,aHeight div fCharHeight);
end;

procedure TpvConsole.CLRSCR(aCB:TpvUInt8);
var i:TpvSizeInt;
begin
 fCursor.CurPos.Column:=1;
 fCursor.CurPos.Row:=1;
 for i:=0 to (Length(fRawBuffer) shr 1)-1 do begin
  fRawBuffer[i shl 1]:=0;
  fRawBuffer[i shl 1+1]:=aCB;
 end;
 fActualBlinking:=false;
end;

procedure TpvConsole.GotoXY(aX,aY:TpvSizeInt);
begin
 if aX<1 then begin
  fCursor.CurPos.Column:=1;
 end else if aX>=fColumns then begin
  fCursor.CurPos.Column:=fColumns;
 end else begin
  fCursor.CurPos.Column:=aX;
 end;
 if aY<1 then begin
  fCursor.CurPos.Row:=1;
 end else if aY>=fRows then begin
  fCursor.CurPos.Row:=fRows;
 end else begin
  fCursor.CurPos.Row:=aY;
 end;
end; 

function TpvConsole.WhereX:TpvSizeInt;
begin
 result:=fCursor.CurPos.Column;
end;

function TpvConsole.WhereY:TpvSizeInt;
begin
 result:=fCursor.CurPos.Row;
end;

procedure TpvConsole.Write(const aString:TpvUTF8String);
var i,l:TPUCUInt32;
    j,MemBufPos:TpvSizeInt;
    c:TpvUInt32;
begin
 i:=1;
 l:=length(aString);
 while i<=l do begin
  c:=PUCUUTF8CodeUnitGetCharAndIncFallback(aString,i);
  case c of
   0:begin
   end;
   7:begin
   end;
   8:begin
    if fDestructiveBackspace then begin
     dec(fCursor.CurPos.Column);
     if fCursor.CurPos.Column<1 then begin
      fCursor.CurPos.Column:=1;
     end;
     MemBufPos:=(((fCursor.CurPos.Row-1)*fColumns)+fCursor.CurPos.Column-1) shl 1;
     fRawBuffer[MemBufPos]:=32;
     fRawBuffer[MemBufPos+1]:=fCursor.Color;
    end else begin
     dec(fCursor.CurPos.Column);
     if fCursor.CurPos.Column<1 then begin
      fCursor.CurPos.Column:=1;
     end;
    end;
   end;
   9:begin
    if (fTabWidth and (fTabWidth-1))=0 then begin
     for j:=1 to (((fCursor.CurPos.Column+fTabWidth) and not (fTabWidth-1))-fCursor.CurPos.Column)+1 do begin
      MemBufPos:=(((fCursor.CurPos.Row-1)*fColumns)+fCursor.CurPos.Column-1) shl 1;
      fRawBuffer[MemBufPos]:=32;
      fRawBuffer[MemBufPos+1]:=fCursor.Color;
      inc(fCursor.CurPos.Column);
      CheckXY;
     end;
    end else begin
     for j:=1 to ((fCursor.CurPos.Column-((fCursor.CurPos.Column+fTabWidth) mod fTabWidth))-fCursor.CurPos.Column)+1 do begin
      MemBufPos:=(((fCursor.CurPos.Row-1)*fColumns)+fCursor.CurPos.Column-1) shl 1;
      fRawBuffer[MemBufPos]:=32;
      fRawBuffer[MemBufPos+1]:=fCursor.Color;
      inc(fCursor.CurPos.Column);
      CheckXY;
     end;
    end;
   end;
   10:begin
    inc(fCursor.CurPos.Row);
    CheckXY;
   end;
   12:begin
    CLRSCR(0);
   end;
   13:begin
    fCursor.CurPos.Column:=1;
   end;
   255:begin
   end;
   else begin
    MemBufPos:=(((fCursor.CurPos.Row-1)*fColumns)+fCursor.CurPos.Column-1) shl 1;
    fRawBuffer[MemBufPos]:=c;
    fRawBuffer[MemBufPos+1]:=fCursor.Color;
    inc(fCursor.CurPos.Column);
    CheckXY;
   end;
  end;
 end;
end;

procedure TpvConsole.WriteLn(const aString:TpvUTF8String);
begin
 Write(aString+#13#10);
end;

procedure TpvConsole.WriteLine(const aString:TpvUTF8String);
var i,j,k,l,x:TPUCUInt32;
    OneLine:TpvUTF8String;
    c:TPUCUUInt32;
begin
 i:=1;
 l:=length(aString);
 j:=0;
 x:=0;
 OneLine:='';
 while (i<=l) do begin
  c:=PUCUUTF8CodeUnitGetCharAndIncFallback(aString,i);
  case c of
   0,31:begin
    // Color escape
    OneLine:=OneLine+#0;
    if i<=l then begin
     OneLine:=OneLine+PUCUUTF32CharToUTF8(PUCUUTF8CodeUnitGetCharAndIncFallback(aString,i));
    end;
   end;
   9:begin
    // Tab
    if (fTabWidth and (fTabWidth-1))=0 then begin
     for k:=1 to (((x+fTabWidth) and not (fTabWidth-1))-x)+1 do begin
      OneLine:=OneLine+#32;
      inc(x);
     end;
    end else begin
     for k:=1 to ((x-((x+fTabWidth) mod fTabWidth))-x)+1 do begin
      OneLine:=OneLine+#32;
      inc(x);
     end;
    end;
   end;
   10:begin
    fLines.Add(OneLine);
    OneLine:='';
    j:=0;
    x:=0;
   end;
   13:begin
    // Ignore
   end;
   else begin
    OneLine:=OneLine+PUCUUTF32CharToUTF8(c);
    inc(j);
    inc(x);
    if j>=fColumns then begin
     fLines.Add(OneLine);
     OneLine:='';
     j:=0;
     x:=0;
    end;
   end;
  end;
 end;
 fLines.Add(OneLine);
end;

procedure TpvConsole.SetTextColor(const aForegroundColor,aBackgroundColor:TpvSizeInt;const aBlink:Boolean);
begin
 if (aBackgroundColor<8) and (aForegroundColor<16) then begin
  fCursor.Color:=(aBackgroundColor shl 4) or aForegroundColor;
  if aBlink then begin
   fCursor.Color:=fCursor.Color or 128;
  end;
 end;
end;

procedure TpvConsole.InsLine;
var i,LineLen,StartI,EndI:TpvSizeInt;
begin
 LineLen:=fColumns shl 1;
 StartI:=((fWrapTop-1)*fColumns) shl 1;
 if fCursor.CurPos.Row>fRows then begin
  EndI:=(fColumns*fRows) shl 1;
 end else begin
  EndI:=(fColumns*fCursor.CurPos.Row) shl 1;
 end;
 for i:=StartI to EndI-1 do begin
  if i<(EndI-LineLen) then begin
   fRawBuffer[i]:=fRawBuffer[i+LineLen];
  end else begin
   fRawBuffer[i]:=0;
  end;
 end;
end;

procedure TpvConsole.DelLine;
var i,LineLen,EndI:TpvSizeInt;
begin
 LineLen:=fColumns shl 1;
 EndI:=(fWrapBottom*fColumns shl 1)-1;
 for i:=(fColumns*(fCursor.CurPos.Row-1) shl 1) to EndI do begin
  if (i<Length(fRawBuffer)-LineLen) then begin
   fRawBuffer[i]:=fRawBuffer[i+LineLen];
  end else begin
   fRawBuffer[i]:=0;
  end;
 end;
end;

procedure TpvConsole.ClrEOL;
var i,MemBufPos,EndPos:TpvSizeInt;
begin
 MemBufPos:=(((fCursor.CurPos.Row-1)*fColumns)+fCursor.CurPos.Column-1) shl 1;
 EndPos:=(((fCursor.CurPos.Row-1)*fColumns)+fColumns-1) shl 1;
 for i:=MemBufPos to EndPos do begin
  fRawBuffer[i]:=0;
 end;
end;

procedure TpvConsole.TextColor(const aForeground:TpvUInt8);
var BackgroundColor:TpvUInt8;
begin
 BackgroundColor:=fCursor.Color and $f0;
 fCursor.Color:=(BackgroundColor or (aForeground and $0f));
end;

procedure TpvConsole.TextBackground(const aBackground:TpvUInt8);
var ForegroundColor:TpvUInt8;
begin
 ForegroundColor:=fCursor.Color and $0f;
 fCursor.Color:=((aBackground shl 4) or ForegroundColor);
end;

function TpvConsole.InvertColor:TpvUInt8;
begin
 result:=(fCursor.Color and $88)+((fCursor.Color and $07) shl 4)+((fCursor.Color and $70) shr 4);
end;

procedure TpvConsole.InvertText(const aX0,aY0,aX1,aY1:TpvSizeInt);
var StartPos,EndPos,CurPos,MemPos:TpvSizeInt;
    ValRet,ValFG,ValBG:TpvUInt8;
begin
 StartPos:=((aY0-1)*fColumns)+(aX0-1);
 EndPos:=((aY1-1)*fColumns)+(aX1-1);
 if EndPos>StartPos then begin
  for CurPos:=StartPos to EndPos do begin
   MemPos:=(CurPos shl 1) or 1;
   ValFG:=(fRawBuffer[MemPos] and $07) shl 4;
   ValBG:=(fRawBuffer[MemPos] and $70) shr 4;
   ValRet:=(fRawBuffer[MemPos] and $88)+(ValBG+ValFG);
   fRawBuffer[MemPos]:=ValRet;
  end;
 end;
 fCurrentBuffer:=@fRawBuffer;
end;

procedure TpvConsole.LinePositionClip;
begin
 if fLinePosition>Length(fLine) then begin
  fLinePosition:=Length(fLine)+1;
 end;
 if fLinePosition<1 then begin
  fLinePosition:=1;
 end;
end;

procedure TpvConsole.KeyLeft;
begin
 LinePositionClip;
 if (fLinePosition>1) and (fLinePosition<=(length(fLine)+1)) then begin
  PUCUUTF8Dec(fLine,fLinePosition);
 end;
 LinePositionClip;
 fCursorTimeAccumulator:=0.0;
end;

procedure TpvConsole.KeyRight;
begin
 LinePositionClip;
 if (fLinePosition>=1) and (fLinePosition<=length(fLine)) then begin
  PUCUUTF8SafeInc(fLine,fLinePosition);
 end;
 LinePositionClip;
 fCursorTimeAccumulator:=0.0;
end;

procedure TpvConsole.KeyUp;
begin
 if fHistoryIndex>0 then begin
  dec(fHistoryIndex);
 end;
 if (fHistoryIndex>=0) and (fHistoryIndex<fHistory.Count) then begin
  fLine:=fHistory.Items[fHistoryIndex];
  fLinePosition:=length(fLine)+1;
  fLineFirstPosition:=1;
 end else begin
  fLine:='';
  fLinePosition:=1;
  fLineFirstPosition:=1;
 end;
 fCursorTimeAccumulator:=0.0;
end;

procedure TpvConsole.KeyDown;
begin
 if (fHistoryIndex>=0) and (fHistoryIndex<fHistory.Count) then begin
  inc(fHistoryIndex);
 end;
 if (fHistoryIndex>=0) and (fHistoryIndex<fHistory.Count) then begin
  fLine:=fHistory.Items[fHistoryIndex];
  fLinePosition:=length(fLine)+1;
  fLineFirstPosition:=1;
 end else begin
  fLine:='';
  fLinePosition:=1;
  fLineFirstPosition:=1;
 end;
 fCursorTimeAccumulator:=0.0;
end;

procedure TpvConsole.KeyEnter;
var OK:boolean;
begin
 OK:=length(trim(fLine))>0;
 if OK then begin
  fHistory.Add(fLine);
  fHistoryIndex:=fHistory.Count;
  if length(fHistoryFileName)>0 then begin
   AppendToHistoryFileName(fHistoryFileName,fLine);
  end;
 end;
 WriteLine(#0#15+'>'+fLine);
 if OK and assigned(fOnExecute) then begin
  fOnExecute(fLine);
 end;
 fLinePosition:=1;
 fLineFirstPosition:=1;
 fLine:='';
 fCursorTimeAccumulator:=0.0;
end;

procedure TpvConsole.KeyEscape;
begin
 fLinePosition:=1;
 fLineFirstPosition:=1;
 fLine:='';
 fHistoryIndex:=fHistory.Count;
 fCursorTimeAccumulator:=0.0;
end;

procedure TpvConsole.KeyHome;
begin
 fLinePosition:=1;
 fLineFirstPosition:=1;
 fCursorTimeAccumulator:=0.0;
end;

procedure TpvConsole.KeyEnd;
begin
 fLinePosition:=length(fLine)+1;
 fCursorTimeAccumulator:=0.0;
end;

procedure TpvConsole.KeyInsert;
begin
 fOverwrite:=not fOverwrite;
 fCursorTimeAccumulator:=0.0;
end;

procedure TpvConsole.KeyDelete;
var CodeUnitLength:TpvSizeInt;
begin
 LinePositionClip;
 if (fLinePosition>=1) and (fLinePosition<=length(fLine)) then begin
  CodeUnitLength:=PUCUUTF8GetCharLen(fLine,fLinePosition);
  Delete(fLine,fLinePosition,CodeUnitLength);
  LinePositionClip;
 end;
 fHistoryIndex:=fHistory.Count;
 fCursorTimeAccumulator:=0.0;
end;

procedure TpvConsole.KeyBackspace;
var //CodeUnitLength:TpvSizeInt;
    i:TPUCUInt32; 
begin
 LinePositionClip;
 if fLinePosition>length(fLine) then begin
  i:=length(fLine)+1;
  PUCUUTF8Dec(fLine,i);
  fLine:=copy(fLine,1,i-1);
  fLinePosition:=length(fLine)+1;
 end else begin
  i:=fLinePosition;
  PUCUUTF8Dec(fLine,i);
  Delete(fLine,i,fLinePosition-i);
  fLinePosition:=i;
  LinePositionClip;
 end;
 fHistoryIndex:=fHistory.Count;
 fCursorTimeAccumulator:=0.0;
end;

procedure TpvConsole.KeyDeletePreviousWord;
var i,Diff:TpvSizeInt;
begin
 LinePositionClip;
 i:=fLinePosition;
 while (i>1) and (fLine[i]=' ') do begin
  dec(i);
 end;
 while (i>1) and (fLine[i]<>' ') do begin
  dec(i);
 end;
 Diff:=fLinePosition-i;
 Delete(fLine,i,Diff);
 fLinePosition:=i;
 fHistoryIndex:=fHistory.Count;
 fCursorTimeAccumulator:=0.0;
end;

procedure TpvConsole.KeyCutFromCurrentToEndOfLine;
var i,Diff:TpvSizeInt;
begin
 LinePositionClip;
 i:=fLinePosition;
 Diff:=length(fLine)-i+1;
 pvApplication.Clipboard.SetText(copy(fLine,i,Diff));
 Delete(fLine,i,Diff);
 fHistoryIndex:=fHistory.Count;
 fCursorTimeAccumulator:=0.0;
end;

procedure TpvConsole.KeyCutFromLineStartToCursor;
begin
 LinePositionClip;
 pvApplication.Clipboard.SetText(copy(fLine,1,fLinePosition-1));
 Delete(fLine,1,fLinePosition-1);
 fLinePosition:=1;
 fLineFirstPosition:=1;
 fHistoryIndex:=fHistory.Count;
 fCursorTimeAccumulator:=0.0;
end;

procedure TpvConsole.KeyPaste;
var s:TPUCURawByteString;
begin
 LinePositionClip;
 s:=pvApplication.Clipboard.GetText;
 Insert(s,fLine,fLinePosition);
 inc(fLinePosition,length(s));
 LinePositionClip;
 fHistoryIndex:=fHistory.Count;
 fCursorTimeAccumulator:=0.0;
end;

procedure TpvConsole.KeyClearScreen;
begin
 fLines.Clear;
 fCursorTimeAccumulator:=0.0;
end;

procedure TpvConsole.KeySwapCurrentCodePointWithPreviousCodePoint;
var i,PreviousCodeUnitLength,CurrentCodeUnitLength:TPUCUInt32;
    PreviousCodePoint{,CurrentCodePoint}:TPUCURawByteString;
begin
 if length(fLine)>0 then begin

  LinePositionClip;

  i:=length(fLine)+1;
  PUCUUTF8Dec(fLine,i);

  if fLinePosition>i then begin

   fLinePosition:=i;

   CurrentCodeUnitLength:=PUCUUTF8GetCharLen(fLine,fLinePosition);
   //CurrentCodePoint:=copy(fLine,fLinePosition,CurrentCodeUnitLength);

   i:=fLinePosition;
   PUCUUTF8Dec(fLine,i);
   PreviousCodeUnitLength:=PUCUUTF8GetCharLen(fLine,i);
   PreviousCodePoint:=copy(fLine,i,PreviousCodeUnitLength);

   Delete(fLine,i,PreviousCodeUnitLength);
   Insert(PreviousCodePoint,fLine,i+CurrentCodeUnitLength);

   fLinePosition:=length(fLine)+1;

   LinePositionClip;

   fHistoryIndex:=fHistory.Count;

  end else if (fLinePosition>1) and (fLinePosition<=length(fLine)) then begin

   CurrentCodeUnitLength:=PUCUUTF8GetCharLen(fLine,fLinePosition);
   //CurrentCodePoint:=copy(fLine,fLinePosition,CurrentCodeUnitLength);

   i:=fLinePosition;
   PUCUUTF8Dec(fLine,i);
   PreviousCodeUnitLength:=PUCUUTF8GetCharLen(fLine,i);
   PreviousCodePoint:=copy(fLine,i,PreviousCodeUnitLength);

   Delete(fLine,i,PreviousCodeUnitLength);
   Insert(PreviousCodePoint,fLine,i+CurrentCodeUnitLength);

   inc(i,CurrentCodeUnitLength);
   PUCUUTF8CodeUnitGetCharAndIncFallback(fLine,i);
   fLinePosition:=i;

   //LinePositionClip;

   fHistoryIndex:=fHistory.Count;

  end;

 end;

 fCursorTimeAccumulator:=0.0;

end;

procedure TpvConsole.KeyChar(const aCodePoint:TpvUInt32);
var s:TPUCURawByteString;
    CodeUnitLength:TpvSizeInt;
begin
 LinePositionClip;
 s:=PUCUUTF32CharToUTF8(aCodePoint);
 if Overwrite then begin
  if fLinePosition>length(fLine) then begin
   fLine:=fLine+s;
   fLinePosition:=length(fLine)+length(s);
  end else begin
   CodeUnitLength:=PUCUUTF8GetCharLen(fLine,fLinePosition);
   Delete(fLine,fLinePosition,CodeUnitLength);
   Insert(s,fLine,fLinePosition);
   inc(fLinePosition,length(s));
  end;
 end else begin
  if fLinePosition>length(fLine) then begin
   fLine:=fLine+s;
   fLinePosition:=length(fLine)+length(s);
  end else begin
   Insert(s,fLine,fLinePosition);
   inc(fLinePosition,length(s));
  end;
 end; 
 fHistoryIndex:=fHistory.Count;
 fCursorTimeAccumulator:=0.0;
end;

function TpvConsole.GetBuffer(const aColumn,aRow:TpvSizeInt;out aCodePoint:TpvUInt32;out aForegroundColor,aBackgroundColor:TpvSizeInt;out aBlink:Boolean):boolean;
var MemBufPos:TpvSizeInt;
    Val:TpvUInt32;
begin
 result:=(aRow>0) and (aRow<=fRows) and (aColumn>0) and (aColumn<=fColumns);
 if result then begin
  MemBufPos:=(((aRow-1)*fColumns)+aColumn-1) shl 1;
  aCodePoint:=fCurrentBuffer^[MemBufPos];
  Val:=fCurrentBuffer^[MemBufPos+1];
  aForegroundColor:=Val and $0f;
  aBackgroundColor:=(Val and $70) shr 4;
  aBlink:=(Val and $80)<>0;
 end else begin
  aCodePoint:=0;
  aForegroundColor:=7;
  aBackgroundColor:=0;
  aBlink:=false;
 end;
end;

procedure TpvConsole.Draw(const aDeltaTime:TpvDouble);
var Index,Row,Column,ForegroundColor,BackgroundColor:TpvSizeInt;
    CodePoint:TpvUInt32;
    Blink:boolean;
    StartColor,Color,OldColor:TpvVector4;
    StartColumn,CountColumns:TpvSizeInt;
begin

 fBlinkTimeAccumulator:=frac(fBlinkTimeAccumulator+(aDeltaTime*0.5));

 fCursorTimeAccumulator:=frac(fCursorTimeAccumulator+aDeltaTime);

 Index:=0;
 OldColor:=TpvVector4.Null;
 for Row:=0 to fRows-1 do begin
  StartColor:=TpvVector4.Null;
  StartColumn:=0;
  CountColumns:=0;
  for Column:=0 to fColumns-1 do begin
   GetBuffer(Column+1,Row+1,CodePoint,ForegroundColor,BackgroundColor,Blink);
   if fCursorOn and fOverwrite and ((not fCursorBlinkOn) or (fCursorTimeAccumulator<0.5)) and ((Column+1)=fCursor.CurPos.Column) and ((Row+1)=fCursor.CurPos.Row) then begin
    Color:=fColors^[ForegroundColor];
   end else begin
    Color:=fColors^[BackgroundColor];
   end;
   if (StartColor=Color) and (CountColumns>0) then begin
    inc(CountColumns);
   end else begin
    if (CountColumns>0) and (StartColor<>0) then begin
     if OldColor<>StartColor then begin
      OldColor:=StartColor;
      if assigned(fOnSetDrawColor) then begin
       fOnSetDrawColor(StartColor);
      end;
     end;
     if assigned(fOnDrawRect) then begin
      fOnDrawRect(StartColumn*fCharWidth,Row*fCharHeight,(StartColumn+CountColumns)*fCharWidth,(Row+1)*fCharHeight);
     end;
    end;
    StartColor:=Color;
    StartColumn:=Column;
    CountColumns:=1;
   end;
   inc(Index);
  end;
  if (CountColumns>0) and (StartColor<>0) then begin
   if OldColor<>StartColor then begin
    OldColor:=StartColor;
    if assigned(fOnSetDrawColor) then begin
     fOnSetDrawColor(StartColor);
    end;
   end;
   if assigned(fOnDrawRect) then begin
    fOnDrawRect(StartColumn*fCharWidth,Row*fCharHeight,(StartColumn+CountColumns)*fCharWidth,(Row+1)*fCharHeight);
   end;
  end;
 end;

 Index:=0;
 for Row:=0 to fRows-1 do begin
  for Column:=0 to fColumns-1 do begin
   if GetBuffer(Column+1,Row+1,CodePoint,ForegroundColor,BackgroundColor,Blink) and (CodePoint<>32) then begin
    if fCursorOn and fOverwrite and ((not fCursorBlinkOn) or (fCursorTimeAccumulator<0.5)) and ((Column+1)=fCursor.CurPos.Column) and ((Row+1)=fCursor.CurPos.Row) then begin
     Color:=fColors^[BackgroundColor];
    end else begin
     Color:=fColors^[ForegroundColor];
    end;
    if OldColor<>Color then begin
     OldColor:=Color;
     if assigned(fOnSetDrawColor) then begin
      fOnSetDrawColor(Color);
     end;
    end;
    if (not Blink) or (fBlinkTimeAccumulator<0.5) then begin
     if assigned(fOnDrawCodePoint) then begin
      fOnDrawCodePoint(CodePoint,Column*fCharWidth,Row*fCharHeight);
     end;
    end;
   end;
   inc(Index);
  end;
 end;

 if fCursorOn and (not fOverwrite) and ((not fCursorBlinkOn) or (fCursorTimeAccumulator<0.5)) then begin
  Column:=fCursor.CurPos.Column;
  Row:=fCursor.CurPos.Row;
  GetBuffer(Column,Row,CodePoint,ForegroundColor,BackgroundColor,Blink);
  if assigned(fOnSetDrawColor) then begin
   fOnSetDrawColor(fColors^[ForegroundColor]);
  end;
  if assigned(fOnDrawCodePoint) then begin
   fOnDrawCodePoint(ord('_'),(Column-1)*fCharWidth,(Row-1)*fCharHeight);
  end;
 end;

end;

function TpvConsole.KeyEvent(const aKeyEvent:TpvApplicationInputKeyEvent):boolean;
begin
 result:=false;
 case aKeyEvent.KeyEventType of
  TpvApplicationInputKeyEventType.Typed:begin
   case aKeyEvent.KeyCode of
    KEYCODE_UP:begin
     KeyUp;
     UpdateScreen;
     result:=true;
    end;
    KEYCODE_DOWN:begin
     KeyDown;
     UpdateScreen;
     result:=true;
    end;
    KEYCODE_LEFT:begin
     KeyLeft;
     UpdateScreen;
     result:=true;
    end;
    KEYCODE_RIGHT:begin
     KeyRight;
     UpdateScreen;
     result:=true;
    end;
    KEYCODE_HOME:begin
     KeyHome;
     UpdateScreen;
     result:=true;
    end;
    KEYCODE_END:begin
     KeyEnd;
     UpdateScreen;
     result:=true;
    end;
    KEYCODE_RETURN:begin
     KeyEnter;
     UpdateScreen;
     result:=true;
    end;
    KEYCODE_ESCAPE:begin
     KeyEscape;
     UpdateScreen;
     result:=true;
    end;
    KEYCODE_INSERT:begin
     KeyInsert;
     UpdateScreen;
     result:=true;
    end;
    KEYCODE_DELETE:begin
     KeyDelete;
     UpdateScreen;
     result:=true;
    end;
    KEYCODE_BACKSPACE:begin
     KeyBackspace;
     UpdateScreen;
     result:=true;
    end;
    KEYCODE_A:begin
     if TpvApplicationInputKeyModifier.CTRL in aKeyEvent.KeyModifiers then begin
      KeyHome;
      UpdateScreen;
      result:=true;
     end;
    end;
    KEYCODE_E:begin
     if TpvApplicationInputKeyModifier.CTRL in aKeyEvent.KeyModifiers then begin
      KeyEnd;
      UpdateScreen;
      result:=true;
     end;
    end;
    KEYCODE_B:begin
     if TpvApplicationInputKeyModifier.CTRL in aKeyEvent.KeyModifiers then begin
      KeyLeft;
      UpdateScreen;
      result:=true;
     end;
    end;
    KEYCODE_F:begin
     if TpvApplicationInputKeyModifier.CTRL in aKeyEvent.KeyModifiers then begin
      KeyRight;
      UpdateScreen;
      result:=true;
     end;
    end;
    KEYCODE_P:begin
     if TpvApplicationInputKeyModifier.CTRL in aKeyEvent.KeyModifiers then begin
      KeyUp;
      UpdateScreen;
      result:=true;
     end;
    end;
    KEYCODE_N:begin
     if TpvApplicationInputKeyModifier.CTRL in aKeyEvent.KeyModifiers then begin
      KeyDown;
      UpdateScreen;
      result:=true;
     end;
    end;
    KEYCODE_H:begin
     if TpvApplicationInputKeyModifier.CTRL in aKeyEvent.KeyModifiers then begin
      KeyBackspace;
      UpdateScreen;
      result:=true;
     end;
    end;
    KEYCODE_D:begin
     if TpvApplicationInputKeyModifier.CTRL in aKeyEvent.KeyModifiers then begin
      KeyDelete;
      UpdateScreen;
      result:=true;
     end;
    end;
    KEYCODE_W:begin
     if TpvApplicationInputKeyModifier.CTRL in aKeyEvent.KeyModifiers then begin
      KeyDeletePreviousWord;
      UpdateScreen;
      result:=true;
     end;
    end;
    KEYCODE_L:begin
     if TpvApplicationInputKeyModifier.CTRL in aKeyEvent.KeyModifiers then begin
      KeyClearScreen;
      UpdateScreen;
      result:=true;
     end;
    end;
    KEYCODE_K:begin
     if TpvApplicationInputKeyModifier.CTRL in aKeyEvent.KeyModifiers then begin
      KeyCutFromCurrentToEndOfLine;
      UpdateScreen;
      result:=true;
     end;
    end;
    KEYCODE_U:begin
     if TpvApplicationInputKeyModifier.CTRL in aKeyEvent.KeyModifiers then begin
      KeyCutFromLineStartToCursor;
      UpdateScreen;
      result:=true;
     end;
    end;
    KEYCODE_Y:begin
     if TpvApplicationInputKeyModifier.CTRL in aKeyEvent.KeyModifiers then begin
      KeyPaste;
      UpdateScreen;
      result:=true;
     end;
    end;
    KEYCODE_T:begin
     if TpvApplicationInputKeyModifier.CTRL in aKeyEvent.KeyModifiers then begin
      KeySwapCurrentCodePointWithPreviousCodePoint;
      UpdateScreen;
      result:=true;
     end;
    end;
    else begin
//   KeyChar(aKeyEvent.KeyCode);
    end;
   end;
  end;
  TpvApplicationInputKeyEventType.Unicode:begin
   if (TpvApplicationInputKeyModifier.CTRL in aKeyEvent.KeyModifiers) and
      (((aKeyEvent.KeyCode>=ord('a')) or (aKeyEvent.KeyCode<=ord('z'))) or
       ((aKeyEvent.KeyCode>=ord('A')) or (aKeyEvent.KeyCode<=ord('Z'))) or
       (aKeyEvent.KeyCode=ord('@'))) then begin
   end else begin
    KeyChar(aKeyEvent.KeyCode);
   end;
   UpdateScreen;
   result:=true;
  end;
  else begin
  end;
 end;
end;

procedure TpvConsole.LoadHistoryFromStream(const aStream:TStream);
var i,l:TPUCUInt32;
    StringList:TStringList;
    s:TpvUTF8String;
begin
 StringList:=TStringList.Create;
 try
  StringList.LoadFromStream(aStream);
  l:=StringList.Count;
  fHistory.Clear;
  for i:=0 to l-1 do begin
   s:=StringList[i];
   s:=StringReplace(s,#127,#10,[rfReplaceAll]);
   fHistory.Add(s);
  end;
  fHistoryIndex:=fHistory.Count;
 finally
  FreeAndNil(StringList);
 end;
end;

procedure TpvConsole.LoadHistoryFromFileName(const aFileName:String);
var MemoryStream:TMemoryStream;
begin
 MemoryStream:=TMemoryStream.Create;
 try
  MemoryStream.LoadFromFile(aFileName);
  MemoryStream.Seek(0,soBeginning);
  LoadHistoryFromStream(MemoryStream);
 finally
  FreeAndNil(MemoryStream);
 end;
end; 

procedure TpvConsole.SaveHistoryToStream(const aStream:TStream);
var i,l:TPUCUInt32;
    s:TpvUTF8String;
    StringList:TStringList;
begin
 StringList:=TStringList.Create;
 try
  l:=fHistory.Count;
  for i:=0 to l-1 do begin
   s:=History.Items[i];
   s:=StringReplace(s,#13#10,#10,[rfReplaceAll]);
   s:=StringReplace(s,#13,#10,[rfReplaceAll]);
   s:=StringReplace(s,#10,#127,[rfReplaceAll]);
   StringList.Add(s);
  end;
  StringList.SaveToStream(aStream);
 finally
  FreeAndNil(StringList);
 end;
end;

procedure TpvConsole.SaveHistoryToFileName(const aFileName:String);
var MemoryStream:TMemoryStream;
begin
 MemoryStream:=TMemoryStream.Create;
 try
  SaveHistoryToStream(MemoryStream);
  MemoryStream.Seek(0,soBeginning);
  MemoryStream.SaveToFile(aFileName);
 finally
  FreeAndNil(MemoryStream);
 end;
end;

procedure TpvConsole.AppendToHistoryFileName(const aFileName:String;const aLine:TpvUTF8String);
var HistoryFile:File;
    Size:TpvInt64;
    s:TpvUTF8String;
begin
 AssignFile(HistoryFile,aFileName);
 if FileExists(aFileName) then begin
  {$i-}Reset(HistoryFile,1);{$i+}
  if IOResult<>0 then begin
   CloseFile(HistoryFile);
   exit;
  end;
  Size:=FileSize(HistoryFile);
  Seek(HistoryFile,Size);
 end else begin
  {$i-}Rewrite(HistoryFile,1);{$i+}
  if IOResult<>0 then begin
   CloseFile(HistoryFile);
   exit;
  end;
 end;
 s:=StringReplace(aLine,#13#10,#10,[rfReplaceAll]);
 s:=StringReplace(s,#13,#10,[rfReplaceAll]);
 s:=StringReplace(s,#10,#127,[rfReplaceAll]);
 s:=aLine+{$ifdef Windows}#13#10{$else}#10{$endif};
 BlockWrite(HistoryFile,s[1],length(s));
 CloseFile(HistoryFile);
end;

end.
