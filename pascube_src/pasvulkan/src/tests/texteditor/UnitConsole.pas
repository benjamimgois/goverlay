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
 unit UnitConsole;
{$ifdef fpc}
 {$mode delphi}
{$else}
 {$legacyifend on}
{$endif}
{$if defined(Win32) or defined(Win64)}
 {$define Windows}
{$ifend}
{$scopedenums on}
{$m+}

interface

uses {$ifdef Windows}Windows,{$endif}SysUtils,Classes,Math,PUCU;

type PConsoleBufferItem=^TConsoleBufferItem;
     TConsoleBufferItem=record
      case boolean of
       false:(
        Video:Int8;
        Dummy:UInt8;
        BackgroundColor:UInt8;
        ForegroundColor:UInt8;
        CodePoint:UInt32;
       );
       true:(
        Value:UInt64;
       );
     end;

     TConsoleBufferItems=array of TConsoleBufferItem;

     TConsole=class
      public
       type TColor=class
             public
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
            end;
            TCursorState=
             (
              Off,
              On,
              Big
             );
{$ifdef Windows}
      private
       type TInputRecord={$ifdef fpc}Windows.TINPUTRECORD{$else}Windows.TInputRecord{$endif};
            //PInputRecord=^TInputRecord;
            TInputRecords=array of TInputRecord;
            TKey=record
             public
              VirtualCode:Int32;
              Normal:Int32;
              Shift:Int32;
              Ctrl:Int32;
              Alt:Int32;
              IgnoreWhenInternational:boolean;
            end;
            PKey=^TKey;
            TKeys=array[0..93] of TKey;
       const NullKey:TKey=
              (
               VirtualCode:$0000;
               Normal:$0000;
               Shift:$0000;
               Ctrl:$0000;
               Alt:$0000;
               IgnoreWhenInternational:true;
              );
             Keys:TKeys=
              (
               // Must be virtual-code-sorted for the binary-search
               (VirtualCode:$0008{VK_BACK};Normal:$0008;Shift:$0008;Ctrl:$007f;Alt:$010e;IgnoreWhenInternational:false),
               (VirtualCode:$0009{VK_TAB};Normal:$0009;Shift:$010f;Ctrl:$0194;Alt:$01a5;IgnoreWhenInternational:false),
               (VirtualCode:$000d{VK_RETURN};Normal:$000d;Shift:$000d;Ctrl:$000a;Alt:$01a6;IgnoreWhenInternational:false),
               (VirtualCode:$001b{VK_ESCAPE};Normal:$001b;Shift:$001b;Ctrl:$001b;Alt:$0101;IgnoreWhenInternational:false),
               (VirtualCode:$0020{VK_SPACE};Normal:$0020;Shift:$0020;Ctrl:$0103;Alt:$0020;IgnoreWhenInternational:false),
               (VirtualCode:$0021{VK_PRIOR};Normal:$0149;Shift:$0149;Ctrl:$018f;Alt:$0199;IgnoreWhenInternational:false),
               (VirtualCode:$0022{VK_NEXT};Normal:$0151;Shift:$0151;Ctrl:$0176;Alt:$01a1;IgnoreWhenInternational:false),
               (VirtualCode:$0023{VK_END};Normal:$014f;Shift:$014f;Ctrl:$0175;Alt:$019f;IgnoreWhenInternational:false),
               (VirtualCode:$0024{VK_HOME};Normal:$0147;Shift:$0147;Ctrl:$0177;Alt:$0197;IgnoreWhenInternational:false),
               (VirtualCode:$0025{VK_LEFT};Normal:$014b;Shift:$014b;Ctrl:$0173;Alt:$019b;IgnoreWhenInternational:false),
               (VirtualCode:$0026{VK_UP};Normal:$0148;Shift:$0148;Ctrl:$018d;Alt:$0198;IgnoreWhenInternational:false),
               (VirtualCode:$0027{VK_RIGHT};Normal:$014d;Shift:$014d;Ctrl:$0174;Alt:$019d;IgnoreWhenInternational:false),
               (VirtualCode:$0028{VK_DOWN};Normal:$0150;Shift:$0150;Ctrl:$0191;Alt:$01a0;IgnoreWhenInternational:false),
               (VirtualCode:$002d{VK_INSERT};Normal:$0152;Shift:$0152;Ctrl:$0192;Alt:$01a2;IgnoreWhenInternational:false),
               (VirtualCode:$002e{VK_DELETE};Normal:$0153;Shift:$0153;Ctrl:$0193;Alt:$01a3;IgnoreWhenInternational:false),
               (VirtualCode:$0030{0};Normal:$0030;Shift:$0029;Ctrl:$ffff;Alt:$0181;IgnoreWhenInternational:true),
               (VirtualCode:$0031{1};Normal:$0031;Shift:$0021;Ctrl:$ffff;Alt:$0178;IgnoreWhenInternational:true),
               (VirtualCode:$0032{2};Normal:$0032;Shift:$0040;Ctrl:$0103;Alt:$0179;IgnoreWhenInternational:true),
               (VirtualCode:$0033{3};Normal:$0033;Shift:$0023;Ctrl:$ffff;Alt:$017a;IgnoreWhenInternational:true),
               (VirtualCode:$0034{4};Normal:$0034;Shift:$0024;Ctrl:$ffff;Alt:$017b;IgnoreWhenInternational:true),
               (VirtualCode:$0035{5};Normal:$0035;Shift:$0025;Ctrl:$ffff;Alt:$017c;IgnoreWhenInternational:true),
               (VirtualCode:$0036{6};Normal:$0036;Shift:$005e;Ctrl:$001e;Alt:$017d;IgnoreWhenInternational:true),
               (VirtualCode:$0037{7};Normal:$0037;Shift:$0026;Ctrl:$ffff;Alt:$017e;IgnoreWhenInternational:true),
               (VirtualCode:$0038{8};Normal:$0038;Shift:$002a;Ctrl:$ffff;Alt:$017f;IgnoreWhenInternational:true),
               (VirtualCode:$0039{9};Normal:$0039;Shift:$0028;Ctrl:$ffff;Alt:$0180;IgnoreWhenInternational:true),
               (VirtualCode:$0041{A};Normal:$0061;Shift:$0041;Ctrl:$0001;Alt:$011e;IgnoreWhenInternational:true),
               (VirtualCode:$0042{B};Normal:$0062;Shift:$0042;Ctrl:$0002;Alt:$0130;IgnoreWhenInternational:true),
               (VirtualCode:$0043{C};Normal:$0063;Shift:$0043;Ctrl:$0003;Alt:$012e;IgnoreWhenInternational:true),
               (VirtualCode:$0044{D};Normal:$0064;Shift:$0044;Ctrl:$0004;Alt:$0120;IgnoreWhenInternational:true),
               (VirtualCode:$0045{E};Normal:$0065;Shift:$0045;Ctrl:$0005;Alt:$0112;IgnoreWhenInternational:true),
               (VirtualCode:$0046{F};Normal:$0066;Shift:$0046;Ctrl:$0006;Alt:$0121;IgnoreWhenInternational:true),
               (VirtualCode:$0047{G};Normal:$0067;Shift:$0047;Ctrl:$0007;Alt:$0122;IgnoreWhenInternational:true),
               (VirtualCode:$0048{H};Normal:$0068;Shift:$0048;Ctrl:$0008;Alt:$0123;IgnoreWhenInternational:true),
               (VirtualCode:$0049{I};Normal:$0069;Shift:$0049;Ctrl:$0009;Alt:$0117;IgnoreWhenInternational:true),
               (VirtualCode:$004a{J};Normal:$006a;Shift:$004a;Ctrl:$000a;Alt:$0124;IgnoreWhenInternational:true),
               (VirtualCode:$004b{K};Normal:$006b;Shift:$004b;Ctrl:$000b;Alt:$0125;IgnoreWhenInternational:true),
               (VirtualCode:$004c{L};Normal:$006c;Shift:$004c;Ctrl:$000c;Alt:$0126;IgnoreWhenInternational:true),
               (VirtualCode:$004d{M};Normal:$006d;Shift:$004d;Ctrl:$000d;Alt:$0132;IgnoreWhenInternational:true),
               (VirtualCode:$004e{N};Normal:$006e;Shift:$004e;Ctrl:$000e;Alt:$0131;IgnoreWhenInternational:true),
               (VirtualCode:$004f{O};Normal:$006f;Shift:$004f;Ctrl:$000f;Alt:$0118;IgnoreWhenInternational:true),
               (VirtualCode:$0050{P};Normal:$0070;Shift:$0050;Ctrl:$0010;Alt:$0119;IgnoreWhenInternational:true),
               (VirtualCode:$0051{Q};Normal:$0071;Shift:$0051;Ctrl:$0011;Alt:$0110;IgnoreWhenInternational:true),
               (VirtualCode:$0052{R};Normal:$0072;Shift:$0052;Ctrl:$0012;Alt:$0113;IgnoreWhenInternational:true),
               (VirtualCode:$0053{S};Normal:$0073;Shift:$0053;Ctrl:$0013;Alt:$011f;IgnoreWhenInternational:true),
               (VirtualCode:$0054{T};Normal:$0074;Shift:$0054;Ctrl:$0014;Alt:$0114;IgnoreWhenInternational:true),
               (VirtualCode:$0055{U};Normal:$0075;Shift:$0055;Ctrl:$0015;Alt:$0116;IgnoreWhenInternational:true),
               (VirtualCode:$0056{V};Normal:$0076;Shift:$0056;Ctrl:$0016;Alt:$012f;IgnoreWhenInternational:true),
               (VirtualCode:$0057{W};Normal:$0077;Shift:$0057;Ctrl:$0017;Alt:$0111;IgnoreWhenInternational:true),
               (VirtualCode:$0058{X};Normal:$0078;Shift:$0058;Ctrl:$0018;Alt:$012d;IgnoreWhenInternational:true),
               (VirtualCode:$0059{Y};Normal:$0079;Shift:$0059;Ctrl:$0019;Alt:$0115;IgnoreWhenInternational:true),
               (VirtualCode:$005a{Z};Normal:$007a;Shift:$005a;Ctrl:$001a;Alt:$012c;IgnoreWhenInternational:true),
               (VirtualCode:$005b{VK_LWIN};Normal:$ffff;Shift:$ffff;Ctrl:$ffff;Alt:$ffff;IgnoreWhenInternational:false),
               (VirtualCode:$005c{VK_RWIN};Normal:$ffff;Shift:$ffff;Ctrl:$ffff;Alt:$ffff;IgnoreWhenInternational:false),
               (VirtualCode:$005d{VK_APPS};Normal:$ffff;Shift:$ffff;Ctrl:$ffff;Alt:$ffff;IgnoreWhenInternational:false),
               (VirtualCode:$0060{VK_NUMPAD0};Normal:$0030;Shift:$0152;Ctrl:$0192;Alt:$ffff;IgnoreWhenInternational:false),
               (VirtualCode:$0061{VK_NUMPAD1};Normal:$0031;Shift:$014f;Ctrl:$0175;Alt:$ffff;IgnoreWhenInternational:false),
               (VirtualCode:$0062{VK_NUMPAD2};Normal:$0032;Shift:$0150;Ctrl:$0191;Alt:$ffff;IgnoreWhenInternational:false),
               (VirtualCode:$0063{VK_NUMPAD3};Normal:$0033;Shift:$0151;Ctrl:$0176;Alt:$ffff;IgnoreWhenInternational:false),
               (VirtualCode:$0064{VK_NUMPAD4};Normal:$0034;Shift:$014b;Ctrl:$0173;Alt:$ffff;IgnoreWhenInternational:false),
               (VirtualCode:$0065{VK_NUMPAD5};Normal:$0035;Shift:$014c;Ctrl:$018f;Alt:$ffff;IgnoreWhenInternational:false),
               (VirtualCode:$0066{VK_NUMPAD6};Normal:$0036;Shift:$014d;Ctrl:$0174;Alt:$ffff;IgnoreWhenInternational:false),
               (VirtualCode:$0067{VK_NUMPAD7};Normal:$0037;Shift:$0147;Ctrl:$0177;Alt:$ffff;IgnoreWhenInternational:false),
               (VirtualCode:$0068{VK_NUMPAD8};Normal:$0038;Shift:$0148;Ctrl:$018d;Alt:$ffff;IgnoreWhenInternational:false),
               (VirtualCode:$0069{VK_NUMPAD9};Normal:$0039;Shift:$0149;Ctrl:$0184;Alt:$ffff;IgnoreWhenInternational:false),
               (VirtualCode:$006a{VK_MULTIPLY};Normal:$002a;Shift:$002a;Ctrl:$0196;Alt:$0137;IgnoreWhenInternational:false),
               (VirtualCode:$006b{VK_ADD};Normal:$002b;Shift:$002b;Ctrl:$0190;Alt:$014e;IgnoreWhenInternational:false),
               (VirtualCode:$006d{VK_SUBTRACT};Normal:$002d;Shift:$002d;Ctrl:$018e;Alt:$014a;IgnoreWhenInternational:false),
               (VirtualCode:$006e{VK_DECIMAL};Normal:$002e;Shift:$002e;Ctrl:$0153;Alt:$0193;IgnoreWhenInternational:false),
               (VirtualCode:$006f{VK_DIVIDE};Normal:$002f;Shift:$002f;Ctrl:$0195;Alt:$01a4;IgnoreWhenInternational:false),
               (VirtualCode:$0070{VK_F1};Normal:$013b;Shift:$0154;Ctrl:$015e;Alt:$0168;IgnoreWhenInternational:false),
               (VirtualCode:$0071{VK_F2};Normal:$013c;Shift:$0155;Ctrl:$015f;Alt:$0169;IgnoreWhenInternational:false),
               (VirtualCode:$0072{VK_F3};Normal:$013d;Shift:$0156;Ctrl:$0160;Alt:$016a;IgnoreWhenInternational:false),
               (VirtualCode:$0073{VK_F4};Normal:$013e;Shift:$0157;Ctrl:$0161;Alt:$016b;IgnoreWhenInternational:false),
               (VirtualCode:$0074{VK_F5};Normal:$013f;Shift:$0158;Ctrl:$0162;Alt:$016c;IgnoreWhenInternational:false),
               (VirtualCode:$0075{VK_F6};Normal:$0140;Shift:$0159;Ctrl:$0163;Alt:$016d;IgnoreWhenInternational:false),
               (VirtualCode:$0076{VK_F7};Normal:$0141;Shift:$015a;Ctrl:$0164;Alt:$016e;IgnoreWhenInternational:false),
               (VirtualCode:$0077{VK_F8};Normal:$0142;Shift:$015b;Ctrl:$0165;Alt:$016f;IgnoreWhenInternational:false),
               (VirtualCode:$0078{VK_F9};Normal:$0143;Shift:$015c;Ctrl:$0166;Alt:$0170;IgnoreWhenInternational:false),
               (VirtualCode:$0079{VK_F10};Normal:$0144;Shift:$015d;Ctrl:$0167;Alt:$0171;IgnoreWhenInternational:false),
               (VirtualCode:$007a{VK_F11};Normal:$0185;Shift:$0187;Ctrl:$0189;Alt:$018b;IgnoreWhenInternational:false),
               (VirtualCode:$007b{VK_F12};Normal:$0186;Shift:$0188;Ctrl:$018a;Alt:$018c;IgnoreWhenInternational:false),
               (VirtualCode:$00ba{VK_OEM_1};Normal:$003b;Shift:$003a;Ctrl:$ffff;Alt:$0127;IgnoreWhenInternational:true),
               (VirtualCode:$00bb{VK_OEM_PLUS};Normal:$003d;Shift:$002b;Ctrl:$ffff;Alt:$0183;IgnoreWhenInternational:true),
               (VirtualCode:$00bc{VK_OEM_COMMA};Normal:$002c;Shift:$003c;Ctrl:$ffff;Alt:$0133;IgnoreWhenInternational:true),
               (VirtualCode:$00bd{VK_OEM_MINUS};Normal:$002d;Shift:$005f;Ctrl:$001f;Alt:$0182;IgnoreWhenInternational:true),
               (VirtualCode:$00be{VK_OEM_PERIOD};Normal:$002e;Shift:$003e;Ctrl:$ffff;Alt:$0134;IgnoreWhenInternational:true),
               (VirtualCode:$00bf{VK_OEM_2};Normal:$002f;Shift:$003f;Ctrl:$ffff;Alt:$0135;IgnoreWhenInternational:true),
               (VirtualCode:$00c0{VK_OEM_3};Normal:$0060;Shift:$007e;Ctrl:$ffff;Alt:$0129;IgnoreWhenInternational:true),
               (VirtualCode:$00db{VK_OEM_4};Normal:$005b;Shift:$007b;Ctrl:$001b;Alt:$011a;IgnoreWhenInternational:true),
               (VirtualCode:$00dc{VK_OEM_5};Normal:$005c;Shift:$007c;Ctrl:$001c;Alt:$012b;IgnoreWhenInternational:true),
               (VirtualCode:$00dd{VK_OEM_6};Normal:$005d;Shift:$007d;Ctrl:$001d;Alt:$011b;IgnoreWhenInternational:true),
               (VirtualCode:$00de{VK_OEM_7};Normal:$0027;Shift:$0022;Ctrl:$ffff;Alt:$0128;IgnoreWhenInternational:true),
               (VirtualCode:$00df{VK_OEM_8};Normal:$ffff;Shift:$ffff;Ctrl:$ffff;Alt:$ffff;IgnoreWhenInternational:true),
               (VirtualCode:$00e2{VK_OEM_102};Normal:$ffff;Shift:$ffff;Ctrl:$ffff;Alt:$ffff;IgnoreWhenInternational:true)
              );
{$endif}
      private
       fWidth:Int32;
       fHeight:Int32;
       fDirty:boolean;
       fBuffer:TConsoleBufferItems;
       fLastBuffer:TConsoleBufferItems;
       fCursorX:Int32;
       fCursorY:Int32;
       fLastCursorX:Int32;
       fLastCursorY:Int32;
       fVideo:Int8;
       fBackgroundColor:UInt8;
       fForegroundColor:UInt8;
       fScrollLock:boolean;
       fCursorState:TCursorState;
       fLastCursorState:TCursorState;
{$ifdef Windows}
       fConsoleInputHandle:Windows.THANDLE;
       fConsoleOutputHandle:Windows.THANDLE;
       fConsoleBuffer:array of CHAR_INFO;
       fConsoleInfo:TConsoleScreenBufferinfo;
       fCursorInfo:TConsoleCursorInfo;
       fConsoleExtendedChar:Int32;
       fOldConsoleMode:DWORD;
       function LookupKey(const aVirtualCode:Int32):PKey;
       function TranslateKey(const aInput:TInputRecord;const aKey:PKey):Int32;
{$endif}
       procedure SetWidth(const aWidth:Int32);
       procedure SetHeight(const aHeight:Int32);
       procedure UpdateBufferSize;
       procedure CheckCursorXY;
      public
       constructor Create; reintroduce;
       destructor Destroy; override;
       procedure ClrScr;
       procedure InsLine;
       procedure DelLine;
       procedure ClrEOL;
       procedure GotoXY(const aX,aY:Int32);
       procedure HighVideo;
       procedure LowVideo;
       procedure NormVideo;
       procedure TextBackground(const aBackgroundColor:UInt8);
       procedure TextColor(const aForegroundColor:UInt8);
       procedure WriteCodePointToBuffer(const aX,aY:Int32;const aCodePoint:UInt32);
       procedure WriteCodePoint(const aCodePoint:UInt32);
       procedure Write(const aString:TPUCUUTF8String);
       procedure WriteLn(const aString:TPUCUUTF8String);
       procedure CursorOff;
       procedure CursorOn;
       procedure CursorBig;
       procedure Flush;
       function KeyPressed:boolean;
       function ReadKey:Int32;
      published
       property Width:Int32 read fWidth write SetWidth;
       property Height:Int32 read fHeight write SetHeight;
       property BackgroundColor:UInt8 read fBackgroundColor write fBackgroundColor;
       property ForegroundColor:UInt8 read fForegroundColor write fForegroundColor;
       property WhereX:Int32 read fCursorX;
       property WhereY:Int32 read fCursorY;
       property ScrollLock:boolean read fScrollLock write fScrollLock;
       property CursorState:TCursorState read fCursorState write fCursorState;
     end;

var Console:TConsole=nil;

implementation

{$ifndef Windows}
uses CRT;
{$endif}

constructor TConsole.Create;
{$ifdef Windows}
var Coords:TCoord;
{$endif}
begin
 inherited Create;
{$ifdef Windows}
 SetConsoleCP(CP_UTF8);
 SetConsoleOutputCP(CP_UTF8);
 fConsoleInputHandle:=GetStdHandle(STD_INPUT_HANDLE);
 fConsoleOutputHandle:=GetStdHandle(STD_OUTPUT_HANDLE);
 fConsoleBuffer:=nil;
 if GetConsoleScreenBufferInfo(fConsoleOutputHandle,fConsoleInfo) then begin
  fWidth:=(fConsoleInfo.srWindow.Right-fConsoleInfo.srWindow.Left)+1;
  fHeight:=(fConsoleInfo.srWindow.Bottom-fConsoleInfo.srWindow.Top)+1;
 end else begin
  fWidth:=80;
  fHeight:=25;
 end;
 Coords.x:=fWidth;
 Coords.y:=fHeight;
 SetConsoleScreenBufferSize(fConsoleOutputHandle,Coords);
 GetConsoleCursorInfo(fConsoleOutputHandle,fCursorInfo);
 fConsoleExtendedChar:=-1;
 GetConsoleMode(fConsoleInputHandle,fOldConsoleMode);
 SetConsoleMode(fConsoleInputHandle,(ENABLE_WINDOW_INPUT or
                                     ENABLE_MOUSE_INPUT) and not
                                    (ENABLE_PROCESSED_INPUT or
                                     ENABLE_WRAP_AT_EOL_OUTPUT));
{$else}
 fWidth:=(CRT.WindMaxX-CRT.WindMinX)+1;
 fHeight:=(CRT.WindMaxY-CRT.WindMinY)+1;
{$endif}
 fBuffer:=nil;
 fLastBuffer:=nil;
 UpdateBufferSize;
 ClrScr;
 fDirty:=false;
 fScrollLock:=true;
 fVideo:=0;
 fBackgroundColor:=TColor.Black;
 fForegroundColor:=TColor.LightGray;
 fLastCursorX:=-1;
 fLastCursorY:=-1;
 GotoXY(1,1);
end;

destructor TConsole.Destroy;
begin
 fBuffer:=nil;
 fLastBuffer:=nil;
{$ifdef Windows}
 fConsoleBuffer:=nil;
 SetConsoleMode(fConsoleInputHandle,fOldConsoleMode);
{$endif}
 inherited Destroy;
end;

procedure TConsole.SetWidth(const aWidth:Int32);
begin
 if fWidth<>aWidth then begin
  fWidth:=aWidth;
  UpdateBufferSize;
  fDirty:=true;
 end;
end;

procedure TConsole.SetHeight(const aHeight:Int32);
begin
 if fHeight<>aHeight then begin
  fHeight:=aHeight;
  UpdateBufferSize;
  fDirty:=true;
 end;
end;

procedure TConsole.UpdateBufferSize;
var x,y:Int32;
    BufferItem:PConsoleBufferItem;
begin
 SetLength(fBuffer,fWidth*fHeight);
 SetLength(fLastBuffer,fWidth*fHeight);
{$ifdef Windows}
 SetLength(fConsoleBuffer,fWidth*fHeight);
{$endif}
 BufferItem:=@fLastBuffer[0];
 for y:=0 to fHeight-1 do begin
  for x:=0 to fWidth-1 do begin
   BufferItem^.Video:=$7f;
   BufferItem^.BackgroundColor:=$ff;
   BufferItem^.ForegroundColor:=$ff;
   BufferItem^.CodePoint:=$ffffffff;
   inc(BufferItem);
  end;
 end;
end;

procedure TConsole.ClrScr;
var x,y:Int32;
    BufferItem:PConsoleBufferItem;
begin
 BufferItem:=@fBuffer[0];
 for y:=0 to fHeight-1 do begin
  for x:=0 to fWidth-1 do begin
   BufferItem^.Video:=fVideo;
   BufferItem^.BackgroundColor:=fBackgroundColor;
   BufferItem^.ForegroundColor:=fForegroundColor;
   BufferItem^.CodePoint:=32;
   inc(BufferItem);
  end;
 end;
end;

procedure TConsole.GotoXY(const aX,aY:Int32);
begin
 fCursorX:=Min(Max(aX,1),fWidth);
 fCursorY:=Min(Max(aY,1),fHeight);
end;

procedure TConsole.HighVideo;
begin
 fVideo:=1;
end;

procedure TConsole.LowVideo;
begin
 fVideo:=-1;
end;

procedure TConsole.NormVideo;
begin
 fVideo:=0;
end;

procedure TConsole.TextBackground(const aBackgroundColor:UInt8);
begin
 fBackgroundColor:=aBackgroundColor;
end;

procedure TConsole.TextColor(const aForegroundColor:UInt8);
begin
 fForegroundColor:=aForegroundColor;
end;

procedure TConsole.InsLine;
var Index:Int32;
begin
 for Index:=1 to Min(Max(fCursorY,0),fHeight)-1 do begin
  Move(fBuffer[Index*fWidth],fBuffer[(Index-1)*fWidth],fWidth*SizeOf(TConsoleBufferItem));
 end;
 ClrEOL;
end;

procedure TConsole.DelLine;
var Index,x,y:Int32;
    BufferItem:PConsoleBufferItem;
begin
 for Index:=Min(Max(fCursorY,0),fHeight)-1 to fHeight-1 do begin
  Move(fBuffer[Index*fWidth],fBuffer[(Index-1)*fWidth],fWidth*SizeOf(TConsoleBufferItem));
 end;
 y:=fHeight-1;
 BufferItem:=@fBuffer[y*fWidth];
 for x:=0 to fWidth-1 do begin
  BufferItem^.Video:=fVideo;
  BufferItem^.BackgroundColor:=fBackgroundColor;
  BufferItem^.ForegroundColor:=fForegroundColor;
  BufferItem^.CodePoint:=32;
  inc(BufferItem);
 end;
end;

procedure TConsole.ClrEOL;
var x,y:Int32;
    BufferItem:PConsoleBufferItem;
begin
 if ((fCursorX>0) and (fCursorX<=fWidth)) and
    ((fCursorY>0) and (fCursorY<=fHeight)) then begin
  y:=fCursorY-1;
  BufferItem:=@fBuffer[y*fWidth];
  for x:=0 to fWidth-1 do begin
   BufferItem^.Video:=fVideo;
   BufferItem^.BackgroundColor:=fBackgroundColor;
   BufferItem^.ForegroundColor:=fForegroundColor;
   BufferItem^.CodePoint:=32;
   inc(BufferItem);
  end;
 end;
end;

procedure TConsole.CheckCursorXY;
begin
 if fCursorX>fWidth then begin
  fCursorX:=1;
  inc(fCursorY);
 end;
 if fCursorY>fHeight then begin
  if fScrollLock then begin
   fCursorX:=1;
   fCursorY:=1;
  end else begin
   if fCursorY>fHeight then begin
    fCursorY:=fHeight;
   end;
   InsLine;
   fCursorX:=1;
   fCursorY:=fHeight;
  end;
 end;
end;

procedure TConsole.WriteCodePointToBuffer(const aX,aY:Int32;const aCodePoint:UInt32);
var BufferItem:PConsoleBufferItem;
begin
 if ((aX>0) and (aX<=fWidth)) and
    ((aY>0) and (aY<=fHeight)) then begin
  BufferItem:=@fBuffer[((aY-1)*fWidth)+(aX-1)];
  BufferItem^.Video:=fVideo;
  BufferItem^.BackgroundColor:=fBackgroundColor;
  BufferItem^.ForegroundColor:=fForegroundColor;
  BufferItem^.CodePoint:=aCodePoint;
 end;
end;

procedure TConsole.WriteCodePoint(const aCodePoint:UInt32);
var Index:Int32;
    BufferItem:PConsoleBufferItem;
begin
 case aCodePoint of
  0:begin
  end;
  7:begin
   //inc(PiepCount,11025);
  end;
  8:begin
   fCursorX:=Max(1,fCursorX-1);
  end;
  9:begin
   for Index:=1 to (((fCursorX+8) and not 7)-fCursorX)+1 do begin
    if ((fCursorX>0) and (fCursorX<=fWidth)) and
       ((fCursorY>0) and (fCursorY<=fHeight)) then begin
     BufferItem:=@fBuffer[((fCursorY-1)*fWidth)+(fCursorX-1)];
     BufferItem^.Video:=fVideo;
     BufferItem^.BackgroundColor:=fBackgroundColor;
     BufferItem^.ForegroundColor:=fForegroundColor;
     BufferItem^.CodePoint:=32;
    end;
    inc(fCursorX);
    CheckCursorXY;
   end;
  end;
  10:begin
   inc(fCursorY);
   CheckCursorXY;
  end;
  12:begin
   ClrScr;
  end;
  13:begin
   fCursorX:=1;
  end;
  255:begin
  end;
  else begin
   if ((fCursorX>0) and (fCursorX<=fWidth)) and
      ((fCursorY>0) and (fCursorY<=fHeight)) then begin
    BufferItem:=@fBuffer[((fCursorY-1)*fWidth)+(fCursorX-1)];
    BufferItem^.Video:=fVideo;
    BufferItem^.BackgroundColor:=fBackgroundColor;
    BufferItem^.ForegroundColor:=fForegroundColor;
    BufferItem^.CodePoint:=aCodePoint;
   end;
   inc(fCursorX);
   CheckCursorXY;
  end;
 end;
end;

procedure TConsole.Write(const aString:TPUCUUTF8String);
var Index,Len:Int32;
begin
 Index:=1;
 Len:=Length(aString);
 while Index<=Len do begin
  WriteCodePoint(PUCUUTF8CodeUnitGetCharAndIncFallback(aString,Index));
 end;
end;

procedure TConsole.WriteLn(const aString:TPUCUUTF8String);
begin
 Write(aString+#13#10);
end;

procedure TConsole.CursorOff;
begin
 fCursorState:=TConsole.TCursorState.Off;
end;

procedure TConsole.CursorOn;
begin
 fCursorState:=TConsole.TCursorState.On;
end;

procedure TConsole.CursorBig;
begin
 fCursorState:=TConsole.TCursorState.Big;
end;

procedure TConsole.Flush;
{$ifdef Windows}
var x,y:Int32;
    BufferItem,LastBufferItem:PConsoleBufferItem;
    CharBufSize,CharacterPos,CurInfo:Windows.TCOORD;
    WriteArea:{$ifdef fpc}Windows.TSMALL_RECT{$else}Windows.TSmallRect{$endif};
    p:{$ifdef fpc}Windows.PCHAR_INFO{$else}Windows.PCharInfo{$endif};
    HasChanges:boolean;
    CursorInfo:TConsoleCursorInfo;
begin
 HasChanges:=(fLastCursorX<>fCursorX) or (fLastCursorY<>fCursorY) or (fLastCursorState<>fCursorState);
 fLastCursorX:=fCursorX;
 fLastCursorY:=fCursorY;
 fLastCursorState:=fCursorState;
 BufferItem:=@fBuffer[0];
 LastBufferItem:=@fLastBuffer[0];
 p:=@fConsoleBuffer[0];
 for y:=1 to fHeight do begin
  for x:=1 to fWidth do begin
   if LastBufferItem^.Value<>BufferItem^.Value then begin
    LastBufferItem^.Value:=BufferItem^.Value;
    HasChanges:=true;
   end;
   p^.Attributes:=(BufferItem^.BackgroundColor shl 4) or BufferItem.ForegroundColor;
   case BufferItem^.Video of
    -1:begin
     p^.Attributes:=p^.Attributes and $77;
    end;
    1:begin
     p^.Attributes:=p^.Attributes or $08;
    end;
   end;
   p^.UnicodeChar:=WideChar(UInt16(BufferItem^.CodePoint));
   inc(LastBufferItem);
   inc(BufferItem);
   inc(p);
  end;
 end;
 if HasChanges then begin
  CharBufSize.x:=fWidth;
  CharBufSize.y:=fHeight;
  CharacterPos.x:=0;
  CharacterPos.y:=0;
  WriteArea.Left:=0;
  WriteArea.Top:=0;
  WriteArea.Right:=fWidth-1;
  WriteArea.Bottom:=fHeight-1;
  WriteConsoleOutputW(fConsoleOutputHandle,@fConsoleBuffer[0],CharBufSize,CharacterPos,WriteArea);
  GetConsoleCursorInfo(fConsoleOutputHandle,CursorInfo);
  case fCursorState of
   TConsole.TCursorState.Off:begin
    CursorInfo.bVisible:=false;
   end;
   TConsole.TCursorState.On:begin
    CursorInfo.dwSize:=fCursorInfo.dwSize;
    CursorInfo.bVisible:=true;
   end;
   TConsole.TCursorState.Big:begin
    CursorInfo.dwSize:=93;
    CursorInfo.bVisible:=true;
   end;
  end;
  CurInfo.X:=fCursorX-1;
  CurInfo.Y:=fCursorY-1;
  SetConsoleCursorPosition(fConsoleOutputHandle,CurInfo);
  SetConsoleCursorInfo(fConsoleOutputHandle,CursorInfo);
 end;
end;
{$else}
var x,y,LastBackgroundColor,LastForegroundColor,LastX,LastY,LastVideo:Int32;
    BufferItem,LastBufferItem:PConsoleBufferItem;
    HasChanges:boolean;
    StringBuffer:string;
 procedure FlushProcessedBuffer;
 begin
  if length(StringBuffer)>0 then begin
   CRT.GotoXY(LastX,LastY);
   System.Write(StringBuffer);
   StringBuffer:='';
  end;
 end;
begin
 HasChanges:=(fLastCursorX<>fCursorX) or (fLastCursorY<>fCursorY) or (fLastCursorState<>fCursorState);
 fLastCursorX:=fCursorX;
 fLastCursorY:=fCursorY;
 fLastCursorState:=fCursorState;
 BufferItem:=@fBuffer[0];
 LastBufferItem:=@fLastBuffer[0];
 for y:=1 to fHeight do begin
  for x:=1 to fWidth do begin
   if (x=fWidth) and (y=fHeight) then begin
    break;
   end;
   if LastBufferItem^.Value<>BufferItem^.Value then begin
    HasChanges:=true;
   end;
   inc(BufferItem);
   inc(LastBufferItem);
  end;
 end;
 if not HasChanges then begin
  exit;
 end;
 BufferItem:=@fBuffer[0];
 LastBufferItem:=@fLastBuffer[0];
 LastVideo:=$7f;
 LastBackgroundColor:=-1;
 LastForegroundColor:=-1;
 LastX:=1;
 LastY:=1;
 CRT.cursoroff;
 BufferItem:=@fBuffer[0];
 LastBufferItem:=@fLastBuffer[0];
 StringBuffer:='';
 for y:=1 to fHeight do begin
  for x:=1 to fWidth do begin
   if (x=fWidth) and (y=fHeight) then begin
    break;
   end;
   if LastBufferItem^.Value<>BufferItem^.Value then begin
    LastBufferItem^.Value:=BufferItem^.Value;
    if LastVideo<>BufferItem^.Video then begin
     LastVideo:=BufferItem^.Video;
     case BufferItem^.Video of
      -1:begin
       CRT.LowVideo;
      end;
      1:begin
       CRT.HighVideo;
      end;
      else begin
       CRT.NormVideo;
      end;
     end;
    end;
    if LastBackgroundColor<>BufferItem^.BackgroundColor then begin
     FlushProcessedBuffer;
     LastBackgroundColor:=BufferItem^.BackgroundColor;
     CRT.TextBackground(LastBackgroundColor);
    end;
    if LastForegroundColor<>BufferItem^.ForegroundColor then begin
     FlushProcessedBuffer;
     LastForegroundColor:=BufferItem^.ForegroundColor;
     CRT.TextColor(LastForegroundColor);
    end;
    if length(StringBuffer)=0 then begin
     LastX:=x;
     LastY:=y;
    end;
    if BufferItem^.CodePoint<128 then begin
     StringBuffer:=StringBuffer+Chr(BufferItem^.CodePoint);
    end else begin
     StringBuffer:=StringBuffer+PUCUUTF32CharToUTF8(BufferItem^.CodePoint);
    end;
   end else begin
    FlushProcessedBuffer;
   end;
   inc(BufferItem);
   inc(LastBufferItem);
  end;
 end;
 FlushProcessedBuffer;
 CRT.GotoXY(fCursorX,fCursorY);
 case fCursorState of
  TConsole.TCursorState.Off:begin
   CRT.cursoroff;
  end;
  TConsole.TCursorState.On:begin
   CRT.cursoron;
  end;
  TConsole.TCursorState.Big:begin
   CRT.cursorbig;
  end;
 end;
end;
{$endif}

{$ifdef Windows}
function TConsole.LookupKey(const aVirtualCode:Int32):PKey;
var MinIndex,MaxIndex,MidIndex:Int32;
begin
 result:=nil;
 MinIndex:=Low(TKeys);
 MaxIndex:=High(TKeys);
 while MinIndex<=MaxIndex do begin
  MidIndex:=MinIndex+((MaxIndex-MinIndex) shr 1);
  if Keys[MidIndex].VirtualCode=aVirtualCode then begin
   result:=@Keys[MidIndex];
   if result^.IgnoreWhenInternational then begin
    result:=@NullKey;
   end;
   break;
  end else if Keys[MidIndex].VirtualCode<aVirtualCode then begin
   MinIndex:=MidIndex+1;
  end else begin
   MaxIndex:=MidIndex-1;
  end;
 end;
end;

function TConsole.TranslateKey(const aInput:TInputRecord;const aKey:PKey):Int32;
begin
 if (aInput.Event.KeyEvent.dwControlKeyState and (RIGHT_ALT_PRESSED or LEFT_ALT_PRESSED))<>0 then begin
  result:=aKey^.Alt;
 end else if (aInput.Event.KeyEvent.dwControlKeyState and (RIGHT_CTRL_PRESSED or LEFT_CTRL_PRESSED))<>0 then begin
  result:=aKey^.Ctrl;
 end else if (aInput.Event.KeyEvent.dwControlKeyState and SHIFT_PRESSED)<>0 then begin
  result:=aKey^.Shift;
 end else begin
  case aInput.Event.KeyEvent.wVirtualKeyCode of
   ord('A')..ord('Z'):begin
    result:=ord(aInput.Event.KeyEvent.AsciiChar);
   end;
   else begin
    result:=aKey^.Normal;
   end;
  end;
 end;
end;

function TConsole.KeyPressed:boolean;
var Index,VirtualKeyCode:Int32;
    CountRead,CountEvents:UInt32;
    Input:TInputRecords;
    Key:PKey;
begin
 result:=fConsoleExtendedChar>=0;
 if not result then begin
  GetNumberOfConsoleInputEvents(fConsoleInputHandle,CountEvents);
  if CountEvents>0 then begin
   SetLength(Input,CountEvents);
   try
    PeekConsoleInput(fConsoleInputHandle,Input[0],CountEvents,CountRead);
    for Index:=0 to CountRead-1 do begin
     case Input[Index].EventType of
      WINDOW_BUFFER_SIZE_EVENT:begin
       result:=true;
       exit;
      end;
      KEY_EVENT:begin
       if Input[Index].Event.KeyEvent.bKeyDown then begin
        VirtualKeyCode:=Input[Index].Event.KeyEvent.wVirtualKeyCode;
        case VirtualKeyCode of
         VK_SHIFT,VK_CONTROL,VK_MENU:begin
          // Ignore
         end;
         else begin
          Key:=LookupKey(VirtualKeyCode);
          if assigned(Key) and (TranslateKey(Input[Index],Key)<>$ffff) then begin
           result:=true;
           exit;
          end;
         end;
        end;
       end;
      end;
     end;
    end;
    ReadConsoleInputW(fConsoleInputHandle,Input[0],CountRead,CountRead);
   finally
    Input:=nil;
   end;
  end;
 end;
end;

function TConsole.ReadKey:Int32;
var Code:Int32;
    Input:TInputRecord;
    CountRead:UInt32;
    Key:PKey;
    Coords:TCoord;
begin
 if fConsoleExtendedChar>=0 then begin
  result:=fConsoleExtendedChar;
  fConsoleExtendedChar:=-1;
 end else begin
  repeat
   if ReadConsoleInputW(fConsoleInputHandle,Input,1,CountRead) then begin
    case Input.EventType of
     WINDOW_BUFFER_SIZE_EVENT:begin
      if GetConsoleScreenBufferInfo(fConsoleOutputHandle,fConsoleInfo) then begin
       if (fWidth<>(fConsoleInfo.srWindow.Right-fConsoleInfo.srWindow.Left)+1) or
          (fHeight<>(fConsoleInfo.srWindow.Bottom-fConsoleInfo.srWindow.Top)+1) then begin
        fWidth:=(fConsoleInfo.srWindow.Right-fConsoleInfo.srWindow.Left)+1;
        fHeight:=(fConsoleInfo.srWindow.Bottom-fConsoleInfo.srWindow.Top)+1;
        UpdateBufferSize;
        fDirty:=true;
        Coords.x:=fWidth;
        Coords.y:=fHeight;
        SetConsoleScreenBufferSize(fConsoleOutputHandle,Coords);
        result:=0;
        fConsoleExtendedChar:=$fffe;
        break;
       end;
      end;
     end;
     KEY_EVENT:begin
      if Input.Event.KeyEvent.bKeyDown then begin
       Key:=LookupKey(Input.Event.KeyEvent.wVirtualKeyCode);
       if assigned(Key) then begin
        Code:=TranslateKey(Input,Key);
        if Code<>$ffff then begin
         if Code>=$100 then begin
          fConsoleExtendedChar:=Code-$100;
          result:=0;
          break;
         end;
         if Code=0 then begin
          if Input.Event.KeyEvent.UnicodeChar<>#0 then begin
           result:=ord(Input.Event.KeyEvent.UnicodeChar);
          end else if Input.Event.KeyEvent.AsciiChar<>#0 then begin
           result:=ord(Input.Event.KeyEvent.AsciiChar);
          end else begin
           result:=Code;
          end;
         end else begin
          result:=Code;
         end;
         break;
        end;
       end;
      end;
     end;
    end;
   end else begin
    result:=-1;
    break;
   end;
  until false;
 end;
end;

{$else}
function TConsole.KeyPressed:boolean;
begin
 result:=CRT.KeyPressed;
end;

function TConsole.ReadKey:Int32;
begin
 result:=ord(CRT.ReadKey);
end;
{$endif}

initialization
 Console:=TConsole.Create;
finalization
 Console.Free;
end.

