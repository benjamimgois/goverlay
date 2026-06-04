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
unit UnitMain;
{$ifdef fpc}
 {$mode delphi}
{$else}
 {$legacyifend on}
{$endif}
{$if defined(Win32) or defined(Win64)}
 {$define Windows}
{$ifend}
{$scopedenums on}

interface

uses SysUtils,Classes,PasVulkan.Types,PasVulkan.TextEditor,UnitConsole;

var AbstractTextEditor:TpvTextEditor=nil;
    AbstractTextEditorView:TpvTextEditor.TView;
    OverwriteMode:boolean=false;

procedure Main;

implementation

var FileName:TpvUTF8String;

function RepChar(const aChar:Char;const aCount:Int32):string;
var Index:Int32;
begin
 SetLength(result,aCount);
 for Index:=1 to aCount do begin
  result[Index]:=aChar;
 end;
end;

procedure DisplayKeys;
 procedure AddFKey(const aFKeyNr:byte;const aName:string);
 begin
  Console.TextBackground(TConsole.TColor.Black);
  Console.TextColor(TConsole.TColor.LightGray);
  Console.Write(UTF8String(IntToStr(aFKeyNr)));
  Console.TextBackground(TConsole.TColor.Cyan);
  Console.TextColor(TConsole.TColor.Black);
  Console.Write(UTF8String(aName));
  Console.TextBackground(TConsole.TColor.Black);
  Console.TextColor(TConsole.TColor.LightGray);
  Console.Write(UTF8String(' '));
 end;
begin
 Console.GotoXY(1,Console.Height);
 AddFKey(1,'Help');
 AddFKey(2,'Save');
 AddFKey(3,'Find');
 AddFKey(4,'Repl');
 AddFKey(5,'Refr');
 if AbstractTextEditorView.LineWrap=0 then begin
  AddFKey(6,'Wrap');
 end else begin
  AddFKey(6,'UnWr');
 end;
 AddFKey(7,'InsL');
 AddFKey(8,'DelL');
 AddFKey(9,'Load');
 AddFKey(10,'Quit');
 AddFKey(11,'Mark');
 AddFKey(12,'    ');
 while Console.WhereX<Console.Width do begin
  Console.Write(' ');
 end;
 Console.Write(' ');
end;

procedure ClearEditScreen;
var Index:Int32;
begin
 Console.TextBackground(TConsole.TColor.Blue);
 Console.TextColor(TConsole.TColor.LightGray);
 for Index:=2 to Console.Height-1 do begin
  Console.GotoXY(1,Index);
  Console.Write(UTF8String(RepChar(#32,Console.Width)));
 end;
 Console.TextBackground(TConsole.TColor.Black);
 Console.TextColor(TConsole.TColor.LightGray);
end;

procedure ResetScreen;
begin

 Console.TextBackground(TConsole.TColor.Blue);
 Console.TextColor(TConsole.TColor.LightGray);
 Console.ClrScr;
 Console.TextBackground(TConsole.TColor.Black);
 Console.TextColor(TConsole.TColor.LightGray);

 Console.CursorOff;

 Console.TextBackground(TConsole.TColor.Cyan);
 Console.TextColor(TConsole.TColor.Black);
 Console.GotoXY(1,1);
 Console.Write(UTF8String(RepChar(#32,Console.Width)));

 Console.GotoXY(2,1);
 Console.Write(FileName);

 Console.GotoXY(Console.Width-6,1);
 Console.Write('[');
 Console.Write('-');
 Console.Write('-');
 Console.Write('-');
 if OverwriteMode then begin
  Console.Write('O');
 end else begin
  Console.Write('-');
 end;
 Console.Write(']');

 DisplayKeys;

 Console.TextBackground(TConsole.TColor.Black);
 Console.TextColor(TConsole.TColor.LightGray);

end;

procedure UpdateScreen;
var x,y,i:Int32;
    BufferItem:TpvTextEditor.TView.PBufferItem;
begin

 ResetScreen;

 AbstractTextEditorView.VisibleAreaWidth:=Console.Width;
 AbstractTextEditorView.VisibleAreaHeight:=Console.Height-2;
 AbstractTextEditorView.NonScrollVisibleAreaWidth:=Console.Width;
 AbstractTextEditorView.NonScrollVisibleAreaHeight:=Console.Height-2;

 AbstractTextEditorView.UpdateBuffer;

 Console.TextBackground(TConsole.TColor.Cyan);
 Console.TextColor(TConsole.TColor.Black);
 Console.GotoXY(Console.Width-40,1);
 Console.Write(UTF8String('Line: '+IntToStr(AbstractTextEditorView.LineColumn.Line)));
 Console.GotoXY(Console.Width-25,1);
 Console.Write(UTF8String('Column: '+IntToStr(AbstractTextEditorView.LineColumn.Column)));

 Console.GotoXY(1,2);

 Console.TextBackground(TConsole.TColor.Blue);
 Console.TextColor(TConsole.TColor.LightGray);
//Console.TextColor(TConsole.TColor.LightCyan);

 i:=0;
 for y:=0 to AbstractTextEditorView.VisibleAreaHeight-1 do begin
  for x:=0 to AbstractTextEditorView.VisibleAreaWidth-1 do begin
   if i<length(AbstractTextEditorView.Buffer) then begin
    BufferItem:=@AbstractTextEditorView.Buffer[i];
    if (BufferItem^.Attribute and TpvTextEditor.TSyntaxHighlighting.TAttributes.Highlight)<>0 then begin
//   Console.HighVideo;
     Console.TextBackground(TConsole.TColor.LightBlue);
    end else begin
//   Console.NormVideo;
     Console.TextBackground(TConsole.TColor.Blue);
    end;
    case BufferItem^.Attribute and TpvTextEditor.TSyntaxHighlighting.TAttributes.Mask of
     TpvTextEditor.TSyntaxHighlighting.TAttributes.String_:begin
      Console.TextColor(TConsole.TColor.LightCyan);
     end;
     TpvTextEditor.TSyntaxHighlighting.TAttributes.Operator:begin
      Console.TextColor(TConsole.TColor.LightGreen);
     end;
     TpvTextEditor.TSyntaxHighlighting.TAttributes.Delimiter:begin
      Console.TextColor(TConsole.TColor.LightGreen);
     end;
     TpvTextEditor.TSyntaxHighlighting.TAttributes.Symbol:begin
      Console.TextColor(TConsole.TColor.LightGreen);
     end;
     TpvTextEditor.TSyntaxHighlighting.TAttributes.Number:begin
      Console.TextColor(TConsole.TColor.LightMagenta);
     end;
     TpvTextEditor.TSyntaxHighlighting.TAttributes.Identifier:begin
      Console.TextColor(TConsole.TColor.Yellow);
     end;
     TpvTextEditor.TSyntaxHighlighting.TAttributes.Keyword:begin
      Console.TextColor(TConsole.TColor.White);
     end;
     TpvTextEditor.TSyntaxHighlighting.TAttributes.Comment:begin
      Console.TextColor(TConsole.TColor.LightGray);
     end;
     TpvTextEditor.TSyntaxHighlighting.TAttributes.Preprocessor:begin
      Console.TextColor(TConsole.TColor.LightRed);
     end;
     else begin
      Console.TextColor(TConsole.TColor.DarkGray);
     end;
    end;
    Console.WriteCodePointToBuffer(x+1,y+2,BufferItem^.CodePoint);
   end;
   inc(i);
  end;
 end;

 Console.GotoXY(AbstractTextEditorView.Cursor.x+1,AbstractTextEditorView.Cursor.y+2);

 if OverwriteMode then begin
  Console.CursorBig;
 end else begin
  Console.CursorOn;
 end;

 Console.Flush;

end;

procedure Main;
var c:Int32;
    RegularExpression:TpvTextEditor.TRegularExpression;
    p,l:TpvSizeInt;
    FileExtension:TpvUTF8String;
begin

 AbstractTextEditor:=TpvTextEditor.Create;
 try

  AbstractTextEditorView:=AbstractTextEditor.CreateView;

  if ParamCount>0 then begin
   FileName:=ParamStr(1);
   FileExtension:=TpvUTF8String(ExtractFileExt(FileName));
   try
    AbstractTextEditor.LoadFromFile(ParamStr(1));
   except
   end;
  end else begin
   FileName:='noname.txt';
   FileExtension:='.txt';
  end;

  AbstractTextEditor.SyntaxHighlighting:=TpvTextEditor.TSyntaxHighlighting.GetSyntaxHighlightingClassByFileExtension(FileExtension).Create(AbstractTextEditor);

  //AbstractTextEditor.Text:='//0123 3.14159e+0 $1337c0de if then { bla }';
//AbstractTextEditor.Text:='''//0123 3.14159e+0 $1337c0de if then { bla }'#13#10'bla';
//AbstractTextEditor.Text:='#ifdef test'#13#10'#define bla(x) \'#13#10' if(x){\'#13#10' }'#13#10'void main(){'#13#10'}'#13#10'#endif';

  repeat

   UpdateScreen;

   if {Console.KeyPressed}true then begin
    c:=Console.ReadKey;
    case c of
     0:begin
      // Code escape
      if Console.KeyPressed then begin
       c:=Console.ReadKey;
       case c of
        82:begin
         // Insert
         OverwriteMode:=not OverwriteMode;
        end;
        83:begin
         // Delete
         AbstractTextEditorView.Delete;
        end;
        71:begin
         // Home
         AbstractTextEditorView.MoveToLineBegin;
        end;
        79:begin
         // End
         AbstractTextEditorView.MoveToLineEnd;
        end;
        73:begin
         // Page up
         AbstractTextEditorView.MovePageUp;
        end;
        81:begin
         // Page down
         AbstractTextEditorView.MovePageDown;
        end;
        72:begin
         // Up
         AbstractTextEditorView.MoveUp;
        end;
        80:begin
         // Down
         AbstractTextEditorView.MoveDown;
        end;
        75:begin
         // Left
         AbstractTextEditorView.MoveLeft;
        end;
        77:begin
         // Right
         AbstractTextEditorView.MoveRight;
        end;
        60:begin
         // F2
         AbstractTextEditor.SaveToFile(ParamStr(1));
        end;
        61:begin
         // F3
         RegularExpression:=TpvTextEditor.TRegularExpression.Create(AbstractTextEditor,'\$[0-9]+',[]);
         try
          if RegularExpression.FindNext(p,l,AbstractTextEditorView.CodePointIndex+1) then begin
           AbstractTextEditorView.CodePointIndex:=p;
          end;
         finally
          RegularExpression.Free;
         end;
        end;
        64:begin
         // F6
         if AbstractTextEditorView.LineWrap=0 then begin
          AbstractTextEditorView.LineWrap:=AbstractTextEditorView.NonScrollVisibleAreaWidth;
         end else begin
          AbstractTextEditorView.LineWrap:=0;
         end;
        end;
        65:begin
         // F7
         AbstractTextEditorView.InsertLine;
        end;
        66:begin
         // F8
         AbstractTextEditorView.DeleteLine;
        end;
        68:begin
         // F10
         break;
        end;
        $fffe:begin
         // Resize
         if AbstractTextEditorView.LineWrap<>0 then begin
          AbstractTextEditorView.LineWrap:=Console.Width;
          AbstractTextEditorView.EnsureCursorIsVisible(true);
         end;
        end;
       end;
      end;
     end;
     3:begin
      // CTRL-C
     end;
     8:begin
      // Backspace
      AbstractTextEditorView.Backspace;
     end;
     13:begin
      AbstractTextEditorView.Enter(OverwriteMode);
     end;
     17:begin
      // Ctrl-Q
      break;
     end;
     25:begin
      // Ctrl-Y
      AbstractTextEditor.Redo(AbstractTextEditorView);
     end;
     26:begin
      // Ctrl-Z
      AbstractTextEditor.Undo(AbstractTextEditorView);
     end;
     27:begin
      // Escape
     end;
     else begin
      AbstractTextEditorView.InsertCodePoint(c,OverwriteMode);
     end;
    end;
{  end else begin
    Sleep(10);}
   end;

  until false;

 finally
  AbstractTextEditor.Free;
 end;

 Console.TextBackground(TConsole.TColor.Black);
 Console.TextColor(TConsole.TColor.LightGray);
 Console.ClrScr;
 Console.GotoXY(1,1);
 Console.Flush;

end;

end.
