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
unit PasVulkan.Application;
{$i PasVulkan.inc}
{$ifdef fpc}
 {$if defined(FPC_VERSION) and (FPC_VERSION>=3)}
  {$define HAS_NAMETHREADFORDEBUGGING}
 {$ifend}
{$else}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=24.0}
   {$legacyifend on}
  {$ifend}
  {$if CompilerVersion>=31.0}
   {$define HAS_NAMETHREADFORDEBUGGING}
  {$ifend}
 {$endif}
{$endif}
{$ifdef fpc}
 {$packenum 4}
{$endif}

interface

uses {$if defined(Unix)}
      BaseUnix,
      Unix,
      UnixType,
      {$ifdef linux}
       linux,
      {$endif}
      ctypes,
     {$elseif defined(Windows)}
      Windows,
      {$ifdef fpc}jwawinbase,{$endif}
      {$if not (defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless))}Messages,{$ifend}
      MMSystem,
      Registry,
      {$if not (defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless))}MultiMon,ShellAPI,PasVulkan.Win32.GameInput,{$ifend}
     {$ifend}
     {$if defined(PasVulkanUseJCLDebug) and not defined(fpc)}
      JclDebug,
     {$ifend}
     SysUtils,
     {$ifndef fpc}
     DateUtils,
     IOUtils,
     {$endif}
     Classes,
     SyncObjs,
     Math,
     PasMP,
     PUCU,
     Vulkan,
     PasVulkan.Types,
     PasVulkan.Profiler,
     PasVulkan.Math,
     PasVulkan.Framework,
{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
     PasVulkan.SDL2,
{$ifend}
     PasVulkan.HighResolutionTimer,
     PasVulkan.Android,
     PasVulkan.Audio,
     PasVulkan.Resources,
     PasVulkan.Collections,
     PasVulkan.NVIDIA.AfterMath;

const MaxSwapChainImages=3;

      MaxInFlightFrames=3;

      FrameTimesHistorySize=1 shl 10;
      FrameTimesHistoryMask=FrameTimesHistorySize-1;

      FramePacingHistorySize=16;
      FramePacingHistoryMask=FramePacingHistorySize-1;

      LOG_NONE=0;
      LOG_ERROR=1;
      LOG_INFO=2;
      LOG_VERBOSE=3;
      LOG_DEBUG=4;

      EVENT_NONE=0;
      EVENT_KEY=1;
      EVENT_POINTER=2;
      EVENT_SCROLLED=3;
      EVENT_DRAGDROPFILE=4;

      KEYCODE_QUIT=-2;
      KEYCODE_ANYKEY=-1;
      KEYCODE_UNKNOWN=0;
      KEYCODE_FIRST=0;
      KEYCODE_BACKSPACE=8;
      KEYCODE_TAB=9;
      KEYCODE_RETURN=13;
      KEYCODE_PAUSE=19;
      KEYCODE_ESCAPE=27;
      KEYCODE_SPACE=32;
      KEYCODE_EXCLAIM=33;
      KEYCODE_QUOTEDBL=34;
      KEYCODE_HASH=35;
      KEYCODE_DOLLAR=36;
      KEYCODE_AMPERSAND=38;
      KEYCODE_APOSTROPHE=39;
      KEYCODE_LEFTPAREN=40;
      KEYCODE_RIGHTPAREN=41;
      KEYCODE_ASTERISK=42;
      KEYCODE_PLUS=43;
      KEYCODE_COMMA=44;
      KEYCODE_MINUS=45;
      KEYCODE_PERIOD=46;
      KEYCODE_SLASH=47;
      KEYCODE_0=48;
      KEYCODE_1=49;
      KEYCODE_2=50;
      KEYCODE_3=51;
      KEYCODE_4=52;
      KEYCODE_5=53;
      KEYCODE_6=54;
      KEYCODE_7=55;
      KEYCODE_8=56;
      KEYCODE_9=57;
      KEYCODE_COLON=58;
      KEYCODE_SEMICOLON=59;
      KEYCODE_LESS=60;
      KEYCODE_EQUALS=61;
      KEYCODE_GREATER=62;
      KEYCODE_QUESTION=63;
      KEYCODE_AT=64;
      KEYCODE_LEFTBRACKET=91;
      KEYCODE_BACKSLASH=92;
      KEYCODE_RIGHTBRACKET=93;
      KEYCODE_CARET=94;
      KEYCODE_UNDERSCORE=95;
      KEYCODE_BACKQUOTE=96;
      KEYCODE_A=97;
      KEYCODE_B=98;
      KEYCODE_C=99;
      KEYCODE_D=100;
      KEYCODE_E=101;
      KEYCODE_F=102;
      KEYCODE_G=103;
      KEYCODE_H=104;
      KEYCODE_I=105;
      KEYCODE_J=106;
      KEYCODE_K=107;
      KEYCODE_L=108;
      KEYCODE_M=109;
      KEYCODE_N=110;
      KEYCODE_O=111;
      KEYCODE_P=112;
      KEYCODE_Q=113;
      KEYCODE_R=114;
      KEYCODE_S=115;
      KEYCODE_T=116;
      KEYCODE_U=117;
      KEYCODE_V=118;
      KEYCODE_W=119;
      KEYCODE_X=120;
      KEYCODE_Y=121;
      KEYCODE_Z=122;
      KEYCODE_LEFTBRACE=123;
      KEYCODE_PIPE=124;
      KEYCODE_RIGHTBRACE=125;
      KEYCODE_TILDE=126;
      KEYCODE_DELETE=177;
      KEYCODE_F1=256;
      KEYCODE_F2=257;
      KEYCODE_F3=258;
      KEYCODE_F4=259;
      KEYCODE_F5=260;
      KEYCODE_F6=261;
      KEYCODE_F7=262;
      KEYCODE_F8=263;
      KEYCODE_F9=264;
      KEYCODE_F10=265;
      KEYCODE_F11=266;
      KEYCODE_F12=267;
      KEYCODE_F13=268;
      KEYCODE_F14=269;
      KEYCODE_F15=270;
      KEYCODE_F16=271;
      KEYCODE_F17=272;
      KEYCODE_F18=273;
      KEYCODE_F19=274;
      KEYCODE_F20=275;
      KEYCODE_F21=276;
      KEYCODE_F22=277;
      KEYCODE_F23=278;
      KEYCODE_F24=279;
      KEYCODE_KP0=280;
      KEYCODE_KP1=281;
      KEYCODE_KP2=282;
      KEYCODE_KP3=283;
      KEYCODE_KP4=284;
      KEYCODE_KP5=285;
      KEYCODE_KP6=286;
      KEYCODE_KP7=287;
      KEYCODE_KP8=288;
      KEYCODE_KP9=289;
      KEYCODE_KP_PERIOD=290;
      KEYCODE_KP_DIVIDE=291;
      KEYCODE_KP_MULTIPLY=292;
      KEYCODE_KP_MINUS=293;
      KEYCODE_KP_PLUS=294;
      KEYCODE_KP_ENTER=295;
      KEYCODE_KP_EQUALS=296;
      KEYCODE_UP=297;
      KEYCODE_DOWN=298;
      KEYCODE_RIGHT=299;
      KEYCODE_LEFT=300;
      KEYCODE_INSERT=301;
      KEYCODE_HOME=302;
      KEYCODE_END=303;
      KEYCODE_PAGEUP=304;
      KEYCODE_PAGEDOWN=305;
      KEYCODE_CAPSLOCK=306;
      KEYCODE_NUMLOCK=307;
      KEYCODE_SCROLLLOCK=308;
      KEYCODE_RSHIFT=309;
      KEYCODE_LSHIFT=310;
      KEYCODE_RCTRL=311;
      KEYCODE_LCTRL=312;
      KEYCODE_RALT=313;
      KEYCODE_LALT=314;
      KEYCODE_MODE=315;
      KEYCODE_HELP=316;
      KEYCODE_PRINTSCREEN=317;
      KEYCODE_SYSREQ=318;
      KEYCODE_MENU=319;
      KEYCODE_POWER=320;
      KEYCODE_APPLICATION=321;
      KEYCODE_SELECT=322;
      KEYCODE_STOP=323;
      KEYCODE_AGAIN=324;
      KEYCODE_UNDO=325;
      KEYCODE_CUT=326;
      KEYCODE_COPY=327;
      KEYCODE_PASTE=328;
      KEYCODE_FIND=329;
      KEYCODE_MUTE=330;
      KEYCODE_VOLUMEUP=331;
      KEYCODE_VOLUMEDOWN=332;
      KEYCODE_KP_EQUALSAS400=333;
      KEYCODE_ALTERASE=334;
      KEYCODE_CANCEL=335;
      KEYCODE_CLEAR=336;
      KEYCODE_PRIOR=337;
      KEYCODE_RETURN2=338;
      KEYCODE_SEPARATOR=339;
      KEYCODE_OUT=340;
      KEYCODE_OPER=341;
      KEYCODE_CLEARAGAIN=342;
      KEYCODE_CRSEL=343;
      KEYCODE_EXSEL=344;
      KEYCODE_KP_00=345;
      KEYCODE_KP_000=346;
      KEYCODE_THOUSANDSSEPARATOR=34;
      KEYCODE_DECIMALSEPARATOR=348;
      KEYCODE_CURRENCYUNIT=349;
      KEYCODE_CURRENCYSUBUNIT=350;
      KEYCODE_KP_LEFTPAREN=351;
      KEYCODE_KP_RIGHTPAREN=352;
      KEYCODE_KP_LEFTBRACE=353;
      KEYCODE_KP_RIGHTBRACE=354;
      KEYCODE_KP_TAB=355;
      KEYCODE_KP_BACKSPACE=356;
      KEYCODE_KP_A=357;
      KEYCODE_KP_B=358;
      KEYCODE_KP_C=359;
      KEYCODE_KP_D=360;
      KEYCODE_KP_E=361;
      KEYCODE_KP_F=362;
      KEYCODE_KP_XOR=363;
      KEYCODE_KP_POWER=364;
      KEYCODE_KP_PERCENT=365;
      KEYCODE_KP_LESS=366;
      KEYCODE_KP_GREATER=368;
      KEYCODE_KP_AMPERSAND=369;
      KEYCODE_KP_DBLAMPERSAND=370;
      KEYCODE_KP_VERTICALBAR=371;
      KEYCODE_KP_DBLVERTICALBAR=372;
      KEYCODE_KP_COLON=373;
      KEYCODE_KP_COMMA=375;
      KEYCODE_KP_HASH=376;
      KEYCODE_KP_SPACE=377;
      KEYCODE_KP_AT=378;
      KEYCODE_KP_EXCLAM=379;
      KEYCODE_KP_MEMSTORE=380;
      KEYCODE_KP_MEMRECALL=381;
      KEYCODE_KP_MEMCLEAR=382;
      KEYCODE_KP_MEMADD=383;
      KEYCODE_KP_MEMSUBTRACT=384;
      KEYCODE_KP_MEMMULTIPLY=385;
      KEYCODE_KP_MEMDIVIDE=386;
      KEYCODE_KP_PLUSMINUS=387;
      KEYCODE_KP_CLEAR=388;
      KEYCODE_KP_CLEARENTRY=389;
      KEYCODE_KP_BINARY=390;
      KEYCODE_KP_OCTAL=391;
      KEYCODE_KP_DECIMAL=392;
      KEYCODE_KP_HEXADECIMAL=393;
      KEYCODE_LGUI=394;
      KEYCODE_RGUI=395;
      KEYCODE_AUDIONEXT=396;
      KEYCODE_AUDIOPREV=397;
      KEYCODE_AUDIOSTOP=398;
      KEYCODE_AUDIOPLAY=399;
      KEYCODE_AUDIOMUTE=400;
      KEYCODE_MEDIASELECT=401;
      KEYCODE_WWW=402;
      KEYCODE_MAIL=403;
      KEYCODE_CALCULATOR=404;
      KEYCODE_COMPUTER=405;
      KEYCODE_AC_SEARCH=406;
      KEYCODE_AC_HOME=407;
      KEYCODE_AC_BACK=408;
      KEYCODE_AC_FORWARD=409;
      KEYCODE_AC_STOP=410;
      KEYCODE_AC_REFRESH=411;
      KEYCODE_AC_BOOKMARKS=412;
      KEYCODE_BRIGHTNESSDOWN=413;
      KEYCODE_BRIGHTNESSUP=414;
      KEYCODE_DISPLAYSWITCH=415;
      KEYCODE_KBDILLUMTOGGLE=416;
      KEYCODE_KBDILLUMDOWN=417;
      KEYCODE_KBDILLUMUP=418;
      KEYCODE_EJECT=419;
      KEYCODE_SLEEP=420;
      KEYCODE_INTERNATIONAL1=421;
      KEYCODE_INTERNATIONAL2=422;
      KEYCODE_INTERNATIONAL3=423;
      KEYCODE_INTERNATIONAL4=424;
      KEYCODE_INTERNATIONAL5=425;
      KEYCODE_INTERNATIONAL6=426;
      KEYCODE_INTERNATIONAL7=427;
      KEYCODE_INTERNATIONAL8=428;
      KEYCODE_INTERNATIONAL9=429;
      KEYCODE_LANG1=430;
      KEYCODE_LANG2=431;
      KEYCODE_LANG3=432;
      KEYCODE_LANG4=433;
      KEYCODE_LANG5=434;
      KEYCODE_LANG6=435;
      KEYCODE_LANG7=436;
      KEYCODE_LANG8=437;
      KEYCODE_LANG9=438;
      KEYCODE_LOCKINGCAPSLOCK=439;
      KEYCODE_LOCKINGNUMLOCK=440;
      KEYCODE_LOCKINGSCROLLLOCK=441;
      KEYCODE_NONUSBACKSLASH=442;
      KEYCODE_NONUSHASH=443;
      KEYCODE_BACK=444;
      KEYCODE_CAMERA=445;
      KEYCODE_CALL=446;
      KEYCODE_CENTER=447;
      KEYCODE_FORWARD_DEL=448;
      KEYCODE_DPAD_CENTER=449;
      KEYCODE_DPAD_LEFT=450;
      KEYCODE_DPAD_RIGHT=451;
      KEYCODE_DPAD_DOWN=452;
      KEYCODE_DPAD_UP=453;
      KEYCODE_ENDCALL=454;
      KEYCODE_ENVELOPE=455;
      KEYCODE_EXPLORER=456;
      KEYCODE_FOCUS=457;
      KEYCODE_GRAVE=458;
      KEYCODE_HEADSETHOOK=459;
      KEYCODE_AUDIO_FAST_FORWARD=460;
      KEYCODE_AUDIO_REWIND=461;
      KEYCODE_NOTIFICATION=462;
      KEYCODE_PICTSYMBOLS=463;
      KEYCODE_SWITCH_CHARSET=464;
      KEYCODE_BUTTON_CIRCLE=465;
      KEYCODE_BUTTON_A=466;
      KEYCODE_BUTTON_B=467;
      KEYCODE_BUTTON_C=468;
      KEYCODE_BUTTON_X=469;
      KEYCODE_BUTTON_Y=470;
      KEYCODE_BUTTON_Z=471;
      KEYCODE_BUTTON_L1=472;
      KEYCODE_BUTTON_R1=473;
      KEYCODE_BUTTON_L2=474;
      KEYCODE_BUTTON_R2=475;
      KEYCODE_BUTTON_THUMBL=476;
      KEYCODE_BUTTON_THUMBR=477;
      KEYCODE_BUTTON_START=478;
      KEYCODE_BUTTON_SELECT=479;
      KEYCODE_BUTTON_MODE=480;
      KEYCODE_102ND=481;
      KEYCODE_KATAKANAHIRAGANA=482;
      KEYCODE_HENKAN=483;
      KEYCODE_MUHENKAN=484;
      KEYCODE_HANGEUL=485;
      KEYCODE_HANJA=486;

      KEYCODE_COUNT=1024;

      ORIENTATION_LANDSCAPE=0;
      ORIENTATION_PORTRAIT=1;

      PERIPHERAL_HARDWAREKEYBOARD=0;
      PERIPHERAL_ONSCEENKEYBOARD=1;
      PERIPHERAL_MULTITOUCHSCREEN=2;
      PERIPHERAL_ACCELEROMETER=3;
      PERIPHERAL_COMPASS=4;
      PERIPHERAL_VIBRATOR=5;

      JOYSTICK_HAT_CENTERED=0;
      JOYSTICK_HAT_LEFT=1 shl 0;
      JOYSTICK_HAT_RIGHT=1 shl 1;
      JOYSTICK_HAT_UP=1 shl 2;
      JOYSTICK_HAT_DOWN=1 shl 3;
      JOYSTICK_HAT_LEFTUP=JOYSTICK_HAT_LEFT or JOYSTICK_HAT_UP;
      JOYSTICK_HAT_RIGHTUP=JOYSTICK_HAT_RIGHT or JOYSTICK_HAT_UP;
      JOYSTICK_HAT_LEFTDOWN=JOYSTICK_HAT_LEFT or JOYSTICK_HAT_DOWN;
      JOYSTICK_HAT_RIGHTDOWN=JOYSTICK_HAT_RIGHT or JOYSTICK_HAT_DOWN;
      JOYSTICK_HAT_NONE=1 shl 4;

      GAME_CONTROLLER_BINDTYPE_NONE=0;
      GAME_CONTROLLER_BINDTYPE_BUTTON=1;
      GAME_CONTROLLER_BINDTYPE_AXIS=2;
      GAME_CONTROLLER_BINDTYPE_HAT=3;

      GAME_CONTROLLER_AXIS_INVALID=-1;
      GAME_CONTROLLER_AXIS_LEFTX=0;
      GAME_CONTROLLER_AXIS_LEFTY=1;
      GAME_CONTROLLER_AXIS_RIGHTX=2;
      GAME_CONTROLLER_AXIS_RIGHTY=3;
      GAME_CONTROLLER_AXIS_TRIGGERLEFT=4;
      GAME_CONTROLLER_AXIS_TRIGGERRIGHT=5;
      GAME_CONTROLLER_AXIS_MAX=6;

      GAME_CONTROLLER_BUTTON_INVALID=-1;
      GAME_CONTROLLER_BUTTON_A=0;
      GAME_CONTROLLER_BUTTON_B=1;
      GAME_CONTROLLER_BUTTON_X=2;
      GAME_CONTROLLER_BUTTON_Y=3;
      GAME_CONTROLLER_BUTTON_BACK=4;
      GAME_CONTROLLER_BUTTON_GUIDE=5;
      GAME_CONTROLLER_BUTTON_START=6;
      GAME_CONTROLLER_BUTTON_LEFTSTICK=7;
      GAME_CONTROLLER_BUTTON_RIGHTSTICK=8;
      GAME_CONTROLLER_BUTTON_LEFTSHOULDER=9;
      GAME_CONTROLLER_BUTTON_RIGHTSHOULDER=10;
      GAME_CONTROLLER_BUTTON_DPAD_UP=11;
      GAME_CONTROLLER_BUTTON_DPAD_DOWN=12;
      GAME_CONTROLLER_BUTTON_DPAD_LEFT=13;
      GAME_CONTROLLER_BUTTON_DPAD_RIGHT=14;
      GAME_CONTROLLER_BUTTON_MISC1=15;
      GAME_CONTROLLER_BUTTON_PADDLE1=16;
      GAME_CONTROLLER_BUTTON_PADDLE2=17;
      GAME_CONTROLLER_BUTTON_PADDLE3=18;
      GAME_CONTROLLER_BUTTON_PADDLE4=19;
      GAME_CONTROLLER_BUTTON_TOUCHPAD=20;
      GAME_CONTROLLER_BUTTON_MAX=21;

      KEYEVENT_DOWN=0;
      KEYEVENT_UP=1;
      KEYEVENT_TYPED=2;
      KEYEVENT_UNICODE=3;

      KEYMODIFIER_LSHIFT=0;
      KEYMODIFIER_RSHIFT=1;
      KEYMODIFIER_LCTRL=2;
      KEYMODIFIER_RCTRL=3;
      KEYMODIFIER_LALT=4;
      KEYMODIFIER_RALT=5;
      KEYMODIFIER_LMETA=6;
      KEYMODIFIER_RMETA=7;
      KEYMODIFIER_NUM=8;
      KEYMODIFIER_CAPS=9;
      KEYMODIFIER_SCROLL=10;
      KEYMODIFIER_MODE=11;
      KEYMODIFIER_RESERVED=12;
      KEYMODIFIER_CTRL=13;
      KEYMODIFIER_SHIFT=14;
      KEYMODIFIER_ALT=15;
      KEYMODIFIER_META=16;

      POINTEREVENT_DOWN=0;
      POINTEREVENT_UP=1;
      POINTEREVENT_MOTION=2;
      POINTEREVENT_DRAG=3;

      POINTERBUTTON_NONE=-1;
      POINTERBUTTON_LEFT=0;
      POINTERBUTTON_RIGHT=1;
      POINTERBUTTON_MIDDLE=2;
      POINTERBUTTON_X1=3;
      POINTERBUTTON_X2=4;

type EpvApplication=class(Exception)
      private
       fTag:string;
       fLogLevel:TpvInt32;
      public
       constructor Create(const aTag,aMessage:string;const aLogLevel:TpvInt32=LOG_NONE); reintroduce; virtual;
       destructor Destroy; override;
      published
       property Tag:string read fTag write fTag;
       property LogLevel:TpvInt32 read fLogLevel write fLogLevel;
     end;

     EpvApplicationClass=class of EpvApplication;

     TpvApplicationRunnable=procedure of object;

     TpvApplicationRunnableList=array of TpvApplicationRunnable;

     TpvApplication=class;

     TpvApplicationClass=class of TpvApplication;

     TpvApplicationRawByteString={$if declared(RawByteString)}RawByteString{$else}AnsiString{$ifend};

     TpvApplicationUnicodeString={$if declared(UnicodeString)}UnicodeString{$else}WideString{$ifend};

     TpvApplicationUTF8String={$if declared(UnicodeString)}UTF8String{$else}AnsiString{$ifend};

     TpvApplicationStringList=TpvGenericList<TpvUTF8String>;

     TpvApplicationOnStep=procedure(const aVulkanApplication:TpvApplication) of object;

     TpvApplicationDisplayOrientation=
      (
       LandscapeLeft,
       LandscapeRight,
       Portrait,
       PortraitUpsideDown
      );
     PpvApplicationDisplayOrientation=^TpvApplicationDisplayOrientation;

     TpvApplicationDisplayOrientations=set of TpvApplicationDisplayOrientation;
     PpvApplicationDisplayOrientations=^TpvApplicationDisplayOrientations;

     TpvApplicationDisplayMode=record
      Width:TpvInt32;
      Height:TpvInt32;
      RefreshRate:TpvInt32;
     end;
     PpvApplicationDisplayMode=^TpvApplicationDisplayMode;

     TpvApplicationDisplayModes=array of TpvApplicationDisplayMode;

     TpvApplicationInputKeyEventType=
      (
       Down,
       Up,
       Typed,
       Unicode
      );
     PpvApplicationInputKeyEventType=^TpvApplicationInputKeyEventType;

     TpvApplicationInputKeyModifier=
      (
       LSHIFT,
       RSHIFT,
       LCTRL,
       RCTRL,
       LALT,
       RALT,
       LMETA,
       RMETA,
       NUM,
       CAPS,
       SCROLL,
       MODE,
       RESERVED,
       CTRL,
       SHIFT,
       ALT,
       META
      );
     PpvApplicationInputKeyModifier=^TpvApplicationInputKeyModifier;

     TpvApplicationInputKeyModifiers=set of TpvApplicationInputKeyModifier;
     PpvApplicationInputKeyModifiers=^TpvApplicationInputKeyModifiers;

     TpvApplicationInputKey=packed record
      public
       KeyCode:TpvInt32;
       ScanCode:TpvInt32;
       KeyModifiers:TpvApplicationInputKeyModifiers;
       constructor Create(const aKeyCode:TpvInt32;
                          const aScanCode:TpvInt32;
                          const aKeyModifiers:TpvApplicationInputKeyModifiers);
     end;
     PpvApplicationInputKey=^TpvApplicationInputKey;

     TpvApplicationInputKeyAction=class;

     TpvApplicationInputKeyActions=TpvObjectGenericList<TpvApplicationInputKeyAction>;

     TpvApplicationInputKeyShortcut=class
      private
       fApplication:TpvApplication;
       fID:TpvUInt64;
       fKey:TpvApplicationInputKey;
       fKeyActions:TpvApplicationInputKeyActions;
      public
       constructor Create(const aApplication:TpvApplication;
                          const aKeyCode:TpvInt32;
                          const aScanCode:TpvInt32;
                          const aKeyModifiers:TpvApplicationInputKeyModifiers); reintroduce;
       destructor Destroy; override;
       procedure AfterConstruction; override;
       procedure BeforeDestruction; override;
       procedure AddKeyAction(const aAction:TpvApplicationInputKeyAction);
       procedure RemoveKeyAction(const aAction:TpvApplicationInputKeyAction);
       function HasKeyAction(const aAction:TpvApplicationInputKeyAction):boolean;
      published
       property ID:TpvUInt64 read fID write fID;
       property KeyCode:TpvInt32 read fKey.KeyCode write fKey.KeyCode;
       property ScanCode:TpvInt32 read fKey.ScanCode write fKey.ScanCode;
       property KeyModifiers:TpvApplicationInputKeyModifiers read fKey.KeyModifiers write fKey.KeyModifiers;
     end;

     TpvApplicationInputKeyShortcuts=TpvObjectGenericList<TpvApplicationInputKeyShortcut>;

     TpvApplicationInputKeyShortcutHashMap=TpvHashMap<TpvApplicationInputKey,TpvApplicationInputKeyShortcut>;

     TpvApplicationInputKeyAction=class
      private
       fApplication:TpvApplication;
       fID:TpvUInt64;
       fName:TpvUTF8String;
       fDescription:TpvUTF8String;
       fKeyShortcuts:TpvApplicationInputKeyShortcuts;
      public
       constructor Create(const aApplication:TpvApplication;
                          const aName:TpvUTF8String='';
                          const aDescription:TpvUTF8String=''); reintroduce;
       destructor Destroy; override;
       procedure AfterConstruction; override;
       procedure BeforeDestruction; override;
       procedure AddKeyShortcut(const aShortcut:TpvApplicationInputKeyShortcut);
       procedure RemoveKeyShortcut(const aShortcut:TpvApplicationInputKeyShortcut);
       function HasKeyShortcut(const aShortcut:TpvApplicationInputKeyShortcut):boolean;
      published
       property ID:TpvUInt64 read fID write fID;
       property Name:TpvUTF8String read fName write fName;
       property Description:TpvUTF8String read fDescription write fDescription;
       property KeyShortcuts:TpvApplicationInputKeyShortcuts read fKeyShortcuts write fKeyShortcuts;
     end;

     TpvApplicationInputKeyEvent=record
      public
       KeyEventType:TpvApplicationInputKeyEventType;
       KeyCode:TpvInt32;
       ScanCode:TpvInt32;
       KeyModifiers:TpvApplicationInputKeyModifiers;
       KeyShortcut:TpvApplicationInputKeyShortcut;
       constructor Create(const aKeyEventType:TpvApplicationInputKeyEventType;
                          const aKeyCode:TpvInt32;
                          const aScanCode:TpvInt32;
                          const aKeyModifiers:TpvApplicationInputKeyModifiers;
                          const aKeyShortcut:TpvApplicationInputKeyShortcut);
     end;
     PpvApplicationInputKeyEvent=^TpvApplicationInputKeyEventType;

     TpvApplicationInputPointerEventType=
      (
       Down,
       Up,
       Motion,
       Drag
      );
     PpvApplicationInputPointerEventType=^TpvApplicationInputPointerEventType;

     TpvApplicationInputPointerButton=
      (
       None,
       Left,
       Middle,
       Right,
       X1,
       X2
      );
     PpvApplicationInputPointerButton=^TpvApplicationInputPointerButton;

     TpvApplicationInputPointerButtons=set of TpvApplicationInputPointerButton;
     PpvApplicationInputPointerButtons=^TpvApplicationInputPointerButtons;

     TpvApplicationInputPointerEvent=record
      public
       PointerEventType:TpvApplicationInputPointerEventType;
       Position:TpvVector2;
       RelativePosition:TpvVector2;
       Pressure:TpvFloat;
       PointerID:TpvInt32;
       Button:TpvApplicationInputPointerButton;
       Buttons:TpvApplicationInputPointerButtons;
       KeyModifiers:TpvApplicationInputKeyModifiers;
       constructor Create(const aPointerEventType:TpvApplicationInputPointerEventType;
                          const aPosition:TpvVector2;
                          const aPressure:TpvFloat;
                          const aPointerID:TpvInt32;
                          const aButton:TpvApplicationInputPointerButton;
                          const aButtons:TpvApplicationInputPointerButtons;
                          const aKeyModifiers:TpvApplicationInputKeyModifiers); overload;
       constructor Create(const aPointerEventType:TpvApplicationInputPointerEventType;
                          const aPosition:TpvVector2;
                          const aRelativePosition:TpvVector2;
                          const aPressure:TpvFloat;
                          const aPointerID:TpvInt32;
                          const aButtons:TpvApplicationInputPointerButtons;
                          const aKeyModifiers:TpvApplicationInputKeyModifiers); overload;
     end;
     PpvApplicationInputPointerEvent=^TpvApplicationInputPointerEventType;

     TpvApplicationInputProcessor=class
      public
       constructor Create; virtual;
       destructor Destroy; override;
       function KeyEvent(const aKeyEvent:TpvApplicationInputKeyEvent):boolean; virtual;
       function PointerEvent(const aPointerEvent:TpvApplicationInputPointerEvent):boolean; virtual;
       function Scrolled(const aRelativeAmount:TpvVector2):boolean; virtual;
       function DragDropFileEvent(aFileName:TpvUTF8String):boolean; virtual;
     end;

     PpvApplicationInputProcessorQueueEvent=^TpvApplicationInputProcessorQueueEvent;
     TpvApplicationInputProcessorQueueEvent=record
      Next:PpvApplicationInputProcessorQueueEvent;
      Time:TpvInt64;
      StringData:TpvUTF8String;
      case Event:TpvInt32 of
       EVENT_KEY:(
        KeyEvent:TpvApplicationInputKeyEvent;
       );
       EVENT_POINTER:(
        PointerEvent:TpvApplicationInputPointerEvent;
       );
       EVENT_SCROLLED:(
        RelativeAmount:TpvVector2;
       );
     end;

     TpvApplicationInputProcessorQueue=class(TpvApplicationInputProcessor)
      private
       fProcessor:TpvApplicationInputProcessor;
       fCriticalSection:TPasMPCriticalSection;
       fQueuedEvents:PpvApplicationInputProcessorQueueEvent;
       fLastQueuedEvent:PpvApplicationInputProcessorQueueEvent;
       fFreeEvents:PpvApplicationInputProcessorQueueEvent;
       fCurrentEventTime:TpvInt64;
       function NewEvent:PpvApplicationInputProcessorQueueEvent;
       procedure FreeEvent(const aEvent:PpvApplicationInputProcessorQueueEvent);
       procedure PushEvent(const aEvent:PpvApplicationInputProcessorQueueEvent);
      public
       constructor Create; override;
       destructor Destroy; override;
       procedure SetProcessor(aProcessor:TpvApplicationInputProcessor);
       function GetProcessor:TpvApplicationInputProcessor;
       procedure Drain;
       function GetCurrentEventTime:TpvInt64;
       function KeyEvent(const aKeyEvent:TpvApplicationInputKeyEvent):boolean; override;
       function PointerEvent(const aPointerEvent:TpvApplicationInputPointerEvent):boolean; override;
       function Scrolled(const aRelativeAmount:TpvVector2):boolean; override;
       function DragDropFileEvent(aFileName:TpvUTF8String):boolean; override;
     end;

     TpvApplicationInputMultiplexer=class(TpvApplicationInputProcessor)
      private
       fProcessors:TList;
      public
       constructor Create; override;
       destructor Destroy; override;
       procedure AddProcessor(const aProcessor:TpvApplicationInputProcessor);
       procedure AddProcessors(const aProcessors:array of TpvApplicationInputProcessor);
       procedure InsertProcessor(const aIndex:TpvInt32;const aProcessor:TpvApplicationInputProcessor);
       procedure RemoveProcessor(const aProcessor:TpvApplicationInputProcessor); overload;
       procedure RemoveProcessor(const aIndex:TpvInt32); overload;
       procedure ClearProcessors;
       function CountProcessors:TpvInt32;
       function KeyEvent(const aKeyEvent:TpvApplicationInputKeyEvent):boolean; override;
       function PointerEvent(const aPointerEvent:TpvApplicationInputPointerEvent):boolean; override;
       function Scrolled(const aRelativeAmount:TpvVector2):boolean; override;
       function DragDropFileEvent(aFileName:TpvUTF8String):boolean; override;
     end;

     TpvApplicationInputTextInputCallback=procedure(aSuccessful:boolean;const aText:TpvApplicationRawByteString) of object;

     TpvApplicationInput=class;

     TpvApplicationJoystick=class
      private
       fID:TpvInt64;
{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
       fIndex:TpvInt32;
       fJoystick:PSDL_Joystick;
       fGameController:PSDL_GameController;
{$elseif not defined(PasVulkanHeadless)}
{$if defined(Windows)}
       fJoystick:TpvUInt32;
       fState:Pointer;
       fJoyCaps:TJOYCAPSW;
       fJoyInfoEx:TJoyInfoEx;
       fWin32GameInputDevice:IGameInputDevice;
       fWin32GameInputDeviceName:TpvUTF8String;
       fWin32GameInputDeviceGUID:TGUID;
{$ifend}
       fAxes:array[0..GAME_CONTROLLER_AXIS_MAX-1] of TpvFloat;
       fButtons:TpvUInt32;
       fHats:TpvUInt32;
{$ifend}
       fCountAxes:TpvInt32;
       fCountBalls:TpvInt32;
       fCountHats:TpvInt32;
       fCountButtons:TpvInt32;
       procedure Initialize;
      public
{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
       constructor Create(const aID:TpvInt64;const aJoystick:PSDL_Joystick;const aGameController:PSDL_GameController); reintroduce;
{$else}
       constructor Create(const aID:TpvInt64); reintroduce;
{$ifend}
       destructor Destroy; override;
       function IsGameController:boolean;
       function Index:TpvInt32;
       function ID:TpvInt32;
       function Name:TpvApplicationRawByteString;
       function GUID:TGUID;
       function DeviceGUID:TGUID;
       function CountAxes:TpvInt32;
       function CountBalls:TpvInt32;
       function CountHats:TpvInt32;
       function CountButtons:TpvInt32;
       procedure Update;
       function GetAxis(const aAxisIndex:TpvInt32):TpvFloat;
       function GetBall(const aBallIndex:TpvInt32;out aDeltaX,aDeltaY:TpvInt32):boolean;
       function GetHat(const aHatIndex:TpvInt32):TpvInt32;
       function GetButton(const aButtonIndex:TpvInt32):boolean;
       function IsGameControllerAttached:boolean;
       function GetGameControllerAxis(const aAxis:TpvInt32):TpvFloat;
       function GetGameControllerButton(const aButton:TpvInt32):boolean;
       function GetGameControllerName:TpvApplicationRawByteString;
       function GetGameControllerMapping:TpvApplicationRawByteString;
     end;

     TpvApplicationJoysticks=class(TpvObjectGenericList<TpvApplicationJoystick>);

     TpvApplicationJoystickIDHashMap=class(TpvHashMap<TpvInt64,TpvApplicationJoystick>);

{$if not (defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless))}
{$if defined(Windows) and not defined(PasVulkanHeadless)}
     TpvApplicationTOUCHINPUT=record
      x:LONG;
      y:LONG;
      hSource:THANDLE;
      dwID:DWORD;
      dwFlags:DWORD;
      dwMask:DWORD;
      dwTime:DWORD;
      dwExtraInfo:ULONG_PTR;
      cxContact:DWORD;
      cyContact:DWORD;
     end;
     PpvApplicationTOUCHINPUT=^TpvApplicationTOUCHINPUT;

     TpvApplicationPOINTER_INPUT_TYPE=TpvUInt32;
     PpvApplicationPOINTER_INPUT_TYPE=^TpvApplicationPOINTER_INPUT_TYPE;

     TpvApplicationPOINTER_FLAGS=TpvUInt32;
     PpvApplicationPOINTER_FLAGS=^TpvApplicationPOINTER_FLAGS;

     TpvApplicationPOINTER_BUTTON_CHANGE_TYPE=TpvUInt32;
     PpvApplicationPOINTER_BUTTON_CHANGE_TYPE=^TpvApplicationPOINTER_BUTTON_CHANGE_TYPE;

     TpvApplicationPOINTER_INFO=record
      pointerType:TpvApplicationPOINTER_INPUT_TYPE;
      pointerId:TpvUInt32;
      frameId:TpvUInt32;
      pointerFlags:TpvApplicationPOINTER_FLAGS;
      sourceDevice:THandle;
      hwndTarget:HWND;
      ptPixelLocation:TPoint;
      ptHimetricLocation:TPoint;
      ptPixelLocationRaw:TPoint;
      ptHimetricLocationRaw:TPoint;
      dwTime:DWORD;
      historyCount:TpvUInt32;
      InputData:TpvInt32;
      dwKeyStates:DWORD;
      PerformanceCount:TpvUInt64;
      ButtonChangeType:TpvApplicationPOINTER_BUTTON_CHANGE_TYPE;
     end;

     PpvApplicationPOINTER_INFO=^TpvApplicationPOINTER_INFO;

     TpvApplicationTOUCH_FLAGS=TpvUInt32;
     PpvApplicationTOUCH_FLAGS=^TpvApplicationTOUCH_FLAGS;

     TpvApplicationTOUCH_MASK=TpvUInt32;
     PpvApplicationTOUCH_MASK=^TpvApplicationTOUCH_MASK;

     TpvApplicationPOINTER_TOUCH_INFO=record
      pointerInfo:TpvApplicationPOINTER_INFO;
      touchFlags:TpvApplicationTOUCH_FLAGS;
      touchMask:TpvApplicationTOUCH_MASK;
      rcContact:TRect;
      rcContactRaw:TRect;
      orientation:TpvUInt32;
      pressure:TpvUInt32;
     end;

     PpvApplicationPOINTER_TOUCH_INFO=^TpvApplicationPOINTER_TOUCH_INFO;

     TpvApplicationPEN_FLAGS=TpvUInt32;
     PpvApplicationPEN_FLAGS=^TpvApplicationPEN_FLAGS;

     TpvApplicationPEN_MASK=TpvUInt32;
     PpvApplicationPEN_MASK=^TpvApplicationPEN_MASK;

     TpvApplicationPOINTER_PEN_INFO=record
      pointerInfo:TpvApplicationPOINTER_INFO;
      penFlags:TpvApplicationPEN_FLAGS;
      penMask:TpvApplicationPEN_MASK;
      pressure:TpvUInt32;
      rotation:TpvUInt32;
      tiltX:TpvInt32;
      tiltY:TpvInt32;
     end;

     PpvApplicationPOINTER_PEN_INFO=^TpvApplicationPOINTER_PEN_INFO;

     TpvApplicationCOMBINED_POINTER_INFO=record
      case TpvUInt8 of
       0:(
        pointerInfo:TpvApplicationPOINTER_INFO;
       );
       1:(
        pointerTouchInfo:TpvApplicationPOINTER_TOUCH_INFO;
       );
       2:(
        pointerPenInfo:TpvApplicationPOINTER_PEN_INFO;
       );
     end;

     PpvApplicationCOMBINED_POINTER_INFO=^TpvApplicationCOMBINED_POINTER_INFO;

     TpvApplicationWin32GameInputDeviceCallbackQueueItem=record
      Device:IGameInputDevice;
      Timestamp:TpvUInt64;
      CurrentStatus:TGameInputDeviceStatus;
      PreviousStatus:TGameInputDeviceStatus;
     end;

     PpvApplicationWin32GameInputDeviceCallbackQueueItem=^TpvApplicationWin32GameInputDeviceCallbackQueueItem;

     TpvApplicationWin32GameInputDeviceCallbackQueue=TPasMPUnboundedQueue<TpvApplicationWin32GameInputDeviceCallbackQueueItem>;

{$ifend}

     TpvApplicationNativeEventKind=
      (
       None,
       Resize,
       Quit,
       Close,
       Destroy,
       LowMemory,
       WillEnterBackground,
       DidEnterBackground,
       WillEnterForeground,
       DidEnterForeground,
       GraphicsReset,
       DropFile,
       TextInput,
       KeyDown,
       KeyUp,
       KeyTyped,
       UnicodeCharTyped,
       MouseButtonDown,
       MouseButtonUp,
       MouseWheel,
       MouseMoved,
       MouseEnter,
       MouseLeave,
       TouchDown,
       TouchUp,
       TouchMotion
      );

     PpvApplicationNativeEventKind=^TpvApplicationNativeEventKind;

     TpvApplicationNativeEvent=record
      StringValue:TpvUTF8String;
      case Kind:TpvApplicationNativeEventKind of
       TpvApplicationNativeEventKind.None:(
       );
       TpvApplicationNativeEventKind.Resize:(
        ResizeWidth:TpvInt32;
        ResizeHeight:TpvInt32;
       );
       TpvApplicationNativeEventKind.Close:(
       );
       TpvApplicationNativeEventKind.Destroy:(
       );
       TpvApplicationNativeEventKind.DropFile:(
       );
       TpvApplicationNativeEventKind.KeyDown,
       TpvApplicationNativeEventKind.KeyUp,
       TpvApplicationNativeEventKind.KeyTyped:(
        KeyCode:TpvInt32;
        ScanCode:TpvInt32;
        KeyModifiers:TpvApplicationInputKeyModifiers;
        KeyRepeat:Boolean;
       );
       TpvApplicationNativeEventKind.UnicodeCharTyped:(
        CharVal:TPUCUUTF32Char;
       );
       TpvApplicationNativeEventKind.MouseButtonDown,
       TpvApplicationNativeEventKind.MouseButtonUp,
       TpvApplicationNativeEventKind.MouseWheel,
       TpvApplicationNativeEventKind.MouseMoved,
       TpvApplicationNativeEventKind.MouseEnter,
       TpvApplicationNativeEventKind.MouseLeave:(
        MouseCoordX:TpvInt32;
        MouseCoordY:TpvInt32;
        MouseDeltaX:TpvInt32;
        MouseDeltaY:TpvInt32;
        MouseKeyModifiers:TpvApplicationInputKeyModifiers;
        MouseButtons:TpvApplicationInputPointerButtons;
        case TpvApplicationNativeEventKind of
         TpvApplicationNativeEventKind.MouseWheel:(
          MouseScrollOffsetX:TpvDouble;
          MouseScrollOffsetY:TpvDouble;
         );
         TpvApplicationNativeEventKind.MouseButtonDown,
         TpvApplicationNativeEventKind.MouseButtonUp,
         TpvApplicationNativeEventKind.MouseMoved,
         TpvApplicationNativeEventKind.MouseEnter,
         TpvApplicationNativeEventKind.MouseLeave:(
          MouseButton:TpvApplicationInputPointerButton;
         );
       );
       TpvApplicationNativeEventKind.TouchDown,
       TpvApplicationNativeEventKind.TouchUp,
       TpvApplicationNativeEventKind.TouchMotion:(
        TouchID:TpvUInt16;
        TouchX:TpvDouble;
        TouchY:TpvDouble;
        TouchDeltaX:TpvDouble;
        TouchDeltaY:TpvDouble;
        TouchPressure:TpvDouble;
        TouchPen:Boolean;
       );
     end;

     PpvApplicationNativeEvent=^TpvApplicationNativeEvent;

     TpvApplicationNativeEventQueue=TPasMPUnboundedQueue<TpvApplicationNativeEvent>;

     TpvApplicationNativeEventLocalQueue=TpvDynamicQueue<TpvApplicationNativeEvent>;

{$ifend}

     TpvApplicationEvent=record
{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
      SDLEvent:TSDL_Event;
      StringData:TpvUTF8String;
{$else}
      NativeEvent:TpvApplicationNativeEvent;
{$ifend}
     end;

     PpvApplicationEvent=^TpvApplicationEvent;

     TpvApplicationInputKeycodeStringHashMap=TpvStringHashMap<TpvInt32>;

     TpvApplicationInput=class
      private
       fVulkanApplication:TpvApplication;
       fKeyCodeNames:array[-1..KEYCODE_COUNT-1] of TpvApplicationRawByteString;
       fKeyCodeLowerCaseNames:array[-1..KEYCODE_COUNT-1] of TpvApplicationRawByteString;
       fCriticalSection:TPasMPCriticalSection;
       fProcessor:TpvApplicationInputProcessor;
       fEvents:array of TpvApplicationEvent;
       fEventTimes:array of TpvInt64;
       fEventCount:TpvInt32;
       fCurrentEventTime:TpvInt64;
       fKeyDown:array[0..$ffff] of boolean;
       fKeyDownCount:TpvInt32;
       fJustKeyDown:array[0..$ffff] of boolean;
       fPointerX:array[0..$ffff] of TpvFloat;
       fPointerY:array[0..$ffff] of TpvFloat;
       fPointerDown:array[0..$ffff] of TpvApplicationInputPointerButtons;
       fPointerJustDown:array[0..$ffff] of TpvApplicationInputPointerButtons;
       fPointerPressure:array[0..$ffff] of TpvFloat;
       fPointerDeltaX:array[0..$ffff] of TpvFloat;
       fPointerDeltaY:array[0..$ffff] of TpvFloat;
       fPointerDownCount:TpvInt32;
       fMouseX:TpvInt32;
       fMouseY:TpvInt32;
       fMouseDown:TpvApplicationInputPointerButtons;
       fMouseJustDown:TpvApplicationInputPointerButtons;
       fMouseDeltaX:TpvInt32;
       fMouseDeltaY:TpvInt32;
       fJustTouched:longbool;
       fMaxPointerID:TpvInt32;
       fJoysticks:TpvApplicationJoysticks;
       fJoystickIDHashMap:TpvApplicationJoystickIDHashMap;
       fMainJoystick:TpvApplicationJoystick;
       fTextInput:longbool;
       fLastTextInput:longbool;
       fKeyCodeNameHashmap:TpvApplicationInputKeycodeStringHashMap;
       fKeyShortcuts:TpvApplicationInputKeyShortcuts;
       fKeyShortcutHashMap:TpvApplicationInputKeyShortcutHashMap;
       fKeyShortcutIDCounter:TpvUInt64;
       fKeyActions:TpvApplicationInputKeyActions;
       fKeyActionIDCounter:TpvUInt64;
{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
       function TranslateSDLKeyCode(const aKeyCode,aScanCode:TpvInt32):TpvInt32;
       function TranslateSDLScanCode(const aKeyCode,aScanCode:TpvInt32):TpvInt32;
       function TranslateSDLKeyModifier(const aKeyModifier:TpvInt32):TpvApplicationInputKeyModifiers;
{$else}
{$ifend}
       procedure AddEvent(const aEvent:TpvApplicationEvent);
       procedure ProcessEvents;
      public
       constructor Create(const aVulkanApplication:TpvApplication); reintroduce;
       destructor Destroy; override;
       procedure ClearKeyDefinitions;
       function GetKeyShortcut(const aKeyCode:TpvInt32;
                               const aScanCode:TpvInt32;
                               const aKeyModifiers:TpvApplicationInputKeyModifiers):TpvApplicationInputKeyShortcut;
       function AddKeyShortcut(const aKeyCode:TpvInt32;
                               const aScanCode:TpvInt32;
                               const aKeyModifiers:TpvApplicationInputKeyModifiers):TpvApplicationInputKeyShortcut;
       procedure RemoveKeyShortcut(const aKeyShortcut:TpvApplicationInputKeyShortcut); overload;
       procedure RemoveKeyShortcut(const aKeyCode:TpvInt32;
                                   const aScanCode:TpvInt32;
                                   const aKeyModifiers:TpvApplicationInputKeyModifiers); overload;
       function AddKeyAction(const aName:TpvUTF8String='';
                             const aDescription:TpvUTF8String=''):TpvApplicationInputKeyAction;
       procedure RemoveKeyAction(const aKeyAction:TpvApplicationInputKeyAction); overload;
       function KeyCodeToString(const aKeyCode:TpvInt32):TpvApplicationRawByteString;
       function StringToKeyCode(const aString:TpvApplicationRawByteString):TpvInt32;
       function GetAccelerometerX:TpvFloat;
       function GetAccelerometerY:TpvFloat;
       function GetAccelerometerZ:TpvFloat;
       function GetOrientationAzimuth:TpvFloat;
       function GetOrientationPitch:TpvFloat;
       function GetOrientationRoll:TpvFloat;
       function GetMaxPointerID:TpvInt32;
       function GetPointerX(const aPointerID:TpvInt32=0):TpvFloat;
       function GetPointerDeltaX(const aPointerID:TpvInt32=0):TpvFloat;
       function GetPointerY(const aPointerID:TpvInt32=0):TpvFloat;
       function GetPointerDeltaY(const aPointerID:TpvInt32=0):TpvFloat;
       function GetPointerPressure(const aPointerID:TpvInt32=0):TpvFloat;
       function IsPointerTouched(const aPointerID:TpvInt32=0;const aButtonMask:TpvApplicationInputPointerButtons=[TpvApplicationInputPointerButton.Left,TpvApplicationInputPointerButton.Middle,TpvApplicationInputPointerButton.Right]):boolean;
       function IsPointerJustTouched(const aPointerID:TpvInt32=0;const aButtonMask:TpvApplicationInputPointerButtons=[TpvApplicationInputPointerButton.Left,TpvApplicationInputPointerButton.Middle,TpvApplicationInputPointerButton.Right]):boolean;
       function IsTouched:boolean;
       function JustTouched:boolean;
       function IsButtonPressed(const aButton:TpvApplicationInputPointerButton):boolean;
       function IsKeyPressed(const aKeyCode:TpvInt32):boolean;
       function IsKeyJustPressed(const aKeyCode:TpvInt32):boolean;
       function GetKeyName(const aKeyCode:TpvInt32):TpvApplicationRawByteString;
       function GetKeyModifiers:TpvApplicationInputKeyModifiers;
       procedure StartTextInput;
       procedure StopTextInput;
       procedure GetTextInput(const aCallback:TpvApplicationInputTextInputCallback;const aTitle,aText:TpvApplicationRawByteString;const aPlaceholder:TpvApplicationRawByteString='');
       procedure SetOnscreenKeyboardVisible(const aVisible:boolean);
       procedure Vibrate(const aMilliseconds:TpvInt32); overload;
       procedure Vibrate(const aPattern:array of TpvInt32;const aRepeats:TpvInt32); overload;
       procedure CancelVibrate;
       procedure GetRotationMatrix(const aMatrix3x3:pointer);
       function GetCurrentEventTime:TpvInt64;
       procedure SetCatchBackKey(const aCatchBack:boolean);
       procedure SetCatchMenuKey(const aCatchMenu:boolean);
       procedure SetInputProcessor(const aProcessor:TpvApplicationInputProcessor);
       function GetInputProcessor:TpvApplicationInputProcessor;
       function IsPeripheralAvailable(const aPeripheral:TpvInt32):boolean;
       function GetNativeOrientation:TpvInt32;
       procedure SetCursorCatched(const aCatched:boolean);
       function IsCursorCatched:boolean;
       procedure SetCursorPosition(const pX,pY:TpvInt32);
       function GetJoystickCount:TpvInt32;
       function GetJoystick(const aID:TpvInt64=-1):TpvApplicationJoystick;
       function GetJoystickByID(const aID:TpvInt64=-1):TpvApplicationJoystick;
       function GetJoystickByIndex(const aIndex:TpvSizeInt=-1):TpvApplicationJoystick;
      published
       property KeyShortcuts:TpvApplicationInputKeyShortcuts read fKeyShortcuts;
       property KeyActions:TpvApplicationInputKeyActions read fKeyActions;
     end;

     TpvApplicationLifecycleListener=class
      public
       constructor Create; reintroduce; virtual;
       destructor Destroy; override;
       function Resume:boolean; virtual;
       function Pause:boolean; virtual;
       function LowMemory:boolean; virtual;
       function Terminate:boolean; virtual;
     end;

     TpvApplicationScreen=class
      public

       constructor Create; virtual;

       destructor Destroy; override;

       procedure Show; virtual;

       procedure Hide; virtual;

       procedure Resume; virtual;

       procedure Pause; virtual;

       procedure LowMemory; virtual;

       procedure Resize(const aWidth,aHeight:TpvInt32); virtual;

       procedure AfterCreateSwapChain; virtual;

       procedure BeforeDestroySwapChain; virtual;

       function HandleEvent(const aEvent:TpvApplicationEvent):boolean; virtual;

       function KeyEvent(const aKeyEvent:TpvApplicationInputKeyEvent):boolean; virtual;

       function PointerEvent(const aPointerEvent:TpvApplicationInputPointerEvent):boolean; virtual;

       function Scrolled(const aRelativeAmount:TpvVector2):boolean; virtual;

       function DragDropFileEvent(aFileName:TpvUTF8String):boolean; virtual;

       function CanBeParallelProcessed:boolean; virtual;

       procedure Check(const aDeltaTime:TpvDouble); virtual;

       procedure Update(const aDeltaTime:TpvDouble); virtual;

       procedure BeginFrame(const aDeltaTime:TpvDouble); virtual;

       function IsReadyForDrawOfInFlightFrameIndex(const aInFlightFrameIndex:TpvInt32):boolean; virtual;

       procedure Draw(const aSwapChainImageIndex:TpvInt32;var aWaitSemaphore:TpvVulkanSemaphore;const aWaitFence:TpvVulkanFence=nil); virtual;

       procedure FinishFrame(const aSwapChainImageIndex:TpvInt32;var aWaitSemaphore:TpvVulkanSemaphore;const aWaitFence:TpvVulkanFence=nil); virtual;

       procedure PostPresent(const aSwapChainImageIndex:TpvInt32); virtual;

       procedure UpdateAudio; virtual;

     end;

     TpvApplicationScreenClass=class of TpvApplicationScreen;

     TpvApplicationAssets=class
      public
       type TFileNameList=array of TpvUTF8String;
      private
       fVulkanApplication:TpvApplication;
       fBasePath:TpvUTF8String;
       function CorrectFileName(const aFileName:TpvUTF8String):TpvUTF8String;
      public
       constructor Create(const aVulkanApplication:TpvApplication);
       destructor Destroy; override;
       function ExistAsset(const aFileName:TpvUTF8String):boolean;
       function GetAssetStream(const aFileName:TpvUTF8String):TStream;
       function GetAssetSize(const aFileName:TpvUTF8String):TpvUInt64;
       function GetAssetDateTime(const aFileName:TpvUTF8String):TDateTime;
       function GetDirectoryFileList(const aPath:TpvUTF8String;const aRaiseExceptionOnNonExistentDirectory:boolean=false):TFileNameList;
       property BasePath:TpvUTF8String read fBasePath;
     end;

     TpvApplicationFiles=class
      private
       fVulkanApplication:TpvApplication;
      public
       constructor Create(const aVulkanApplication:TpvApplication);
       destructor Destroy; override;
       function GetCacheStoragePath:TpvUTF8String;
       function GetLocalStoragePath:TpvUTF8String;
       function GetRoamingStoragePath:TpvUTF8String;
       function GetExternalStoragePath:TpvUTF8String;
       function IsCacheStorageAvailable:boolean;
       function IsLocalStorageAvailable:boolean;
       function IsRoamingStorageAvailable:boolean;
       function IsExternalStorageAvailable:boolean;
     end;

     TpvApplicationClipboard=class
      private
       fVulkanApplication:TpvApplication;
      public
       constructor Create(const aVulkanApplication:TpvApplication);
       destructor Destroy; override;
       function HasText:boolean;
       function GetText:TpvApplicationUTF8String;
       procedure SetText(const aTextString:TpvApplicationUTF8String);
     end;

     TpvApplicationCommandPools=array of array of TpvVulkanCommandPool;

     TpvApplicationCommandBuffers=array of array of TpvVulkanCommandBuffer;

     TpvApplicationCommandBufferFences=array of array of TpvVulkanFence;

     TpvApplicationOnEvent=function(const aVulkanApplication:TpvApplication;const aEvent:TpvApplicationEvent):boolean of object;

     PpvApplicationPresentMode=^TpvApplicationPresentMode;
     TpvApplicationPresentMode=
      (
       Immediate=0,
       Mailbox=1,
       FIFO=2,
       FIFORelaxed=3,
       NoVSync={$ifdef fpc}0{$else}TpvApplicationPresentMode.Immediate{$endif},
       GreedyVSync={$ifdef fpc}1{$else}TpvApplicationPresentMode.Mailbox{$endif},
       VSync={$ifdef fpc}2{$else}TpvApplicationPresentMode.FIFO{$endif}
      );

     PpvApplicationFramePacingMode=^TpvApplicationFramePacingMode;
     TpvApplicationFramePacingMode=
      (
       None=0,
       Auto=1,
       MonitorRefreshRate=2,
       PresentIntervalEstimation=3,
       VulkanPresentTiming=4,
       VulkanPresentTimingFeedback=5
      );

     PpvApplicationFramePacingStrategy=^TpvApplicationFramePacingStrategy;
     TpvApplicationFramePacingStrategy=
      (
       DeviationCompensation=0,
       AbsoluteTimeRaster=1
      );

     PpvApplicationLowLatencyMode=^TpvApplicationLowLatencyMode;
     TpvApplicationLowLatencyMode=
      (
       None=0,
       Auto=1,
       NVReflex=2,
       AMDAntiLag=3
      );

     TpvApplicationPresentTimingFeedbackRefreshMode=
      (
       Unknown=0,
       VRR=1,
       FRR=2
      );

     TpvApplicationProcessingMode=
      (
       Strict=0,
       Flexible=1
      );

     TpvApplicationSwapChainColorSpace=
      (
       RGB=0,
       SRGB=1
      );

     TpvApplicationPresentFrameLatencyMode=
      (
       None=-1,
       Auto=0,
       PresentWait=1,
       FenceWait=2,
       CombinedWait=3
      );

     TpvApplicationVulkanDebugExtensionMode=
      (
       None=-1,
       DebugReportMarker=0,
       DebugUtils=1
      );

     { TpvApplicationUpdateThread }

     TpvApplicationUpdateThread=class(TPasMPThread)
      private
       fApplication:TpvApplication;
       fEvent:TPasMPSimpleEvent;
       fDoneEvent:TPasMPSimpleEvent;
       fFPUExceptionMask:TFPUExceptionMask;
       fFPUPrecisionMode:TFPUPrecisionMode;
       fFPURoundingMode:TFPURoundingMode;
       fInvoked:TPasMPBool32;
      protected
       procedure Execute; override;
      public
       class var UpdateThreadTag:TpvUInt64;
      public
       constructor Create(const aApplication:TpvApplication); reintroduce;
       destructor Destroy; override;
       procedure Shutdown;
       procedure Invoke;
       procedure WaitForDone;
      published
       property Invoked:TPasMPBool32 read fInvoked;
     end;

     TpvApplicationDelayedObjectInstanceToFree=record
      ObjectInstance:TObject;
      IterationsLeft:TpvSizeInt;
     end;
     PpvApplicationDelayedObjectInstanceToFree=^TpvApplicationDelayedObjectInstanceToFree;

     TpvApplicationDelayedObjectInstanceToFreeArray=TpvDynamicArray<TpvApplicationDelayedObjectInstanceToFree>;

     { TpvApplication }

     TpvApplication=class
      private
       type TVulkanBackBufferState=
             (
              Acquire,
              Present
             );
            TAcquireVulkanBackBufferState=
             (
              Entry,
              WaitOnPreviousFrames,
              WaitOnPresentCompleteFence,
              CheckSettings,
              Acquire,
              WaitOnFence,
              Apply,
              RecreateSwapChain,
              RecreateSurface,
              RecreateDevice
             );
             TWin32TouchIDFreeList=TpvDynamicQueue<TpvUInt32>;
             TWin32TouchIDHashMap=class(TpvHashMap<TpvUInt32,TpvUInt32>)
             end;
       const PresentModeToVulkanPresentMode:array[TpvApplicationPresentMode.Immediate..TpvApplicationPresentMode.FIFORelaxed] of TVkPresentModeKHR=
              (
               VK_PRESENT_MODE_IMMEDIATE_KHR,
               VK_PRESENT_MODE_MAILBOX_KHR,
               VK_PRESENT_MODE_FIFO_KHR,
               VK_PRESENT_MODE_FIFO_RELAXED_KHR
              );
      private

       fTitle:TpvUTF8String;
       fVersion:TpvUInt32;

       fWindowTitle:TpvUTF8String;

       fHasNewWindowTitle:TPasMPBool32;

       fPathName:TpvUTF8String;

       fOldPathNames:TpvApplicationStringList;

       fCacheStoragePath:TpvUTF8String;

       fLocalStoragePath:TpvUTF8String;

       fRoamingStoragePath:TpvUTF8String;

       fExternalStoragePath:TpvUTF8String;

       fVulkanEventLock:TPasMPCriticalSection;

       fPasMPInstance:TPasMP;

       fPasMPProfilerSuppressGaps:TPasMPBool32;

       fPasMPProfilerVisibleTimePeriod:TPasMPHighResolutionTime;

       fPasMPProfilerHistory:TPasMPProfilerHistory;

       fPasMPProfilerHistoryCount:TPasMPInt32;

       fDoDestroyGlobalPasMPInstance:TPasMPBool32;

       fHighResolutionTimer:TpvHighResolutionTimer;

       fFrameLimiterHighResolutionTimerSleepWithDriftCompensation:TpvHighResolutionTimerSleepWithDriftCompensation;

       fAssets:TpvApplicationAssets;

       fFiles:TpvApplicationFiles;

       fInput:TpvApplicationInput;

       fClipboard:TpvApplicationClipboard;

       fAudio:TpvAudio;

       fResourceManager:TpvResourceManager;

       fRunnableList:TpvApplicationRunnableList;
       fRunnableListCount:TpvInt32;
       fRunnableListCriticalSection:TPasMPCriticalSection;

       fLifecycleListenerList:TList;
       fLifecycleListenerListCriticalSection:TPasMPCriticalSection;

       fDisplayOrientations:TpvApplicationDisplayOrientations;

       fCurrentWidth:TpvInt32;
       fCurrentHeight:TpvInt32;
       fCurrentFullscreen:TpvInt32;
       fCurrentRealFullScreen:TpvInt32;
       fCurrentFullScreenWidth:Int32;
       fCurrentFullScreenHeight:Int32;
       fCurrentFullScreenRefreshRate:TpvInt32;
       fCurrentMaximized:TpvInt32;
       fCurrentPresentMode:TpvInt32;
       fCurrentVisibleMouseCursor:TpvInt32;
       fCurrentCatchMouseOnButton:TpvInt32;
       fCurrentCatchMouse:TpvInt32;
       fCurrentEffectiveCatchMouse:TpvInt32;
       fCurrentRelativeMouse:TpvInt32;
       fCurrentHideSystemBars:TpvInt32;
       fCurrentAcceptDragDropFiles:TpvInt32;
       fCurrentBlocking:TpvInt32;
       fCurrentWaitOnPreviousFrames:TpvInt32;

       fSwapChainColorSpace:TpvApplicationSwapChainColorSpace;

       fSwapChainHDR:Boolean;

       fWidth:TpvInt32;
       fHeight:TpvInt32;
       fFullScreenWidth:TpvInt32;
       fFullScreenHeight:TpvInt32;
       fFullScreenRefreshRate:TpvInt32;
       fUseRealFullScreen:boolean;
       fFullScreen:boolean;
       fMaximized:boolean;
       fPresentMode:TpvApplicationPresentMode;
       fPresentFrameLatency:TpvUInt64;
       fPresentFrameLatencyMode:TpvApplicationPresentFrameLatencyMode;
       fProcessingMode:TpvApplicationProcessingMode;
       fResizable:boolean;
       fVisibleMouseCursor:boolean;
       fCatchMouseOnButton:boolean;
       fCatchMouse:boolean;
       fEffectiveCatchMouse:boolean;
       fRelativeMouse:boolean;
       fHideSystemBars:boolean;
       fAcceptDragDropFiles:boolean;
       fUseBreadcrumbs:boolean;
       fManualBreadcrumbs:boolean;
       fManualSyncBreadcrumbs:boolean;
       fAndroidMouseTouchEvents:boolean;
       fAndroidTouchMouseEvents:boolean;
       fAndroidBlockOnPause:boolean;
       fAndroidTrapBackButton:boolean;
       fUseAudio:boolean;
       fBlocking:boolean;
       fUpdateWaitsForGPU:boolean;
       fUseExtraUpdateThread:boolean;
       fWaitOnPreviousFrames:boolean;
       fWaitOnPreviousFrame:boolean;
       fTerminationWithAltF4:boolean;
       fTerminationOnQuitEvent:boolean;

       fBackgroundResourceLoaderFrameTimeout:TpvInt64;

{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
       fSDLVersion:TSDL_Version;

{$if defined(PasVulkanUseSDL2WithVulkanSupport)}
       fSDLVersionWithVulkanSupport:boolean;
{$ifend}
{$ifend}

       fDebugging:boolean;

       fLoadWasCalled:boolean;

       fActive:boolean;

       fTerminated:boolean;

{$if defined(fpc) and defined(android) and not (defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless))}
       fAndroidApp:TpvPointer;
       fAndroidWindow:PANativeWindow;
       fAndroidReady:TPasMPBool32;
       fAndroidQuit:TPasMPBool32;
       fAndroidAppProcessMessages:procedure(const aAndroidApp:TpvPointer;const aWait:boolean);
{$ifend}

{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
       fSDLWaveFormat:TSDL_AudioSpec;

       fSDLDisplayMode:TSDL_DisplayMode;
       fSurfaceWindow:PSDL_Window;
{$ifend}

       fEvent:TpvApplicationEvent;

       fLastPressedKeyEvent:TpvApplicationEvent;
       fKeyRepeatTimeAccumulator:TpvHighResolutionTime;
       fKeyRepeatInterval:TpvHighResolutionTime;
       fKeyRepeatInitialInterval:TpvHighResolutionTime;
       fNativeKeyRepeat:boolean;

       fScreenWidth:TpvInt32;
       fScreenHeight:TpvInt32;

{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
       fVideoFlags:TSDLUInt32;
{$ifend}

       fExclusiveFullScreenMode:TpvVulkanExclusiveFullScreenMode;

       fFullscreenFocusNeeded:boolean;

       fStayActiveRegardlessOfVisibility:boolean;

       fWindowMinimizedOrHidden:boolean;

       fGraphicsReady:boolean;

       fReinitializeGraphics:boolean;

       fVulkanRecreateSwapChainOnSuboptimalSurface:boolean;

       fVulkanDebugging:boolean;

       fVulkanShaderPrintfDebugging:boolean;

       fVulkanSynchronizationValidation:boolean;

       fVulkanValidation:boolean;

       fVulkanNVIDIAAfterMath:boolean;

       fVulkanNoUniqueObjectsValidation:boolean;

       fVulkanDebuggingEnabled:boolean;

       fVulkanDebugExtensionMode:TpvApplicationVulkanDebugExtensionMode;

       fVulkanPreferDedicatedGPUs:boolean;

       fVulkanMultiviewSupportEnabled:boolean;

       fVulkanInstance:TpvVulkanInstance;

       fVulkanDevice:TpvVulkanDevice;

       fVulkanPipelineCache:TpvVulkanPipelineCache;

       fVulkanPipelineCacheFileName:TpvUTF8String;

       fCountCPUThreads:TpvInt32;

       fAvailableCPUCores:TPasMPAvailableCPUCores;

       fInternalPresentQueueCommandPool:TpvVulkanCommandPool;
       fInternalPresentQueueCommandBuffer:TpvVulkanCommandBuffer;
       fInternalPresentQueueCommandBufferFence:TpvVulkanFence;

       fInternalGraphicsQueueCommandPool:TpvVulkanCommandPool;
       fInternalGraphicsQueueCommandBuffer:TpvVulkanCommandBuffer;
       fInternalGraphicsQueueCommandBufferFence:TpvVulkanFence;

{      fVulkanCountCommandQueues:TpvInt32;

       fVulkanCommandPools:array of TpvApplicationCommandPools;
       fVulkanCommandBuffers:array of TpvApplicationCommandBuffers;
       fVulkanCommandBufferFences:array of TpvApplicationCommandBufferFences;

       fVulkanUniversalCommandPools:TpvApplicationCommandPools;
       fVulkanUniversalCommandBuffers:TpvApplicationCommandBuffers;
       fVulkanUniversalCommandBufferFences:TpvApplicationCommandBufferFences;

       fVulkanPresentCommandPools:TpvApplicationCommandPools;
       fVulkanPresentCommandBuffers:TpvApplicationCommandBuffers;
       fVulkanPresentCommandBufferFences:TpvApplicationCommandBufferFences;

       fVulkanGraphicsCommandPools:TpvApplicationCommandPools;
       fVulkanGraphicsCommandBuffers:TpvApplicationCommandBuffers;
       fVulkanGraphicsCommandBufferFences:TpvApplicationCommandBufferFences;

       fVulkanComputeCommandPools:TpvApplicationCommandPools;
       fVulkanComputeCommandBuffers:TpvApplicationCommandBuffers;
       fVulkanComputeCommandBufferFences:TpvApplicationCommandBufferFences;

       fVulkanTransferCommandPools:TpvApplicationCommandPools;
       fVulkanTransferCommandBuffers:TpvApplicationCommandBuffers;
       fVulkanTransferCommandBufferFences:TpvApplicationCommandBufferFences;
}

       fVulkanSurface:TpvVulkanSurface;

       fGraphicsPipelinesReady:boolean;

       fSkipNextDrawFrame:boolean;

//     fVulkanPresentationSurface:TpvVulkanPresentationSurface;

       fOnEvent:TpvApplicationOnEvent;

       fOnStep:TpvApplicationOnStep;

       fScreenLock:TPasMPCriticalSection;

       fScreen:TpvApplicationScreen;

       fStartScreen:TpvApplicationScreenClass;

       fNextScreen:TpvApplicationScreen;

       fNextScreenClass:TpvApplicationScreenClass;

       fHasNewNextScreen:boolean;

       fHasLastTime:boolean;

       fDoUpdateMainJoystick:boolean;

       fLastTime:TpvHighResolutionTime;
       fNowTime:TpvHighResolutionTime;
       fDeltaTime:TpvHighResolutionTime;
       //fNextTime:TpvHighResolutionTime;
       fFloatDeltaTime:TpvDouble;
       fUpdateDeltaTime:TpvDouble;

       fFrameRateLimiterLastTime:TpvHighResolutionTime;
       fFrameRateLimiterDeviation:TpvHighResolutionTime;

       // Frame pacing state for temporally consistent frame output
       fFramePacingMode:TpvApplicationFramePacingMode;
       fFramePacingStrategy:TpvApplicationFramePacingStrategy;
       fFramePacingActive:boolean;
       fFramePacingEstimatedRefreshInterval:TpvInt64; // in high-res timer ticks
       fFramePacingNextPresentTarget:TpvInt64;
       fFramePacingLastPresentTime:TpvInt64;
       fFramePacingHistory:array[0..FramePacingHistorySize-1] of TpvInt64;
       fFramePacingHistoryIndex:TpvInt32;
       fFramePacingHistoryCount:TpvInt32;
       fFramePacingDriftAccumulator:TpvInt64;
       fFramePacingSleepWithDriftCompensation:TpvHighResolutionTimerSleepWithDriftCompensation;
       fFramePacingPresentTimingRefreshDuration:TpvUInt64; // from VK_EXT_present_timing, in nanoseconds
       fFramePacingPresentTimingTimeDomainID:TpvUInt64; // from vkGetSwapchainTimeDomainPropertiesEXT
       fFramePacingPresentTimingAvailable:boolean;
       fFramePacingEffectiveInterval:TpvInt64; // computed pacing interval, consumed by FramePacingAndFrameRateLimiter

       // Present timing feedback state (VulkanPresentTimingFeedback mode)
       fPresentTimingFeedbackRefreshDuration:TpvUInt64; // ns
       fPresentTimingFeedbackRefreshInterval:TpvUInt64; // ns (alignment unit)
       fPresentTimingFeedbackRefreshMode:TpvApplicationPresentTimingFeedbackRefreshMode;
       fPresentTimingFeedbackRefreshCounter:TpvUInt64;
       fPresentTimingFeedbackHasRefreshFeedback:boolean;
       fPresentTimingFeedbackTimeDomainCount:TpvInt32;
       fPresentTimingFeedbackTimeDomains:array[0..7] of TVkTimeDomainKHR;
       fPresentTimingFeedbackTimeDomainIDs:array[0..7] of TpvUInt64;
       fPresentTimingFeedbackActiveTimeDomainID:TpvUInt64;
       fPresentTimingFeedbackCalibratedHostTime:TpvUInt64;
       fPresentTimingFeedbackCalibratedStageTime:TpvUInt64;
       fPresentTimingFeedbackLastRecalibrationTime:TpvUInt64;
       fPresentTimingFeedbackNeedRecalibration:boolean;
       fPresentTimingFeedbackLastTargetTime:TpvUInt64;
       fPresentTimingFeedbackPresentationTimeError:TpvInt64;
       fPresentTimingFeedbackPendingCompensation:TpvInt64;
       fPresentTimingFeedbackLastPollPresentID:TpvUInt64;
       fPresentTimingFeedbackErrorRingIndex:TpvInt32;
       fPresentTimingFeedbackErrorRingCount:TpvInt32;
       fPresentTimingFeedbackErrorRingValues:array[0..15] of TpvInt64;
       fPresentTimingFeedbackInitialized:boolean;

       // Low latency mode
       fLowLatencyMode:TpvApplicationLowLatencyMode;
       fLowLatencyActive:boolean;
       fLowLatencyActiveMode:TpvApplicationLowLatencyMode;
       fLowLatencyFrameID:TpvUInt64;
       fLowLatencySleepSemaphore:TpvVulkanTimelineSemaphore;

       fFrameTimesHistoryDeltaTimes:array[0..FrameTimesHistorySize-1] of TpvDouble;
       fFrameTimesHistoryTimePoints:array[0..FrameTimesHistorySize-1] of TpvHighResolutionTime;
       fFrameTimesHistoryIndex:TpvSizeInt;
       fFrameTimesHistoryCount:TpvSizeInt;
       fFrameTimesHistorySum:TpvDouble;

       fFramesPerSecond:TpvDouble;

       fTimingCPUUpdate:TpvDouble;
       fTimingCPUDraw:TpvDouble;
       fTimingCPUBeginFrame:TpvDouble;
       fTimingCPUFinishFrame:TpvDouble;
       fTimingCPUAcquire:TpvDouble;
       fTimingCPUPresent:TpvDouble;
       fTimingCPUFramePacing:TpvDouble;
       fTimingCPUUpdateWait:TpvDouble;
       fTimingCPUFrameStartTime:TpvHighResolutionTime;
       fTimingCPUUpdateStart:TpvDouble;
       fTimingCPUUpdateEnd:TpvDouble;
       fTimingCPUDrawStart:TpvDouble;
       fTimingCPUDrawEnd:TpvDouble;

       fMaximumFramesPerSecond:TpvDouble;

       fFrameCounter:TpvInt64;

       fUpdateFrameCounter:TpvInt64;

       fDrawFrameCounter:TpvInt64;

       fDesiredCountInFlightFrames:TpvInt32;

       fCountInFlightFrames:TpvInt32;

       fPreviousInFlightFrameIndex:TpvInt32;

       fCurrentInFlightFrameIndex:TpvInt32;

       fNextInFlightFrameIndex:TpvInt32;

       fDrawInFlightFrameIndex:TpvInt32;

       fUpdateInFlightFrameIndex:TpvInt32;

       fCountSwapChainImages:TpvInt32;

       fDesiredCountSwapChainImages:TpvInt32;

       fSwapChainImageCounterIndex:TpvInt32;

       fSwapChainImageIndex:TpvInt32;

       fVulkanPresentID:TpvUInt64;

       fVulkanPresentLastID:TpvUInt64;

       fVulkanAPIVersion:TvkUInt32;

       fVulkanPhysicalDeviceHandle:TVkPhysicalDevice;

       fVulkanBackBufferState:TVulkanBackBufferState;

       fAcquireVulkanBackBufferState:TAcquireVulkanBackBufferState;

       fVulkanWaitSemaphore:TpvVulkanSemaphore;

       fVulkanWaitFence:TpvVulkanFence;

       fVulkanSwapChainQueueFamilyIndices:TVkUInt32DynamicArray;

       fVulkanSwapChain:TpvVulkanSwapChain;

       fVulkanOldSwapChain:TpvVulkanSwapChain;

       fVulkanTransferInFlightCommandsFromOldSwapChain:boolean;

       fVulkanInFlightFenceIndices:array[0..MaxInFlightFrames-1] of TpvInt32;

       fVulkanWaitFences:array of TpvVulkanFence;

       fVulkanWaitFencesReady:array of boolean;

       fVulkanPresentCompleteSemaphores:array of TpvVulkanSemaphore;

       fVulkanPresentCompleteFences:array of TpvVulkanFence;

       fVulkanPresentCompleteFencesReady:array of boolean;

       fVulkanDepthImageFormat:TVkFormat;

       fVulkanDepthFrameBufferAttachment:TpvVulkanFrameBufferAttachment;

       fVulkanFrameBufferColorAttachments:TpvVulkanFrameBufferAttachments;

       fVulkanRenderPass:TpvVulkanRenderPass;

       fVulkanFrameBuffers:TpvVulkanSwapChainSimpleDirectRenderTargetFrameBuffers;

       fVulkanPresentCommandPool:TpvVulkanCommandPool;

       fVulkanGraphicsCommandPool:TpvVulkanCommandPool;

       fVulkanSurfaceRecreated:boolean;

       fVulkanBlankCommandBuffers:array of TpvVulkanCommandBuffer;

       fVulkanBlankCommandBufferSemaphores:array of TpvVulkanSemaphore;

       fVulkanPresentToDrawImageBarrierGraphicsQueueCommandBuffers:array of TpvVulkanCommandBuffer;
       fVulkanPresentToDrawImageBarrierGraphicsQueueCommandBufferSemaphores:array of TpvVulkanSemaphore;

       fVulkanPresentToDrawImageBarrierPresentQueueCommandBuffers:array of TpvVulkanCommandBuffer;
       fVulkanPresentToDrawImageBarrierPresentQueueCommandBufferSemaphores:array of TpvVulkanSemaphore;

       fVulkanDrawToPresentImageBarrierGraphicsQueueCommandBuffers:array of TpvVulkanCommandBuffer;
       fVulkanDrawToPresentImageBarrierGraphicsQueueCommandBufferSemaphores:array of TpvVulkanSemaphore;

       fVulkanDrawToPresentImageBarrierPresentQueueCommandBuffers:array of TpvVulkanCommandBuffer;
       fVulkanDrawToPresentImageBarrierPresentQueueCommandBufferSemaphores:array of TpvVulkanSemaphore;

       fVulkanFrameFences:array[0..3] of TpvVulkanFence;
       fVulkanFrameFencesReady:TpvUInt32;
       fVulkanFrameFenceCounter:TpvUInt32;
       fVulkanFrameFenceCommandBuffers:array of array[0..3] of TpvVulkanCommandBuffer;
       fVulkanFrameFenceSemaphores:array of array[0..3] of TpvVulkanSemaphore;

       fVulkanWaitFenceCommandBuffers:array of TpvVulkanCommandBuffer;
       fVulkanWaitFenceSemaphores:array of TpvVulkanSemaphore;

       fVulkanDelayResizeBugWorkaround:boolean;

       fVulkanNVIDIADiagnosticConfigExtensionFound:boolean;

       fVulkanNVIDIADiagnosticCheckPointsExtensionFound:boolean;

       fVulkanNVIDIADeviceDiagnosticsConfigCreateInfoNV:TVkDeviceDiagnosticsConfigCreateInfoNV;

       fUniverse:TObject;

       fUpdateThread:TpvApplicationUpdateThread;

       fInUpdateJobFunction:TPasMPBool32;

       fUpdateJob:PPasMPJob;

       fDelayedObjectInstanceToFreeArray:TpvApplicationDelayedObjectInstanceToFreeArray;
       fDelayedObjectInstanceToFreeArrayLock:TPasMPCriticalSection;

{$if not (defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless))}
       fNativeEventQueue:TpvApplicationNativeEventQueue;

       fNativeEventLocalQueue:TpvApplicationNativeEventLocalQueue;
{$ifend}

{$if not defined(PasVulkanHeadless)}
{$if defined(Windows) and not defined(PasVulkanUseSDL2)}
       fWin32HInstance:HINST;
       fWin32Handle:HWND;
       fWin32Callback:{$ifdef fpc}WNDPROC{$else}Pointer{$endif};
       fWin32Cursor:HCURSOR;
       fWin32HiddenCursor:HCURSOR;
       fWin32Icon:HICON;
       fWin32KeyRepeat:Boolean;
       fWin32MouseInside:Boolean;
       fWin32WindowClass:ATOM;
       fWin32Style:DWORD;
       fWin32Rect:TRect;
       fWin32Title:WideString;
       //fWin32KeyState:TKeyboardState;
       fWin32MouseCoordX:TpvInt32;
       fWin32MouseCoordY:TpvInt32;
       fWin32AudioThread:TPasMPThread;
       fWin32HasFocus:Boolean;
       fWin32OldLeft:TpvInt32;
       fWin32OldTop:TpvInt32;
       fWin32OldWidth:TpvInt32;
       fWin32OldHeight:TpvInt32;
       fWin32FullScreen:Boolean;
       fWin32RealFullScreen:Boolean;
       fWin32HighSurrogate:TpvUInt32;
       fWin32LowSurrogate:TpvUInt32;
       fWin32TouchActive:Boolean;
       fWin32TouchInputs:array of TpvApplicationTOUCHINPUT;
       fWin32TouchIDHashMap:TWin32TouchIDHashMap;
       fWin32TouchIDFreeList:TWin32TouchIDFreeList;
       fWin32TouchIDCounter:TpvUInt32;
       fWin32TouchLastX:array[0..$1fff] of TpvDouble;
       fWin32TouchLastY:array[0..$1fff] of TpvDouble;
       fWin32MainFiber:LPVOID;
       fWin32MessageFiber:LPVOID;
       fWin32NCMouseButton:UINT;
       fWin32NCMousePos:LParam;
       fWin32HasGameInput:boolean;
       fWin32GameInput:IGameInput;
       fWin32GameInputDeviceCallbackQueue:TpvApplicationWin32GameInputDeviceCallbackQueue;
       fWin32GameInputDeviceCallbackToken:TGameInputCallbackToken;

       function Win32ProcessEvent(aMsg:UINT;aWParam:WParam;aLParam:LParam):TpvInt64;

{$ifend}
{$ifend}

       procedure SetTitle(const aTitle:TpvUTF8String);

       procedure SetWindowTitle(const aWindowTitle:TpvUTF8String);

       procedure SetDesiredCountInFlightFrames(const aDesiredCountInFlightFrames:TpvInt32);

       procedure SetDesiredCountSwapChainImages(const aDesiredCountSwapChainImages:TpvInt32);

       function GetAndroidSeparateMouseAndTouch:boolean;
       procedure SetAndroidSeparateMouseAndTouch(const aValue:boolean);

       procedure InitializeGraphics;
       procedure DeinitializeGraphics;

       procedure InitializeAudio;
       procedure DeinitializeAudio;

{$if defined(Windows) and not (defined(PasVulkanUseSDL2) or defined(PasVulkanHeadless))}
       procedure ProcessWin32APIMessages;
{$ifend}

       procedure UpdateJoysticks(const aInitial:boolean);

       function PasMPInstanceOnWorkerThreadException(const aException:Exception):Boolean;

       function GetNativeRefreshRate:TpvDouble;

      protected

       class procedure VulkanDebugLn(const What:TpvUTF8String); static;

       function VulkanOnDebugReportCallback(const aFlags:TVkDebugReportFlagsEXT;const aObjectType:TVkDebugReportObjectTypeEXT;const aObject:TpvUInt64;const aLocation:TVkSize;aMessageCode:TpvInt32;const aLayerPrefix,aMessage:TpvUTF8String):TVkBool32;

       function VulkanOnDebugUtilsMessengerCallback(const aMessageSeverity:TVkDebugUtilsMessageSeverityFlagsEXT;const aMessageTypes:TVkDebugUtilsMessageTypeFlagsEXT;const aCallbackData:PVkDebugUtilsMessengerCallbackDataEXT;const aUserData:pointer):TVkBool32;

       procedure VulkanWaitIdle;

       procedure CreateVulkanDevice(const aSurface:TpvVulkanSurface=nil);

       procedure CreateVulkanInstance;
       procedure DestroyVulkanInstance;

       procedure CreateVulkanSurface;
       procedure DestroyVulkanSurface;

       procedure CreateVulkanSwapChain;
       procedure DestroyVulkanSwapChain;

       procedure CreateVulkanRenderPass;
       procedure DestroyVulkanRenderPass;

       procedure CreateVulkanFrameBuffers;
       procedure DestroyVulkanFrameBuffers;

       procedure CreateVulkanCommandBuffers;
       procedure DestroyVulkanCommandBuffers;

       function ShouldSkipNextFrameForRendering:boolean;

       function WaitForSwapChainLatency:boolean;

       function AcquireVulkanBackBuffer:boolean;
       function PresentVulkanBackBuffer:boolean;

       procedure SetScreen(const aScreen:TpvApplicationScreen);
       procedure SetNextScreen(const aNextScreen:TpvApplicationScreen);
       procedure SetNextScreenClass(const aNextScreenClass:TpvApplicationScreenClass);

       procedure UpdateFrameTimesHistory;

       procedure FramePacingAndFrameRateLimiter;

       procedure PollPresentTimingFeedback;
       procedure RecalibratePresentTimingDomains;
       procedure UpdatePresentTimingFeedbackProperties;
       procedure ComputePresentTimingTarget(var aTimingInfo:TVkPresentTimingInfoEXT);
       procedure InitializeLowLatencyMode;
       procedure ShutdownLowLatencyMode;
       procedure SetLowLatencyMarker(const aMarker:TVkLatencyMarkerNV);
       procedure LowLatencySleep;

       procedure UpdateJobFunction(const aJob:PPasMPJob;const aThreadIndex:TPasMPInt32);
       procedure DrawJobFunction(const aJob:PPasMPJob;const aThreadIndex:TPasMPInt32);

       procedure UpdateAudioHook;

       procedure AfterCreateSwapChainWithCheck;

       procedure BeforeDestroySwapChainWithCheck;

       function IsVisibleToUser:boolean;

       function WaitForReadyState:boolean;

       procedure DrawBlackScreen(const aSwapChainImageIndex:TpvInt32;var aWaitSemaphore:TpvVulkanSemaphore;const aWaitFence:TpvVulkanFence=nil); virtual;

       procedure ClearDelayedObjectsToFree;

       procedure ClearDelayedObjectsToFreeIteration;

       procedure ParseCommandLine;

       procedure ProcessOldPathNames;

      public

       constructor Create; reintroduce; virtual;
       destructor Destroy; override;

       class procedure Log(const aLevel:TpvInt32;const aWhere,aWhat:TpvUTF8String); static;

       procedure DelayFreeObjectInstance(const aObjectInstance:TObject;const aIterationsDelay:TpvInt32);

       procedure AddQueues; virtual;

       procedure ReadConfig; virtual;
       procedure SaveConfig; virtual;

       procedure PostRunnable(const aRunnable:TpvApplicationRunnable);

       procedure AddLifecycleListener(const aLifecycleListener:TpvApplicationLifecycleListener);
       procedure RemoveLifecycleListener(const aLifecycleListener:TpvApplicationLifecycleListener);

       function GetPercentileXthFrameTime(const aPercentileXth:TpvDouble):TpvDouble;

       function GetMedianFrameTime(const aTime:TpvDouble):TpvDouble;

       procedure Initialize;

       procedure Terminate;

       procedure ProcessRunnables;

       procedure ProcessMessages;

       procedure Run;

       procedure SetFocus;

       procedure SetupVulkanInstance(const aVulkanInstance:TpvVulkanInstance); virtual;

       procedure ChooseVulkanPhysicalDevice(var aVulkanPhysicalDevice:TpvVulkanPhysicalDevice); virtual;

       procedure SetupVulkanDevice(const aVulkanDevice:TpvVulkanDevice); virtual;

       procedure Setup; virtual;

       procedure Start; virtual;

       procedure Stop; virtual;

       procedure Load; virtual;

       procedure Unload; virtual;

       procedure Resume; virtual;

       procedure Pause; virtual;

       procedure LowMemory; virtual;

       procedure Resize(const aWidth,aHeight:TpvInt32); virtual;

       procedure AfterCreateSwapChain; virtual;

       procedure BeforeDestroySwapChain; virtual;

       function HandleEvent(const aEvent:TpvApplicationEvent):boolean; virtual;

       function KeyEvent(const aKeyEvent:TpvApplicationInputKeyEvent):boolean; virtual;

       function PointerEvent(const aPointerEvent:TpvApplicationInputPointerEvent):boolean; virtual;

       function Scrolled(const aRelativeAmount:TpvVector2):boolean; virtual;

       function DragDropFileEvent(aFileName:TpvUTF8String):boolean; virtual;

       function CanBeParallelProcessed:boolean; virtual;

       procedure Check(const aDeltaTime:TpvDouble); virtual; // example for VR input handling

       procedure Update(const aDeltaTime:TpvDouble); virtual;

       procedure BeginFrame(const aDeltaTime:TpvDouble); virtual;

       function IsReadyForDrawOfInFlightFrameIndex(const aInFlightFrameIndex:TpvInt32):boolean; virtual;

       function WaitForPreviousFrame(const aBlocking:Boolean=true):Boolean; virtual;

       procedure WaitForAllInFlightFrames;

       procedure Draw(const aSwapChainImageIndex:TpvInt32;var aWaitSemaphore:TpvVulkanSemaphore;const aWaitFence:TpvVulkanFence=nil); virtual;

       procedure FinishFrame(const aSwapChainImageIndex:TpvInt32;var aWaitSemaphore:TpvVulkanSemaphore;const aWaitFence:TpvVulkanFence=nil); virtual; // example for VR output handling of the rendered stereo images

       procedure PostPresent(const aSwapChainImageIndex:TpvInt32); virtual;

       procedure UpdateAudio; virtual;

       procedure DumpVulkanMemoryManager; virtual;

       function GetSupportedDisplayModes(const aDisplayIndex:TpvInt32=0):TpvApplicationDisplayModes;

       class procedure Main; virtual;

       property VulkanFrameBuffers:TpvVulkanSwapChainSimpleDirectRenderTargetFrameBuffers read fVulkanFrameBuffers;

      published

       property PasMPInstance:TPasMP read fPasMPInstance;

       property PasMPProfilerSuppressGaps:TPasMPBool32 read fPasMPProfilerSuppressGaps write fPasMPProfilerSuppressGaps;

       property PasMPProfilerVisibleTimePeriod:TPasMPHighResolutionTime read fPasMPProfilerVisibleTimePeriod write fPasMPProfilerVisibleTimePeriod;

      public

       property PasMPProfilerHistory:TPasMPProfilerHistory read fPasMPProfilerHistory write fPasMPProfilerHistory;

       property PasMPProfilerHistoryCount:TPasMPInt32 read fPasMPProfilerHistoryCount write fPasMPProfilerHistoryCount;

      published

       property HighResolutionTimer:TpvHighResolutionTimer read fHighResolutionTimer;

       property Assets:TpvApplicationAssets read fAssets;

       property Files:TpvApplicationFiles read fFiles;

       property Input:TpvApplicationInput read fInput;

       property Clipboard:TpvApplicationClipboard read fClipboard;

       property Audio:TpvAudio read fAudio;

       property ResourceManager:TpvResourceManager read fResourceManager;

       property Title:TpvUTF8String read fTitle write SetTitle;
       property Version:TpvUInt32 read fVersion write fVersion;

       property WindowTitle:TpvUTF8String read fWindowTitle write SetWindowTitle;

       property PathName:TpvUTF8String read fPathName write fPathName;
       property OldPathNames:TpvApplicationStringList read fOldPathNames;

       property SwapChainColorSpace:TpvApplicationSwapChainColorSpace read fSwapChainColorSpace write fSwapChainColorSpace;

       property SwapChainHDR:Boolean read fSwapChainHDR write fSwapChainHDR;

       property Width:TpvInt32 read fWidth write fWidth;
       property Height:TpvInt32 read fHeight write fHeight;

       property SkipNextDrawFrame:boolean read fSkipNextDrawFrame write fSkipNextDrawFrame;

       property FullScreenWidth:TpvInt32 read fFullScreenWidth write fFullScreenWidth;
       property FullScreenHeight:TpvInt32 read fFullScreenHeight write fFullScreenHeight;
       property FullScreenRefreshRate:TpvInt32 read fFullScreenRefreshRate write fFullScreenRefreshRate;

       property UseRealFullScreen:boolean read fUseRealFullScreen write fUseRealFullScreen;

       property Fullscreen:boolean read fFullScreen write fFullScreen;

       property Maximized:boolean read fMaximized write fMaximized;

       property ExclusiveFullScreenMode:TpvVulkanExclusiveFullScreenMode read fExclusiveFullScreenMode write fExclusiveFullScreenMode;

       property FullscreenFocusNeeded:boolean read fFullscreenFocusNeeded write fFullscreenFocusNeeded;

       property StayActiveRegardlessOfVisibility:boolean read fStayActiveRegardlessOfVisibility write fStayActiveRegardlessOfVisibility;

       property ReinitializeGraphics:boolean read fReinitializeGraphics write fReinitializeGraphics;

       property PresentMode:TpvApplicationPresentMode read fPresentMode write fPresentMode;

       property FramePacingMode:TpvApplicationFramePacingMode read fFramePacingMode write fFramePacingMode;

       property FramePacingStrategy:TpvApplicationFramePacingStrategy read fFramePacingStrategy write fFramePacingStrategy;

       property LowLatencyMode:TpvApplicationLowLatencyMode read fLowLatencyMode write fLowLatencyMode;
       property LowLatencyActive:boolean read fLowLatencyActive;
       property LowLatencyActiveMode:TpvApplicationLowLatencyMode read fLowLatencyActiveMode;
       property PresentTimingFeedbackRefreshMode:TpvApplicationPresentTimingFeedbackRefreshMode read fPresentTimingFeedbackRefreshMode;

       property PresentFrameLatency:TpvUInt64 read fPresentFrameLatency write fPresentFrameLatency;

       property PresentFrameLatencyMode:TpvApplicationPresentFrameLatencyMode read fPresentFrameLatencyMode write fPresentFrameLatencyMode;

       property ProcessingMode:TpvApplicationProcessingMode read fProcessingMode write fProcessingMode;

       property Resizable:boolean read fResizable write fResizable;

       property VisibleMouseCursor:boolean read fVisibleMouseCursor write fVisibleMouseCursor;

       property CatchMouseOnButton:boolean read fCatchMouseOnButton write fCatchMouseOnButton;

       property CatchMouse:boolean read fCatchMouse write fCatchMouse;

       property RelativeMouse:boolean read fRelativeMouse write fRelativeMouse;

       property HideSystemBars:boolean read fHideSystemBars write fHideSystemBars;

       property AcceptDragDropFiles:boolean read fAcceptDragDropFiles write fAcceptDragDropFiles;

       property UseBreadcrumbs:boolean read fUseBreadcrumbs write fUseBreadcrumbs;

       property ManualBreadcrumbs:boolean read fManualBreadcrumbs write fManualBreadcrumbs;

       property ManualSyncBreadcrumbs:boolean read fManualSyncBreadcrumbs write fManualSyncBreadcrumbs;

       property DisplayOrientations:TpvApplicationDisplayOrientations read fDisplayOrientations write fDisplayOrientations;

       property AndroidSeparateMouseAndTouch:boolean read GetAndroidSeparateMouseAndTouch write SetAndroidSeparateMouseAndTouch;

       property AndroidMouseTouchEvents:boolean read fAndroidMouseTouchEvents write fAndroidMouseTouchEvents;

       property AndroidTouchMouseEvents:boolean read fAndroidTouchMouseEvents write fAndroidTouchMouseEvents;

       property AndroidBlockOnPause:boolean read fAndroidBlockOnPause write fAndroidBlockOnPause;

       property AndroidTrapBackButton:boolean read fAndroidTrapBackButton write fAndroidTrapBackButton;

       property UseAudio:boolean read fUseAudio write fUseAudio;

       property Blocking:boolean read fBlocking write fBlocking;

       property UpdateWaitsForGPU:boolean read fUpdateWaitsForGPU write fUpdateWaitsForGPU;

       property UseExtraUpdateThread:boolean read fUseExtraUpdateThread write fUseExtraUpdateThread;

       property WaitOnPreviousFrames:boolean read fWaitOnPreviousFrames write fWaitOnPreviousFrames;

       property WaitOnPreviousFrame:boolean read fWaitOnPreviousFrame write fWaitOnPreviousFrame;

       property TerminationWithAltF4:boolean read fTerminationWithAltF4 write fTerminationWithAltF4;

       property TerminationOnQuitEvent:boolean read fTerminationOnQuitEvent write fTerminationOnQuitEvent;

       property BackgroundResourceLoaderFrameTimeout:TpvInt64 read fBackgroundResourceLoaderFrameTimeout write fBackgroundResourceLoaderFrameTimeout;

       property Debugging:boolean read fDebugging;

       property Active:boolean read fActive;

       property Terminated:boolean read fTerminated;

       property CountCPUThreads:TpvInt32 read fCountCPUThreads;

       property OnEvent:TpvApplicationOnEvent read fOnEvent write fOnEvent;
       property OnStep:TpvApplicationOnStep read fOnStep write fOnStep;

       property VulkanAPIVersion:TvkUInt32 read fVulkanAPIVersion write fVulkanAPIVersion;

       property VulkanPhysicalDeviceHandle:TVkPhysicalDevice read fVulkanPhysicalDeviceHandle write fVulkanPhysicalDeviceHandle;

       property VulkanRecreateSwapChainOnSuboptimalSurface:boolean read fVulkanRecreateSwapChainOnSuboptimalSurface write fVulkanRecreateSwapChainOnSuboptimalSurface;

       property VulkanDebugging:boolean read fVulkanDebugging write fVulkanDebugging;

       property VulkanShaderPrintfDebugging:boolean read fVulkanShaderPrintfDebugging write fVulkanShaderPrintfDebugging;

       property VulkanSynchronizationValidation:boolean read fVulkanSynchronizationValidation write fVulkanSynchronizationValidation;

       property VulkanValidation:boolean read fVulkanValidation write fVulkanValidation;

       property VulkanNVIDIAAfterMath:boolean read fVulkanNVIDIAAfterMath write fVulkanNVIDIAAfterMath;

       property VulkanNoUniqueObjectsValidation:boolean read fVulkanNoUniqueObjectsValidation write fVulkanNoUniqueObjectsValidation;

       property VulkanDebuggingEnabled:boolean read fVulkanDebuggingEnabled;

       property VulkanPreferDedicatedGPUs:boolean read fVulkanPreferDedicatedGPUs write fVulkanPreferDedicatedGPUs;

       property VulkanMultiviewSupportEnabled:boolean read fVulkanMultiviewSupportEnabled;

       property VulkanInstance:TpvVulkanInstance read fVulkanInstance;

       property VulkanDevice:TpvVulkanDevice read fVulkanDevice;

       property VulkanPipelineCache:TpvVulkanPipelineCache read fVulkanPipelineCache;

       property VulkanPipelineCacheFileName:TpvUTF8String read fVulkanPipelineCacheFileName write fVulkanPipelineCacheFileName;
{
       property VulkanUniversalCommandPools:TpvApplicationCommandPools read fVulkanUniversalCommandPools;
       property VulkanUniversalCommandBuffers:TpvApplicationCommandBuffers read fVulkanUniversalCommandBuffers;
       property VulkamUniversalCommandBufferFences:TpvApplicationCommandBufferFences read fVulkanUniversalCommandBufferFences;

       property VulkanPresentCommandPools:TpvApplicationCommandPools read fVulkanPresentCommandPools;
       property VulkanPresentCommandBuffers:TpvApplicationCommandBuffers read fVulkanPresentCommandBuffers;
       property VulkanPresentCommandBufferFences:TpvApplicationCommandBufferFences read fVulkanPresentCommandBufferFences;

       property VulkanGraphicsCommandPools:TpvApplicationCommandPools read fVulkanGraphicsCommandPools;
       property VulkanGraphicsCommandBuffers:TpvApplicationCommandBuffers read fVulkanGraphicsCommandBuffers;
       property VulkanGraphicsCommandBufferFences:TpvApplicationCommandBufferFences read fVulkanGraphicsCommandBufferFences;

       property VulkanComputeCommandPools:TpvApplicationCommandPools read fVulkanComputeCommandPools;
       property VulkanComputeCommandBuffers:TpvApplicationCommandBuffers read fVulkanComputeCommandBuffers;
       property VulkanComputeCommandBufferFences:TpvApplicationCommandBufferFences read fVulkanComputeCommandBufferFences;

       property VulkanTransferCommandPools:TpvApplicationCommandPools read fVulkanTransferCommandPools;
       property VulkanTransferCommandBuffers:TpvApplicationCommandBuffers read fVulkanTransferCommandBuffers;
       property VulkanTransferCommandBufferFences:TpvApplicationCommandBufferFences read fVulkanTransferCommandBufferFences;
 }

       property VulkanSwapChain:TpvVulkanSwapChain read fVulkanSwapChain;

       property VulkanTransferInFlightCommandsFromOldSwapChain:boolean read fVulkanTransferInFlightCommandsFromOldSwapChain write fVulkanTransferInFlightCommandsFromOldSwapChain;

       property VulkanDepthImageFormat:TVkFormat read fVulkanDepthImageFormat;

       property VulkanRenderPass:TpvVulkanRenderPass read fVulkanRenderPass;

       property VulkanNVIDIADiagnosticConfigExtensionFound:boolean read fVulkanNVIDIADiagnosticConfigExtensionFound;

       property VulkanNVIDIADiagnosticCheckPointsExtensionFound:boolean read fVulkanNVIDIADiagnosticCheckPointsExtensionFound;

       property StartScreen:TpvApplicationScreenClass read fStartScreen write fStartScreen;

       property Screen:TpvApplicationScreen read fScreen write SetScreen;

       property NextScreen:TpvApplicationScreen read fNextScreen write SetNextScreen;

       property NextScreenClass:TpvApplicationScreenClass read fNextScreenClass write SetNextScreenClass;

       property DeltaTime:TpvDouble read fFloatDeltaTime;

       property FramesPerSecond:TpvDouble read fFramesPerSecond;

       property TimingCPUUpdate:TpvDouble read fTimingCPUUpdate;

       property TimingCPUDraw:TpvDouble read fTimingCPUDraw;

       property TimingCPUBeginFrame:TpvDouble read fTimingCPUBeginFrame;

       property TimingCPUFinishFrame:TpvDouble read fTimingCPUFinishFrame;

       property TimingCPUAcquire:TpvDouble read fTimingCPUAcquire;

       property TimingCPUPresent:TpvDouble read fTimingCPUPresent;

       property TimingCPUFramePacing:TpvDouble read fTimingCPUFramePacing;

       property TimingCPUUpdateWait:TpvDouble read fTimingCPUUpdateWait;

       property TimingCPUUpdateStart:TpvDouble read fTimingCPUUpdateStart;

       property TimingCPUUpdateEnd:TpvDouble read fTimingCPUUpdateEnd;

       property TimingCPUDrawStart:TpvDouble read fTimingCPUDrawStart;

       property TimingCPUDrawEnd:TpvDouble read fTimingCPUDrawEnd;

       property MaximumFramesPerSecond:TpvDouble read fMaximumFramesPerSecond write fMaximumFramesPerSecond;

       property FrameCounter:TpvInt64 read fFrameCounter;

       property UpdateFrameCounter:TpvInt64 read fUpdateFrameCounter;

       property DrawFrameCounter:TpvInt64 read fDrawFrameCounter;

       property DesiredCountInFlightFrames:TpvInt32 read fDesiredCountInFlightFrames write SetDesiredCountInFlightFrames;

       property CountInFlightFrames:TpvInt32 read fCountInFlightFrames;

       property PreviousInFlightFrameIndex:TpvInt32 read fPreviousInFlightFrameIndex;

       property CurrentInFlightFrameIndex:TpvInt32 read fCurrentInFlightFrameIndex;

       property NextInFlightFrameIndex:TpvInt32 read fNextInFlightFrameIndex;

       property DrawInFlightFrameIndex:TpvInt32 read fDrawInFlightFrameIndex;

       property UpdateInFlightFrameIndex:TpvInt32 read fUpdateInFlightFrameIndex;

       property DesiredCountSwapChainImages:TpvInt32 read fDesiredCountSwapChainImages write SetDesiredCountSwapChainImages;

       property CountSwapChainImages:TpvInt32 read fCountSwapChainImages;

       property SwapChainImageCounterIndex:TpvInt32 read fSwapChainImageCounterIndex;

       property SwapChainImageIndex:TpvInt32 read fSwapChainImageIndex;

       property Universe:TObject read fUniverse write fUniverse;

     end;

const pvApplicationInputKeyModifierKeyShortcutMask:TpvApplicationInputKeyModifiers=
       [
        TpvApplicationInputKeyModifier.SHIFT,
        TpvApplicationInputKeyModifier.CTRL,
        TpvApplicationInputKeyModifier.ALT,
        TpvApplicationInputKeyModifier.META
       ];

var pvApplication:TpvApplication=nil;

    pvDebuggerPresent:Boolean=false;

    pvOutputLogLevel:TpvInt32=LOG_INFO;

{$if defined(Windows) and (defined(Debug) or not defined(Release))}
    pvStdOut:Windows.THandle=0;
    pvIsStdOutUTF8:Boolean=false;
{$ifend}

{$if defined(fpc) and defined(android)}
    AndroidJavaVM:PJavaVM=nil;
    AndroidJavaEnv:PJNIEnv=nil;
    AndroidJavaClass:jclass=nil;
    AndroidJavaObject:jobject=nil;

    AndroidActivity:PANativeActivity=nil;

    AndroidSavedState:TpvPointer=nil;
    AndroidSavedStateSize:TpvSizeUInt=0;

{$if defined(fpc) and defined(android) and (defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless))}
    AndroidAssetManagerObject:JObject=nil;
{$ifend}

    AndroidAssetManager:PAAssetManager=nil;

    AndroidInternalDataPath:TpvUTF8String='';
    AndroidExternalDataPath:TpvUTF8String='';
    AndroidLibraryPath:TpvUTF8String='';

    AndroidDeviceName:TpvUTF8String='';

function AndroidGetManufacturerName:TpvApplicationUnicodeString;
function AndroidGetModelName:TpvApplicationUnicodeString;
function AndroidGetDeviceName:TpvApplicationUnicodeString;
{$if defined(fpc) and defined(android) and (defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless))}
procedure AndroidGetAssetManager;
procedure AndroidReleaseAssetManager;
{$ifend}
//function Android_JNI_GetEnv:PJNIEnv; cdecl;

{$if not (defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless))}
procedure Android_ANativeActivity_onCreate(aActivity:PANativeActivity;aSavedState:pointer;aSavedStateSize:cuint32;const aApplicationClass:TpvApplicationClass);
{$ifend}

{$ifend}

{$if defined(Windows)}
function IsDebuggerPresent:LongBool; stdcall; external 'kernel32.dll' name 'IsDebuggerPresent';
{$else}
function IsDebuggerPresent:LongBool;
{$ifend}

{$if defined(fpc)}
function DumpExceptionCallStack(e:Exception;aAddr:Pointer=nil;aFrameCount:Longint=0;aFrames:PPointer=nil):string;
{$else}
function DumpExceptionCallStack(e:Exception):string;
{$ifend}

procedure LogCrash(const aExceptionString:String);

implementation

uses PasVulkan.Utils,PasDblStrUtils,PasVulkan.Compression,PasVulkan.PasMP;

const BoolToInt:array[boolean] of TpvInt32=(0,1);

      BoolToLongBool:array[boolean] of longbool=(false,true);

{$if not defined(PasVulkanHeadless)}
{$if defined(Windows) and not defined(PasVulkanUseSDL2)}
const Win32ClassName='PasVulkanWindow';

      Win32CursorMaskAND:TpvUInt8=$ff;
      Win32CursorMaskXOR:TpvUInt8=$00;

      PT_POINTER=1;
      PT_TOUCH=2;
      PT_PEN=3;
      PT_MOUSE=4;
      PT_TOUCHPAD=5;

      POINTER_MESSAGE_FLAG_NEW=$00000001;
      POINTER_MESSAGE_FLAG_INRANGE=$00000002;
      POINTER_MESSAGE_FLAG_INCONTACT=$00000004;
      POINTER_MESSAGE_FLAG_FIRSTBUTTON=$00000010;
      POINTER_MESSAGE_FLAG_SECONDBUTTON=$00000020;
      POINTER_MESSAGE_FLAG_THIRDBUTTON=$00000040;
      POINTER_MESSAGE_FLAG_FOURTHBUTTON=$00000080;
      POINTER_MESSAGE_FLAG_FIFTHBUTTON=$00000100;
      POINTER_MESSAGE_FLAG_PRIMARY=$00000200;
      POINTER_MESSAGE_FLAG_CONFIDENCE=$00000400;
      POINTER_MESSAGE_FLAG_CANCELED=$0000800;

      POINTER_FLAG_NONE=$00000000;
      POINTER_FLAG_NEW=$00000001;
      POINTER_FLAG_INRANGE=$00000002;
      POINTER_FLAG_INCONTACT=$00000004;
      POINTER_FLAG_FIRSTBUTTON=$00000010;
      POINTER_FLAG_SECONDBUTTON=$00000020;
      POINTER_FLAG_THIRDBUTTON=$00000040;
      POINTER_FLAG_FOURTHBUTTON=$00000080;
      POINTER_FLAG_FIFTHBUTTON=$00000100;
      POINTER_FLAG_PRIMARY=$00002000;
      POINTER_FLAG_CONFIDENCE=$00004000;
      POINTER_FLAG_CANCELED=$00008000;
      POINTER_FLAG_DOWN=$00010000;
      POINTER_FLAG_UPDATE=$00020000;
      POINTER_FLAG_UP=$00040000;
      POINTER_FLAG_WHEEL=$00080000;
      POINTER_FLAG_HWHEEL=$00100000;
      POINTER_FLAG_CAPTURECHANGED=$00200000;
      POINTER_FLAG_HASTRANSFORM=$00400000;

      POINTER_MOD_SHIFT=$0004;
      POINTER_MOD_CTRL=$0008;

      POINTER_CHANGE_NONE=0;
      POINTER_CHANGE_FIRSTBUTTON_DOWN=1;
      POINTER_CHANGE_FIRSTBUTTON_UP=2;
      POINTER_CHANGE_SECONDBUTTON_DOWN=3;
      POINTER_CHANGE_SECONDBUTTON_UP=4;
      POINTER_CHANGE_THIRDBUTTON_DOWN=5;
      POINTER_CHANGE_THIRDBUTTON_UP=6;
      POINTER_CHANGE_FOURTHBUTTON_DOWN=7;
      POINTER_CHANGE_FOURTHBUTTON_UP=8;
      POINTER_CHANGE_FIFTHBUTTON_DOWN=9;
      POINTER_CHANGE_FIFTHBUTTON_UP=10;

      TOUCH_FLAG_NONE=$00000000;

      TOUCH_MASK_NONE=$00000000;
      TOUCH_MASK_CONTACTAREA=$00000001;
      TOUCH_MASK_ORIENTATION=$00000002;
      TOUCH_MASK_PRESSURE=$00000004;

      PEN_FLAG_NONE=$00000000;
      PEN_FLAG_BARREL=$00000001;
      PEN_FLAG_INVERTED=$00000002;
      PEN_FLAG_ERASER=$00000004;

      PEN_MASK_NONE=$00000000;
      PEN_MASK_PRESSURE=$00000001;
      PEN_MASK_ROTATION=$00000002;
      PEN_MASK_TILT_X=$00000004;
      PEN_MASK_TILT_Y=$00000008;

      TWF_FINETOUCH=$00000001;
      TWF_WANTPALM=$00000002;

      WM_GESTURE=$00000119;
      WM_TOUCH=$00000240;
      WM_TOUCHMOVE=$00000240;
      WM_TOUCHDOWN=$00000241;
      WM_TOUCHUP=$00000242;
      WM_POINTERUPDATE=$00000245;
      WM_POINTERDOWN=$00000246;
      WM_POINTERUP=$00000247;
      WM_POINTERCAPTURECHANGED=$0000024c;
      WM_TABLET_QUERYSYSTEMGESTURESTATUS=$000002cc;

      TOUCHEVENTF_MOVE=$0001;
      TOUCHEVENTF_DOWN=$0002;
      TOUCHEVENTF_UP=$0004;
      TOUCHEVENTF_INRANGE=$0008;
      TOUCHEVENTF_PRIMARY=$0010;
      TOUCHEVENTF_NOCOALESCE=$0020;
      TOUCHEVENTF_PEN=$0040;
      TOUCHEVENTF_PALM=$0080;

var Win32WindowClass:TWNDCLASSW=(
     style:0;
     lpfnWndProc:nil;
     cbClsExtra:0;
     cbWndExtra:0;
     hInstance:0;
     hIcon:0;
     hCursor:0;
     hbrBackground:0;
     lpszMenuName:nil;
     lpszClassName:Win32ClassName;
    );

function RegisterTouchWindow(h:HWND;ulFlags:ULONG):BOOL; stdcall; external 'user32.dll' name 'RegisterTouchWindow';
function UnregisterTouchWindow(h:HWND):BOOL; stdcall; external 'user32.dll' name 'UnregisterTouchWindow';
function GetTouchInputInfo(hTouchInput:THANDLE;cInput:ULONG;pInputs:PpvApplicationTOUCHINPUT;cbSize:LONG):BOOL; stdcall; external 'user32.dll' name 'GetTouchInputInfo';
procedure CloseTouchInputHandle(hTouchInput:THANDLE); stdcall; external 'user32.dll' name 'CloseTouchInputHandle';

function SetPropA(h:HWND;p:LPCSTR;hData:THANDLE):BOOL; stdcall; external 'user32.dll' name 'SetPropA';
function SetPropW(h:HWND;p:LPWSTR;hData:THANDLE):BOOL; stdcall; external 'user32.dll' name 'SetPropW';

const XINPUT_DLL='xinput1_4.dll'; // >= Windows 8

const XINPUT_DEVTYPE_GAMEPAD=$01;

      XINPUT_DEVSUBTYPE_UNKNOWN=$00;
      XINPUT_DEVSUBTYPE_GAMEPAD=$01;
      XINPUT_DEVSUBTYPE_WHEEL=$02;
      XINPUT_DEVSUBTYPE_ARCADE_STICK=$03;
      XINPUT_DEVSUBTYPE_FLIGHT_STICK=$04;
      XINPUT_DEVSUBTYPE_DANCE_PAD=$05;
      XINPUT_DEVSUBTYPE_GUITAR=$06;
      XINPUT_DEVSUBTYPE_GUITAR_ALTERNATE=$07;
      XINPUT_DEVSUBTYPE_DRUM_KIT=$08;
      XINPUT_DEVSUBTYPE_GUITAR_BASS=$0b;
      XINPUT_DEVSUBTYPE_ARCADE_PAD=$13;

      XINPUT_CAPS_FFB_SUPPORTED=$0001;
      XINPUT_CAPS_WIRELESS=$0002;
      XINPUT_CAPS_VOICE_SUPPORTED=$0004;
      XINPUT_CAPS_PMD_SUPPORTED=$0008;
      XINPUT_CAPS_NO_NAVIGATION=$0010;

      XINPUT_GAMEPAD_DPAD_UP=$0001;
      XINPUT_GAMEPAD_DPAD_DOWN=$0002;
      XINPUT_GAMEPAD_DPAD_LEFT=$0004;
      XINPUT_GAMEPAD_DPAD_RIGHT=$0008;
      XINPUT_GAMEPAD_START=$0010;
      XINPUT_GAMEPAD_BACK=$0020;
      XINPUT_GAMEPAD_LEFT_THUMB=$0040;
      XINPUT_GAMEPAD_RIGHT_THUMB=$0080;
      XINPUT_GAMEPAD_LEFT_SHOULDER=$0100;
      XINPUT_GAMEPAD_RIGHT_SHOULDER=$0200;
      XINPUT_GAMEPAD_GUIDE=$0400;
      XINPUT_GAMEPAD_A=$1000;
      XINPUT_GAMEPAD_B=$2000;
      XINPUT_GAMEPAD_X=$4000;
      XINPUT_GAMEPAD_Y=$8000;

      XINPUT_GAMEPAD_LEFT_THUMB_DEADZONE=7849;
      XINPUT_GAMEPAD_RIGHT_THUMB_DEADZONE=8689;
      XINPUT_GAMEPAD_TRIGGER_THRESHOLD=30;

      XINPUT_FLAG_GAMEPAD=$00000001;

      XINPUT_BATTERY_DEVTYPE_GAMEPAD=$00;
      XINPUT_BATTERY_DEVTYPE_HEADSET=$01;

      XINPUT_BATTERY_TYPE_DISCONNECTED=$00;
      XINPUT_BATTERY_TYPE_WIRED=$01;
      XINPUT_BATTERY_TYPE_ALKALINE=$02;
      XINPUT_BATTERY_TYPE_NIMH=$03;
      XINPUT_BATTERY_TYPE_UNKNOWN=$ff;

      XINPUT_BATTERY_LEVEL_EMPTY=$00;
      XINPUT_BATTERY_LEVEL_LOW=$01;
      XINPUT_BATTERY_LEVEL_MEDIUM=$02;
      XINPUT_BATTERY_LEVEL_FULL=$03;

      XUSER_MAX_COUNT=4;

      XUSER_INDEX_ANY=$000000ff;

      XINPUT_VK_PAD_A=$5800;
      XINPUT_VK_PAD_B=$5801;
      XINPUT_VK_PAD_X=$5802;
      XINPUT_VK_PAD_Y=$5803;
      XINPUT_VK_PAD_RSHOULDER=$5804;
      XINPUT_VK_PAD_LSHOULDER=$5805;
      XINPUT_VK_PAD_LTRIGGER=$5806;
      XINPUT_VK_PAD_RTRIGGER=$5807;

      XINPUT_VK_PAD_DPAD_UP=$5810;
      XINPUT_VK_PAD_DPAD_DOWN=$5811;
      XINPUT_VK_PAD_DPAD_LEFT=$5812;
      XINPUT_VK_PAD_DPAD_RIGHT=$5813;
      XINPUT_VK_PAD_START=$5814;
      XINPUT_VK_PAD_BACK=$5815;
      XINPUT_VK_PAD_LTHUMB_PRESS=$5816;
      XINPUT_VK_PAD_RTHUMB_PRESS=$5817;

      XINPUT_VK_PAD_LTHUMB_UP=$5820;
      XINPUT_VK_PAD_LTHUMB_DOWN=$5821;
      XINPUT_VK_PAD_LTHUMB_RIGHT=$5822;
      XINPUT_VK_PAD_LTHUMB_LEFT=$5823;
      XINPUT_VK_PAD_LTHUMB_UPLEFT=$5824;
      XINPUT_VK_PAD_LTHUMB_UPRIGHT=$5825;
      XINPUT_VK_PAD_LTHUMB_DOWNRIGHT=$5826;
      XINPUT_VK_PAD_LTHUMB_DOWNLEFT=$5827;

      XINPUT_VK_PAD_RTHUMB_UP=$5830;
      XINPUT_VK_PAD_RTHUMB_DOWN=$5831;
      XINPUT_VK_PAD_RTHUMB_RIGHT=$5832;
      XINPUT_VK_PAD_RTHUMB_LEFT=$5833;
      XINPUT_VK_PAD_RTHUMB_UPLEFT=$5834;
      XINPUT_VK_PAD_RTHUMB_UPRIGHT=$5835;
      XINPUT_VK_PAD_RTHUMB_DOWNRIGHT=$5836;
      XINPUT_VK_PAD_RTHUMB_DOWNLEFT=$5837;

      XINPUT_KEYSTROKE_KEYDOWN=$0001;
      XINPUT_KEYSTROKE_KEYUP=$0002;
      XINPUT_KEYSTROKE_REPEAT=$0004;

type TXINPUT_GAMEPAD=record
      wButtons:TpvUInt16;
      bLeftTrigger:TpvUInt8;
      bRightTrigger:TpvUInt8;
      sThumbLX:TpvInt16;
      sThumbLY:TpvInt16;
      sThumbRX:TpvInt16;
      sThumbRY:TpvInt16;
     end;
     PXINPUT_GAMEPAD=^TXINPUT_GAMEPAD;

     TXINPUT_STATE=record
      dwPacketNumber:TpvUInt32;
      Gamepad:TXINPUT_GAMEPAD;
     end;
     PXINPUT_STATE=^TXINPUT_STATE;

     TXINPUT_VIBRATION=record
      wLeftMotorSpeed:TpvUInt16;
      wRightMotorSpeed:TpvUInt16;
     end;
     PXINPUT_VIBRATION=^TXINPUT_VIBRATION;

     TXINPUT_CAPABILITIES=record
      Type_:TpvUInt8;
      SubType:TpvUInt8;
      Flags:TpvUInt16;
      Gamepad:TXINPUT_GAMEPAD;
      Vibration:TXINPUT_VIBRATION;
     end;
     PXINPUT_CAPABILITIES=^TXINPUT_CAPABILITIES;

     TXINPUT_BATTERY_INFORMATION=record
      BatteryType:TpvUInt8;
      BatteryLevel:TpvUInt8;
     end;
     PXINPUT_BATTERY_INFORMATION=^TXINPUT_BATTERY_INFORMATION;

     TXINPUT_KEYSTROKE=record
      VirtualKey:TpvUInt16;
      Unicode:WCHAR;
      Flags:TpvUInt16;
      UserIndex:TpvUInt8;
      HidCode:TpvUInt8;
     end;
     PXINPUT_KEYSTROKE=^TXINPUT_KEYSTROKE;

function XInputGetState(dwUserIndex:TpvUInt32;pState:PXINPUT_STATE):TpvUInt32; {$ifdef cpu386}stdcall;{$endif} external XINPUT_DLL name 'XInputGetState';
function XInputSetState(dwUserIndex:TpvUInt32;pVibration:PXINPUT_VIBRATION):TpvUInt32; {$ifdef cpu386}stdcall;{$endif} external XINPUT_DLL name 'XInputSetState';
function XInputGetCapabilities(dwUserIndex,dwFlags:TpvUInt32;pCapabilities:PXINPUT_CAPABILITIES):TpvUInt32; {$ifdef cpu386}stdcall;{$endif} external XINPUT_DLL name 'XInputGetCapabilities';
procedure XInputEnable(Enable:BOOL); {$ifdef cpu386}stdcall;{$endif} external XINPUT_DLL name 'XInputEnable';
function XInputGetAudioDeviceIds(dwUserIndex:TpvUInt32;pRenderDeviceId:PLPWSTR;pRenderCount:PUINT;pCaptureDeviceId:PLPWSTR;pCaptureCount:PUINT):TpvUInt32; {$ifdef cpu386}stdcall;{$endif} external XINPUT_DLL name 'XInputGetAudioDeviceIds';
function XInputGetBatteryInformation(dwUserIndex:TpvUInt32;devType:TpvUInt8;pBatteryInformation:PXINPUT_BATTERY_INFORMATION):TpvUInt32; {$ifdef cpu386}stdcall;{$endif} external XINPUT_DLL name 'XInputGetBatteryInformation';
function XInputGetKeystroke(dwUserIndex,dwReserved:TpvUInt32;pKeystroke:PXINPUT_KEYSTROKE):TpvUInt32; {$ifdef cpu386}stdcall;{$endif} external XINPUT_DLL name 'XInputGetKeystroke';

type TGetPointerType=function(pointerId:TpvUInt32;pointerType:PpvApplicationPOINTER_INPUT_TYPE):BOOL; stdcall;
     TGetPointerTouchInfo=function(pointerId:TpvUInt32;touchInfo:PpvApplicationPOINTER_TOUCH_INFO):BOOL; stdcall;
     TGetPointerPenInfo=function(pointerId:TpvUInt32;penInfo:PpvApplicationPOINTER_PEN_INFO):BOOL; stdcall;
     TEnableMouseInPointer=function(fEnable:BOOL):BOOL; stdcall;

     TDPI_AWARENESS_CONTEXT=THandle;

     TPROCESS_DPI_AWARENESS=DWORD;

     TRtlGetNtVersionNumbers=procedure(out aMajor,aMinor,aBuild:DWORD); stdcall;
     TSetProcessDPIAware=function:bool; stdcall;
     TSetProcessDpiAwareness=function(const aValue:TPROCESS_DPI_AWARENESS):bool; stdcall;
     TSetProcessDpiAwarenessContext=function(const aValue:TDPI_AWARENESS_CONTEXT):bool; stdcall;
     TEnableNonClientDpiScaling=function(const aHWND:HWND):bool; stdcall;

var GetPointerType:TGetPointerType=nil;
    GetPointerTouchInfo:TGetPointerTouchInfo=nil;
    GetPointerPenInfo:TGetPointerPenInfo=nil;
    EnableMouseInPointer:TEnableMouseInPointer=nil;
    RtlGetNtVersionNumbers:TRtlGetNtVersionNumbers=nil;
    SetProcessDPIAware:TSetProcessDPIAware=nil;
    SetProcessDpiAwareness:TSetProcessDpiAwareness=nil;
    SetProcessDpiAwarenessContext:TSetProcessDpiAwarenessContext=nil;
    EnableNonClientDpiScaling:TEnableNonClientDpiScaling=nil;

    Win32HasGetPointer:boolean=false;

    WindowsVersionMajor:DWORD=0;
    WindowsVersionMinor:DWORD=0;
    WindowsVersionBuildNumber:DWORD=0;

const DPI_AWARENESS_CONTEXT_UNAWARE=TDPI_AWARENESS_CONTEXT(-1);
      DPI_AWARENESS_CONTEXT_SYSTEM_AWARE=TDPI_AWARENESS_CONTEXT(-2);
      DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE=TDPI_AWARENESS_CONTEXT(-3);
      DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2=TDPI_AWARENESS_CONTEXT(-4);

      PROCESS_DPI_UNAWARE=0;
      PROCESS_SYSTEM_DPI_AWARE=1;
      PROCESS_PER_MONITOR_DPI_AWARE=2;

{$ifend}
{$ifend}

{$if defined(fpc) and defined(Windows)}
//function IsDebuggerPresent:longbool; stdcall; external 'kernel32.dll' name 'IsDebuggerPresent';
{$ifend}

function GetDateTimeUTCOffset(const aWhen:TDateTime):TDateTime;
{$if defined(fpc) and declared(GetLocalTimeOffset)}
begin
 result:=GetLocalTimeOffset/1440.0;
end;
{$elseif defined(DelphiXE2AndUp) and declared(TTimeZone)}
begin
 result:=0.0;
 result:=result+TTimeZone.Local.GetUtcOffset(aWhen);
end;
{$else}
var SystemTimes:array[0..1] of TSystemTime;
    DateTimes:array[0..1] of TDateTime;
begin
{$if declared(GetUniversalTime)}
 GetUniversalTime(SystemTimes[0]);
{$else}
 GetSystemTime(SystemTimes[0]);
{$ifend}
 GetLocalTime(SystemTimes[1]);
 DateTimes[0]:=SystemTimeToDateTime(SystemTimes[0]);
 DateTimes[1]:=SystemTimeToDateTime(SystemTimes[1]);
 result:=MinutesBetween(DateTimes[0],DateTimes[1])/1440.0;
end;
{$ifend}

function DateTimeFromLocalTimeToUniversalTime(const aDateTime:TDateTime):TDateTime;
{$if defined(fpc) and declared(LocalTimeToUniversal)}
begin
 result:=LocalTimeToUniversal(aDateTime);
end;
{$elseif defined(DelphiXE2AndUp) and declared(TTimeZone)}
begin
 result:=TTimeZone.Local.ToUniversalTime(aDateTime);
end;
{$else}
begin
 result:=aDateTime+GetDateTimeUTCOffset(aDateTime);
end;
{$ifend}

function DateTimeFromUniversalTimeToLocalTime(const aDateTime:TDateTime):TDateTime;
{$if defined(fpc) and declared(LocalTimeToUniversal)}
begin
 result:=UniversalTimeToLocal(aDateTime);
end;
{$elseif defined(DelphiXE2AndUp) and declared(TTimeZone)}
begin
 result:=TTimeZone.Local.ToLocalTime(aDateTime);
end;
{$else}
begin
 result:=aDateTime-GetDateTimeUTCOffset(aDateTime);
end;
{$ifend}

{$if not declared(NowUTC)}
function NowUTC:TDateTime;
{$if defined(DelphiXE2AndUp)}
begin
 result:=TDateTime.NowUTC;
end;
{$else}
begin
 result:=DateTimeFromLocalTimeToUniversalTime(Now);
end;
{$ifend}
{$ifend}

{$if not declared(FileAgeUTC)}
function FileAgeUTC(const FileName:String;out FileDateTimeUTC:TDateTime;FollowLink:Boolean=True):Boolean;
begin
{$if defined(DelphiXE2AndUp)}
 result:=FileExists(FileName);
 if result then begin
  FileDateTimeUTC:=TFile.GetLastWriteTimeUtc(FileName);
 end;
{$else}
 result:=FileAge(FileName,FileDateTimeUTC{$ifdef fpc},FollowLink{$endif});
 if result then begin
  FileDateTimeUTC:=DateTimeFromLocalTimeToUniversalTime(FileDateTimeUTC);
 end;
{$ifend}
end;
{$ifend}

function DateTimeFromUnixTime(const aUnixTime:TpvInt64):TDateTime;
{$if declared(UnixToDateTime)}
begin
 result:=UnixToDateTime(aUnixTime);
end;
{$else}
begin
 result:=(TDateTime(aUnixTime)/86400.0)+25569.0;
end;
{$ifend}

function DateTimeToUnixTime(const aDateTime:TDateTime):TpvInt64;
{$if declared(DateTimeToUnix)}
begin
 result:=DateTimeToUnix(aDateTime);
end;
{$else}
begin
 result:=Trunc((aDateTime-25569.0)*86400.0);
end;
{$ifend}

{$if defined(fpc)}
function DumpExceptionCallStack(e:Exception;aAddr:Pointer;aFrameCount:Longint;aFrames:PPointer):string;
var i:int32;
    Frames:PPointer;
begin
 result:='Program exception! '+LineEnding+'Stack trace:'+LineEnding+LineEnding;
 if assigned(e) then begin
  result:=result+'Exception class: '+e.ClassName+LineEnding+'Message: '+e.Message+LineEnding;
 end;
 if assigned(aAddr) then begin
  result:=result+BackTraceStrFunc(aAddr);
 end else begin
  result:=result+BackTraceStrFunc(ExceptAddr);
 end;
 if assigned(aFrames) and (aFrameCount>0) then begin
  Frames:=aFrames;
  for i:=0 to aFrameCount-1 do begin
   result:=result+LineEnding+BackTraceStrFunc(Frames);
   inc(Frames);
  end;
 end else begin
  Frames:=ExceptFrames;
  for i:=0 to ExceptFrameCount-1 do begin
   result:=result+LineEnding+BackTraceStrFunc(Frames);
   inc(Frames);
  end;
 end;
end;
{$else}
function DumpExceptionCallStack(e:Exception):string;
const LineEnding={$ifdef Unix}#10{$else}#13#10{$endif};
var s:string;
begin
 result:='Program exception! '+LineEnding;
 if assigned(e) then begin
  result:=result+'Exception class: '+e.ClassName+LineEnding+'Message: '+e.Message+LineEnding;
  s:=e.StackTrace;
  if length(s)>0 then begin
   result:=result+s;
  end;
 end;
end;
{$ifend}

procedure LogCrash(const aExceptionString:String);
{$ifdef PasVulkanUseCrashLog}
var FileName:String;
    LogFile:TextFile;
{$endif}
begin
{$ifdef PasVulkanUseCrashLog}
 FileName:=ChangeFileExt(ParamStr(0),'.crashlog');
 if FileExists(FileName) then begin
  AssignFile(LogFile,FileName);
  Append(LogFile);
 end else begin
  AssignFile(LogFile,FileName);
  Rewrite(LogFile);
 end;
 WriteLn(LogFile);
 WriteLn(LogFile,'-----------------------------------------');
 WriteLn(LogFile);
 WriteLn(LogFile,DateTimeToStr(Now)+':');
 WriteLn(LogFile);
 WriteLn(LogFile,aExceptionString);
 WriteLn(LogFile);
 CloseFile(LogFile);
{$endif}
end;

{$if defined(Linux)}
function IsDebuggerPresent:LongBool;
var StatFile:TextFile;
    CurrentLine,Info:String;
begin
 AssignFile(StatFile,'/proc/self/status');
 Reset(StatFile);
 while not EOF(StatFile) do begin
  ReadLn(StatFile,CurrentLine);
  if Pos('TRACERPID:',UpperCase(CurrentLine))>0 then begin
   Info:=trim(Copy(CurrentLine,Pos(':',CurrentLine)+1,length(CurrentLine)));
   result:=Info<>'0';
   exit;
  end;
 end;
 CloseFile(StatFile);
 result:=false;
end;
{$elseif not defined(Windows)}
function IsDebuggerPresent:LongBool;
begin
 result:=false;
end;
{$ifend}

{$if defined(Unix)}
procedure signal_handler(aSignal:cint); cdecl;
begin
 case aSignal of
  SIGINT,SIGTERM,SIGKILL:begin
   if assigned(pvApplication) then begin
    pvApplication.Terminate;
   end;
  end;
 end;
end;

procedure InstallSignalHandlers;
begin
 fpsignal(SIGTERM,signal_handler);
 fpsignal(SIGINT,signal_handler);
 fpsignal(SIGHUP,signalhandler(SIG_IGN));
 fpsignal(SIGCHLD,signalhandler(SIG_IGN));
 fpsignal(SIGPIPE,signalhandler(SIG_IGN));
 fpsignal(SIGALRM,signalhandler(SIG_IGN));
 fpsignal(SIGWINCH,signalhandler(SIG_IGN));
end;
{$ifend}

{$ifdef unix}

function GetAppDataCacheStoragePath(Postfix:TpvApplicationRawByteString):TpvApplicationRawByteString;
{$ifdef darwin}
var TruePath:TpvApplicationRawByteString;
{$endif}
begin
{$ifdef darwin}
{$ifdef darwinsandbox}
 if DirectoryExists(IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(GetEnvironmentVariable('HOME'))+'Library')+'Containers') then begin
  if length(Postfix)>0 then begin
    TruePath:=IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(GetEnvironmentVariable('HOME'))+'Library')+'Containers')+Postfix;
   if not DirectoryExists(TruePath) then begin
    CreateDir(TruePath);
   end;
   result:=TruePath;
  end else begin
   result:=IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(GetEnvironmentVariable('HOME'))+'Library')+'Containers';
  end;
 end else{$endif} begin
  if length(Postfix)>0 then begin
   result:=IncludeTrailingPathDelimiter(GetEnvironmentVariable('HOME'))+'.'+Postfix;
   if not DirectoryExists(result) then begin
    TruePath:=IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(GetEnvironmentVariable('HOME'))+'Library')+'Engine Support')+Postfix;
    if not DirectoryExists(TruePath) then begin
     CreateDir(TruePath);
    end;
    if DirectoryExists(TruePath) then begin
     fpSymLink(PAnsiChar(TruePath),PAnsiChar(result));
    end else begin
     TruePath:=result;
    end;
    if not DirectoryExists(result) then begin
     CreateDir(result);
    end;
   end;
  end else begin
   result:=GetEnvironmentVariable('HOME');
   if DirectoryExists(result) then begin
    TruePath:=IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(result)+'Library')+'Application Support';
    if DirectoryExists(TruePath) then begin
     result:=TruePath;
    end;
   end;
  end;
 end;
 result:=IncludeTrailingPathDelimiter(result)+'cache';
 if not DirectoryExists(result) then begin
  CreateDir(result);
 end;
{$else}
 result:=GetEnvironmentVariable('XDG_CACHE_HOME');
 if (length(result)=0) or not DirectoryExists(result) then begin
  result:=GetEnvironmentVariable('HOME');
  if not DirectoryExists(result) then begin
   CreateDir(result);
  end;
  result:=IncludeTrailingPathDelimiter(result)+'.cache';
  if not DirectoryExists(result) then begin
   CreateDir(result);
  end;
 end;
 if length(Postfix)>0 then begin
  result:=IncludeTrailingPathDelimiter(result)+Postfix;
  if not DirectoryExists(result) then begin
   CreateDir(result);
  end;
 end;
 result:=IncludeTrailingPathDelimiter(result);
{$endif}
 result:=IncludeTrailingPathDelimiter(result);
end;

function GetAppDataLocalStoragePath(Postfix:TpvApplicationRawByteString):TpvApplicationRawByteString;
{$ifdef darwin}
var TruePath:TpvApplicationRawByteString;
{$endif}
begin
{$ifdef darwin}
{$ifdef darwinsandbox}
 if DirectoryExists(IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(GetEnvironmentVariable('HOME'))+'Library')+'Containers') then begin
  if length(Postfix)>0 then begin
   TruePath:=IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(GetEnvironmentVariable('HOME'))+'Library')+'Containers')+Postfix;
   if not DirectoryExists(TruePath) then begin
    CreateDir(TruePath);
   end;
   result:=TruePath;
  end else begin
   result:=IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(GetEnvironmentVariable('HOME'))+'Library')+'Containers';
  end;
 end else{$endif} begin
  if length(Postfix)>0 then begin
   result:=IncludeTrailingPathDelimiter(GetEnvironmentVariable('HOME'))+'.'+Postfix;
   if not DirectoryExists(result) then begin
    TruePath:=IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(GetEnvironmentVariable('HOME'))+'Library')+'Engine Support')+Postfix;
    if not DirectoryExists(TruePath) then begin
     CreateDir(TruePath);
    end;
    if DirectoryExists(TruePath) then begin
     fpSymLink(PAnsiChar(TruePath),PAnsiChar(result));
    end else begin
     TruePath:=result;
    end;
    if not DirectoryExists(result) then begin
     CreateDir(result);
    end;
   end;
  end else begin
   result:=GetEnvironmentVariable('HOME');
   if DirectoryExists(result) then begin
    TruePath:=IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(result)+'Library')+'Application Support';
    if DirectoryExists(TruePath) then begin
     result:=TruePath;
    end;
   end;
  end;
 end;
 result:=IncludeTrailingPathDelimiter(result)+'local';
 if not DirectoryExists(result) then begin
  CreateDir(result);
 end;
{$else}
 result:=GetEnvironmentVariable('XDG_DATA_HOME');
 if (length(result)=0) or not DirectoryExists(result) then begin
  result:=GetEnvironmentVariable('HOME');
  if not DirectoryExists(result) then begin
   CreateDir(result);
  end;
  result:=IncludeTrailingPathDelimiter(result)+'.local';
  if not DirectoryExists(result) then begin
   CreateDir(result);
  end;
  result:=IncludeTrailingPathDelimiter(result)+'share';
  if not DirectoryExists(result) then begin
   CreateDir(result);
  end;
 end;
 if length(Postfix)>0 then begin
  result:=IncludeTrailingPathDelimiter(result)+Postfix;
  if not DirectoryExists(result) then begin
   CreateDir(result);
  end;
 end;
{$endif}
 result:=IncludeTrailingPathDelimiter(result);
end;

function GetAppDataRoamingStoragePath(Postfix:TpvApplicationRawByteString):TpvApplicationRawByteString;
{$ifdef darwin}
var TruePath:TpvApplicationRawByteString;
{$endif}
begin
{$ifdef darwin}
{$ifdef darwinsandbox}
 if DirectoryExists(IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(GetEnvironmentVariable('HOME'))+'Library')+'Containers') then begin
  if length(Postfix)>0 then begin
   TruePath:=IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(GetEnvironmentVariable('HOME'))+'Library')+'Containers')+Postfix;
   if not DirectoryExists(TruePath) then begin
    CreateDir(TruePath);
   end;
   result:=TruePath;
  end else begin
   result:=IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(GetEnvironmentVariable('HOME'))+'Library')+'Containers';
  end;
 end else{$endif} begin
  if length(Postfix)>0 then begin
   result:=IncludeTrailingPathDelimiter(GetEnvironmentVariable('HOME'))+'.'+Postfix;
   if not DirectoryExists(result) then begin
    TruePath:=IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(GetEnvironmentVariable('HOME'))+'Library')+'Engine Support')+Postfix;
    if not DirectoryExists(TruePath) then begin
     CreateDir(TruePath);
    end;
    if DirectoryExists(TruePath) then begin
     fpSymLink(PAnsiChar(TruePath),PAnsiChar(result));
    end else begin
     TruePath:=result;
    end;
    if not DirectoryExists(result) then begin
     CreateDir(result);
    end;
   end;
  end else begin
   result:=GetEnvironmentVariable('HOME');
   if DirectoryExists(result) then begin
    TruePath:=IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(result)+'Library')+'Application Support';
    if DirectoryExists(TruePath) then begin
     result:=TruePath;
    end;
   end;
  end;
 end;
 result:=IncludeTrailingPathDelimiter(result)+'roaming';
 if not DirectoryExists(result) then begin
  CreateDir(result);
 end;
{$else}
 result:=GetEnvironmentVariable('XDG_CONFIG_HOME');
 if (length(result)=0) or not DirectoryExists(result) then begin
  result:=GetEnvironmentVariable('HOME');
  if not DirectoryExists(result) then begin
   CreateDir(result);
  end;
  result:=IncludeTrailingPathDelimiter(result)+'.config';
  if not DirectoryExists(result) then begin
   CreateDir(result);
  end;
 end;
 if length(Postfix)>0 then begin
  result:=IncludeTrailingPathDelimiter(result)+Postfix;
  if not DirectoryExists(result) then begin
   CreateDir(result);
  end;
 end;
{$endif}
 result:=IncludeTrailingPathDelimiter(result);
end;
{$else}
function ExpandEnvironmentStrings(const s:TpvApplicationRawByteString):TpvApplicationRawByteString;
var i:TpvInt32;
begin
 i:=ExpandEnvironmentStringsA(pansichar(s),nil,0);
 if i>0 then begin
  result:='';
  SetLength(result,i);
  ExpandEnvironmentStringsA(pansichar(s),pansichar(result),i);
  SetLength(result,i-1);
 end else begin
  result:='';
 end;
end;

function GetEnvironmentVariable(const s:TpvApplicationRawByteString):TpvApplicationRawByteString;
var i:TpvInt32;
begin
 i:=GetEnvironmentVariableA(pansichar(s),nil,0);
 if i>0 then begin
  result:='';
  SetLength(result,i);
  GetEnvironmentVariableA(pansichar(s),pansichar(result),i);
  SetLength(result,i-1);
 end else begin
  result:='';
 end;
end;

function GetAppDataCacheStoragePath(Postfix:string):string;
type TSHGetFolderPath=function(hwndOwner:hwnd;nFolder:TpvInt32;nToken:Windows.THandle;dwFlags:TpvInt32;lpszPath:PWideChar):hresult; stdcall;
     TSHGetKnownFolderPath=function(const rfid:TGUID;dwFlags:DWord;hToken:THandle;out ppszPath:PWideChar):HResult; stdcall;
const LocalLowGUID:TGUID='{A520A1A4-1780-4FF6-BD18-167343C5AF16}';
      CSIDL_LOCALAPPDATA=$001c;
var SHGetFolderPath:TSHGetFolderPath;
    SHGetKnownFolderPath:TSHGetKnownFolderPath;
    FilePath:PWideChar;
    LibHandle:Windows.THandle;
    Reg:TRegistry;
begin
 result:='';
 try
  // First try over the SHELL32.DLL from Windows >= Vista
  LibHandle:=LoadLibrary('SHELL32.DLL');
  if LibHandle<>0 then begin
   try
    SHGetKnownFolderPath:=GetProcAddress(LibHandle,'SHGetKnownFolderPath');
    FilePath:=nil;
    if assigned(SHGetKnownFolderPath) and
       (SHGetKnownFolderPath(LocalLowGUID,0,0,FilePath)>=0) then begin
     result:=String(WideString(FilePath));
    end;
   finally
    FreeLibrary(LibHandle);
   end;
  end;
  if length(result)=0 then begin
   // Other try over the SHFOLDER.DLL from MSIE >= 5.0 on Win9x or from Windows >= 2000
   LibHandle:=LoadLibrary('SHFOLDER.DLL');
   if LibHandle<>0 then begin
    try
     SHGetFolderPath:=GetProcAddress(LibHandle,'SHGetFolderPathW');
     GetMem(FilePath,4096*2);
     FillChar(FilePath^,4096*2,ansichar(#0));
     try
      if SHGetFolderPath(0,CSIDL_LOCALAPPDATA,0,0,FilePath)=0 then begin
       result:=String(WideString(FilePath));
       if (length(result)>0) and DirectoryExists(ExpandFileName(IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(result)+'..')+'LocalLow')) then begin
        result:=ExpandFileName(IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(result)+'..')+'LocalLow');
       end;
      end;
     finally
      FreeMem(FilePath);
     end;
    finally
     FreeLibrary(LibHandle);
    end;
   end;
  end;
 except
  result:='';
 end;
 if length(result)=0 then begin
  // Other try over the %localappdata% enviroment variable
  result:=String(GetEnvironmentVariable('localappdata'));
  if length(result)=0 then begin
   try
    // Again ather try over the windows registry
    Reg:=TRegistry.Create;
    try
     Reg.RootKey:=HKEY_CURRENT_USER;
     if Reg.OpenKeyReadOnly('Volatile Environment') then begin
      try
       try
        result:=Reg.ReadString('LOCALAPPDATA');
        if (length(result)>0) and DirectoryExists(ExpandFileName(IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(result)+'..')+'LocalLow')) then begin
         result:=ExpandFileName(IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(result)+'..')+'LocalLow');
        end;
       except
        result:='';
       end;
      finally
       Reg.CloseKey;
      end;
     end;
    finally
     Reg.Free;
    end;
   except
    result:='';
   end;
   if length(result)=0 then begin
    // Fallback for Win9x without SHFOLDER.DLL from MSIE >= 5.0
    result:=String(GetEnvironmentVariable('windir'));
    if length(result)>0 then begin
     // For german Win9x installations
     result:=IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(String(result))+'Lokale Einstellungen')+'Anwendungsdaten';
     if not DirectoryExists(String(result)) then begin
      // For all other language Win9x installations
      result:=IncludeTrailingPathDelimiter(String(result))+'Local Settings';
      if not DirectoryExists(String(result)) then begin
       result:=IncludeTrailingPathDelimiter(String(result))+'Engine Data';
       if not DirectoryExists(String(result)) then begin
        CreateDir(String(result));
       end;
      end;
     end;
    end else begin
     // Oops!!! So use simply our own program directory then!
     result:=ExtractFilePath(ParamStr(0));
    end;
   end;
  end;
 end;
 if length(Postfix)>0 then begin
  result:=String(IncludeTrailingPathDelimiter(String(result))+String(Postfix));
  if not DirectoryExists(String(result)) then begin
   CreateDir(String(result));
  end;
 end;
 result:=IncludeTrailingPathDelimiter(String(result));
end;

function GetAppDataLocalStoragePath(Postfix:string):string;
type TSHGetFolderPath=function(hwndOwner:hwnd;nFolder:TpvInt32;nToken:Windows.THandle;dwFlags:TpvInt32;lpszPath:PWideChar):hresult; stdcall;
const CSIDL_LOCALAPPDATA=$001c;
var SHGetFolderPath:TSHGetFolderPath;
    FilePath:PWideChar;
    LibHandle:Windows.THandle;
    Reg:TRegistry;
begin
 result:='';
 try
  // First try over the SHFOLDER.DLL from MSIE >= 5.0 on Win9x or from Windows >= 2000
  LibHandle:=LoadLibrary('SHFOLDER.DLL');
  if LibHandle<>0 then begin
   try
    SHGetFolderPath:=GetProcAddress(LibHandle,'SHGetFolderPathW');
    GetMem(FilePath,4096*2);
    FillChar(FilePath^,4096*2,ansichar(#0));
    try
     if SHGetFolderPath(0,CSIDL_LOCALAPPDATA,0,0,FilePath)=0 then begin
      result:=String(WideString(FilePath));
     end;
    finally
     FreeMem(FilePath);
    end;
   finally
    FreeLibrary(LibHandle);
   end;
  end;
 except
  result:='';
 end;
 if length(result)=0 then begin
   // Other try over the %localappdata% enviroment variable
  result:=String(GetEnvironmentVariable('localappdata'));
  if length(result)=0 then begin
   try
    // Again ather try over the windows registry
    Reg:=TRegistry.Create;
    try
     Reg.RootKey:=HKEY_CURRENT_USER;
     if Reg.OpenKeyReadOnly('Volatile Environment') then begin
      try
       try
        result:=Reg.ReadString('LOCALAPPDATA');
       except
        result:='';
       end;
      finally
       Reg.CloseKey;
      end;
     end;
    finally
     Reg.Free;
    end;
   except
    result:='';
   end;
   if length(result)=0 then begin
    // Fallback for Win9x without SHFOLDER.DLL from MSIE >= 5.0
    result:=String(GetEnvironmentVariable('windir'));
    if length(result)>0 then begin
     // For german Win9x installations
     result:=IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(String(result))+'Lokale Einstellungen')+'Anwendungsdaten';
     if not DirectoryExists(String(result)) then begin
      // For all other language Win9x installations
      result:=IncludeTrailingPathDelimiter(String(result))+'Local Settings';
      if not DirectoryExists(String(result)) then begin
       result:=IncludeTrailingPathDelimiter(String(result))+'Engine Data';
       if not DirectoryExists(String(result)) then begin
        CreateDir(String(result));
       end;
      end;
     end;
    end else begin
     // Oops!!! So use simply our own program directory then!
     result:=ExtractFilePath(ParamStr(0));
    end;
   end;
  end;
 end;
 if length(Postfix)>0 then begin
  result:=String(IncludeTrailingPathDelimiter(String(result))+String(Postfix));
  if not DirectoryExists(String(result)) then begin
   CreateDir(String(result));
  end;
 end;
 result:=IncludeTrailingPathDelimiter(String(result));
end;

function GetAppDataRoamingStoragePath(Postfix:string):string;
type TSHGetFolderPath=function(hwndOwner:hwnd;nFolder:TpvInt32;nToken:Windows.THandle;dwFlags:TpvInt32;lpszPath:PWideChar):hresult; stdcall;
const CSIDL_APPDATA=$001a;
var SHGetFolderPath:TSHGetFolderPath;
    FilePath:PWideChar;
    LibHandle:Windows.THandle;
    Reg:TRegistry;
begin
 result:='';
 try
  // First try over the SHFOLDER.DLL from MSIE >= 5.0 on Win9x or from Windows >= 2000
  LibHandle:=LoadLibrary('SHFOLDER.DLL');
  if LibHandle<>0 then begin
   try
    SHGetFolderPath:=GetProcAddress(LibHandle,'SHGetFolderPathW');
    GetMem(FilePath,4096*2);
    FillChar(FilePath^,4096*2,ansichar(#0));
    try
     if SHGetFolderPath(0,CSIDL_APPDATA,0,0,FilePath)=0 then begin
      result:=String(WideString(FilePath));
     end;
    finally
     FreeMem(FilePath);
    end;
   finally
    FreeLibrary(LibHandle);
   end;
  end;
 except
  result:='';
 end;
 if length(result)=0 then begin
   // Other try over the %appdata% enviroment variable
  result:=String(GetEnvironmentVariable('appdata'));
  if length(result)=0 then begin
   try
    // Again ather try over the windows registry
    Reg:=TRegistry.Create;
    try
     Reg.RootKey:=HKEY_CURRENT_USER;
     if Reg.OpenKeyReadOnly('Volatile Environment') then begin
      try
       try
        result:=Reg.ReadString('APPDATA');
       except
        result:='';
       end;
      finally
       Reg.CloseKey;
      end;
     end;
    finally
     Reg.Free;
    end;
   except
    result:='';
   end;
   if length(result)=0 then begin
    // Fallback for Win9x without SHFOLDER.DLL from MSIE >= 5.0
    result:=String(GetEnvironmentVariable('windir'));
    if length(result)>0 then begin
     // For german Win9x installations
     result:=IncludeTrailingPathDelimiter(String(result))+'Anwendungsdaten';
     if not DirectoryExists(String(result)) then begin
      // For all other language Win9x installations
      result:=IncludeTrailingPathDelimiter(String(result))+'Engine Data';
      if not DirectoryExists(String(result)) then begin
       CreateDir(String(result));
      end;
     end;
    end else begin
     // Oops!!! So use simply our own program directory then!
     result:=ExtractFilePath(ParamStr(0));
    end;
   end;
  end;
 end;
 if length(Postfix)>0 then begin
  result:=String(IncludeTrailingPathDelimiter(String(result))+String(Postfix));
  if not DirectoryExists(String(result)) then begin
   CreateDir(String(result));
  end;
 end;
 result:=IncludeTrailingPathDelimiter(String(result));
end;
{$endif}

constructor EpvApplication.Create(const aTag,aMessage:string;const aLogLevel:TpvInt32=LOG_NONE);
begin
 inherited Create(aMessage);
 fTag:=aTag;
 fLogLevel:=aLogLevel;
end;

destructor EpvApplication.Destroy;
begin
 fTag:='';
 inherited Destroy;
end;

constructor TpvApplicationInputKey.Create(const aKeyCode:TpvInt32;
                                          const aScanCode:TpvInt32;
                                          const aKeyModifiers:TpvApplicationInputKeyModifiers);
begin
 KeyCode:=aKeyCode;
 ScanCode:=aScanCode;
 KeyModifiers:=aKeyModifiers;
end;

constructor TpvApplicationInputKeyShortcut.Create(const aApplication:TpvApplication;
                                                  const aKeyCode:TpvInt32;
                                                  const aScanCode:TpvInt32;
                                                  const aKeyModifiers:TpvApplicationInputKeyModifiers);
begin
 inherited Create;
 fApplication:=aApplication;
 fKey:=TpvApplicationInputKey.Create(aKeyCode,aScanCode,aKeyModifiers);
 fKeyActions:=TpvApplicationInputKeyActions.Create(false);
end;

destructor TpvApplicationInputKeyShortcut.Destroy;
begin
 FreeAndNil(fKeyActions);
 inherited Destroy;
end;

procedure TpvApplicationInputKeyShortcut.AfterConstruction;
var Action:TpvApplicationInputKeyAction;
begin
 inherited AfterConstruction;
 for Action in fKeyActions do begin
  if Action.fKeyShortcuts.IndexOf(self)<0 then begin
   Action.fKeyShortcuts.Add(self);
  end;
 end;
end;

procedure TpvApplicationInputKeyShortcut.BeforeDestruction;
var Index:TpvInt32;
    Action:TpvApplicationInputKeyAction;
begin
 for Action in fKeyActions do begin
  Index:=Action.fKeyShortcuts.IndexOf(self);
  if Index>=0 then begin
   Action.fKeyShortcuts.Delete(Index);
  end;
 end;
 inherited BeforeDestruction;
end;

procedure TpvApplicationInputKeyShortcut.AddKeyAction(const aAction:TpvApplicationInputKeyAction);
begin
 if fKeyActions.IndexOf(aAction)<0 then begin
  fKeyActions.Add(aAction);
  if aAction.fKeyShortcuts.IndexOf(self)<0 then begin
   aAction.fKeyShortcuts.Add(self);
  end;
 end;
end;

procedure TpvApplicationInputKeyShortcut.RemoveKeyAction(const aAction:TpvApplicationInputKeyAction);
var Index:TpvInt32;
begin
 Index:=fKeyActions.IndexOf(aAction);
 if Index>=0 then begin
  fKeyActions.Delete(Index);
  Index:=aAction.fKeyShortcuts.IndexOf(self);
  if Index>=0 then begin
   aAction.fKeyShortcuts.Delete(Index);
  end;
 end;
end;

function TpvApplicationInputKeyShortcut.HasKeyAction(const aAction:TpvApplicationInputKeyAction):boolean;
begin
 result:=fKeyActions.IndexOf(aAction)>=0;
end;

constructor TpvApplicationInputKeyAction.Create(const aApplication:TpvApplication;
                                                const aName:TpvUTF8String;
                                                const aDescription:TpvUTF8String);
begin
 inherited Create;
 fApplication:=aApplication;
 fID:=0;
 fName:=aName;
 fDescription:=aDescription;
 fKeyShortcuts:=TpvApplicationInputKeyShortcuts.Create(false);
end;

destructor TpvApplicationInputKeyAction.Destroy;
begin
 FreeAndNil(fKeyShortcuts);
 inherited Destroy;
end;

procedure TpvApplicationInputKeyAction.AfterConstruction;
var Shortcut:TpvApplicationInputKeyShortcut;
begin
 inherited AfterConstruction;
 for Shortcut in fKeyShortcuts do begin
  if Shortcut.fKeyActions.IndexOf(self)<0 then begin
   Shortcut.fKeyActions.Add(self);
  end;
 end;
end;

procedure TpvApplicationInputKeyAction.BeforeDestruction;
var Index:TpvInt32;
    Shortcut:TpvApplicationInputKeyShortcut;
begin
 for Shortcut in fKeyShortcuts do begin
  Index:=Shortcut.fKeyActions.IndexOf(self);
  if Index>=0 then begin
   Shortcut.fKeyActions.Delete(Index);
  end;
 end;
 inherited BeforeDestruction;
end;

procedure TpvApplicationInputKeyAction.AddKeyShortcut(const aShortcut:TpvApplicationInputKeyShortcut);
begin
 if fKeyShortcuts.IndexOf(aShortcut)<0 then begin
  fKeyShortcuts.Add(aShortcut);
  if aShortcut.fKeyActions.IndexOf(self)<0 then begin
   aShortcut.fKeyActions.Add(self);
  end;
 end;
end;

procedure TpvApplicationInputKeyAction.RemoveKeyShortcut(const aShortcut:TpvApplicationInputKeyShortcut);
var Index:TpvInt32;
begin
 Index:=fKeyShortcuts.IndexOf(aShortcut);
 if Index>=0 then begin
  fKeyShortcuts.Delete(Index);
  Index:=aShortcut.fKeyActions.IndexOf(self);
  if Index>=0 then begin
   aShortcut.fKeyActions.Delete(Index);
  end;
 end;
end;

function TpvApplicationInputKeyAction.HasKeyShortcut(const aShortcut:TpvApplicationInputKeyShortcut):boolean;
begin
 result:=fKeyShortcuts.IndexOf(aShortcut)>=0;
end;

constructor TpvApplicationInputKeyEvent.Create(const aKeyEventType:TpvApplicationInputKeyEventType;
                                               const aKeyCode:TpvInt32;
                                               const aScanCode:TpvInt32;
                                               const aKeyModifiers:TpvApplicationInputKeyModifiers;
                                               const aKeyShortcut:TpvApplicationInputKeyShortcut);
begin
 KeyEventType:=aKeyEventType;
 KeyCode:=aKeyCode;
 ScanCode:=aScanCode;
 KeyModifiers:=aKeyModifiers;
 KeyShortcut:=aKeyShortcut;
end;

constructor TpvApplicationInputPointerEvent.Create(const aPointerEventType:TpvApplicationInputPointerEventType;
                                                   const aPosition:TpvVector2;
                                                   const aPressure:TpvFloat;
                                                   const aPointerID:TpvInt32;
                                                   const aButton:TpvApplicationInputPointerButton;
                                                   const aButtons:TpvApplicationInputPointerButtons;
                                                   const aKeyModifiers:TpvApplicationInputKeyModifiers);
begin
 PointerEventType:=aPointerEventType;
 Position:=aPosition;
 Pressure:=aPressure;
 PointerID:=aPointerID;
 Button:=aButton;
 Buttons:=aButtons;
 KeyModifiers:=aKeyModifiers;
end;

constructor TpvApplicationInputPointerEvent.Create(const aPointerEventType:TpvApplicationInputPointerEventType;
                                                   const aPosition:TpvVector2;
                                                   const aRelativePosition:TpvVector2;
                                                   const aPressure:TpvFloat;
                                                   const aPointerID:TpvInt32;
                                                   const aButtons:TpvApplicationInputPointerButtons;
                                                   const aKeyModifiers:TpvApplicationInputKeyModifiers);
begin
 PointerEventType:=aPointerEventType;
 Position:=aPosition;
 RelativePosition:=aRelativePosition;
 Pressure:=aPressure;
 PointerID:=aPointerID;
 Buttons:=aButtons;
 KeyModifiers:=aKeyModifiers;
end;

constructor TpvApplicationInputProcessor.Create;
begin
end;

destructor TpvApplicationInputProcessor.Destroy;
begin
end;

function TpvApplicationInputProcessor.KeyEvent(const aKeyEvent:TpvApplicationInputKeyEvent):boolean;
begin
 result:=false;
end;

function TpvApplicationInputProcessor.PointerEvent(const aPointerEvent:TpvApplicationInputPointerEvent):boolean;
begin
 result:=false;
end;

function TpvApplicationInputProcessor.Scrolled(const aRelativeAmount:TpvVector2):boolean;
begin
 result:=false;
end;

function TpvApplicationInputProcessor.DragDropFileEvent(aFileName:TpvUTF8String):boolean;
begin
 result:=false;
end;

constructor TpvApplicationInputProcessorQueue.Create;
begin
 inherited Create;
 fProcessor:=nil;
 fCriticalSection:=TPasMPCriticalSection.Create;
 fQueuedEvents:=nil;
 fLastQueuedEvent:=nil;
 fFreeEvents:=nil;
 fCurrentEventTime:=0;
end;

destructor TpvApplicationInputProcessorQueue.Destroy;
var CurrentEvent,NextEvent:PpvApplicationInputProcessorQueueEvent;
begin
 CurrentEvent:=fQueuedEvents;
 while assigned(CurrentEvent) do begin
  NextEvent:=CurrentEvent^.Next;
  Finalize(CurrentEvent^);
  FreeMem(CurrentEvent);
  CurrentEvent:=NextEvent;
 end;
 CurrentEvent:=fFreeEvents;
 while assigned(CurrentEvent) do begin
  NextEvent:=CurrentEvent^.Next;
  Finalize(CurrentEvent^);
  FreeMem(CurrentEvent);
  CurrentEvent:=NextEvent;
 end;
 FreeAndNil(fCriticalSection);
 inherited Destroy;
end;

function TpvApplicationInputProcessorQueue.NewEvent:PpvApplicationInputProcessorQueueEvent;
begin
 if assigned(fFreeEvents) then begin
  result:=fFreeEvents;
  fFreeEvents:=result^.Next;
  result^.Next:=nil;
  result^.Event:=EVENT_NONE;
 end else begin
  GetMem(result,SizeOf(TpvApplicationInputProcessorQueueEvent));
  FillChar(result^,SizeOf(TpvApplicationInputProcessorQueueEvent),AnsiChar(#0));
 end;
 Initialize(result^);
 result^.Time:=pvApplication.fHighResolutionTimer.GetTime;
end;

procedure TpvApplicationInputProcessorQueue.FreeEvent(const aEvent:PpvApplicationInputProcessorQueueEvent);
begin
 if assigned(aEvent) then begin
  Finalize(aEvent^);
  FreeMem(aEvent);
 end;
end;

procedure TpvApplicationInputProcessorQueue.PushEvent(const aEvent:PpvApplicationInputProcessorQueueEvent);
begin
 if assigned(fLastQueuedEvent) then begin
  fLastQueuedEvent^.Next:=aEvent;
 end else begin
  fQueuedEvents:=aEvent;
 end;
 fLastQueuedEvent:=aEvent;
 aEvent^.Next:=nil;
end;

procedure TpvApplicationInputProcessorQueue.SetProcessor(aProcessor:TpvApplicationInputProcessor);
begin
 fProcessor:=aProcessor;
end;

function TpvApplicationInputProcessorQueue.GetProcessor:TpvApplicationInputProcessor;
begin
 result:=fProcessor;
end;

procedure TpvApplicationInputProcessorQueue.Drain;
var Events,LastQueuedEvent,CurrentEvent,NextEvent:PpvApplicationInputProcessorQueueEvent;
begin
 fCriticalSection.Acquire;
 try
  Events:=fQueuedEvents;
  LastQueuedEvent:=fLastQueuedEvent;
  fQueuedEvents:=nil;
  fLastQueuedEvent:=nil;
 finally
  fCriticalSection.Release;
 end;
 CurrentEvent:=Events;
 while assigned(CurrentEvent) do begin
  NextEvent:=CurrentEvent^.Next;
  fCurrentEventTime:=CurrentEvent^.Time;
  if assigned(fProcessor) then begin
   case CurrentEvent^.Event of
    EVENT_KEY:begin
     fProcessor.KeyEvent(CurrentEvent^.KeyEvent);
    end;
    EVENT_POINTER:begin
     fProcessor.PointerEvent(CurrentEvent^.PointerEvent);
    end;
    EVENT_SCROLLED:begin
     fProcessor.Scrolled(CurrentEvent^.RelativeAmount);
    end;
    EVENT_DRAGDROPFILE:begin
     try
      fProcessor.DragDropFileEvent(CurrentEvent^.StringData);
     finally
      CurrentEvent^.StringData:='';
     end;
    end;
   end;
  end;
  FreeEvent(CurrentEvent);
  CurrentEvent:=NextEvent;
 end;
end;

function TpvApplicationInputProcessorQueue.GetCurrentEventTime:TpvInt64;
begin
 result:=fCurrentEventTime;
end;

function TpvApplicationInputProcessorQueue.KeyEvent(const aKeyEvent:TpvApplicationInputKeyEvent):boolean;
var Event:PpvApplicationInputProcessorQueueEvent;
begin
 result:=false;
 fCriticalSection.Acquire;
 try
  Event:=NewEvent;
  if assigned(Event) then begin
   Event^.Event:=EVENT_KEY;
   Event^.KeyEvent:=aKeyEvent;
   PushEvent(Event);
  end;
 finally
  fCriticalSection.Release;
 end;
end;

function TpvApplicationInputProcessorQueue.PointerEvent(const aPointerEvent:TpvApplicationInputPointerEvent):boolean;
var Event:PpvApplicationInputProcessorQueueEvent;
begin
 result:=false;
 fCriticalSection.Acquire;
 try
  Event:=NewEvent;
  if assigned(Event) then begin
   Event^.Event:=EVENT_POINTER;
   Event^.PointerEvent:=aPointerEvent;
   PushEvent(Event);
  end;
 finally
  fCriticalSection.Release;
 end;
end;

function TpvApplicationInputProcessorQueue.Scrolled(const aRelativeAmount:TpvVector2):boolean;
var Event:PpvApplicationInputProcessorQueueEvent;
begin
 result:=false;
 fCriticalSection.Acquire;
 try
  Event:=NewEvent;
  if assigned(Event) then begin
   Event^.Event:=EVENT_SCROLLED;
   Event^.RelativeAmount:=aRelativeAmount;
   PushEvent(Event);
  end;
 finally
  fCriticalSection.Release;
 end;
end;

function TpvApplicationInputProcessorQueue.DragDropFileEvent(aFileName:TpvUTF8String):boolean;
var Event:PpvApplicationInputProcessorQueueEvent;
begin
 result:=false;
 fCriticalSection.Acquire;
 try
  Event:=NewEvent;
  if assigned(Event) then begin
   Event^.Event:=EVENT_DRAGDROPFILE;
   Event^.StringData:=aFileName;
   PushEvent(Event);
  end;
 finally
  fCriticalSection.Release;
 end;
end;

constructor TpvApplicationInputMultiplexer.Create;
begin
 inherited Create;
 fProcessors:=TList.Create;
end;

destructor TpvApplicationInputMultiplexer.Destroy;
begin
 FreeAndNil(fProcessors);
 inherited Destroy;
end;

procedure TpvApplicationInputMultiplexer.AddProcessor(const aProcessor:TpvApplicationInputProcessor);
begin
 fProcessors.Add(aProcessor);
end;

procedure TpvApplicationInputMultiplexer.AddProcessors(const aProcessors:array of TpvApplicationInputProcessor);
var i:TpvInt32;
begin
 for i:=0 to length(aProcessors)-1 do begin
  fProcessors.Add(aProcessors[i]);
 end;
end;

procedure TpvApplicationInputMultiplexer.InsertProcessor(const aIndex:TpvInt32;const aProcessor:TpvApplicationInputProcessor);
begin
 fProcessors.Insert(aIndex,aProcessor);
end;

procedure TpvApplicationInputMultiplexer.RemoveProcessor(const aProcessor:TpvApplicationInputProcessor);
begin
 fProcessors.Remove(aProcessor);
end;

procedure TpvApplicationInputMultiplexer.RemoveProcessor(const aIndex:TpvInt32);
begin
 fProcessors.Delete(aIndex);
end;

procedure TpvApplicationInputMultiplexer.ClearProcessors;
begin
 fProcessors.Clear;
end;

function TpvApplicationInputMultiplexer.CountProcessors:TpvInt32;
begin
 result:=fProcessors.Count;
end;

function TpvApplicationInputMultiplexer.KeyEvent(const aKeyEvent:TpvApplicationInputKeyEvent):boolean;
var i:TpvInt32;
    p:TpvApplicationInputProcessor;
begin
 result:=false;
 for i:=0 to fProcessors.Count-1 do begin
  p:=fProcessors.Items[i];
  if assigned(p) and p.KeyEvent(aKeyEvent) then begin
   result:=true;
   exit;
  end;
 end;
end;

function TpvApplicationInputMultiplexer.PointerEvent(const aPointerEvent:TpvApplicationInputPointerEvent):boolean;
var i:TpvInt32;
    p:TpvApplicationInputProcessor;
begin
 result:=false;
 for i:=0 to fProcessors.Count-1 do begin
  p:=fProcessors.Items[i];
  if assigned(p) and p.PointerEvent(aPointerEvent) then begin
   result:=true;
   exit;
  end;
 end;
end;

function TpvApplicationInputMultiplexer.Scrolled(const aRelativeAmount:TpvVector2):boolean;
var i:TpvInt32;
    p:TpvApplicationInputProcessor;
begin
 result:=false;
 for i:=0 to fProcessors.Count-1 do begin
  p:=fProcessors.Items[i];
  if assigned(p) then begin
   if p.Scrolled(aRelativeAmount) then begin
    result:=true;
    exit;
   end;
  end;
 end;
end;

function TpvApplicationInputMultiplexer.DragDropFileEvent(aFileName:TpvUTF8String):boolean;
var i:TpvInt32;
    p:TpvApplicationInputProcessor;
begin
 result:=false;
 for i:=0 to fProcessors.Count-1 do begin
  p:=fProcessors.Items[i];
  if assigned(p) then begin
   if p.DragDropFileEvent(aFileName) then begin
    result:=true;
    exit;
   end;
  end;
 end;
end;

{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
constructor TpvApplicationJoystick.Create(const aID:TpvInt64;const aJoystick:PSDL_Joystick;const aGameController:PSDL_GameController);
begin
 inherited Create;
 fJoystick:=aJoystick;
 fGameController:=aGameController;
 fID:=aID;
end;
{$elseif defined(Windows) and not defined(PasVulkanHeadless)}
constructor TpvApplicationJoystick.Create(const aID:TpvInt64);
begin
 inherited Create;
 fJoystick:=aID;
 fID:=fJoystick;
 GetMem(fState,SizeOf(TXINPUT_STATE));
 fWin32GameInputDevice:=nil;
end;
{$else}
constructor TpvApplicationJoystick.Create(const aID:TpvInt64);
begin
 inherited Create;
 fID:=aID;
end;
{$ifend}

destructor TpvApplicationJoystick.Destroy;
begin
{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
 if assigned(fGameController) then begin
  SDL_GameControllerClose(fGameController);
 end else if assigned(fJoystick) then begin
  SDL_JoystickClose(fJoystick);
 end;
{$elseif (defined(Windows) and not defined(PasVulkanHeadless))}
 if assigned(fState) then begin
  try
   FreeMem(fState);
  finally
   fState:=nil;
  end;
 end;
 fWin32GameInputDevice:=nil;
{$ifend}
 inherited Destroy;
end;

procedure TpvApplicationJoystick.Initialize;
{$if defined(Windows) and not (defined(PasVulkanUseSDL2) or defined(PasVulkanHeadless))}
var GameInputDeviceInfo:PGameInputDeviceInfo;
{$ifend}
begin
{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
 fCountAxes:=SDL_JoystickNumAxes(fJoystick);
 fCountBalls:=SDL_JoystickNumBalls(fJoystick);
 fCountHats:=SDL_JoystickNumHats(fJoystick);
 fCountButtons:=SDL_JoystickNumButtons(fJoystick);
{$elseif defined(Windows) and not defined(PasVulkanHeadless)}
 if assigned(fWin32GameInputDevice) then begin
  fWin32GameInputDeviceName:='';
  FillChar(fWin32GameInputDeviceGUID,SizeOf(TGUID),#0);
  GameInputDeviceInfo:=fWin32GameInputDevice.GetDeviceInfo;
  if assigned(GameInputDeviceInfo) then begin
   if assigned(GameInputDeviceInfo^.displayName) then begin
    SetString(fWin32GameInputDeviceName,GameInputDeviceInfo^.displayName^.data,GameInputDeviceInfo^.displayName^.sizeInBytes);
   end;
   if length(fWin32GameInputDeviceName)=0 then begin
    fWin32GameInputDeviceName:='GameInput device';
   end;
   fWin32GameInputDeviceGUID.D1:=(TpvUInt32(GameInputDeviceInfo.revisionNumber) shl 16) or
                                 (TpvUInt32(GameInputDeviceInfo.interfaceNumber) shl 8) or
                                 (TpvUInt32(GameInputDeviceInfo.collectionNumber) shl 0);
   fWin32GameInputDeviceGUID.D2:=GameInputDeviceInfo.vendorId;
   fWin32GameInputDeviceGUID.D3:=GameInputDeviceInfo.productId;
   fWin32GameInputDeviceGUID.D4[0]:=GameInputDeviceInfo.deviceId.value[0];
   fWin32GameInputDeviceGUID.D4[1]:=GameInputDeviceInfo.deviceId.value[1];
   fWin32GameInputDeviceGUID.D4[2]:=GameInputDeviceInfo.deviceId.value[2];
   fWin32GameInputDeviceGUID.D4[3]:=GameInputDeviceInfo.deviceId.value[3];
   fWin32GameInputDeviceGUID.D4[4]:=GameInputDeviceInfo.deviceId.value[4];
   fWin32GameInputDeviceGUID.D4[5]:=GameInputDeviceInfo.deviceId.value[5];
   fWin32GameInputDeviceGUID.D4[6]:=GameInputDeviceInfo.deviceId.value[6];
   fWin32GameInputDeviceGUID.D4[7]:=GameInputDeviceInfo.deviceId.value[7];
   fCountAxes:=GameInputDeviceInfo^.controllerAxisCount;
   fCountBalls:=0;
   fCountHats:=GameInputDeviceInfo^.controllerSwitchCount;
   fCountButtons:=GameInputDeviceInfo^.controllerButtonCount;
  end else begin
   fCountAxes:=0;
   fCountBalls:=0;
   fCountHats:=0;
   fCountButtons:=0;
  end;
 end else if fJoystick<XUSER_MAX_COUNT then begin
  // The XInput API has a hard coded button/axis mapping, so we just match it
  fCountAxes:=6;
  fCountBalls:=0;
  fCountHats:=1;
  fCountButtons:=11;
 end else begin
  if joyGetDevCapsW(fJoystick-XUSER_MAX_COUNT,@fJoyCaps,SizeOf(TJOYCAPSW))=MMSYSERR_NOERROR then begin
   fCountAxes:=fJoyCaps.wMaxAxes;
   fCountBalls:=0;
   fCountHats:=1;
   fCountButtons:=fJoyCaps.wMaxButtons;
  end else begin
   fCountAxes:=0;
   fCountBalls:=0;
   fCountHats:=0;
   fCountButtons:=0;
  end;
 end;
{$ifend}
end;

function TpvApplicationJoystick.IsGameController:boolean;
{$if (defined(Windows) and not (defined(PasVulkanUseSDL2) or defined(PasVulkanHeadless)))}
var Capabilities:TXINPUT_CAPABILITIES;
{$ifend}
begin
{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
 result:=assigned(fGameController);
{$elseif defined(Windows) and not defined(PasVulkanHeadless)}
 if assigned(fWin32GameInputDevice) then begin
  result:=true;
 end else if (fJoystick<XUSER_MAX_COUNT) and (XInputGetCapabilities(fJoystick,0,@Capabilities)=ERROR_SUCCESS) then begin
  result:=Capabilities.SubType=XINPUT_DEVSUBTYPE_GAMEPAD;
 end else begin
  result:=false;
 end;
{$else}
 result:=false;
{$ifend}
end;

function TpvApplicationJoystick.Index:TpvInt32;
begin
 result:=pvApplication.Input.fJoysticks.IndexOf(self);
end;

function TpvApplicationJoystick.ID:TpvInt32;
begin
{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
 result:=SDL_JoystickInstanceID(fJoystick);
{$elseif defined(Windows) and not defined(PasVulkanHeadless)}
 result:=fJoystick;
{$else}
 result:=0;
{$ifend}
end;

function TpvApplicationJoystick.Name:TpvApplicationRawByteString;
begin
{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
 result:=SDL_JoystickName(fJoystick);
{$elseif defined(Windows) and not defined(PasVulkanHeadless)}
 if assigned(fWin32GameInputDevice) then begin
  result:=fWin32GameInputDeviceName;
 end else if fJoystick<XUSER_MAX_COUNT then begin
  result:='XInput'+IntToStr(fJoystick);
 end else begin
  result:=PUCUUTF16ToUTF8(PWideChar(@fJoyCaps.szPname[0]));
 end;
{$else}
 result:='';
{$ifend}
end;

function TpvApplicationJoystick.GUID:TGUID;
begin
{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
 result:=SDL_JoystickGetGUID(fJoystick);
{$elseif defined(Windows) and not defined(PasVulkanHeadless)}
 if assigned(fWin32GameInputDevice) then begin
  result:=fWin32GameInputDeviceGUID;
 end else begin
  FillChar(result,SizeOf(TGUID),#0);
  if fJoystick<XUSER_MAX_COUNT then begin
   result.D1:=TpvUInt32($10000000) or fJoystick;
  end else begin
   result.D1:=TpvUInt32($20000000) or (fJoystick-XUSER_MAX_COUNT);
   result.D2:=fJoyCaps.wMid;
   result.D3:=fJoyCaps.wPid;
  end;
 end;
{$else}
 FillChar(result,SizeOf(TGUID),#0);
{$ifend}
end;

function TpvApplicationJoystick.DeviceGUID:TGUID;
begin
{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
 result:=SDL_JoystickGetDeviceGUID(fJoystick);
{$elseif defined(Windows) and not defined(PasVulkanHeadless)}
 if assigned(fWin32GameInputDevice) then begin
  result:=fWin32GameInputDeviceGUID;
 end else begin
  FillChar(result,SizeOf(TGUID),#0);
  if fJoystick<XUSER_MAX_COUNT then begin
   result.D1:=TpvUInt32($10000000) or fJoystick;
  end else begin
   result.D1:=TpvUInt32($20000000) or (fJoystick-XUSER_MAX_COUNT);
   result.D2:=fJoyCaps.wMid;
   result.D3:=fJoyCaps.wPid;
  end;
 end;
{$else}
 FillChar(result,SizeOf(TGUID),#0);
{$ifend}
end;

function TpvApplicationJoystick.CountAxes:TpvInt32;
begin
 result:=fCountAxes;
end;

function TpvApplicationJoystick.CountBalls:TpvInt32;
begin
 result:=fCountBalls;
end;

function TpvApplicationJoystick.CountHats:TpvInt32;
begin
 result:=fCountHats;
end;

function TpvApplicationJoystick.CountButtons:TpvInt32;
begin
 result:=fCountButtons;
end;

procedure TpvApplicationJoystick.Update;
{$if defined(Windows) and not (defined(PasVulkanUseSDL2) or defined(PasVulkanHeadless))}
var GameInputReading:IGameInputReading;
    GameInputGamepadState:TGameInputGamepadState;
{$ifend}
begin
{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
 SDL_JoystickUpdate;
{$elseif not defined(PasVulkanHeadless)}
 fAxes[0]:=0.0;
 fAxes[1]:=0.0;
 fAxes[2]:=0.0;
 fAxes[3]:=0.0;
 fAxes[4]:=0.0;
 fAxes[5]:=0.0;
 fButtons:=0;
 fHats:=0;
{$if defined(Windows) and not defined(PasVulkanHeadless)}
 if assigned(fWin32GameInputDevice) then begin
  GameInputReading:=nil;
  try
   if pvApplication.fWin32GameInput.GetCurrentReading(GameInputKindGamepad,fWin32GameInputDevice,GameInputReading)=NO_ERROR then begin
    if GameInputReading.GetGamepadState(@GameInputGamepadState) then begin
     fAxes[GAME_CONTROLLER_AXIS_LEFTX]:=GameInputGamepadState.leftThumbstickX;
     fAxes[GAME_CONTROLLER_AXIS_LEFTY]:=-GameInputGamepadState.leftThumbstickY;
     fAxes[GAME_CONTROLLER_AXIS_RIGHTX]:=GameInputGamepadState.rightThumbstickX;
     fAxes[GAME_CONTROLLER_AXIS_RIGHTY]:=-GameInputGamepadState.rightThumbstickY;
     fAxes[GAME_CONTROLLER_AXIS_TRIGGERLEFT]:=GameInputGamepadState.leftTrigger;
     fAxes[GAME_CONTROLLER_AXIS_TRIGGERRIGHT]:=GameInputGamepadState.rightTrigger;
     if (GameInputGamepadState.buttons and GameInputGamepadA)<>0 then begin
      fButtons:=fButtons or (TpvUInt32(1) shl GAME_CONTROLLER_BUTTON_A);
     end;
     if (GameInputGamepadState.buttons and GameInputGamepadB)<>0 then begin
      fButtons:=fButtons or (TpvUInt32(1) shl GAME_CONTROLLER_BUTTON_B);
     end;
     if (GameInputGamepadState.buttons and GameInputGamepadX)<>0 then begin
      fButtons:=fButtons or (TpvUInt32(1) shl GAME_CONTROLLER_BUTTON_X);
     end;
     if (GameInputGamepadState.buttons and GameInputGamepadY)<>0 then begin
      fButtons:=fButtons or (TpvUInt32(1) shl GAME_CONTROLLER_BUTTON_Y);
     end;
     if (GameInputGamepadState.buttons and GameInputGamepadMenu)<>0 then begin
      fButtons:=fButtons or (TpvUInt32(1) shl GAME_CONTROLLER_BUTTON_BACK);
     end;
     if (GameInputGamepadState.buttons and GameInputGamepadView)<>0 then begin
      fButtons:=fButtons or (TpvUInt32(1) shl GAME_CONTROLLER_BUTTON_START);
     end;
     if (GameInputGamepadState.buttons and GameInputGamepadLeftThumbstick)<>0 then begin
      fButtons:=fButtons or (TpvUInt32(1) shl GAME_CONTROLLER_BUTTON_LEFTSTICK);
     end;
     if (GameInputGamepadState.buttons and GameInputGamepadRightThumbstick)<>0 then begin
      fButtons:=fButtons or (TpvUInt32(1) shl GAME_CONTROLLER_BUTTON_RIGHTSTICK);
     end;
     if (GameInputGamepadState.buttons and GameInputGamepadLeftShoulder)<>0 then begin
      fButtons:=fButtons or (TpvUInt32(1) shl GAME_CONTROLLER_BUTTON_LEFTSHOULDER);
     end;
     if (GameInputGamepadState.buttons and GameInputGamepadRightShoulder)<>0 then begin
      fButtons:=fButtons or (TpvUInt32(1) shl GAME_CONTROLLER_BUTTON_RIGHTSHOULDER);
     end;
     if (GameInputGamepadState.buttons and GameInputGamepadDPadUp)<>0 then begin
      fButtons:=fButtons or (TpvUInt32(1) shl GAME_CONTROLLER_BUTTON_DPAD_UP);
      fHats:=fHats or JOYSTICK_HAT_UP;
     end;
     if (GameInputGamepadState.buttons and GameInputGamepadDPadDown)<>0 then begin
      fButtons:=fButtons or (TpvUInt32(1) shl GAME_CONTROLLER_BUTTON_DPAD_DOWN);
      fHats:=fHats or JOYSTICK_HAT_DOWN;
     end;
     if (GameInputGamepadState.buttons and GameInputGamepadDPadLeft)<>0 then begin
      fButtons:=fButtons or (TpvUInt32(1) shl GAME_CONTROLLER_BUTTON_DPAD_LEFT);
      fHats:=fHats or JOYSTICK_HAT_LEFT;
     end;
     if (GameInputGamepadState.buttons and GameInputGamepadDPadRight)<>0 then begin
      fButtons:=fButtons or (TpvUInt32(1) shl GAME_CONTROLLER_BUTTON_DPAD_RIGHT);
      fHats:=fHats or JOYSTICK_HAT_RIGHT;
     end;
    end;
   end;
  finally
   GameInputReading:=nil;
  end;
 end else if fJoystick<XUSER_MAX_COUNT then begin
  if XInputGetState(fJoystick,fState)=ERROR_SUCCESS then begin
   fAxes[GAME_CONTROLLER_AXIS_LEFTX]:=Min(Max(PXINPUT_STATE(fState)^.Gamepad.sThumbLX/32767.0,-1.0),1.0);
   fAxes[GAME_CONTROLLER_AXIS_LEFTY]:=Min(Max(TpvInt16(not PXINPUT_STATE(fState)^.Gamepad.sThumbLY)/32767.0,-1.0),1.0);
   fAxes[GAME_CONTROLLER_AXIS_RIGHTX]:=Min(Max(PXINPUT_STATE(fState)^.Gamepad.sThumbRX/32767.0,-1.0),1.0);
   fAxes[GAME_CONTROLLER_AXIS_RIGHTY]:=Min(Max(TpvInt16(not PXINPUT_STATE(fState)^.Gamepad.sThumbRY)/32767.0,-1.0),1.0);
   fAxes[GAME_CONTROLLER_AXIS_TRIGGERLEFT]:=Min(Max(PXINPUT_STATE(fState)^.Gamepad.bLeftTrigger/255.0,0.0),1.0);
   fAxes[GAME_CONTROLLER_AXIS_TRIGGERRIGHT]:=Min(Max(PXINPUT_STATE(fState)^.Gamepad.bRightTrigger/255.0,0.0),1.0);
   if (PXINPUT_STATE(fState)^.Gamepad.wButtons and XINPUT_GAMEPAD_A)<>0 then begin
    fButtons:=fButtons or (TpvUInt32(1) shl GAME_CONTROLLER_BUTTON_A);
   end;
   if (PXINPUT_STATE(fState)^.Gamepad.wButtons and XINPUT_GAMEPAD_B)<>0 then begin
    fButtons:=fButtons or (TpvUInt32(1) shl GAME_CONTROLLER_BUTTON_B);
   end;
   if (PXINPUT_STATE(fState)^.Gamepad.wButtons and XINPUT_GAMEPAD_X)<>0 then begin
    fButtons:=fButtons or (TpvUInt32(1) shl GAME_CONTROLLER_BUTTON_X);
   end;
   if (PXINPUT_STATE(fState)^.Gamepad.wButtons and XINPUT_GAMEPAD_Y)<>0 then begin
    fButtons:=fButtons or (TpvUInt32(1) shl GAME_CONTROLLER_BUTTON_Y);
   end;
   if (PXINPUT_STATE(fState)^.Gamepad.wButtons and XINPUT_GAMEPAD_BACK)<>0 then begin
    fButtons:=fButtons or (TpvUInt32(1) shl GAME_CONTROLLER_BUTTON_BACK);
   end;
   if (PXINPUT_STATE(fState)^.Gamepad.wButtons and XINPUT_GAMEPAD_GUIDE)<>0 then begin
    fButtons:=fButtons or (TpvUInt32(1) shl GAME_CONTROLLER_BUTTON_GUIDE);
   end;
   if (PXINPUT_STATE(fState)^.Gamepad.wButtons and XINPUT_GAMEPAD_START)<>0 then begin
    fButtons:=fButtons or (TpvUInt32(1) shl GAME_CONTROLLER_BUTTON_START);
   end;
   if (PXINPUT_STATE(fState)^.Gamepad.wButtons and XINPUT_GAMEPAD_LEFT_THUMB)<>0 then begin
    fButtons:=fButtons or (TpvUInt32(1) shl GAME_CONTROLLER_BUTTON_LEFTSTICK);
   end;
   if (PXINPUT_STATE(fState)^.Gamepad.wButtons and XINPUT_GAMEPAD_RIGHT_THUMB)<>0 then begin
    fButtons:=fButtons or (TpvUInt32(1) shl GAME_CONTROLLER_BUTTON_RIGHTSTICK);
   end;
   if (PXINPUT_STATE(fState)^.Gamepad.wButtons and XINPUT_GAMEPAD_LEFT_SHOULDER)<>0 then begin
    fButtons:=fButtons or (TpvUInt32(1) shl GAME_CONTROLLER_BUTTON_LEFTSHOULDER);
   end;
   if (PXINPUT_STATE(fState)^.Gamepad.wButtons and XINPUT_GAMEPAD_RIGHT_SHOULDER)<>0 then begin
    fButtons:=fButtons or (TpvUInt32(1) shl GAME_CONTROLLER_BUTTON_RIGHTSHOULDER);
   end;
   if (PXINPUT_STATE(fState)^.Gamepad.wButtons and XINPUT_GAMEPAD_DPAD_UP)<>0 then begin
    fButtons:=fButtons or (TpvUInt32(1) shl GAME_CONTROLLER_BUTTON_DPAD_UP);
    fHats:=fHats or JOYSTICK_HAT_UP;
   end;
   if (PXINPUT_STATE(fState)^.Gamepad.wButtons and XINPUT_GAMEPAD_DPAD_DOWN)<>0 then begin
    fButtons:=fButtons or (TpvUInt32(1) shl GAME_CONTROLLER_BUTTON_DPAD_DOWN);
    fHats:=fHats or JOYSTICK_HAT_DOWN;
   end;
   if (PXINPUT_STATE(fState)^.Gamepad.wButtons and XINPUT_GAMEPAD_DPAD_LEFT)<>0 then begin
    fButtons:=fButtons or (TpvUInt32(1) shl GAME_CONTROLLER_BUTTON_DPAD_LEFT);
    fHats:=fHats or JOYSTICK_HAT_LEFT;
   end;
   if (PXINPUT_STATE(fState)^.Gamepad.wButtons and XINPUT_GAMEPAD_DPAD_RIGHT)<>0 then begin
    fButtons:=fButtons or (TpvUInt32(1) shl GAME_CONTROLLER_BUTTON_DPAD_RIGHT);
    fHats:=fHats or JOYSTICK_HAT_RIGHT;
   end;
  end;
 end else begin
  fJoyInfoEx.dwSize:=SizeOf(TJoyInfoEx);
  fJoyInfoEx.dwFlags:=JOY_RETURNALL;
  if joyGetPosEx(fJoystick-XUSER_MAX_COUNT,@fJoyInfoEx)=JOYERR_NOERROR then begin
   if CountAxes>0 then begin
    fAxes[0]:=((fJoyInfoEx.wXpos-fJoyCaps.wXmin)*(2.0/(fJoyCaps.wXmax-fJoyCaps.wXmin)))-1.0;
   end else begin
    fAxes[0]:=0;
   end;
   if CountAxes>1 then begin
    fAxes[1]:=-(((fJoyInfoEx.wYpos-fJoyCaps.wYmin)*(2.0/(fJoyCaps.wYmax-fJoyCaps.wYmin)))-1.0);
   end else begin
    fAxes[1]:=0;
   end;
   if CountAxes>2 then begin
    fAxes[2]:=((fJoyInfoEx.wZpos-fJoyCaps.wZmin)*(2.0/(fJoyCaps.wZmax-fJoyCaps.wZmin)))-1.0;
   end else begin
    fAxes[2]:=0;
   end;
   if CountAxes>3 then begin
    fAxes[3]:=-(((fJoyInfoEx.dwRpos-fJoyCaps.wRmin)*(2.0/(fJoyCaps.wRmax-fJoyCaps.wRmin)))-1.0);
   end else begin
    fAxes[3]:=0;
   end;
   if CountAxes>4 then begin
    fAxes[4]:=((fJoyInfoEx.dwUpos-fJoyCaps.wUmin)*(2.0/(fJoyCaps.wUmax-fJoyCaps.wUmin)))-1.0;
   end else begin
    fAxes[4]:=0;
   end;
   if CountAxes>5 then begin
    fAxes[5]:=((fJoyInfoEx.dwVpos-fJoyCaps.wVmin)*(2.0/(fJoyCaps.wVmax-fJoyCaps.wVmin)))-1.0;
   end else begin
    fAxes[5]:=0;
   end;
   case fJoyInfoEx.dwPOV of
    0..2249:begin // 0
     fHats:=JOYSTICK_HAT_UP;
    end;
    2250..6749:begin // 4500
     fHats:=JOYSTICK_HAT_RIGHTUP;
    end;
    6750..11249:begin // 9000
     fHats:=JOYSTICK_HAT_RIGHT;
    end;
    11250..15749:begin // 13500
     fHats:=JOYSTICK_HAT_RIGHTDOWN;
    end;
    15750..20249:begin // 18000
     fHats:=JOYSTICK_HAT_DOWN;
    end;
    20250..24749:begin // 22500
     fHats:=JOYSTICK_HAT_LEFTDOWN;
    end;
    24750..29249:begin // 27000
     fHats:=JOYSTICK_HAT_LEFT;
    end;
    29250..33749:begin // 31500
     fHats:=JOYSTICK_HAT_LEFTUP;
    end;
    33750..35999:begin // 0
     fHats:=JOYSTICK_HAT_UP;
    end;
    else begin
     fHats:=JOYSTICK_HAT_CENTERED;
    end;
   end;
   if (fJoyInfoEx.wButtons and (TpvUInt32(1) shl 0))<>0 then begin
    fButtons:=fButtons or (TpvUInt32(1) shl GAME_CONTROLLER_BUTTON_A);
   end;
   if (fJoyInfoEx.wButtons and (TpvUInt32(1) shl 1))<>0 then begin
    fButtons:=fButtons or (TpvUInt32(1) shl GAME_CONTROLLER_BUTTON_B);
   end;
   if (fJoyInfoEx.wButtons and (TpvUInt32(1) shl 2))<>0 then begin
    fButtons:=fButtons or (TpvUInt32(1) shl GAME_CONTROLLER_BUTTON_X);
   end;
   if (fJoyInfoEx.wButtons and (TpvUInt32(1) shl 3))<>0 then begin
    fButtons:=fButtons or (TpvUInt32(1) shl GAME_CONTROLLER_BUTTON_Y);
   end;
   if (fJoyInfoEx.wButtons and (TpvUInt32(1) shl 4))<>0 then begin
    fButtons:=fButtons or (TpvUInt32(1) shl GAME_CONTROLLER_BUTTON_BACK);
   end;
   if (fJoyInfoEx.wButtons and (TpvUInt32(1) shl 5))<>0 then begin
    fButtons:=fButtons or (TpvUInt32(1) shl GAME_CONTROLLER_BUTTON_GUIDE);
   end;
   if (fJoyInfoEx.wButtons and (TpvUInt32(1) shl 6))<>0 then begin
    fButtons:=fButtons or (TpvUInt32(1) shl GAME_CONTROLLER_BUTTON_START);
   end;
   if (fJoyInfoEx.wButtons and (TpvUInt32(1) shl 7))<>0 then begin
    fButtons:=fButtons or (TpvUInt32(1) shl GAME_CONTROLLER_BUTTON_LEFTSTICK);
   end;
   if (fJoyInfoEx.wButtons and (TpvUInt32(1) shl 8))<>0 then begin
    fButtons:=fButtons or (TpvUInt32(1) shl GAME_CONTROLLER_BUTTON_RIGHTSTICK);
   end;
   if (fJoyInfoEx.wButtons and (TpvUInt32(1) shl 9))<>0 then begin
    fButtons:=fButtons or (TpvUInt32(1) shl GAME_CONTROLLER_BUTTON_LEFTSHOULDER);
   end;
   if (fJoyInfoEx.wButtons and (TpvUInt32(1) shl 10))<>0 then begin
    fButtons:=fButtons or (TpvUInt32(1) shl GAME_CONTROLLER_BUTTON_RIGHTSHOULDER);
   end;
  end;
 end;
{$ifend}
{$ifend}
end;

function TpvApplicationJoystick.GetAxis(const aAxisIndex:TpvInt32):TpvFloat;
begin
{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
 result:=Min(Max(SDL_JoystickGetAxis(fJoystick,aAxisIndex)/32767.0,-1.0),1.0);
{$elseif not defined(PasVulkanHeadless)}
 if aAxisIndex in [0..GAME_CONTROLLER_AXIS_MAX-1] then begin
  result:=fAxes[aAxisIndex];
 end else begin
  result:=0;
 end;
{$else}
 result:=0;
{$ifend}
end;

function TpvApplicationJoystick.GetBall(const aBallIndex:TpvInt32;out aDeltaX,aDeltaY:TpvInt32):boolean;
begin
{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
 result:=SDL_JoystickGetBall(fJoystick,aBallIndex,@aDeltaX,@aDeltaY)<>0;
{$else}
 result:=false;
{$ifend}
end;

function TpvApplicationJoystick.GetHat(const aHatIndex:TpvInt32):TpvInt32;
begin
{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
 case SDL_JoystickGetHat(fJoystick,aHatIndex) of
  SDL_HAT_LEFTUP:begin
   result:=JOYSTICK_HAT_LEFTUP;
  end;
  SDL_HAT_UP:begin
   result:=JOYSTICK_HAT_UP;
  end;
  SDL_HAT_RIGHTUP:begin
   result:=JOYSTICK_HAT_RIGHTUP;
  end;
  SDL_HAT_LEFT:begin
   result:=JOYSTICK_HAT_LEFT;
  end;
  SDL_HAT_CENTERED:begin
   result:=JOYSTICK_HAT_CENTERED;
  end;
  SDL_HAT_RIGHT:begin
   result:=JOYSTICK_HAT_RIGHT;
  end;
  SDL_HAT_LEFTDOWN:begin
   result:=JOYSTICK_HAT_LEFTDOWN;
  end;
  SDL_HAT_DOWN:begin
   result:=JOYSTICK_HAT_DOWN;
  end;
  SDL_HAT_RIGHTDOWN:begin
   result:=JOYSTICK_HAT_RIGHTDOWN;
  end;
  else begin
   result:=JOYSTICK_HAT_NONE;
  end;
 end;
{$elseif not defined(PasVulkanHeadless)}
 result:=fHats;
{$else}
 result:=JOYSTICK_HAT_NONE;
{$ifend}
end;

function TpvApplicationJoystick.GetButton(const aButtonIndex:TpvInt32):boolean;
begin
{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
 result:=SDL_JoystickGetButton(fJoystick,aButtonIndex)<>0;
{$elseif not defined(PasVulkanHeadless)}
 result:=(fButtons and (TpvUInt32(1) shl aButtonIndex))<>0;
{$else}
 result:=false;
{$ifend}
end;

function TpvApplicationJoystick.IsGameControllerAttached:boolean;
{$if (defined(Windows) and not (defined(PasVulkanUseSDL2) or defined(PasVulkanHeadless)))}
var Capabilities:TXINPUT_CAPABILITIES;
{$ifend}
begin
{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
 if assigned(fGameController) then begin
  result:=SDL_GameControllerGetAttached(fGameController)<>0;
 end else begin
  result:=false;
 end;
{$elseif defined(Windows) and not defined(PasVulkanHeadless)}
 result:=assigned(fWin32GameInputDevice) or
         ((fJoystick<XUSER_MAX_COUNT) and (XInputGetCapabilities(fJoystick,0,@Capabilities)=ERROR_SUCCESS)) or
         ((fJoystick>=XUSER_MAX_COUNT) and (joyGetDevCapsW(fJoystick-XUSER_MAX_COUNT,@fJoyCaps,SizeOf(TJOYCAPSW))=MMSYSERR_NOERROR));
{$else}
 result:=false;
{$ifend}
end;

function TpvApplicationJoystick.GetGameControllerAxis(const aAxis:TpvInt32):TpvFloat;
begin
{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
 if assigned(fGameController) then begin
  case aAxis of
   GAME_CONTROLLER_AXIS_LEFTX:begin
    result:=Min(Max(SDL_GameControllerGetAxis(fGameController,SDL_CONTROLLER_AXIS_LEFTX)/32767.0,-1.0),1.0);
   end;
   GAME_CONTROLLER_AXIS_LEFTY:begin
    result:=Min(Max(SDL_GameControllerGetAxis(fGameController,SDL_CONTROLLER_AXIS_LEFTY)/32767.0,-1.0),1.0);
   end;
   GAME_CONTROLLER_AXIS_RIGHTX:begin
    result:=Min(Max(SDL_GameControllerGetAxis(fGameController,SDL_CONTROLLER_AXIS_RIGHTX)/32767.0,-1.0),1.0);
   end;
   GAME_CONTROLLER_AXIS_RIGHTY:begin
    result:=Min(Max(SDL_GameControllerGetAxis(fGameController,SDL_CONTROLLER_AXIS_RIGHTY)/32767.0,-1.0),1.0);
   end;
   GAME_CONTROLLER_AXIS_TRIGGERLEFT:begin
    result:=Min(Max(SDL_GameControllerGetAxis(fGameController,SDL_CONTROLLER_AXIS_TRIGGERLEFT)/32767.0,-1.0),1.0);
   end;
   GAME_CONTROLLER_AXIS_TRIGGERRIGHT:begin
    result:=Min(Max(SDL_GameControllerGetAxis(fGameController,SDL_CONTROLLER_AXIS_TRIGGERRIGHT)/32767.0,-1.0),1.0);
   end;
   else begin
    result:=0;
   end;
  end;
 end else begin
  result:=0;
 end;
{$elseif not defined(PasVulkanHeadless)}
 case aAxis of
  0..GAME_CONTROLLER_AXIS_MAX-1:begin
   result:=fAxes[aAxis];
  end;
  else begin
   result:=0;
  end;
 end;
{$else}
 result:=0;
{$ifend}
end;

function TpvApplicationJoystick.GetGameControllerButton(const aButton:TpvInt32):boolean;
begin
{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
 if assigned(fGameController) then begin
  case aButton of
   GAME_CONTROLLER_BUTTON_A:begin
    result:=SDL_GameControllerGetButton(fGameController,SDL_CONTROLLER_BUTTON_A)<>0;
   end;
   GAME_CONTROLLER_BUTTON_B:begin
    result:=SDL_GameControllerGetButton(fGameController,SDL_CONTROLLER_BUTTON_B)<>0;
   end;
   GAME_CONTROLLER_BUTTON_X:begin
    result:=SDL_GameControllerGetButton(fGameController,SDL_CONTROLLER_BUTTON_X)<>0;
   end;
   GAME_CONTROLLER_BUTTON_Y:begin
    result:=SDL_GameControllerGetButton(fGameController,SDL_CONTROLLER_BUTTON_Y)<>0;
   end;
   GAME_CONTROLLER_BUTTON_BACK:begin
    result:=SDL_GameControllerGetButton(fGameController,SDL_CONTROLLER_BUTTON_BACK)<>0;
   end;
   GAME_CONTROLLER_BUTTON_GUIDE:begin
    result:=SDL_GameControllerGetButton(fGameController,SDL_CONTROLLER_BUTTON_GUIDE)<>0;
   end;
   GAME_CONTROLLER_BUTTON_START:begin
    result:=SDL_GameControllerGetButton(fGameController,SDL_CONTROLLER_BUTTON_START)<>0;
   end;
   GAME_CONTROLLER_BUTTON_LEFTSTICK:begin
    result:=SDL_GameControllerGetButton(fGameController,SDL_CONTROLLER_BUTTON_LEFTSTICK)<>0;
   end;
   GAME_CONTROLLER_BUTTON_RIGHTSTICK:begin
    result:=SDL_GameControllerGetButton(fGameController,SDL_CONTROLLER_BUTTON_RIGHTSTICK)<>0;
   end;
   GAME_CONTROLLER_BUTTON_LEFTSHOULDER:begin
    result:=SDL_GameControllerGetButton(fGameController,SDL_CONTROLLER_BUTTON_LEFTSHOULDER)<>0;
   end;
   GAME_CONTROLLER_BUTTON_RIGHTSHOULDER:begin
    result:=SDL_GameControllerGetButton(fGameController,SDL_CONTROLLER_BUTTON_RIGHTSHOULDER)<>0;
   end;
   GAME_CONTROLLER_BUTTON_DPAD_UP:begin
    result:=SDL_GameControllerGetButton(fGameController,SDL_CONTROLLER_BUTTON_DPAD_UP)<>0;
   end;
   GAME_CONTROLLER_BUTTON_DPAD_DOWN:begin
    result:=SDL_GameControllerGetButton(fGameController,SDL_CONTROLLER_BUTTON_DPAD_DOWN)<>0;
   end;
   GAME_CONTROLLER_BUTTON_DPAD_LEFT:begin
    result:=SDL_GameControllerGetButton(fGameController,SDL_CONTROLLER_BUTTON_DPAD_LEFT)<>0;
   end;
   GAME_CONTROLLER_BUTTON_DPAD_RIGHT:begin
    result:=SDL_GameControllerGetButton(fGameController,SDL_CONTROLLER_BUTTON_DPAD_RIGHT)<>0;
   end;
   GAME_CONTROLLER_BUTTON_MISC1:begin
    result:=SDL_GameControllerGetButton(fGameController,SDL_CONTROLLER_BUTTON_MISC1)<>0;
   end;
   GAME_CONTROLLER_BUTTON_PADDLE1:begin
    result:=SDL_GameControllerGetButton(fGameController,SDL_CONTROLLER_BUTTON_PADDLE1)<>0;
   end;
   GAME_CONTROLLER_BUTTON_PADDLE2:begin
    result:=SDL_GameControllerGetButton(fGameController,SDL_CONTROLLER_BUTTON_PADDLE2)<>0;
   end;
   GAME_CONTROLLER_BUTTON_PADDLE3:begin
    result:=SDL_GameControllerGetButton(fGameController,SDL_CONTROLLER_BUTTON_PADDLE3)<>0;
   end;
   GAME_CONTROLLER_BUTTON_PADDLE4:begin
    result:=SDL_GameControllerGetButton(fGameController,SDL_CONTROLLER_BUTTON_PADDLE4)<>0;
   end;
   GAME_CONTROLLER_BUTTON_TOUCHPAD:begin
    result:=SDL_GameControllerGetButton(fGameController,GAME_CONTROLLER_BUTTON_TOUCHPAD)<>0;
   end;
   else begin
    result:=false;
   end;
  end;
 end else begin
  result:=false;
 end;
{$elseif not defined(PasVulkanHeadless)}
 result:=(fButtons and (TpvUInt32(1) shl aButton))<>0;
{$else}
 result:=false;
{$ifend}
end;

function TpvApplicationJoystick.GetGameControllerName:TpvApplicationRawByteString;
begin
{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
 if assigned(fGameController) then begin
  result:=SDL_GameControllerName(fGameController);
 end else begin
  result:='';
 end;
{$elseif defined(Windows) and not defined(PasVulkanHeadless)}
 result:=Name;
{$else}
 result:='';
{$ifend}
end;

function TpvApplicationJoystick.GetGameControllerMapping:TpvApplicationRawByteString;
begin
{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
 if assigned(fGameController) then begin
  result:=SDL_GameControllerMapping(fGameController);
 end else begin
  result:='';
 end;
{$else}
 result:='';
{$ifend}
end;

constructor TpvApplicationInput.Create(const aVulkanApplication:TpvApplication);
var Index:TpvInt32;
begin
 inherited Create;
 fVulkanApplication:=aVulkanApplication;
 fKeyCodeNameHashmap:=TpvApplicationInputKeycodeStringHashMap.Create(KEYCODE_UNKNOWN);
 FillChar(fKeyCodeNames,SizeOf(fKeyCodeNames),AnsiChar(#0));
 FillChar(fKeyCodeLowerCaseNames,SizeOf(fKeyCodeLowerCaseNames),AnsiChar(#0));
 fKeyCodeNames[KEYCODE_ANYKEY]:='ANYKEY';
 fKeyCodeNames[KEYCODE_UNKNOWN]:='UNKNOWN';
 fKeyCodeNames[KEYCODE_FIRST]:='FIRST';
 fKeyCodeNames[KEYCODE_BACKSPACE]:='BACKSPACE';
 fKeyCodeNames[KEYCODE_TAB]:='TAB';
 fKeyCodeNames[KEYCODE_RETURN]:='RETURN';
 fKeyCodeNames[KEYCODE_PAUSE]:='PAUSE';
 fKeyCodeNames[KEYCODE_ESCAPE]:='ESCAPE';
 fKeyCodeNames[KEYCODE_SPACE]:='SPACE';
 fKeyCodeNames[KEYCODE_EXCLAIM]:='EXCLAIM';
 fKeyCodeNames[KEYCODE_QUOTEDBL]:='QUOTEDBL';
 fKeyCodeNames[KEYCODE_HASH]:='HASH';
 fKeyCodeNames[KEYCODE_DOLLAR]:='DOLLAR';
 fKeyCodeNames[KEYCODE_AMPERSAND]:='AMPERSAND';
 fKeyCodeNames[KEYCODE_APOSTROPHE]:='APOSTROPHE';
 fKeyCodeNames[KEYCODE_LEFTPAREN]:='LEFTPAREN';
 fKeyCodeNames[KEYCODE_RIGHTPAREN]:='RIGHTPAREN';
 fKeyCodeNames[KEYCODE_ASTERISK]:='ASTERISK';
 fKeyCodeNames[KEYCODE_PLUS]:='PLUS';
 fKeyCodeNames[KEYCODE_COMMA]:='COMMA';
 fKeyCodeNames[KEYCODE_MINUS]:='MINUS';
 fKeyCodeNames[KEYCODE_PERIOD]:='PERIOD';
 fKeyCodeNames[KEYCODE_SLASH]:='SLASH';
 fKeyCodeNames[KEYCODE_0]:='0';
 fKeyCodeNames[KEYCODE_1]:='1';
 fKeyCodeNames[KEYCODE_2]:='2';
 fKeyCodeNames[KEYCODE_3]:='3';
 fKeyCodeNames[KEYCODE_4]:='4';
 fKeyCodeNames[KEYCODE_5]:='5';
 fKeyCodeNames[KEYCODE_6]:='6';
 fKeyCodeNames[KEYCODE_7]:='7';
 fKeyCodeNames[KEYCODE_8]:='8';
 fKeyCodeNames[KEYCODE_9]:='9';
 fKeyCodeNames[KEYCODE_COLON]:='COLON';
 fKeyCodeNames[KEYCODE_SEMICOLON]:='SEMICOLON';
 fKeyCodeNames[KEYCODE_LESS]:='LESS';
 fKeyCodeNames[KEYCODE_EQUALS]:='EQUALS';
 fKeyCodeNames[KEYCODE_GREATER]:='GREATER';
 fKeyCodeNames[KEYCODE_QUESTION]:='QUESTION';
 fKeyCodeNames[KEYCODE_AT]:='AT';
 fKeyCodeNames[KEYCODE_LEFTBRACKET]:='LEFTBRACKET';
 fKeyCodeNames[KEYCODE_BACKSLASH]:='BACKSLASH';
 fKeyCodeNames[KEYCODE_RIGHTBRACKET]:='RIGHTBRACKET';
 fKeyCodeNames[KEYCODE_CARET]:='CARET';
 fKeyCodeNames[KEYCODE_UNDERSCORE]:='UNDERSCORE';
 fKeyCodeNames[KEYCODE_BACKQUOTE]:='BACKQUOTE';
 fKeyCodeNames[KEYCODE_a]:='a';
 fKeyCodeNames[KEYCODE_b]:='b';
 fKeyCodeNames[KEYCODE_c]:='c';
 fKeyCodeNames[KEYCODE_d]:='d';
 fKeyCodeNames[KEYCODE_e]:='e';
 fKeyCodeNames[KEYCODE_f]:='f';
 fKeyCodeNames[KEYCODE_g]:='g';
 fKeyCodeNames[KEYCODE_h]:='h';
 fKeyCodeNames[KEYCODE_i]:='i';
 fKeyCodeNames[KEYCODE_j]:='j';
 fKeyCodeNames[KEYCODE_k]:='k';
 fKeyCodeNames[KEYCODE_l]:='l';
 fKeyCodeNames[KEYCODE_m]:='m';
 fKeyCodeNames[KEYCODE_n]:='n';
 fKeyCodeNames[KEYCODE_o]:='o';
 fKeyCodeNames[KEYCODE_p]:='p';
 fKeyCodeNames[KEYCODE_q]:='q';
 fKeyCodeNames[KEYCODE_r]:='r';
 fKeyCodeNames[KEYCODE_s]:='s';
 fKeyCodeNames[KEYCODE_t]:='t';
 fKeyCodeNames[KEYCODE_u]:='u';
 fKeyCodeNames[KEYCODE_v]:='v';
 fKeyCodeNames[KEYCODE_w]:='w';
 fKeyCodeNames[KEYCODE_x]:='x';
 fKeyCodeNames[KEYCODE_y]:='y';
 fKeyCodeNames[KEYCODE_z]:='z';
 fKeyCodeNames[KEYCODE_DELETE]:='DELETE';
 fKeyCodeNames[KEYCODE_F1]:='F1';
 fKeyCodeNames[KEYCODE_F2]:='F2';
 fKeyCodeNames[KEYCODE_F3]:='F3';
 fKeyCodeNames[KEYCODE_F4]:='F4';
 fKeyCodeNames[KEYCODE_F5]:='F5';
 fKeyCodeNames[KEYCODE_F6]:='F6';
 fKeyCodeNames[KEYCODE_F7]:='F7';
 fKeyCodeNames[KEYCODE_F8]:='F8';
 fKeyCodeNames[KEYCODE_F9]:='F9';
 fKeyCodeNames[KEYCODE_F10]:='F10';
 fKeyCodeNames[KEYCODE_F11]:='F11';
 fKeyCodeNames[KEYCODE_F12]:='F12';
 fKeyCodeNames[KEYCODE_F13]:='F13';
 fKeyCodeNames[KEYCODE_F14]:='F14';
 fKeyCodeNames[KEYCODE_F15]:='F15';
 fKeyCodeNames[KEYCODE_F16]:='F16';
 fKeyCodeNames[KEYCODE_F17]:='F17';
 fKeyCodeNames[KEYCODE_F18]:='F18';
 fKeyCodeNames[KEYCODE_F19]:='F19';
 fKeyCodeNames[KEYCODE_F20]:='F20';
 fKeyCodeNames[KEYCODE_F21]:='F21';
 fKeyCodeNames[KEYCODE_F22]:='F22';
 fKeyCodeNames[KEYCODE_F23]:='F23';
 fKeyCodeNames[KEYCODE_F24]:='F24';
 fKeyCodeNames[KEYCODE_KP0]:='KP0';
 fKeyCodeNames[KEYCODE_KP1]:='KP1';
 fKeyCodeNames[KEYCODE_KP2]:='KP2';
 fKeyCodeNames[KEYCODE_KP3]:='KP3';
 fKeyCodeNames[KEYCODE_KP4]:='KP4';
 fKeyCodeNames[KEYCODE_KP5]:='KP5';
 fKeyCodeNames[KEYCODE_KP6]:='KP6';
 fKeyCodeNames[KEYCODE_KP7]:='KP7';
 fKeyCodeNames[KEYCODE_KP8]:='KP8';
 fKeyCodeNames[KEYCODE_KP9]:='KP9';
 fKeyCodeNames[KEYCODE_KP_PERIOD]:='KP_PERIOD';
 fKeyCodeNames[KEYCODE_KP_DIVIDE]:='KP_DIVIDE';
 fKeyCodeNames[KEYCODE_KP_MULTIPLY]:='KP_MULTIPLY';
 fKeyCodeNames[KEYCODE_KP_MINUS]:='KP_MINUS';
 fKeyCodeNames[KEYCODE_KP_PLUS]:='KP_PLUS';
 fKeyCodeNames[KEYCODE_KP_ENTER]:='KP_ENTER';
 fKeyCodeNames[KEYCODE_KP_EQUALS]:='KP_EQUALS';
 fKeyCodeNames[KEYCODE_UP]:='UP';
 fKeyCodeNames[KEYCODE_DOWN]:='DOWN';
 fKeyCodeNames[KEYCODE_RIGHT]:='RIGHT';
 fKeyCodeNames[KEYCODE_LEFT]:='LEFT';
 fKeyCodeNames[KEYCODE_INSERT]:='INSERT';
 fKeyCodeNames[KEYCODE_HOME]:='HOME';
 fKeyCodeNames[KEYCODE_END]:='END';
 fKeyCodeNames[KEYCODE_PAGEUP]:='PAGEUP';
 fKeyCodeNames[KEYCODE_PAGEDOWN]:='PAGEDOWN';
 fKeyCodeNames[KEYCODE_CAPSLOCK]:='CAPSLOCK';
 fKeyCodeNames[KEYCODE_NUMLOCK]:='NUMLOCK';
 fKeyCodeNames[KEYCODE_SCROLLLOCK]:='SCROLLLOCK';
 fKeyCodeNames[KEYCODE_RSHIFT]:='RSHIFT';
 fKeyCodeNames[KEYCODE_LSHIFT]:='LSHIFT';
 fKeyCodeNames[KEYCODE_RCTRL]:='RCTRL';
 fKeyCodeNames[KEYCODE_LCTRL]:='LCTRL';
 fKeyCodeNames[KEYCODE_RALT]:='RALT';
 fKeyCodeNames[KEYCODE_LALT]:='LALT';
 fKeyCodeNames[KEYCODE_MODE]:='MODE';
 fKeyCodeNames[KEYCODE_HELP]:='HELP';
 fKeyCodeNames[KEYCODE_PRINTSCREEN]:='PRINTSCREEN';
 fKeyCodeNames[KEYCODE_SYSREQ]:='SYSREQ';
 fKeyCodeNames[KEYCODE_MENU]:='MENU';
 fKeyCodeNames[KEYCODE_POWER]:='POWER';
 fKeyCodeNames[KEYCODE_APPLICATION]:='APPLICATION';
 fKeyCodeNames[KEYCODE_SELECT]:='SELECT';
 fKeyCodeNames[KEYCODE_STOP]:='STOP';
 fKeyCodeNames[KEYCODE_AGAIN]:='AGAIN';
 fKeyCodeNames[KEYCODE_UNDO]:='UNDO';
 fKeyCodeNames[KEYCODE_CUT]:='CUT';
 fKeyCodeNames[KEYCODE_COPY]:='COPY';
 fKeyCodeNames[KEYCODE_PASTE]:='PASTE';
 fKeyCodeNames[KEYCODE_FIND]:='FIND';
 fKeyCodeNames[KEYCODE_MUTE]:='MUTE';
 fKeyCodeNames[KEYCODE_VOLUMEUP]:='VOLUMEUP';
 fKeyCodeNames[KEYCODE_VOLUMEDOWN]:='VOLUMEDOWN';
 fKeyCodeNames[KEYCODE_KP_EQUALSAS400]:='KP_EQUALSAS400';
 fKeyCodeNames[KEYCODE_ALTERASE]:='ALTERASE';
 fKeyCodeNames[KEYCODE_CANCEL]:='CANCEL';
 fKeyCodeNames[KEYCODE_CLEAR]:='CLEAR';
 fKeyCodeNames[KEYCODE_PRIOR]:='PRIOR';
 fKeyCodeNames[KEYCODE_RETURN2]:='RETURN2';
 fKeyCodeNames[KEYCODE_SEPARATOR]:='SEPARATOR';
 fKeyCodeNames[KEYCODE_OUT]:='OUT';
 fKeyCodeNames[KEYCODE_OPER]:='OPER';
 fKeyCodeNames[KEYCODE_CLEARAGAIN]:='CLEARAGAIN';
 fKeyCodeNames[KEYCODE_CRSEL]:='CRSEL';
 fKeyCodeNames[KEYCODE_EXSEL]:='EXSEL';
 fKeyCodeNames[KEYCODE_KP_00]:='KP_00';
 fKeyCodeNames[KEYCODE_KP_000]:='KP_000';
 fKeyCodeNames[KEYCODE_THOUSANDSSEPARATOR]:='THOUSANDSSEPARATOR';
 fKeyCodeNames[KEYCODE_DECIMALSEPARATOR]:='DECIMALSEPARATOR';
 fKeyCodeNames[KEYCODE_CURRENCYUNIT]:='CURRENCYUNIT';
 fKeyCodeNames[KEYCODE_CURRENCYSUBUNIT]:='CURRENCYSUBUNIT';
 fKeyCodeNames[KEYCODE_KP_LEFTPAREN]:='KP_LEFTPAREN';
 fKeyCodeNames[KEYCODE_KP_RIGHTPAREN]:='KP_RIGHTPAREN';
 fKeyCodeNames[KEYCODE_KP_LEFTBRACE]:='KP_LEFTBRACE';
 fKeyCodeNames[KEYCODE_KP_RIGHTBRACE]:='KP_RIGHTBRACE';
 fKeyCodeNames[KEYCODE_KP_TAB]:='KP_TAB';
 fKeyCodeNames[KEYCODE_KP_BACKSPACE]:='KP_BACKSPACE';
 fKeyCodeNames[KEYCODE_KP_A]:='KP_A';
 fKeyCodeNames[KEYCODE_KP_B]:='KP_B';
 fKeyCodeNames[KEYCODE_KP_C]:='KP_C';
 fKeyCodeNames[KEYCODE_KP_D]:='KP_D';
 fKeyCodeNames[KEYCODE_KP_E]:='KP_E';
 fKeyCodeNames[KEYCODE_KP_F]:='KP_F';
 fKeyCodeNames[KEYCODE_KP_XOR]:='KP_XOR';
 fKeyCodeNames[KEYCODE_KP_POWER]:='KP_POWER';
 fKeyCodeNames[KEYCODE_KP_PERCENT]:='KP_PERCENT';
 fKeyCodeNames[KEYCODE_KP_LESS]:='KP_LESS';
 fKeyCodeNames[KEYCODE_KP_GREATER]:='KP_GREATER';
 fKeyCodeNames[KEYCODE_KP_AMPERSAND]:='KP_AMPERSAND';
 fKeyCodeNames[KEYCODE_KP_DBLAMPERSAND]:='KP_DBLAMPERSAND';
 fKeyCodeNames[KEYCODE_KP_VERTICALBAR]:='KP_VERTICALBAR';
 fKeyCodeNames[KEYCODE_KP_DBLVERTICALBAR]:='KP_DBLVERTICALBAR';
 fKeyCodeNames[KEYCODE_KP_COLON]:='KP_COLON';
 fKeyCodeNames[KEYCODE_KP_COMMA]:='KP_COMMA';
 fKeyCodeNames[KEYCODE_KP_HASH]:='KP_HASH';
 fKeyCodeNames[KEYCODE_KP_SPACE]:='KP_SPACE';
 fKeyCodeNames[KEYCODE_KP_AT]:='KP_AT';
 fKeyCodeNames[KEYCODE_KP_EXCLAM]:='KP_EXCLAM';
 fKeyCodeNames[KEYCODE_KP_MEMSTORE]:='KP_MEMSTORE';
 fKeyCodeNames[KEYCODE_KP_MEMRECALL]:='KP_MEMRECALL';
 fKeyCodeNames[KEYCODE_KP_MEMCLEAR]:='KP_MEMCLEAR';
 fKeyCodeNames[KEYCODE_KP_MEMADD]:='KP_MEMADD';
 fKeyCodeNames[KEYCODE_KP_MEMSUBTRACT]:='KP_MEMSUBTRACT';
 fKeyCodeNames[KEYCODE_KP_MEMMULTIPLY]:='KP_MEMMULTIPLY';
 fKeyCodeNames[KEYCODE_KP_MEMDIVIDE]:='KP_MEMDIVIDE';
 fKeyCodeNames[KEYCODE_KP_PLUSMINUS]:='KP_PLUSMINUS';
 fKeyCodeNames[KEYCODE_KP_CLEAR]:='KP_CLEAR';
 fKeyCodeNames[KEYCODE_KP_CLEARENTRY]:='KP_CLEARENTRY';
 fKeyCodeNames[KEYCODE_KP_BINARY]:='KP_BINARY';
 fKeyCodeNames[KEYCODE_KP_OCTAL]:='KP_OCTAL';
 fKeyCodeNames[KEYCODE_KP_DECIMAL]:='KP_DECIMAL';
 fKeyCodeNames[KEYCODE_KP_HEXADECIMAL]:='KP_HEXADECIMAL';
 fKeyCodeNames[KEYCODE_LGUI]:='LGUI';
 fKeyCodeNames[KEYCODE_RGUI]:='RGUI';
 fKeyCodeNames[KEYCODE_AUDIONEXT]:='AUDIONEXT';
 fKeyCodeNames[KEYCODE_AUDIOPREV]:='AUDIOPREV';
 fKeyCodeNames[KEYCODE_AUDIOSTOP]:='AUDIOSTOP';
 fKeyCodeNames[KEYCODE_AUDIOPLAY]:='AUDIOPLAY';
 fKeyCodeNames[KEYCODE_AUDIOMUTE]:='AUDIOMUTE';
 fKeyCodeNames[KEYCODE_MEDIASELECT]:='MEDIASELECT';
 fKeyCodeNames[KEYCODE_WWW]:='WWW';
 fKeyCodeNames[KEYCODE_MAIL]:='MAIL';
 fKeyCodeNames[KEYCODE_CALCULATOR]:='CALCULATOR';
 fKeyCodeNames[KEYCODE_COMPUTER]:='COMPUTER';
 fKeyCodeNames[KEYCODE_AC_SEARCH]:='AC_SEARCH';
 fKeyCodeNames[KEYCODE_AC_HOME]:='AC_HOME';
 fKeyCodeNames[KEYCODE_AC_BACK]:='AC_BACK';
 fKeyCodeNames[KEYCODE_AC_FORWARD]:='AC_FORWARD';
 fKeyCodeNames[KEYCODE_AC_STOP]:='AC_STOP';
 fKeyCodeNames[KEYCODE_AC_REFRESH]:='AC_REFRESH';
 fKeyCodeNames[KEYCODE_AC_BOOKMARKS]:='AC_BOOKMARKS';
 fKeyCodeNames[KEYCODE_BRIGHTNESSDOWN]:='BRIGHTNESSDOWN';
 fKeyCodeNames[KEYCODE_BRIGHTNESSUP]:='BRIGHTNESSUP';
 fKeyCodeNames[KEYCODE_DISPLAYSWITCH]:='DISPLAYSWITCH';
 fKeyCodeNames[KEYCODE_KBDILLUMTOGGLE]:='KBDILLUMTOGGLE';
 fKeyCodeNames[KEYCODE_KBDILLUMDOWN]:='KBDILLUMDOWN';
 fKeyCodeNames[KEYCODE_KBDILLUMUP]:='KBDILLUMUP';
 fKeyCodeNames[KEYCODE_EJECT]:='EJECT';
 fKeyCodeNames[KEYCODE_SLEEP]:='SLEEP';
 fKeyCodeNames[KEYCODE_INTERNATIONAL1]:='INTERNATIONAL1';
 fKeyCodeNames[KEYCODE_INTERNATIONAL2]:='INTERNATIONAL2';
 fKeyCodeNames[KEYCODE_INTERNATIONAL3]:='INTERNATIONAL3';
 fKeyCodeNames[KEYCODE_INTERNATIONAL4]:='INTERNATIONAL4';
 fKeyCodeNames[KEYCODE_INTERNATIONAL5]:='INTERNATIONAL5';
 fKeyCodeNames[KEYCODE_INTERNATIONAL6]:='INTERNATIONAL6';
 fKeyCodeNames[KEYCODE_INTERNATIONAL7]:='INTERNATIONAL7';
 fKeyCodeNames[KEYCODE_INTERNATIONAL8]:='INTERNATIONAL8';
 fKeyCodeNames[KEYCODE_INTERNATIONAL9]:='INTERNATIONAL9';
 fKeyCodeNames[KEYCODE_LANG1]:='LANG1';
 fKeyCodeNames[KEYCODE_LANG2]:='LANG2';
 fKeyCodeNames[KEYCODE_LANG3]:='LANG3';
 fKeyCodeNames[KEYCODE_LANG4]:='LANG4';
 fKeyCodeNames[KEYCODE_LANG5]:='LANG5';
 fKeyCodeNames[KEYCODE_LANG6]:='LANG6';
 fKeyCodeNames[KEYCODE_LANG7]:='LANG7';
 fKeyCodeNames[KEYCODE_LANG8]:='LANG8';
 fKeyCodeNames[KEYCODE_LANG9]:='LANG9';
 fKeyCodeNames[KEYCODE_LOCKINGCAPSLOCK]:='LOCKINGCAPSLOCK';
 fKeyCodeNames[KEYCODE_LOCKINGNUMLOCK]:='LOCKINGNUMLOCK';
 fKeyCodeNames[KEYCODE_LOCKINGSCROLLLOCK]:='LOCKINGSCROLLLOCK';
 fKeyCodeNames[KEYCODE_NONUSBACKSLASH]:='NONUSBACKSLASH';
 fKeyCodeNames[KEYCODE_NONUSHASH]:='NONUSHASH';
 fKeyCodeNames[KEYCODE_BACK]:='BACK';
 fKeyCodeNames[KEYCODE_CAMERA]:='CAMERA';
 fKeyCodeNames[KEYCODE_CALL]:='CALL';
 fKeyCodeNames[KEYCODE_CENTER]:='CENTER';
 fKeyCodeNames[KEYCODE_FORWARD_DEL]:='FORWARD_DEL';
 fKeyCodeNames[KEYCODE_DPAD_CENTER]:='DPAD_CENTER';
 fKeyCodeNames[KEYCODE_DPAD_LEFT]:='DPAD_LEFT';
 fKeyCodeNames[KEYCODE_DPAD_RIGHT]:='DPAD_RIGHT';
 fKeyCodeNames[KEYCODE_DPAD_DOWN]:='DPAD_DOWN';
 fKeyCodeNames[KEYCODE_DPAD_UP]:='DPAD_UP';
 fKeyCodeNames[KEYCODE_ENDCALL]:='ENDCALL';
 fKeyCodeNames[KEYCODE_ENVELOPE]:='ENVELOPE';
 fKeyCodeNames[KEYCODE_EXPLORER]:='EXPLORER';
 fKeyCodeNames[KEYCODE_FOCUS]:='FOCUS';
 fKeyCodeNames[KEYCODE_GRAVE]:='GRAVE';
 fKeyCodeNames[KEYCODE_HEADSETHOOK]:='HEADSETHOOK';
 fKeyCodeNames[KEYCODE_AUDIO_FAST_FORWARD]:='AUDIO_FAST_FORWARD';
 fKeyCodeNames[KEYCODE_AUDIO_REWIND]:='AUDIO_REWIND';
 fKeyCodeNames[KEYCODE_NOTIFICATION]:='NOTIFICATION';
 fKeyCodeNames[KEYCODE_PICTSYMBOLS]:='PICTSYMBOLS';
 fKeyCodeNames[KEYCODE_SWITCH_CHARSET]:='SWITCH_CHARSET';
 fKeyCodeNames[KEYCODE_BUTTON_CIRCLE]:='BUTTON_CIRCLE';
 fKeyCodeNames[KEYCODE_BUTTON_A]:='BUTTON_A';
 fKeyCodeNames[KEYCODE_BUTTON_B]:='BUTTON_B';
 fKeyCodeNames[KEYCODE_BUTTON_C]:='BUTTON_C';
 fKeyCodeNames[KEYCODE_BUTTON_X]:='BUTTON_X';
 fKeyCodeNames[KEYCODE_BUTTON_Y]:='BUTTON_Y';
 fKeyCodeNames[KEYCODE_BUTTON_Z]:='BUTTON_Z';
 fKeyCodeNames[KEYCODE_BUTTON_L1]:='BUTTON_L1';
 fKeyCodeNames[KEYCODE_BUTTON_R1]:='BUTTON_R1';
 fKeyCodeNames[KEYCODE_BUTTON_L2]:='BUTTON_L2';
 fKeyCodeNames[KEYCODE_BUTTON_R2]:='BUTTON_R2';
 fKeyCodeNames[KEYCODE_BUTTON_THUMBL]:='BUTTON_THUMBL';
 fKeyCodeNames[KEYCODE_BUTTON_THUMBR]:='BUTTON_THUMBR';
 fKeyCodeNames[KEYCODE_BUTTON_START]:='BUTTON_START';
 fKeyCodeNames[KEYCODE_BUTTON_SELECT]:='BUTTON_SELECT';
 fKeyCodeNames[KEYCODE_BUTTON_MODE]:='BUTTON_MODE';
 fKeyCodeNames[KEYCODE_102ND]:='KEYCODE_102ND';
 fKeyCodeNames[KEYCODE_KATAKANAHIRAGANA]:='KATAKANAHIRAGANA';
 fKeyCodeNames[KEYCODE_HENKAN]:='HENKAN';
 fKeyCodeNames[KEYCODE_MUHENKAN]:='MUHENKAN';
 fKeyCodeNames[KEYCODE_HANGEUL]:='HANGEUL';
 fKeyCodeNames[KEYCODE_HANJA]:='HANJA';
 for Index:=Low(fKeyCodeNames) to High(fKeyCodeNames) do begin
  fKeyCodeLowerCaseNames[Index]:=PUCUUTF8LowerCase(fKeyCodeNames[Index]);
  if length(fKeyCodeLowerCaseNames[Index])>0 then begin
   fKeyCodeNameHashmap.Add(fKeyCodeLowerCaseNames[Index],Index);
  end;
 end;
 fCriticalSection:=TPasMPCriticalSection.Create;
 fProcessor:=nil;
 fEvents:=nil;
 fEventTimes:=nil;
 fEventCount:=0;
 fCurrentEventTime:=0;
 FillChar(fKeyDown,SizeOf(fKeyDown),AnsiChar(#0));
 fKeyDownCount:=0;
 FillChar(fJustKeyDown,SizeOf(fJustKeyDown),AnsiChar(#0));
 FillChar(fPointerX,SizeOf(fPointerX),AnsiChar(#0));
 FillChar(fPointerY,SizeOf(fPointerY),AnsiChar(#0));
 FillChar(fPointerDown,SizeOf(fPointerDown),AnsiChar(#0));
 FillChar(fPointerJustDown,SizeOf(fPointerJustDown),AnsiChar(#0));
 FillChar(fPointerPressure,SizeOf(fPointerPressure),AnsiChar(#0));
 FillChar(fPointerDeltaX,SizeOf(fPointerDeltaX),AnsiChar(#0));
 FillChar(fPointerDeltaY,SizeOf(fPointerDeltaY),AnsiChar(#0));
 fPointerDownCount:=0;
 fMouseX:=0;
 fMouseY:=0;
 fMouseDown:=[];
 fMouseJustDown:=[];
 fMouseDeltaX:=0;
 fMouseDeltaY:=0;
 fJustTouched:=false;
 fMaxPointerID:=-1;
 SetLength(fEvents,1024);
 SetLength(fEventTimes,1024);
 fJoysticks:=TpvApplicationJoysticks.Create;
 fJoysticks.OwnsObjects:=true;
 fJoystickIDHashMap:=TpvApplicationJoystickIDHashMap.Create(nil);
 fMainJoystick:=nil;
 fTextInput:=false;
 fLastTextInput:=false;
 fKeyShortcuts:=TpvApplicationInputKeyShortcuts.Create(true);
 fKeyShortcutHashMap:=TpvApplicationInputKeyShortcutHashMap.Create(nil);
 fKeyShortcutIDCounter:=0;
 fKeyActions:=TpvApplicationInputKeyActions.Create;
 fKeyActionIDCounter:=0;
end;

destructor TpvApplicationInput.Destroy;
begin
 FreeAndNil(fKeyActions);
 FreeAndNil(fKeyShortcuts);
 FreeAndNil(fKeyShortcutHashMap);
 FreeAndNil(fJoysticks);
 FreeAndNil(fJoystickIDHashMap);
 FreeAndNil(fKeyCodeNameHashmap);
 fEvents:=nil;
 fCriticalSection.Free;
 inherited Destroy;
end;

procedure TpvApplicationInput.ClearKeyDefinitions;
begin
 fKeyShortcuts.Clear;
 fKeyShortcutHashMap.Clear;
 fKeyShortcutIDCounter:=0;
 fKeyActions.Clear;
 fKeyActionIDCounter:=0;
end;

function TpvApplicationInput.GetKeyShortcut(const aKeyCode:TpvInt32;
                                            const aScanCode:TpvInt32;
                                            const aKeyModifiers:TpvApplicationInputKeyModifiers):TpvApplicationInputKeyShortcut;
var KeyModifiers:TpvApplicationInputKeyModifiers;
    Key:TpvApplicationInputKey;
begin
 KeyModifiers:=aKeyModifiers*pvApplicationInputKeyModifierKeyShortcutMask;

 Key:=TpvApplicationInputKey.Create(aKeyCode,aScanCode,KeyModifiers);
 result:=fKeyShortcutHashMap[Key];
 if assigned(result) then begin
  exit;
 end;

 if aKeyCode>=0 then begin
  Key:=TpvApplicationInputKey.Create(aKeyCode,-1,KeyModifiers);
  result:=fKeyShortcutHashMap[Key];
  if assigned(result) then begin
   exit;
  end;
 end;

 if aScanCode>=0 then begin
  Key:=TpvApplicationInputKey.Create(-1,aScanCode,KeyModifiers);
  result:=fKeyShortcutHashMap[Key];
  if assigned(result) then begin
   exit;
  end;
 end;

end;

function TpvApplicationInput.AddKeyShortcut(const aKeyCode:TpvInt32;
                                            const aScanCode:TpvInt32;
                                            const aKeyModifiers:TpvApplicationInputKeyModifiers):TpvApplicationInputKeyShortcut;
var KeyModifiers:TpvApplicationInputKeyModifiers;
    Key:TpvApplicationInputKey;
begin
 KeyModifiers:=aKeyModifiers*pvApplicationInputKeyModifierKeyShortcutMask;
 Key:=TpvApplicationInputKey.Create(aKeyCode,aScanCode,KeyModifiers);
 result:=fKeyShortcutHashMap[Key];
 if not assigned(result) then begin
  inc(fKeyShortcutIDCounter);
  result:=TpvApplicationInputKeyShortcut.Create(pvApplication,aKeyCode,aScanCode,aKeyModifiers);
  try
   result.fID:=fKeyShortcutIDCounter;
   fKeyShortcutHashMap.Add(Key,result);
  finally
   fKeyShortcuts.Add(result);
  end;
 end;
end;

procedure TpvApplicationInput.RemoveKeyShortcut(const aKeyShortcut:TpvApplicationInputKeyShortcut);
var Index:TpvInt32;
begin
 if assigned(aKeyShortcut) then begin
  Index:=fKeyShortcuts.IndexOf(aKeyShortcut);
  if Index>=0 then begin
   try
    fKeyShortcuts.Delete(Index);
    fKeyShortcutHashMap.Delete(aKeyShortcut.fKey);
   finally
    aKeyShortcut.Free;
   end;
  end;
 end;
end;

procedure TpvApplicationInput.RemoveKeyShortcut(const aKeyCode:TpvInt32;
                                                const aScanCode:TpvInt32;
                                                const aKeyModifiers:TpvApplicationInputKeyModifiers);
var KeyModifiers:TpvApplicationInputKeyModifiers;
    Key:TpvApplicationInputKey;
    Shortcut:TpvApplicationInputKeyShortcut;
begin
 KeyModifiers:=aKeyModifiers*pvApplicationInputKeyModifierKeyShortcutMask;
 Key:=TpvApplicationInputKey.Create(aKeyCode,aScanCode,KeyModifiers);
 Shortcut:=fKeyShortcutHashMap[Key];
 if assigned(Shortcut) then begin
  RemoveKeyShortcut(Shortcut);
 end;
end;

function TpvApplicationInput.AddKeyAction(const aName:TpvUTF8String;
                                          const aDescription:TpvUTF8String):TpvApplicationInputKeyAction;
begin
 inc(fKeyActionIDCounter);
 result:=TpvApplicationInputKeyAction.Create(pvApplication,aName,aDescription);
 try
  result.fID:=fKeyActionIDCounter;
 finally
  fKeyActions.Add(result);
 end;
end;

procedure TpvApplicationInput.RemoveKeyAction(const aKeyAction:TpvApplicationInputKeyAction);
var Index:TpvInt32;
begin
 if assigned(aKeyAction) then begin
  Index:=fKeyActions.IndexOf(aKeyAction);
  if Index>=0 then begin
   try
    fKeyActions.Delete(Index);
   finally
    aKeyAction.Free;
   end;
  end;
 end;
end;

function TpvApplicationInput.KeyCodeToString(const aKeyCode:TpvInt32):TpvApplicationRawByteString;
begin
 if (aKeyCode>=0) and (aKeyCode<KEYCODE_COUNT) then begin
  result:=fKeyCodeLowerCaseNames[aKeyCode];
 end else begin
  result:='';
 end;
end;

function TpvApplicationInput.StringToKeyCode(const aString:TpvApplicationRawByteString):TpvInt32;
begin
 result:=fKeyCodeNameHashmap[PUCUUTF8LowerCase(aString)];
end;

{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
function TpvApplicationInput.TranslateSDLKeyCode(const aKeyCode,aScanCode:TpvInt32):TpvInt32;
begin
 case aKeyCode of
  SDLK_BACKSPACE:begin
   result:=KEYCODE_BACKSPACE;
  end;
  SDLK_TAB:begin
   result:=KEYCODE_TAB;
  end;
  SDLK_RETURN:begin
   result:=KEYCODE_RETURN;
  end;
  SDLK_PAUSE:begin
   result:=KEYCODE_PAUSE;
  end;
  SDLK_ESCAPE:begin
   result:=KEYCODE_ESCAPE;
  end;
  SDLK_SPACE:begin
   result:=KEYCODE_SPACE;
  end;
  SDLK_EXCLAIM:begin
   result:=KEYCODE_EXCLAIM;
  end;
  SDLK_QUOTEDBL:begin
   result:=KEYCODE_QUOTEDBL;
  end;
  SDLK_HASH:begin
   result:=KEYCODE_HASH;
  end;
  SDLK_DOLLAR:begin
   result:=KEYCODE_DOLLAR;
  end;
  SDLK_AMPERSAND:begin
   result:=KEYCODE_AMPERSAND;
  end;
  SDLK_APOSTROPHE:begin
   result:=KEYCODE_APOSTROPHE;
  end;
  SDLK_LEFTPAREN:begin
   result:=KEYCODE_LEFTPAREN;
  end;
  SDLK_RIGHTPAREN:begin
   result:=KEYCODE_RIGHTPAREN;
  end;
  SDLK_ASTERISK:begin
   result:=KEYCODE_ASTERISK;
  end;
  SDLK_PLUS:begin
   result:=KEYCODE_PLUS;
  end;
  SDLK_COMMA:begin
   result:=KEYCODE_COMMA;
  end;
  SDLK_MINUS:begin
   result:=KEYCODE_MINUS;
  end;
  SDLK_PERIOD:begin
   result:=KEYCODE_PERIOD;
  end;
  SDLK_SLASH:begin
   result:=KEYCODE_SLASH;
  end;
  SDLK_0:begin
   result:=KEYCODE_0;
  end;
  SDLK_1:begin
   result:=KEYCODE_1;
  end;
  SDLK_2:begin
   result:=KEYCODE_2;
  end;
  SDLK_3:begin
   result:=KEYCODE_3;
  end;
  SDLK_4:begin
   result:=KEYCODE_4;
  end;
  SDLK_5:begin
   result:=KEYCODE_5;
  end;
  SDLK_6:begin
   result:=KEYCODE_6;
  end;
  SDLK_7:begin
   result:=KEYCODE_7;
  end;
  SDLK_8:begin
   result:=KEYCODE_8;
  end;
  SDLK_9:begin
   result:=KEYCODE_9;
  end;
  SDLK_COLON:begin
   result:=KEYCODE_COLON;
  end;
  SDLK_SEMICOLON:begin
   result:=KEYCODE_SEMICOLON;
  end;
  SDLK_LESS:begin
   result:=KEYCODE_LESS;
  end;
  SDLK_EQUALS:begin
   result:=KEYCODE_EQUALS;
  end;
  SDLK_GREATER:begin
   result:=KEYCODE_GREATER;
  end;
  SDLK_QUESTION:begin
   result:=KEYCODE_QUESTION;
  end;
  SDLK_AT:begin
   result:=KEYCODE_AT;
  end;
  SDLK_LEFTBRACKET:begin
   result:=KEYCODE_LEFTBRACKET;
  end;
  SDLK_BACKSLASH:begin
   result:=KEYCODE_BACKSLASH;
  end;
  SDLK_RIGHTBRACKET:begin
   result:=KEYCODE_RIGHTBRACKET;
  end;
  SDLK_CARET:begin
   result:=KEYCODE_CARET;
  end;
  SDLK_UNDERSCORE:begin
   result:=KEYCODE_UNDERSCORE;
  end;
  SDLK_BACKQUOTE:begin
   result:=KEYCODE_BACKQUOTE;
  end;
  SDLK_a:begin
   result:=KEYCODE_a;
  end;
  SDLK_b:begin
   result:=KEYCODE_b;
  end;
  SDLK_c:begin
   result:=KEYCODE_c;
  end;
  SDLK_d:begin
   result:=KEYCODE_d;
  end;
  SDLK_e:begin
   result:=KEYCODE_e;
  end;
  SDLK_f:begin
   result:=KEYCODE_f;
  end;
  SDLK_g:begin
   result:=KEYCODE_g;
  end;
  SDLK_h:begin
   result:=KEYCODE_h;
  end;
  SDLK_i:begin
   result:=KEYCODE_i;
  end;
  SDLK_j:begin
   result:=KEYCODE_j;
  end;
  SDLK_k:begin
   result:=KEYCODE_k;
  end;
  SDLK_l:begin
   result:=KEYCODE_l;
  end;
  SDLK_m:begin
   result:=KEYCODE_m;
  end;
  SDLK_n:begin
   result:=KEYCODE_n;
  end;
  SDLK_o:begin
   result:=KEYCODE_o;
  end;
  SDLK_p:begin
   result:=KEYCODE_p;
  end;
  SDLK_q:begin
   result:=KEYCODE_q;
  end;
  SDLK_r:begin
   result:=KEYCODE_r;
  end;
  SDLK_s:begin
   result:=KEYCODE_s;
  end;
  SDLK_t:begin
   result:=KEYCODE_t;
  end;
  SDLK_u:begin
   result:=KEYCODE_u;
  end;
  SDLK_v:begin
   result:=KEYCODE_v;
  end;
  SDLK_w:begin
   result:=KEYCODE_w;
  end;
  SDLK_x:begin
   result:=KEYCODE_x;
  end;
  SDLK_y:begin
   result:=KEYCODE_y;
  end;
  SDLK_z:begin
   result:=KEYCODE_z;
  end;
  SDLK_LEFTBRACE:begin
   result:=KEYCODE_LEFTBRACE;
  end;
  SDLK_PIPE:begin
   result:=KEYCODE_PIPE;
  end;
  SDLK_RIGHTBRACE:begin
   result:=KEYCODE_RIGHTBRACE;
  end;
  SDLK_TILDE:begin
   result:=KEYCODE_TILDE;
  end;
  SDLK_DELETE:begin
   result:=KEYCODE_DELETE;
  end;
  SDLK_F1:begin
   result:=KEYCODE_F1;
  end;
  SDLK_F2:begin
   result:=KEYCODE_F2;
  end;
  SDLK_F3:begin
   result:=KEYCODE_F3;
  end;
  SDLK_F4:begin
   result:=KEYCODE_F4;
  end;
  SDLK_F5:begin
   result:=KEYCODE_F5;
  end;
  SDLK_F6:begin
   result:=KEYCODE_F6;
  end;
  SDLK_F7:begin
   result:=KEYCODE_F7;
  end;
  SDLK_F8:begin
   result:=KEYCODE_F8;
  end;
  SDLK_F9:begin
   result:=KEYCODE_F9;
  end;
  SDLK_F10:begin
   result:=KEYCODE_F10;
  end;
  SDLK_F11:begin
   result:=KEYCODE_F11;
  end;
  SDLK_F12:begin
   result:=KEYCODE_F12;
  end;
  SDLK_F13:begin
   result:=KEYCODE_F13;
  end;
  SDLK_F14:begin
   result:=KEYCODE_F14;
  end;
  SDLK_F15:begin
   result:=KEYCODE_F15;
  end;
  SDLK_F16:begin
   result:=KEYCODE_F16;
  end;
  SDLK_F17:begin
   result:=KEYCODE_F17;
  end;
  SDLK_F18:begin
   result:=KEYCODE_F18;
  end;
  SDLK_F19:begin
   result:=KEYCODE_F19;
  end;
  SDLK_F20:begin
   result:=KEYCODE_F20;
  end;
  SDLK_F21:begin
   result:=KEYCODE_F21;
  end;
  SDLK_F22:begin
   result:=KEYCODE_F22;
  end;
  SDLK_F23:begin
   result:=KEYCODE_F23;
  end;
  SDLK_F24:begin
   result:=KEYCODE_F24;
  end;
  SDLK_KP0:begin
   result:=KEYCODE_KP0;
  end;
  SDLK_KP1:begin
   result:=KEYCODE_KP1;
  end;
  SDLK_KP2:begin
   result:=KEYCODE_KP2;
  end;
  SDLK_KP3:begin
   result:=KEYCODE_KP3;
  end;
  SDLK_KP4:begin
   result:=KEYCODE_KP4;
  end;
  SDLK_KP5:begin
   result:=KEYCODE_KP5;
  end;
  SDLK_KP6:begin
   result:=KEYCODE_KP6;
  end;
  SDLK_KP7:begin
   result:=KEYCODE_KP7;
  end;
  SDLK_KP8:begin
   result:=KEYCODE_KP8;
  end;
  SDLK_KP9:begin
   result:=KEYCODE_KP9;
  end;
  SDLK_KP_PERIOD:begin
   result:=KEYCODE_KP_PERIOD;
  end;
  SDLK_KP_DIVIDE:begin
   result:=KEYCODE_KP_DIVIDE;
  end;
  SDLK_KP_MULTIPLY:begin
   result:=KEYCODE_KP_MULTIPLY;
  end;
  SDLK_KP_MINUS:begin
   result:=KEYCODE_KP_MINUS;
  end;
  SDLK_KP_PLUS:begin
   result:=KEYCODE_KP_PLUS;
  end;
  SDLK_KP_ENTER:begin
   result:=KEYCODE_KP_ENTER;
  end;
  SDLK_KP_EQUALS:begin
   result:=KEYCODE_KP_EQUALS;
  end;
  SDLK_UP:begin
   result:=KEYCODE_UP;
  end;
  SDLK_DOWN:begin
   result:=KEYCODE_DOWN;
  end;
  SDLK_RIGHT:begin
   result:=KEYCODE_RIGHT;
  end;
  SDLK_LEFT:begin
   result:=KEYCODE_LEFT;
  end;
  SDLK_INSERT:begin
   result:=KEYCODE_INSERT;
  end;
  SDLK_HOME:begin
   result:=KEYCODE_HOME;
  end;
  SDLK_END:begin
   result:=KEYCODE_END;
  end;
  SDLK_PAGEUP:begin
   result:=KEYCODE_PAGEUP;
  end;
  SDLK_PAGEDOWN:begin
   result:=KEYCODE_PAGEDOWN;
  end;
  SDLK_CAPSLOCK:begin
   result:=KEYCODE_CAPSLOCK;
  end;
  SDLK_NUMLOCK:begin
   result:=KEYCODE_NUMLOCK;
  end;
  SDLK_SCROLLOCK:begin
   result:=KEYCODE_SCROLLLOCK;
  end;
  SDLK_RSHIFT:begin
   result:=KEYCODE_RSHIFT;
  end;
  SDLK_LSHIFT:begin
   result:=KEYCODE_LSHIFT;
  end;
  SDLK_RCTRL:begin
   result:=KEYCODE_RCTRL;
  end;
  SDLK_LCTRL:begin
   result:=KEYCODE_LCTRL;
  end;
  SDLK_RALT:begin
   result:=KEYCODE_RALT;
  end;
  SDLK_LALT:begin
   result:=KEYCODE_LALT;
  end;
  SDLK_MODE:begin
   result:=KEYCODE_MODE;
  end;
  SDLK_HELP:begin
   result:=KEYCODE_HELP;
  end;
  SDLK_PRINTSCREEN:begin
   result:=KEYCODE_PRINTSCREEN;
  end;
  SDLK_SYSREQ:begin
   result:=KEYCODE_SYSREQ;
  end;
  SDLK_MENU:begin
   result:=KEYCODE_MENU;
  end;
  SDLK_POWER:begin
   result:=KEYCODE_POWER;
  end;
  SDLK_APPLICATION:begin
   result:=KEYCODE_APPLICATION;
  end;
  SDLK_SELECT:begin
   result:=KEYCODE_SELECT;
  end;
  SDLK_STOP:begin
   result:=KEYCODE_STOP;
  end;
  SDLK_AGAIN:begin
   result:=KEYCODE_AGAIN;
  end;
  SDLK_UNDO:begin
   result:=KEYCODE_UNDO;
  end;
  SDLK_CUT:begin
   result:=KEYCODE_CUT;
  end;
  SDLK_COPY:begin
   result:=KEYCODE_COPY;
  end;
  SDLK_PASTE:begin
   result:=KEYCODE_PASTE;
  end;
  SDLK_FIND:begin
   result:=KEYCODE_FIND;
  end;
  SDLK_MUTE:begin
   result:=KEYCODE_MUTE;
  end;
  SDLK_VOLUMEUP:begin
   result:=KEYCODE_VOLUMEUP;
  end;
  SDLK_VOLUMEDOWN:begin
   result:=KEYCODE_VOLUMEDOWN;
  end;
  SDLK_KP_EQUALSAS400:begin
   result:=KEYCODE_KP_EQUALSAS400;
  end;
  SDLK_ALTERASE:begin
   result:=KEYCODE_ALTERASE;
  end;
  SDLK_CANCEL:begin
   result:=KEYCODE_CANCEL;
  end;
  SDLK_CLEAR:begin
   result:=KEYCODE_CLEAR;
  end;
  SDLK_PRIOR:begin
   result:=KEYCODE_PRIOR;
  end;
  SDLK_RETURN2:begin
   result:=KEYCODE_RETURN2;
  end;
  SDLK_SEPARATOR:begin
   result:=KEYCODE_SEPARATOR;
  end;
  SDLK_OUT:begin
   result:=KEYCODE_OUT;
  end;
  SDLK_OPER:begin
   result:=KEYCODE_OPER;
  end;
  SDLK_CLEARAGAIN:begin
   result:=KEYCODE_CLEARAGAIN;
  end;
  SDLK_CRSEL:begin
   result:=KEYCODE_CRSEL;
  end;
  SDLK_EXSEL:begin
   result:=KEYCODE_EXSEL;
  end;
  SDLK_KP_00:begin
   result:=KEYCODE_KP_00;
  end;
  SDLK_KP_000:begin
   result:=KEYCODE_KP_000;
  end;
  SDLK_THOUSANDSSEPARATOR:begin
   result:=KEYCODE_THOUSANDSSEPARATOR;
  end;
  SDLK_DECIMALSEPARATOR:begin
   result:=KEYCODE_DECIMALSEPARATOR;
  end;
  SDLK_CURRENCYUNIT:begin
   result:=KEYCODE_CURRENCYUNIT;
  end;
  SDLK_CURRENCYSUBUNIT:begin
   result:=KEYCODE_CURRENCYSUBUNIT;
  end;
  SDLK_KP_LEFTPAREN:begin
   result:=KEYCODE_KP_LEFTPAREN;
  end;
  SDLK_KP_RIGHTPAREN:begin
   result:=KEYCODE_KP_RIGHTPAREN;
  end;
  SDLK_KP_LEFTBRACE:begin
   result:=KEYCODE_KP_LEFTBRACE;
  end;
  SDLK_KP_RIGHTBRACE:begin
   result:=KEYCODE_KP_RIGHTBRACE;
  end;
  SDLK_KP_TAB:begin
   result:=KEYCODE_KP_TAB;
  end;
  SDLK_KP_BACKSPACE:begin
   result:=KEYCODE_KP_BACKSPACE;
  end;
  SDLK_KP_A:begin
   result:=KEYCODE_KP_A;
  end;
  SDLK_KP_B:begin
   result:=KEYCODE_KP_B;
  end;
  SDLK_KP_C:begin
   result:=KEYCODE_KP_C;
  end;
  SDLK_KP_D:begin
   result:=KEYCODE_KP_D;
  end;
  SDLK_KP_E:begin
   result:=KEYCODE_KP_E;
  end;
  SDLK_KP_F:begin
   result:=KEYCODE_KP_F;
  end;
  SDLK_KP_XOR:begin
   result:=KEYCODE_KP_XOR;
  end;
  SDLK_KP_POWER:begin
   result:=KEYCODE_KP_POWER;
  end;
  SDLK_KP_PERCENT:begin
   result:=KEYCODE_KP_PERCENT;
  end;
  SDLK_KP_LESS:begin
   result:=KEYCODE_KP_LESS;
  end;
  SDLK_KP_GREATER:begin
   result:=KEYCODE_KP_GREATER;
  end;
  SDLK_KP_AMPERSAND:begin
   result:=KEYCODE_KP_AMPERSAND;
  end;
  SDLK_KP_DBLAMPERSAND:begin
   result:=KEYCODE_KP_DBLAMPERSAND;
  end;
  SDLK_KP_VERTICALBAR:begin
   result:=KEYCODE_KP_VERTICALBAR;
  end;
  SDLK_KP_DBLVERTICALBAR:begin
   result:=KEYCODE_KP_DBLVERTICALBAR;
  end;
  SDLK_KP_COLON:begin
   result:=KEYCODE_KP_COLON;
  end;
  SDLK_KP_COMMA:begin
   result:=KEYCODE_KP_COMMA;
  end;
  SDLK_KP_HASH:begin
   result:=KEYCODE_KP_HASH;
  end;
  SDLK_KP_SPACE:begin
   result:=KEYCODE_KP_SPACE;
  end;
  SDLK_KP_AT:begin
   result:=KEYCODE_KP_AT;
  end;
  SDLK_KP_EXCLAM:begin
   result:=KEYCODE_KP_EXCLAM;
  end;
  SDLK_KP_MEMSTORE:begin
   result:=KEYCODE_KP_MEMSTORE;
  end;
  SDLK_KP_MEMRECALL:begin
   result:=KEYCODE_KP_MEMRECALL;
  end;
  SDLK_KP_MEMCLEAR:begin
   result:=KEYCODE_KP_MEMCLEAR;
  end;
  SDLK_KP_MEMADD:begin
   result:=KEYCODE_KP_MEMADD;
  end;
  SDLK_KP_MEMSUBTRACT:begin
   result:=KEYCODE_KP_MEMSUBTRACT;
  end;
  SDLK_KP_MEMMULTIPLY:begin
   result:=KEYCODE_KP_MEMMULTIPLY;
  end;
  SDLK_KP_MEMDIVIDE:begin
   result:=KEYCODE_KP_MEMDIVIDE;
  end;
  SDLK_KP_PLUSMINUS:begin
   result:=KEYCODE_KP_PLUSMINUS;
  end;
  SDLK_KP_CLEAR:begin
   result:=KEYCODE_KP_CLEAR;
  end;
  SDLK_KP_CLEARENTRY:begin
   result:=KEYCODE_KP_CLEARENTRY;
  end;
  SDLK_KP_BINARY:begin
   result:=KEYCODE_KP_BINARY;
  end;
  SDLK_KP_OCTAL:begin
   result:=KEYCODE_KP_OCTAL;
  end;
  SDLK_KP_DECIMAL:begin
   result:=KEYCODE_KP_DECIMAL;
  end;
  SDLK_KP_HEXADECIMAL:begin
   result:=KEYCODE_KP_HEXADECIMAL;
  end;
  SDLK_LGUI:begin
   result:=KEYCODE_LGUI;
  end;
  SDLK_RGUI:begin
   result:=KEYCODE_RGUI;
  end;
  SDLK_AUDIONEXT:begin
   result:=KEYCODE_AUDIONEXT;
  end;
  SDLK_AUDIOPREV:begin
   result:=KEYCODE_AUDIOPREV;
  end;
  SDLK_AUDIOSTOP:begin
   result:=KEYCODE_AUDIOSTOP;
  end;
  SDLK_AUDIOPLAY:begin
   result:=KEYCODE_AUDIOPLAY;
  end;
  SDLK_AUDIOMUTE:begin
   result:=KEYCODE_AUDIOMUTE;
  end;
  SDLK_MEDIASELECT:begin
   result:=KEYCODE_MEDIASELECT;
  end;
  SDLK_WWW:begin
   result:=KEYCODE_WWW;
  end;
  SDLK_MAIL:begin
   result:=KEYCODE_MAIL;
  end;
  SDLK_CALCULATOR:begin
   result:=KEYCODE_CALCULATOR;
  end;
  SDLK_COMPUTER:begin
   result:=KEYCODE_COMPUTER;
  end;
  SDLK_AC_SEARCH:begin
   result:=KEYCODE_AC_SEARCH;
  end;
  SDLK_AC_HOME:begin
   result:=KEYCODE_AC_HOME;
  end;
  SDLK_AC_BACK:begin
   result:=KEYCODE_AC_BACK;
  end;
  SDLK_AC_FORWARD:begin
   result:=KEYCODE_AC_FORWARD;
  end;
  SDLK_AC_STOP:begin
   result:=KEYCODE_AC_STOP;
  end;
  SDLK_AC_REFRESH:begin
   result:=KEYCODE_AC_REFRESH;
  end;
  SDLK_AC_BOOKMARKS:begin
   result:=KEYCODE_AC_BOOKMARKS;
  end;
  SDLK_BRIGHTNESSDOWN:begin
   result:=KEYCODE_BRIGHTNESSDOWN;
  end;
  SDLK_BRIGHTNESSUP:begin
   result:=KEYCODE_BRIGHTNESSUP;
  end;
  SDLK_DISPLAYSWITCH:begin
   result:=KEYCODE_DISPLAYSWITCH;
  end;
  SDLK_KBDILLUMTOGGLE:begin
   result:=KEYCODE_KBDILLUMTOGGLE;
  end;
  SDLK_KBDILLUMDOWN:begin
   result:=KEYCODE_KBDILLUMDOWN;
  end;
  SDLK_KBDILLUMUP:begin
   result:=KEYCODE_KBDILLUMUP;
  end;
  SDLK_EJECT:begin
   result:=KEYCODE_EJECT;
  end;
  SDLK_SLEEP:begin
   result:=KEYCODE_SLEEP;
  end;
  else begin
   case aScanCode of
    SDL_SCANCODE_INTERNATIONAL1:begin
     result:=KEYCODE_INTERNATIONAL1;
    end;
    SDL_SCANCODE_INTERNATIONAL2:begin
     result:=KEYCODE_INTERNATIONAL2;
    end;
    SDL_SCANCODE_INTERNATIONAL3:begin
     result:=KEYCODE_INTERNATIONAL3;
    end;
    SDL_SCANCODE_INTERNATIONAL4:begin
     result:=KEYCODE_INTERNATIONAL4;
    end;
    SDL_SCANCODE_INTERNATIONAL5:begin
     result:=KEYCODE_INTERNATIONAL5;
    end;
    SDL_SCANCODE_INTERNATIONAL6:begin
     result:=KEYCODE_INTERNATIONAL6;
    end;
    SDL_SCANCODE_INTERNATIONAL7:begin
     result:=KEYCODE_INTERNATIONAL7;
    end;
    SDL_SCANCODE_INTERNATIONAL8:begin
     result:=KEYCODE_INTERNATIONAL8;
    end;
    SDL_SCANCODE_INTERNATIONAL9:begin
     result:=KEYCODE_INTERNATIONAL9;
    end;
    SDL_SCANCODE_LANG1:begin
     result:=KEYCODE_LANG1;
    end;
    SDL_SCANCODE_LANG2:begin
     result:=KEYCODE_LANG2;
    end;
    SDL_SCANCODE_LANG3:begin
     result:=KEYCODE_LANG3;
    end;
    SDL_SCANCODE_LANG4:begin
     result:=KEYCODE_LANG4;
    end;
    SDL_SCANCODE_LANG5:begin
     result:=KEYCODE_LANG5;
    end;
    SDL_SCANCODE_LANG6:begin
     result:=KEYCODE_LANG6;
    end;
    SDL_SCANCODE_LANG7:begin
     result:=KEYCODE_LANG7;
    end;
    SDL_SCANCODE_LANG8:begin
     result:=KEYCODE_LANG8;
    end;
    SDL_SCANCODE_LANG9:begin
     result:=KEYCODE_LANG9;
    end;
    SDL_SCANCODE_LOCKINGCAPSLOCK:begin
     result:=KEYCODE_LOCKINGCAPSLOCK;
    end;
    SDL_SCANCODE_LOCKINGNUMLOCK:begin
     result:=KEYCODE_LOCKINGNUMLOCK;
    end;
    SDL_SCANCODE_LOCKINGSCROLLLOCK:begin
     result:=KEYCODE_LOCKINGSCROLLLOCK;
    end;
    SDL_SCANCODE_NONUSBACKSLASH:begin
     result:=KEYCODE_NONUSBACKSLASH;
    end;
    SDL_SCANCODE_NONUSHASH:begin
     result:=KEYCODE_NONUSHASH;
    end;
    else begin
     result:=KEYCODE_UNKNOWN;
    end;
   end;
  end;
 end;
end;

function TpvApplicationInput.TranslateSDLScanCode(const aKeyCode,aScanCode:TpvInt32):TpvInt32;
begin
 case aScanCode of
  SDL_SCANCODE_BACKSPACE:begin
   result:=KEYCODE_BACKSPACE;
  end;
  SDL_SCANCODE_TAB:begin
   result:=KEYCODE_TAB;
  end;
  SDL_SCANCODE_RETURN:begin
   result:=KEYCODE_RETURN;
  end;
  SDL_SCANCODE_PAUSE:begin
   result:=KEYCODE_PAUSE;
  end;
  SDL_SCANCODE_ESCAPE:begin
   result:=KEYCODE_ESCAPE;
  end;
  SDL_SCANCODE_SPACE:begin
   result:=KEYCODE_SPACE;
  end;
{ SDL_SCANCODE_EXCLAIM:begin
   result:=KEYCODE_EXCLAIM;
  end;
  SDL_SCANCODE_QUOTEDBL:begin
   result:=KEYCODE_QUOTEDBL;
  end;
  SDL_SCANCODE_HASH:begin
   result:=KEYCODE_HASH;
  end;
  SDL_SCANCODE_DOLLAR:begin
   result:=KEYCODE_DOLLAR;
  end;
  SDL_SCANCODE_AMPERSAND:begin
   result:=KEYCODE_AMPERSAND;
  end;}
  SDL_SCANCODE_APOSTROPHE:begin
   result:=KEYCODE_APOSTROPHE;
  end;
{ SDL_SCANCODE_LEFTPAREN:begin
   result:=KEYCODE_LEFTPAREN;
  end;
  SDL_SCANCODE_RIGHTPAREN:begin
   result:=KEYCODE_RIGHTPAREN;
  end;
  SDL_SCANCODE_ASTERISK:begin
   result:=KEYCODE_ASTERISK;
  end;
  SDL_SCANCODE_PLUS:begin
   result:=KEYCODE_PLUS;
  end;}
  SDL_SCANCODE_COMMA:begin
   result:=KEYCODE_COMMA;
  end;
  SDL_SCANCODE_MINUS:begin
   result:=KEYCODE_MINUS;
  end;
  SDL_SCANCODE_PERIOD:begin
   result:=KEYCODE_PERIOD;
  end;
  SDL_SCANCODE_SLASH:begin
   result:=KEYCODE_SLASH;
  end;
  SDL_SCANCODE_0:begin
   result:=KEYCODE_0;
  end;
  SDL_SCANCODE_1:begin
   result:=KEYCODE_1;
  end;
  SDL_SCANCODE_2:begin
   result:=KEYCODE_2;
  end;
  SDL_SCANCODE_3:begin
   result:=KEYCODE_3;
  end;
  SDL_SCANCODE_4:begin
   result:=KEYCODE_4;
  end;
  SDL_SCANCODE_5:begin
   result:=KEYCODE_5;
  end;
  SDL_SCANCODE_6:begin
   result:=KEYCODE_6;
  end;
  SDL_SCANCODE_7:begin
   result:=KEYCODE_7;
  end;
  SDL_SCANCODE_8:begin
   result:=KEYCODE_8;
  end;
  SDL_SCANCODE_9:begin
   result:=KEYCODE_9;
  end;
{ SDL_SCANCODE_COLON:begin
   result:=KEYCODE_COLON;
  end;}
  SDL_SCANCODE_SEMICOLON:begin
   result:=KEYCODE_SEMICOLON;
  end;
{ SDL_SCANCODE_LESS:begin
   result:=KEYCODE_LESS;
  end;}
  SDL_SCANCODE_EQUALS:begin
   result:=KEYCODE_EQUALS;
  end;
{ SDL_SCANCODE_GREATER:begin
   result:=KEYCODE_GREATER;
  end;
  SDL_SCANCODE_QUESTION:begin
   result:=KEYCODE_QUESTION;
  end;
  SDL_SCANCODE_AT:begin
   result:=KEYCODE_AT;
  end;}
  SDL_SCANCODE_LEFTBRACKET:begin
   result:=KEYCODE_LEFTBRACKET;
  end;
  SDL_SCANCODE_BACKSLASH:begin
   result:=KEYCODE_BACKSLASH;
  end;
  SDL_SCANCODE_RIGHTBRACKET:begin
   result:=KEYCODE_RIGHTBRACKET;
  end;
{ SDL_SCANCODE_CARET:begin
   result:=KEYCODE_CARET;
  end;
  SDL_SCANCODE_UNDERSCORE:begin
   result:=KEYCODE_UNDERSCORE;
  end;
  SDL_SCANCODE_BACKQUOTE:begin
   result:=KEYCODE_BACKQUOTE;
  end;}
  SDL_SCANCODE_a:begin
   result:=KEYCODE_a;
  end;
  SDL_SCANCODE_b:begin
   result:=KEYCODE_b;
  end;
  SDL_SCANCODE_c:begin
   result:=KEYCODE_c;
  end;
  SDL_SCANCODE_d:begin
   result:=KEYCODE_d;
  end;
  SDL_SCANCODE_e:begin
   result:=KEYCODE_e;
  end;
  SDL_SCANCODE_f:begin
   result:=KEYCODE_f;
  end;
  SDL_SCANCODE_g:begin
   result:=KEYCODE_g;
  end;
  SDL_SCANCODE_h:begin
   result:=KEYCODE_h;
  end;
  SDL_SCANCODE_i:begin
   result:=KEYCODE_i;
  end;
  SDL_SCANCODE_j:begin
   result:=KEYCODE_j;
  end;
  SDL_SCANCODE_k:begin
   result:=KEYCODE_k;
  end;
  SDL_SCANCODE_l:begin
   result:=KEYCODE_l;
  end;
  SDL_SCANCODE_m:begin
   result:=KEYCODE_m;
  end;
  SDL_SCANCODE_n:begin
   result:=KEYCODE_n;
  end;
  SDL_SCANCODE_o:begin
   result:=KEYCODE_o;
  end;
  SDL_SCANCODE_p:begin
   result:=KEYCODE_p;
  end;
  SDL_SCANCODE_q:begin
   result:=KEYCODE_q;
  end;
  SDL_SCANCODE_r:begin
   result:=KEYCODE_r;
  end;
  SDL_SCANCODE_s:begin
   result:=KEYCODE_s;
  end;
  SDL_SCANCODE_t:begin
   result:=KEYCODE_t;
  end;
  SDL_SCANCODE_u:begin
   result:=KEYCODE_u;
  end;
  SDL_SCANCODE_v:begin
   result:=KEYCODE_v;
  end;
  SDL_SCANCODE_w:begin
   result:=KEYCODE_w;
  end;
  SDL_SCANCODE_x:begin
   result:=KEYCODE_x;
  end;
  SDL_SCANCODE_y:begin
   result:=KEYCODE_y;
  end;
  SDL_SCANCODE_z:begin
   result:=KEYCODE_z;
  end;
{ SDL_SCANCODE_LEFTBRACE:begin
   result:=KEYCODE_LEFTBRACE;
  end;
  SDL_SCANCODE_PIPE:begin
   result:=KEYCODE_PIPE;
  end;
  SDL_SCANCODE_RIGHTBRACE:begin
   result:=KEYCODE_RIGHTBRACE;
  end;}
  SDL_SCANCODE_GRAVE:begin
   result:=KEYCODE_GRAVE;
  end;
  SDL_SCANCODE_DELETE:begin
   result:=KEYCODE_DELETE;
  end;
  SDL_SCANCODE_F1:begin
   result:=KEYCODE_F1;
  end;
  SDL_SCANCODE_F2:begin
   result:=KEYCODE_F2;
  end;
  SDL_SCANCODE_F3:begin
   result:=KEYCODE_F3;
  end;
  SDL_SCANCODE_F4:begin
   result:=KEYCODE_F4;
  end;
  SDL_SCANCODE_F5:begin
   result:=KEYCODE_F5;
  end;
  SDL_SCANCODE_F6:begin
   result:=KEYCODE_F6;
  end;
  SDL_SCANCODE_F7:begin
   result:=KEYCODE_F7;
  end;
  SDL_SCANCODE_F8:begin
   result:=KEYCODE_F8;
  end;
  SDL_SCANCODE_F9:begin
   result:=KEYCODE_F9;
  end;
  SDL_SCANCODE_F10:begin
   result:=KEYCODE_F10;
  end;
  SDL_SCANCODE_F11:begin
   result:=KEYCODE_F11;
  end;
  SDL_SCANCODE_F12:begin
   result:=KEYCODE_F12;
  end;
  SDL_SCANCODE_F13:begin
   result:=KEYCODE_F13;
  end;
  SDL_SCANCODE_F14:begin
   result:=KEYCODE_F14;
  end;
  SDL_SCANCODE_F15:begin
   result:=KEYCODE_F15;
  end;
  SDL_SCANCODE_F16:begin
   result:=KEYCODE_F16;
  end;
  SDL_SCANCODE_F17:begin
   result:=KEYCODE_F17;
  end;
  SDL_SCANCODE_F18:begin
   result:=KEYCODE_F18;
  end;
  SDL_SCANCODE_F19:begin
   result:=KEYCODE_F19;
  end;
  SDL_SCANCODE_F20:begin
   result:=KEYCODE_F20;
  end;
  SDL_SCANCODE_F21:begin
   result:=KEYCODE_F21;
  end;
  SDL_SCANCODE_F22:begin
   result:=KEYCODE_F22;
  end;
  SDL_SCANCODE_F23:begin
   result:=KEYCODE_F23;
  end;
  SDL_SCANCODE_F24:begin
   result:=KEYCODE_F24;
  end;
  SDL_SCANCODE_KP_0:begin
   result:=KEYCODE_KP0;
  end;
  SDL_SCANCODE_KP_1:begin
   result:=KEYCODE_KP1;
  end;
  SDL_SCANCODE_KP_2:begin
   result:=KEYCODE_KP2;
  end;
  SDL_SCANCODE_KP_3:begin
   result:=KEYCODE_KP3;
  end;
  SDL_SCANCODE_KP_4:begin
   result:=KEYCODE_KP4;
  end;
  SDL_SCANCODE_KP_5:begin
   result:=KEYCODE_KP5;
  end;
  SDL_SCANCODE_KP_6:begin
   result:=KEYCODE_KP6;
  end;
  SDL_SCANCODE_KP_7:begin
   result:=KEYCODE_KP7;
  end;
  SDL_SCANCODE_KP_8:begin
   result:=KEYCODE_KP8;
  end;
  SDL_SCANCODE_KP_9:begin
   result:=KEYCODE_KP9;
  end;
  SDL_SCANCODE_KP_PERIOD:begin
   result:=KEYCODE_KP_PERIOD;
  end;
  SDL_SCANCODE_KP_DIVIDE:begin
   result:=KEYCODE_KP_DIVIDE;
  end;
  SDL_SCANCODE_KP_MULTIPLY:begin
   result:=KEYCODE_KP_MULTIPLY;
  end;
  SDL_SCANCODE_KP_MINUS:begin
   result:=KEYCODE_KP_MINUS;
  end;
  SDL_SCANCODE_KP_PLUS:begin
   result:=KEYCODE_KP_PLUS;
  end;
  SDL_SCANCODE_KP_ENTER:begin
   result:=KEYCODE_KP_ENTER;
  end;
  SDL_SCANCODE_KP_EQUALS:begin
   result:=KEYCODE_KP_EQUALS;
  end;
  SDL_SCANCODE_UP:begin
   result:=KEYCODE_UP;
  end;
  SDL_SCANCODE_DOWN:begin
   result:=KEYCODE_DOWN;
  end;
  SDL_SCANCODE_RIGHT:begin
   result:=KEYCODE_RIGHT;
  end;
  SDL_SCANCODE_LEFT:begin
   result:=KEYCODE_LEFT;
  end;
  SDL_SCANCODE_INSERT:begin
   result:=KEYCODE_INSERT;
  end;
  SDL_SCANCODE_HOME:begin
   result:=KEYCODE_HOME;
  end;
  SDL_SCANCODE_END:begin
   result:=KEYCODE_END;
  end;
  SDL_SCANCODE_PAGEUP:begin
   result:=KEYCODE_PAGEUP;
  end;
  SDL_SCANCODE_PAGEDOWN:begin
   result:=KEYCODE_PAGEDOWN;
  end;
  SDL_SCANCODE_CAPSLOCK:begin
   result:=KEYCODE_CAPSLOCK;
  end;
  SDL_SCANCODE_NUMLOCKCLEAR:begin
   result:=KEYCODE_NUMLOCK;
  end;
  SDL_SCANCODE_SCROLLLOCK:begin
   result:=KEYCODE_SCROLLLOCK;
  end;
  SDL_SCANCODE_RSHIFT:begin
   result:=KEYCODE_RSHIFT;
  end;
  SDL_SCANCODE_LSHIFT:begin
   result:=KEYCODE_LSHIFT;
  end;
  SDL_SCANCODE_RCTRL:begin
   result:=KEYCODE_RCTRL;
  end;
  SDL_SCANCODE_LCTRL:begin
   result:=KEYCODE_LCTRL;
  end;
  SDL_SCANCODE_RALT:begin
   result:=KEYCODE_RALT;
  end;
  SDL_SCANCODE_LALT:begin
   result:=KEYCODE_LALT;
  end;
  SDL_SCANCODE_MODE:begin
   result:=KEYCODE_MODE;
  end;
  SDL_SCANCODE_HELP:begin
   result:=KEYCODE_HELP;
  end;
  SDL_SCANCODE_PRINTSCREEN:begin
   result:=KEYCODE_PRINTSCREEN;
  end;
  SDL_SCANCODE_SYSREQ:begin
   result:=KEYCODE_SYSREQ;
  end;
  SDL_SCANCODE_MENU:begin
   result:=KEYCODE_MENU;
  end;
  SDL_SCANCODE_POWER:begin
   result:=KEYCODE_POWER;
  end;
  SDL_SCANCODE_APPLICATION:begin
   result:=KEYCODE_APPLICATION;
  end;
  SDL_SCANCODE_SELECT:begin
   result:=KEYCODE_SELECT;
  end;
  SDL_SCANCODE_STOP:begin
   result:=KEYCODE_STOP;
  end;
  SDL_SCANCODE_AGAIN:begin
   result:=KEYCODE_AGAIN;
  end;
  SDL_SCANCODE_UNDO:begin
   result:=KEYCODE_UNDO;
  end;
  SDL_SCANCODE_CUT:begin
   result:=KEYCODE_CUT;
  end;
  SDL_SCANCODE_COPY:begin
   result:=KEYCODE_COPY;
  end;
  SDL_SCANCODE_PASTE:begin
   result:=KEYCODE_PASTE;
  end;
  SDL_SCANCODE_FIND:begin
   result:=KEYCODE_FIND;
  end;
  SDL_SCANCODE_MUTE:begin
   result:=KEYCODE_MUTE;
  end;
  SDL_SCANCODE_VOLUMEUP:begin
   result:=KEYCODE_VOLUMEUP;
  end;
  SDL_SCANCODE_VOLUMEDOWN:begin
   result:=KEYCODE_VOLUMEDOWN;
  end;
  SDL_SCANCODE_KP_EQUALSAS400:begin
   result:=KEYCODE_KP_EQUALSAS400;
  end;
  SDL_SCANCODE_ALTERASE:begin
   result:=KEYCODE_ALTERASE;
  end;
  SDL_SCANCODE_CANCEL:begin
   result:=KEYCODE_CANCEL;
  end;
  SDL_SCANCODE_CLEAR:begin
   result:=KEYCODE_CLEAR;
  end;
  SDL_SCANCODE_PRIOR:begin
   result:=KEYCODE_PRIOR;
  end;
  SDL_SCANCODE_RETURN2:begin
   result:=KEYCODE_RETURN2;
  end;
  SDL_SCANCODE_SEPARATOR:begin
   result:=KEYCODE_SEPARATOR;
  end;
  SDL_SCANCODE_OUT:begin
   result:=KEYCODE_OUT;
  end;
  SDL_SCANCODE_OPER:begin
   result:=KEYCODE_OPER;
  end;
  SDL_SCANCODE_CLEARAGAIN:begin
   result:=KEYCODE_CLEARAGAIN;
  end;
  SDL_SCANCODE_CRSEL:begin
   result:=KEYCODE_CRSEL;
  end;
  SDL_SCANCODE_EXSEL:begin
   result:=KEYCODE_EXSEL;
  end;
  SDL_SCANCODE_KP_00:begin
   result:=KEYCODE_KP_00;
  end;
  SDL_SCANCODE_KP_000:begin
   result:=KEYCODE_KP_000;
  end;
  SDL_SCANCODE_THOUSANDSSEPARATOR:begin
   result:=KEYCODE_THOUSANDSSEPARATOR;
  end;
  SDL_SCANCODE_DECIMALSEPARATOR:begin
   result:=KEYCODE_DECIMALSEPARATOR;
  end;
  SDL_SCANCODE_CURRENCYUNIT:begin
   result:=KEYCODE_CURRENCYUNIT;
  end;
  SDL_SCANCODE_CURRENCYSUBUNIT:begin
   result:=KEYCODE_CURRENCYSUBUNIT;
  end;
  SDL_SCANCODE_KP_LEFTPAREN:begin
   result:=KEYCODE_KP_LEFTPAREN;
  end;
  SDL_SCANCODE_KP_RIGHTPAREN:begin
   result:=KEYCODE_KP_RIGHTPAREN;
  end;
  SDL_SCANCODE_KP_LEFTBRACE:begin
   result:=KEYCODE_KP_LEFTBRACE;
  end;
  SDL_SCANCODE_KP_RIGHTBRACE:begin
   result:=KEYCODE_KP_RIGHTBRACE;
  end;
  SDL_SCANCODE_KP_TAB:begin
   result:=KEYCODE_KP_TAB;
  end;
  SDL_SCANCODE_KP_BACKSPACE:begin
   result:=KEYCODE_KP_BACKSPACE;
  end;
  SDL_SCANCODE_KP_A:begin
   result:=KEYCODE_KP_A;
  end;
  SDL_SCANCODE_KP_B:begin
   result:=KEYCODE_KP_B;
  end;
  SDL_SCANCODE_KP_C:begin
   result:=KEYCODE_KP_C;
  end;
  SDL_SCANCODE_KP_D:begin
   result:=KEYCODE_KP_D;
  end;
  SDL_SCANCODE_KP_E:begin
   result:=KEYCODE_KP_E;
  end;
  SDL_SCANCODE_KP_F:begin
   result:=KEYCODE_KP_F;
  end;
  SDL_SCANCODE_KP_XOR:begin
   result:=KEYCODE_KP_XOR;
  end;
  SDL_SCANCODE_KP_POWER:begin
   result:=KEYCODE_KP_POWER;
  end;
  SDL_SCANCODE_KP_PERCENT:begin
   result:=KEYCODE_KP_PERCENT;
  end;
  SDL_SCANCODE_KP_LESS:begin
   result:=KEYCODE_KP_LESS;
  end;
  SDL_SCANCODE_KP_GREATER:begin
   result:=KEYCODE_KP_GREATER;
  end;
  SDL_SCANCODE_KP_AMPERSAND:begin
   result:=KEYCODE_KP_AMPERSAND;
  end;
  SDL_SCANCODE_KP_DBLAMPERSAND:begin
   result:=KEYCODE_KP_DBLAMPERSAND;
  end;
  SDL_SCANCODE_KP_VERTICALBAR:begin
   result:=KEYCODE_KP_VERTICALBAR;
  end;
  SDL_SCANCODE_KP_DBLVERTICALBAR:begin
   result:=KEYCODE_KP_DBLVERTICALBAR;
  end;
  SDL_SCANCODE_KP_COLON:begin
   result:=KEYCODE_KP_COLON;
  end;
  SDL_SCANCODE_KP_COMMA:begin
   result:=KEYCODE_KP_COMMA;
  end;
  SDL_SCANCODE_KP_HASH:begin
   result:=KEYCODE_KP_HASH;
  end;
  SDL_SCANCODE_KP_SPACE:begin
   result:=KEYCODE_KP_SPACE;
  end;
  SDL_SCANCODE_KP_AT:begin
   result:=KEYCODE_KP_AT;
  end;
  SDL_SCANCODE_KP_EXCLAM:begin
   result:=KEYCODE_KP_EXCLAM;
  end;
  SDL_SCANCODE_KP_MEMSTORE:begin
   result:=KEYCODE_KP_MEMSTORE;
  end;
  SDL_SCANCODE_KP_MEMRECALL:begin
   result:=KEYCODE_KP_MEMRECALL;
  end;
  SDL_SCANCODE_KP_MEMCLEAR:begin
   result:=KEYCODE_KP_MEMCLEAR;
  end;
  SDL_SCANCODE_KP_MEMADD:begin
   result:=KEYCODE_KP_MEMADD;
  end;
  SDL_SCANCODE_KP_MEMSUBTRACT:begin
   result:=KEYCODE_KP_MEMSUBTRACT;
  end;
  SDL_SCANCODE_KP_MEMMULTIPLY:begin
   result:=KEYCODE_KP_MEMMULTIPLY;
  end;
  SDL_SCANCODE_KP_MEMDIVIDE:begin
   result:=KEYCODE_KP_MEMDIVIDE;
  end;
  SDL_SCANCODE_KP_PLUSMINUS:begin
   result:=KEYCODE_KP_PLUSMINUS;
  end;
  SDL_SCANCODE_KP_CLEAR:begin
   result:=KEYCODE_KP_CLEAR;
  end;
  SDL_SCANCODE_KP_CLEARENTRY:begin
   result:=KEYCODE_KP_CLEARENTRY;
  end;
  SDL_SCANCODE_KP_BINARY:begin
   result:=KEYCODE_KP_BINARY;
  end;
  SDL_SCANCODE_KP_OCTAL:begin
   result:=KEYCODE_KP_OCTAL;
  end;
  SDL_SCANCODE_KP_DECIMAL:begin
   result:=KEYCODE_KP_DECIMAL;
  end;
  SDL_SCANCODE_KP_HEXADECIMAL:begin
   result:=KEYCODE_KP_HEXADECIMAL;
  end;
  SDL_SCANCODE_LGUI:begin
   result:=KEYCODE_LGUI;
  end;
  SDL_SCANCODE_RGUI:begin
   result:=KEYCODE_RGUI;
  end;
  SDL_SCANCODE_AUDIONEXT:begin
   result:=KEYCODE_AUDIONEXT;
  end;
  SDL_SCANCODE_AUDIOPREV:begin
   result:=KEYCODE_AUDIOPREV;
  end;
  SDL_SCANCODE_AUDIOSTOP:begin
   result:=KEYCODE_AUDIOSTOP;
  end;
  SDL_SCANCODE_AUDIOPLAY:begin
   result:=KEYCODE_AUDIOPLAY;
  end;
  SDL_SCANCODE_AUDIOMUTE:begin
   result:=KEYCODE_AUDIOMUTE;
  end;
  SDL_SCANCODE_MEDIASELECT:begin
   result:=KEYCODE_MEDIASELECT;
  end;
  SDL_SCANCODE_WWW:begin
   result:=KEYCODE_WWW;
  end;
  SDL_SCANCODE_MAIL:begin
   result:=KEYCODE_MAIL;
  end;
  SDL_SCANCODE_CALCULATOR:begin
   result:=KEYCODE_CALCULATOR;
  end;
  SDL_SCANCODE_COMPUTER:begin
   result:=KEYCODE_COMPUTER;
  end;
  SDL_SCANCODE_AC_SEARCH:begin
   result:=KEYCODE_AC_SEARCH;
  end;
  SDL_SCANCODE_AC_HOME:begin
   result:=KEYCODE_AC_HOME;
  end;
  SDL_SCANCODE_AC_BACK:begin
   result:=KEYCODE_AC_BACK;
  end;
  SDL_SCANCODE_AC_FORWARD:begin
   result:=KEYCODE_AC_FORWARD;
  end;
  SDL_SCANCODE_AC_STOP:begin
   result:=KEYCODE_AC_STOP;
  end;
  SDL_SCANCODE_AC_REFRESH:begin
   result:=KEYCODE_AC_REFRESH;
  end;
  SDL_SCANCODE_AC_BOOKMARKS:begin
   result:=KEYCODE_AC_BOOKMARKS;
  end;
  SDL_SCANCODE_BRIGHTNESSDOWN:begin
   result:=KEYCODE_BRIGHTNESSDOWN;
  end;
  SDL_SCANCODE_BRIGHTNESSUP:begin
   result:=KEYCODE_BRIGHTNESSUP;
  end;
  SDL_SCANCODE_DISPLAYSWITCH:begin
   result:=KEYCODE_DISPLAYSWITCH;
  end;
  SDL_SCANCODE_KBDILLUMTOGGLE:begin
   result:=KEYCODE_KBDILLUMTOGGLE;
  end;
  SDL_SCANCODE_KBDILLUMDOWN:begin
   result:=KEYCODE_KBDILLUMDOWN;
  end;
  SDL_SCANCODE_KBDILLUMUP:begin
   result:=KEYCODE_KBDILLUMUP;
  end;
  SDL_SCANCODE_EJECT:begin
   result:=KEYCODE_EJECT;
  end;
  SDL_SCANCODE_SLEEP:begin
   result:=KEYCODE_SLEEP;
  end;
  SDL_SCANCODE_INTERNATIONAL1:begin
   result:=KEYCODE_INTERNATIONAL1;
  end;
  SDL_SCANCODE_INTERNATIONAL2:begin
   result:=KEYCODE_INTERNATIONAL2;
  end;
  SDL_SCANCODE_INTERNATIONAL3:begin
   result:=KEYCODE_INTERNATIONAL3;
  end;
  SDL_SCANCODE_INTERNATIONAL4:begin
   result:=KEYCODE_INTERNATIONAL4;
  end;
  SDL_SCANCODE_INTERNATIONAL5:begin
   result:=KEYCODE_INTERNATIONAL5;
  end;
  SDL_SCANCODE_INTERNATIONAL6:begin
   result:=KEYCODE_INTERNATIONAL6;
  end;
  SDL_SCANCODE_INTERNATIONAL7:begin
   result:=KEYCODE_INTERNATIONAL7;
  end;
  SDL_SCANCODE_INTERNATIONAL8:begin
   result:=KEYCODE_INTERNATIONAL8;
  end;
  SDL_SCANCODE_INTERNATIONAL9:begin
   result:=KEYCODE_INTERNATIONAL9;
  end;
  SDL_SCANCODE_LANG1:begin
   result:=KEYCODE_LANG1;
  end;
  SDL_SCANCODE_LANG2:begin
   result:=KEYCODE_LANG2;
  end;
  SDL_SCANCODE_LANG3:begin
   result:=KEYCODE_LANG3;
  end;
  SDL_SCANCODE_LANG4:begin
   result:=KEYCODE_LANG4;
  end;
  SDL_SCANCODE_LANG5:begin
   result:=KEYCODE_LANG5;
  end;
  SDL_SCANCODE_LANG6:begin
   result:=KEYCODE_LANG6;
  end;
  SDL_SCANCODE_LANG7:begin
   result:=KEYCODE_LANG7;
  end;
  SDL_SCANCODE_LANG8:begin
   result:=KEYCODE_LANG8;
  end;
  SDL_SCANCODE_LANG9:begin
   result:=KEYCODE_LANG9;
  end;
  SDL_SCANCODE_LOCKINGCAPSLOCK:begin
   result:=KEYCODE_LOCKINGCAPSLOCK;
  end;
  SDL_SCANCODE_LOCKINGNUMLOCK:begin
   result:=KEYCODE_LOCKINGNUMLOCK;
  end;
  SDL_SCANCODE_LOCKINGSCROLLLOCK:begin
   result:=KEYCODE_LOCKINGSCROLLLOCK;
  end;
  SDL_SCANCODE_NONUSBACKSLASH:begin
   result:=KEYCODE_NONUSBACKSLASH;
  end;
  SDL_SCANCODE_NONUSHASH:begin
   result:=KEYCODE_NONUSHASH;
  end;
  else begin
   result:=KEYCODE_UNKNOWN;
  end;
 end;
end;

function TpvApplicationInput.TranslateSDLKeyModifier(const aKeyModifier:TpvInt32):TpvApplicationInputKeyModifiers;
begin
 result:=[];
 if (aKeyModifier and PasVulkan.SDL2.KMOD_LSHIFT)<>0 then begin
  Include(result,TpvApplicationInputKeyModifier.LSHIFT);
  Include(result,TpvApplicationInputKeyModifier.SHIFT);
 end;
 if (aKeyModifier and PasVulkan.SDL2.KMOD_RSHIFT)<>0 then begin
  Include(result,TpvApplicationInputKeyModifier.RSHIFT);
  Include(result,TpvApplicationInputKeyModifier.SHIFT);
 end;
 if (aKeyModifier and PasVulkan.SDL2.KMOD_LCTRL)<>0 then begin
  Include(result,TpvApplicationInputKeyModifier.LCTRL);
  Include(result,TpvApplicationInputKeyModifier.CTRL);
 end;
 if (aKeyModifier and PasVulkan.SDL2.KMOD_RCTRL)<>0 then begin
  Include(result,TpvApplicationInputKeyModifier.RCTRL);
  Include(result,TpvApplicationInputKeyModifier.CTRL);
 end;
 if (aKeyModifier and PasVulkan.SDL2.KMOD_LALT)<>0 then begin
  Include(result,TpvApplicationInputKeyModifier.LALT);
  Include(result,TpvApplicationInputKeyModifier.ALT);
 end;
 if (aKeyModifier and PasVulkan.SDL2.KMOD_RALT)<>0 then begin
  Include(result,TpvApplicationInputKeyModifier.RALT);
  Include(result,TpvApplicationInputKeyModifier.ALT);
 end;
 if (aKeyModifier and PasVulkan.SDL2.KMOD_LMETA)<>0 then begin
  Include(result,TpvApplicationInputKeyModifier.LMETA);
  Include(result,TpvApplicationInputKeyModifier.META);
 end;
 if (aKeyModifier and PasVulkan.SDL2.KMOD_RMETA)<>0 then begin
  Include(result,TpvApplicationInputKeyModifier.RMETA);
  Include(result,TpvApplicationInputKeyModifier.META);
 end;
 if (aKeyModifier and PasVulkan.SDL2.KMOD_NUM)<>0 then begin
  Include(result,TpvApplicationInputKeyModifier.NUM);
 end;
 if (aKeyModifier and PasVulkan.SDL2.KMOD_CAPS)<>0 then begin
  Include(result,TpvApplicationInputKeyModifier.CAPS);
 end;
 if (aKeyModifier and PasVulkan.SDL2.KMOD_MODE)<>0 then begin
  Include(result,TpvApplicationInputKeyModifier.MODE);
 end;
 if (aKeyModifier and PasVulkan.SDL2.KMOD_RESERVED)<>0 then begin
  Include(result,TpvApplicationInputKeyModifier.RESERVED);
 end;
end;

const SDL_KEYTYPED=$30000;

{$else}
{$ifend}

procedure TpvApplicationInput.AddEvent(const aEvent:TpvApplicationEvent);
begin
 if fEventCount>=length(fEvents) then begin
  SetLength(fEvents,(fEventCount+1)*2);
  SetLength(fEventTimes,(fEventCount+1)*2);
 end;
 fEvents[fEventCount]:=aEvent;
 fEventTimes[fEventCount]:=pvApplication.fHighResolutionTimer.ToNanoseconds(pvApplication.fHighResolutionTimer.GetTime);
 inc(fEventCount);
end;

procedure TpvApplicationInput.ProcessEvents;
{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
var Index,PointerID,KeyCode,ScanCode,Position:TpvInt32;
    KeyModifiers:TpvApplicationInputKeyModifiers;
    Event:PpvApplicationEvent;
    SDLEvent:PSDL_Event;
    OK:boolean;
    KeyShortcut:TpvApplicationInputKeyShortcut;
begin
 fCriticalSection.Acquire;
 try
  fJustTouched:=false;
  if fEventCount>0 then begin
   for Index:=0 to fEventCount-1 do begin
    Event:=@fEvents[Index];
    SDLEvent:=@Event^.SDLEvent;
    fCurrentEventTime:=fEventTimes[fEventCount];
    case SDLEvent^.type_ of
     SDL_QUITEV:begin
      KeyShortcut:=nil;
      if (not pvApplication.KeyEvent(TpvApplicationInputKeyEvent.Create(TpvApplicationInputKeyEventType.Down,KEYCODE_QUIT,KEYCODE_QUIT,[],KeyShortcut))) and assigned(fProcessor) then begin
       fProcessor.KeyEvent(TpvApplicationInputKeyEvent.Create(TpvApplicationInputKeyEventType.Down,KEYCODE_QUIT,KEYCODE_QUIT,[],KeyShortcut));
      end;
      if (not pvApplication.KeyEvent(TpvApplicationInputKeyEvent.Create(TpvApplicationInputKeyEventType.Typed,KEYCODE_QUIT,KEYCODE_QUIT,[],KeyShortcut))) and assigned(fProcessor) then begin
       fProcessor.KeyEvent(TpvApplicationInputKeyEvent.Create(TpvApplicationInputKeyEventType.Typed,KEYCODE_QUIT,KEYCODE_QUIT,[],KeyShortcut));
      end;
      if (not pvApplication.KeyEvent(TpvApplicationInputKeyEvent.Create(TpvApplicationInputKeyEventType.Up,KEYCODE_QUIT,KEYCODE_QUIT,[],KeyShortcut))) and assigned(fProcessor) then begin
       fProcessor.KeyEvent(TpvApplicationInputKeyEvent.Create(TpvApplicationInputKeyEventType.Up,KEYCODE_QUIT,KEYCODE_QUIT,[],KeyShortcut));
      end;
     end;
     SDL_DROPFILE:begin
      try
       if (not pvApplication.DragDropFileEvent(Event^.StringData)) and assigned(fProcessor) then begin
        fProcessor.DragDropFileEvent(Event^.StringData);
       end;
      finally
       Event^.StringData:='';
      end;
     end;
     SDL_KEYDOWN,SDL_KEYUP,SDL_KEYTYPED:begin
      KeyCode:=TranslateSDLKeyCode(SDLEvent^.key.keysym.sym,SDLEvent^.key.keysym.scancode);
      ScanCode:=TranslateSDLScanCode(SDLEvent^.key.keysym.sym,SDLEvent^.key.keysym.scancode);
      KeyModifiers:=TranslateSDLKeyModifier(SDLEvent^.key.keysym.modifier);
      KeyShortcut:=GetKeyShortCut(KeyCode,ScanCode,KeyModifiers);
      case SDLEvent^.type_ of
       SDL_KEYDOWN:begin
        fKeyDown[KeyCode and $ffff]:=true;
        inc(fKeyDownCount);
        fJustKeyDown[KeyCode and $ffff]:=true;
        if (not pvApplication.KeyEvent(TpvApplicationInputKeyEvent.Create(TpvApplicationInputKeyEventType.Down,KeyCode,ScanCode,KeyModifiers,KeyShortcut))) and assigned(fProcessor) then begin
         fProcessor.KeyEvent(TpvApplicationInputKeyEvent.Create(TpvApplicationInputKeyEventType.Down,KeyCode,ScanCode,KeyModifiers,KeyShortcut));
        end;
       end;
       SDL_KEYUP:begin
        fKeyDown[KeyCode and $ffff]:=false;
        if fKeyDownCount>0 then begin
         dec(fKeyDownCount);
        end;
        fJustKeyDown[KeyCode and $ffff]:=false;
        if (not pvApplication.KeyEvent(TpvApplicationInputKeyEvent.Create(TpvApplicationInputKeyEventType.Up,KeyCode,ScanCode,KeyModifiers,KeyShortcut))) and assigned(fProcessor) then begin
         fProcessor.KeyEvent(TpvApplicationInputKeyEvent.Create(TpvApplicationInputKeyEventType.Up,KeyCode,ScanCode,KeyModifiers,KeyShortcut));
        end;
       end;
       SDL_KEYTYPED:begin
        if (not pvApplication.KeyEvent(TpvApplicationInputKeyEvent.Create(TpvApplicationInputKeyEventType.Typed,KeyCode,ScanCode,KeyModifiers,KeyShortcut))) and assigned(fProcessor) then begin
         fProcessor.KeyEvent(TpvApplicationInputKeyEvent.Create(TpvApplicationInputKeyEventType.Typed,KeyCode,ScanCode,KeyModifiers,KeyShortcut));
        end;
       end;
      end;
     end;
     SDL_TEXTINPUT:begin
      KeyModifiers:=[];
      Position:=0;
      while Position<length(SDLEvent^.tedit.text) do begin
       KeyCode:=PUCUUTF8PtrCodeUnitGetCharAndIncFallback(PAnsiChar(TpvPointer(@SDLEvent^.tedit.text[0])),length(SDLEvent^.tedit.text),Position);
       case KeyCode of
        0:begin
         break;
        end;
        else begin
         ScanCode:=0;
         KeyShortcut:=GetKeyShortCut(KeyCode,ScanCode,KeyModifiers);
         if (not pvApplication.KeyEvent(TpvApplicationInputKeyEvent.Create(TpvApplicationInputKeyEventType.Unicode,KeyCode,ScanCode,KeyModifiers,KeyShortcut))) and assigned(fProcessor) then begin
          fProcessor.KeyEvent(TpvApplicationInputKeyEvent.Create(TpvApplicationInputKeyEventType.Unicode,KeyCode,ScanCode,KeyModifiers,KeyShortcut));
         end;
        end;
       end;
      end;
     end;
     SDL_MOUSEMOTION:begin
      KeyModifiers:=GetKeyModifiers;
      fMouseX:=SDLEvent^.motion.x;
      fMouseY:=SDLEvent^.motion.y;
      fMouseDeltaX:=SDLEvent^.motion.xrel;
      fMouseDeltaY:=SDLEvent^.motion.yrel;
      OK:=pvApplication.PointerEvent(TpvApplicationInputPointerEvent.Create(TpvApplicationInputPointerEventType.Motion,
                                                                            TpvVector2.Create(SDLEvent^.motion.x,SDLEvent^.motion.y),
                                                                            TpvVector2.Create(SDLEvent^.motion.xrel,SDLEvent^.motion.yrel),
                                                                            ord(fMouseDown<>[]) and 1,
                                                                            0,
                                                                            fMouseDown,
                                                                            KeyModifiers));
      if assigned(fProcessor) and not OK then begin
       fProcessor.PointerEvent(TpvApplicationInputPointerEvent.Create(TpvApplicationInputPointerEventType.Motion,
                                                                      TpvVector2.Create(SDLEvent^.motion.x,SDLEvent^.motion.y),
                                                                      TpvVector2.Create(SDLEvent^.motion.xrel,SDLEvent^.motion.yrel),
                                                                      ord(fMouseDown<>[]) and 1,
                                                                      0,
                                                                      fMouseDown,
                                                                      KeyModifiers));
      end;
     end;
     SDL_MOUSEBUTTONDOWN:begin
      KeyModifiers:=GetKeyModifiers;
      fMaxPointerID:=max(fMaxPointerID,0);
 {    fMouseDeltaX:=SDLEvent^.button.x-fMouseX;
      fMouseDeltaY:=SDLEvent^.button.y-fMouseY;}
      fMouseX:=SDLEvent^.button.x;
      fMouseY:=SDLEvent^.button.y;
      case SDLEvent^.button.button of
       SDL_BUTTON_LEFT:begin
        Include(fMouseDown,TpvApplicationInputPointerButton.Left);
        Include(fMouseJustDown,TpvApplicationInputPointerButton.Left);
        fJustTouched:=true;
        if (not pvApplication.PointerEvent(TpvApplicationInputPointerEvent.Create(TpvApplicationInputPointerEventType.Down,TpvVector2.Create(SDLEvent^.motion.x,SDLEvent^.motion.y),1.0,0,TpvApplicationInputPointerButton.Left,fMouseDown,KeyModifiers))) and assigned(fProcessor) then begin
         fProcessor.PointerEvent(TpvApplicationInputPointerEvent.Create(TpvApplicationInputPointerEventType.Down,TpvVector2.Create(SDLEvent^.motion.x,SDLEvent^.motion.y),1.0,0,TpvApplicationInputPointerButton.Left,fMouseDown,KeyModifiers));
        end;
       end;
       SDL_BUTTON_RIGHT:begin
        Include(fMouseDown,TpvApplicationInputPointerButton.Right);
        Include(fMouseJustDown,TpvApplicationInputPointerButton.Right);
        fJustTouched:=true;
        if (not pvApplication.PointerEvent(TpvApplicationInputPointerEvent.Create(TpvApplicationInputPointerEventType.Down,TpvVector2.Create(SDLEvent^.motion.x,SDLEvent^.motion.y),1.0,0,TpvApplicationInputPointerButton.Right,fMouseDown,KeyModifiers))) and assigned(fProcessor) then begin
         fProcessor.PointerEvent(TpvApplicationInputPointerEvent.Create(TpvApplicationInputPointerEventType.Down,TpvVector2.Create(SDLEvent^.motion.x,SDLEvent^.motion.y),1.0,0,TpvApplicationInputPointerButton.Right,fMouseDown,KeyModifiers));
        end;
       end;
       SDL_BUTTON_MIDDLE:begin
        Include(fMouseDown,TpvApplicationInputPointerButton.Middle);
        Include(fMouseJustDown,TpvApplicationInputPointerButton.Middle);
        fJustTouched:=true;
        if (not pvApplication.PointerEvent(TpvApplicationInputPointerEvent.Create(TpvApplicationInputPointerEventType.Down,TpvVector2.Create(SDLEvent^.motion.x,SDLEvent^.motion.y),1.0,0,TpvApplicationInputPointerButton.Middle,fMouseDown,KeyModifiers))) and assigned(fProcessor) then begin
         fProcessor.PointerEvent(TpvApplicationInputPointerEvent.Create(TpvApplicationInputPointerEventType.Down,TpvVector2.Create(SDLEvent^.motion.x,SDLEvent^.motion.y),1.0,0,TpvApplicationInputPointerButton.Middle,fMouseDown,KeyModifiers));
        end;
       end;
      end;
     end;
     SDL_MOUSEBUTTONUP:begin
      KeyModifiers:=GetKeyModifiers;
      fMaxPointerID:=max(fMaxPointerID,0);
 {    fMouseDeltaX:=SDLEvent^.button.x-fMouseX;
      fMouseDeltaY:=SDLEvent^.button.y-fMouseY;}
      fMouseX:=SDLEvent^.button.x;
      fMouseY:=SDLEvent^.button.y;
      case SDLEvent^.button.button of
       SDL_BUTTON_LEFT:begin
        Exclude(fMouseDown,TpvApplicationInputPointerButton.Left);
        Exclude(fMouseJustDown,TpvApplicationInputPointerButton.Left);
        if (not pvApplication.PointerEvent(TpvApplicationInputPointerEvent.Create(TpvApplicationInputPointerEventType.Up,TpvVector2.Create(SDLEvent^.motion.x,SDLEvent^.motion.y),1.0,0,TpvApplicationInputPointerButton.Left,fMouseDown,KeyModifiers))) and assigned(fProcessor) then begin
         fProcessor.PointerEvent(TpvApplicationInputPointerEvent.Create(TpvApplicationInputPointerEventType.Up,TpvVector2.Create(SDLEvent^.motion.x,SDLEvent^.motion.y),1.0,0,TpvApplicationInputPointerButton.Left,fMouseDown,KeyModifiers));
        end;
       end;
       SDL_BUTTON_RIGHT:begin
        Exclude(fMouseDown,TpvApplicationInputPointerButton.Right);
        Exclude(fMouseJustDown,TpvApplicationInputPointerButton.Right);
        if (not pvApplication.PointerEvent(TpvApplicationInputPointerEvent.Create(TpvApplicationInputPointerEventType.Up,TpvVector2.Create(SDLEvent^.motion.x,SDLEvent^.motion.y),1.0,0,TpvApplicationInputPointerButton.Right,fMouseDown,KeyModifiers))) and assigned(fProcessor) then begin
         fProcessor.PointerEvent(TpvApplicationInputPointerEvent.Create(TpvApplicationInputPointerEventType.Up,TpvVector2.Create(SDLEvent^.motion.x,SDLEvent^.motion.y),1.0,0,TpvApplicationInputPointerButton.Right,fMouseDown,KeyModifiers));
        end;
       end;
       SDL_BUTTON_MIDDLE:begin
        Exclude(fMouseDown,TpvApplicationInputPointerButton.Middle);
        Exclude(fMouseJustDown,TpvApplicationInputPointerButton.Middle);
        if (not pvApplication.PointerEvent(TpvApplicationInputPointerEvent.Create(TpvApplicationInputPointerEventType.Up,TpvVector2.Create(SDLEvent^.motion.x,SDLEvent^.motion.y),1.0,0,TpvApplicationInputPointerButton.Middle,fMouseDown,KeyModifiers))) and assigned(fProcessor) then begin
         fProcessor.PointerEvent(TpvApplicationInputPointerEvent.Create(TpvApplicationInputPointerEventType.Up,TpvVector2.Create(SDLEvent^.motion.x,SDLEvent^.motion.y),1.0,0,TpvApplicationInputPointerButton.Middle,fMouseDown,KeyModifiers));
        end;
       end;
      end;
     end;
     SDL_MOUSEWHEEL:begin
      if (not pvApplication.Scrolled(TpvVector2.Create(SDLEvent^.wheel.x,SDLEvent^.wheel.y))) and assigned(fProcessor) then begin
       fProcessor.Scrolled(TpvVector2.Create(SDLEvent^.wheel.x,SDLEvent^.wheel.y));
      end;
     end;
     SDL_FINGERMOTION:begin
      KeyModifiers:=GetKeyModifiers;
      PointerID:=SDLEvent^.tfinger.fingerId and $ffff;
      fMaxPointerID:=max(fMaxPointerID,PointerID+1);
      fPointerX[PointerID]:=SDLEvent^.tfinger.x*pvApplication.fWidth;
      fPointerY[PointerID]:=SDLEvent^.tfinger.y*pvApplication.fHeight;
      fPointerPressure[PointerID]:=SDLEvent^.tfinger.pressure;
      fPointerDeltaX[PointerID]:=SDLEvent^.tfinger.dx*pvApplication.fWidth;
      fPointerDeltaY[PointerID]:=SDLEvent^.tfinger.dy*pvApplication.fHeight;
      if (not pvApplication.PointerEvent(TpvApplicationInputPointerEvent.Create(TpvApplicationInputPointerEventType.Motion,TpvVector2.Create(fPointerX[PointerID],fPointerY[PointerID]),TpvVector2.Create(fPointerDeltaX[PointerID],fPointerDeltaY[PointerID]),fPointerPressure[PointerID],PointerID+1,fPointerDown[PointerID],KeyModifiers))) and assigned(fProcessor) then begin
       fProcessor.PointerEvent(TpvApplicationInputPointerEvent.Create(TpvApplicationInputPointerEventType.Motion,TpvVector2.Create(fPointerX[PointerID],fPointerY[PointerID]),TpvVector2.Create(fPointerDeltaX[PointerID],fPointerDeltaY[PointerID]),fPointerPressure[PointerID],PointerID+1,fPointerDown[PointerID],KeyModifiers));
      end;
     end;
     SDL_FINGERDOWN:begin
      KeyModifiers:=GetKeyModifiers;
      inc(fPointerDownCount);
      PointerID:=SDLEvent^.tfinger.fingerId and $ffff;
      fMaxPointerID:=max(fMaxPointerID,PointerID+1);
      fPointerX[PointerID]:=SDLEvent^.tfinger.x*pvApplication.fWidth;
      fPointerY[PointerID]:=SDLEvent^.tfinger.y*pvApplication.fHeight;
      fPointerPressure[PointerID]:=SDLEvent^.tfinger.pressure;
      fPointerDeltaX[PointerID]:=SDLEvent^.tfinger.dx*pvApplication.fWidth;
      fPointerDeltaY[PointerID]:=SDLEvent^.tfinger.dy*pvApplication.fHeight;
      Include(fPointerDown[PointerID],TpvApplicationInputPointerButton.Left);
      Include(fPointerJustDown[PointerID],TpvApplicationInputPointerButton.Left);
      fJustTouched:=true;
      if (not pvApplication.PointerEvent(TpvApplicationInputPointerEvent.Create(TpvApplicationInputPointerEventType.Down,TpvVector2.Create(fPointerX[PointerID],fPointerY[PointerID]),fPointerPressure[PointerID],PointerID+1,TpvApplicationInputPointerButton.Left,fPointerDown[PointerID],KeyModifiers))) and assigned(fProcessor) then begin
       fProcessor.PointerEvent(TpvApplicationInputPointerEvent.Create(TpvApplicationInputPointerEventType.Down,TpvVector2.Create(fPointerX[PointerID],fPointerY[PointerID]),fPointerPressure[PointerID],PointerID+1,TpvApplicationInputPointerButton.Left,fPointerDown[PointerID],KeyModifiers));
      end;
     end;
     SDL_FINGERUP:begin
      KeyModifiers:=GetKeyModifiers;
      if fPointerDownCount>0 then begin
       dec(fPointerDownCount);
      end;
      PointerID:=SDLEvent^.tfinger.fingerId and $ffff;
      fMaxPointerID:=max(fMaxPointerID,PointerID+1);
      fPointerX[PointerID]:=SDLEvent^.tfinger.x*pvApplication.fWidth;
      fPointerY[PointerID]:=SDLEvent^.tfinger.y*pvApplication.fHeight;
      fPointerPressure[PointerID]:=SDLEvent^.tfinger.pressure;
      fPointerDeltaX[PointerID]:=SDLEvent^.tfinger.dx*pvApplication.fWidth;
      fPointerDeltaY[PointerID]:=SDLEvent^.tfinger.dy*pvApplication.fHeight;
      Exclude(fPointerDown[PointerID],TpvApplicationInputPointerButton.Left);
      Exclude(fPointerJustDown[PointerID],TpvApplicationInputPointerButton.Left);
      if (not pvApplication.PointerEvent(TpvApplicationInputPointerEvent.Create(TpvApplicationInputPointerEventType.Up,TpvVector2.Create(fPointerX[PointerID],fPointerY[PointerID]),fPointerPressure[PointerID],PointerID+1,TpvApplicationInputPointerButton.Left,fPointerDown[PointerID],KeyModifiers))) and assigned(fProcessor) then begin
       fProcessor.PointerEvent(TpvApplicationInputPointerEvent.Create(TpvApplicationInputPointerEventType.Up,TpvVector2.Create(fPointerX[PointerID],fPointerY[PointerID]),fPointerPressure[PointerID],PointerID+1,TpvApplicationInputPointerButton.Left,fPointerDown[PointerID],KeyModifiers));
      end;
     end;
    end;
   end;
  end;
 finally
  fCriticalSection.Release;
  fEventCount:=0;
 end;
end;
{$elseif defined(PasVulkanHeadless)}
begin
 fEventCount:=0;
end;
{$else}
var Index,PointerID,KeyCode,ScanCode,Position:TpvInt32;
    KeyModifiers:TpvApplicationInputKeyModifiers;
    Event:PpvApplicationEvent;
    NativeEvent:PpvApplicationNativeEvent;
    OK:boolean;
    KeyShortcut:TpvApplicationInputKeyShortcut;
begin
 fCriticalSection.Acquire;
 try
  fJustTouched:=false;
  if fEventCount>0 then begin
   for Index:=0 to fEventCount-1 do begin
    Event:=@fEvents[Index];
    NativeEvent:=@Event^.NativeEvent;
    fCurrentEventTime:=fEventTimes[fEventCount];
    case NativeEvent^.Kind of
     TpvApplicationNativeEventKind.Quit:begin
      KeyShortcut:=nil;
      if (not pvApplication.KeyEvent(TpvApplicationInputKeyEvent.Create(TpvApplicationInputKeyEventType.Down,KEYCODE_QUIT,KEYCODE_QUIT,[],KeyShortcut))) and assigned(fProcessor) then begin
       fProcessor.KeyEvent(TpvApplicationInputKeyEvent.Create(TpvApplicationInputKeyEventType.Down,KEYCODE_QUIT,KEYCODE_QUIT,[],KeyShortcut));
      end;
      if (not pvApplication.KeyEvent(TpvApplicationInputKeyEvent.Create(TpvApplicationInputKeyEventType.Typed,KEYCODE_QUIT,KEYCODE_QUIT,[],KeyShortcut))) and assigned(fProcessor) then begin
       fProcessor.KeyEvent(TpvApplicationInputKeyEvent.Create(TpvApplicationInputKeyEventType.Typed,KEYCODE_QUIT,KEYCODE_QUIT,[],KeyShortcut));
      end;
      if (not pvApplication.KeyEvent(TpvApplicationInputKeyEvent.Create(TpvApplicationInputKeyEventType.Up,KEYCODE_QUIT,KEYCODE_QUIT,[],KeyShortcut))) and assigned(fProcessor) then begin
       fProcessor.KeyEvent(TpvApplicationInputKeyEvent.Create(TpvApplicationInputKeyEventType.Up,KEYCODE_QUIT,KEYCODE_QUIT,[],KeyShortcut));
      end;
     end;
     TpvApplicationNativeEventKind.DropFile:begin
      try
       if (not pvApplication.DragDropFileEvent(Event^.NativeEvent.StringValue)) and assigned(fProcessor) then begin
        fProcessor.DragDropFileEvent(Event^.NativeEvent.StringValue);
       end;
      finally
       Event^.NativeEvent.StringValue:='';
      end;
     end;
     TpvApplicationNativeEventKind.KeyDown,
     TpvApplicationNativeEventKind.KeyUp,
     TpvApplicationNativeEventKind.KeyTyped:begin
      KeyCode:=NativeEvent^.KeyCode;
      ScanCode:=NativeEvent^.ScanCode;
      KeyModifiers:=NativeEvent^.KeyModifiers;
      KeyShortcut:=GetKeyShortCut(KeyCode,ScanCode,KeyModifiers);
      case NativeEvent^.Kind of
       TpvApplicationNativeEventKind.KeyDown:begin
        fKeyDown[KeyCode and $ffff]:=true;
        inc(fKeyDownCount);
        fJustKeyDown[KeyCode and $ffff]:=true;
        if (not pvApplication.KeyEvent(TpvApplicationInputKeyEvent.Create(TpvApplicationInputKeyEventType.Down,KeyCode,ScanCode,KeyModifiers,KeyShortcut))) and assigned(fProcessor) then begin
         fProcessor.KeyEvent(TpvApplicationInputKeyEvent.Create(TpvApplicationInputKeyEventType.Down,KeyCode,ScanCode,KeyModifiers,KeyShortcut));
        end;
       end;
       TpvApplicationNativeEventKind.KeyUp:begin
        fKeyDown[KeyCode and $ffff]:=false;
        if fKeyDownCount>0 then begin
         dec(fKeyDownCount);
        end;
        fJustKeyDown[KeyCode and $ffff]:=false;
        if (not pvApplication.KeyEvent(TpvApplicationInputKeyEvent.Create(TpvApplicationInputKeyEventType.Up,KeyCode,ScanCode,KeyModifiers,KeyShortcut))) and assigned(fProcessor) then begin
         fProcessor.KeyEvent(TpvApplicationInputKeyEvent.Create(TpvApplicationInputKeyEventType.Up,KeyCode,ScanCode,KeyModifiers,KeyShortcut));
        end;
       end;
       TpvApplicationNativeEventKind.KeyTyped:begin
        if (not pvApplication.KeyEvent(TpvApplicationInputKeyEvent.Create(TpvApplicationInputKeyEventType.Typed,KeyCode,ScanCode,KeyModifiers,KeyShortcut))) and assigned(fProcessor) then begin
         fProcessor.KeyEvent(TpvApplicationInputKeyEvent.Create(TpvApplicationInputKeyEventType.Typed,KeyCode,ScanCode,KeyModifiers,KeyShortcut));
        end;
       end;
       else begin
       end;
      end;
     end;
     TpvApplicationNativeEventKind.UnicodeCharTyped:begin
      KeyModifiers:=[];
      KeyCode:=NativeEvent^.CharVal;
      ScanCode:=0;
      KeyShortcut:=GetKeyShortCut(KeyCode,ScanCode,KeyModifiers);
      if (not pvApplication.KeyEvent(TpvApplicationInputKeyEvent.Create(TpvApplicationInputKeyEventType.Unicode,KeyCode,ScanCode,KeyModifiers,KeyShortcut))) and assigned(fProcessor) then begin
       fProcessor.KeyEvent(TpvApplicationInputKeyEvent.Create(TpvApplicationInputKeyEventType.Unicode,KeyCode,ScanCode,KeyModifiers,KeyShortcut));
      end;
     end;
     TpvApplicationNativeEventKind.TextInput:begin
      KeyModifiers:=[];
      Position:=0;
      while Position<length(NativeEvent^.StringValue) do begin
       KeyCode:=PUCUUTF8PtrCodeUnitGetCharAndIncFallback(PAnsiChar(TpvPointer(@NativeEvent^.StringValue[1])),length(NativeEvent^.StringValue),Position);
       case KeyCode of
        0:begin
         break;
        end;
        else begin
         ScanCode:=0;
         KeyShortcut:=GetKeyShortCut(KeyCode,ScanCode,KeyModifiers);
         if (not pvApplication.KeyEvent(TpvApplicationInputKeyEvent.Create(TpvApplicationInputKeyEventType.Unicode,KeyCode,ScanCode,KeyModifiers,KeyShortcut))) and assigned(fProcessor) then begin
          fProcessor.KeyEvent(TpvApplicationInputKeyEvent.Create(TpvApplicationInputKeyEventType.Unicode,KeyCode,ScanCode,KeyModifiers,KeyShortcut));
         end;
        end;
       end;
      end;
     end;
     TpvApplicationNativeEventKind.MouseMoved:begin
      KeyModifiers:=GetKeyModifiers;
      fMouseX:=NativeEvent^.MouseCoordX;
      fMouseY:=NativeEvent^.MouseCoordY;
      fMouseDeltaX:=NativeEvent^.MouseDeltaX;
      fMouseDeltaY:=NativeEvent^.MouseDeltaY;
      OK:=pvApplication.PointerEvent(TpvApplicationInputPointerEvent.Create(TpvApplicationInputPointerEventType.Motion,
                                                                            TpvVector2.Create(NativeEvent^.MouseCoordX,NativeEvent^.MouseCoordY),
                                                                            TpvVector2.Create(NativeEvent^.MouseDeltaX,NativeEvent^.MouseDeltaY),
                                                                            ord(fMouseDown<>[]) and 1,
                                                                            0,
                                                                            fMouseDown,
                                                                            KeyModifiers));
      if assigned(fProcessor) and not OK then begin
       fProcessor.PointerEvent(TpvApplicationInputPointerEvent.Create(TpvApplicationInputPointerEventType.Motion,
                                                                      TpvVector2.Create(NativeEvent^.MouseCoordX,NativeEvent^.MouseCoordY),
                                                                      TpvVector2.Create(NativeEvent^.MouseDeltaX,NativeEvent^.MouseDeltaY),
                                                                      ord(fMouseDown<>[]) and 1,
                                                                      0,
                                                                      fMouseDown,
                                                                      KeyModifiers));
      end;
     end;
     TpvApplicationNativeEventKind.MouseButtonDown:begin
      KeyModifiers:=GetKeyModifiers;
      fMaxPointerID:=max(fMaxPointerID,0);
 {    fMouseDeltaX:=NativeEvent^.MouseCoordX-fMouseX;
      fMouseDeltaY:=NativeEvent^.MouseCoordY-fMouseY;}
      fMouseX:=NativeEvent^.MouseCoordX;
      fMouseY:=NativeEvent^.MouseCoordY;
      case NativeEvent^.MouseButton of
       TpvApplicationInputPointerButton.Left:begin
        Include(fMouseDown,TpvApplicationInputPointerButton.Left);
        Include(fMouseJustDown,TpvApplicationInputPointerButton.Left);
        fJustTouched:=true;
        if (not pvApplication.PointerEvent(TpvApplicationInputPointerEvent.Create(TpvApplicationInputPointerEventType.Down,TpvVector2.Create(NativeEvent^.MouseCoordX,NativeEvent^.MouseCoordY),1.0,0,TpvApplicationInputPointerButton.Left,fMouseDown,KeyModifiers))) and assigned(fProcessor) then begin
         fProcessor.PointerEvent(TpvApplicationInputPointerEvent.Create(TpvApplicationInputPointerEventType.Down,TpvVector2.Create(NativeEvent^.MouseCoordX,NativeEvent^.MouseCoordY),1.0,0,TpvApplicationInputPointerButton.Left,fMouseDown,KeyModifiers));
        end;
       end;
       TpvApplicationInputPointerButton.Right:begin
        Include(fMouseDown,TpvApplicationInputPointerButton.Right);
        Include(fMouseJustDown,TpvApplicationInputPointerButton.Right);
        fJustTouched:=true;
        if (not pvApplication.PointerEvent(TpvApplicationInputPointerEvent.Create(TpvApplicationInputPointerEventType.Down,TpvVector2.Create(NativeEvent^.MouseCoordX,NativeEvent^.MouseCoordY),1.0,0,TpvApplicationInputPointerButton.Right,fMouseDown,KeyModifiers))) and assigned(fProcessor) then begin
         fProcessor.PointerEvent(TpvApplicationInputPointerEvent.Create(TpvApplicationInputPointerEventType.Down,TpvVector2.Create(NativeEvent^.MouseCoordX,NativeEvent^.MouseCoordY),1.0,0,TpvApplicationInputPointerButton.Right,fMouseDown,KeyModifiers));
        end;
       end;
       TpvApplicationInputPointerButton.Middle:begin
        Include(fMouseDown,TpvApplicationInputPointerButton.Middle);
        Include(fMouseJustDown,TpvApplicationInputPointerButton.Middle);
        fJustTouched:=true;
        if (not pvApplication.PointerEvent(TpvApplicationInputPointerEvent.Create(TpvApplicationInputPointerEventType.Down,TpvVector2.Create(NativeEvent^.MouseCoordX,NativeEvent^.MouseCoordY),1.0,0,TpvApplicationInputPointerButton.Middle,fMouseDown,KeyModifiers))) and assigned(fProcessor) then begin
         fProcessor.PointerEvent(TpvApplicationInputPointerEvent.Create(TpvApplicationInputPointerEventType.Down,TpvVector2.Create(NativeEvent^.MouseCoordX,NativeEvent^.MouseCoordY),1.0,0,TpvApplicationInputPointerButton.Middle,fMouseDown,KeyModifiers));
        end;
       end;
       TpvApplicationInputPointerButton.X1:begin
        Include(fMouseDown,TpvApplicationInputPointerButton.X1);
        Include(fMouseJustDown,TpvApplicationInputPointerButton.X1);
        fJustTouched:=true;
        if (not pvApplication.PointerEvent(TpvApplicationInputPointerEvent.Create(TpvApplicationInputPointerEventType.Down,TpvVector2.Create(NativeEvent^.MouseCoordX,NativeEvent^.MouseCoordY),1.0,0,TpvApplicationInputPointerButton.X1,fMouseDown,KeyModifiers))) and assigned(fProcessor) then begin
         fProcessor.PointerEvent(TpvApplicationInputPointerEvent.Create(TpvApplicationInputPointerEventType.Down,TpvVector2.Create(NativeEvent^.MouseCoordX,NativeEvent^.MouseCoordY),1.0,0,TpvApplicationInputPointerButton.X1,fMouseDown,KeyModifiers));
        end;
       end;
       TpvApplicationInputPointerButton.X2:begin
        Include(fMouseDown,TpvApplicationInputPointerButton.X2);
        Include(fMouseJustDown,TpvApplicationInputPointerButton.X2);
        fJustTouched:=true;
        if (not pvApplication.PointerEvent(TpvApplicationInputPointerEvent.Create(TpvApplicationInputPointerEventType.Down,TpvVector2.Create(NativeEvent^.MouseCoordX,NativeEvent^.MouseCoordY),1.0,0,TpvApplicationInputPointerButton.X2,fMouseDown,KeyModifiers))) and assigned(fProcessor) then begin
         fProcessor.PointerEvent(TpvApplicationInputPointerEvent.Create(TpvApplicationInputPointerEventType.Down,TpvVector2.Create(NativeEvent^.MouseCoordX,NativeEvent^.MouseCoordY),1.0,0,TpvApplicationInputPointerButton.X2,fMouseDown,KeyModifiers));
        end;
       end;
      end;
     end;
     TpvApplicationNativeEventKind.MouseButtonUp:begin
      KeyModifiers:=GetKeyModifiers;
      fMaxPointerID:=max(fMaxPointerID,0);
 {    fMouseDeltaX:=NativeEvent^.MouseCoordX-fMouseX;
      fMouseDeltaY:=NativeEvent^.MouseCoordY-fMouseY;}
      fMouseX:=NativeEvent^.MouseCoordX;
      fMouseY:=NativeEvent^.MouseCoordY;
      case NativeEvent^.MouseButton of
       TpvApplicationInputPointerButton.Left:begin
        Exclude(fMouseDown,TpvApplicationInputPointerButton.Left);
        Exclude(fMouseJustDown,TpvApplicationInputPointerButton.Left);
        if (not pvApplication.PointerEvent(TpvApplicationInputPointerEvent.Create(TpvApplicationInputPointerEventType.Up,TpvVector2.Create(NativeEvent^.MouseCoordX,NativeEvent^.MouseCoordY),1.0,0,TpvApplicationInputPointerButton.Left,fMouseDown,KeyModifiers))) and assigned(fProcessor) then begin
         fProcessor.PointerEvent(TpvApplicationInputPointerEvent.Create(TpvApplicationInputPointerEventType.Up,TpvVector2.Create(NativeEvent^.MouseCoordX,NativeEvent^.MouseCoordY),1.0,0,TpvApplicationInputPointerButton.Left,fMouseDown,KeyModifiers));
        end;
       end;
       TpvApplicationInputPointerButton.Right:begin
        Exclude(fMouseDown,TpvApplicationInputPointerButton.Right);
        Exclude(fMouseJustDown,TpvApplicationInputPointerButton.Right);
        if (not pvApplication.PointerEvent(TpvApplicationInputPointerEvent.Create(TpvApplicationInputPointerEventType.Up,TpvVector2.Create(NativeEvent^.MouseCoordX,NativeEvent^.MouseCoordY),1.0,0,TpvApplicationInputPointerButton.Right,fMouseDown,KeyModifiers))) and assigned(fProcessor) then begin
         fProcessor.PointerEvent(TpvApplicationInputPointerEvent.Create(TpvApplicationInputPointerEventType.Up,TpvVector2.Create(NativeEvent^.MouseCoordX,NativeEvent^.MouseCoordY),1.0,0,TpvApplicationInputPointerButton.Right,fMouseDown,KeyModifiers));
        end;
       end;
       TpvApplicationInputPointerButton.Middle:begin
        Exclude(fMouseDown,TpvApplicationInputPointerButton.Middle);
        Exclude(fMouseJustDown,TpvApplicationInputPointerButton.Middle);
        if (not pvApplication.PointerEvent(TpvApplicationInputPointerEvent.Create(TpvApplicationInputPointerEventType.Up,TpvVector2.Create(NativeEvent^.MouseCoordX,NativeEvent^.MouseCoordY),1.0,0,TpvApplicationInputPointerButton.Middle,fMouseDown,KeyModifiers))) and assigned(fProcessor) then begin
         fProcessor.PointerEvent(TpvApplicationInputPointerEvent.Create(TpvApplicationInputPointerEventType.Up,TpvVector2.Create(NativeEvent^.MouseCoordX,NativeEvent^.MouseCoordY),1.0,0,TpvApplicationInputPointerButton.Middle,fMouseDown,KeyModifiers));
        end;
       end;
       TpvApplicationInputPointerButton.X1:begin
        Exclude(fMouseDown,TpvApplicationInputPointerButton.X1);
        Exclude(fMouseJustDown,TpvApplicationInputPointerButton.X1);
        if (not pvApplication.PointerEvent(TpvApplicationInputPointerEvent.Create(TpvApplicationInputPointerEventType.Up,TpvVector2.Create(NativeEvent^.MouseCoordX,NativeEvent^.MouseCoordY),1.0,0,TpvApplicationInputPointerButton.X1,fMouseDown,KeyModifiers))) and assigned(fProcessor) then begin
         fProcessor.PointerEvent(TpvApplicationInputPointerEvent.Create(TpvApplicationInputPointerEventType.Up,TpvVector2.Create(NativeEvent^.MouseCoordX,NativeEvent^.MouseCoordY),1.0,0,TpvApplicationInputPointerButton.X1,fMouseDown,KeyModifiers));
        end;
       end;
       TpvApplicationInputPointerButton.X2:begin
        Exclude(fMouseDown,TpvApplicationInputPointerButton.X2);
        Exclude(fMouseJustDown,TpvApplicationInputPointerButton.X2);
        if (not pvApplication.PointerEvent(TpvApplicationInputPointerEvent.Create(TpvApplicationInputPointerEventType.Up,TpvVector2.Create(NativeEvent^.MouseCoordX,NativeEvent^.MouseCoordY),1.0,0,TpvApplicationInputPointerButton.X2,fMouseDown,KeyModifiers))) and assigned(fProcessor) then begin
         fProcessor.PointerEvent(TpvApplicationInputPointerEvent.Create(TpvApplicationInputPointerEventType.Up,TpvVector2.Create(NativeEvent^.MouseCoordX,NativeEvent^.MouseCoordY),1.0,0,TpvApplicationInputPointerButton.X2,fMouseDown,KeyModifiers));
        end;
       end;
      end;
     end;
     TpvApplicationNativeEventKind.MouseWheel:begin
      if (not pvApplication.Scrolled(TpvVector2.Create(NativeEvent^.MouseScrollOffsetX,NativeEvent^.MouseScrollOffsetY))) and assigned(fProcessor) then begin
       fProcessor.Scrolled(TpvVector2.Create(NativeEvent^.MouseScrollOffsetX,NativeEvent^.MouseScrollOffsetY));
      end;
     end;
     TpvApplicationNativeEventKind.TouchMotion:begin
      KeyModifiers:=GetKeyModifiers;
      PointerID:=NativeEvent^.TouchID and $ffff;
      fMaxPointerID:=max(fMaxPointerID,PointerID+1);
      fPointerX[PointerID]:=NativeEvent^.TouchX;
      fPointerY[PointerID]:=NativeEvent^.TouchY;
      fPointerPressure[PointerID]:=NativeEvent^.TouchPressure;
      fPointerDeltaX[PointerID]:=NativeEvent^.TouchDeltaX;
      fPointerDeltaY[PointerID]:=NativeEvent^.TouchDeltaY;
      if (not pvApplication.PointerEvent(TpvApplicationInputPointerEvent.Create(TpvApplicationInputPointerEventType.Motion,TpvVector2.Create(fPointerX[PointerID],fPointerY[PointerID]),TpvVector2.Create(fPointerDeltaX[PointerID],fPointerDeltaY[PointerID]),fPointerPressure[PointerID],PointerID+1,fPointerDown[PointerID],KeyModifiers))) and assigned(fProcessor) then begin
       fProcessor.PointerEvent(TpvApplicationInputPointerEvent.Create(TpvApplicationInputPointerEventType.Motion,TpvVector2.Create(fPointerX[PointerID],fPointerY[PointerID]),TpvVector2.Create(fPointerDeltaX[PointerID],fPointerDeltaY[PointerID]),fPointerPressure[PointerID],PointerID+1,fPointerDown[PointerID],KeyModifiers));
      end;
     end;
     TpvApplicationNativeEventKind.TouchDown:begin
      KeyModifiers:=GetKeyModifiers;
      inc(fPointerDownCount);
      PointerID:=NativeEvent^.TouchID and $ffff;
      fMaxPointerID:=max(fMaxPointerID,PointerID+1);
      fPointerX[PointerID]:=NativeEvent^.TouchX;
      fPointerY[PointerID]:=NativeEvent^.TouchY;
      fPointerPressure[PointerID]:=NativeEvent^.TouchPressure;
      fPointerDeltaX[PointerID]:=NativeEvent^.TouchDeltaX;
      fPointerDeltaY[PointerID]:=NativeEvent^.TouchDeltaY;
      Include(fPointerDown[PointerID],TpvApplicationInputPointerButton.Left);
      Include(fPointerJustDown[PointerID],TpvApplicationInputPointerButton.Left);
      fJustTouched:=true;
      if (not pvApplication.PointerEvent(TpvApplicationInputPointerEvent.Create(TpvApplicationInputPointerEventType.Down,TpvVector2.Create(fPointerX[PointerID],fPointerY[PointerID]),fPointerPressure[PointerID],PointerID+1,TpvApplicationInputPointerButton.Left,fPointerDown[PointerID],KeyModifiers))) and assigned(fProcessor) then begin
       fProcessor.PointerEvent(TpvApplicationInputPointerEvent.Create(TpvApplicationInputPointerEventType.Down,TpvVector2.Create(fPointerX[PointerID],fPointerY[PointerID]),fPointerPressure[PointerID],PointerID+1,TpvApplicationInputPointerButton.Left,fPointerDown[PointerID],KeyModifiers));
      end;
     end;
     TpvApplicationNativeEventKind.TouchUp:begin
      KeyModifiers:=GetKeyModifiers;
      if fPointerDownCount>0 then begin
       dec(fPointerDownCount);
      end;
      PointerID:=NativeEvent^.TouchID and $ffff;
      fMaxPointerID:=max(fMaxPointerID,PointerID+1);
      fPointerX[PointerID]:=NativeEvent^.TouchX;
      fPointerY[PointerID]:=NativeEvent^.TouchY;
      fPointerPressure[PointerID]:=NativeEvent^.TouchPressure;
      fPointerDeltaX[PointerID]:=NativeEvent^.TouchDeltaX;
      fPointerDeltaY[PointerID]:=NativeEvent^.TouchDeltaY;
      Exclude(fPointerDown[PointerID],TpvApplicationInputPointerButton.Left);
      Exclude(fPointerJustDown[PointerID],TpvApplicationInputPointerButton.Left);
      if (not pvApplication.PointerEvent(TpvApplicationInputPointerEvent.Create(TpvApplicationInputPointerEventType.Up,TpvVector2.Create(fPointerX[PointerID],fPointerY[PointerID]),fPointerPressure[PointerID],PointerID+1,TpvApplicationInputPointerButton.Left,fPointerDown[PointerID],KeyModifiers))) and assigned(fProcessor) then begin
       fProcessor.PointerEvent(TpvApplicationInputPointerEvent.Create(TpvApplicationInputPointerEventType.Up,TpvVector2.Create(fPointerX[PointerID],fPointerY[PointerID]),fPointerPressure[PointerID],PointerID+1,TpvApplicationInputPointerButton.Left,fPointerDown[PointerID],KeyModifiers));
      end;
     end;
     else begin
     end;
    end;
   end;
  end;
 finally
  fCriticalSection.Release;
  fEventCount:=0;
 end;
end;
{$ifend}

function TpvApplicationInput.GetAccelerometerX:TpvFloat;
begin
 result:=0.0;
end;

function TpvApplicationInput.GetAccelerometerY:TpvFloat;
begin
 result:=0.0;
end;

function TpvApplicationInput.GetAccelerometerZ:TpvFloat;
begin
 result:=0.0;
end;

function TpvApplicationInput.GetOrientationAzimuth:TpvFloat;
begin
 result:=0.0;
end;

function TpvApplicationInput.GetOrientationPitch:TpvFloat;
begin
 result:=0.0;
end;

function TpvApplicationInput.GetOrientationRoll:TpvFloat;
begin
 result:=0.0;
end;

function TpvApplicationInput.GetMaxPointerID:TpvInt32;
begin
 fCriticalSection.Acquire;
 try
  result:=fMaxPointerID;
 finally
  fCriticalSection.Release;
 end;
end;

function TpvApplicationInput.GetPointerX(const aPointerID:TpvInt32=0):TpvFloat;
begin
 fCriticalSection.Acquire;
 try
  if aPointerID=0 then begin
   result:=fMouseX;
  end else if (aPointerID>0) and (aPointerID<=$10000) then begin
   result:=fPointerX[aPointerID-1];
  end else begin
   result:=0.0;
  end;
 finally
  fCriticalSection.Release;
 end;
end;

function TpvApplicationInput.GetPointerDeltaX(const aPointerID:TpvInt32=0):TpvFloat;
begin
 fCriticalSection.Acquire;
 try
  if aPointerID=0 then begin
   result:=fMouseDeltaX;
  end else if (aPointerID>0) and (aPointerID<=$10000) then begin
   result:=fPointerDeltaX[aPointerID-1];
  end else begin
   result:=0.0;
  end;
 finally
  fCriticalSection.Release;
 end;
end;

function TpvApplicationInput.GetPointerY(const aPointerID:TpvInt32=0):TpvFloat;
begin
 fCriticalSection.Acquire;
 try
  if aPointerID=0 then begin
   result:=fMouseY;
  end else if (aPointerID>0) and (aPointerID<=$10000) then begin
   result:=fPointerY[aPointerID-1];
  end else begin
   result:=0.0;
  end;
 finally
  fCriticalSection.Release;
 end;
end;

function TpvApplicationInput.GetPointerDeltaY(const aPointerID:TpvInt32=0):TpvFloat;
begin
 fCriticalSection.Acquire;
 try
  if aPointerID=0 then begin
   result:=fMouseDeltaY;
  end else if (aPointerID>0) and (aPointerID<=$10000) then begin
   result:=fPointerDeltaY[aPointerID-1];
  end else begin
   result:=0.0;
  end;
 finally
  fCriticalSection.Release;
 end;
end;

function TpvApplicationInput.GetPointerPressure(const aPointerID:TpvInt32=0):TpvFloat;
begin
 fCriticalSection.Acquire;
 try
  if aPointerID=0 then begin
   result:=ord(fMouseDown<>[]) and 1;
  end else if (aPointerID>0) and (aPointerID<=$10000) then begin
   result:=fPointerPressure[aPointerID-1];
  end else begin
   result:=0.0;
  end;
 finally
  fCriticalSection.Release;
 end;
end;

function TpvApplicationInput.IsPointerTouched(const aPointerID:TpvInt32=0;const aButtonMask:TpvApplicationInputPointerButtons=[TpvApplicationInputPointerButton.Left,TpvApplicationInputPointerButton.Middle,TpvApplicationInputPointerButton.Right]):boolean;
begin
 fCriticalSection.Acquire;
 try
  if aPointerID=0 then begin
   result:=(fMouseDown*aButtonMask)<>[];
  end else if (aPointerID>0) and (aPointerID<=$10000) then begin
   result:=(fPointerDown[aPointerID-1]*aButtonMask)<>[];
  end else begin
   result:=false;
  end;
 finally
  fCriticalSection.Release;
 end;
end;

function TpvApplicationInput.IsPointerJustTouched(const aPointerID:TpvInt32=0;const aButtonMask:TpvApplicationInputPointerButtons=[TpvApplicationInputPointerButton.Left,TpvApplicationInputPointerButton.Middle,TpvApplicationInputPointerButton.Right]):boolean;
begin
 fCriticalSection.Acquire;
 try
  if aPointerID=0 then begin
   result:=(fMouseJustDown*aButtonMask)<>[];
   fMouseJustDown:=fMouseJustDown-aButtonMask;
  end else if (aPointerID>0) and (aPointerID<=$10000) then begin
   result:=(fPointerJustDown[aPointerID-1]*aButtonMask)<>[];
   fPointerJustDown[aPointerID-1]:=fPointerJustDown[aPointerID-1]-aButtonMask;
  end else begin
   result:=false;
  end;
 finally
  fCriticalSection.Release;
 end;
end;

function TpvApplicationInput.IsTouched:boolean;
begin
 fCriticalSection.Acquire;
 try
  result:=(fMouseDown<>[]) or (fPointerDownCount<>0);
 finally
  fCriticalSection.Release;
 end;
end;

function TpvApplicationInput.JustTouched:boolean;
begin
 fCriticalSection.Acquire;
 try
  result:=fJustTouched;
 finally
  fCriticalSection.Release;
 end;
end;

function TpvApplicationInput.IsButtonPressed(const aButton:TpvApplicationInputPointerButton):boolean;
begin
 fCriticalSection.Acquire;
 try
  result:=aButton in fMouseDown;
 finally
  fCriticalSection.Release;
 end;
end;

function TpvApplicationInput.IsKeyPressed(const aKeyCode:TpvInt32):boolean;
begin
 fCriticalSection.Acquire;
 try
  case aKeyCode of
   KEYCODE_ANYKEY:begin
    result:=fKeyDownCount>0;
   end;
   $0000..$ffff:begin
    result:=fKeyDown[aKeyCode and $ffff];
   end;
   else begin
    result:=false;
   end;
  end;
 finally
  fCriticalSection.Release;
 end;
end;

function TpvApplicationInput.IsKeyJustPressed(const aKeyCode:TpvInt32):boolean;
begin
 fCriticalSection.Acquire;
 try
  case aKeyCode of
   $0000..$ffff:begin
    result:=fJustKeyDown[aKeyCode and $ffff];
    fJustKeyDown[aKeyCode and $ffff]:=false;
   end;
   else begin
    result:=false;
   end;
  end;
 finally
  fCriticalSection.Release;
 end;
end;

function TpvApplicationInput.GetKeyName(const aKeyCode:TpvInt32):TpvApplicationRawByteString;
begin
 if (aKeyCode>=low(fKeyCodeNames)) and (aKeyCode<=high(fKeyCodeNames)) then begin
  result:=fKeyCodeNames[aKeyCode];
 end else begin
  result:='';
 end;
end;

function TpvApplicationInput.GetKeyModifiers:TpvApplicationInputKeyModifiers;
begin
{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
 result:=TranslateSDLKeyModifier(SDL_GetModState);
{$else}
 result:=[];
{$if not defined(PasVulkanHeadless)}
{$if defined(Windows)}
 if HIWORD(GetAsyncKeyState(VK_MENU))<>0 then begin
  result:=result+[TpvApplicationInputKeyModifier.ALT];
 end;
 if HIWORD(GetAsyncKeyState(VK_LMENU))<>0 then begin
  result:=result+[TpvApplicationInputKeyModifier.ALT,TpvApplicationInputKeyModifier.LALT];
 end;
 if HIWORD(GetAsyncKeyState(VK_RMENU))<>0 then begin
  result:=result+[TpvApplicationInputKeyModifier.ALT,TpvApplicationInputKeyModifier.RALT];
 end;

 if HIWORD(GetAsyncKeyState(VK_CONTROL))<>0 then begin
  result:=result+[TpvApplicationInputKeyModifier.CTRL];
 end;
 if HIWORD(GetAsyncKeyState(VK_LCONTROL))<>0 then begin
  result:=result+[TpvApplicationInputKeyModifier.CTRL,TpvApplicationInputKeyModifier.LCTRL];
 end;
 if HIWORD(GetAsyncKeyState(VK_RCONTROL))<>0 then begin
  result:=result+[TpvApplicationInputKeyModifier.CTRL,TpvApplicationInputKeyModifier.RCTRL];
 end;

 if HIWORD(GetAsyncKeyState(VK_SHIFT))<>0 then begin
  result:=result+[TpvApplicationInputKeyModifier.SHIFT];
 end;
 if HIWORD(GetAsyncKeyState(VK_LSHIFT))<>0 then begin
  result:=result+[TpvApplicationInputKeyModifier.SHIFT,TpvApplicationInputKeyModifier.LSHIFT];
 end;
 if HIWORD(GetAsyncKeyState(VK_RSHIFT))<>0 then begin
  result:=result+[TpvApplicationInputKeyModifier.SHIFT,TpvApplicationInputKeyModifier.RSHIFT];
 end;

 if HIWORD(GetAsyncKeyState(VK_LWIN))<>0 then begin
  result:=result+[TpvApplicationInputKeyModifier.META,TpvApplicationInputKeyModifier.LMETA];
 end;
 if HIWORD(GetAsyncKeyState(VK_RWIN))<>0 then begin
  result:=result+[TpvApplicationInputKeyModifier.META,TpvApplicationInputKeyModifier.RMETA];
 end;

 if (GetAsyncKeyState(VK_CAPITAL) and $0001)<>0 then begin
  result:=result+[TpvApplicationInputKeyModifier.CAPS];
 end;

 if (GetAsyncKeyState(VK_NUMLOCK) and $0001)<>0 then begin
  result:=result+[TpvApplicationInputKeyModifier.NUM];
 end;

 if (GetAsyncKeyState(VK_SCROLL) and $0001)<>0 then begin
  result:=result+[TpvApplicationInputKeyModifier.SCROLL];
 end;
{$ifend}
{$ifend}
{$ifend}
end;

procedure TpvApplicationInput.StartTextInput;
begin
 fCriticalSection.Acquire;
 try
  fTextInput:=true;
 finally
  fCriticalSection.Release;
 end;
end;

procedure TpvApplicationInput.StopTextInput;
begin
 fCriticalSection.Acquire;
 try
  fTextInput:=false;
 finally
  fCriticalSection.Release;
 end;
end;

procedure TpvApplicationInput.GetTextInput(const aCallback:TpvApplicationInputTextInputCallback;const aTitle,aText:TpvApplicationRawByteString;const aPlaceholder:TpvApplicationRawByteString='');
begin
end;

procedure TpvApplicationInput.SetOnscreenKeyboardVisible(const aVisible:boolean);
begin
end;

procedure TpvApplicationInput.Vibrate(const aMilliseconds:TpvInt32);
begin
end;

procedure TpvApplicationInput.Vibrate(const aPattern:array of TpvInt32;const aRepeats:TpvInt32);
begin
end;

procedure TpvApplicationInput.CancelVibrate;
begin
end;

procedure TpvApplicationInput.GetRotationMatrix(const aMatrix3x3:pointer);
begin
end;

function TpvApplicationInput.GetCurrentEventTime:TpvInt64;
begin
 result:=fCurrentEventTime;
end;

procedure TpvApplicationInput.SetCatchBackKey(const aCatchBack:boolean);
begin
end;

procedure TpvApplicationInput.SetCatchMenuKey(const aCatchMenu:boolean);
begin
end;

procedure TpvApplicationInput.SetInputProcessor(const aProcessor:TpvApplicationInputProcessor);
begin
 fCriticalSection.Acquire;
 try
  fProcessor:=aProcessor;
 finally
  fCriticalSection.Release;
 end;
end;

function TpvApplicationInput.GetInputProcessor:TpvApplicationInputProcessor;
begin
 fCriticalSection.Acquire;
 try
  result:=fProcessor;
 finally
  fCriticalSection.Release;
 end;
end;

function TpvApplicationInput.IsPeripheralAvailable(const aPeripheral:TpvInt32):boolean;
begin
 fCriticalSection.Acquire;
 try
  case aPeripheral of
   PERIPHERAL_HARDWAREKEYBOARD,PERIPHERAL_MULTITOUCHSCREEN:begin
    result:=true;
   end;
   PERIPHERAL_ONSCEENKEYBOARD,PERIPHERAL_ACCELEROMETER,PERIPHERAL_COMPASS,PERIPHERAL_VIBRATOR:begin
    result:=false;
   end;
   else begin
    result:=false;
   end;
  end;
 finally
  fCriticalSection.Release;
 end;
end;

function TpvApplicationInput.GetNativeOrientation:TpvInt32;
{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
var SDLDisplayMode:TSDL_DisplayMode;
begin
 if SDL_GetDesktopDisplayMode(SDL_GetWindowDisplayIndex(pvApplication.fSurfaceWindow),@SDLDisplayMode)=0 then begin
  if SDLDisplayMode.w<SDLDisplayMode.h then begin
   result:=ORIENTATION_LANDSCAPE;
  end else begin
   result:=ORIENTATION_PORTRAIT;
  end;
 end else begin
  result:=ORIENTATION_LANDSCAPE;
 end;
end;
{$else}
begin
 result:=ORIENTATION_LANDSCAPE;
end;
{$ifend}

procedure TpvApplicationInput.SetCursorCatched(const aCatched:boolean);
begin
 fCriticalSection.Acquire;
 try
  pvApplication.fCatchMouse:=aCatched;
 finally
  fCriticalSection.Release;
 end;
end;

function TpvApplicationInput.IsCursorCatched:boolean;
begin
 fCriticalSection.Acquire;
 try
  result:=pvApplication.fCatchMouse;
 finally
  fCriticalSection.Release;
 end;
end;

procedure TpvApplicationInput.SetCursorPosition(const pX,pY:TpvInt32);
{$if defined(Windows) and not (defined(PasVulkanUseSDL2) or defined(PasVulkanHeadless))}
var Rect:TRect;
{$ifend}
begin
 fCriticalSection.Acquire;
 try
{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
  SDL_WarpMouseInWindow(pvApplication.fSurfaceWindow,pX,pY);
{$elseif defined(Windows) and not defined(PasVulkanHeadless)}
  if GetWindowRect(pvApplication.fWin32Handle,Rect) then begin
   Windows.SetCursorPos(Rect.Left+pX,Rect.Top+pY);
  end;
{$else}
{$ifend}
 finally
  fCriticalSection.Release;
 end;
end;

function TpvApplicationInput.GetJoystickCount:TpvInt32;
begin
{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
 result:=SDL_NumJoysticks;
{$elseif defined(Windows) and not defined(PasVulkanHeadless)}
 result:=Max(fJoysticks.Count,0);
{$else}
 result:=0;
{$ifend}
end;

function TpvApplicationInput.GetJoystick(const aID:TpvInt64=-1):TpvApplicationJoystick;
begin
 if aID>=0 then begin
  result:=fJoystickIDHashMap[aID];
 end else begin
  result:=fMainJoystick;
 end;
end;

function TpvApplicationInput.GetJoystickByID(const aID:TpvInt64=-1):TpvApplicationJoystick;
begin
 if aID>=0 then begin
  result:=fJoystickIDHashMap[aID];
 end else begin
  result:=fMainJoystick;
 end;
end;

function TpvApplicationInput.GetJoystickByIndex(const aIndex:TpvSizeInt=-1):TpvApplicationJoystick;
begin
 if aIndex>=0 then begin
  if aIndex<fJoysticks.Count then begin
   result:=fJoysticks[aIndex];
  end else begin
   result:=nil;
  end;
 end else begin
  result:=fMainJoystick;
 end;
end;

constructor TpvApplicationLifecycleListener.Create;
begin
 inherited Create;
end;

destructor TpvApplicationLifecycleListener.Destroy;
begin
 inherited Destroy;
end;

function TpvApplicationLifecycleListener.Resume:boolean;
begin
 result:=false;
end;

function TpvApplicationLifecycleListener.Pause:boolean;
begin
 result:=false;
end;

function TpvApplicationLifecycleListener.LowMemory:boolean;
begin
 result:=false;
end;

function TpvApplicationLifecycleListener.Terminate:boolean;
begin
 result:=false;
end;

constructor TpvApplicationScreen.Create;
begin
 inherited Create;
end;

destructor TpvApplicationScreen.Destroy;
begin
 inherited Destroy;
end;

procedure TpvApplicationScreen.Show;
begin
end;

procedure TpvApplicationScreen.Hide;
begin
end;

procedure TpvApplicationScreen.Resume;
begin
end;

procedure TpvApplicationScreen.Pause;
begin
end;

procedure TpvApplicationScreen.LowMemory;
begin
end;

procedure TpvApplicationScreen.Resize(const aWidth,aHeight:TpvInt32);
begin
end;

procedure TpvApplicationScreen.AfterCreateSwapChain;
begin
end;

procedure TpvApplicationScreen.BeforeDestroySwapChain;
begin
end;

function TpvApplicationScreen.HandleEvent(const aEvent:TpvApplicationEvent):boolean;
begin
 result:=false;
end;

function TpvApplicationScreen.KeyEvent(const aKeyEvent:TpvApplicationInputKeyEvent):boolean;
begin
 result:=false;
end;

function TpvApplicationScreen.PointerEvent(const aPointerEvent:TpvApplicationInputPointerEvent):boolean;
begin
 result:=false;
end;

function TpvApplicationScreen.Scrolled(const aRelativeAmount:TpvVector2):boolean;
begin
 result:=false;
end;

function TpvApplicationScreen.DragDropFileEvent(aFileName:TpvUTF8String):boolean;
begin
 result:=false;
end;

function TpvApplicationScreen.CanBeParallelProcessed:boolean;
begin
 result:=false;
end;

procedure TpvApplicationScreen.Check(const aDeltaTime:TpvDouble);
begin
end;

procedure TpvApplicationScreen.Update(const aDeltaTime:TpvDouble);
begin
end;

procedure TpvApplicationScreen.BeginFrame(const aDeltaTime:TpvDouble);
begin
end;

function TpvApplicationScreen.IsReadyForDrawOfInFlightFrameIndex(const aInFlightFrameIndex:TpvInt32):boolean;
begin
 result:=true;
end;

procedure TpvApplicationScreen.Draw(const aSwapChainImageIndex:TpvInt32;var aWaitSemaphore:TpvVulkanSemaphore;const aWaitFence:TpvVulkanFence=nil);
begin
end;

procedure TpvApplicationScreen.FinishFrame(const aSwapChainImageIndex:TpvInt32;var aWaitSemaphore:TpvVulkanSemaphore;const aWaitFence:TpvVulkanFence=nil);
begin
end;

procedure TpvApplicationScreen.PostPresent(const aSwapChainImageIndex:TpvInt32);
begin
end;

procedure TpvApplicationScreen.UpdateAudio;
begin
end;

constructor TpvApplicationAssets.Create(const aVulkanApplication:TpvApplication);
var ExePath, TestPath: String;
begin
 inherited Create;
 fVulkanApplication:=aVulkanApplication;
{$if defined(Android)}
 fBasePath:='';
{$elseif defined(PasVulkanAdjustDelphiWorkingDirectory)}
 fBasePath:=TpvUTF8String(IncludeTrailingPathDelimiter(ExpandFileName(IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)))+'..')+'..')+'..')+'assets'))));
{$elseif defined(PasVulkanUseCurrentWorkingDirectory)}
 fBasePath:=TpvUTF8String(IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(ExtractFilePath(GetCurrentDir))+'assets'));
{$elseif defined(PasVulkanUseRelativeDirectory)}
 fBasePath:=TpvUTF8String(IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)))+'assets'));
{$else}
 ExePath:=ExtractFilePath(ParamStr(0));
 TestPath:=IncludeTrailingPathDelimiter(ExePath+'assets');
 if DirectoryExists(TestPath) then begin
  fBasePath:=TpvUTF8String(TestPath);
 end else begin
  TestPath:=IncludeTrailingPathDelimiter(ExpandFileName(ExePath+'..'+PathDelim+'assets'));
  if DirectoryExists(TestPath) then begin
   fBasePath:=TpvUTF8String(TestPath);
  end else begin
   TestPath:=IncludeTrailingPathDelimiter(ExpandFileName(ExePath+'..'+PathDelim+'share'+PathDelim+'goverlay'+PathDelim+'assets'));
   fBasePath:=TpvUTF8String(TestPath);
  end;
 end;
{$ifend}
end;

destructor TpvApplicationAssets.Destroy;
begin
 inherited Destroy;
end;

function TpvApplicationAssets.CorrectFileName(const aFileName:TpvUTF8String):TpvUTF8String;
begin
 result:=TpvUTF8String(StringReplace(StringReplace(String({$ifndef Android}fBasePath+{$endif}aFileName),'/',PathDelim,[rfReplaceAll]),'\',PathDelim,[rfReplaceAll]));
end;

function TpvApplicationAssets.ExistAsset(const aFileName:TpvUTF8String):boolean;
{$ifdef Android}
var Asset:PAAsset;
begin
 result:=false;
 if assigned(AndroidAssetManager) then begin
  Asset:=AAssetManager_open(AndroidAssetManager,pansichar(TpvApplicationRawByteString(CorrectFileName(aFileName))),AASSET_MODE_UNKNOWN);
  if assigned(Asset) then begin
   AAsset_close(Asset);
   result:=true;
  end;
 end else begin
  raise Exception.Create('Asset manager is null');
 end;
end;
{$else}
begin
 result:=FileExists(String(CorrectFileName(aFileName)));
end;
{$endif}

function TpvApplicationAssets.GetAssetStream(const aFileName:TpvUTF8String):TStream;
{$ifdef Android}
var Asset:PAAsset;
    Size:TpvInt64;
begin
 result:=nil;
 if assigned(AndroidAssetManager) then begin
  Asset:=AAssetManager_open(AndroidAssetManager,pansichar(TpvApplicationRawByteString(CorrectFileName(aFileName))),AASSET_MODE_UNKNOWN);
  if assigned(Asset) then begin
   try
    Size:=AAsset_getLength(Asset);
    result:=TMemoryStream.Create;
    result.Size:=Size;
    AAsset_read(Asset,TMemoryStream(result).Memory,Size);
  //Move(AAsset_getBuffer(Asset)^,Data^,Size);
   finally
    AAsset_close(Asset);
   end;
  end else begin
   raise Exception.Create('Asset "'+aFileName+'" not found');
  end;
 end else begin
  raise Exception.Create('Asset manager is null');
 end;
end;
{$else}
begin
 result:=TFileStream.Create(String(CorrectFileName(aFileName)),fmOpenRead or fmShareDenyWrite);
end;
{$endif}

function TpvApplicationAssets.GetAssetSize(const aFileName:TpvUTF8String):TpvUInt64;
{$ifdef Android}
var Asset:PAAsset;
begin
 result:=0;
 if assigned(AndroidAssetManager) then begin
  Asset:=AAssetManager_open(AndroidAssetManager,pansichar(TpvApplicationRawByteString(CorrectFileName(aFileName))),AASSET_MODE_UNKNOWN);
  if assigned(Asset) then begin
   try
    result:=AAsset_getLength(Asset);
   finally
    AAsset_close(Asset);
   end;
  end else begin
   raise Exception.Create('Asset "'+aFileName+'" not found');
  end;
 end else begin
  raise Exception.Create('Asset manager is null');
 end;
end;
{$else}
var Stream:TStream;
begin
 Stream:=TFileStream.Create(String(CorrectFileName(aFileName)),fmOpenRead or fmShareDenyWrite);
 try
  result:=Stream.Size;
 finally
  FreeAndNil(Stream);
 end;
end;
{$endif}

function TpvApplicationAssets.GetAssetDateTime(const aFileName:TpvUTF8String):TDateTime;
{$ifdef Android}
var Asset:PAAsset;
    FileDescriptor:TpvInt32;
    Stat:TStat;
begin
 result:=0;
 if assigned(AndroidAssetManager) then begin
  Asset:=AAssetManager_open(AndroidAssetManager,pansichar(TpvApplicationRawByteString(CorrectFileName(aFileName))),AASSET_MODE_UNKNOWN);
  if assigned(Asset) then begin
   try
    FileDescriptor:=AAsset_openFileDescriptor(Asset,nil,nil);
    if fpFStat(FileDescriptor,Stat)=0 then begin
     result:=FileDateToDateTime(Stat.st_mtime);
    end;
   finally
     AAsset_close(Asset);
   end;
  end else begin
   raise Exception.Create('Asset "'+aFileName+'" not found');
  end;
 end else begin
  raise Exception.Create('Asset manager is null');
 end;
end;
{$else}
begin
 if not FileAgeUTC(String(CorrectFileName(aFileName)),result) then begin
  result:=0.0;
 end;
end;
{$endif}

function TpvApplicationAssets.GetDirectoryFileList(const aPath:TpvUTF8String;const aRaiseExceptionOnNonExistentDirectory:boolean=false):TFileNameList;
{$ifdef Android}
var AssetDir:PAAssetDir;
    Count:TpvSizeInt;
    FileName:PAnsiChar;
begin
 result:=nil;
 if assigned(AndroidAssetManager) then begin
  AssetDir:=AAssetManager_openDir(AndroidAssetManager,PAnsiChar(TpvApplicationRawByteString(CorrectFileName(aPath))){,AASSET_MODE_UNKNOWN});
  if assigned(AssetDir) then begin
   try
    Count:=0;
    try
     repeat
      FileName:=AAssetDir_getNextFileName(AssetDir);
      if assigned(FileName) then begin
       if length(result)<=Count then begin
        SetLength(result,(Count+1)*2);
       end;
       result[Count]:=TpvUTF8String(PAnsiChar(FileName));
       inc(Count);
      end else begin
       break;
      end;
     until false;
    finally
     SetLength(result,Count);
    end;
   finally
    AAssetDir_close(AssetDir);
   end;
  end else begin
   if aRaiseExceptionOnNonExistentDirectory then begin
    raise Exception.Create('Asset directory "'+String(aPath)+'" not found');
   end;
  end;
 end else begin
  raise Exception.Create('Asset manager is null');
 end;
end;
{$else}
var Count:TpvSizeInt;
    SearchRec:TSearchRec;
begin
 result:=nil;
 if DirectoryExists(IncludeTrailingPathDelimiter(String(CorrectFileName(aPath)))) then begin
  if FindFirst(IncludeTrailingPathDelimiter(String(CorrectFileName(aPath)))+{$if defined(Unix) or defined(Posix)}'*'{$else}'*.*'{$ifend},faAnyFile,SearchRec)=0 then begin
   Count:=0;
   try
    try
     repeat
      if ((SearchRec.Attr and faDirectory)=0) and
         (SearchRec.Name<>'.') and
         (SearchRec.Name<>'..') then begin
       if length(result)<=Count then begin
        SetLength(result,(Count+1)*2);
       end;
       result[Count]:=TpvUTF8String(SearchRec.Name);
       inc(Count);
      end;
     until FindNext(SearchRec)<>0;
    finally
     FindClose(SearchRec);
    end;
   finally
    SetLength(result,Count);
   end;
  end;
 end else begin
  if aRaiseExceptionOnNonExistentDirectory then begin
   raise Exception.Create('Asset directory "'+String(aPath)+'" not found');
  end;
 end;
end;
{$endif}

constructor TpvApplicationFiles.Create(const aVulkanApplication:TpvApplication);
begin
 inherited Create;
 fVulkanApplication:=aVulkanApplication;
end;

destructor TpvApplicationFiles.Destroy;
begin
 inherited Destroy;
end;

function TpvApplicationFiles.GetCacheStoragePath:TpvUTF8String;
begin
 if length(fVulkanApplication.fCacheStoragePath)>0 then begin
  result:=TpvUTF8String(IncludeTrailingPathDelimiter(String(fVulkanApplication.fCacheStoragePath)));
 end else begin
  result:='';
 end;
end;

function TpvApplicationFiles.GetLocalStoragePath:TpvUTF8String;
begin
 if length(fVulkanApplication.fLocalStoragePath)>0 then begin
  result:=TpvUTF8String(IncludeTrailingPathDelimiter(String(fVulkanApplication.fLocalStoragePath)));
 end else begin
  result:='';
 end;
end;

function TpvApplicationFiles.GetRoamingStoragePath:TpvUTF8String;
begin
 if length(fVulkanApplication.fRoamingStoragePath)>0 then begin
  result:=TpvUTF8String(IncludeTrailingPathDelimiter(String(fVulkanApplication.fRoamingStoragePath)));
 end else begin
  result:='';
 end;
end;

function TpvApplicationFiles.GetExternalStoragePath:TpvUTF8String;
begin
 if length(fVulkanApplication.fExternalStoragePath)>0 then begin
  result:=TpvUTF8String(IncludeTrailingPathDelimiter(String(fVulkanApplication.fExternalStoragePath)));
 end else begin
  result:='';
 end;
end;

function TpvApplicationFiles.IsCacheStorageAvailable:boolean;
begin
 result:=length(fVulkanApplication.fCacheStoragePath)>0;
end;

function TpvApplicationFiles.IsLocalStorageAvailable:boolean;
begin
 result:=length(fVulkanApplication.fLocalStoragePath)>0;
end;

function TpvApplicationFiles.IsRoamingStorageAvailable:boolean;
begin
 result:=length(fVulkanApplication.fRoamingStoragePath)>0;
end;

function TpvApplicationFiles.IsExternalStorageAvailable:boolean;
begin
 result:=length(fVulkanApplication.fExternalStoragePath)>0;
end;

constructor TpvApplicationClipboard.Create(const aVulkanApplication:TpvApplication);
begin
 inherited Create;
 fVulkanApplication:=aVulkanApplication;
end;

destructor TpvApplicationClipboard.Destroy;
begin
 inherited Destroy;
end;

function TpvApplicationClipboard.HasText:boolean;
{$if defined(Windows)}
var ClipboardHandle:THandle;
    Data:pointer;
    Error:TpvUInt32;
begin
 result:=false;
 if Windows.OpenClipboard(0) then begin
  try
   ClipboardHandle:=Windows.GetClipboardData(CF_UNICODETEXT);
   if ClipboardHandle<>0 then begin
    Data:=Windows.GlobalLock(ClipboardHandle);
    try
     if assigned(Data) then begin
      result:=PWideChar(Data)^<>#0;
     end;
    finally
     Windows.GlobalUnlock(ClipboardHandle);
    end;
   end else begin
    Error:=GetLastError;
    pvApplication.Log(LOG_DEBUG,'Clipboard','GetLastError '+IntToStr(Error));
   end;
  finally
   Windows.CloseClipboard;
  end;
 end;
end;
{$elseif defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
begin
 result:=SDL_HasClipboardText<>SDL_FALSE;
end;
{$else}
begin
 result:=false;
end;
{$ifend}

function TpvApplicationClipboard.GetText:TpvApplicationUTF8String;
{$if defined(Windows)}
var ClipboardHandle:THandle;
    Data:pointer;
    UTF16Data:WideString;
    Error:TpvUInt32;
begin
 result:='';
 if Windows.OpenClipboard(0) then begin
  try
   ClipboardHandle:=Windows.GetClipboardData(CF_UNICODETEXT);
   if ClipboardHandle<>0 then begin
    Data:=Windows.GlobalLock(ClipboardHandle);
    try
     if assigned(Data) then begin
      UTF16Data:=PWideChar(Data);
      result:=PUCUUTF16ToUTF8(UTF16Data);
     end;
    finally
     Windows.GlobalUnlock(ClipboardHandle);
    end;
   end else begin
    Error:=GetLastError;
    pvApplication.Log(LOG_DEBUG,'Clipboard','GetLastError '+IntToStr(Error));
   end;
  finally
   Windows.CloseClipboard;
  end;
 end;
end;
{$elseif defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
var p:PAnsiChar;
    l:TpvInt32;
begin
 result:='';
 p:=SDL_GetClipboardText;
 if assigned(p) then begin
  try
   l:=StrLen(p);
   if l>0 then begin
    SetLength(result,l);
    Move(p^,result[1],l);
   end;
  finally
   SDL_free(p);
  end;
 end;
end;
{$else}
begin
 result:='';
end;
{$ifend}

procedure TpvApplicationClipboard.SetText(const aTextString:TpvApplicationUTF8String);
{$if defined(Windows)}
var ClipboardHandle:THandle;
    Data:pointer;
    UTF16Data:WideString;
    Error:TpvUInt32;
    Size:TpvSizeInt;
begin
 UTF16Data:=PUCUUTF8ToUTF16(aTextString);
 if Windows.OpenClipboard(0) then begin
  try
   Size:=(length(UTF16Data)+1)*SizeOf(WideChar);
   ClipboardHandle:=Windows.GlobalAlloc(GMEM_MOVEABLE or GMEM_ZEROINIT or GMEM_DDESHARE,Size);
   if ClipboardHandle<>0 then begin
    Data:=Windows.GlobalLock(ClipboardHandle);
    if assigned(Data) then begin
     try
      Move(UTF16Data[1],Data^,length(UTF16Data)*SizeOf(WideChar));
      PWideChar(Data)[length(UTF16Data)+1]:=#0;
     finally
      Windows.GlobalUnlock(ClipboardHandle);
     end;
    end;
    Windows.EmptyClipboard;
    if Windows.SetClipboardData(CF_UNICODETEXT,ClipboardHandle)=0 then begin
     Error:=GetLastError;
     pvApplication.Log(LOG_DEBUG,'Clipboard','GetLastError '+IntToStr(Error));
    end;
   end else begin
    Error:=GetLastError;
    pvApplication.Log(LOG_DEBUG,'Clipboard','GetLastError '+IntToStr(Error));
   end;
  finally
   Windows.CloseClipboard;
  end;
 end;
end;
{$elseif defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
begin
 SDL_SetClipboardText(PAnsiChar(aTextString));
end;
{$else}
begin
end;
{$ifend}

procedure AudioFillBuffer(AudioEngine:TpvAudio;Buffer:TpvPointer;Len:TpvInt32);
begin
 while (AudioEngine.IsReady and AudioEngine.IsActive) and assigned(AudioEngine.Thread) and not AudioEngine.Thread.Terminated do begin
  if AudioEngine.RingBuffer.AvailableForRead>=Len then begin
   AudioEngine.RingBuffer.Read(Buffer,Len);
   AudioEngine.Thread.ReadEvent.SetEvent;
   exit;
  end;
  if AudioEngine.Thread.Sleeping<>0 then begin
   AudioEngine.Thread.Event.SetEvent;
  end;
  Sleep(1);
 end;
 FillChar(Buffer^,Len,0);
end;

{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
procedure SDLFillBuffer(UserData:TpvPointer;Stream:PSDLUInt8;Remain:TSDLInt32); cdecl;
begin
 AudioFillBuffer(UserData,Stream,Remain);
end;
{$else}
{$ifend}

{$if defined(Windows) and not (defined(PasVulkanUseSDL2) or defined(PasVulkanHeadless))}
procedure TpvApplicationMessageFiberProc(const lpFiberParameter:LPVOID); stdcall;
var Application:TpvApplication;
begin
 Application:=TpvApplication(lpFiberParameter);
 repeat
  Application.ProcessWin32APIMessages;
  SwitchToFiber(Application.fWin32MainFiber);
 until false;
end;
{$ifend}

constructor TpvApplicationUpdateThread.Create(const aApplication:TpvApplication);
begin
 fApplication:=aApplication;
 fEvent:=TPasMPSimpleEvent.Create;
 fDoneEvent:=TPasMPSimpleEvent.Create;
 fFPUExceptionMask:=GetExceptionMask;
 fFPUPrecisionMode:=GetPrecisionMode;
 fFPURoundingMode:=GetRoundMode;
 fInvoked:=false;
 inherited Create(false);
end;

destructor TpvApplicationUpdateThread.Destroy;
begin
 Shutdown;
 FreeAndNil(fEvent);
 FreeAndNil(fDoneEvent);
 inherited Destroy;
end;

procedure TpvApplicationUpdateThread.Shutdown;
begin
 if not Finished then begin
  Terminate;
  fEvent.SetEvent;
  WaitFor;
 end;
end;

procedure TpvApplicationUpdateThread.Invoke;
begin
 if not TPasMPInterlocked.CompareExchange(fInvoked,TPasMPBool32(true),TPasMPBool32(false)) then begin
  fEvent.SetEvent;
 end;
end;

procedure TpvApplicationUpdateThread.WaitForDone;
begin
 if TPasMPInterlocked.Read(fInvoked) then begin
  try
   repeat
    case fDoneEvent.WaitFor(10000) of
     TWaitResult.wrSignaled:begin
      break;
     end;
     TWaitResult.wrError:begin
      pvApplication.Log(LOG_ERROR,'TpvApplicationUpdateThread.WaitForDone','fDoneEvent.WaitFor failed! Last tag was '+IntToHex(UpdateThreadTag));
      break;
     end;
     TWaitResult.wrTimeout:begin
      pvApplication.Log(LOG_DEBUG,'TpvApplicationUpdateThread.WaitForDone','fDoneEvent.WaitFor timeouted! Trying again . . .  Last tag was '+IntToHex(UpdateThreadTag));
     end;
     TWaitResult.wrAbandoned:begin
      pvApplication.Log(LOG_ERROR,'TpvApplicationUpdateThread.WaitForDone','fDoneEvent.WaitFor abandoned! Last tag was '+IntToHex(UpdateThreadTag));
      break;
     end;
     else begin
      Assert(false);
     end;
    end;
   until false;
  finally
   TPasMPInterlocked.Exchange(fInvoked,TPasMPBool32(false));
  end;
 end;
end;

procedure TpvApplicationUpdateThread.Execute;
var ExceptionString:String;
begin
{$ifdef HAS_NAMETHREADFORDEBUGGING}
 NameThreadForDebugging('TpvApplicationUpdateThread');
{$endif}
 ReturnValue:=0;
 UpdateThreadTag:=0;
 Priority:=TThreadPriority.tpHigher;
 try
  SetExceptionMask(fFPUExceptionMask);
  SetPrecisionMode(fFPUPrecisionMode);
  SetRoundMode(fFPURoundingMode);
  while not Terminated do begin
   fEvent.WaitFor($FFFFFFFF);
   if Terminated then begin
    fDoneEvent.SetEvent;
    break;
   end else begin
    fApplication.UpdateJobFunction(nil,0);
    fDoneEvent.SetEvent;
   end;
  end;
 except
  on e:Exception do begin
   ExceptionString:=DumpExceptionCallStack(e);
{$if defined(fpc) and defined(android) and (defined(Release) or not defined(Debug))}
   __android_log_write(ANDROID_LOG_ERROR,'PasVulkanApplication',PAnsiChar(TpvApplicationRawByteString(ExceptionString)));
{$ifend}
   TpvApplication.Log(LOG_ERROR,'TpvApplicationUpdateThread.Execute',ExceptionString);
   LogCrash(ExceptionString);
   raise;
  end;
 end;
end;

constructor TpvApplication.Create;
var FrameIndex:TpvInt32;
begin

{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
 SDL_SetMainReady;

 SDL_SetHint(SDL_HINT_WINDOWS_DISABLE_THREAD_NAMING,'1');

{$if defined(Linux)}
{SDL_SetHint('SDL_VIDEODRIVER','wayland,x11');
 SDL_SetHint(SDL_HINT_VIDEO_DRIVER,'wayland,x11');//}
{$ifend}

{$else}
{$ifend}

 inherited Create;

 VulkanDisableFloatingPointExceptions;

{$if defined(Release)}
 fDebugging:=false;
{$elseif defined(Windows)}
 fDebugging:={$ifdef fpc}IsDebuggerPresent{$else}DebugHook<>0{$endif};
{$else}
 fDebugging:=false;
{$ifend}

 fLoadWasCalled:=false;

 fTitle:='PasVulkan Application';
 fVersion:=$0100;

 fWindowTitle:=fTitle;

 fHasNewWindowTitle:=false;

 fPathName:='PasVulkanApplication';

 fOldPathNames:=TpvApplicationStringList.Create;

 fCacheStoragePath:='';

 fLocalStoragePath:='';

 fRoamingStoragePath:='';

 fExternalStoragePath:='';

 fVulkanEventLock:=TPasMPCriticalSection.Create;

 if assigned(GlobalPasMP) then begin
  fPasMPInstance:=GlobalPasMP;
  fDoDestroyGlobalPasMPInstance:=false;
 end else begin
  GlobalPasMPCountThreads:=-1;
  GlobalPasMPMinimumCountThreads:=4;
  GlobalPasMPMaximumCountThreads:=-1;
  GlobalPasMPThreadHeadRoomForForeignTasks:=0;
  GlobalPasMPDoCPUCorePinning:=false;
  GlobalPasMPSleepingOnIdle:=true;
  GlobalPasMPAllWorkerThreadsHaveOwnSystemThreads:=false;
  GlobalPasMPProfiling:=false;
  fPasMPInstance:=TPasMP.GetGlobalInstance;
  pvCompressionPasMPInstance:=fPasMPInstance;
  fDoDestroyGlobalPasMPInstance:=true;
 end;

 if not assigned(fPasMPInstance.OnWorkerThreadException) then begin
  fPasMPInstance.OnWorkerThreadException:=PasMPInstanceOnWorkerThreadException;
 end;

 fPasMPProfilerSuppressGaps:=true;

 if assigned(fPasMPInstance.Profiler) then begin
  fPasMPProfilerVisibleTimePeriod:=(fPasMPInstance.Profiler.HighResolutionTimer.QuarterSecondInterval+1) shr 1;
 end else begin
  fPasMPProfilerVisibleTimePeriod:=-1;
 end;

 FillChar(fPasMPProfilerHistory,SizeOf(TPasMPProfilerHistory),#0);

 fPasMPProfilerHistoryCount:=0;

 fHighResolutionTimer:=TpvHighResolutionTimer.Create;

 fFrameLimiterHighResolutionTimerSleepWithDriftCompensation:=TpvHighResolutionTimerSleepWithDriftCompensation.Create(fHighResolutionTimer);

 fFramePacingSleepWithDriftCompensation:=TpvHighResolutionTimerSleepWithDriftCompensation.Create(fHighResolutionTimer);

 fDelayedObjectInstanceToFreeArray.Initialize;

 fDelayedObjectInstanceToFreeArrayLock:=TPasMPCriticalSection.Create;

 fAssets:=TpvApplicationAssets.Create(self);

 fFiles:=TpvApplicationFiles.Create(self);

 fInput:=TpvApplicationInput.Create(self);

 fClipboard:=TpvApplicationClipboard.Create(self);

 fAudio:=nil;

 fResourceManager:=TpvResourceManager.Create;

 for FrameIndex:=low(fVulkanFrameFences) to high(fVulkanFrameFences) do begin
  fVulkanFrameFences[FrameIndex]:=nil;
 end;

 fVulkanFrameFencesReady:=0;
 fVulkanFrameFenceCounter:=0;

 fRunnableList:=nil;
 fRunnableListCount:=0;
 fRunnableListCriticalSection:=TPasMPCriticalSection.Create;

 fLifecycleListenerList:=TList.Create;
 fLifecycleListenerListCriticalSection:=TPasMPCriticalSection.Create;

{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
 fLastPressedKeyEvent.SDLEvent.type_:=0;
{$else}
 fLastPressedKeyEvent.NativeEvent.Kind:=TpvApplicationNativeEventKind.None;
{$ifend}
 fKeyRepeatTimeAccumulator:=0;
 fKeyRepeatInterval:=fHighResolutionTimer.MillisecondInterval*100;
 fKeyRepeatInitialInterval:=fHighResolutionTimer.MillisecondInterval*400;
 fNativeKeyRepeat:=true;

 fCurrentWidth:=-1;
 fCurrentHeight:=-1;
 fCurrentFullscreen:=-1;
 fCurrentRealFullScreen:=-1;
 fCurrentFullScreenWidth:=-1;
 fCurrentFullScreenHeight:=-1;
 fCurrentFullScreenRefreshRate:=-1;
 fCurrentMaximized:=-1;
 fCurrentPresentMode:=High(TpvInt32);
 fCurrentVisibleMouseCursor:=-1;
 fCurrentCatchMouseOnButton:=-1;
 fCurrentCatchMouse:=-1;
 fCurrentEffectiveCatchMouse:=-1;
 fCurrentRelativeMouse:=-1;
 fCurrentHideSystemBars:=-1;
 fCurrentAcceptDragDropFiles:=-1;
 fCurrentBlocking:=-1;
 fCurrentWaitOnPreviousFrames:=-1;

 fSwapChainColorSpace:=TpvApplicationSwapChainColorSpace.SRGB;

 fSwapChainHDR:=false;

 fWidth:=1280;
 fHeight:=720;
 fFullScreenWidth:=0;
 fFullScreenHeight:=0;
 fFullScreenRefreshRate:=0;
 fUseRealFullScreen:=false;
 fFullScreen:=false;
 fMaximized:=false;
 fExclusiveFullScreenMode:=TpvVulkanExclusiveFullScreenMode.Default;
 fPresentMode:=TpvApplicationPresentMode.Immediate;
 fPresentFrameLatency:={$ifdef Android}2{$else}1{$endif};
 fPresentFrameLatencyMode:=TpvApplicationPresentFrameLatencyMode.CombinedWait;
 fProcessingMode:=TpvApplicationProcessingMode.Strict;
 fResizable:=true;
 fVisibleMouseCursor:=false;
 fCatchMouseOnButton:=false;
 fCatchMouse:=false;
 fEffectiveCatchMouse:=false;
 fRelativeMouse:=false;
 fHideSystemBars:=false;
 fAcceptDragDropFiles:=false;
 fUseBreadcrumbs:=false;
 fManualBreadcrumbs:=false;
 fManualSyncBreadcrumbs:=false;
 fDisplayOrientations:=[TpvApplicationDisplayOrientation.LandscapeLeft,TpvApplicationDisplayOrientation.LandscapeRight];
 fAndroidMouseTouchEvents:=false;
 fAndroidTouchMouseEvents:=false;
 fAndroidBlockOnPause:=true;
 fAndroidTrapBackButton:=true;
 fUseAudio:=false;
 fBlocking:=true;
 fUpdateWaitsForGPU:=false;
 fUseExtraUpdateThread:=false;
 fWaitOnPreviousFrames:=false;
 fWaitOnPreviousFrame:=false;
 fTerminationWithAltF4:=true;
 fTerminationOnQuitEvent:=true;

 fBackgroundResourceLoaderFrameTimeout:=5;

 fMaximumFramesPerSecond:=0.0;

 fActive:=true;

 fTerminated:=false;

 fGraphicsReady:=false;

 fReinitializeGraphics:=false;

 fSkipNextDrawFrame:=false;

 fStayActiveRegardlessOfVisibility:=false;

 fWindowMinimizedOrHidden:=false;

 fVulkanRecreateSwapChainOnSuboptimalSurface:=false;

 fVulkanDebugging:=false;

 fVulkanShaderPrintfDebugging:=false;

 fVulkanSynchronizationValidation:=false;

 fVulkanDebuggingEnabled:=false;

 fVulkanPreferDedicatedGPUs:=true;

 fVulkanValidation:=false;

 fVulkanNVIDIAAfterMath:=false;

 fVulkanNoUniqueObjectsValidation:=false;

 fVulkanMultiviewSupportEnabled:=false;

 fVulkanDelayResizeBugWorkaround:=false;

 fVulkanInstance:=nil;

 fVulkanDevice:=nil;

 fVulkanPipelineCache:=nil;

 fUpdateJob:=nil;

 fInUpdateJobFunction:=false;

 fCountCPUThreads:=Max(1,TPasMP.GetCountOfHardwareThreads(fAvailableCPUCores));
{$if defined(fpc) and defined(android)}
 __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication',PAnsiChar(TpvApplicationRawByteString('Detected CPU thread count: '+IntToStr(fCountCPUThreads))));
{$ifend}

{$if not (defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless))}
 fNativeEventQueue:=TpvApplicationNativeEventQueue.Create;

 fNativeEventLocalQueue.Initialize;
{$ifend}

{fVulkanCountCommandQueues:=0;

 fVulkanCommandPools:=nil;
 fVulkanCommandBuffers:=nil;
 fVulkanCommandBufferFences:=nil;

 fVulkanUniversalCommandPools:=nil;
 fVulkanUniversalCommandBuffers:=nil;
 fVulkanUniversalCommandBufferFences:=nil;

 fVulkanPresentCommandPools:=nil;
 fVulkanPresentCommandBuffers:=nil;
 fVulkanPresentCommandBufferFences:=nil;

 fVulkanGraphicsCommandPools:=nil;
 fVulkanGraphicsCommandBuffers:=nil;
 fVulkanGraphicsCommandBufferFences:=nil;

 fVulkanComputeCommandPools:=nil;
 fVulkanComputeCommandBuffers:=nil;
 fVulkanComputeCommandBufferFences:=nil;

 fVulkanTransferCommandPools:=nil;
 fVulkanTransferCommandBuffers:=nil;
 fVulkanTransferCommandBufferFences:=nil;}

 fVulkanPresentID:=0;

 fVulkanPresentLastID:=0;

 fVulkanAPIVersion:=VK_API_VERSION_1_0;

 fVulkanPhysicalDeviceHandle:=VK_NULL_HANDLE;

 fVulkanBackBufferState:=TVulkanBackBufferState.Acquire;

 fAcquireVulkanBackBufferState:=TAcquireVulkanBackBufferState.Entry;

 fVulkanSwapChainQueueFamilyIndices.Initialize;

 fVulkanSwapChain:=nil;

 fVulkanOldSwapChain:=nil;

 fVulkanTransferInFlightCommandsFromOldSwapChain:=false;

 fScreenLock:=TPasMPCriticalSection.Create;

 fScreen:=nil;

 fNextScreen:=nil;

 fNextScreenClass:=nil;

 fHasNewNextScreen:=false;

 fHasLastTime:=false;

 fLastTime:=0;
 fNowTime:=0;
 fDeltaTime:=0;

//fNextTime:=0;

 fFrameRateLimiterLastTime:=0;
 fFrameRateLimiterDeviation:=0;

 fFramePacingMode:=TpvApplicationFramePacingMode.None;
 fFramePacingStrategy:=TpvApplicationFramePacingStrategy.AbsoluteTimeRaster;
 fFramePacingActive:=false;
 fFramePacingEstimatedRefreshInterval:=0;
 fFramePacingNextPresentTarget:=0;
 fFramePacingLastPresentTime:=0;
 FillChar(fFramePacingHistory,SizeOf(fFramePacingHistory),#0);
 fFramePacingHistoryIndex:=0;
 fFramePacingHistoryCount:=0;
 fFramePacingDriftAccumulator:=0;
 fFramePacingPresentTimingRefreshDuration:=0;
 fFramePacingPresentTimingTimeDomainID:=0;
 fFramePacingPresentTimingAvailable:=false;
 fFramePacingEffectiveInterval:=0;

 fPresentTimingFeedbackRefreshDuration:=0;
 fPresentTimingFeedbackRefreshInterval:=0;
 fPresentTimingFeedbackRefreshMode:=TpvApplicationPresentTimingFeedbackRefreshMode.Unknown;
 fPresentTimingFeedbackRefreshCounter:=0;
 fPresentTimingFeedbackHasRefreshFeedback:=false;
 fPresentTimingFeedbackTimeDomainCount:=0;
 fPresentTimingFeedbackActiveTimeDomainID:=0;
 fPresentTimingFeedbackCalibratedHostTime:=0;
 fPresentTimingFeedbackCalibratedStageTime:=0;
 fPresentTimingFeedbackLastRecalibrationTime:=0;
 fPresentTimingFeedbackNeedRecalibration:=true;
 fPresentTimingFeedbackLastTargetTime:=0;
 fPresentTimingFeedbackPresentationTimeError:=0;
 fPresentTimingFeedbackPendingCompensation:=0;
 fPresentTimingFeedbackLastPollPresentID:=0;
 fPresentTimingFeedbackErrorRingIndex:=0;
 fPresentTimingFeedbackErrorRingCount:=0;
 fPresentTimingFeedbackInitialized:=false;

 fLowLatencyMode:=TpvApplicationLowLatencyMode.None;
 fLowLatencyActive:=false;
 fLowLatencyActiveMode:=TpvApplicationLowLatencyMode.None;
 fLowLatencyFrameID:=0;
 fLowLatencySleepSemaphore:=nil;

 fFrameCounter:=0;

 fUpdateFrameCounter:=0;

 fDrawFrameCounter:=0;

 fTimingCPUUpdate:=0.0;
 fTimingCPUDraw:=0.0;
 fTimingCPUBeginFrame:=0.0;
 fTimingCPUFinishFrame:=0.0;
 fTimingCPUAcquire:=0.0;
 fTimingCPUPresent:=0.0;
 fTimingCPUFramePacing:=0.0;
 fTimingCPUUpdateWait:=0.0;
 fTimingCPUFrameStartTime:=0;
 fTimingCPUUpdateStart:=0.0;
 fTimingCPUUpdateEnd:=0.0;
 fTimingCPUDrawStart:=0.0;
 fTimingCPUDrawEnd:=0.0;

 SetDesiredCountInFlightFrames(2);

 fPreviousInFlightFrameIndex:=1;

 fCurrentInFlightFrameIndex:=0;

 fNextInFlightFrameIndex:=1;

 fDrawInFlightFrameIndex:=0;

 fUpdateInFlightFrameIndex:=1;

 SetDesiredCountSwapChainImages(3);

 fCountSwapChainImages:=1;

 fSwapChainImageCounterIndex:=0;

 fSwapChainImageIndex:=0;

 fOnEvent:=nil;

 fUniverse:=nil;

 for FrameIndex:=0 to MaxInFlightFrames-1 do begin
  fVulkanInFlightFenceIndices[FrameIndex]:=-1;
 end;

 pvApplication:=self;

 ParseCommandLine;

end;

destructor TpvApplication.Destroy;
begin

 ClearDelayedObjectsToFree;

{$if not (defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless))}
 fNativeEventLocalQueue.Finalize;

 FreeAndNil(fNativeEventQueue);
{$ifend}

 FreeAndNil(fLifecycleListenerList);
 FreeAndNil(fLifecycleListenerListCriticalSection);

 FreeAndNil(fUniverse);

 fRunnableList:=nil;
 fRunnableListCount:=0;
 FreeAndNil(fRunnableListCriticalSection);

 FreeAndNil(fResourceManager);

 FreeAndNil(fAudio);

 FreeAndNil(fClipboard);

 FreeAndNil(fInput);

 FreeAndNil(fFiles);

 FreeAndNil(fAssets);

 FreeAndNil(fOldPathNames);

 FreeAndNil(fDelayedObjectInstanceToFreeArrayLock);
 fDelayedObjectInstanceToFreeArray.Finalize;

 FreeAndNil(fFrameLimiterHighResolutionTimerSleepWithDriftCompensation);
 FreeAndNil(fFramePacingSleepWithDriftCompensation);

 FreeAndNil(fHighResolutionTimer);

 if fDoDestroyGlobalPasMPInstance then begin
  TPasMP.DestroyGlobalInstance;
 end;

 fPasMPInstance:=nil;

 FreeAndNil(fVulkanEventLock);

 FreeAndNil(fScreenLock);

 pvApplication:=nil;

 inherited Destroy;
end;

class procedure TpvApplication.VulkanDebugLn(const What:TpvUTF8String);
{$if defined(Windows)}
{$if defined(Debug) or not defined(Release)}
const AnsiCRLF:array[0..1] of AnsiChar=(#13,#10);
      WideCRLF:array[0..1] of WideChar=(#13,#10);
var TemporaryString:WideString;
{$ifend}
begin
{$if defined(Debug) or not defined(Release)}
 if pvOutputLogLevel>LOG_NONE then begin
  if pvDebuggerPresent then begin
   TemporaryString:=PUCUUTF8ToUTF16(What);
   OutputDebugStringW(PWideChar(TemporaryString));
  end else begin
   TemporaryString:='';
  end;
  if (pvStdOut<>0) and (pvStdOut<>Invalid_Handle_Value) then begin
   if pvIsStdOutUTF8 then begin
    WriteConsoleA(pvStdOut,PAnsiChar(What),length(What),PCardinal(nil)^,nil);
    WriteConsoleA(pvStdOut,PAnsiChar(@AnsiCRLF[0]),Length(AnsiCRLF),PCardinal(nil)^,nil);
   end else begin
    if not pvDebuggerPresent then begin
     TemporaryString:=PUCUUTF8ToUTF16(What);
    end;
    WriteConsoleW(pvStdOut,PWideChar(TemporaryString),length(TemporaryString),PCardinal(nil)^,nil);
    WriteConsoleW(pvStdOut,PAnsiChar(@WideCRLF[0]),Length(WideCRLF),PCardinal(nil)^,nil);
   end;
 //WriteLn(What);
  end;
 end;
{$ifend}
end;
{$elseif defined(fpc) and defined(android)}
begin
{$if defined(Debug) or not defined(Release)}
 if pvOutputLogLevel>LOG_NONE then begin
  __android_log_write(ANDROID_LOG_DEBUG,'PasVulkanApplication',PAnsiChar(TpvUTF8String(What)));
 end;
{$ifend}
end;
{$else}
begin
{$if defined(Debug) or not defined(Release)}
 if pvOutputLogLevel>LOG_NONE then begin
  WriteLn({$ifdef Windows}WideString(What){$else}What{$endif});
 end;
{$ifend}
end;
{$ifend}

class procedure TpvApplication.Log(const aLevel:TpvInt32;const aWhere,aWhat:TpvUTF8String);
begin
 if aLevel<=pvOutputLogLevel then begin
{$if (defined(fpc) and defined(android)) and (defined(Debug) or not defined(Release))}
  case aLevel of
   LOG_NONE:begin
   end;
   LOG_ERROR:begin
    __android_log_write(ANDROID_LOG_ERROR,PAnsiChar(TpvUTF8String(aWhere)),PAnsiChar(TpvUTF8String(aWhat)));
   end;
   LOG_INFO:begin
    __android_log_write(ANDROID_LOG_INFO,PAnsiChar(TpvUTF8String(aWhere)),PAnsiChar(TpvUTF8String(aWhat)));
   end;
   LOG_VERBOSE:begin
    __android_log_write(ANDROID_LOG_VERBOSE,PAnsiChar(TpvUTF8String(aWhere)),PAnsiChar(TpvUTF8String(aWhat)));
   end;
   LOG_DEBUG:begin
    __android_log_write(ANDROID_LOG_DEBUG,PAnsiChar(TpvUTF8String(aWhere)),PAnsiChar(TpvUTF8String(aWhat)));
   end;
  end;
{$elseif defined(Debug) or not defined(Release)}
  case aLevel of
   LOG_NONE:begin
   end;
   LOG_ERROR:begin
    VulkanDebugLn('[Error] '+aWhere+': '+aWhat);
   end;
   LOG_INFO:begin
    VulkanDebugLn('[Info] '+aWhere+': '+aWhat);
   end;
   LOG_VERBOSE:begin
    VulkanDebugLn('[Verbose] '+aWhere+': '+aWhat);
   end;
   LOG_DEBUG:begin
    VulkanDebugLn('[Debug] '+aWhere+': '+aWhat);
   end;
  end;
{$ifend}
 end;
end;

procedure TpvApplication.ParseCommandLine;
var Index,Count:TpvSizeInt;
    Value:TpvInt32;
    Parameter:string;
begin

 // Parse command line parameters
 Index:=1;
 Count:=ParamCount;
 while Index<=Count do begin
  Parameter:=LowerCase(ParamStr(Index));
  inc(Index);
  if (length(Parameter)>0) and ((Parameter[1]='-') or (Parameter[1]='/')) then begin
   Delete(Parameter,1,1);
   if (length(Parameter)>0) and ((Parameter[1]='-') or (Parameter[1]='/')) then begin
    Delete(Parameter,1,1);
   end;
   if Parameter='breadcrumbs' then begin
    fUseBreadcrumbs:=true;
   end else if Parameter='manualbreadcrumbs' then begin
    fManualBreadcrumbs:=true;
   end else if Parameter='manualsyncbreadcrumbs' then begin
    fManualSyncBreadcrumbs:=true;
   end;
  end;
 end;
end;

procedure TpvApplication.ProcessOldPathNames;
var Index,PartIndex:TpvSizeInt;
    OldPathName,OldPath,NewPath:TpvUTF8String;
    OldPaths,NewPaths:array[0..2] of TpvUTF8String;
begin

 if assigned(fOldPathNames) and (fOldPathNames.Count>0) then begin

  for Index:=0 to fOldPathNames.Count-1 do begin

   OldPathName:=fOldPathNames.Items[Index];
   if (length(OldPathName)>0) and (OldPathName<>fPathName) then begin

    OldPaths[0]:=TpvUTF8String(ExcludeTrailingPathDelimiter(GetAppDataCacheStoragePath(String(OldPathName))));
    NewPaths[0]:=ExcludeTrailingPathDelimiter(fCacheStoragePath);

    OldPaths[1]:=TpvUTF8String(ExcludeTrailingPathDelimiter(GetAppDataLocalStoragePath(String(OldPathName))));
    NewPaths[1]:=ExcludeTrailingPathDelimiter(fLocalStoragePath);

    OldPaths[2]:=TpvUTF8String(ExcludeTrailingPathDelimiter(GetAppDataRoamingStoragePath(String(OldPathName))));
    NewPaths[2]:=ExcludeTrailingPathDelimiter(fRoamingStoragePath);

    for PartIndex:=0 to 2 do begin

     OldPath:=OldPaths[PartIndex];
     NewPath:=NewPaths[PartIndex];

     if OldPath<>NewPath then begin

      if (length(OldPath)>0) and DirectoryExists(String(OldPath)) then begin

       if (length(NewPath)>0) and not DirectoryExists(String(NewPath)) then begin

        if not RenameFile(String(OldPath),String(NewPath)) then begin

         if DirectoryExists(String(NewPath)) then begin
          // Merge contents if target already exists after failed rename
         end;

        end;

       end;

      end;

     end;

    end;

   end;

  end;

 end;

end;

procedure TpvApplication.ClearDelayedObjectsToFree;
var Index:TpvSizeInt;
begin
 fDelayedObjectInstanceToFreeArrayLock.Acquire;
 try
  for Index:=0 to fDelayedObjectInstanceToFreeArray.Count-1 do begin
   FreeAndNil(fDelayedObjectInstanceToFreeArray.Items[Index].ObjectInstance);
  end;
  fDelayedObjectInstanceToFreeArray.Clear;
 finally
  fDelayedObjectInstanceToFreeArrayLock.Release;
 end;
end;

procedure TpvApplication.ClearDelayedObjectsToFreeIteration;
var Index:TpvSizeInt;
    Item:PpvApplicationDelayedObjectInstanceToFree;
begin
 fDelayedObjectInstanceToFreeArrayLock.Acquire;
 try
  Index:=0;
  while Index<fDelayedObjectInstanceToFreeArray.Count do begin
   Item:=@fDelayedObjectInstanceToFreeArray.Items[Index];
   if Item^.IterationsLeft<=0 then begin
    FreeAndNil(Item^.ObjectInstance);
    fDelayedObjectInstanceToFreeArray.Delete(Index);
   end else begin
    dec(Item^.IterationsLeft);
    inc(Index);
   end;
  end;
 finally
  fDelayedObjectInstanceToFreeArrayLock.Release;
 end;
end;

procedure TpvApplication.DelayFreeObjectInstance(const aObjectInstance:TObject;const aIterationsDelay:TpvInt32);
var Item:PpvApplicationDelayedObjectInstanceToFree;
begin
 fDelayedObjectInstanceToFreeArrayLock.Acquire;
 try
  Item:=pointer(fDelayedObjectInstanceToFreeArray.AddNew);
  Item^.ObjectInstance:=aObjectInstance;
  Item^.IterationsLeft:=aIterationsDelay;
 finally
  fDelayedObjectInstanceToFreeArrayLock.Release;
 end;
end;

function TpvApplication.PasMPInstanceOnWorkerThreadException(const aException:Exception):Boolean;
var ExceptionString:string;
begin
 ExceptionString:=DumpExceptionCallStack(aException);
{$if defined(fpc) and defined(android) and (defined(Release) or not defined(Debug))}
 __android_log_write(ANDROID_LOG_ERROR,'PasVulkanApplication',PAnsiChar(TpvApplicationRawByteString(ExceptionString)));
{$ifend}
 TpvApplication.Log(LOG_ERROR,'TpvApplication.PasMPInstanceOnWorkerThreadException',TpvUTF8String(ExceptionString));
 LogCrash(ExceptionString);
 result:=false;
end;

function TpvApplication.GetNativeRefreshRate:TpvDouble;
{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
var SDLDisplayMode:TSDL_DisplayMode;
begin
 if SDL_GetDesktopDisplayMode(SDL_GetWindowDisplayIndex(pvApplication.fSurfaceWindow),@SDLDisplayMode)=0 then begin
  result:=SDLDisplayMode.refresh_rate;
 end else begin
  result:=0.0;
 end;
end;
{$elseif defined(Windows) and not defined(PasVulkanHeadless)}
const ENUM_CURRENT_SETTINGS=DWORD(-1);
var MonitorHandle:HMONITOR;
    MonitorInfoEx:{$ifdef fpc}TMONITORINFOEXW{$else}TMonitorInfoExW{$endif};
    devMode:{$ifdef fpc}TDEVMODEW{$else}DEVMODEW{$endif};
begin
 result:=0.0;
 MonitorHandle:=MonitorFromWindow(fWin32Handle,MONITOR_DEFAULTTONEAREST);
 if MonitorHandle<>0 then begin
  FillChar(MonitorInfoEx,SizeOf(MonitorInfoEx),#0);
  MonitorInfoEx.cbSize:=SizeOf(MonitorInfoEx);
  if {$ifdef fpc}GetMonitorInfo{$else}GetMonitorInfoW{$endif}(MonitorHandle,@MonitorInfoEx) then begin
   FillChar(devMode,SizeOf(devMode),#0);
   devMode.dmSize:=SizeOf(devMode);
   if EnumDisplaySettingsW(@MonitorInfoEx.szDevice[0],ENUM_CURRENT_SETTINGS,{$ifdef fpc}@{$endif}devMode) then begin
    if devMode.dmDisplayFrequency>1 then begin
     result:=devMode.dmDisplayFrequency;
    end;
   end;
  end;
 end;
end;
{$else}
begin
 result:=0.0;
end;
{$ifend}

procedure TpvApplication.SetTitle(const aTitle:TpvUTF8String);
begin
 if fTitle<>aTitle then begin
  fTitle:=aTitle;
  SetWindowTitle(fTitle);
 end;
end;

procedure TpvApplication.SetWindowTitle(const aWindowTitle:TpvUTF8String);
begin
 if fWindowTitle<>aWindowTitle then begin
  fWindowTitle:=aWindowTitle;
  TPasMPInterlocked.Write(fHasNewWindowTitle,true);
 end;
end;

procedure TpvApplication.SetDesiredCountInFlightFrames(const aDesiredCountInFlightFrames:TpvInt32);
begin
 if aDesiredCountInFlightFrames<0 then begin
  fDesiredCountInFlightFrames:=-1;
 end else if aDesiredCountInFlightFrames<1 then begin
  fDesiredCountInFlightFrames:=1;
 end else if aDesiredCountInFlightFrames>MaxInFlightFrames then begin
  fDesiredCountInFlightFrames:=MaxInFlightFrames;
 end else begin
  fDesiredCountInFlightFrames:=aDesiredCountInFlightFrames;
 end;
end;

procedure TpvApplication.SetDesiredCountSwapChainImages(const aDesiredCountSwapChainImages:TpvInt32);
begin
 if aDesiredCountSwapChainImages<1 then begin
  fDesiredCountSwapChainImages:=1;
 end else if aDesiredCountSwapChainImages>MaxSwapChainImages then begin
  fDesiredCountSwapChainImages:=MaxSwapChainImages;
 end else begin
  fDesiredCountSwapChainImages:=aDesiredCountSwapChainImages;
 end;
end;

function TpvApplication.GetAndroidSeparateMouseAndTouch:boolean;
begin
 result:=not (fAndroidMouseTouchEvents or fAndroidTouchMouseEvents);
end;

procedure TpvApplication.SetAndroidSeparateMouseAndTouch(const aValue:boolean);
begin
 if GetAndroidSeparateMouseAndTouch<>aValue then begin
  fAndroidMouseTouchEvents:=not aValue;
  fAndroidTouchMouseEvents:=not aValue;
 end;
end;

function TpvApplication.VulkanOnDebugReportCallback(const aFlags:TVkDebugReportFlagsEXT;const aObjectType:TVkDebugReportObjectTypeEXT;const aObject:TpvUInt64;const aLocation:TVkSize;aMessageCode:TpvInt32;const aLayerPrefix,aMessage:TpvUTF8String):TVkBool32;
var Prefix:TpvUTF8String;
begin
 try
  Prefix:='';
  if (aFlags and TVkDebugReportFlagsEXT(VK_DEBUG_REPORT_ERROR_BIT_EXT))<>0 then begin
   Prefix:=Prefix+'ERROR: ';
  end;
  if (aFlags and TVkDebugReportFlagsEXT(VK_DEBUG_REPORT_WARNING_BIT_EXT))<>0 then begin
   Prefix:=Prefix+'WARNING: ';
  end;
  if (aFlags and TVkDebugReportFlagsEXT(VK_DEBUG_REPORT_PERFORMANCE_WARNING_BIT_EXT))<>0 then begin
   Prefix:=Prefix+'PERFORMANCE: ';
  end;
  if (aFlags and TVkDebugReportFlagsEXT(VK_DEBUG_REPORT_INFORMATION_BIT_EXT))<>0 then begin
   Prefix:=Prefix+'INFORMATION: ';
  end;
  if (aFlags and TVkDebugReportFlagsEXT(VK_DEBUG_REPORT_DEBUG_BIT_EXT))<>0 then begin
   Prefix:=Prefix+'DEBUG: ';
  end;
  VulkanDebugLn('[Debug] '+Prefix+'['+aLayerPrefix+'] Code '+TpvUTF8String(IntToStr(aMessageCode))+' : '+aMessage);
 finally
  result:=VK_FALSE;
 end;
end;

function TpvApplication.VulkanOnDebugUtilsMessengerCallback(const aMessageSeverity:TVkDebugUtilsMessageSeverityFlagsEXT;const aMessageTypes:TVkDebugUtilsMessageTypeFlagsEXT;const aCallbackData:PVkDebugUtilsMessengerCallbackDataEXT;const aUserData:pointer):TVkBool32;
const NewLine={$if defined(Windows)}#13#10{$else}#10{$ifend};
      Tab=#9;
var Index:TpvSizeInt;
    Message,MessageIDName,MessageTypes,MessageSeverityTypes,Objects,QueueLabels,CmdBufLabels,Whole:TpvUTF8String;
    pObjects:PVkDebugUtilsObjectNameInfoEXT;
    pLabels:PVkDebugUtilsLabelEXT;
    DoBreak:Boolean;
    LogLevel:TpvInt32;
begin

 DoBreak:=false;

 try

  if pvOutputLogLevel>LOG_NONE then begin

   if assigned(aCallbackData) then begin

    Message:=aCallbackData^.pMessage;

    MessageIDName:=aCallbackData^.pMessageIdName;

    if (pos('Mapping an image with layout',String(Message))>0) and (pos('can result in undefined behavior if this memory is used by the device',String(Message))>0) then begin
     // Ignore because the AMD allocator will mix up memory types on IGP processors.
    end else if pos('Invalid SPIR-V binary version 1.3',String(Message))>0 then begin
     // Ignore because the validator is wrong here.
    end else if pos('Shader requires flag',String(Message))>0 then begin
     // Ignore because the validator is wrong here.
    end else if (pos('SPIR-V module not valid: Pointer operand',String(Message))>0) and (pos('must be a memory object',String(Message))>0) then begin
     // Ignore because the validator is wrong here.
    end else if pos('UNASSIGNED-CoreValidation-DrawState-ClearCmdBeforeDraw',String(MessageIDName))>0 then begin
     // Ignore
    end else begin

     LogLevel:=LOG_DEBUG;
     MessageSeverityTypes:='';
     if (aMessageSeverity and TVkDebugUtilsMessageSeverityFlagsEXT(VK_DEBUG_UTILS_MESSAGE_SEVERITY_VERBOSE_BIT_EXT))<>0 then begin
      if length(MessageSeverityTypes)>0 then begin
       MessageSeverityTypes:=MessageSeverityTypes+'|';
      end;
      MessageSeverityTypes:=MessageSeverityTypes+'VERBOSE';
      LogLevel:=LOG_VERBOSE;
     end;
     if (aMessageSeverity and TVkDebugUtilsMessageSeverityFlagsEXT(VK_DEBUG_UTILS_MESSAGE_SEVERITY_INFO_BIT_EXT))<>0 then begin
      if length(MessageSeverityTypes)>0 then begin
       MessageSeverityTypes:=MessageSeverityTypes+'|';
      end;
      MessageSeverityTypes:=MessageSeverityTypes+'INFORMATION';
      LogLevel:=LOG_INFO;
     end;
     if (aMessageSeverity and TVkDebugUtilsMessageSeverityFlagsEXT(VK_DEBUG_UTILS_MESSAGE_SEVERITY_WARNING_BIT_EXT))<>0 then begin
      if length(MessageSeverityTypes)>0 then begin
       MessageSeverityTypes:=MessageSeverityTypes+'|';
      end;
      MessageSeverityTypes:=MessageSeverityTypes+'WARNING';
      LogLevel:=LOG_INFO;
     end;
     if (aMessageSeverity and TVkDebugUtilsMessageSeverityFlagsEXT(VK_DEBUG_UTILS_MESSAGE_SEVERITY_ERROR_BIT_EXT))<>0 then begin
      if length(MessageSeverityTypes)>0 then begin
       MessageSeverityTypes:=MessageSeverityTypes+'|';
      end;
      MessageSeverityTypes:=MessageSeverityTypes+'ERROR';
      LogLevel:=LOG_ERROR;
      DoBreak:=true;
     end;

     MessageTypes:='';
     if (aMessageTypes and TVkDebugUtilsMessageTypeFlagsEXT(VK_DEBUG_UTILS_MESSAGE_TYPE_GENERAL_BIT_EXT))<>0 then begin
      if length(MessageTypes)>0 then begin
       MessageTypes:=MessageTypes+'|';
      end;
      MessageTypes:=MessageTypes+'GENERAL';
     end;
     if (aMessageTypes and TVkDebugUtilsMessageTypeFlagsEXT(VK_DEBUG_UTILS_MESSAGE_TYPE_VALIDATION_BIT_EXT))<>0 then begin
      if length(MessageTypes)>0 then begin
       MessageTypes:=MessageTypes+'|';
      end;
      MessageTypes:=MessageTypes+'VALIDATION';
     end;
     if (aMessageTypes and TVkDebugUtilsMessageTypeFlagsEXT(VK_DEBUG_UTILS_MESSAGE_TYPE_PERFORMANCE_BIT_EXT))<>0 then begin
      if length(MessageTypes)>0 then begin
       MessageTypes:=MessageTypes+'|';
      end;
      MessageTypes:=MessageTypes+'PERFORMANCE';
     end;
     if (aMessageTypes and TVkDebugUtilsMessageTypeFlagsEXT(VK_DEBUG_UTILS_MESSAGE_TYPE_DEVICE_ADDRESS_BINDING_BIT_EXT))<>0 then begin
      if length(MessageTypes)>0 then begin
       MessageTypes:=MessageTypes+'|';
      end;
      MessageTypes:=MessageTypes+'DEVICE_ADDRESS_BINDING';
     end;

     Objects:='';
     if aCallbackData^.objectCount>0 then begin
      Objects:=NewLine+Tab+'Objects - '+TpvUTF8String(IntToStr(aCallbackData^.objectCount));
      pObjects:=aCallbackData^.pObjects;
      for Index:=0 to TpvSizeInt(aCallbackData^.objectCount)-1 do begin
       Objects:=Objects+NewLine+Tab+Tab+'Object['+TpvUTF8String(IntToStr(Index))+'] - '+
                TpvUTF8String(VulkanObjectTypeToString(pObjects^.objectType))+', '+
                'Handle '+TpvUTF8String(UIntToStr(TpvUInt64(pObjects^.objectHandle)));
       if assigned(pObjects^.pObjectName) and (length(pObjects^.pObjectName)>0) then begin
        Objects:=Objects+', Name '+TpvUTF8String(pObjects^.pObjectName);
       end;
       inc(pObjects);
      end;
     end;

     QueueLabels:='';
     if aCallbackData^.QueueLabelCount>0 then begin
      QueueLabels:=NewLine+Tab+'Queue labels - '+TpvUTF8String(IntToStr(aCallbackData^.QueueLabelCount));
      pLabels:=aCallbackData^.pQueueLabels;
      for Index:=0 to TpvSizeInt(aCallbackData^.QueueLabelCount)-1 do begin
       QueueLabels:=QueueLabels+NewLine+Tab+Tab+'Label['+TpvUTF8String(IntToStr(Index))+'] - '+TpvUTF8String(pLabels^.pLabelName)+'{ '+TpvUTF8String(ConvertDoubleToString(pLabels^.color[0]))+', '+TpvUTF8String(ConvertDoubleToString(pLabels^.color[1]))+', '+TpvUTF8String(ConvertDoubleToString(pLabels^.color[2]))+', '+TpvUTF8String(ConvertDoubleToString(pLabels^.color[3]))+' }';
       inc(pLabels);
      end;
     end;

     CmdBufLabels:='';
     if aCallbackData^.cmdBufLabelCount>0 then begin
      CmdBufLabels:=NewLine+Tab+'Command buffer labels - '+IntToStr(aCallbackData^.cmdBufLabelCount);
      pLabels:=aCallbackData^.pCmdBufLabels;
      for Index:=0 to TpvSizeInt(aCallbackData^.cmdBufLabelCount)-1 do begin
       CmdBufLabels:=CmdBufLabels+NewLine+Tab+Tab+'Label['+IntToStr(Index)+'] - '+TpvUTF8String(pLabels^.pLabelName)+'{ '+ConvertDoubleToString(pLabels^.color[0])+', '+ConvertDoubleToString(pLabels^.color[1])+', '+ConvertDoubleToString(pLabels^.color[2])+', '+ConvertDoubleToString(pLabels^.color[3])+' }';
       inc(pLabels);
      end;
     end;

     if LogLevel<=pvOutputLogLevel then begin

      Whole:='[Debug] '+MessageSeverityTypes+': '+MessageTypes+' - Message ID number: '+IntToStr(aCallbackData^.messageIdNumber)+' - Message ID name: '+MessageIDName+NewLine+Tab+Message+Objects+QueueLabels+CmdBufLabels;

      VulkanDebugLn(Whole);

     end;

    end;

   end;

  end;

 finally
  result:=VK_FALSE;
 end;

 if DoBreak then begin
  Sleep(0);
 end;

end;

procedure TpvApplication.VulkanWaitIdle;
var Index,SubIndex:TpvInt32;
begin
{$if (defined(fpc) and defined(android)) and not defined(Release)}
 __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Entering TpvApplication.VulkanWaitIdle');
{$ifend}
 try
  if assigned(fVulkanDevice) then begin
   if fUpdateWaitsForGPU then begin
    if fUseExtraUpdateThread and assigned(fUpdateThread) then begin
     fUpdateThread.WaitForDone;
    end else begin
     if assigned(fUpdateJob) then begin
      try
       fPasMPInstance.WaitRelease(fUpdateJob);
      finally
       fUpdateJob:=nil;
      end;
     end;
     while TPasMPInterlocked.Read(fInUpdateJobFunction) do begin
      TPasMP.Yield;
     end;
    end;
   end;
   fVulkanDevice.WaitIdle;
   for Index:=0 to Max(length(fVulkanPresentCompleteFencesReady),length(fVulkanWaitFences))-1 do begin
    if (Index<length(fVulkanPresentCompleteFencesReady)) and fVulkanPresentCompleteFencesReady[Index] then begin
     fVulkanPresentCompleteFences[Index].WaitFor;
     fVulkanPresentCompleteFences[Index].Reset;
     fVulkanPresentCompleteFencesReady[Index]:=false;
    end;
    if (Index<length(fVulkanWaitFencesReady)) and fVulkanWaitFencesReady[Index] and assigned(fVulkanWaitFences[Index]) then begin
     fVulkanWaitFences[Index].WaitFor;
     fVulkanWaitFences[Index].Reset;
     fVulkanWaitFencesReady[Index]:=false;
    end;
   end;
   for Index:=0 to length(fVulkanDevice.QueueFamilyQueues)-1 do begin
    for SubIndex:=0 to length(fVulkanDevice.QueueFamilyQueues[Index])-1 do begin
     if assigned(fVulkanDevice.QueueFamilyQueues[Index,SubIndex]) then begin
      fVulkanDevice.QueueFamilyQueues[Index,SubIndex].WaitIdle;
     end;
    end;
   end;
   fVulkanDevice.WaitIdle;
  end;
 finally
{$if (defined(fpc) and defined(android)) and not defined(Release)}
  __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Leaving TpvApplication.VulkanWaitIdle');
{$ifend}
 end;
end;

procedure TpvApplication.AddQueues;
begin
 fVulkanDevice.AddQueues(fVulkanSurface,true,false);
end;

procedure TpvApplication.CreateVulkanDevice(const aSurface:TpvVulkanSurface=nil);
var QueueFamilyIndex,ThreadIndex,SwapChainImageIndex,Index:TpvInt32;
    FormatProperties:TVkFormatProperties;
    PhysicalDevice:TpvVulkanPhysicalDevice;
    DriverVersionString:RawByteString;
begin
{$if (defined(fpc) and defined(android)) and not defined(Release)}
 __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Entering TpvApplication.CreateVulkanDevice');
{$ifend}
 if not assigned(VulkanDevice) then begin

{$if (defined(fpc) and defined(android)) and not defined(Release)}
  __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Creating vulkan device');
{$ifend}

  PhysicalDevice:=nil;

  ChooseVulkanPhysicalDevice(PhysicalDevice);

  if (fVulkanPhysicalDeviceHandle<>VK_NULL_HANDLE) and not assigned(PhysicalDevice) then begin
   for Index:=0 to fVulkanInstance.PhysicalDevices.Count-1 do begin
    if fVulkanInstance.PhysicalDevices.Items[Index].Handle=fVulkanPhysicalDeviceHandle then begin
     PhysicalDevice:=fVulkanInstance.PhysicalDevices.Items[Index];
    end;
   end;
   if not assigned(PhysicalDevice) then begin
    VulkanDebugLn('Failed to find requested physical device, falling back to choosing best physical device');
   end;
  end;

  fVulkanDevice:=TpvVulkanDevice.Create(fVulkanInstance,
                                        PhysicalDevice,
                                        aSurface,
                                        nil,
                                        fVulkanPreferDedicatedGPUs);

  fVulkanDevice.UseBreadcrumbs:=fUseBreadcrumbs;
  fVulkanDevice.BreadcrumbForceManual:=fManualBreadcrumbs;
  fVulkanDevice.BreadcrumbForceSyncManual:=fManualSyncBreadcrumbs;

  fVulkanPhysicalDeviceHandle:=fVulkanDevice.PhysicalDevice.Handle;

  VulkanDebugLn('Device name: '+TpvUTF8String(fVulkanDevice.PhysicalDevice.DeviceName));

  VulkanDebugLn('Device Vendor ID: 0x'+
                TpvUTF8String(IntToHex(fVulkanDevice.PhysicalDevice.Properties.vendorID,8)));

  VulkanDebugLn('Device ID: 0x'+
                TpvUTF8String(IntToHex(fVulkanDevice.PhysicalDevice.Properties.deviceID,8)));

  VulkanDebugLn('Device Vulkan API version: '+TpvUTF8String(fVulkanDevice.PhysicalDevice.GetAPIVersionString));

  DriverVersionString:=fVulkanDevice.PhysicalDevice.GetDriverVersionString;

  fVulkanDelayResizeBugWorkaround:=false;

  if fVulkanDevice.PhysicalDevice.Properties.vendorID=TpvUInt32(TpvVulkanVendorID.NVIDIA) then begin
{$if defined(Linux)}
   {if DriverVersionString='525.105.17.0' then}begin
    fVulkanDelayResizeBugWorkaround:=true;
   end;
{$ifend}
  end;

  VulkanDebugLn('Device driver version: '+TpvUTF8String(DriverVersionString));

  for Index:=0 to fVulkanDevice.PhysicalDevice.AvailableLayerNames.Count-1 do begin
   VulkanDebugLn('Device layer: '+TpvUTF8String(fVulkanDevice.PhysicalDevice.AvailableLayerNames[Index]));
  end;
  for Index:=0 to fVulkanDevice.PhysicalDevice.AvailableExtensionNames.Count-1 do begin
   VulkanDebugLn('Device extension: '+TpvUTF8String(fVulkanDevice.PhysicalDevice.AvailableExtensionNames[Index]));
  end;

  if fVulkanDevice.PhysicalDevice.AvailableExtensionNames.IndexOf(VK_KHR_GET_MEMORY_REQUIREMENTS_2_EXTENSION_NAME)>=0 then begin
   fVulkanDevice.EnabledExtensionNames.Add(VK_KHR_GET_MEMORY_REQUIREMENTS_2_EXTENSION_NAME);
  end;

  if fVulkanDevice.PhysicalDevice.AvailableExtensionNames.IndexOf(VK_KHR_DEDICATED_ALLOCATION_EXTENSION_NAME)>=0 then begin
   fVulkanDevice.EnabledExtensionNames.Add(VK_KHR_DEDICATED_ALLOCATION_EXTENSION_NAME);
  end;

  if fVulkanDevice.PhysicalDevice.AvailableExtensionNames.IndexOf(VK_EXT_SHADER_VIEWPORT_INDEX_LAYER_EXTENSION_NAME)>=0 then begin
   fVulkanDevice.EnabledExtensionNames.Add(VK_EXT_SHADER_VIEWPORT_INDEX_LAYER_EXTENSION_NAME);
  end;

  if fVulkanDevice.PhysicalDevice.AvailableExtensionNames.IndexOf(VK_EXT_HOST_QUERY_RESET_EXTENSION_NAME)>=0 then begin
   fVulkanDevice.EnabledExtensionNames.Add(VK_EXT_HOST_QUERY_RESET_EXTENSION_NAME);
  end;

  if fVulkanDevice.PhysicalDevice.AvailableExtensionNames.IndexOf(VK_EXT_FULL_SCREEN_EXCLUSIVE_EXTENSION_NAME)>=0 then begin
   fVulkanDevice.EnabledExtensionNames.Add(VK_EXT_FULL_SCREEN_EXCLUSIVE_EXTENSION_NAME);
  end;

  if fVulkanDevice.PhysicalDevice.AvailableExtensionNames.IndexOf(VK_KHR_PRESENT_ID_EXTENSION_NAME)>=0 then begin
   fVulkanDevice.EnabledExtensionNames.Add(VK_KHR_PRESENT_ID_EXTENSION_NAME);
  end;

  if fVulkanDevice.PhysicalDevice.AvailableExtensionNames.IndexOf(VK_KHR_PRESENT_WAIT_EXTENSION_NAME)>=0 then begin
   fVulkanDevice.EnabledExtensionNames.Add(VK_KHR_PRESENT_WAIT_EXTENSION_NAME);
  end;

  if fVulkanDevice.PhysicalDevice.AvailableExtensionNames.IndexOf(VK_KHR_PRESENT_ID_2_EXTENSION_NAME)>=0 then begin
   fVulkanDevice.EnabledExtensionNames.Add(VK_KHR_PRESENT_ID_2_EXTENSION_NAME);
  end;

  if fVulkanDevice.PhysicalDevice.AvailableExtensionNames.IndexOf(VK_KHR_CALIBRATED_TIMESTAMPS_EXTENSION_NAME)>=0 then begin
   fVulkanDevice.EnabledExtensionNames.Add(VK_KHR_CALIBRATED_TIMESTAMPS_EXTENSION_NAME);
  end;

  if fVulkanDevice.PhysicalDevice.AvailableExtensionNames.IndexOf(VK_EXT_PRESENT_TIMING_EXTENSION_NAME)>=0 then begin
   fVulkanDevice.EnabledExtensionNames.Add(VK_EXT_PRESENT_TIMING_EXTENSION_NAME);
  end;

  if fVulkanDevice.PhysicalDevice.AvailableExtensionNames.IndexOf(VK_KHR_PRESENT_WAIT_2_EXTENSION_NAME)>=0 then begin
   fVulkanDevice.EnabledExtensionNames.Add(VK_KHR_PRESENT_WAIT_2_EXTENSION_NAME);
  end;

  if fVulkanDevice.PhysicalDevice.AvailableExtensionNames.IndexOf(VK_EXT_SWAPCHAIN_MAINTENANCE_1_EXTENSION_NAME)>=0 then begin
   fVulkanDevice.EnabledExtensionNames.Add(VK_EXT_SWAPCHAIN_MAINTENANCE_1_EXTENSION_NAME);
  end;

  if fVulkanDevice.PhysicalDevice.AvailableExtensionNames.IndexOf(VK_NV_LOW_LATENCY_2_EXTENSION_NAME)>=0 then begin
   fVulkanDevice.EnabledExtensionNames.Add(VK_NV_LOW_LATENCY_2_EXTENSION_NAME);
  end;

  if fVulkanDevice.PhysicalDevice.AvailableExtensionNames.IndexOf(VK_AMD_ANTI_LAG_EXTENSION_NAME)>=0 then begin
   fVulkanDevice.EnabledExtensionNames.Add(VK_AMD_ANTI_LAG_EXTENSION_NAME);
  end;

  if fVulkanDevice.PhysicalDevice.AvailableExtensionNames.IndexOf(VK_EXT_MULTI_DRAW_EXTENSION_NAME)>=0 then begin
   fVulkanDevice.EnabledExtensionNames.Add(VK_EXT_MULTI_DRAW_EXTENSION_NAME);
  end;

  if fVulkanDevice.PhysicalDevice.AvailableExtensionNames.IndexOf(VK_EXT_CONSERVATIVE_RASTERIZATION_EXTENSION_NAME)>=0 then begin
   fVulkanDevice.EnabledExtensionNames.Add(VK_EXT_CONSERVATIVE_RASTERIZATION_EXTENSION_NAME);
  end;

  if fVulkanDebugging and
     fVulkanDebuggingEnabled and
     fVulkanValidation and
     (fVulkanDevice.PhysicalDevice.AvailableExtensionNames.IndexOf(VK_EXT_DEBUG_MARKER_EXTENSION_NAME)>=0) and
     (fVulkanDevice.Instance.EnabledExtensionNames.IndexOf(VK_EXT_DEBUG_UTILS_EXTENSION_NAME)<0) then begin
   fVulkanDevice.EnabledExtensionNames.Add(VK_EXT_DEBUG_MARKER_EXTENSION_NAME);
  end;

  if fVulkanDebugging and
     fVulkanDebuggingEnabled and
     fVulkanValidation and
     (fVulkanDevice.PhysicalDevice.AvailableExtensionNames.IndexOf(VK_EXT_TOOLING_INFO_EXTENSION_NAME)>=0) then begin
   fVulkanDevice.EnabledExtensionNames.Add(VK_EXT_TOOLING_INFO_EXTENSION_NAME);
  end;

  fVulkanNVIDIADiagnosticConfigExtensionFound:=fVulkanNVIDIAAfterMath and
                                               (fVulkanDevice.PhysicalDevice.AvailableExtensionNames.IndexOf(VK_NV_DEVICE_DIAGNOSTICS_CONFIG_EXTENSION_NAME)>=0);
  if fVulkanNVIDIADiagnosticConfigExtensionFound then begin
   fVulkanDevice.EnabledExtensionNames.Add(VK_NV_DEVICE_DIAGNOSTICS_CONFIG_EXTENSION_NAME);
   fVulkanDevice.UseNVIDIADeviceDiagnostics:=true;
  end;

  fVulkanNVIDIADiagnosticCheckPointsExtensionFound:=fVulkanNVIDIAAfterMath and
                                                    (fVulkanDevice.PhysicalDevice.AvailableExtensionNames.IndexOf(VK_NV_DEVICE_DIAGNOSTIC_CHECKPOINTS_EXTENSION_NAME)>=0);
  if fVulkanNVIDIADiagnosticCheckPointsExtensionFound then begin
   fVulkanDevice.EnabledExtensionNames.Add(VK_NV_DEVICE_DIAGNOSTIC_CHECKPOINTS_EXTENSION_NAME);
   fVulkanDevice.UseNVIDIADeviceDiagnostics:=true;
  end;

  if fVulkanDevice.UseBreadcrumbs then begin
   if fVulkanDevice.PhysicalDevice.AvailableExtensionNames.IndexOf(VK_AMD_BUFFER_MARKER_EXTENSION_NAME)>=0 then begin
    fVulkanDevice.EnabledExtensionNames.Add(VK_AMD_BUFFER_MARKER_EXTENSION_NAME);
   end;
   if fVulkanDevice.PhysicalDevice.AvailableExtensionNames.IndexOf(VK_NV_DEVICE_DIAGNOSTIC_CHECKPOINTS_EXTENSION_NAME)>=0 then begin
    if fVulkanDevice.EnabledExtensionNames.IndexOf(VK_NV_DEVICE_DIAGNOSTIC_CHECKPOINTS_EXTENSION_NAME)<0 then begin
     fVulkanDevice.EnabledExtensionNames.Add(VK_NV_DEVICE_DIAGNOSTIC_CHECKPOINTS_EXTENSION_NAME);
    end;
   end;
  end;

  if (fVulkanInstance.APIVersion and VK_API_VERSION_WITHOUT_PATCH_MASK)=VK_API_VERSION_1_0 then begin
   // = Vulkan API version 1.0
   if fVulkanInstance.EnabledExtensionNames.IndexOf(VK_KHR_GET_PHYSICAL_DEVICE_PROPERTIES_2_EXTENSION_NAME)>=0 then begin
    if fVulkanDevice.PhysicalDevice.AvailableExtensionNames.IndexOf(VK_KHR_MULTIVIEW_EXTENSION_NAME)>=0 then begin
     fVulkanDevice.EnabledExtensionNames.Add(VK_KHR_MULTIVIEW_EXTENSION_NAME);
     fVulkanMultiviewSupportEnabled:=true;
    end;
   end;
  end else begin
   // >= Vulkan API version 1.1
   fVulkanMultiviewSupportEnabled:=true;
   if fVulkanInstance.EnabledExtensionNames.IndexOf(VK_KHR_GET_PHYSICAL_DEVICE_PROPERTIES_2_EXTENSION_NAME)>=0 then begin
    if fVulkanDevice.PhysicalDevice.AvailableExtensionNames.IndexOf(VK_KHR_MULTIVIEW_EXTENSION_NAME)>=0 then begin
     fVulkanDevice.EnabledExtensionNames.Add(VK_KHR_MULTIVIEW_EXTENSION_NAME);
     fVulkanMultiviewSupportEnabled:=true;
    end;
   end;
  end;

  if fVulkanShaderPrintfDebugging and (fVulkanDevice.PhysicalDevice.AvailableExtensionNames.IndexOf(VK_KHR_SHADER_NON_SEMANTIC_INFO_EXTENSION_NAME)>=0) then begin
   fVulkanDevice.EnabledExtensionNames.Add(VK_KHR_SHADER_NON_SEMANTIC_INFO_EXTENSION_NAME);
  end;

  SetupVulkanDevice(fVulkanDevice);

{$if (defined(fpc) and defined(android)) and not defined(Release)}
  __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Created vulkan device');
{$ifend}

{$if (defined(fpc) and defined(android)) and not defined(Release)}
  __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Adding vulkan device queues');
{$ifend}
  AddQueues;
{$if (defined(fpc) and defined(android)) and not defined(Release)}
  __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Added vulkan device queues');
{$ifend}

{$if (defined(fpc) and defined(android)) and not defined(Release)}
  __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Adding VK_KHR_SWAPCHAIN_EXTENSION_NAME to vulkan device');
{$ifend}
  fVulkanDevice.EnabledExtensionNames.Add(VK_KHR_SWAPCHAIN_EXTENSION_NAME);
{$if (defined(fpc) and defined(android)) and not defined(Release)}
  __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Added VK_KHR_SWAPCHAIN_EXTENSION_NAME to vulkan device');
{$ifend}

{$if (defined(fpc) and defined(android)) and not defined(Release)}
  __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Initializing vulkan device');
{$ifend}
  fVulkanDevice.Initialize;
{$if (defined(fpc) and defined(android)) and not defined(Release)}
  __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Initialized vulkan device');
{$ifend}

  if (length(fVulkanPipelineCacheFileName)>0) and FileExists(String(fVulkanPipelineCacheFileName)) then begin
{$if (defined(fpc) and defined(android)) and not defined(Release)}
   __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Existent pipeline cache found, loading...');
{$ifend}
   try
    fVulkanPipelineCache:=TpvVulkanPipelineCache.CreateFromFile(fVulkanDevice,String(fVulkanPipelineCacheFileName));
   except
    on e:EpvVulkanPipelineCacheException do begin
     fVulkanPipelineCache:=TpvVulkanPipelineCache.Create(fVulkanDevice);
    end;
   end;
{$if (defined(fpc) and defined(android)) and not defined(Release)}
   __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Existent pipeline cache loaded');
{$ifend}
  end else begin
{$if (defined(fpc) and defined(android)) and not defined(Release)}
   __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','No existent pipeline cache found, creating new pipeline cache...');
{$ifend}
   fVulkanPipelineCache:=TpvVulkanPipelineCache.Create(fVulkanDevice);
{$if (defined(fpc) and defined(android)) and not defined(Release)}
   __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Created new pipeline cache...');
{$ifend}
  end;

  fInternalPresentQueueCommandPool:=TpvVulkanCommandPool.Create(fVulkanDevice,
                                                                fVulkanDevice.PresentQueueFamilyIndex,
                                                                TVkCommandPoolCreateFlags(VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT));

  fInternalPresentQueueCommandBuffer:=TpvVulkanCommandBuffer.Create(fInternalPresentQueueCommandPool,VK_COMMAND_BUFFER_LEVEL_PRIMARY);

  fInternalPresentQueueCommandBufferFence:=TpvVulkanFence.Create(fVulkanDevice);

  fInternalGraphicsQueueCommandPool:=TpvVulkanCommandPool.Create(fVulkanDevice,
                                                                 fVulkanDevice.GraphicsQueueFamilyIndex,
                                                                 TVkCommandPoolCreateFlags(VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT));

  fInternalGraphicsQueueCommandBuffer:=TpvVulkanCommandBuffer.Create(fInternalGraphicsQueueCommandPool,VK_COMMAND_BUFFER_LEVEL_PRIMARY);

  fInternalGraphicsQueueCommandBufferFence:=TpvVulkanFence.Create(fVulkanDevice);

{ fVulkanCountCommandQueues:=length(fVulkanDevice.PhysicalDevice.QueueFamilyProperties);
  SetLength(fVulkanCommandPools,fVulkanCountCommandQueues,fCountCPUThreads+1,MaxSwapChainImages);
  SetLength(fVulkanCommandBuffers,fVulkanCountCommandQueues,fCountCPUThreads+1,MaxSwapChainImages);
  SetLength(fVulkanCommandBufferFences,fVulkanCountCommandQueues,fCountCPUThreads+1,MaxSwapChainImages);
  for QueueFamilyIndex:=0 to length(fVulkanDevice.PhysicalDevice.QueueFamilyProperties)-1 do begin
   if (QueueFamilyIndex=fVulkanDevice.UniversalQueueFamilyIndex) or
      (QueueFamilyIndex=fVulkanDevice.PresentQueueFamilyIndex) or
      (QueueFamilyIndex=fVulkanDevice.GraphicsQueueFamilyIndex) or
      (QueueFamilyIndex=fVulkanDevice.ComputeQueueFamilyIndex) or
      (QueueFamilyIndex=fVulkanDevice.TransferQueueFamilyIndex) then begin
    for ThreadIndex:=0 to fCountCPUThreads do begin
     for SwapChainImageIndex:=0 to MaxSwapChainImages-1 do begin
      fVulkanCommandPools[QueueFamilyIndex,ThreadIndex,SwapChainImageIndex]:=TpvVulkanCommandPool.Create(fVulkanDevice,QueueFamilyIndex,TVkCommandPoolCreateFlags(VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT));
      fVulkanCommandBuffers[QueueFamilyIndex,ThreadIndex,SwapChainImageIndex]:=TpvVulkanCommandBuffer.Create(fVulkanCommandPools[QueueFamilyIndex,ThreadIndex,SwapChainImageIndex],VK_COMMAND_BUFFER_LEVEL_PRIMARY);
      fVulkanCommandBufferFences[QueueFamilyIndex,ThreadIndex,SwapChainImageIndex]:=TpvVulkanFence.Create(fVulkanDevice);
     end;
    end;
   end;
  end;

  if fVulkanDevice.UniversalQueueFamilyIndex>=0 then begin
   fVulkanUniversalCommandPools:=fVulkanCommandPools[fVulkanDevice.UniversalQueueFamilyIndex];
   fVulkanUniversalCommandBuffers:=fVulkanCommandBuffers[fVulkanDevice.UniversalQueueFamilyIndex];
   fVulkanUniversalCommandBufferFences:=fVulkanCommandBufferFences[fVulkanDevice.UniversalQueueFamilyIndex];
  end else begin
   fVulkanUniversalCommandPools:=nil;
   fVulkanUniversalCommandBuffers:=nil;
   fVulkanUniversalCommandBufferFences:=nil;
  end;

  if fVulkanDevice.PresentQueueFamilyIndex>=0 then begin
   fVulkanPresentCommandPools:=fVulkanCommandPools[fVulkanDevice.PresentQueueFamilyIndex];
   fVulkanPresentCommandBuffers:=fVulkanCommandBuffers[fVulkanDevice.PresentQueueFamilyIndex];
   fVulkanPresentCommandBufferFences:=fVulkanCommandBufferFences[fVulkanDevice.PresentQueueFamilyIndex];
  end else begin
   fVulkanPresentCommandPools:=nil;
   fVulkanPresentCommandBuffers:=nil;
   fVulkanPresentCommandBufferFences:=nil;
  end;

  if fVulkanDevice.GraphicsQueueFamilyIndex>=0 then begin
   fVulkanGraphicsCommandPools:=fVulkanCommandPools[fVulkanDevice.GraphicsQueueFamilyIndex];
   fVulkanGraphicsCommandBuffers:=fVulkanCommandBuffers[fVulkanDevice.GraphicsQueueFamilyIndex];
   fVulkanGraphicsCommandBufferFences:=fVulkanCommandBufferFences[fVulkanDevice.GraphicsQueueFamilyIndex];
  end else begin
   fVulkanGraphicsCommandPools:=nil;
   fVulkanGraphicsCommandBuffers:=nil;
   fVulkanGraphicsCommandBufferFences:=nil;
  end;

  if fVulkanDevice.ComputeQueueFamilyIndex>=0 then begin
   fVulkanComputeCommandPools:=fVulkanCommandPools[fVulkanDevice.ComputeQueueFamilyIndex];
   fVulkanComputeCommandBuffers:=fVulkanCommandBuffers[fVulkanDevice.ComputeQueueFamilyIndex];
   fVulkanComputeCommandBufferFences:=fVulkanCommandBufferFences[fVulkanDevice.ComputeQueueFamilyIndex];
  end else begin
   fVulkanComputeCommandPools:=nil;
   fVulkanComputeCommandBuffers:=nil;
   fVulkanComputeCommandBufferFences:=nil;
  end;

  if fVulkanDevice.TransferQueueFamilyIndex>=0 then begin
   fVulkanTransferCommandPools:=fVulkanCommandPools[fVulkanDevice.TransferQueueFamilyIndex];
   fVulkanTransferCommandBuffers:=fVulkanCommandBuffers[fVulkanDevice.TransferQueueFamilyIndex];
   fVulkanTransferCommandBufferFences:=fVulkanCommandBufferFences[fVulkanDevice.TransferQueueFamilyIndex];
  end else begin
   fVulkanTransferCommandPools:=nil;
   fVulkanTransferCommandBuffers:=nil;
   fVulkanTransferCommandBufferFences:=nil;
  end;}

  fVulkanDepthImageFormat:=fVulkanDevice.PhysicalDevice.GetBestSupportedDepthFormat(false);

  fVulkanInstance.Commands.GetPhysicalDeviceFormatProperties(fVulkanDevice.PhysicalDevice.Handle,fVulkanDepthImageFormat,@FormatProperties);
  if (FormatProperties.OptimalTilingFeatures and TVkFormatFeatureFlags(VK_FORMAT_FEATURE_DEPTH_STENCIL_ATTACHMENT_BIT))=0 then begin
   raise EpvVulkanException.Create('No suitable depth image format!');
  end;

 end;
end;

procedure TpvApplication.CreateVulkanInstance;
{$if (defined(PasVulkanUseSDL2) or defined(Windows)) and not defined(PasVulkanHeadless)}
type TExtensions=array of PAnsiChar;
var Index:TpvInt32;
{$if defined(PasVulkanUseSDL2)}
    SDL_SysWMinfo:TSDL_SysWMinfo;
{$ifend}
    CountExtensions:TpvInt32;
    Extensions:TExtensions;
    DebugExtensionName:TpvUTF8String;
begin
{$if (defined(fpc) and defined(android)) and not defined(Release)}
 __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Entering TpvApplication.CreateVulkanInstance');
{$ifend}
 if not assigned(fVulkanInstance) then begin
{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
  SDL_GetVersion(SDL_SysWMinfo.version);
  if {$if defined(PasVulkanUseSDL2WithVulkanSupport)}fSDLVersionWithVulkanSupport or{$ifend}
     (SDL_GetWindowWMInfo(fSurfaceWindow,@SDL_SysWMinfo)<>0) then{$ifend}begin
   fVulkanInstance:=TpvVulkanInstance.Create(TpvVulkanCharString(fTitle),
                                             Version,
                                             'PasVulkanApplication',
                                             $0100,
                                             fVulkanAPIVersion,
                                             false,
                                             nil);
   VulkanDebugLn('Instance Vulkan API version: '+TpvUTF8String(fVulkanInstance.GetAPIVersionString));
   for Index:=0 to fVulkanInstance.AvailableLayerNames.Count-1 do begin
    VulkanDebugLn('Instance layer: '+TpvUTF8String(fVulkanInstance.AvailableLayerNames[Index]));
   end;
   for Index:=0 to fVulkanInstance.AvailableExtensionNames.Count-1 do begin
    VulkanDebugLn('Instance extension: '+TpvUTF8String(fVulkanInstance.AvailableExtensionNames[Index]));
   end;
{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
{$if defined(PasVulkanUseSDL2WithVulkanSupport)}
   if fSDLVersionWithVulkanSupport then begin
    if not SDL_Vulkan_GetInstanceExtensions(fSurfaceWindow,@CountExtensions,nil) then begin
     raise EpvVulkanException.Create('Vulkan initialization failure at SDL_Vulkan_GetInstanceExtensions: '+String(SDL_GetError));
    end;
    Extensions:=nil;
    try
     SetLength(Extensions,CountExtensions);
     if not SDL_Vulkan_GetInstanceExtensions(fSurfaceWindow,@CountExtensions,@Extensions[0]) then begin
      raise EpvVulkanException.Create('Vulkan initialization failure at SDL_Vulkan_GetInstanceExtensions: '+String(SDL_GetError));
     end;
     for Index:=0 to CountExtensions-1 do begin
      fVulkanInstance.EnabledExtensionNames.Add(String(Extensions[Index]));
{$if (defined(fpc) and defined(android)) and not defined(Release)}
      VulkanDebugLn('Instance SDL2 extension: '+TpvUTF8String(Extensions[Index]));
{$ifend}
     end;
    finally
     Extensions:=nil;
    end;
   end else{$ifend} begin
    fVulkanInstance.EnabledExtensionNames.Add(VK_KHR_SURFACE_EXTENSION_NAME);
    case SDL_SysWMinfo.subsystem of
{$if defined(Android)}
     SDL_SYSWM_ANDROID:begin
      fVulkanInstance.EnabledExtensionNames.Add(VK_KHR_ANDROID_SURFACE_EXTENSION_NAME);
     end;
{$ifend}
{$if defined(Wayland) and defined(Unix)}
     SDL_SYSWM_WAYLAND:begin
      fVulkanInstance.EnabledExtensionNames.Add(VK_KHR_WAYLAND_SURFACE_EXTENSION_NAME);
     end;
{$ifend}
{$if defined(Windows)}
     SDL_SYSWM_WINDOWS:begin
      fVulkanInstance.EnabledExtensionNames.Add(VK_KHR_WIN32_SURFACE_EXTENSION_NAME);
     end;
{$ifend}
{$if (defined(XLIB) or defined(XCB)) and defined(Unix)}
     SDL_SYSWM_X11:begin
{$if defined(XLIB) and defined(Unix)}
      fVulkanInstance.EnabledExtensionNames.Add(VK_KHR_XLIB_SURFACE_EXTENSION_NAME);
{$elseif defined(XCB) and defined(Unix)}
      fVulkanInstance.EnabledExtensionNames.Add(VK_KHR_XCB_SURFACE_EXTENSION_NAME);
{$ifend}
     end;
{$ifend}
     else begin
      raise EpvVulkanException.Create('Vulkan initialization failure');
     end;
    end;
   end;
{$elseif defined(Windows) and not defined(PasVulkanHeadless)}
   begin
    fVulkanInstance.EnabledExtensionNames.Add(VK_KHR_SURFACE_EXTENSION_NAME);
    fVulkanInstance.EnabledExtensionNames.Add(VK_KHR_WIN32_SURFACE_EXTENSION_NAME);
   end;
{$ifend}
   if fVulkanInstance.AvailableExtensionNames.IndexOf(VK_EXT_DEBUG_UTILS_EXTENSION_NAME)>=0 then begin
    DebugExtensionName:=VK_EXT_DEBUG_UTILS_EXTENSION_NAME;
    fVulkanDebugExtensionMode:=TpvApplicationVulkanDebugExtensionMode.DebugUtils;
   end else begin
    DebugExtensionName:=VK_EXT_DEBUG_REPORT_EXTENSION_NAME;
    fVulkanDebugExtensionMode:=TpvApplicationVulkanDebugExtensionMode.DebugReportMarker;
   end;
   if fVulkanDebugging and
      (fVulkanInstance.AvailableExtensionNames.IndexOf(DebugExtensionName)>=0) then begin
    fVulkanInstance.EnabledExtensionNames.Add(DebugExtensionName);
    fVulkanDebuggingEnabled:=true;
    if fVulkanValidation then begin
{$if defined(Android)}
     if fVulkanInstance.AvailableLayerNames.IndexOf('VK_LAYER_GOOGLE_threading')>=0 then begin
      fVulkanInstance.EnabledLayerNames.Add('VK_LAYER_GOOGLE_threading');
     end;
     if fVulkanInstance.AvailableLayerNames.IndexOf('VK_LAYER_LUNARG_parameter_validation')>=0 then begin
      fVulkanInstance.EnabledLayerNames.Add('VK_LAYER_LUNARG_parameter_validation');
     end;
     if fVulkanInstance.AvailableLayerNames.IndexOf('VK_LAYER_LUNARG_device_limits')>=0 then begin
      fVulkanInstance.EnabledLayerNames.Add('VK_LAYER_LUNARG_device_limits');
     end;
     if fVulkanInstance.AvailableLayerNames.IndexOf('VK_LAYER_LUNARG_object_tracker')>=0 then begin
      fVulkanInstance.EnabledLayerNames.Add('VK_LAYER_LUNARG_object_tracker');
     end;
     if fVulkanInstance.AvailableLayerNames.IndexOf('VK_LAYER_LUNARG_image')>=0 then begin
      fVulkanInstance.EnabledLayerNames.Add('VK_LAYER_LUNARG_image');
     end;
     if fVulkanInstance.AvailableLayerNames.IndexOf('VK_LAYER_LUNARG_core_validation')>=0 then begin
      fVulkanInstance.EnabledLayerNames.Add('VK_LAYER_LUNARG_core_validation');
     end;
     if fVulkanInstance.AvailableLayerNames.IndexOf('VK_LAYER_LUNARG_swapchain')>=0 then begin
      fVulkanInstance.EnabledLayerNames.Add('VK_LAYER_LUNARG_swapchain');
     end;
     if (fVulkanInstance.AvailableLayerNames.IndexOf('VK_LAYER_GOOGLE_unique_objects')>=0) and not fVulkanNoUniqueObjectsValidation then begin
      fVulkanInstance.EnabledLayerNames.Add('VK_LAYER_GOOGLE_unique_objects');
     end;
{$else}
     if fVulkanNoUniqueObjectsValidation then begin
      if fVulkanInstance.AvailableLayerNames.IndexOf('VK_LAYER_GOOGLE_threading')>=0 then begin
       fVulkanInstance.EnabledLayerNames.Add('VK_LAYER_GOOGLE_threading');
      end;
      if fVulkanInstance.AvailableLayerNames.IndexOf('VK_LAYER_LUNARG_parameter_validation')>=0 then begin
       fVulkanInstance.EnabledLayerNames.Add('VK_LAYER_LUNARG_parameter_validation');
      end;
      if fVulkanInstance.AvailableLayerNames.IndexOf('VK_LAYER_LUNARG_device_limits')>=0 then begin
       fVulkanInstance.EnabledLayerNames.Add('VK_LAYER_LUNARG_device_limits');
      end;
      if fVulkanInstance.AvailableLayerNames.IndexOf('VK_LAYER_LUNARG_object_tracker')>=0 then begin
       fVulkanInstance.EnabledLayerNames.Add('VK_LAYER_LUNARG_object_tracker');
      end;
      if fVulkanInstance.AvailableLayerNames.IndexOf('VK_LAYER_LUNARG_image')>=0 then begin
       fVulkanInstance.EnabledLayerNames.Add('VK_LAYER_LUNARG_image');
      end;
      if fVulkanInstance.AvailableLayerNames.IndexOf('VK_LAYER_LUNARG_core_validation')>=0 then begin
       fVulkanInstance.EnabledLayerNames.Add('VK_LAYER_LUNARG_core_validation');
      end;
      if fVulkanInstance.AvailableLayerNames.IndexOf('VK_LAYER_LUNARG_swapchain')>=0 then begin
       fVulkanInstance.EnabledLayerNames.Add('VK_LAYER_LUNARG_swapchain');
      end;
     end else begin
      if fVulkanInstance.AvailableLayerNames.IndexOf('VK_LAYER_KHRONOS_validation')>=0 then begin
       fVulkanInstance.EnabledLayerNames.Add('VK_LAYER_KHRONOS_validation');
      end else if fVulkanInstance.AvailableLayerNames.IndexOf('VK_LAYER_LUNARG_standard_validation')>=0 then begin
       fVulkanInstance.EnabledLayerNames.Add('VK_LAYER_LUNARG_standard_validation');
      end;
     end;
{$ifend}
(*   if {$ifdef Android}(fVulkanInstance.AvailableExtensionNames.IndexOf(VK_EXT_DEBUG_REPORT_EXTENSION_NAME)<0) and{$endif}
        (fVulkanInstance.AvailableExtensionNames.IndexOf(VK_EXT_DEBUG_UTILS_EXTENSION_NAME)>=0) then begin
      fVulkanInstance.EnabledExtensionNames.Add(VK_EXT_DEBUG_UTILS_EXTENSION_NAME);
     end;*)
    end;
   end else begin
    fVulkanDebuggingEnabled:=false;
   end;
   if fVulkanInstance.AvailableExtensionNames.IndexOf(VK_KHR_GET_PHYSICAL_DEVICE_PROPERTIES_2_EXTENSION_NAME)>=0 then begin
    fVulkanInstance.EnabledExtensionNames.Add(VK_KHR_GET_PHYSICAL_DEVICE_PROPERTIES_2_EXTENSION_NAME);
   end;
   if fVulkanInstance.AvailableExtensionNames.IndexOf(VK_KHR_GET_SURFACE_CAPABILITIES_2_EXTENSION_NAME)>=0 then begin
    fVulkanInstance.EnabledExtensionNames.Add(VK_KHR_GET_SURFACE_CAPABILITIES_2_EXTENSION_NAME);
    // VK_EXT_surface_maintenance1 is the instance-level dependency of the device-level VK_EXT_swapchain_maintenance1 (enabled
    // later when available) -> enable it here so the device extension's requirement is satisfied (VUID-vkCreateDevice-...-01387).
    if fVulkanInstance.AvailableExtensionNames.IndexOf(VK_EXT_SURFACE_MAINTENANCE_1_EXTENSION_NAME)>=0 then begin
     fVulkanInstance.EnabledExtensionNames.Add(VK_EXT_SURFACE_MAINTENANCE_1_EXTENSION_NAME);
    end;
   end;
   SetupVulkanInstance(fVulkanInstance);
{$if (defined(fpc) and defined(android)) and not defined(Release)}
   VulkanDebugLn('Calling TpvVulkanInstance.Initialize() . . .');
{$ifend}
   fVulkanInstance.ShaderPrintfDebugging:=fVulkanDebuggingEnabled and fVulkanShaderPrintfDebugging;
   fVulkanInstance.SynchronizationValidation:=fVulkanDebuggingEnabled and fVulkanValidation and fVulkanSynchronizationValidation;
   fVulkanInstance.Initialize;
{$if (defined(fpc) and defined(android)) and not defined(Release)}
   VulkanDebugLn('Called TpvVulkanInstance.Initialize() . . .');
{$ifend}
   if fVulkanDebuggingEnabled then begin
    case fVulkanDebugExtensionMode of
     TpvApplicationVulkanDebugExtensionMode.DebugUtils:begin
      fVulkanInstance.OnInstanceDebugUtilsMessengerCallback:=VulkanOnDebugUtilsMessengerCallback;
      fVulkanInstance.InstallDebugUtilsMessengerCallback;
     end;
     TpvApplicationVulkanDebugExtensionMode.DebugReportMarker:begin
      fVulkanInstance.OnInstanceDebugReportCallback:=VulkanOnDebugReportCallback;
      fVulkanInstance.InstallDebugReportCallback;
     end;
     else begin
      Assert(false);
     end;
    end;
   end;
  end;
 end;
{$if (defined(fpc) and defined(android)) and not defined(Release)}
 __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Leaving TpvApplication.CreateVulkanInstance');
{$ifend}
end;
{$else}
begin
 Assert(false);
end;
{$ifend}

procedure TpvApplication.DestroyVulkanInstance;
var Index,SubIndex,SubSubIndex:TpvInt32;
begin

 if length(fVulkanPipelineCacheFileName)>0 then begin
  try
   fVulkanPipelineCache.SaveToFile(String(fVulkanPipelineCacheFileName));
  except
  end;
 end;

{fVulkanUniversalCommandPools:=nil;
 fVulkanUniversalCommandBuffers:=nil;
 fVulkanUniversalCommandBufferFences:=nil;

 fVulkanPresentCommandPools:=nil;
 fVulkanPresentCommandBuffers:=nil;
 fVulkanPresentCommandBufferFences:=nil;

 fVulkanGraphicsCommandPools:=nil;
 fVulkanGraphicsCommandBuffers:=nil;
 fVulkanGraphicsCommandBufferFences:=nil;

 fVulkanComputeCommandPools:=nil;
 fVulkanComputeCommandBuffers:=nil;
 fVulkanComputeCommandBufferFences:=nil;

 fVulkanTransferCommandPools:=nil;
 fVulkanTransferCommandBuffers:=nil;
 fVulkanTransferCommandBufferFences:=nil;

 for Index:=0 to fVulkanCountCommandQueues-1 do begin
  for SubIndex:=0 to fCountCPUThreads do begin
   for SubSubIndex:=0 to MaxSwapChainImages-1 do begin
    FreeAndNil(fVulkanCommandBufferFences[Index,SubIndex,SubSubIndex]);
    FreeAndNil(fVulkanCommandBuffers[Index,SubIndex,SubSubIndex]);
    FreeAndNil(fVulkanCommandPools[Index,SubIndex,SubSubIndex]);
   end;
  end;
 end;

 fVulkanCommandPools:=nil;
 fVulkanCommandBuffers:=nil;
 fVulkanCommandBufferFences:=nil;}

 FreeAndNil(fInternalPresentQueueCommandBufferFence);
 FreeAndNil(fInternalPresentQueueCommandBuffer);
 FreeAndNil(fInternalPresentQueueCommandPool);

 FreeAndNil(fInternalGraphicsQueueCommandBufferFence);
 FreeAndNil(fInternalGraphicsQueueCommandBuffer);
 FreeAndNil(fInternalGraphicsQueueCommandPool);

 //FreeAndNil(VulkanPresentationSurface);
 FreeAndNil(fVulkanPipelineCache);
 FreeAndNil(fVulkanDevice);
 FreeAndNil(fVulkanInstance);
//VulkanPresentationSurface:=nil;

 fVulkanDevice:=nil;
 fVulkanInstance:=nil;

end;

procedure TpvApplication.CreateVulkanSurface;
{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
var SDL_SysWMinfo:TSDL_SysWMinfo;
    VulkanSurfaceCreateInfo:TpvVulkanSurfaceCreateInfo;
{$if defined(PasVulkanUseSDL2WithVulkanSupport)}
    VulkanSurface:TVkSurfaceKHR;
{$ifend}
begin
{$if (defined(fpc) and defined(android)) and not defined(Release)}
  __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Entering TpvApplication.AllocateVulkanSurface');
{$ifend}
 if not assigned(fVulkanSurface) then begin
{$if defined(PasVulkanUseSDL2WithVulkanSupport)}if fSDLVersionWithVulkanSupport then begin
   if not SDL_Vulkan_CreateSurface(fSurfaceWindow,fVulkanInstance.Handle,@VulkanSurface) then begin
    raise EpvVulkanException.Create('Vulkan initialization failure at SDL_Vulkan_CreateSurface: '+String(SDL_GetError));
   end;
{$if (defined(fpc) and defined(android)) and not defined(Release)}
   __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Creating vulkan surface');
{$ifend}
   fVulkanSurface:=TpvVulkanSurface.CreateHandle(fVulkanInstance,VulkanSurface);
{$if (defined(fpc) and defined(android)) and not defined(Release)}
   __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Created vulkan surface');
{$ifend}
   end else{$ifend} begin
   SDL_GetVersion(SDL_SysWMinfo.version);
   if SDL_GetWindowWMInfo(fSurfaceWindow,@SDL_SysWMinfo)<>0 then begin
    FillChar(VulkanSurfaceCreateInfo,SizeOf(TpvVulkanSurfaceCreateInfo),#0);
    case SDL_SysWMinfo.subsystem of
{$if defined(Android)}
     SDL_SYSWM_ANDROID:begin
{$if (defined(fpc) and defined(android)) and not defined(Release)}
      __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication',PAnsiChar('Got native window 0x'+IntToHex(PtrUInt(SDL_SysWMinfo.Window),SizeOf(PtrUInt)*2)));
{$ifend}
      VulkanSurfaceCreateInfo.Android.sType:=VK_STRUCTURE_TYPE_ANDROID_SURFACE_CREATE_INFO_KHR;
      VulkanSurfaceCreateInfo.Android.window:=SDL_SysWMinfo.Window;
     end;
{$ifend}
{$if defined(Wayland) and defined(Unix)}
     SDL_SYSWM_WAYLAND:begin
      VulkanSurfaceCreateInfo.Wayland.sType:=VK_STRUCTURE_TYPE_WAYLAND_SURFACE_CREATE_INFO_KHR;
      VulkanSurfaceCreateInfo.Wayland.display:=SDL_SysWMinfo.Wayland.Display;
      VulkanSurfaceCreateInfo.Wayland.surface:=SDL_SysWMinfo.Wayland.surface;
     end;
{$ifend}
{$if defined(Windows)}
     SDL_SYSWM_WINDOWS:begin
      VulkanSurfaceCreateInfo.Win32.sType:=VK_STRUCTURE_TYPE_WIN32_SURFACE_CREATE_INFO_KHR;
      VulkanSurfaceCreateInfo.Win32.hwnd_:=SDL_SysWMinfo.Window;
     end;
{$ifend}
{$if defined(XLIB) and defined(Unix)}
     SDL_SYSWM_X11:begin
      VulkanSurfaceCreateInfo.XLIB.sType:=VK_STRUCTURE_TYPE_XLIB_SURFACE_CREATE_INFO_KHR;
      VulkanSurfaceCreateInfo.XLIB.Dpy:=SDL_SysWMinfo.X11.Display;
      VulkanSurfaceCreateInfo.XLIB.Window:=SDL_SysWMinfo.X11.Window;
     end;
{$ifend}
{$if (defined(XCB) and not defined(XLIB)) and defined(Unix)}
     SDL_SYSWM_X11:begin
      raise EpvVulkanException.Create('Vulkan initialization failure');
      exit;
     end;
{$ifend}
     else begin
      raise EpvVulkanException.Create('Vulkan initialization failure');
      exit;
     end;
    end;

{$if (defined(fpc) and defined(android)) and not defined(Release)}
    __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Creating vulkan surface');
{$ifend}
    fVulkanSurface:=TpvVulkanSurface.Create(fVulkanInstance,VulkanSurfaceCreateInfo);
{$if (defined(fpc) and defined(android)) and not defined(Release)}
    __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Created vulkan surface');
{$ifend}

   end;

  end;

  if assigned(fVulkanSurface) and not assigned(fVulkanDevice) then begin
   CreateVulkanDevice(fVulkanSurface);
   if not assigned(fVulkanDevice) then begin
    raise EpvVulkanSurfaceException.Create('Device does not support surface');
   end;
  end;

 end;
{$if (defined(fpc) and defined(android)) and not defined(Release)}
 __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Leaving TpvApplication.AllocateVulkanSurface');
{$ifend}
end;
{$elseif defined(Windows) and not defined(PasVulkanHeadless)}
var VulkanSurfaceCreateInfo:TpvVulkanSurfaceCreateInfo;
begin
{$if (defined(fpc) and defined(android)) and not defined(Release)}
  __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Entering TpvApplication.AllocateVulkanSurface');
{$ifend}
 if not assigned(fVulkanSurface) then begin
  begin
   begin
    FillChar(VulkanSurfaceCreateInfo,SizeOf(TpvVulkanSurfaceCreateInfo),#0);
    VulkanSurfaceCreateInfo.Win32.sType:=VK_STRUCTURE_TYPE_WIN32_SURFACE_CREATE_INFO_KHR;
    VulkanSurfaceCreateInfo.Win32.hwnd_:=fWin32Handle;

{$if (defined(fpc) and defined(android)) and not defined(Release)}
    __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Creating vulkan surface');
{$ifend}
    fVulkanSurface:=TpvVulkanSurface.Create(fVulkanInstance,VulkanSurfaceCreateInfo);
{$if (defined(fpc) and defined(android)) and not defined(Release)}
    __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Created vulkan surface');
{$ifend}

   end;

  end;

  if assigned(fVulkanSurface) and not assigned(fVulkanDevice) then begin
   CreateVulkanDevice(fVulkanSurface);
   if not assigned(fVulkanDevice) then begin
    raise EpvVulkanSurfaceException.Create('Device does not support surface');
   end;
  end;

 end;
{$if (defined(fpc) and defined(android)) and not defined(Release)}
 __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Leaving TpvApplication.AllocateVulkanSurface');
{$ifend}
end;
{$else}
begin
 Assert(false);
end;
{$ifend}

procedure TpvApplication.DestroyVulkanSurface;
begin
{$if (defined(fpc) and defined(android)) and not defined(Release)}
 __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Entering TpvApplication.DestroyVulkanSurface');
{$ifend}
 FreeAndNil(fVulkanSurface);
{$if (defined(fpc) and defined(android)) and not defined(Release)}
 __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Leaving TpvApplication.DestroyVulkanSurface');
{$ifend}
end;

procedure TpvApplication.CreateVulkanSwapChain;
type TTimeDomains=array[0..15] of TVkTimeDomainKHR;
     TTimeDomainIDs=array[0..15] of TpvUInt64;
var Index:TpvInt32;
    SwapchainTimingProperties:TVkSwapchainTimingPropertiesEXT;
    SwapchainTimingPropertiesCounter:TpvUInt64;
    SwapchainTimeDomainProperties:TVkSwapchainTimeDomainPropertiesEXT;
    TimeDomains:TTimeDomains;
    TimeDomainIDs:TTimeDomainIDs;
    TimeDomainCount:TpvUInt64;
{$if defined(Windows) and not defined(PasVulkanHeadless)}
{$if defined(PasVulkanUseSDL2)}
    WMInfo:TSDL_SysWMinfo;
{$ifend}
    WindowHandle:HWND;
{$ifend}
begin
{$if (defined(fpc) and defined(android)) and not defined(Release)}
 __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Entering TpvApplication.CreateVulkanSwapChain');
{$ifend}

 DestroyVulkanSwapChain;

{$if not defined(PasVulkanHeadless)}
 if fVulkanDevice.GraphicsQueueFamilyIndex<>fVulkanDevice.PresentQueueFamilyIndex then begin
  fVulkanSwapChainQueueFamilyIndices.Clear;
  fVulkanSwapChainQueueFamilyIndices.Add(fVulkanDevice.GraphicsQueueFamilyIndex);
  fVulkanSwapChainQueueFamilyIndices.Add(fVulkanDevice.PresentQueueFamilyIndex);
  fVulkanSwapChainQueueFamilyIndices.Finish;
 end;
{$ifend}

{$if defined(Windows)}
{$if defined(PasVulkanHeadless)}
  WindowHandle:=0;
{$elseif defined(PasVulkanUseSDL2)}
  SDL_VERSION(WMInfo.version);
  SDL_GetWindowWMInfo(fSurfaceWindow,@WMInfo);
  WindowHandle:=WMInfo.window;
{$else}
  WindowHandle:=fWin32Handle;
{$ifend}
{$ifend}

 fVulkanPresentID:=0;

 fVulkanPresentLastID:=0;

{$if defined(PasVulkanHeadless)}
 fVulkanSwapChain:=nil;
 fCountSwapChainImages:=0;
{$else}
  fVulkanSwapChain:=TpvVulkanSwapChain.Create(fVulkanDevice,
                                             fVulkanSurface,
                                             fVulkanOldSwapChain,
                                             fWidth,
                                             fHeight,
                                             fDesiredCountSwapChainImages, //IfThen(fPresentMode<>TpvApplicationPresentMode.Immediate,fDesiredCountSwapChainImages,1),
                                             1,
                                             VK_FORMAT_UNDEFINED,
                                             VK_COLOR_SPACE_SRGB_NONLINEAR_KHR,
                                             TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT),
                                             VK_SHARING_MODE_EXCLUSIVE,
                                             fVulkanSwapChainQueueFamilyIndices.Items,
                                             [VK_COMPOSITE_ALPHA_OPAQUE_BIT_KHR,VK_COMPOSITE_ALPHA_PRE_MULTIPLIED_BIT_KHR,VK_COMPOSITE_ALPHA_POST_MULTIPLIED_BIT_KHR,VK_COMPOSITE_ALPHA_INHERIT_BIT_KHR],
                                             false,
                                             PresentModeToVulkanPresentMode[fPresentMode],
                                             true,
                                             TVkSurfaceTransformFlagsKHR($ffffffff),
                                             fSwapChainColorSpace=TpvApplicationSwapChainColorSpace.SRGB,
                                             fSwapChainHDR,
                                             fFullScreen,
                                             fExclusiveFullScreenMode,
                                             {$if defined(Windows)}@WindowHandle{$else}nil{$ifend});

 fCountSwapChainImages:=fVulkanSwapChain.CountImages;

 // Query VK_EXT_present_timing refresh duration if available
 fFramePacingPresentTimingAvailable:=false;
 fFramePacingPresentTimingRefreshDuration:=0;
 fFramePacingEffectiveInterval:=0;
 if assigned(fVulkanDevice) and
    fVulkanDevice.PresentTimingSupport and
    assigned(fVulkanDevice.Commands.Commands.GetSwapchainTimingPropertiesEXT) then begin
  try
   FillChar(SwapchainTimingProperties,SizeOf(TVkSwapchainTimingPropertiesEXT),#0);
   SwapchainTimingProperties.sType:=VK_STRUCTURE_TYPE_SWAPCHAIN_TIMING_PROPERTIES_EXT;
   SwapchainTimingPropertiesCounter:=0;
   if fVulkanDevice.Commands.GetSwapchainTimingPropertiesEXT(fVulkanDevice.Handle,
                                                             fVulkanSwapChain.Handle,
                                                             @SwapchainTimingProperties,
                                                             @SwapchainTimingPropertiesCounter)=VK_SUCCESS then begin
    if SwapchainTimingProperties.refreshDuration>0 then begin
     fFramePacingPresentTimingRefreshDuration:=SwapchainTimingProperties.refreshDuration;
     fFramePacingPresentTimingAvailable:=true;
     Log(LOG_INFO,'TpvApplication.CreateVulkanSwapChain','VK_EXT_present_timing: refreshDuration='+IntToStr(fFramePacingPresentTimingRefreshDuration)+'ns');
    end;
   end;
  except
   Log(LOG_INFO,'TpvApplication.CreateVulkanSwapChain','VK_EXT_present_timing query failed');
  end;
 end;

 // Query time domain ID for VK_EXT_present_timing
 fFramePacingPresentTimingTimeDomainID:=0;
 if fFramePacingPresentTimingAvailable and assigned(fVulkanDevice.Commands.Commands.GetSwapchainTimeDomainPropertiesEXT) then begin
  try
   FillChar(SwapchainTimeDomainProperties,SizeOf(TVkSwapchainTimeDomainPropertiesEXT),#0);
   SwapchainTimeDomainProperties.sType:=VK_STRUCTURE_TYPE_SWAPCHAIN_TIME_DOMAIN_PROPERTIES_EXT;
   SwapchainTimeDomainProperties.timeDomainCount:=Length(TimeDomains);
   SwapchainTimeDomainProperties.pTimeDomains:=@TimeDomains[0];
   SwapchainTimeDomainProperties.pTimeDomainIDs:=@TimeDomainIDs[0];
   TimeDomainCount:=0;
   if fVulkanDevice.Commands.GetSwapchainTimeDomainPropertiesEXT(fVulkanDevice.Handle,
                                                                 fVulkanSwapChain.Handle,
                                                                 @SwapchainTimeDomainProperties,
                                                                 @TimeDomainCount)=VK_SUCCESS then begin
    if TimeDomainCount>0 then begin
     fFramePacingPresentTimingTimeDomainID:=TimeDomainIDs[0];
     Log(LOG_INFO,'TpvApplication.CreateVulkanSwapChain','VK_EXT_present_timing: timeDomainID='+IntToStr(fFramePacingPresentTimingTimeDomainID));
     fPresentTimingFeedbackTimeDomainCount:=1;
     fPresentTimingFeedbackTimeDomains[0]:=TimeDomains[0];
     fPresentTimingFeedbackTimeDomainIDs[0]:=TimeDomainIDs[0];
    end;
   end;
  except
   Log(LOG_INFO,'TpvApplication.CreateVulkanSwapChain','VK_EXT_present_timing time domain query failed');
  end;
 end;

 // Reset frame pacing state for new swapchain
 fFramePacingActive:=false;
 fFramePacingNextPresentTarget:=0;
 fFramePacingLastPresentTime:=0;
 fFramePacingHistoryIndex:=0;
 fFramePacingHistoryCount:=0;
 fFramePacingDriftAccumulator:=0;
 if assigned(fFramePacingSleepWithDriftCompensation) then begin
  fFramePacingSleepWithDriftCompensation.Reset;
 end;

 // Reset present timing feedback state for new swapchain
 fPresentTimingFeedbackRefreshCounter:=0;
 fPresentTimingFeedbackHasRefreshFeedback:=false;
 fPresentTimingFeedbackNeedRecalibration:=true;
 fPresentTimingFeedbackLastTargetTime:=0;
 fPresentTimingFeedbackPresentationTimeError:=0;
 fPresentTimingFeedbackPendingCompensation:=0;
 fPresentTimingFeedbackLastPollPresentID:=0;
 fPresentTimingFeedbackErrorRingIndex:=0;
 fPresentTimingFeedbackErrorRingCount:=0;
 fPresentTimingFeedbackTimeDomainCount:=0;
 if fFramePacingPresentTimingAvailable and
    (fFramePacingMode=TpvApplicationFramePacingMode.VulkanPresentTimingFeedback) then begin
  UpdatePresentTimingFeedbackProperties;
  fPresentTimingFeedbackActiveTimeDomainID:=fFramePacingPresentTimingTimeDomainID;
  fPresentTimingFeedbackInitialized:=true;
  RecalibratePresentTimingDomains;
 end else begin
  fPresentTimingFeedbackInitialized:=false;
 end;
{$ifend}

 fSwapChainImageCounterIndex:=0;

 fSwapChainImageIndex:=0;

 for Index:=0 to MaxInFlightFrames-1 do begin
  fVulkanInFlightFenceIndices[Index]:=-1;
 end;

 SetLength(fVulkanWaitFences,fCountSwapChainImages);
 SetLength(fVulkanWaitFencesReady,fCountSwapChainImages);
 SetLength(fVulkanPresentCompleteSemaphores,fCountSwapChainImages);
 SetLength(fVulkanPresentCompleteFences,fCountSwapChainImages);
 SetLength(fVulkanPresentCompleteFencesReady,fCountSwapChainImages);

 for Index:=0 to fCountSwapChainImages-1 do begin
  fVulkanWaitFences[Index]:=TpvVulkanFence.Create(fVulkanDevice);
  fVulkanWaitFencesReady[Index]:=false;
  fVulkanPresentCompleteSemaphores[Index]:=TpvVulkanSemaphore.Create(fVulkanDevice);
  fVulkanPresentCompleteFences[Index]:=TpvVulkanFence.Create(fVulkanDevice);
  fVulkanPresentCompleteFencesReady[Index]:=false;
 end;

{$if (defined(fpc) and defined(android)) and not defined(Release)}
 __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Leaving TpvApplication.DestroyVulkanSwapChain');
{$ifend}
end;

procedure TpvApplication.DestroyVulkanSwapChain;
var Index:TpvInt32;
begin
{$if (defined(fpc) and defined(android)) and not defined(Release)}
 __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Entering TpvApplication.DestroyVulkanSwapChain');
{$ifend}
 for Index:=0 to length(fVulkanWaitFencesReady)-1 do begin
  fVulkanWaitFencesReady[Index]:=false;
 end;
 for Index:=0 to length(fVulkanPresentCompleteFencesReady)-1 do begin
  fVulkanPresentCompleteFencesReady[Index]:=false;
 end;
 for Index:=0 to length(fVulkanWaitFences)-1 do begin
  FreeAndNil(fVulkanWaitFences[Index]);
 end;
 for Index:=0 to length(fVulkanPresentCompleteSemaphores)-1 do begin
  FreeAndNil(fVulkanPresentCompleteSemaphores[Index]);
 end;
 for Index:=0 to length(fVulkanPresentCompleteFences)-1 do begin
  FreeAndNil(fVulkanPresentCompleteFences[Index]);
 end;
 fVulkanWaitFences:=nil;
 fVulkanWaitFencesReady:=nil;
 fVulkanPresentCompleteSemaphores:=nil;
 fVulkanPresentCompleteFences:=nil;
 fVulkanPresentCompleteFencesReady:=nil;
 for Index:=0 to MaxInFlightFrames-1 do begin
  fVulkanInFlightFenceIndices[Index]:=-1;
 end;
 FreeAndNil(fVulkanSwapChain);
 fVulkanSwapChainQueueFamilyIndices.Finalize;
{$if (defined(fpc) and defined(android)) and not defined(Release)}
 __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Leaving TpvApplication.DestroyVulkanSwapChain');
{$ifend}
end;

procedure TpvApplication.CreateVulkanRenderPass;
begin
{$if (defined(fpc) and defined(android)) and not defined(Release)}
 __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Entering TpvApplication.CreateVulkanRenderPass');
{$ifend}

 DestroyVulkanRenderPass;

 if assigned(pvApplication.VulkanDevice) then begin

  fVulkanRenderPass:=TpvVulkanRenderPass.Create(pvApplication.VulkanDevice);

  fVulkanRenderPass.AddSubpassDescription(0,
                                          VK_PIPELINE_BIND_POINT_GRAPHICS,
                                          [],
                                          [fVulkanRenderPass.AddAttachmentReference(fVulkanRenderPass.AddAttachmentDescription(0,
                                                                                                                               fVulkanSwapChain.ImageFormat,
                                                                                                                               VK_SAMPLE_COUNT_1_BIT,
                                                                                                                               VK_ATTACHMENT_LOAD_OP_CLEAR,
                                                                                                                               VK_ATTACHMENT_STORE_OP_STORE,
                                                                                                                               VK_ATTACHMENT_LOAD_OP_DONT_CARE,
                                                                                                                               VK_ATTACHMENT_STORE_OP_DONT_CARE,
                                                                                                                               VK_IMAGE_LAYOUT_UNDEFINED, //VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL, //VK_IMAGE_LAYOUT_UNDEFINED, // VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL,
                                                                                                                               VK_IMAGE_LAYOUT_PRESENT_SRC_KHR //VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL //VK_IMAGE_LAYOUT_PRESENT_SRC_KHR  // VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL
                                                                                                                              ),
                                                                              VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL
                                                                             )],
                                          [],
                                          fVulkanRenderPass.AddAttachmentReference(fVulkanRenderPass.AddAttachmentDescription(0,
                                                                                                                              fVulkanDepthImageFormat,
                                                                                                                              VK_SAMPLE_COUNT_1_BIT,
                                                                                                                              VK_ATTACHMENT_LOAD_OP_CLEAR,
                                                                                                                              VK_ATTACHMENT_STORE_OP_DONT_CARE,
                                                                                                                              VK_ATTACHMENT_LOAD_OP_DONT_CARE,
                                                                                                                              VK_ATTACHMENT_STORE_OP_DONT_CARE,
                                                                                                                              VK_IMAGE_LAYOUT_UNDEFINED, //VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL, // VK_IMAGE_LAYOUT_UNDEFINED, // VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL,
                                                                                                                              VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL
                                                                                                                             ),
                                                                                   VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL
                                                                                  ),
                                          []);
{ fVulkanRenderPass.AddSubpassDependency(VK_SUBPASS_EXTERNAL,
                                         0,
                                         TVkPipelineStageFlags(VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT),
                                         TVkPipelineStageFlags(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT),
                                         TVkAccessFlags(VK_ACCESS_MEMORY_READ_BIT),
                                         TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_READ_BIT) or TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT),
                                         TVkDependencyFlags(VK_DEPENDENCY_BY_REGION_BIT));
  fVulkanRenderPass.AddSubpassDependency(0,
                                         VK_SUBPASS_EXTERNAL,
                                         TVkPipelineStageFlags(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT),
                                         TVkPipelineStageFlags(VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT),
                                         TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_READ_BIT) or TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT),
                                         TVkAccessFlags(VK_ACCESS_MEMORY_READ_BIT),
                                         TVkDependencyFlags(VK_DEPENDENCY_BY_REGION_BIT));}
  fVulkanRenderPass.AddSubpassDependency(VK_SUBPASS_EXTERNAL,
                                         0,
                                         TVkPipelineStageFlags(VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT),
                                         TVkPipelineStageFlags(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_EARLY_FRAGMENT_TESTS_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_LATE_FRAGMENT_TESTS_BIT),
                                         TVkAccessFlags(VK_ACCESS_MEMORY_READ_BIT),
                                         TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_READ_BIT) or TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT) or TVkAccessFlags(VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_READ_BIT) or TVkAccessFlags(VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT),
                                         TVkDependencyFlags(VK_DEPENDENCY_BY_REGION_BIT));
  fVulkanRenderPass.AddSubpassDependency(0,
                                         VK_SUBPASS_EXTERNAL,
                                         TVkPipelineStageFlags(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_EARLY_FRAGMENT_TESTS_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_LATE_FRAGMENT_TESTS_BIT),
                                         TVkPipelineStageFlags(VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT),
                                         TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_READ_BIT) or TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT) or TVkAccessFlags(VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_READ_BIT) or TVkAccessFlags(VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT),
                                         TVkAccessFlags(VK_ACCESS_MEMORY_READ_BIT),
                                         TVkDependencyFlags(VK_DEPENDENCY_BY_REGION_BIT));
  fVulkanRenderPass.Initialize;

  fVulkanRenderPass.ClearValues[0].color.float32[0]:=0.0;
  fVulkanRenderPass.ClearValues[0].color.float32[1]:=0.0;
  fVulkanRenderPass.ClearValues[0].color.float32[2]:=0.0;
  fVulkanRenderPass.ClearValues[0].color.float32[3]:=1.0;

 end else begin

  fVulkanRenderPass:=nil;

 end;

{$if (defined(fpc) and defined(android)) and not defined(Release)}
 __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Leaving TpvApplication.CreateVulkanRenderPass');
{$ifend}
end;

procedure TpvApplication.DestroyVulkanRenderPass;
begin
{$if (defined(fpc) and defined(android)) and not defined(Release)}
 __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Entering TpvApplication.DestroyVulkanRenderPass');
{$ifend}
 FreeAndNil(fVulkanRenderPass);
{$if (defined(fpc) and defined(android)) and not defined(Release)}
 __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Leaving TpvApplication.DestroyVulkanRenderPass');
{$ifend}
end;

procedure TpvApplication.CreateVulkanFrameBuffers;
var Index:TpvInt32;
    ColorAttachmentImage:TpvVulkanImage;
    ColorAttachmentImageView:TpvVulkanImageView;
    SrcPipelineStageFlags:TVkPipelineStageFlags;
begin
{$if (defined(fpc) and defined(android)) and not defined(Release)}
 __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Leaving TpvApplication.CreateVulkanFrameBuffers');
{$ifend}

 DestroyVulkanFrameBuffers;

 if assigned(fVulkanSwapChain) then begin

  SetLength(fVulkanFrameBufferColorAttachments,fVulkanSwapChain.CountImages);

  for Index:=0 to fVulkanSwapChain.CountImages-1 do begin
   fVulkanFrameBufferColorAttachments[Index]:=nil;
  end;

  for Index:=0 to fVulkanSwapChain.CountImages-1 do begin

   ColorAttachmentImage:=nil;

   ColorAttachmentImageView:=nil;

   try

    ColorAttachmentImage:=TpvVulkanImage.Create(fVulkanDevice,
                                                fVulkanSwapChain.Images[Index].Handle,
                                                nil,
                                                false);


    if (fVulkanDevice.GraphicsQueue=fVulkanDevice.PresentQueue) or
       ((fVulkanDevice.PhysicalDevice.QueueFamilyProperties[fVulkanDevice.PresentQueue.QueueFamilyIndex].queueFlags and TpvUInt32(VK_QUEUE_GRAPHICS_BIT))<>0) then begin
     SrcPipelineStageFlags:=TVkPipelineStageFlags(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT);
    end else begin
     SrcPipelineStageFlags:=TVkPipelineStageFlags(VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT);
    end;

    ColorAttachmentImage.SetLayout(TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                   VK_IMAGE_LAYOUT_UNDEFINED,
                                   VK_IMAGE_LAYOUT_PRESENT_SRC_KHR,
                                   TVkAccessFlags(0),
                                   TVkAccessFlags(VK_ACCESS_MEMORY_READ_BIT),
                                   SrcPipelineStageFlags,
                                   TVkPipelineStageFlags(VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT),
                                   nil,
                                   fInternalPresentQueueCommandBuffer,
                                   fVulkanDevice.PresentQueue,
                                   fInternalPresentQueueCommandBufferFence,
                                   true);

    ColorAttachmentImageView:=TpvVulkanImageView.Create(fVulkanDevice,
                                                        ColorAttachmentImage,
                                                        VK_IMAGE_VIEW_TYPE_2D,
                                                        fVulkanSwapChain.ImageFormat,
                                                        VK_COMPONENT_SWIZZLE_IDENTITY,
                                                        VK_COMPONENT_SWIZZLE_IDENTITY,
                                                        VK_COMPONENT_SWIZZLE_IDENTITY,
                                                        VK_COMPONENT_SWIZZLE_IDENTITY,
                                                        TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT),
                                                        0,
                                                        1,
                                                        0,
                                                        1);

    ColorAttachmentImage.ImageView:=ColorAttachmentImageView;
    ColorAttachmentImageView.Image:=ColorAttachmentImage;

    fVulkanFrameBufferColorAttachments[Index]:=TpvVulkanFrameBufferAttachment.Create(fVulkanDevice,
                                                                                     ColorAttachmentImage,
                                                                                     ColorAttachmentImageView,
                                                                                     fVulkanSwapChain.Width,
                                                                                     fVulkanSwapChain.Height,
                                                                                     fVulkanSwapChain.ImageFormat,
                                                                                     true,
                                                                                     'fVulkanFrameBufferColorAttachments['+IntToStr(Index)+']');

   except
    FreeAndNil(fVulkanFrameBufferColorAttachments[Index]);
    FreeAndNil(ColorAttachmentImageView);
    FreeAndNil(ColorAttachmentImage);
    raise;
   end;

  end;

  fVulkanDepthFrameBufferAttachment:=TpvVulkanFrameBufferAttachment.Create(fVulkanDevice,
                                                                           fVulkanDevice.GraphicsQueue,
                                                                           fInternalGraphicsQueueCommandBuffer,
                                                                           fInternalGraphicsQueueCommandBufferFence,
                                                                           fVulkanSwapChain.Width,
                                                                           fVulkanSwapChain.Height,
                                                                           fVulkanDepthImageFormat,
                                                                           TVkBufferUsageFlags(VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT),
                                                                           VK_SHARING_MODE_EXCLUSIVE,
                                                                           fVulkanSwapChainQueueFamilyIndices.Items,
                                                                           0,
                                                                           'fVulkanDepthFrameBufferAttachment');

  SetLength(fVulkanFrameBuffers,fVulkanSwapChain.CountImages);
  for Index:=0 to fVulkanSwapChain.CountImages-1 do begin
   fVulkanFrameBuffers[Index]:=nil;
  end;
  for Index:=0 to fVulkanSwapChain.CountImages-1 do begin
   fVulkanFrameBuffers[Index]:=TpvVulkanFrameBuffer.Create(fVulkanDevice,
                                                           fVulkanRenderPass,
                                                           fVulkanSwapChain.Width,
                                                           fVulkanSwapChain.Height,
                                                           1,
                                                           [fVulkanFrameBufferColorAttachments[Index],fVulkanDepthFrameBufferAttachment],
                                                           false,
                                                           'fVulkanFrameBuffers['+IntToStr(Index)+']');
  end;

 end;
{$if (defined(fpc) and defined(android)) and not defined(Release)}
 __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Entering TpvApplication.CreateVulkanFrameBuffers');
{$ifend}
end;

procedure TpvApplication.DestroyVulkanFrameBuffers;
var Index:TpvInt32;
begin
{$if (defined(fpc) and defined(android)) and not defined(Release)}
 __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Entering TpvApplication.DestroyVulkanFrameBuffers');
{$ifend}
 for Index:=0 to length(fVulkanFrameBufferColorAttachments)-1 do begin
  FreeAndNil(fVulkanFrameBufferColorAttachments[Index]);
 end;
 fVulkanFrameBufferColorAttachments:=nil;
 FreeAndNil(fVulkanDepthFrameBufferAttachment);
 for Index:=0 to length(fVulkanFrameBuffers)-1 do begin
  FreeAndNil(fVulkanFrameBuffers[Index]);
 end;
 fVulkanFrameBuffers:=nil;
{$if (defined(fpc) and defined(android)) and not defined(Release)}
 __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Leaving TpvApplication.DestroyVulkanFrameBuffers');
{$ifend}
end;

procedure TpvApplication.CreateVulkanCommandBuffers;
var Index,OtherIndex:TpvInt32;
    ImageMemoryBarrier:TVkImageMemoryBarrier;
begin
{$if (defined(fpc) and defined(android)) and not defined(Release)}
 __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Entering TpvApplication.CreateVulkanCommandBuffers');
{$ifend}

 DestroyVulkanCommandBuffers;

 if CountSwapChainImages>0 then begin

  SetLength(fVulkanFrameFenceCommandBuffers,CountSwapChainImages);
  SetLength(fVulkanFrameFenceSemaphores,CountSwapChainImages);
  SetLength(fVulkanWaitFenceCommandBuffers,CountSwapChainImages);
  SetLength(fVulkanWaitFenceSemaphores,CountSwapChainImages);
  SetLength(fVulkanBlankCommandBuffers,CountSwapChainImages);
  SetLength(fVulkanBlankCommandBufferSemaphores,CountSwapChainImages);
  SetLength(fVulkanPresentToDrawImageBarrierGraphicsQueueCommandBuffers,CountSwapChainImages);
  SetLength(fVulkanPresentToDrawImageBarrierGraphicsQueueCommandBufferSemaphores,CountSwapChainImages);
  SetLength(fVulkanPresentToDrawImageBarrierPresentQueueCommandBuffers,CountSwapChainImages);
  SetLength(fVulkanPresentToDrawImageBarrierPresentQueueCommandBufferSemaphores,CountSwapChainImages);
  SetLength(fVulkanDrawToPresentImageBarrierGraphicsQueueCommandBuffers,CountSwapChainImages);
  SetLength(fVulkanDrawToPresentImageBarrierGraphicsQueueCommandBufferSemaphores,CountSwapChainImages);
  SetLength(fVulkanDrawToPresentImageBarrierPresentQueueCommandBuffers,CountSwapChainImages);
  SetLength(fVulkanDrawToPresentImageBarrierPresentQueueCommandBufferSemaphores,CountSwapChainImages);

  fVulkanPresentCommandPool:=TpvVulkanCommandPool.Create(fVulkanDevice,
                                                         fVulkanDevice.PresentQueueFamilyIndex,
                                                         TVkCommandPoolCreateFlags(VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT));

  fVulkanGraphicsCommandPool:=TpvVulkanCommandPool.Create(fVulkanDevice,
                                                          fVulkanDevice.GraphicsQueueFamilyIndex,
                                                          TVkCommandPoolCreateFlags(VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT));

  for Index:=low(fVulkanFrameFences) to high(fVulkanFrameFences) do begin
   fVulkanFrameFences[Index]:=TpvVulkanFence.Create(fVulkanDevice);
  end;

  fVulkanFrameFencesReady:=0;
  fVulkanFrameFenceCounter:=0;

  for Index:=0 to CountSwapChainImages-1 do begin

   for OtherIndex:=low(fVulkanFrameFences) to high(fVulkanFrameFences) do begin
    fVulkanFrameFenceCommandBuffers[Index,OtherIndex]:=TpvVulkanCommandBuffer.Create(fVulkanGraphicsCommandPool,VK_COMMAND_BUFFER_LEVEL_PRIMARY);
    fVulkanFrameFenceSemaphores[Index,OtherIndex]:=TpvVulkanSemaphore.Create(fVulkanDevice);
    fVulkanFrameFenceCommandBuffers[Index,OtherIndex].BeginRecording(TVkCommandBufferUsageFlags(VK_COMMAND_BUFFER_USAGE_SIMULTANEOUS_USE_BIT));
    fVulkanFrameFenceCommandBuffers[Index,OtherIndex].EndRecording;
   end;

   fVulkanWaitFenceCommandBuffers[Index]:=TpvVulkanCommandBuffer.Create(fVulkanGraphicsCommandPool,VK_COMMAND_BUFFER_LEVEL_PRIMARY);
   fVulkanWaitFenceSemaphores[Index]:=TpvVulkanSemaphore.Create(fVulkanDevice);
   fVulkanWaitFenceCommandBuffers[Index].BeginRecording(TVkCommandBufferUsageFlags(VK_COMMAND_BUFFER_USAGE_SIMULTANEOUS_USE_BIT));
   fVulkanWaitFenceCommandBuffers[Index].EndRecording;

   fVulkanBlankCommandBuffers[Index]:=TpvVulkanCommandBuffer.Create(fVulkanGraphicsCommandPool,VK_COMMAND_BUFFER_LEVEL_PRIMARY);
   fVulkanBlankCommandBufferSemaphores[Index]:=TpvVulkanSemaphore.Create(fVulkanDevice);

   if (fVulkanDevice.PresentQueueFamilyIndex<>fVulkanDevice.GraphicsQueueFamilyIndex) or
      ((assigned(fVulkanDevice.PresentQueue) and assigned(fVulkanDevice.GraphicsQueue)) and
       (fVulkanDevice.PresentQueue<>fVulkanDevice.GraphicsQueue)) then begin

    // If present and graphics queue families are different, then image barriers are required

    begin
     // Present => graphics on graphics queue
     FillChar(ImageMemoryBarrier,SizeOf(TVkImageMemoryBarrier),#0);
     ImageMemoryBarrier.sType:=VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
     ImageMemoryBarrier.pNext:=nil;
     ImageMemoryBarrier.srcAccessMask:=TVkAccessFlags(VK_ACCESS_MEMORY_READ_BIT);
     ImageMemoryBarrier.dstAccessMask:=TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT);
     ImageMemoryBarrier.oldLayout:=VK_IMAGE_LAYOUT_UNDEFINED;
     ImageMemoryBarrier.newLayout:=VK_IMAGE_LAYOUT_PRESENT_SRC_KHR;
     ImageMemoryBarrier.srcQueueFamilyIndex:=fVulkanDevice.PresentQueueFamilyIndex;
     ImageMemoryBarrier.dstQueueFamilyIndex:=fVulkanDevice.GraphicsQueueFamilyIndex;
     ImageMemoryBarrier.image:=fVulkanFrameBufferColorAttachments[Index].Image.Handle;
     ImageMemoryBarrier.subresourceRange.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
     ImageMemoryBarrier.subresourceRange.baseMipLevel:=0;
     ImageMemoryBarrier.subresourceRange.levelCount:=1;
     ImageMemoryBarrier.subresourceRange.baseArrayLayer:=0;
     ImageMemoryBarrier.subresourceRange.layerCount:=1;

     fVulkanPresentToDrawImageBarrierGraphicsQueueCommandBuffers[Index]:=TpvVulkanCommandBuffer.Create(fVulkanGraphicsCommandPool,VK_COMMAND_BUFFER_LEVEL_PRIMARY);
     fVulkanDevice.DebugMarker.SetObjectName(fVulkanPresentToDrawImageBarrierGraphicsQueueCommandBuffers[Index].Handle,
                                             VK_DEBUG_REPORT_OBJECT_TYPE_COMMAND_BUFFER_EXT,
                                             'PresentToGraphics_GraphicsQueue');
     fVulkanPresentToDrawImageBarrierGraphicsQueueCommandBufferSemaphores[Index]:=TpvVulkanSemaphore.Create(fVulkanDevice);
     fVulkanPresentToDrawImageBarrierGraphicsQueueCommandBuffers[Index].BeginRecording(TVkCommandBufferUsageFlags(VK_COMMAND_BUFFER_USAGE_SIMULTANEOUS_USE_BIT));
     fVulkanPresentToDrawImageBarrierGraphicsQueueCommandBuffers[Index].CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT),
                                                                                           TVkPipelineStageFlags(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT),
                                                                                           0,
                                                                                           0,nil,
                                                                                           0,nil,
                                                                                           1,@ImageMemoryBarrier);
     fVulkanPresentToDrawImageBarrierGraphicsQueueCommandBuffers[Index].EndRecording;

    end;

    begin
     // Present => graphics on present queue
     FillChar(ImageMemoryBarrier,SizeOf(TVkImageMemoryBarrier),#0);
     ImageMemoryBarrier.sType:=VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
     ImageMemoryBarrier.pNext:=nil;
     ImageMemoryBarrier.srcAccessMask:=TVkAccessFlags(VK_ACCESS_MEMORY_READ_BIT);
     ImageMemoryBarrier.dstAccessMask:=0;
     ImageMemoryBarrier.oldLayout:=VK_IMAGE_LAYOUT_UNDEFINED;
     ImageMemoryBarrier.newLayout:=VK_IMAGE_LAYOUT_PRESENT_SRC_KHR;
     ImageMemoryBarrier.srcQueueFamilyIndex:=fVulkanDevice.PresentQueueFamilyIndex;
     ImageMemoryBarrier.dstQueueFamilyIndex:=fVulkanDevice.GraphicsQueueFamilyIndex;
     ImageMemoryBarrier.image:=fVulkanFrameBufferColorAttachments[Index].Image.Handle;
     ImageMemoryBarrier.subresourceRange.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
     ImageMemoryBarrier.subresourceRange.baseMipLevel:=0;
     ImageMemoryBarrier.subresourceRange.levelCount:=1;
     ImageMemoryBarrier.subresourceRange.baseArrayLayer:=0;
     ImageMemoryBarrier.subresourceRange.layerCount:=1;

     fVulkanPresentToDrawImageBarrierPresentQueueCommandBuffers[Index]:=TpvVulkanCommandBuffer.Create(fVulkanPresentCommandPool,VK_COMMAND_BUFFER_LEVEL_PRIMARY);
     fVulkanDevice.DebugMarker.SetObjectName(fVulkanPresentToDrawImageBarrierPresentQueueCommandBuffers[Index].Handle,
                                             VK_DEBUG_REPORT_OBJECT_TYPE_COMMAND_BUFFER_EXT,
                                             'PresentToGraphics_PresentQueue');
     fVulkanPresentToDrawImageBarrierPresentQueueCommandBufferSemaphores[Index]:=TpvVulkanSemaphore.Create(fVulkanDevice);
     fVulkanPresentToDrawImageBarrierPresentQueueCommandBuffers[Index].BeginRecording(TVkCommandBufferUsageFlags(VK_COMMAND_BUFFER_USAGE_SIMULTANEOUS_USE_BIT));
     fVulkanPresentToDrawImageBarrierPresentQueueCommandBuffers[Index].CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT),
                                                                                          TVkPipelineStageFlags(VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT),
                                                                                          0,
                                                                                          0,nil,
                                                                                          0,nil,
                                                                                          1,@ImageMemoryBarrier);
     fVulkanPresentToDrawImageBarrierPresentQueueCommandBuffers[Index].EndRecording;

    end;

    begin
     // Graphics => present on graphics queue
     FillChar(ImageMemoryBarrier,SizeOf(TVkImageMemoryBarrier),#0);
     ImageMemoryBarrier.sType:=VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
     ImageMemoryBarrier.pNext:=nil;
     ImageMemoryBarrier.srcAccessMask:=TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT);
     ImageMemoryBarrier.dstAccessMask:=TVkAccessFlags(VK_ACCESS_MEMORY_READ_BIT);
     ImageMemoryBarrier.oldLayout:=VK_IMAGE_LAYOUT_PRESENT_SRC_KHR;
     ImageMemoryBarrier.newLayout:=VK_IMAGE_LAYOUT_PRESENT_SRC_KHR;
     ImageMemoryBarrier.srcQueueFamilyIndex:=fVulkanDevice.GraphicsQueueFamilyIndex;
     ImageMemoryBarrier.dstQueueFamilyIndex:=fVulkanDevice.PresentQueueFamilyIndex;
     ImageMemoryBarrier.image:=fVulkanFrameBufferColorAttachments[Index].Image.Handle;
     ImageMemoryBarrier.subresourceRange.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
     ImageMemoryBarrier.subresourceRange.baseMipLevel:=0;
     ImageMemoryBarrier.subresourceRange.levelCount:=1;
     ImageMemoryBarrier.subresourceRange.baseArrayLayer:=0;
     ImageMemoryBarrier.subresourceRange.layerCount:=1;

     fVulkanDrawToPresentImageBarrierGraphicsQueueCommandBuffers[Index]:=TpvVulkanCommandBuffer.Create(fVulkanGraphicsCommandPool,VK_COMMAND_BUFFER_LEVEL_PRIMARY);
     fVulkanDevice.DebugMarker.SetObjectName(fVulkanDrawToPresentImageBarrierGraphicsQueueCommandBuffers[Index].Handle,
                                             VK_DEBUG_REPORT_OBJECT_TYPE_COMMAND_BUFFER_EXT,
                                             'GraphicsToPresent_GraphicsQueue');
     fVulkanDrawToPresentImageBarrierGraphicsQueueCommandBufferSemaphores[Index]:=TpvVulkanSemaphore.Create(fVulkanDevice);
     fVulkanDrawToPresentImageBarrierGraphicsQueueCommandBuffers[Index].BeginRecording(TVkCommandBufferUsageFlags(VK_COMMAND_BUFFER_USAGE_SIMULTANEOUS_USE_BIT));
     fVulkanDrawToPresentImageBarrierGraphicsQueueCommandBuffers[Index].CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT),
                                                                                           TVkPipelineStageFlags(VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT),
                                                                                           0,
                                                                                           0,nil,
                                                                                           0,nil,
                                                                                           1,@ImageMemoryBarrier);
     fVulkanDrawToPresentImageBarrierGraphicsQueueCommandBuffers[Index].EndRecording;

    end;

    begin
     // Graphics => present on present queue
     // A layout transition which happens as part of an ownership transfer needs to be specified twice
     // one for the release, and one for the acquire.
     FillChar(ImageMemoryBarrier,SizeOf(TVkImageMemoryBarrier),#0);
     ImageMemoryBarrier.sType:=VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
     ImageMemoryBarrier.pNext:=nil;
     ImageMemoryBarrier.srcAccessMask:=0; // No srcAccessMask is needed, waiting for a semaphore does that automatically.
     ImageMemoryBarrier.dstAccessMask:=0; // No dstAccessMask is needed, signalling a semaphore does that automatically.
     ImageMemoryBarrier.oldLayout:=VK_IMAGE_LAYOUT_PRESENT_SRC_KHR;
     ImageMemoryBarrier.newLayout:=VK_IMAGE_LAYOUT_PRESENT_SRC_KHR;
     ImageMemoryBarrier.srcQueueFamilyIndex:=fVulkanDevice.GraphicsQueueFamilyIndex;
     ImageMemoryBarrier.dstQueueFamilyIndex:=fVulkanDevice.PresentQueueFamilyIndex;
     ImageMemoryBarrier.image:=fVulkanFrameBufferColorAttachments[Index].Image.Handle;
     ImageMemoryBarrier.subresourceRange.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
     ImageMemoryBarrier.subresourceRange.baseMipLevel:=0;
     ImageMemoryBarrier.subresourceRange.levelCount:=1;
     ImageMemoryBarrier.subresourceRange.baseArrayLayer:=0;
     ImageMemoryBarrier.subresourceRange.layerCount:=1;

     fVulkanDrawToPresentImageBarrierPresentQueueCommandBuffers[Index]:=TpvVulkanCommandBuffer.Create(fVulkanPresentCommandPool,VK_COMMAND_BUFFER_LEVEL_PRIMARY);
     fVulkanDevice.DebugMarker.SetObjectName(fVulkanDrawToPresentImageBarrierPresentQueueCommandBuffers[Index].Handle,
                                             VK_DEBUG_REPORT_OBJECT_TYPE_COMMAND_BUFFER_EXT,
                                             'GraphicsToPresent_PresentQueue');
     fVulkanDrawToPresentImageBarrierPresentQueueCommandBufferSemaphores[Index]:=TpvVulkanSemaphore.Create(fVulkanDevice);
     fVulkanDrawToPresentImageBarrierPresentQueueCommandBuffers[Index].BeginRecording(TVkCommandBufferUsageFlags(VK_COMMAND_BUFFER_USAGE_SIMULTANEOUS_USE_BIT));
     fVulkanDrawToPresentImageBarrierPresentQueueCommandBuffers[Index].CmdPipelineBarrier(TVkPipelineStageFlags(VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT),
                                                                                          TVkPipelineStageFlags(VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT),
                                                                                          0,
                                                                                          0,nil,
                                                                                          0,nil,
                                                                                          1,@ImageMemoryBarrier);
     fVulkanDrawToPresentImageBarrierPresentQueueCommandBuffers[Index].EndRecording;

    end;

   end else begin

    fVulkanPresentToDrawImageBarrierGraphicsQueueCommandBuffers[Index]:=nil;
    fVulkanPresentToDrawImageBarrierGraphicsQueueCommandBufferSemaphores[Index]:=nil;

    fVulkanPresentToDrawImageBarrierPresentQueueCommandBuffers[Index]:=nil;
    fVulkanPresentToDrawImageBarrierPresentQueueCommandBufferSemaphores[Index]:=nil;

    fVulkanDrawToPresentImageBarrierGraphicsQueueCommandBuffers[Index]:=nil;
    fVulkanDrawToPresentImageBarrierGraphicsQueueCommandBufferSemaphores[Index]:=nil;

    fVulkanDrawToPresentImageBarrierPresentQueueCommandBuffers[Index]:=nil;
    fVulkanDrawToPresentImageBarrierPresentQueueCommandBufferSemaphores[Index]:=nil;

   end;

  end;

 end;
{$if (defined(fpc) and defined(android)) and not defined(Release)}
 __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Leaving TpvApplication.CreateVulkanCommandBuffers');
{$ifend}
end;

procedure TpvApplication.DestroyVulkanCommandBuffers;
var Index,OtherIndex:TpvInt32;
begin
{$if (defined(fpc) and defined(android)) and not defined(Release)}
 __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Entering TpvApplication.DestroyVulkanCommandBuffers');
{$ifend}
 for OtherIndex:=low(fVulkanFrameFences) to high(fVulkanFrameFences) do begin
  FreeAndNil(fVulkanFrameFences[OtherIndex]);
  for Index:=0 to length(fVulkanFrameFenceCommandBuffers)-1 do begin
   FreeAndNil(fVulkanFrameFenceCommandBuffers[Index,OtherIndex]);
  end;
  for Index:=0 to length(fVulkanFrameFenceSemaphores)-1 do begin
   FreeAndNil(fVulkanFrameFenceSemaphores[Index,OtherIndex]);
  end;
 end;
 for Index:=0 to length(fVulkanFrameFenceSemaphores)-1 do begin
  FreeAndNil(fVulkanWaitFenceCommandBuffers[Index]);
 end;
 for Index:=0 to length(fVulkanWaitFenceSemaphores)-1 do begin
  FreeAndNil(fVulkanWaitFenceSemaphores[Index]);
 end;
 for Index:=0 to length(fVulkanBlankCommandBuffers)-1 do begin
  FreeAndNil(fVulkanBlankCommandBuffers[Index]);
 end;
 for Index:=0 to length(fVulkanBlankCommandBufferSemaphores)-1 do begin
  FreeAndNil(fVulkanBlankCommandBufferSemaphores[Index]);
 end;
 for Index:=0 to length(fVulkanPresentToDrawImageBarrierGraphicsQueueCommandBuffers)-1 do begin
  FreeAndNil(fVulkanPresentToDrawImageBarrierGraphicsQueueCommandBuffers[Index]);
 end;
 for Index:=0 to length(fVulkanPresentToDrawImageBarrierGraphicsQueueCommandBufferSemaphores)-1 do begin
  FreeAndNil(fVulkanPresentToDrawImageBarrierGraphicsQueueCommandBufferSemaphores[Index]);
 end;
 for Index:=0 to length(fVulkanPresentToDrawImageBarrierPresentQueueCommandBuffers)-1 do begin
  FreeAndNil(fVulkanPresentToDrawImageBarrierPresentQueueCommandBuffers[Index]);
 end;
 for Index:=0 to length(fVulkanPresentToDrawImageBarrierPresentQueueCommandBufferSemaphores)-1 do begin
  FreeAndNil(fVulkanPresentToDrawImageBarrierPresentQueueCommandBufferSemaphores[Index]);
 end;
 for Index:=0 to length(fVulkanDrawToPresentImageBarrierGraphicsQueueCommandBuffers)-1 do begin
  FreeAndNil(fVulkanDrawToPresentImageBarrierGraphicsQueueCommandBuffers[Index]);
 end;
 for Index:=0 to length(fVulkanDrawToPresentImageBarrierGraphicsQueueCommandBufferSemaphores)-1 do begin
  FreeAndNil(fVulkanDrawToPresentImageBarrierGraphicsQueueCommandBufferSemaphores[Index]);
 end;
 for Index:=0 to length(fVulkanDrawToPresentImageBarrierPresentQueueCommandBuffers)-1 do begin
  FreeAndNil(fVulkanDrawToPresentImageBarrierPresentQueueCommandBuffers[Index]);
 end;
 for Index:=0 to length(fVulkanDrawToPresentImageBarrierPresentQueueCommandBufferSemaphores)-1 do begin
  FreeAndNil(fVulkanDrawToPresentImageBarrierPresentQueueCommandBufferSemaphores[Index]);
 end;
 fVulkanFrameFenceCommandBuffers:=nil;
 fVulkanFrameFenceSemaphores:=nil;
 fVulkanWaitFenceCommandBuffers:=nil;
 fVulkanWaitFenceSemaphores:=nil;
 fVulkanBlankCommandBuffers:=nil;
 fVulkanBlankCommandBufferSemaphores:=nil;
 fVulkanPresentToDrawImageBarrierGraphicsQueueCommandBuffers:=nil;
 fVulkanPresentToDrawImageBarrierGraphicsQueueCommandBufferSemaphores:=nil;
 fVulkanPresentToDrawImageBarrierPresentQueueCommandBuffers:=nil;
 fVulkanPresentToDrawImageBarrierPresentQueueCommandBufferSemaphores:=nil;
 fVulkanDrawToPresentImageBarrierGraphicsQueueCommandBuffers:=nil;
 fVulkanDrawToPresentImageBarrierGraphicsQueueCommandBufferSemaphores:=nil;
 fVulkanDrawToPresentImageBarrierPresentQueueCommandBuffers:=nil;
 fVulkanDrawToPresentImageBarrierPresentQueueCommandBufferSemaphores:=nil;
 FreeAndNil(fVulkanPresentCommandPool);
 FreeAndNil(fVulkanGraphicsCommandPool);
{$if (defined(fpc) and defined(android)) and not defined(Release)}
 __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Leaving TpvApplication.DestroyVulkanCommandBuffers');
{$ifend}
end;

procedure TpvApplication.SetScreen(const aScreen:TpvApplicationScreen);
begin
 if fScreen<>aScreen then begin
  fScreenLock.Acquire;
  try
   if assigned(fScreen) then begin
    fScreen.Pause;
    if assigned(fVulkanSurface) then begin
     VulkanWaitIdle;
     if fGraphicsPipelinesReady then begin
      fScreen.BeforeDestroySwapChain;
     end else begin
      BeforeDestroySwapChainWithCheck;
     end;
    end;
    fScreen.Hide;
    fScreen.Free;
   end;
   fScreen:=aScreen;
   if assigned(fScreen) then begin
    fScreen.Show;
    if assigned(fScreen) then begin
     fScreen.Resize(fWidth,fHeight);
    end;
    if assigned(fVulkanSurface) then begin
     VulkanWaitIdle;
     if fGraphicsPipelinesReady then begin
      fScreen.AfterCreateSwapChain;
     end else begin
      AfterCreateSwapChainWithCheck;
     end;
    end;
    fScreen.Resume;
    if CanBeParallelProcessed then begin
     // At parallel processing, skip the next first screen frame, due to double buffering at the parallel processing approach
     fSkipNextDrawFrame:=true;
    end;
   end;
  finally
   fScreenLock.Release;
  end;
 end;
end;

function TpvApplication.ShouldSkipNextFrameForRendering:boolean;
begin
 result:=fSkipNextDrawFrame or not
         ((not (CanBeParallelProcessed and (fCountInFlightFrames>1))) or
         IsReadyForDrawOfInFlightFrameIndex(fCurrentInFlightFrameIndex));
end;

function TpvApplication.WaitForPreviousFrame(const aBlocking:Boolean):Boolean;
var InFlightFenceIndex:TpvSizeInt;
    OK:Boolean;
begin
 result:=false;
 InFlightFenceIndex:=fVulkanInFlightFenceIndices[fPreviousInFlightFrameIndex];
 if (InFlightFenceIndex>=0) and
    fVulkanWaitFencesReady[InFlightFenceIndex] then begin
  fVulkanEventLock.Acquire;
  try
   if fVulkanWaitFences[InFlightFenceIndex].GetStatus<>VK_SUCCESS then begin
    if fBlocking then begin
     fVulkanWaitFences[InFlightFenceIndex].WaitFor;
     OK:=true;
    end else begin
     OK:=false;
    end;
   end;
   if OK then begin
    fVulkanWaitFences[InFlightFenceIndex].Reset;
    fVulkanWaitFencesReady[InFlightFenceIndex]:=false;
    fVulkanInFlightFenceIndices[fPreviousInFlightFrameIndex]:=-1;
   end;
  finally
   fVulkanEventLock.Release;
  end;
  result:=OK;
 end;
end;

procedure TpvApplication.WaitForAllInFlightFrames;
var InFlightFrameIndex:TpvSizeInt;
    InFlightFenceIndex:TpvSizeInt;
begin
 fVulkanEventLock.Acquire;
 try
  for InFlightFrameIndex:=0 to fCountInFlightFrames-1 do begin
   InFlightFenceIndex:=fVulkanInFlightFenceIndices[InFlightFrameIndex];
   if (InFlightFenceIndex>=0) and
      fVulkanWaitFencesReady[InFlightFenceIndex] then begin
    if fVulkanWaitFences[InFlightFenceIndex].GetStatus<>VK_SUCCESS then begin
     fVulkanWaitFences[InFlightFenceIndex].WaitFor;
    end;
    fVulkanWaitFences[InFlightFenceIndex].Reset;
    fVulkanWaitFencesReady[InFlightFenceIndex]:=false;
    fVulkanInFlightFenceIndices[InFlightFrameIndex]:=-1;
   end;
  end;
 finally
  fVulkanEventLock.Release;
 end;
end;

function TpvApplication.WaitForSwapChainLatency:boolean;
var Target,TimeOut:TpvUInt64;
    WaitResult:TVkResult;
    PrepreviousFrameFrenceIndex:TpvInt32;
    PrepreviousFrameFrenceMask:TpvUInt32;
    PrepreviousFrameFrence:TpvVulkanFence;
    PacingNow,PacingInterval:TpvInt64;
    PacingSum:TpvInt64;
    PacingIndex,PacingSortIndex,PacingCount:TpvInt32;
    PacingSorted:array[0..FramePacingHistorySize-1] of TpvInt64;
    PacingTemp:TpvInt64;
    RefreshRate:TpvDouble;
    PresentWait2Info:TVkPresentWait2InfoKHR;
begin

 if fGraphicsReady and (fStayActiveRegardlessOfVisibility or IsVisibleToUser) then begin

   // Frame present waiting part (prefer present_wait2, fallback to present_wait)
   if (fPresentFrameLatencyMode in [TpvApplicationPresentFrameLatencyMode.Auto,
                                    TpvApplicationPresentFrameLatencyMode.PresentWait,
                                    TpvApplicationPresentFrameLatencyMode.CombinedWait]) and
      assigned(fVulkanDevice) and
      (fVulkanDevice.PresentIDSupport or fVulkanDevice.PresentID2Support) and
      (fVulkanDevice.PresentWaitSupport or fVulkanDevice.PresentWait2Support) and
      (fPresentFrameLatency<>0) and
      (fVulkanPresentLastID>fPresentFrameLatency) and
      (fPresentMode=TpvApplicationPresentMode.VSync{=TpvApplicationPresentMode.FIFO}) then begin
    Target:=fVulkanPresentLastID-fPresentFrameLatency;
    if fBlocking then begin
{$ifdef Windows}
     TimeOut:=1000000000; // one second for to avoid deadlock issue with nvidia
{$else}
     TimeOut:=High(TpvUInt64);
{$endif}
    end else begin
     TimeOut:=1; // one nanosecond
    end;
    if fVulkanDevice.PresentWait2Support and
       assigned(fVulkanDevice.Commands.Commands.WaitForPresent2KHR) then begin
     // VK_KHR_present_wait2 path
     FillChar(PresentWait2Info,SizeOf(TVkPresentWait2InfoKHR),#0);
     PresentWait2Info.sType:=VK_STRUCTURE_TYPE_PRESENT_WAIT_2_INFO_KHR;
     PresentWait2Info.presentId:=Target;
     PresentWait2Info.timeout:=TimeOut;
     WaitResult:=fVulkanDevice.Commands.WaitForPresent2KHR(fVulkanDevice.Handle,fVulkanSwapChain.Handle,@PresentWait2Info);
    end else if assigned(fVulkanDevice.Commands.Commands.WaitForPresentKHR) then begin
     // VK_KHR_present_wait fallback path
     WaitResult:=fVulkanDevice.Commands.WaitForPresentKHR(fVulkanDevice.Handle,fVulkanSwapChain.Handle,Target,TimeOut);
    end else begin
     WaitResult:=VK_SUCCESS;
    end;
    case WaitResult of
     VK_SUCCESS,
     VK_SUBOPTIMAL_KHR:begin
      result:=true;
     end;
     VK_ERROR_OUT_OF_DATE_KHR,
     VK_TIMEOUT:begin
      result:=true;
(*{$ifdef Windows}
      if IsVisibleToUser then begin
       fAcquireVulkanBackBufferState:=TAcquireVulkanBackBufferState.RecreateSwapChain;
       result:=true;
       exit;
      end;
{$endif}
      result:=false;*)
     end;
     else begin
      Log(LOG_INFO,'TpvApplication.WaitForSwapChainLatency','vkWaitForPresent failed: '+VulkanErrorToString(WaitResult));
      result:=true;
     end;
    end;
   end else begin
    result:=true;
   end;

  // Frame fence waiting part
  if result then begin

   result:=false;

   if (fVulkanBackBufferState=TVulkanBackBufferState.Present) or
      (fPresentFrameLatencyMode=TpvApplicationPresentFrameLatencyMode.None) or
      ((fPresentFrameLatencyMode in [TpvApplicationPresentFrameLatencyMode.Auto,
                                     TpvApplicationPresentFrameLatencyMode.PresentWait]) and
       assigned(fVulkanDevice) and
       (fVulkanDevice.PresentIDSupport or fVulkanDevice.PresentID2Support) and
       (fVulkanDevice.PresentWaitSupport or fVulkanDevice.PresentWait2Support) and
       (fPresentMode=TpvApplicationPresentMode.VSync) and
       (fPresentFrameLatency>0)) then begin

    result:=true;

   end else begin

    // Based on a Sebastian Aaltonen tweet thread, which can found at
    // https://twitter.com/SebAaltonen/status/1569608367618011136 .
    // Reformulated summary:
    // If instead of waiting for the GPU to finish with previous frame
    // respectively the Minus-InFlightFrameCount frame at the beginning
    // of the simulation, we consider waiting for the GPU to finish with
    // the frame before the previous frame (-2 frame index), so we will
    // have a lower overall latency (input lag) and only have to buffer
    // twice the dynamic resources.
    // This approach stabilizes latencies and results in up to three frames
    // in flight, and furthermore the simulation can then also write directly
    // to GPU buffer data pointers if desired.
    // Indeed, in a GPU-bound scenario, this can have only marginally worse
    // latency than waiting for idle, but however far higher throughput.
    // Moreover, it seems to be the best compromise between latency and
    // throughput.
    // However, spiky CPU frames with variable length that happen to exceed
    // the GPU budget could become a problem here. In this case, an extra
    // frame for buffering would better hide the variable CPU cost, and
    // now we get a GPU blast instead.
    // Nevertheless, this problem only occurs when the CPU/GPU utilization
    // is very close to 100%/100% and the frame costs fluctuate strongly.
    // Normally, however, the CPU or GPU usually have a bit of headroom
    // to hide the latency.

    PrepreviousFrameFrenceIndex:=(fVulkanFrameFenceCounter+(4-2)) and 3;

    PrepreviousFrameFrenceMask:=TpvUInt32(1) shl PrepreviousFrameFrenceIndex;

    PrepreviousFrameFrence:=fVulkanFrameFences[PrepreviousFrameFrenceIndex];

    result:=false;

    if fBlocking or
       (((fVulkanFrameFencesReady and PrepreviousFrameFrenceMask)=0) or
        ((not assigned(PrepreviousFrameFrence)) or
         (PrepreviousFrameFrence.GetStatus=VK_SUCCESS))) then begin

     try
      if (fVulkanFrameFencesReady and PrepreviousFrameFrenceMask)<>0 then begin
       fVulkanFrameFencesReady:=fVulkanFrameFencesReady and not PrepreviousFrameFrenceMask;
       if assigned(PrepreviousFrameFrence) then begin
        if fBlocking then begin
         PrepreviousFrameFrence.WaitFor;
        end;
        PrepreviousFrameFrence.Reset;
       end;
      end;
     except
      Log(LOG_VERBOSE,'TpvApplication.WaitForSwapChainLatency','Exception at preprevious waiting');
      raise;
     end;

     result:=true;

    end;

   end;

  end;

  //////////////////////////////////////////////////////////////////////////////
  // Frame pacing: estimate display refresh interval and publish it to        //
  // FramePacingAndFrameRateLimiter which does the actual sleep at frame end. //
  //////////////////////////////////////////////////////////////////////////////

  if fBlocking and (fFramePacingMode<>TpvApplicationFramePacingMode.None) then begin

   PacingNow:=fHighResolutionTimer.GetTime;

   // Record frame-to-frame interval for refresh rate estimation.
   if fFramePacingLastPresentTime<>0 then begin
    fFramePacingHistory[fFramePacingHistoryIndex]:=PacingNow-fFramePacingLastPresentTime;
    fFramePacingHistoryIndex:=(fFramePacingHistoryIndex+1) and FramePacingHistoryMask;
    if fFramePacingHistoryCount<FramePacingHistorySize then begin
     inc(fFramePacingHistoryCount);
    end;
   end;

   // Determine the effective refresh interval:
   // Priority: VulkanPresentTiming > MonitorRefreshRate > PresentIntervalEstimation
   // Auto mode tries all three in order, falling through on failure.
   PacingInterval:=0;

   if (fFramePacingMode in [TpvApplicationFramePacingMode.Auto,TpvApplicationFramePacingMode.VulkanPresentTiming]) and
      fFramePacingPresentTimingAvailable and (fFramePacingPresentTimingRefreshDuration>0) then begin

    // VK_EXT_present_timing path: use the actual refresh duration reported by the driver
    PacingInterval:=fHighResolutionTimer.FromNanoseconds(fFramePacingPresentTimingRefreshDuration);

   end else if fFramePacingMode in [TpvApplicationFramePacingMode.Auto,TpvApplicationFramePacingMode.MonitorRefreshRate,TpvApplicationFramePacingMode.PresentIntervalEstimation] then begin

    repeat

     // Try monitor refresh rate first (unless explicitly PresentIntervalEstimation-only)
     if fFramePacingMode in [TpvApplicationFramePacingMode.Auto,TpvApplicationFramePacingMode.MonitorRefreshRate] then begin
      RefreshRate:=GetNativeRefreshRate;
      if RefreshRate>=1.0 then begin
       fFramePacingEffectiveInterval:=fHighResolutionTimer.FromFloatSeconds(1.0/RefreshRate);
       break;
      end;
     end;

     // Fall back to present history estimation when monitor query failed or not requested
     if (fFramePacingMode in [TpvApplicationFramePacingMode.Auto,TpvApplicationFramePacingMode.PresentIntervalEstimation]) and
        (fFramePacingHistoryCount>=4) then begin

      // Software estimation path: compute median of recent present-to-present intervals
      // to robustly estimate the display refresh interval.
      PacingCount:=fFramePacingHistoryCount;
      for PacingIndex:=0 to PacingCount-1 do begin
       PacingSorted[PacingIndex]:=fFramePacingHistory[(fFramePacingHistoryIndex+FramePacingHistorySize-PacingCount+PacingIndex) and FramePacingHistoryMask];
      end;
      // Simple insertion sort for small array (max 16 elements)
      for PacingIndex:=1 to PacingCount-1 do begin
       PacingTemp:=PacingSorted[PacingIndex];
       PacingSortIndex:=PacingIndex;
       while (PacingSortIndex>0) and (PacingSorted[PacingSortIndex-1]>PacingTemp) do begin
        PacingSorted[PacingSortIndex]:=PacingSorted[PacingSortIndex-1];
        dec(PacingSortIndex);
       end;
       PacingSorted[PacingSortIndex]:=PacingTemp;
      end;
      // Use median (middle quartile range average for robustness)
      PacingSum:=0;
      for PacingIndex:=(PacingCount shr 2) to (PacingCount-(PacingCount shr 2))-1 do begin
       PacingSum:=PacingSum+PacingSorted[PacingIndex];
      end;
      PacingInterval:=PacingSum div (PacingCount-(2*(PacingCount shr 2)));

      // Sanity check: only publish the estimated interval when it looks like
      // a realistic display refresh rate (between ~8ms/125Hz and ~50ms/20Hz).
      if (PacingInterval>0) and
         (PacingInterval>=fHighResolutionTimer.FromMilliseconds(8)) and
         (PacingInterval<=fHighResolutionTimer.FromMilliseconds(50)) then begin
       fFramePacingEffectiveInterval:=PacingInterval;
      end else begin
       fFramePacingEffectiveInterval:=0;
      end;

     end else begin

      // Assume a default refresh rate of 60Hz when no better information is available, to avoid running with an uncapped frame rate and high CPU/GPU load.
      fFramePacingEffectiveInterval:=fHighResolutionTimer.FromFloatSeconds(1.0/60.0);

     end;

     break;

    until false;

   end;

   fFramePacingLastPresentTime:=PacingNow;

   // Present timing feedback polling (VulkanPresentTimingFeedback mode)
   if fFramePacingMode=TpvApplicationFramePacingMode.VulkanPresentTimingFeedback then begin
    PollPresentTimingFeedback;
    if fPresentTimingFeedbackNeedRecalibration then begin
     RecalibratePresentTimingDomains;
    end;
   end;

  end;

 end else begin

  result:=false;

 end;

end;

function TpvApplication.AcquireVulkanBackBuffer:boolean;
var RecreationTries,
    ImageIndex,FrameIndex,NextInFlightFrameIndex,InFlightFenceIndex:TpvInt32;
    TimeOut:TpvUInt64;
begin

 result:=false;

 fVulkanSurfaceRecreated:=false;

 try

  case fVulkanBackBufferState of

   TVulkanBackBufferState.Acquire:begin

    if not assigned(fVulkanSwapChain) then begin
     fAcquireVulkanBackBufferState:=TAcquireVulkanBackBufferState.RecreateSurface;
     fVulkanSurfaceRecreated:=true;
    end;

    RecreationTries:=0;

    repeat

     case fAcquireVulkanBackBufferState of

      TAcquireVulkanBackBufferState.Entry:begin
       fAcquireVulkanBackBufferState:=TAcquireVulkanBackBufferState.WaitOnPreviousFrames;
       continue;
      end;

      TAcquireVulkanBackBufferState.WaitOnPreviousFrames:begin
       if fWaitOnPreviousFrames then begin
        for ImageIndex:=0 to fCountSwapChainImages-1 do begin
         if fVulkanPresentCompleteFencesReady[ImageIndex] then begin
          if fVulkanPresentCompleteFences[ImageIndex].GetStatus<>VK_SUCCESS then begin
           if fBlocking then begin
            fVulkanPresentCompleteFences[ImageIndex].WaitFor;
           end else begin
            exit;
           end;
          end;
          fVulkanPresentCompleteFences[ImageIndex].Reset;
          fVulkanPresentCompleteFencesReady[ImageIndex]:=false;
         end;
         if fVulkanWaitFencesReady[ImageIndex] then begin
          if fVulkanWaitFences[ImageIndex].GetStatus<>VK_SUCCESS then begin
           if fBlocking then begin
            fVulkanWaitFences[ImageIndex].WaitFor;
           end else begin
            exit;
           end;
          end;
          fVulkanWaitFences[ImageIndex].Reset;
          fVulkanWaitFencesReady[ImageIndex]:=false;
         end;
        end;
        fVulkanDevice.WaitIdle; // even when fBlocking is false, for to satisfy the validation layers in some edge-cases
        for FrameIndex:=0 to MaxInFlightFrames-1 do begin
         fVulkanInFlightFenceIndices[FrameIndex]:=-1;
        end;
       end;
       fAcquireVulkanBackBufferState:=TAcquireVulkanBackBufferState.WaitOnPresentCompleteFence;
       continue;
      end;

      TAcquireVulkanBackBufferState.WaitOnPresentCompleteFence:begin
       if fVulkanPresentCompleteFencesReady[fSwapChainImageCounterIndex] then begin
        if fVulkanPresentCompleteFences[fSwapChainImageCounterIndex].GetStatus<>VK_SUCCESS then begin
         if fBlocking then begin
          fVulkanPresentCompleteFences[fSwapChainImageCounterIndex].WaitFor;
         end else begin
          break;
         end;
        end;
        fVulkanPresentCompleteFences[fSwapChainImageCounterIndex].Reset;
        fVulkanPresentCompleteFencesReady[fSwapChainImageCounterIndex]:=false;
       end;
       fAcquireVulkanBackBufferState:=TAcquireVulkanBackBufferState.CheckSettings;
       continue;
      end;

      TAcquireVulkanBackBufferState.CheckSettings:begin
       if ((not fVulkanDelayResizeBugWorkaround) and
           ((fVulkanSwapChain.Width<>fWidth) or
            (fVulkanSwapChain.Height<>fHeight))) or
          (fVulkanSwapChain.PresentMode<>PresentModeToVulkanPresentMode[fPresentMode]) then begin
        VulkanDebugLn('New surface dimension size and/or vertical synchronization setting detected! Old width: '+IntToStr(fWidth)+' - Old height: '+IntToStr(fHeight)+' - Old preset mode: '+IntToStr(Int32(fPresentMode))+' - New width: '+IntToStr(fVulkanSwapChain.Width)+' - New height: '+IntToStr(fVulkanSwapChain.Height)+' - New preset mode: '+IntToStr(Int32(fVulkanSwapChain.PresentMode)));
        fAcquireVulkanBackBufferState:=TAcquireVulkanBackBufferState.RecreateSwapChain;
       end else begin
        fAcquireVulkanBackBufferState:=TAcquireVulkanBackBufferState.Acquire;
       end;
       continue;
      end;

      TAcquireVulkanBackBufferState.Acquire:begin
       try
        if fBlocking then begin
         if fCountSwapChainImages>1 then begin
          TimeOut:=TpvUInt64(high(TpvUInt64));
         end else begin
          TimeOut:=1000000000; // 1e+9 nanoseconds = 1000 milliseconds = 1 second, for AMD drivers, which have a immediate-present-mode deadlock problem at fullscreen otherwise
         end;
        end else begin
         TimeOut:=0;
        end;
        NextInFlightFrameIndex:=fCurrentInFlightFrameIndex+1;
        if NextInFlightFrameIndex>=fCountInFlightFrames then begin
         dec(NextInFlightFrameIndex,fCountInFlightFrames);
        end;
        case fVulkanSwapChain.AcquireNextImage(fVulkanPresentCompleteSemaphores[fSwapChainImageCounterIndex],
                                               fVulkanPresentCompleteFences[fSwapChainImageCounterIndex],
                                               TimeOut) of
         VK_SUCCESS:begin
          fVulkanPresentCompleteFencesReady[fSwapChainImageCounterIndex]:=true;
          fPreviousInFlightFrameIndex:=fCurrentInFlightFrameIndex;
          fCurrentInFlightFrameIndex:=NextInFlightFrameIndex;
          fNextInFlightFrameIndex:=fCurrentInFlightFrameIndex+1;
          if fNextInFlightFrameIndex>=fCountInFlightFrames then begin
           dec(fNextInFlightFrameIndex,fCountInFlightFrames);
          end;
          fSwapChainImageIndex:=fVulkanSwapChain.CurrentImageIndex;
          fAcquireVulkanBackBufferState:=TAcquireVulkanBackBufferState.WaitOnFence;
          continue;
         end;
         VK_SUBOPTIMAL_KHR:begin
          if fVulkanRecreateSwapChainOnSuboptimalSurface then begin
           VulkanDebugLn('Suboptimal surface detected!');
           fAcquireVulkanBackBufferState:=TAcquireVulkanBackBufferState.RecreateSwapChain;
           continue;
          end else begin
           fVulkanPresentCompleteFencesReady[fSwapChainImageCounterIndex]:=true;
           fPreviousInFlightFrameIndex:=fCurrentInFlightFrameIndex;
           fCurrentInFlightFrameIndex:=NextInFlightFrameIndex;
           fNextInFlightFrameIndex:=fCurrentInFlightFrameIndex+1;
           if fNextInFlightFrameIndex>=fCountInFlightFrames then begin
            dec(fNextInFlightFrameIndex,fCountInFlightFrames);
           end;
           fSwapChainImageIndex:=fVulkanSwapChain.CurrentImageIndex;
           fAcquireVulkanBackBufferState:=TAcquireVulkanBackBufferState.WaitOnFence;
           continue;
          end;
         end;
         else {VK_TIMEOUT:}begin
          break;
         end;
        end;
       except
        on VulkanResultException:EpvVulkanResultException do begin
         case VulkanResultException.ResultCode of
          VK_ERROR_SURFACE_LOST_KHR,
          VK_ERROR_FULL_SCREEN_EXCLUSIVE_MODE_LOST_EXT:begin
           fAcquireVulkanBackBufferState:=TAcquireVulkanBackBufferState.RecreateSurface;
           VulkanDebugLn(TpvUTF8String(VulkanResultException.ClassName+': '+VulkanResultException.Message));
          end;
          VK_ERROR_OUT_OF_DATE_KHR,
          VK_SUBOPTIMAL_KHR:begin
           fAcquireVulkanBackBufferState:=TAcquireVulkanBackBufferState.RecreateSwapChain;
           VulkanDebugLn(TpvUTF8String(VulkanResultException.ClassName+': '+VulkanResultException.Message));
          end;
          else begin
           raise;
          end;
         end;
        end;
       end;
      end;

      TAcquireVulkanBackBufferState.WaitOnFence:begin
       if fWaitOnPreviousFrame then begin
        InFlightFenceIndex:=fVulkanInFlightFenceIndices[fPreviousInFlightFrameIndex];
        if (InFlightFenceIndex>=0) and
           fVulkanWaitFencesReady[InFlightFenceIndex] then begin
         if fVulkanWaitFences[InFlightFenceIndex].GetStatus<>VK_SUCCESS then begin
          if fBlocking then begin
           fVulkanWaitFences[InFlightFenceIndex].WaitFor;
          end else begin
           break;
          end;
         end;
         fVulkanWaitFences[InFlightFenceIndex].Reset;
         fVulkanWaitFencesReady[InFlightFenceIndex]:=false;
         fVulkanInFlightFenceIndices[fPreviousInFlightFrameIndex]:=-1;
        end;
       end;
       InFlightFenceIndex:=fVulkanInFlightFenceIndices[fCurrentInFlightFrameIndex];
       if (InFlightFenceIndex>=0) and
          fVulkanWaitFencesReady[InFlightFenceIndex] then begin
        if fVulkanWaitFences[InFlightFenceIndex].GetStatus<>VK_SUCCESS then begin
         if fBlocking then begin
          fVulkanWaitFences[InFlightFenceIndex].WaitFor;
         end else begin
          break;
         end;
        end;
        fVulkanWaitFences[InFlightFenceIndex].Reset;
        fVulkanWaitFencesReady[InFlightFenceIndex]:=false;
        fVulkanInFlightFenceIndices[fCurrentInFlightFrameIndex]:=-1;
       end;
       if fVulkanWaitFencesReady[fSwapChainImageIndex] then begin
        if fVulkanWaitFences[fSwapChainImageIndex].GetStatus<>VK_SUCCESS then begin
         if fBlocking then begin
          fVulkanWaitFences[fSwapChainImageIndex].WaitFor;
         end else begin
          break;
         end;
        end;
        fVulkanWaitFences[fSwapChainImageIndex].Reset;
        fVulkanWaitFencesReady[fSwapChainImageIndex]:=false;
       end;
       fVulkanInFlightFenceIndices[fCurrentInFlightFrameIndex]:=fSwapChainImageIndex;
       fAcquireVulkanBackBufferState:=TAcquireVulkanBackBufferState.Apply;
       continue;
      end;

      TAcquireVulkanBackBufferState.Apply:begin

       fVulkanWaitSemaphore:=fVulkanPresentCompleteSemaphores[fSwapChainImageCounterIndex];

       if assigned(fVulkanPresentToDrawImageBarrierGraphicsQueueCommandBuffers[fSwapChainImageIndex]) then begin

        // If present and graphics queue families are different, then a image barrier is required

        fVulkanPresentToDrawImageBarrierPresentQueueCommandBuffers[fSwapChainImageIndex].Execute(fVulkanDevice.PresentQueue,
                                                                                                             TVkPipelineStageFlags(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT),
                                                                                                             fVulkanWaitSemaphore,
                                                                                                             fVulkanPresentToDrawImageBarrierPresentQueueCommandBufferSemaphores[fSwapChainImageIndex],
                                                                                                             nil,
                                                                                                             false);
        fVulkanWaitSemaphore:=fVulkanPresentToDrawImageBarrierPresentQueueCommandBufferSemaphores[fSwapChainImageIndex];

        fVulkanPresentToDrawImageBarrierGraphicsQueueCommandBuffers[fSwapChainImageIndex].Execute(fVulkanDevice.GraphicsQueue,
                                                                                                              TVkPipelineStageFlags(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT),
                                                                                                              fVulkanWaitSemaphore,
                                                                                                              fVulkanPresentToDrawImageBarrierGraphicsQueueCommandBufferSemaphores[fSwapChainImageIndex],
                                                                                                              nil,
                                                                                                              false);
        fVulkanWaitSemaphore:=fVulkanPresentToDrawImageBarrierGraphicsQueueCommandBufferSemaphores[fSwapChainImageIndex];

       end;

 {     if assigned(fVulkanDrawToPresentImageBarrierGraphicsQueueCommandBuffers[fSwapChainImageIndex]) and
          assigned(fVulkanDrawToPresentImageBarrierPresentQueueCommandBuffers[fSwapChainImageIndex]) then begin
        fVulkanWaitFence:=nil;
       end else begin
        fVulkanWaitFence:=fVulkanWaitFences[fSwapChainImageIndex];
       end;}

       fVulkanWaitFence:=nil;

       result:=true;

       fAcquireVulkanBackBufferState:=TAcquireVulkanBackBufferState.Entry;

       fVulkanBackBufferState:=TVulkanBackBufferState.Present;

       break;

      end;

      TAcquireVulkanBackBufferState.RecreateSwapChain,
      TAcquireVulkanBackBufferState.RecreateSurface:begin

       if fUseExtraUpdateThread and assigned(fUpdateThread) then begin
        fUpdateThread.WaitForDone;
       end else begin
        if assigned(fUpdateJob) then begin
         try
          fPasMPInstance.WaitRelease(fUpdateJob);
         finally
          fUpdateJob:=nil;
         end;
        end;
        while TPasMPInterlocked.Read(fInUpdateJobFunction) do begin
         TPasMP.Yield;
        end;
       end;

       for ImageIndex:=0 to fCountSwapChainImages-1 do begin
        if fVulkanPresentCompleteFencesReady[ImageIndex] then begin
         fVulkanPresentCompleteFences[ImageIndex].WaitFor;
         fVulkanPresentCompleteFences[ImageIndex].Reset;
         fVulkanPresentCompleteFencesReady[ImageIndex]:=false;
        end;
        if fVulkanWaitFencesReady[ImageIndex] then begin
         fVulkanWaitFences[ImageIndex].WaitFor;
         fVulkanWaitFences[ImageIndex].Reset;
         fVulkanWaitFencesReady[ImageIndex]:=false;
        end;
       end;

       fVulkanDevice.WaitIdle;

       if fAcquireVulkanBackBufferState=TAcquireVulkanBackBufferState.RecreateSurface then begin
        VulkanDebugLn('Recreating vulkan surface... ');
       end else begin
        VulkanDebugLn('Recreating vulkan swap chain... ');
       end;
       if fVulkanTransferInFlightCommandsFromOldSwapChain then begin
        fVulkanOldSwapChain:=fVulkanSwapChain;
       end else begin
        fVulkanOldSwapChain:=nil;
       end;
       try
        VulkanWaitIdle;
        BeforeDestroySwapChainWithCheck;
        if fVulkanTransferInFlightCommandsFromOldSwapChain then begin
         fVulkanSwapChain:=nil;
        end;
        DestroyVulkanCommandBuffers;
        DestroyVulkanFrameBuffers;
        DestroyVulkanRenderPass;
        DestroyVulkanSwapChain;
        if fAcquireVulkanBackBufferState=TAcquireVulkanBackBufferState.RecreateSurface then begin
         DestroyVulkanSurface;
         CreateVulkanSurface;
        end;
        CreateVulkanSwapChain;
        CreateVulkanRenderPass;
        CreateVulkanFrameBuffers;
        CreateVulkanCommandBuffers;
        VulkanWaitIdle;
        AfterCreateSwapChainWithCheck;
       finally
        FreeAndNil(fVulkanOldSwapChain);
       end;
       if fAcquireVulkanBackBufferState=TAcquireVulkanBackBufferState.RecreateSurface then begin
        VulkanDebugLn('Recreated vulkan surface... ');
       end else begin
        VulkanDebugLn('Recreated vulkan swap chain... ');
       end;

       fVulkanWaitSemaphore:=nil;
       fVulkanWaitFence:=nil;

       fSwapChainImageCounterIndex:=0;

       fSwapChainImageIndex:=0;

       fVulkanSurfaceRecreated:=true;

       fAcquireVulkanBackBufferState:=TAcquireVulkanBackBufferState.Entry;

       if RecreationTries<3 then begin
        inc(RecreationTries);
        continue;
       end else begin
        // For to avoid main loop deadlocks
        break;
       end;

      end;

      else begin
       break;
      end;

     end;

     break;

    until false;

   end;

   else {TVulkanBackBufferState.Present:}begin
    result:=true;
   end;

  end;

 except
  Log(LOG_VERBOSE,'TpvApplication.AcquireVulkanBackBuffer','Exception');
  raise;
 end;

end;

function TpvApplication.PresentVulkanBackBuffer:boolean;
var PresentIdKHR:TVkPresentIdKHR;
    PresentId2KHR:TVkPresentId2KHR;
    PresentTimingsInfoEXT:TVkPresentTimingsInfoEXT;
    PresentTimingInfoEXT:TVkPresentTimingInfoEXT;
    PresentNext:Pointer;
    PresentFenceInfo:TVkSwapchainPresentFenceInfoKHR;
    PresentFenceHandle:TVkFence;
begin

 SetLowLatencyMarker(VK_LATENCY_MARKER_PRESENT_START_NV);

 result:=false;

 try

  if (fVulkanFrameFencesReady and (TpvUInt32(1) shl (fVulkanFrameFenceCounter and 3)))<>0 then begin
   fVulkanFrameFences[fVulkanFrameFenceCounter and 3].Reset;
  end;

  fVulkanFrameFenceCommandBuffers[fSwapChainImageIndex,fVulkanFrameFenceCounter].Execute(fVulkanDevice.GraphicsQueue,
                                                                                         TVkPipelineStageFlags(VK_PIPELINE_STAGE_ALL_COMMANDS_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT),
                                                                                         fVulkanWaitSemaphore,
                                                                                         fVulkanFrameFenceSemaphores[fSwapChainImageIndex,fVulkanFrameFenceCounter],
                                                                                         fVulkanFrameFences[fVulkanFrameFenceCounter],
                                                                                         false);
  fVulkanWaitSemaphore:=fVulkanFrameFenceSemaphores[fSwapChainImageIndex,fVulkanFrameFenceCounter];

  fVulkanFrameFencesReady:=fVulkanFrameFencesReady or (TpvUInt32(1) shl (fVulkanFrameFenceCounter and 3));

  fVulkanFrameFenceCounter:=(fVulkanFrameFenceCounter+1) and 3;

  if assigned(fVulkanDrawToPresentImageBarrierGraphicsQueueCommandBuffers[fSwapChainImageIndex]) and
     assigned(fVulkanDrawToPresentImageBarrierPresentQueueCommandBuffers[fSwapChainImageIndex]) then begin

   // If present and graphics queue families are different, then a image barrier is required

   fVulkanDrawToPresentImageBarrierGraphicsQueueCommandBuffers[fSwapChainImageIndex].Execute(fVulkanDevice.GraphicsQueue,
                                                                                             TVkPipelineStageFlags(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT),
                                                                                             fVulkanWaitSemaphore,
                                                                                             fVulkanDrawToPresentImageBarrierGraphicsQueueCommandBufferSemaphores[fSwapChainImageIndex],
                                                                                             nil,
                                                                                             false);
   fVulkanWaitSemaphore:=fVulkanDrawToPresentImageBarrierGraphicsQueueCommandBufferSemaphores[fSwapChainImageIndex];

   fVulkanDrawToPresentImageBarrierPresentQueueCommandBuffers[fSwapChainImageIndex].Execute(fVulkanDevice.PresentQueue,
                                                                                            TVkPipelineStageFlags(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT),
                                                                                            fVulkanWaitSemaphore,
                                                                                            fVulkanDrawToPresentImageBarrierPresentQueueCommandBufferSemaphores[fSwapChainImageIndex],
                                                                                            fVulkanWaitFences[fSwapChainImageIndex],
                                                                                            false);
   fVulkanWaitSemaphore:=fVulkanDrawToPresentImageBarrierPresentQueueCommandBufferSemaphores[fSwapChainImageIndex];

   fVulkanWaitFence:=fVulkanWaitFences[fSwapChainImageIndex];

  end else if not assigned(fVulkanWaitFence) then begin

   fVulkanWaitFenceCommandBuffers[fSwapChainImageIndex].Execute(fVulkanDevice.GraphicsQueue,
                                                                TVkPipelineStageFlags(VK_PIPELINE_STAGE_ALL_COMMANDS_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT) or TVkPipelineStageFlags(VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT),
                                                                fVulkanWaitSemaphore,
                                                                fVulkanWaitFenceSemaphores[fSwapChainImageIndex],
                                                                fVulkanWaitFences[fSwapChainImageIndex],
                                                                false);
   fVulkanWaitSemaphore:=fVulkanWaitFenceSemaphores[fSwapChainImageIndex];

   fVulkanWaitFence:=fVulkanWaitFences[fSwapChainImageIndex];

  end;

  fVulkanWaitFencesReady[fSwapChainImageIndex]:=true;

 //fVulkanDevice.GraphicsQueue.WaitIdle; // A GPU/CPU graphics queue synchronization point only for debug cases here, when something got run wrong

  fVulkanBackBufferState:=TVulkanBackBufferState.Acquire;

  PresentNext:=nil;

  if fVulkanDevice.PresentID2Support then begin
   // VK_KHR_present_id2 path
   FillChar(PresentId2KHR,SizeOf(TVkPresentId2KHR),#0);
   PresentId2KHR.sType:=VK_STRUCTURE_TYPE_PRESENT_ID_2_KHR;
   PresentId2KHR.swapchainCount:=1;
   PresentId2KHR.pPresentIds:=@fVulkanPresentID;
   inc(fVulkanPresentID);
   PresentNext:=@PresentId2KHR;
  end else if fVulkanDevice.PresentIDSupport then begin
   // VK_KHR_present_id fallback path
   FillChar(PresentIdKHR,SizeOf(TVkPresentIdKHR),#0);
   PresentIdKHR.sType:=VK_STRUCTURE_TYPE_PRESENT_ID_KHR;
   PresentIdKHR.swapchainCount:=1;
   PresentIdKHR.pPresentIds:=@fVulkanPresentID;
   inc(fVulkanPresentID);
   PresentNext:=@PresentIdKHR;
  end;

  // Chain VK_EXT_present_timing info when available, to request
  // presentation at the nearest refresh cycle for consistent pacing
  // Present timing: either simple (nearest refresh cycle) or feedback-based
  if (fFramePacingMode=TpvApplicationFramePacingMode.VulkanPresentTimingFeedback) and
     fPresentTimingFeedbackInitialized and
     assigned(fVulkanDevice) and
     fVulkanDevice.PresentTimingSupport then begin
   ComputePresentTimingTarget(PresentTimingInfoEXT);
   FillChar(PresentTimingsInfoEXT,SizeOf(TVkPresentTimingsInfoEXT),#0);
   PresentTimingsInfoEXT.sType:=VK_STRUCTURE_TYPE_PRESENT_TIMINGS_INFO_EXT;
   PresentTimingsInfoEXT.swapchainCount:=1;
   PresentTimingsInfoEXT.pTimingInfos:=@PresentTimingInfoEXT;
   PresentTimingsInfoEXT.pNext:=PresentNext;
   PresentNext:=@PresentTimingsInfoEXT;
  end else if (fFramePacingMode<>TpvApplicationFramePacingMode.None) and
              fFramePacingPresentTimingAvailable and
              assigned(fVulkanDevice) and
              fVulkanDevice.PresentTimingSupport then begin
   // Simple present timing: request presentation at the nearest refresh cycle for consistent pacing
   FillChar(PresentTimingInfoEXT,SizeOf(TVkPresentTimingInfoEXT),#0);
   PresentTimingInfoEXT.sType:=VK_STRUCTURE_TYPE_PRESENT_TIMING_INFO_EXT;
   PresentTimingInfoEXT.flags:=TVkPresentTimingInfoFlagsEXT(VK_PRESENT_TIMING_INFO_PRESENT_AT_NEAREST_REFRESH_CYCLE_BIT_EXT);
   PresentTimingInfoEXT.targetTime:=0; // nearest refresh cycle
   PresentTimingInfoEXT.timeDomainID:=fFramePacingPresentTimingTimeDomainID;
   PresentTimingInfoEXT.presentStageQueries:=0;
   PresentTimingInfoEXT.targetTimeDomainPresentStage:=0;
   FillChar(PresentTimingsInfoEXT,SizeOf(TVkPresentTimingsInfoEXT),#0);
   PresentTimingsInfoEXT.sType:=VK_STRUCTURE_TYPE_PRESENT_TIMINGS_INFO_EXT;
   PresentTimingsInfoEXT.swapchainCount:=1;
   PresentTimingsInfoEXT.pTimingInfos:=@PresentTimingInfoEXT;
   PresentTimingsInfoEXT.pNext:=PresentNext;
   PresentNext:=@PresentTimingsInfoEXT;
  end;

  // Chain present fence via VK_KHR_swapchain_maintenance1 when available
  if fVulkanDevice.SwapchainMaintenance1Support and
     (fSwapChainImageIndex>=0) and
     (fSwapChainImageIndex<length(fVulkanPresentCompleteFences)) and
     assigned(fVulkanPresentCompleteFences[fSwapChainImageIndex]) then begin
   if fVulkanPresentCompleteFencesReady[fSwapChainImageIndex] then begin
    fVulkanPresentCompleteFences[fSwapChainImageIndex].WaitFor;
    fVulkanPresentCompleteFences[fSwapChainImageIndex].Reset;
    fVulkanPresentCompleteFencesReady[fSwapChainImageIndex]:=false;
   end;
   PresentFenceHandle:=fVulkanPresentCompleteFences[fSwapChainImageIndex].Handle;
   FillChar(PresentFenceInfo,SizeOf(TVkSwapchainPresentFenceInfoKHR),#0);
   PresentFenceInfo.sType:=VK_STRUCTURE_TYPE_SWAPCHAIN_PRESENT_FENCE_INFO_KHR;
   PresentFenceInfo.swapchainCount:=1;
   PresentFenceInfo.pFences:=@PresentFenceHandle;
   PresentFenceInfo.pNext:=PresentNext;
   PresentNext:=@PresentFenceInfo;
   fVulkanPresentCompleteFencesReady[fSwapChainImageIndex]:=true;
  end;

  try
   case fVulkanSwapChain.QueuePresent(fVulkanDevice.PresentQueue,fVulkanWaitSemaphore,PresentNext) of
    VK_SUCCESS:begin
     //fVulkanDevice.WaitIdle; // A GPU/CPU frame synchronization point only for debug cases here, when something got run wrong
     fVulkanPresentLastID:=fVulkanPresentID;
     fNextInFlightFrameIndex:=fCurrentInFlightFrameIndex+1;
     if fNextInFlightFrameIndex>=fCountInFlightFrames then begin
      dec(fNextInFlightFrameIndex,fCountInFlightFrames);
     end;
     inc(fSwapChainImageCounterIndex);
     if fSwapChainImageCounterIndex>=fCountSwapChainImages then begin
      dec(fSwapChainImageCounterIndex,fCountSwapChainImages);
     end;
     result:=true;
    end;
    VK_SUBOPTIMAL_KHR:begin
     fVulkanPresentLastID:=fVulkanPresentID;
     if fVulkanRecreateSwapChainOnSuboptimalSurface then begin
      if not (fAcquireVulkanBackBufferState in [TAcquireVulkanBackBufferState.RecreateSwapChain,
                                                TAcquireVulkanBackBufferState.RecreateSurface,
                                                TAcquireVulkanBackBufferState.RecreateDevice]) then begin
       VulkanDebugLn('Suboptimal surface detected!');
       fAcquireVulkanBackBufferState:=TAcquireVulkanBackBufferState.RecreateSwapChain;
      end;
     end else begin
      //fVulkanDevice.WaitIdle; // A GPU/CPU frame synchronization point only for debug cases here, when something got run wrong
      fNextInFlightFrameIndex:=fCurrentInFlightFrameIndex+1;
      if fNextInFlightFrameIndex>=fCountInFlightFrames then begin
       dec(fNextInFlightFrameIndex,fCountInFlightFrames);
      end;
      inc(fSwapChainImageCounterIndex);
      if fSwapChainImageCounterIndex>=fCountSwapChainImages then begin
       dec(fSwapChainImageCounterIndex,fCountSwapChainImages);
      end;
      result:=true;
     end;
    end;
    else begin
    end;
   end;
  except
   on VulkanResultException:EpvVulkanResultException do begin
    case VulkanResultException.ResultCode of
     VK_ERROR_SURFACE_LOST_KHR,
     VK_ERROR_FULL_SCREEN_EXCLUSIVE_MODE_LOST_EXT:begin
      if not (fAcquireVulkanBackBufferState in [TAcquireVulkanBackBufferState.RecreateSurface,
                                                TAcquireVulkanBackBufferState.RecreateDevice]) then begin
       fAcquireVulkanBackBufferState:=TAcquireVulkanBackBufferState.RecreateSurface;
      end;
      VulkanDebugLn(TpvUTF8String(VulkanResultException.ClassName+': '+VulkanResultException.Message));
     end;
     VK_ERROR_OUT_OF_DATE_KHR,
     VK_SUBOPTIMAL_KHR:begin
      if not (fAcquireVulkanBackBufferState in [TAcquireVulkanBackBufferState.RecreateSwapChain,
                                                TAcquireVulkanBackBufferState.RecreateSurface,
                                                TAcquireVulkanBackBufferState.RecreateDevice]) then begin
       fAcquireVulkanBackBufferState:=TAcquireVulkanBackBufferState.RecreateSwapChain;
      end;
 {    inc(fCurrentInFlightFrameIndex);
      if fCurrentInFlightFrameIndex>=fCountInFlightFrames then begin
       dec(fCurrentInFlightFrameIndex,fCountInFlightFrames);
      end;}
      fNextInFlightFrameIndex:=fCurrentInFlightFrameIndex+1;
      if fNextInFlightFrameIndex>=fCountInFlightFrames then begin
       dec(fNextInFlightFrameIndex,fCountInFlightFrames);
      end;
      VulkanDebugLn(TpvUTF8String(VulkanResultException.ClassName+': '+VulkanResultException.Message));
     end;
     else begin
      raise;
     end;
    end;
   end;
  end;

 except
  Log(LOG_VERBOSE,'TpvApplication.PresentVulkanBackBuffer','Exception');
  raise;
 end;

 SetLowLatencyMarker(VK_LATENCY_MARKER_PRESENT_END_NV);

end;

procedure TpvApplication.SetNextScreen(const aNextScreen:TpvApplicationScreen);
begin
 if (fScreen<>aNextScreen) and (fNextScreen<>aNextScreen) then begin
  FreeAndNil(fNextScreen);
  fNextScreen:=aNextScreen;
  fHasNewNextScreen:=true;
 end;
end;

procedure TpvApplication.SetNextScreenClass(const aNextScreenClass:TpvApplicationScreenClass);
begin
 if (not (fScreen is aNextScreenClass)) and (fNextScreenClass<>aNextScreenClass) then begin
  fNextScreenClass:=aNextScreenClass;
  fHasNewNextScreen:=true;
 end;
end;

procedure TpvApplication.ReadConfig;
begin
end;

procedure TpvApplication.SaveConfig;
begin
end;

procedure TpvApplication.PostRunnable(const aRunnable:TpvApplicationRunnable);
var Index:TpvInt32;
begin
 fRunnableListCriticalSection.Acquire;
 try
  Index:=fRunnableListCount;
  inc(fRunnableListCount);
  if Index>=length(fRunnableList) then begin
   SetLength(fRunnableList,(Index+1)*2);
  end;
  fRunnableList[Index]:=aRunnable;
 finally
  fRunnableListCriticalSection.Release;
 end;
end;

procedure TpvApplication.AddLifecycleListener(const aLifecycleListener:TpvApplicationLifecycleListener);
begin
 fLifecycleListenerListCriticalSection.Acquire;
 try
  if fLifecycleListenerList.IndexOf(aLifecycleListener)<0 then begin
   fLifecycleListenerList.Add(aLifecycleListener);
  end;
 finally
  fLifecycleListenerListCriticalSection.Release;
 end;
end;

procedure TpvApplication.RemoveLifecycleListener(const aLifecycleListener:TpvApplicationLifecycleListener);
var Index:TpvInt32;
begin
 fLifecycleListenerListCriticalSection.Acquire;
 try
  Index:=fLifecycleListenerList.IndexOf(aLifecycleListener);
  if Index>=0 then begin
   fLifecycleListenerList.Delete(Index);
  end;
 finally
  fLifecycleListenerListCriticalSection.Release;
 end;
end;

procedure TpvApplication.Initialize;
begin
end;

procedure TpvApplication.Terminate;
begin
 fTerminated:=true;
end;

procedure TpvApplication.InitializeGraphics;
begin
{$if (defined(fpc) and defined(android)) and not defined(Release)}
 __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Entering TpvApplication.InitializeGraphics');
{$ifend}
 if not fGraphicsReady then begin
  try
   fGraphicsReady:=true;
   CreateVulkanSurface;
   CreateVulkanSwapChain;
   CreateVulkanRenderPass;
   CreateVulkanFrameBuffers;
   CreateVulkanCommandBuffers;
   VulkanWaitIdle;
   AfterCreateSwapChainWithCheck;
  except
   Terminate;
   raise;
  end;
 end;
{$if (defined(fpc) and defined(android)) and not defined(Release)}
 __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Leaving TpvApplication.InitializeGraphics');
{$ifend}
end;

procedure TpvApplication.DeinitializeGraphics;
begin
{$if (defined(fpc) and defined(android)) and not defined(Release)}
 __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Entering TpvApplication.DeinitializeGraphics');
{$ifend}
 if fGraphicsReady then begin
  VulkanWaitIdle;
  BeforeDestroySwapChainWithCheck;
  DestroyVulkanCommandBuffers;
  DestroyVulkanFrameBuffers;
  DestroyVulkanRenderPass;
  DestroyVulkanSwapChain;
  DestroyVulkanSurface;
  fGraphicsReady:=false;
 end;
{$if (defined(fpc) and defined(android)) and not defined(Release)}
 __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Leaving TpvApplication.DeinitializeGraphics');
{$ifend}
end;

{$if defined(Windows) and not (defined(PasVulkanUseSDL2) or defined(PasVulkanHeadless))}

// On Windows >= 10 the old MMSYSTEM WaveOut and DirectSound APIs are just thin WASAPI API wrappers now, so
// that we can use the old but simple to use MMSYSTEM WAVEOUT API here without big disadvantages over using
// WASAPI directly.

type { TpvWin32AudioThread }

     TpvWin32AudioThread=class(TPasMPThread)
      private
       const SampleRate=48000;
             Channels=2;
             Bits=16;
             BufferSize=1024;
      private
       fApplication:TpvApplication;
       fAudio:TpvAudio;
       fEvent:THandle;
      protected
       procedure TerminatedSet; override;
       procedure Execute; override;
      public
       constructor Create(aApplication:TpvApplication;aAudio:TpvAudio); reintroduce;
       destructor Destroy; override;
     end;

constructor TpvWin32AudioThread.Create(aApplication:TpvApplication;aAudio:TpvAudio);
begin
 fApplication:=aApplication;
 fAudio:=aAudio;
 fEvent:=CreateEventW(nil,false,false,nil);
 inherited Create(false);
end;

destructor TpvWin32AudioThread.Destroy;
begin
 if not Terminated then begin
  Terminate;
  WaitFor;
 end;
 if fEvent<>0 then begin
  CloseHandle(fEvent);
 end;
 inherited Destroy;
end;

procedure TpvWin32AudioThread.TerminatedSet;
begin
 if fEvent<>0 then begin
  SetEvent(fEvent);
 end;
 inherited TerminatedSet;
end;

procedure TpvWin32AudioThread.Execute;
const CountBuffers=4;
var WaveFormat:TWaveFormatEx;
    WaveHandler:array[0..CountBuffers-1] of TWAVEHDR;
    WaveOutHandle:HWAVEOUT;
    BufferCounter:TpvInt32;
begin
 if fEvent<>0 then begin
  Priority:=TThreadPriority.tpTimeCritical;
  try
   FillChar(WaveFormat,SizeOf(TWaveFormatEx),#0);
   WaveFormat.wFormatTag:=WAVE_FORMAT_PCM;
   WaveFormat.nChannels:=2;
   WaveFormat.nSamplesPerSec:=SampleRate;
   WaveFormat.nAvgBytesPerSec:=SampleRate*SizeOf(TpvInt16)*2;
   WaveFormat.nBlockAlign:=SizeOf(TpvInt16)*WaveFormat.nChannels;
   WaveFormat.wBitsPerSample:=SizeOf(TpvInt16)*8;
   WaveFormat.cbSize:=0;
   for BufferCounter:=0 to CountBuffers-1 do begin
    FillChar(WaveHandler[BufferCounter],SizeOf(TWAVEHDR),#0);
    WaveHandler[BufferCounter].dwBufferLength:=BufferSize*SizeOf(TpvInt16)*2;
    WaveHandler[BufferCounter].dwBytesRecorded:=0;
    WaveHandler[BufferCounter].dwUser:=0;
    WaveHandler[BufferCounter].dwFlags:=WHDR_DONE;
    WaveHandler[BufferCounter].dwLoops:=0;
    GetMem(WaveHandler[BufferCounter].lpData,WaveHandler[BufferCounter].dwBufferLength);
   end;
   try
    BufferCounter:=0;
    if waveOutOpen(@WaveOutHandle,WAVE_MAPPER,@WaveFormat,DWORD_PTR(fEvent),0,CALLBACK_EVENT)=MMSYSERR_NOERROR then begin
     try
      while not Terminated do begin
       for BufferCounter:=0 to CountBuffers-1 do begin
        if (WaveHandler[BufferCounter].dwFlags and WHDR_DONE)<>0 then begin
         if waveOutUnprepareHeader(WaveOutHandle,@WaveHandler[BufferCounter],SizeOf(TWAVEHDR))<>WAVERR_STILLPLAYING then begin
          WaveHandler[BufferCounter].dwFlags:=WaveHandler[BufferCounter].dwFlags and not WHDR_DONE;
          AudioFillBuffer(fAudio,WaveHandler[BufferCounter].lpData,WaveHandler[BufferCounter].dwBufferLength);
          waveOutPrepareHeader(WaveOutHandle,@WaveHandler[BufferCounter],SizeOf(TWAVEHDR));
          waveOutWrite(WaveOutHandle,@WaveHandler[BufferCounter],SizeOf(TWAVEHDR));
         end;
        end;
       end;
       WaitForSingleObject(fEvent,1000);
      end;
      for BufferCounter:=0 to CountBuffers-1 do begin
       if (WaveHandler[BufferCounter].dwFlags and WHDR_DONE)=0 then begin
        while waveOutUnprepareHeader(WaveOutHandle,@WaveHandler[BufferCounter],SizeOf(TWAVEHDR))=WAVERR_STILLPLAYING do begin
         sleep(1);
        end;
       end;
      end;
     finally
      waveOutReset(WaveOutHandle);
      waveOutClose(WaveOutHandle);
     end;
    end;
   finally
    for BufferCounter:=0 to CountBuffers-1 do begin
     if assigned(WaveHandler[BufferCounter].lpData) then begin
      FreeMem(WaveHandler[BufferCounter].lpData);
     end;
    end;
   end;
  finally
  end;
 end;
end;

{$ifend}

procedure TpvApplication.InitializeAudio;
{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
begin
{$if (defined(fpc) and defined(android)) and not defined(Release)}
 __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Entering TpvApplication.InitializeAudio . . .');
{$ifend}
 if fUseAudio and not assigned(fAudio) then begin
  FillChar(fSDLWaveFormat,SizeOf(TSDL_AudioSpec),#0);
  fSDLWaveFormat.Channels:=2;
  fSDLWaveFormat.Format:=AUDIO_S16;
  fSDLWaveFormat.Freq:=48000;
  fSDLWaveFormat.Callback:=@SDLFillBuffer;
  fSDLWaveFormat.silence:=0;
  fSDLWaveFormat.Samples:=512;
  fSDLWaveFormat.Size:=((fSDLWaveFormat.Samples*fSDLWaveFormat.Channels*(fSDLWaveFormat.Format and $ff))+7) shr 3;
  fAudio:=TpvAudio.Create(fSDLWaveFormat.Freq,
                          fSDLWaveFormat.Channels,
                          fSDLWaveFormat.Format and $ff,
                          fSDLWaveFormat.Samples);
  fAudio.SetMixerAGC(true);
  fAudio.UpdateHook:=UpdateAudioHook;
  fSDLWaveFormat.userdata:=fAudio;
  if SDL_OpenAudio(@fSDLWaveFormat,nil)<0 then begin
   raise EpvApplication.Create('SDL','Unable to initialize SDL audio: '+SDL_GetError,LOG_ERROR);
  end;
  SDL_PauseAudio(1);
 end;
{$if (defined(fpc) and defined(android)) and not defined(Release)}
 __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Leaving TpvApplication.InitializeAudio . . .');
{$ifend}
end;
{$elseif defined(Windows) and not defined(PasVulkanHeadless)}
begin
 if fUseAudio and not assigned(fAudio) then begin
  fAudio:=TpvAudio.Create(TpvWin32AudioThread.SampleRate,
                          TpvWin32AudioThread.Channels,
                          TpvWin32AudioThread.Bits,
                          TpvWin32AudioThread.BufferSize);
  fAudio.SetMixerAGC(true);
  fAudio.UpdateHook:=UpdateAudioHook;
  fWin32AudioThread:=TpvWin32AudioThread.Create(self,fAudio);
 end;
end;
{$else}
begin
 if fUseAudio and not assigned(fAudio) then begin
  Assert(false);
 end;
end;
{$ifend}

procedure TpvApplication.DeinitializeAudio;
{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
begin
{$if (defined(fpc) and defined(android)) and not defined(Release)}
 __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Entering TpvApplication.DeinitializeAudio . . .');
{$ifend}
 if assigned(fAudio) then begin
  SDL_CloseAudio;
  FreeAndNil(fAudio);
 end;
{$if (defined(fpc) and defined(android)) and not defined(Release)}
 __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Leaving TpvApplication.DeinitializeAudio . . .');
{$ifend}
end;
{$elseif defined(Windows) and not defined(PasVulkanHeadless)}
begin
 if assigned(fWin32AudioThread) then begin
  fWin32AudioThread.Terminate;
  fWin32AudioThread.WaitFor;
  FreeAndNil(fWin32AudioThread);
 end;
 if assigned(fAudio) then begin
  FreeAndNil(fAudio);
 end;
end;
{$else}
begin
 if assigned(fAudio) then begin
  FreeAndNil(fAudio);
 end;
end;
{$ifend}

procedure TpvApplication.UpdateFrameTimesHistory;
var Index:TpvSizeInt;
begin

 if fFloatDeltaTime>0.0 then begin

  while fFrameTimesHistoryCount>0 do begin
   Index:=((fFrameTimesHistoryIndex+FrameTimesHistorySize)-fFrameTimesHistoryCount) and FrameTimesHistoryMask;
   if abs(fNowTime-fFrameTimesHistoryTimePoints[Index])>=fHighResolutionTimer.SecondInterval then begin
    fFrameTimesHistorySum:=fFrameTimesHistorySum-fFrameTimesHistoryDeltaTimes[Index];
    fFrameTimesHistoryDeltaTimes[Index]:=0.0;
    fFrameTimesHistoryTimePoints[Index]:=0;
    dec(fFrameTimesHistoryCount);
   end else begin
    break;
   end;
  end;

  if fFrameTimesHistoryCount<FrameTimesHistorySize then begin
   inc(fFrameTimesHistoryCount);
  end else begin
   fFrameTimesHistorySum:=fFrameTimesHistorySum-fFrameTimesHistoryDeltaTimes[fFrameTimesHistoryIndex];
  end;
  fFrameTimesHistorySum:=fFrameTimesHistorySum+fFloatDeltaTime;
  fFrameTimesHistoryDeltaTimes[fFrameTimesHistoryIndex]:=fFloatDeltaTime;
  fFrameTimesHistoryTimePoints[fFrameTimesHistoryIndex]:=fNowTime;

  fFrameTimesHistoryIndex:=(fFrameTimesHistoryIndex+1) and FrameTimesHistoryMask;

 end;

 if (fFrameTimesHistoryCount>0) and (fFrameTimesHistorySum>0.0) then begin
  fFramesPerSecond:=fFrameTimesHistoryCount/fFrameTimesHistorySum;
 end else if fFloatDeltaTime>0.0 then begin
  fFramesPerSecond:=1.0/fFloatDeltaTime;
 end else begin
  fFramesPerSecond:=0.0;
 end;

end;

function TpvApplicationGetPercentile95thFrameTimeCompare(const a,b:TpvDouble):TpvInt32;
begin
 result:=Sign(a-b);
end;

function TpvApplication.GetPercentileXthFrameTime(const aPercentileXth:TpvDouble):TpvDouble;
var FrameTimes:TpvDoubleDynamicArray;
    Index,Count:TpvSizeInt;
    TotalTimeTaken,DestinationAccumulatedTime,Sample,Factor:TpvDouble;
begin

 // Don't solely rely on the count of samples. Factor in the total time consumed (which favors
 // bigger samples). Here's an illustrative case with 95th percentile:
 // If a game operates at 60 fps for 1 hour and then takes the next hour to render one frame,
 // Using only the sample count would suggest 60 fps / 16.67mspf.
 // But in reality, the user experienced 1 hour at 60 fps and another hour at 0.000277778 fps.
 // The accurate 95-p is 0.000277778 fps (3600000 mspf), not 60 fps.

 result:=0.0;

 Count:=fFrameTimesHistoryCount;

 if Count>0 then begin

  FrameTimes:=nil;
  try

   SetLength(FrameTimes,Count);

   for Index:=0 to Count-1 do begin
    FrameTimes[Index]:=fFrameTimesHistoryDeltaTimes[((fFrameTimesHistoryIndex+FrameTimesHistorySize)-(Index+1)) and FrameTimesHistoryMask];
   end;

   if Count>1 then begin
    TpvTypedSort<TpvDouble>.IntroSort(@FrameTimes[0],0,Count-1,TpvApplicationGetPercentile95thFrameTimeCompare);
   end;

   TotalTimeTaken:=0.0;
   for Index:=0 to Count-1 do begin
    TotalTimeTaken:=TotalTimeTaken+FrameTimes[Index];
   end;

   Factor:=aPercentileXth*0.01;
   if Factor<=0.0 then begin
    Factor:=0.0;
   end else if Factor>=1.0 then begin
    Factor:=1.0;
   end;

   DestinationAccumulatedTime:=TotalTimeTaken*Factor;

   result:=FrameTimes[Count-1]; // default to the slowest frame time

   TotalTimeTaken:=0.0;
   for Index:=0 to Count-1 do begin
    Sample:=FrameTimes[Index];
    TotalTimeTaken:=TotalTimeTaken+Sample;
    if TotalTimeTaken>=DestinationAccumulatedTime then begin
     result:=Sample;
     break;
    end;
   end;

  finally
   FrameTimes:=nil;
  end;

 end;

end;

function TpvApplication.GetMedianFrameTime(const aTime:TpvDouble):TpvDouble;
var FrameTimes:TpvDoubleDynamicArray;
    Index,Count:TpvSizeInt;
    Sum:TpvDouble;
begin

 result:=0.0;

 // Don't solely rely on the count of samples. Median is a better measure of central tendency
 // than the mean (average) for frame times, as it is less sensitive to outliers.

 if fFrameTimesHistoryCount>0 then begin

  FrameTimes:=nil;
  try

   // Count the number of frame times to use, based on the time
   Count:=0;
   Sum:=0.0;
   for Index:=0 to fFrameTimesHistoryCount-1 do begin
    Sum:=Sum+fFrameTimesHistoryDeltaTimes[((fFrameTimesHistoryIndex+FrameTimesHistorySize)-(Index+1)) and FrameTimesHistoryMask];
    if Sum<=aTime then begin
     inc(Count);
    end else begin
     break;
    end;
   end;

   if Count>0 then begin

    SetLength(FrameTimes,Count);

    for Index:=0 to Count-1 do begin
     FrameTimes[Index]:=fFrameTimesHistoryDeltaTimes[((fFrameTimesHistoryIndex+FrameTimesHistorySize)-(Index+1)) and FrameTimesHistoryMask];
    end;

    if Count>1 then begin
     TpvTypedSort<TpvDouble>.IntroSort(@FrameTimes[0],0,length(FrameTimes)-1,TpvApplicationGetPercentile95thFrameTimeCompare);
    end;

    if (Count and 1)=0 then begin
     result:=(FrameTimes[Count shr 1]+FrameTimes[(Count shr 1)-1])*0.5;
    end else begin
     result:=FrameTimes[Count shr 1];
    end;

   end else begin

    result:=fFrameTimesHistoryDeltaTimes[((fFrameTimesHistoryIndex+FrameTimesHistorySize)-1) and FrameTimesHistoryMask];

   end;

  finally
   FrameTimes:=nil;
  end;

 end;

end;

procedure TpvApplication.FramePacingAndFrameRateLimiter;
var LastTime,NowTime,FrameTime,TargetInterval,SleepDuration,
    LateAmount,Skipped:TpvHighResolutionTime;
begin

 // VRR + low latency: when VRR display is detected and low latency mode is active,
 // skip CPU-side frame pacing to let the display adapt to the application frame rate
 if fLowLatencyActive and
    (fPresentTimingFeedbackRefreshMode=TpvApplicationPresentTimingFeedbackRefreshMode.VRR) and
    (not ((fMaximumFramesPerSecond>0.0) and not IsZero(fMaximumFramesPerSecond))) then begin
  fFrameRateLimiterDeviation:=0;
  fFramePacingNextPresentTarget:=0;
  exit;
 end;

 // VulkanPresentTimingFeedback mode: GPU feedback loop handles pacing, skip CPU-side throttling
 if (fFramePacingMode=TpvApplicationFramePacingMode.VulkanPresentTimingFeedback) and
    (not ((fMaximumFramesPerSecond>0.0) and not IsZero(fMaximumFramesPerSecond))) then begin
  fFrameRateLimiterDeviation:=0;
  fFramePacingNextPresentTarget:=0;
  exit;
 end;

 if fFrameRateLimiterLastTime=0 then begin
  fFrameRateLimiterLastTime:=fHighResolutionTimer.GetTime; // Initialize first last time
 end;

 LastTime:=fFrameRateLimiterLastTime;
 NowTime:=fHighResolutionTimer.GetTime;

 // Calculate frame time
 FrameTime:=NowTime-LastTime;

 // Determine target interval: FPS limiter takes priority, then frame pacing,
 // otherwise no throttling. Both use the same reactive sleep-at-frame-end
 // mechanism for stable DeltaTime.

 if (fMaximumFramesPerSecond>0.0) and not IsZero(fMaximumFramesPerSecond) then begin

  // If the frame limiter is enabled, do our magic here. :-)

  // Calculate the target time interval based on the maximum frames per second value.
  TargetInterval:=fHighResolutionTimer.FromFloatSeconds(1.0/fMaximumFramesPerSecond);

 end else if fFramePacingEffectiveInterval>0 then begin

  TargetInterval:=fFramePacingEffectiveInterval;

 end else begin

  TargetInterval:=0;

 end;

 if (fFramePacingStrategy=TpvApplicationFramePacingStrategy.AbsoluteTimeRaster) and (TargetInterval>0) then begin

  // Absolute time raster pacing: advance a fixed deadline by the target interval each frame,
  // sleep until the deadline, and skip missed slots on slow frames. This provides a stable
  // long-term frame cadence without cumulative drift.

  // Initialize the deadline on first use or after a reset (e.g. swapchain recreate).
  if fFramePacingNextPresentTarget=0 then begin
   fFramePacingNextPresentTarget:=NowTime+TargetInterval;
  end else begin
   // Advance the deadline by one interval for the just-finished frame.
   fFramePacingNextPresentTarget:=fFramePacingNextPresentTarget+TargetInterval;
  end;

  if NowTime<fFramePacingNextPresentTarget then begin

   // Frame finished early => sleep until the absolute deadline.
   fFramePacingSleepWithDriftCompensation.Sleep(fFramePacingNextPresentTarget-NowTime);
   NowTime:=fHighResolutionTimer.GetTime;

  end else begin

   // Frame finished late => skip missed deadline slots so we do not accumulate
   // an ever-growing delay or burst of short-sleeping catch-up frames.
   LateAmount:=NowTime-fFramePacingNextPresentTarget;
   Skipped:=(LateAmount div TargetInterval)+1;
   fFramePacingNextPresentTarget:=fFramePacingNextPresentTarget+(Skipped*TargetInterval);

  end;

  // Reset deviation-based state since it is not used in this mode.
  fFrameRateLimiterDeviation:=0;

 end else if TargetInterval>0 then begin

  // Reactive deviation-compensated pacing (original behavior for all other modes).

  // Check if the deviation should be reset to zero, for example, if a slow frame was present.
  if (FrameTime*100)>((TargetInterval*103)-(fFrameRateLimiterDeviation*100)) then begin

   // So for example, if a slow frame was present, the deviation should be reset to zero, as
   // the low performance should not be compensated for later.
   fFrameRateLimiterDeviation:=0;

  end else begin

   SleepDuration:=TargetInterval-(FrameTime+fFrameRateLimiterDeviation);

   // The sleep function should not be called if the time required to sleep is shorter than the time
   // the function calls are likely to take.
   if SleepDuration>0 then begin
    NowTime:=fFrameLimiterHighResolutionTimerSleepWithDriftCompensation.Sleep(SleepDuration);
   end;

   // Calculate new frame time
   FrameTime:=NowTime-LastTime;

   // Any inaccuracies during sleep should be compensated for in the next frame, however the cumulative
   // deviation should be limited to avoid stuttering if a series of slow frames is followed by a fast frame.
   fFrameRateLimiterDeviation:=Min(TargetInterval shr 4,fFrameRateLimiterDeviation+(FrameTime-TargetInterval));

  end;

  // Reset absolute raster state since it is not used in this mode.
  fFramePacingNextPresentTarget:=0;

 end else begin

  // No frame limiter and no frame pacing => Do not sleep at all
  fFrameRateLimiterDeviation:=0;
  fFramePacingNextPresentTarget:=0;

 end;

 fFrameRateLimiterLastTime:=NowTime;

end;

{procedure TpvApplication.FramePacingAndFrameRateLimiter;
var NowTime,Interval:TpvHighResolutionTime;
begin
 NowTime:=fHighResolutionTimer.GetTime;
 if (fMaximumFramesPerSecond>0.0) and not IsZero(fMaximumFramesPerSecond) then begin
  if (NowTime<fNextTime) and
     (fNextTime<=(NowTime+fHighResolutionTimer.SecondInterval)) then begin
   fFrameLimiterHighResolutionTimerSleepWithDriftCompensation.Sleep(fNextTime-NowTime);
  end;
  Interval:=fHighResolutionTimer.FromFloatSeconds(1.0/fMaximumFramesPerSecond);
  if (fNextTime=0) or (fNextTime>=(NowTime+Interval)) then begin
   fNextTime:=NowTime+Interval;
   NowTime:=fHighResolutionTimer.GetTime;
   if fNextTime>=(NowTime+Interval) then begin
    fNextTime:=NowTime+Interval;
   end;
  end else begin
   fNextTime:=fNextTime+Interval;
  end;
 end else begin
  if NowTime>0 then begin
   fNextTime:=NowTime-1;
  end else begin
   fNextTime:=0;
  end;
 end;
end;}

procedure TpvApplication.PollPresentTimingFeedback;
var PastTimingInfo:TVkPastPresentationTimingInfoEXT;
    PastTimingProperties:TVkPastPresentationTimingPropertiesEXT;
    PastTimings:array[0..15] of TVkPastPresentationTimingEXT;
    Index:TpvInt32;
    ActualTime,ErrorTime:TpvInt64;
begin
 if (not assigned(fVulkanDevice)) or
    (not fVulkanDevice.PresentTimingSupport) or
    (not assigned(fVulkanDevice.Commands.Commands.GetPastPresentationTimingEXT)) or
    (not assigned(fVulkanSwapChain)) then begin
  exit;
 end;
 FillChar(PastTimingInfo,SizeOf(TVkPastPresentationTimingInfoEXT),#0);
 PastTimingInfo.sType:=VK_STRUCTURE_TYPE_PAST_PRESENTATION_TIMING_INFO_EXT;
 PastTimingInfo.swapchain:=fVulkanSwapChain.Handle;
 for Index:=0 to 15 do begin
  FillChar(PastTimings[Index],SizeOf(TVkPastPresentationTimingEXT),#0);
  PastTimings[Index].sType:=VK_STRUCTURE_TYPE_PAST_PRESENTATION_TIMING_EXT;
  PastTimings[Index].presentStageCount:=0;
  PastTimings[Index].pPresentStages:=nil;
 end;
 FillChar(PastTimingProperties,SizeOf(TVkPastPresentationTimingPropertiesEXT),#0);
 PastTimingProperties.sType:=VK_STRUCTURE_TYPE_PAST_PRESENTATION_TIMING_PROPERTIES_EXT;
 PastTimingProperties.presentationTimingCount:=16;
 PastTimingProperties.pPresentationTimings:=@PastTimings[0];
 try
  if fVulkanDevice.Commands.GetPastPresentationTimingEXT(fVulkanDevice.Handle,
                                                         @PastTimingInfo,
                                                         @PastTimingProperties)=VK_SUCCESS then begin
   for Index:=0 to TpvInt32(PastTimingProperties.presentationTimingCount)-1 do begin
    if (PastTimings[Index].reportComplete<>VK_FALSE) and
       (PastTimings[Index].presentId>fPresentTimingFeedbackLastPollPresentID) then begin
     fPresentTimingFeedbackLastPollPresentID:=PastTimings[Index].presentId;
     if (PastTimings[Index].targetTime>0) and (fPresentTimingFeedbackLastTargetTime>0) then begin
      ActualTime:=TpvInt64(PastTimings[Index].targetTime);
      ErrorTime:=ActualTime-TpvInt64(fPresentTimingFeedbackLastTargetTime);
      fPresentTimingFeedbackErrorRingValues[fPresentTimingFeedbackErrorRingIndex]:=ErrorTime;
      fPresentTimingFeedbackErrorRingIndex:=(fPresentTimingFeedbackErrorRingIndex+1) and 15;
      if fPresentTimingFeedbackErrorRingCount<16 then begin
       inc(fPresentTimingFeedbackErrorRingCount);
      end;
      fPresentTimingFeedbackPresentationTimeError:=ErrorTime;
     end;
    end;
   end;
   if PastTimingProperties.timingPropertiesCounter>fPresentTimingFeedbackRefreshCounter then begin
    fPresentTimingFeedbackRefreshCounter:=PastTimingProperties.timingPropertiesCounter;
    UpdatePresentTimingFeedbackProperties;
   end;
   if PastTimingProperties.timeDomainsCounter>0 then begin
    fPresentTimingFeedbackNeedRecalibration:=true;
   end;
   // Periodic recalibration every ~1 second
   if fHighResolutionTimer.GetTime>fPresentTimingFeedbackLastRecalibrationTime+fHighResolutionTimer.SecondInterval then begin
    fPresentTimingFeedbackNeedRecalibration:=true;
   end;
  end;
 except
 end;
end;

procedure TpvApplication.RecalibratePresentTimingDomains;
var TimestampInfos:array[0..1] of TVkCalibratedTimestampInfoKHR;
    SwapchainCalibratedInfo:TVkSwapchainCalibratedTimestampInfoEXT;
    Timestamps:array[0..1] of TpvUInt64;
    MaxDeviation:TpvUInt64;
    ActiveDomain:TVkTimeDomainKHR;
    Count:TpvUInt32;
begin
 if (not assigned(fVulkanDevice)) or
    (not fVulkanDevice.CalibratedTimestampsSupport) then begin
  exit;
 end;
 // Determine the active present timing domain type
 ActiveDomain:=VK_TIME_DOMAIN_CLOCK_MONOTONIC_RAW_KHR;
 if fPresentTimingFeedbackTimeDomainCount>0 then begin
  ActiveDomain:=fPresentTimingFeedbackTimeDomains[0];
 end;
 FillChar(TimestampInfos,SizeOf(TimestampInfos),#0);
 FillChar(Timestamps,SizeOf(Timestamps),#0);
 FillChar(SwapchainCalibratedInfo,SizeOf(SwapchainCalibratedInfo),#0);
 // infos[0] = host domain (CLOCK_MONOTONIC_RAW)
 TimestampInfos[0].sType:=VK_STRUCTURE_TYPE_CALIBRATED_TIMESTAMP_INFO_KHR;
 TimestampInfos[0].timeDomain:=VK_TIME_DOMAIN_CLOCK_MONOTONIC_RAW_KHR;
 MaxDeviation:=0;
 if (ActiveDomain=TVkTimeDomainKHR(VK_TIME_DOMAIN_SWAPCHAIN_LOCAL_EXT)) and
    assigned(fVulkanSwapChain) then begin
  // 2-entry query: host + swapchain domain simultaneously
  TimestampInfos[1].sType:=VK_STRUCTURE_TYPE_CALIBRATED_TIMESTAMP_INFO_KHR;
  TimestampInfos[1].timeDomain:=TVkTimeDomainKHR(VK_TIME_DOMAIN_SWAPCHAIN_LOCAL_EXT);
  SwapchainCalibratedInfo.sType:=VK_STRUCTURE_TYPE_SWAPCHAIN_CALIBRATED_TIMESTAMP_INFO_EXT;
  SwapchainCalibratedInfo.pNext:=nil;
  SwapchainCalibratedInfo.swapchain:=fVulkanSwapChain.Handle;
  SwapchainCalibratedInfo.presentStage:=0;
  SwapchainCalibratedInfo.timeDomainId:=fPresentTimingFeedbackActiveTimeDomainID;
  TimestampInfos[1].pNext:=@SwapchainCalibratedInfo;
  Count:=2;
 end else begin
  Count:=1;
 end;
 try
  if assigned(fVulkanDevice.Commands.Commands.GetCalibratedTimestampsKHR) then begin
   if fVulkanDevice.Commands.GetCalibratedTimestampsKHR(fVulkanDevice.Handle,
                                                        Count,
                                                        @TimestampInfos[0],
                                                        @Timestamps[0],
                                                        @MaxDeviation)=VK_SUCCESS then begin
    fPresentTimingFeedbackCalibratedHostTime:=Timestamps[0];
    if Count>1 then begin
     fPresentTimingFeedbackCalibratedStageTime:=Timestamps[1];
    end else begin
     // Same domain as host: identity calibration
     fPresentTimingFeedbackCalibratedStageTime:=Timestamps[0];
    end;
    fPresentTimingFeedbackNeedRecalibration:=false;
    fPresentTimingFeedbackLastRecalibrationTime:=fHighResolutionTimer.GetTime;
   end;
  end else if assigned(fVulkanDevice.Commands.Commands.GetCalibratedTimestampsEXT) then begin
   if fVulkanDevice.Commands.GetCalibratedTimestampsEXT(fVulkanDevice.Handle,
                                                        Count,
                                                        @TimestampInfos[0],
                                                        @Timestamps[0],
                                                        @MaxDeviation)=VK_SUCCESS then begin
    fPresentTimingFeedbackCalibratedHostTime:=Timestamps[0];
    if Count>1 then begin
     fPresentTimingFeedbackCalibratedStageTime:=Timestamps[1];
    end else begin
     // Same domain as host: identity calibration
     fPresentTimingFeedbackCalibratedStageTime:=Timestamps[0];
    end;
    fPresentTimingFeedbackNeedRecalibration:=false;
    fPresentTimingFeedbackLastRecalibrationTime:=fHighResolutionTimer.GetTime;
   end;
  end;
 except
 end;
end;

procedure TpvApplication.UpdatePresentTimingFeedbackProperties;
var SwapchainTimingProperties:TVkSwapchainTimingPropertiesEXT;
    SwapchainTimingPropertiesCounter:TpvUInt64;
begin
 if (not assigned(fVulkanDevice)) or
    (not fVulkanDevice.PresentTimingSupport) or
    (not assigned(fVulkanDevice.Commands.Commands.GetSwapchainTimingPropertiesEXT)) or
    (not assigned(fVulkanSwapChain)) then begin
  exit;
 end;
 FillChar(SwapchainTimingProperties,SizeOf(TVkSwapchainTimingPropertiesEXT),#0);
 SwapchainTimingProperties.sType:=VK_STRUCTURE_TYPE_SWAPCHAIN_TIMING_PROPERTIES_EXT;
 SwapchainTimingPropertiesCounter:=0;
 try
  if fVulkanDevice.Commands.GetSwapchainTimingPropertiesEXT(fVulkanDevice.Handle,
                                                            fVulkanSwapChain.Handle,
                                                            @SwapchainTimingProperties,
                                                            @SwapchainTimingPropertiesCounter)=VK_SUCCESS then begin
   fPresentTimingFeedbackRefreshDuration:=SwapchainTimingProperties.refreshDuration;
   fPresentTimingFeedbackRefreshInterval:=SwapchainTimingProperties.refreshInterval;
   if SwapchainTimingProperties.refreshInterval=TpvUInt64($ffffffffffffffff) then begin
    fPresentTimingFeedbackRefreshMode:=TpvApplicationPresentTimingFeedbackRefreshMode.VRR;
   end else if SwapchainTimingProperties.refreshInterval>0 then begin
    fPresentTimingFeedbackRefreshMode:=TpvApplicationPresentTimingFeedbackRefreshMode.FRR;
   end else begin
    fPresentTimingFeedbackRefreshMode:=TpvApplicationPresentTimingFeedbackRefreshMode.Unknown;
   end;
   fPresentTimingFeedbackHasRefreshFeedback:=true;
  end;
 except
 end;
end;

procedure TpvApplication.ComputePresentTimingTarget(var aTimingInfo:TVkPresentTimingInfoEXT);
var NowTime,TargetTime,CompensationTime:TpvUInt64;
    MeanError:TpvInt64;
    Index:TpvInt32;
begin
 FillChar(aTimingInfo,SizeOf(TVkPresentTimingInfoEXT),#0);
 aTimingInfo.sType:=VK_STRUCTURE_TYPE_PRESENT_TIMING_INFO_EXT;
 aTimingInfo.timeDomainID:=fPresentTimingFeedbackActiveTimeDomainID;
 aTimingInfo.presentStageQueries:=0;
 aTimingInfo.targetTimeDomainPresentStage:=0;
 if (not fPresentTimingFeedbackHasRefreshFeedback) or
    (fPresentTimingFeedbackRefreshDuration=0) then begin
  aTimingInfo.flags:=TVkPresentTimingInfoFlagsEXT(VK_PRESENT_TIMING_INFO_PRESENT_AT_NEAREST_REFRESH_CYCLE_BIT_EXT);
  aTimingInfo.targetTime:=0;
  exit;
 end;
 MeanError:=0;
 if fPresentTimingFeedbackErrorRingCount>0 then begin
  for Index:=0 to fPresentTimingFeedbackErrorRingCount-1 do begin
   MeanError:=MeanError+fPresentTimingFeedbackErrorRingValues[Index];
  end;
  MeanError:=MeanError div fPresentTimingFeedbackErrorRingCount;
 end;
 CompensationTime:=0;
 if MeanError>0 then begin
  CompensationTime:=TpvUInt64(MeanError shr 2);
 end;
 if fPresentTimingFeedbackRefreshMode=TpvApplicationPresentTimingFeedbackRefreshMode.VRR then begin
  aTimingInfo.flags:=TVkPresentTimingInfoFlagsEXT(VK_PRESENT_TIMING_INFO_PRESENT_AT_RELATIVE_TIME_BIT_EXT);
  TargetTime:=fPresentTimingFeedbackRefreshDuration;
  if TargetTime>CompensationTime then begin
   TargetTime:=TargetTime-CompensationTime;
  end;
  aTimingInfo.targetTime:=TargetTime;
 end else begin
  NowTime:=fHighResolutionTimer.ToNanoseconds(fHighResolutionTimer.GetTime);
  TargetTime:=NowTime+fPresentTimingFeedbackRefreshDuration;
  if fPresentTimingFeedbackRefreshInterval>0 then begin
   TargetTime:=(((TargetTime+fPresentTimingFeedbackRefreshInterval)-1) div fPresentTimingFeedbackRefreshInterval)*fPresentTimingFeedbackRefreshInterval;
  end;
  if TargetTime>CompensationTime then begin
   TargetTime:=TargetTime-CompensationTime;
  end;
  // Convert from host time domain to swapchain time domain using calibration offset
  if (fPresentTimingFeedbackCalibratedHostTime>0) and
     (fPresentTimingFeedbackCalibratedStageTime>0) and
     (fPresentTimingFeedbackCalibratedHostTime<>fPresentTimingFeedbackCalibratedStageTime) then begin
   TargetTime:=TpvUInt64(TpvInt64(TargetTime)+TpvInt64(fPresentTimingFeedbackCalibratedStageTime)-TpvInt64(fPresentTimingFeedbackCalibratedHostTime));
  end;
  aTimingInfo.flags:=0;
  aTimingInfo.targetTime:=TargetTime;
 end;
 fPresentTimingFeedbackLastTargetTime:=aTimingInfo.targetTime;
end;

procedure TpvApplication.InitializeLowLatencyMode;
var LatencySleepModeInfo:TVkLatencySleepModeInfoNV;
    AntiLagData:TVkAntiLagDataAMD;
begin
 fLowLatencyActive:=false;
 fLowLatencyActiveMode:=TpvApplicationLowLatencyMode.None;
 if not assigned(fVulkanDevice) then begin
  exit;
 end;
 case fLowLatencyMode of
  TpvApplicationLowLatencyMode.NVReflex:begin
   if fVulkanDevice.LowLatency2Support and
      assigned(fVulkanDevice.Commands.Commands.SetLatencySleepModeNV) and
      assigned(fVulkanSwapChain) then begin
    FillChar(LatencySleepModeInfo,SizeOf(TVkLatencySleepModeInfoNV),#0);
    LatencySleepModeInfo.sType:=VK_STRUCTURE_TYPE_LATENCY_SLEEP_MODE_INFO_NV;
    LatencySleepModeInfo.lowLatencyMode:=VK_TRUE;
    LatencySleepModeInfo.lowLatencyBoost:=VK_FALSE;
    LatencySleepModeInfo.minimumIntervalUs:=0;
    try
     if fVulkanDevice.Commands.SetLatencySleepModeNV(fVulkanDevice.Handle,
                                                     fVulkanSwapChain.Handle,
                                                     @LatencySleepModeInfo)=VK_SUCCESS then begin
      fLowLatencyActive:=true;
      Log(LOG_INFO,'TpvApplication.InitializeLowLatencyMode','NV Reflex low latency mode activated');
       fLowLatencyActiveMode:=TpvApplicationLowLatencyMode.NVReflex;
      fLowLatencySleepSemaphore:=TpvVulkanTimelineSemaphore.Create(fVulkanDevice,0);
      fLowLatencyFrameID:=0;
     end;
    except
    end;
   end;
  end;
  TpvApplicationLowLatencyMode.AMDAntiLag:begin
   if fVulkanDevice.AntiLagSupport and
      assigned(fVulkanDevice.Commands.Commands.AntiLagUpdateAMD) then begin
     FillChar(AntiLagData,SizeOf(TVkAntiLagDataAMD),#0);
     AntiLagData.sType:=VK_STRUCTURE_TYPE_ANTI_LAG_DATA_AMD;
     AntiLagData.mode:=VK_ANTI_LAG_MODE_ON_AMD;
     AntiLagData.maxFPS:=0;
     AntiLagData.pPresentationInfo:=nil;
     try
      fVulkanDevice.Commands.AntiLagUpdateAMD(fVulkanDevice.Handle,@AntiLagData);
      fLowLatencyActive:=true;
      fLowLatencyActiveMode:=TpvApplicationLowLatencyMode.AMDAntiLag;
      Log(LOG_INFO,'TpvApplication.InitializeLowLatencyMode','AMD Anti-Lag mode activated');
     except
     end;
   end;
  end;
  TpvApplicationLowLatencyMode.Auto:begin
   if fVulkanDevice.LowLatency2Support and
      assigned(fVulkanDevice.Commands.Commands.SetLatencySleepModeNV) and
      assigned(fVulkanSwapChain) then begin
    FillChar(LatencySleepModeInfo,SizeOf(TVkLatencySleepModeInfoNV),#0);
    LatencySleepModeInfo.sType:=VK_STRUCTURE_TYPE_LATENCY_SLEEP_MODE_INFO_NV;
    LatencySleepModeInfo.lowLatencyMode:=VK_TRUE;
    LatencySleepModeInfo.lowLatencyBoost:=VK_FALSE;
    LatencySleepModeInfo.minimumIntervalUs:=0;
    try
     if fVulkanDevice.Commands.SetLatencySleepModeNV(fVulkanDevice.Handle,
                                                     fVulkanSwapChain.Handle,
                                                     @LatencySleepModeInfo)=VK_SUCCESS then begin
      fLowLatencyActive:=true;
      Log(LOG_INFO,'TpvApplication.InitializeLowLatencyMode','NV Reflex low latency mode activated (auto)');
      fLowLatencyActiveMode:=TpvApplicationLowLatencyMode.NVReflex;
      fLowLatencySleepSemaphore:=TpvVulkanTimelineSemaphore.Create(fVulkanDevice,0);
      fLowLatencyFrameID:=0;
     end;
    except
    end;
   end else if fVulkanDevice.AntiLagSupport and
               assigned(fVulkanDevice.Commands.Commands.AntiLagUpdateAMD) then begin
    FillChar(AntiLagData,SizeOf(TVkAntiLagDataAMD),#0);
    AntiLagData.sType:=VK_STRUCTURE_TYPE_ANTI_LAG_DATA_AMD;
    AntiLagData.mode:=VK_ANTI_LAG_MODE_ON_AMD;
    AntiLagData.maxFPS:=0;
    AntiLagData.pPresentationInfo:=nil;
    try
     fVulkanDevice.Commands.AntiLagUpdateAMD(fVulkanDevice.Handle,@AntiLagData);
     fLowLatencyActive:=true;
     fLowLatencyActiveMode:=TpvApplicationLowLatencyMode.AMDAntiLag;
     Log(LOG_INFO,'TpvApplication.InitializeLowLatencyMode','AMD Anti-Lag mode activated (auto)');
    except
    end;
   end;
  end;
 end;
end;

procedure TpvApplication.ShutdownLowLatencyMode;
var LatencySleepModeInfo:TVkLatencySleepModeInfoNV;
    AntiLagData:TVkAntiLagDataAMD;
begin
 if fLowLatencyActive and assigned(fVulkanDevice) then begin
  case fLowLatencyActiveMode of
   TpvApplicationLowLatencyMode.NVReflex:begin
    if fVulkanDevice.LowLatency2Support and
       assigned(fVulkanDevice.Commands.Commands.SetLatencySleepModeNV) and
       assigned(fVulkanSwapChain) then begin
     FillChar(LatencySleepModeInfo,SizeOf(TVkLatencySleepModeInfoNV),#0);
     LatencySleepModeInfo.sType:=VK_STRUCTURE_TYPE_LATENCY_SLEEP_MODE_INFO_NV;
     LatencySleepModeInfo.lowLatencyMode:=VK_FALSE;
     LatencySleepModeInfo.lowLatencyBoost:=VK_FALSE;
     LatencySleepModeInfo.minimumIntervalUs:=0;
     try
      fVulkanDevice.Commands.SetLatencySleepModeNV(fVulkanDevice.Handle,
                                                   fVulkanSwapChain.Handle,
                                                   @LatencySleepModeInfo);
     except
     end;
    end;
    FreeAndNil(fLowLatencySleepSemaphore);
   end;
   TpvApplicationLowLatencyMode.AMDAntiLag:begin
    if fVulkanDevice.AntiLagSupport and
       assigned(fVulkanDevice.Commands.Commands.AntiLagUpdateAMD) then begin
     FillChar(AntiLagData,SizeOf(TVkAntiLagDataAMD),#0);
     AntiLagData.sType:=VK_STRUCTURE_TYPE_ANTI_LAG_DATA_AMD;
     AntiLagData.mode:=VK_ANTI_LAG_MODE_OFF_AMD;
     AntiLagData.maxFPS:=0;
     AntiLagData.pPresentationInfo:=nil;
     try
      fVulkanDevice.Commands.AntiLagUpdateAMD(fVulkanDevice.Handle,@AntiLagData);
     except
     end;
    end;
   end;
  end;
  fLowLatencyActiveMode:=TpvApplicationLowLatencyMode.None;
  fLowLatencyActive:=false;
 end;
end;


procedure TpvApplication.SetLowLatencyMarker(const aMarker:TVkLatencyMarkerNV);
var MarkerInfo:TVkSetLatencyMarkerInfoNV;
    AntiLagData:TVkAntiLagDataAMD;
    AntiLagPresInfo:TVkAntiLagPresentationInfoAMD;
begin
 if fLowLatencyActive and assigned(fVulkanDevice) then begin
  case fLowLatencyActiveMode of
   TpvApplicationLowLatencyMode.NVReflex:begin
    if fVulkanDevice.LowLatency2Support and
       assigned(fVulkanDevice.Commands.Commands.SetLatencyMarkerNV) and
       assigned(fVulkanSwapChain) then begin
     FillChar(MarkerInfo,SizeOf(TVkSetLatencyMarkerInfoNV),#0);
     MarkerInfo.sType:=VK_STRUCTURE_TYPE_SET_LATENCY_MARKER_INFO_NV;
     MarkerInfo.presentID:=fVulkanPresentID;
     MarkerInfo.marker:=aMarker;
     fVulkanDevice.Commands.SetLatencyMarkerNV(fVulkanDevice.Handle,
                                               fVulkanSwapChain.Handle,
                                               @MarkerInfo);
    end;
   end;
   TpvApplicationLowLatencyMode.AMDAntiLag:begin
    if fVulkanDevice.AntiLagSupport and
       assigned(fVulkanDevice.Commands.Commands.AntiLagUpdateAMD) then begin
     if aMarker=VK_LATENCY_MARKER_INPUT_SAMPLE_NV then begin
      FillChar(AntiLagPresInfo,SizeOf(TVkAntiLagPresentationInfoAMD),#0);
      AntiLagPresInfo.sType:=VK_STRUCTURE_TYPE_ANTI_LAG_PRESENTATION_INFO_AMD;
      AntiLagPresInfo.stage:=VK_ANTI_LAG_STAGE_INPUT_AMD;
      AntiLagPresInfo.frameIndex:=fFrameCounter;
      FillChar(AntiLagData,SizeOf(TVkAntiLagDataAMD),#0);
      AntiLagData.sType:=VK_STRUCTURE_TYPE_ANTI_LAG_DATA_AMD;
      AntiLagData.mode:=VK_ANTI_LAG_MODE_ON_AMD;
      AntiLagData.maxFPS:=0;
      AntiLagData.pPresentationInfo:=@AntiLagPresInfo;
      fVulkanDevice.Commands.AntiLagUpdateAMD(fVulkanDevice.Handle,@AntiLagData);
     end else if aMarker=VK_LATENCY_MARKER_PRESENT_START_NV then begin
      FillChar(AntiLagPresInfo,SizeOf(TVkAntiLagPresentationInfoAMD),#0);
      AntiLagPresInfo.sType:=VK_STRUCTURE_TYPE_ANTI_LAG_PRESENTATION_INFO_AMD;
      AntiLagPresInfo.stage:=VK_ANTI_LAG_STAGE_PRESENT_AMD;
      AntiLagPresInfo.frameIndex:=fFrameCounter;
      FillChar(AntiLagData,SizeOf(TVkAntiLagDataAMD),#0);
      AntiLagData.sType:=VK_STRUCTURE_TYPE_ANTI_LAG_DATA_AMD;
      AntiLagData.mode:=VK_ANTI_LAG_MODE_ON_AMD;
      AntiLagData.maxFPS:=0;
      AntiLagData.pPresentationInfo:=@AntiLagPresInfo;
      fVulkanDevice.Commands.AntiLagUpdateAMD(fVulkanDevice.Handle,@AntiLagData);
     end;
    end;
   end;
  end;
 end;
end;

procedure TpvApplication.LowLatencySleep;
var SleepInfo:TVkLatencySleepInfoNV;
begin
 if fLowLatencyActive and
    assigned(fVulkanDevice) and
    fVulkanDevice.LowLatency2Support and
    assigned(fVulkanDevice.Commands.Commands.LatencySleepNV) and
    assigned(fVulkanSwapChain) and
    assigned(fLowLatencySleepSemaphore) then begin
  inc(fLowLatencyFrameID);
  FillChar(SleepInfo,SizeOf(TVkLatencySleepInfoNV),#0);
  SleepInfo.sType:=VK_STRUCTURE_TYPE_LATENCY_SLEEP_INFO_NV;
  SleepInfo.signalSemaphore:=fLowLatencySleepSemaphore.Handle;
  SleepInfo.value:=fLowLatencyFrameID;
  try
   if fVulkanDevice.Commands.LatencySleepNV(fVulkanDevice.Handle,
                                            fVulkanSwapChain.Handle,
                                            @SleepInfo)=VK_SUCCESS then begin
    fLowLatencySleepSemaphore.WaitFor(fLowLatencyFrameID,
                                      fHighResolutionTimer.SecondInterval);
   end;
  except
  end;
 end;
end;

procedure TpvApplication.UpdateJobFunction(const aJob:PPasMPJob;const aThreadIndex:TPasMPInt32);
var StartTime:TpvHighResolutionTime;
begin
 if not TPasMPInterlocked.CompareExchange(fInUpdateJobFunction,TPasMPBool32(true),TPasMPBool32(false)) then begin
  try
    SetLowLatencyMarker(VK_LATENCY_MARKER_SIMULATION_START_NV);
    fTimingCPUUpdateStart:=fHighResolutionTimer.ToFloatSeconds(fHighResolutionTimer.GetTime-fTimingCPUFrameStartTime);
    StartTime:=fHighResolutionTimer.GetTime;
    Update(fUpdateDeltaTime);
    fTimingCPUUpdate:=fHighResolutionTimer.ToFloatSeconds(fHighResolutionTimer.GetTime-StartTime);
    fTimingCPUUpdateEnd:=fHighResolutionTimer.ToFloatSeconds(fHighResolutionTimer.GetTime-fTimingCPUFrameStartTime);
    SetLowLatencyMarker(VK_LATENCY_MARKER_SIMULATION_END_NV);
  finally
   TPasMPInterlocked.Write(fInUpdateJobFunction,TPasMPBool32(false));
  end;
 end;
end;

procedure TpvApplication.DrawJobFunction(const aJob:PPasMPJob;const aThreadIndex:TPasMPInt32);
var StartTime:TpvHighResolutionTime;
begin
 SetLowLatencyMarker(VK_LATENCY_MARKER_RENDERSUBMIT_START_NV);
 fTimingCPUDrawStart:=fHighResolutionTimer.ToFloatSeconds(fHighResolutionTimer.GetTime-fTimingCPUFrameStartTime);
 StartTime:=fHighResolutionTimer.GetTime;
 Draw(fSwapChainImageIndex,fVulkanWaitSemaphore,fVulkanWaitFence);
 fTimingCPUDraw:=fHighResolutionTimer.ToFloatSeconds(fHighResolutionTimer.GetTime-StartTime);
 fTimingCPUDrawEnd:=fHighResolutionTimer.ToFloatSeconds(fHighResolutionTimer.GetTime-fTimingCPUFrameStartTime);
 SetLowLatencyMarker(VK_LATENCY_MARKER_RENDERSUBMIT_END_NV);
end;

procedure TpvApplication.UpdateAudioHook;
begin
 UpdateAudio;
end;

procedure TpvApplication.ProcessRunnables;
var Index,Count:TpvInt32;
begin
 fRunnableListCriticalSection.Acquire;
 try
  Count:=fRunnableListCount;
  if Count>0 then begin
   Index:=0;
   while Index<Count do begin
    if assigned(fRunnableList[Index]) then begin
     fRunnableListCriticalSection.Release;
     try
      fRunnableList[Index]();
     finally
      fRunnableListCriticalSection.Acquire;
     end;
    end;
    inc(Index);
   end;
   if Count<fRunnableListCount then begin
    Count:=fRunnableListCount-Count;
    Index:=0;
    while Index<Count do begin
     fRunnableList[Index]:=fRunnableList[fRunnableListCount+Index];
     inc(Index);
    end;
    fRunnableListCount:=Count;
   end else begin
    fRunnableListCount:=0;
   end;
  end;
 finally
  fRunnableListCriticalSection.Release;
 end;
end;

procedure TpvApplication.AfterCreateSwapChainWithCheck;
begin
 if fLoadWasCalled then begin
  AfterCreateSwapChain;
 end;
end;

procedure TpvApplication.BeforeDestroySwapChainWithCheck;
begin
 if fLoadWasCalled then begin
  BeforeDestroySwapChain;
 end;
end;

function TpvApplication.IsVisibleToUser:boolean;
{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
const FullScreenFocusActiveFlags=SDL_WINDOW_SHOWN or SDL_WINDOW_INPUT_FOCUS {or SDL_WINDOW_MOUSE_FOCUS};
      FullScreenActiveFlags=SDL_WINDOW_SHOWN {or SDL_WINDOW_MOUSE_FOCUS};
var WindowFlags:TSDLUInt32;
begin
 WindowFlags:=SDL_GetWindowFlags(fSurfaceWindow);
 result:=((fCurrentFullScreen=0) or
          ((fFullscreenFocusNeeded and ((WindowFlags and FullScreenFocusActiveFlags)=FullScreenFocusActiveFlags)) or
           ((not fFullscreenFocusNeeded) and ((WindowFlags and FullScreenActiveFlags)=FullScreenActiveFlags)))) and
         ((WindowFlags and SDL_WINDOW_MINIMIZED)=0) and
         ((WindowFlags and SDL_WINDOW_HIDDEN)=0) and
         not fWindowMinimizedOrHidden;
end;
{$elseif defined(Windows) and not defined(PasVulkanHeadless)}
const FullScreenFocusActiveFlags=WS_VISIBLE;
      FullScreenActiveFlags=WS_VISIBLE;
var WindowFlags:DWORD;
begin
 WindowFlags:=GetWindowLong(fWin32Handle,GWL_STYLE);
 result:=((fCurrentFullScreen=0) or
          (((fFullscreenFocusNeeded and ((WindowFlags and FullScreenFocusActiveFlags)=FullScreenFocusActiveFlags)) and fWin32HasFocus and ((Windows.GetActiveWindow=fWin32Handle) or (Windows.GetFocus=fWin32Handle))) or
           ((not fFullscreenFocusNeeded) and ((WindowFlags and FullScreenActiveFlags)=FullScreenActiveFlags)))) and
         (((WindowFlags and WS_MINIMIZE)=0) and not IsIconic(fWin32Handle));
end;
{$else}
begin
 result:=true;
end;
{$ifend}

function TpvApplication.WaitForReadyState:boolean;
{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
begin
 result:=true;
end;
{$elseif defined(fpc) and defined(Android)}
begin
 while not ((fAndroidReady and assigned(PANativeWindow)) or fAndroidQuit) do begin
  if assigned(fAndroidAppProcessMessages) then begin
   fAndroidAppProcessMessages(fAndroidApp,true);
  end;
 end;
 result:=fAndroidReady and not fAndroidQuit;
end;
{$elseif defined(Windows) and not defined(PasVulkanHeadless)}
begin
 result:=true;
end;
{$elseif defined(PasVulkanHeadless)}
begin
 result:=true;
end;
{$else}
begin
 result:=false;
end;
{$ifend}

{$if defined(Windows) and not (defined(PasVulkanUseSDL2) or defined(PasVulkanHeadless))}
procedure TpvApplication.ProcessWin32APIMessages;
var Msg:TMsg;
begin
 while PeekMessageW(Msg,0,0,0,PM_REMOVE) do begin
  TranslateMessage(Msg);
  DispatchMessageW(Msg);
 end;
end;
{$ifend}

procedure TpvApplication.UpdateJoysticks(const aInitial:boolean);
var Index:TpvSizeInt;
    Joystick:TpvApplicationJoystick;
{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
    SDLJoystick:PSDL_Joystick;
    SDLGameController:PSDL_GameController;
    XDGDataDirectories,XDGDataDirectory:String;
    GameControllerDBFilePath:String;
    GameControllerDBStream:TStream;
    GameControllerDBMemoryStream:TMemoryStream;
    SDLRW:PSDL_RWops;
{$elseif defined(Windows) and not (defined(PasVulkanUseSDL2) or defined(PasVulkanHeadless))}
    IDCounter:TpvSizeInt;
    XInputCapabilities:TXINPUT_CAPABILITIES;
    JoyCaps:TJOYCAPSW;
    Attached:boolean;
    DeviceCallbackQueueItem:TpvApplicationWin32GameInputDeviceCallbackQueueItem;
    Device:IGameInputDevice;
{$ifend}
begin
{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
 if aInitial then begin
  GameControllerDBFilePath:=IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)))+'gamecontrollerdb.txt';
  if not FileExists(GameControllerDBFilePath) then begin
{$ifdef Unix}
   GameControllerDBFilePath:=IncludeTrailingPathDelimiter(GetEnvironmentVariable('HOME'))+'.steam/root/steamapps/common/Steamworks SDK Redist/gamecontrollerdb.txt';
   if not FileExists(GameControllerDBFilePath) then begin
    XDGDataDirectories:=GetEnvironmentVariable('XDG_DATA_DIRS');
    if length(XDGDataDirectories)=0 then begin
     XDGDataDirectories:=IncludeTrailingPathDelimiter(GetEnvironmentVariable('HOME'))+'.local/share/:/usr/local/share/:/usr/share/';
    end else begin
     XDGDataDirectories:=XDGDataDirectories+':'+IncludeTrailingPathDelimiter(GetEnvironmentVariable('HOME'))+'.local/share/:'+GetEnvironmentVariable('HOME')+'.config/:/usr/local/share/:/usr/share/';
    end;
    while length(XDGDataDirectories)>0 do begin
     Index:=Pos(':',XDGDataDirectories);
     if Index>0 then begin
      XDGDataDirectory:=Copy(XDGDataDirectories,1,Index-1);
      XDGDataDirectories:=Copy(XDGDataDirectories,Index+1,MaxInt);
     end else begin
      XDGDataDirectory:=XDGDataDirectories;
      XDGDataDirectories:='';
     end;
     GameControllerDBFilePath:=IncludeTrailingPathDelimiter(XDGDataDirectory)+'SDL2/gamecontrollerdb.txt';
     if FileExists(GameControllerDBFilePath) then begin
      break;
     end;
     GameControllerDBFilePath:=IncludeTrailingPathDelimiter(XDGDataDirectory)+'sdl2/gamecontrollerdb.txt';
     if FileExists(GameControllerDBFilePath) then begin
      break;
     end;
     GameControllerDBFilePath:=IncludeTrailingPathDelimiter(XDGDataDirectory)+'gamecontrollerdb/gamecontrollerdb.txt';
     if FileExists(GameControllerDBFilePath) then begin
      break;
     end;
     GameControllerDBFilePath:=IncludeTrailingPathDelimiter(XDGDataDirectory)+'gamecontrollerdb.txt';
     if FileExists(GameControllerDBFilePath) then begin
      break;
     end;
{    GameControllerDBFilePath:=IncludeTrailingPathDelimiter(XDGDataDirectory)+'AutismPowered/SDL2GameControllerMapper/gamecontrollerdb.txt';
     if FileExists(GameControllerDBFilePath) then begin
      break;
     end;}
    end;
   end;
{$else} // Windows
   GameControllerDBFilePath:='C:\Program Files\Steam\steamapps\common\Steamworks SDK Redist\gamecontrollerdb.txt';
   if not FileExists(GameControllerDBFilePath) then begin
    GameControllerDBFilePath:='C:\Program Files (x86)\Steam\steamapps\common\Steamworks SDK Redist\gamecontrollerdb.txt';
   end;
{$endif}
  end;
  if FileExists(GameControllerDBFilePath) then begin
   pvApplication.Log(LOG_VERBOSE,'TpvApplication.UpdateJoysticks','SDL2 game controller database "'+GameControllerDBFilePath+'" used.');
   GameControllerDBStream:=TMemoryStream.Create;
   try
    TMemoryStream(GameControllerDBStream).LoadFromFile(GameControllerDBFilePath);
   except
    try
     FreeAndNil(GameControllerDBStream);
    finally
     if fAssets.ExistAsset('gamecontrollerdb.txt') then begin
      pvApplication.Log(LOG_VERBOSE,'TpvApplication.UpdateJoysticks','Internal asset SDL2 game controller database used.');
      GameControllerDBStream:=fAssets.GetAssetStream('gamecontrollerdb.txt');
     end;
    end;
   end;
  end else if fAssets.ExistAsset('gamecontrollerdb.txt') then begin
   pvApplication.Log(LOG_VERBOSE,'TpvApplication.UpdateJoysticks','Internal asset SDL2 game controller database used.');
   GameControllerDBStream:=fAssets.GetAssetStream('gamecontrollerdb.txt');
  end else begin
   pvApplication.Log(LOG_VERBOSE,'TpvApplication.UpdateJoysticks','No SDL2 game controller database used.');
   GameControllerDBStream:=nil;
  end;
  if assigned(GameControllerDBStream) then begin
   try
    GameControllerDBMemoryStream:=TMemoryStream.Create;
    try
     GameControllerDBStream.Seek(0,soBeginning);
     if GameControllerDBMemoryStream.CopyFrom(GameControllerDBStream,GameControllerDBStream.Size)=GameControllerDBStream.Size then begin
      SDLRW:=SDL_RWFromConstMem(GameControllerDBMemoryStream.Memory,GameControllerDBMemoryStream.Size);
      if assigned(SDLRW) then begin
       try
        SDL_GameControllerAddMappingsFromRW(SDLRW,SDL_FALSE);
       finally
        SDL_FreeRW(SDLRW);
       end;
      end;
     end;
    finally
     FreeAndNil(GameControllerDBMemoryStream);
    end;
   finally
    FreeAndNil(GameControllerDBStream);
   end;
  end;
  for Index:=0 to SDL_NumJoysticks-1 do begin
   if SDL_IsGameController(Index)<>0 then begin
    SDLGameController:=SDL_GameControllerOpen(Index);
    if assigned(SDLGameController) then begin
     SDLJoystick:=SDL_GameControllerGetJoystick(SDLGameController);
    end else begin
     SDLJoystick:=nil;
    end;
   end else begin
    SDLGameController:=nil;
    SDLJoystick:=SDL_JoystickOpen(Index);
   end;
   if assigned(SDLJoystick) then begin
    Joystick:=TpvApplicationJoystick.Create(SDL_JoystickInstanceID(SDLJoystick),SDLJoystick,SDLGameController);
    try
     Joystick.fIndex:=Index;
     Joystick.Initialize;
    finally
     try
      fInput.fJoystickIDHashMap.Add(Joystick.fID,Joystick);
     finally
      fInput.fJoysticks.Add(Joystick);
     end;
    end;
    fDoUpdateMainJoystick:=true;
   end;
  end;
 end;
{$elseif defined(Windows) and not (defined(PasVulkanUseSDL2) or defined(PasVulkanHeadless))}
 if fWin32HasGameInput then begin
  Device:=nil;
  try
   while fWin32GameInputDeviceCallbackQueue.Dequeue(DeviceCallbackQueueItem) do begin
    try
     Device:=DeviceCallbackQueueItem.Device;
     if assigned(Device) then begin
      IDCounter:=TpvInt64(TpvPtrInt(Device));
      Joystick:=fInput.fJoystickIDHashMap[IDCounter];
      Attached:=(DeviceCallbackQueueItem.CurrentStatus and GameInputDeviceConnected)<>0;
      if assigned(Joystick) and not Attached then begin
       try
        Joystick.fWin32GameInputDevice:=nil;
       finally
        try
         fInput.fJoystickIDHashMap.Delete(Joystick.fID);
        finally
         fInput.fJoysticks.Remove(Joystick);
        end;
       end;
       fDoUpdateMainJoystick:=true;
      end else if Attached and not assigned(Joystick) then begin
       Joystick:=TpvApplicationJoystick.Create(IDCounter);
       try
        Joystick.fWin32GameInputDevice:=Device;
        Joystick.Initialize;
       finally
        try
         fInput.fJoysticks.Add(Joystick);
        finally
         fInput.fJoystickIDHashMap.Add(Joystick.fID,Joystick);
        end;
       end;
       fDoUpdateMainJoystick:=true;
      end;
     end;
    finally
     DeviceCallbackQueueItem.Device:=nil;
    end;
   end;
  finally
   Device:=nil;
  end;
 end else begin
  for IDCounter:=0 to (XUSER_MAX_COUNT+joyGetNumDevs)-1 do begin
   if IDCounter<XUSER_MAX_COUNT then begin
    Attached:=XInputGetCapabilities(IDCounter,0,@XInputCapabilities)=ERROR_SUCCESS;
   end else begin
    Attached:=joyGetDevCapsW(IDCounter-XUSER_MAX_COUNT,@JoyCaps,SizeOf(TJOYCAPSW))=MMSYSERR_NOERROR;
   end;
   Joystick:=fInput.fJoystickIDHashMap[IDCounter];
   if assigned(Joystick) and not Attached then begin
    try
     fInput.fJoystickIDHashMap.Delete(Joystick.fID);
    finally
     fInput.fJoysticks.Remove(Joystick);
    end;
    fDoUpdateMainJoystick:=true;
   end else if Attached and not assigned(Joystick) then begin
    Joystick:=TpvApplicationJoystick.Create(IDCounter);
    try
     Joystick.Initialize;
    finally
     try
      fInput.fJoysticks.Add(Joystick);
     finally
      fInput.fJoystickIDHashMap.Add(Joystick.fID,Joystick);
     end;
    end;
    fDoUpdateMainJoystick:=true;
   end;
  end;
 end;
{$ifend}
 if fDoUpdateMainJoystick then begin
  fInput.fMainJoystick:=nil;
  if fInput.fJoysticks.Count>0 then begin
   for Index:=0 to fInput.fJoysticks.Count-1 do begin
    Joystick:=TpvApplicationJoystick(fInput.fJoysticks.Items[Index]);
    if assigned(Joystick) then begin
     fInput.fMainJoystick:=Joystick;
     break;
    end;
   end;
  end;
 end;
{$if not (defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless))}
 for Index:=0 to fInput.fJoysticks.Count-1 do begin
  Joystick:=TpvApplicationJoystick(fInput.fJoysticks.Items[Index]);
  if assigned(Joystick) then begin
   Joystick.Update;
  end;
 end;
{$ifend}
end;

procedure TpvApplication.ProcessMessages;
var Index,Counter,Tries:TpvInt32;
{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
    SDLJoystick:PSDL_Joystick;
    SDLGameController:PSDL_GameController;
    Joystick:TpvApplicationJoystick;
    FullscreenDisplayMode:TSDL_DisplayMode;
    DisplayIndex:TpvInt32;
{$else}
 {$if defined(Windows) and not defined(PasVulkanHeadless)}
    devMode:{$ifdef fpc}TDEVMODEW{$else}DEVMODEW{$endif};
    Rect:TRect;
    Point:TPoint;
    MonitorInfo:TMonitorInfo;
 {$ifend}
{$ifend}
    OK,Found:boolean;
    DoSkipNextFrameForRendering,ReadyForSwapChainLatency:boolean;
    CurrentJobWorkerThread:TPasMPJobWorkerThread;
    LocalNextScreen:TpvApplicationScreen;
    LocalNextScreenClass:TpvApplicationScreenClass;
    StartTime:TpvHighResolutionTime;
begin

 if assigned(fPasMPInstance.Profiler) then begin
  fPasMPInstance.Profiler.Start(fPasMPProfilerSuppressGaps);
 end;

 DoSkipNextFrameForRendering:=ShouldSkipNextFrameForRendering;

 LowLatencySleep;
 SetLowLatencyMarker(VK_LATENCY_MARKER_INPUT_SAMPLE_NV);

 ReadyForSwapChainLatency:=DoSkipNextFrameForRendering or WaitForSwapChainLatency;

 ClearDelayedObjectsToFreeIteration;

 ProcessRunnables;

 fDoUpdateMainJoystick:=false;

 if TPasMPInterlocked.CompareExchange(fHasNewWindowTitle,false,true) then begin
{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
  SDL_SetWindowTitle(fSurfaceWindow,PAnsiChar(TpvApplicationRawByteString(fWindowTitle)));
{$elseif defined(Windows) and not defined(PasVulkanHeadless)}
  fWin32Title:=PUCUUTF8ToUTF16(fWindowTitle);
  SetWindowTextW(fWin32Handle,PWideChar(fWin32Title));
{$ifend}
 end;

 if fCurrentHideSystemBars<>ord(fHideSystemBars) then begin
{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
  if fHideSystemBars then begin
   SDL_SetHint(SDL_HINT_ANDROID_HIDE_SYSTEM_BARS,'1');
  end else begin
   SDL_SetHint(SDL_HINT_ANDROID_HIDE_SYSTEM_BARS,'0');
  end;
{$else}
{$ifend}
 end;

 if fCurrentVisibleMouseCursor<>ord(fVisibleMouseCursor) then begin
  fCurrentVisibleMouseCursor:=ord(fVisibleMouseCursor);
{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
  if fVisibleMouseCursor then begin
   SDL_ShowCursor(1);
  end else begin
   SDL_ShowCursor(0);
  end;
{$elseif defined(Windows) and not defined(PasVulkanHeadless)}
  if fVisibleMouseCursor then begin
   fWin32Cursor:=LoadCursor(0,IDC_ARROW);
  end else begin
   fWin32Cursor:=fWin32HiddenCursor;
  end;
  SetCursor(fWin32Cursor);
{$else}
{$ifend}
 end;

 if fCurrentCatchMouse<>ord(fCatchMouse) then begin
  fCurrentCatchMouse:=ord(fCatchMouse);
 end;

 fEffectiveCatchMouse:=fCatchMouse;

 if fCurrentCatchMouseOnButton<>ord(fCatchMouseOnButton) then begin
  fCurrentCatchMouseOnButton:=ord(fCatchMouseOnButton);
  fEffectiveCatchMouse:=fCatchMouseOnButton and (fInput.fMouseDown<>[]);
 end else if fCatchMouseOnButton then begin
  fEffectiveCatchMouse:=fInput.fMouseDown<>[];
 end;

 if fEffectiveCatchMouse and not IsVisibleToUser then begin
  fEffectiveCatchMouse:=false;
 end;

 if fCurrentEffectiveCatchMouse<>ord(fEffectiveCatchMouse) then begin
  fCurrentEffectiveCatchMouse:=ord(fEffectiveCatchMouse);
{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
  if fEffectiveCatchMouse then begin
   SDL_SetRelativeMouseMode(1);
  end else begin
   SDL_SetRelativeMouseMode(0);
  end;
{$elseif defined(Windows) and not defined(PasVulkanHeadless)}
  if fEffectiveCatchMouse then begin
   SetForegroundWindow(fWin32Handle);
   Windows.SetFocus(fWin32Handle);
   SetCapture(fWin32Handle);
   if GetClientRect(fWin32Handle,Rect) then begin
    if ClientToScreen(fWin32Handle,Rect.TopLeft) and ClientToScreen(fWin32Handle,Rect.BottomRight) then begin
     ClipCursor({$ifdef fpc}Rect{$else}@Rect{$endif});
    end;
   end;
  end else begin
   if GetCapture<>0 then begin
    ReleaseCapture;
   end;
   ClipCursor(nil);
  end;
{$else}
{$ifend}
 end;

 if fCurrentRelativeMouse<>ord(fRelativeMouse) then begin
  fCurrentRelativeMouse:=ord(fRelativeMouse);
{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
{$elseif defined(Windows) and not defined(PasVulkanHeadless)}
  if fRelativeMouse and GetWindowRect(pvApplication.fWin32Handle,Rect) then begin
   Point.x:=(fWidth+1) shr 1;
   Point.y:=(fHeight+1) shr 1;
   if ClientToScreen(fWin32Handle,Point) then begin
    Windows.SetCursorPos(Point.x,Point.y);
   end;
  end;
{$ifend}
 end;

 if fCurrentAcceptDragDropFiles<>ord(fAcceptDragDropFiles) then begin
  fCurrentAcceptDragDropFiles:=ord(fAcceptDragDropFiles);
{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
  if fAcceptDragDropFiles then begin
   SDL_EventState(SDL_DROPFILE,SDL_ENABLE);
  end else begin
   SDL_EventState(SDL_DROPFILE,SDL_DISABLE);
  end;
{$elseif defined(Windows) and not defined(PasVulkanHeadless)}
  DragAcceptFiles(fWin32Handle,fAcceptDragDropFiles);
{$ifend}
 end;

 if fHasNewNextScreen then begin
  fHasNewNextScreen:=false;
  LocalNextScreen:=fNextScreen;
  LocalNextScreenClass:=fNextScreenClass;
  fNextScreen:=nil;
  fNextScreenClass:=nil;
  if assigned(LocalNextScreenClass) then begin
   if not (assigned(fScreen) and (fScreen is LocalNextScreenClass)) then begin
    SetScreen(LocalNextScreenClass.Create);
   end;
  end else if fScreen<>LocalNextScreen then begin
   SetScreen(LocalNextScreen);
  end;
 end;

 if fCurrentMaximized<>TpvInt32(fMaximized) then begin
  fCurrentMaximized:=TpvInt32(fMaximized);
{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
  if fMaximized then begin
   SDL_MinimizeWindow(fSurfaceWindow);
  end else begin
   SDL_RestoreWindow(fSurfaceWindow);
  end;
{$elseif defined(Windows) and not defined(PasVulkanHeadless)}
  if fMaximized then begin
   ShowWindow(fWin32Handle,SW_MAXIMIZE);
  end else begin
   ShowWindow(fWin32Handle,SW_RESTORE);
  end;
{$ifend}
 end;

 if (fCurrentWidth<>fWidth) or (fCurrentHeight<>fHeight) or (fCurrentPresentMode<>TpvInt32(fPresentMode)) then begin
  fCurrentWidth:=fWidth;
  fCurrentHeight:=fHeight;
  fCurrentPresentMode:=TpvInt32(fPresentMode);
  if not fFullScreen then begin
{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
   SDL_SetWindowSize(fSurfaceWindow,fWidth,fHeight);
{$else}
{$ifend}
  end;
  if fGraphicsReady then begin
   DeinitializeGraphics;
   InitializeGraphics;
  end;
 end;

 for Tries:=0 to 1 do begin

  fInput.fCriticalSection.Acquire;
  try

    if fInput.fLastTextInput<>fInput.fTextInput then begin
     fInput.fLastTextInput:=fInput.fTextInput;
{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
     if fInput.fTextInput then begin
      SDL_StartTextInput;
     end else begin
      SDL_StopTextInput;
     end;
{$ifend}
    end;

   fInput.fEventCount:=0;

   fInput.fMouseDeltaX:=0;
   fInput.fMouseDeltaY:=0;
   FillChar(fInput.fPointerDeltaX,SizeOf(fInput.fPointerDeltaX[0])*max(fInput.fMaxPointerID+1,0),AnsiChar(#0));
   FillChar(fInput.fPointerDeltaY,SizeOf(fInput.fPointerDeltaY[0])*max(fInput.fMaxPointerID+1,0),AnsiChar(#0));

{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
   if fLastPressedKeyEvent.SDLEvent.type_<>0 then begin
    if fKeyRepeatTimeAccumulator>0 then begin
     dec(fKeyRepeatTimeAccumulator,fDeltaTime);
     while fKeyRepeatTimeAccumulator<0 do begin
      inc(fKeyRepeatTimeAccumulator,fKeyRepeatInterval);
      fInput.AddEvent(fLastPressedKeyEvent);
     end;
    end;
   end;

   while SDL_PollEvent(@fEvent.SDLEvent)<>0 do begin
    if HandleEvent(fEvent) then begin
     continue;
    end;
    case fEvent.SDLEvent.type_ of
     SDL_QUITEV:begin
      if fTerminationOnQuitEvent then begin
       VulkanWaitIdle;
       Pause;
       DeinitializeGraphics;
       Terminate;
      end else begin
       fInput.AddEvent(fEvent);
      end;
     end;
     SDL_APP_TERMINATING:begin
      VulkanWaitIdle;
      Pause;
      DeinitializeGraphics;
      Terminate;
     end;
     SDL_APP_LOWMEMORY:begin
      LowMemory;
     end;
     SDL_APP_WILLENTERBACKGROUND:begin
      //writeln('SDL_APP_WILLENTERBACKGROUND');
{$if defined(fpc) and defined(android)}
      __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication',PAnsiChar(TpvApplicationRawByteString('SDL_APP_WILLENTERBACKGROUND')));
{$ifend}
      fActive:=false;
      VulkanWaitIdle;
      Pause;
      DeinitializeGraphics;
      fHasLastTime:=false;
     end;
     SDL_APP_DIDENTERBACKGROUND:begin
      //writeln('SDL_APP_DIDENTERBACKGROUND');
{$if defined(fpc) and defined(android)}
      __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication',PAnsiChar(TpvApplicationRawByteString('SDL_APP_DIDENTERBACKGROUND')));
{$ifend}
     end;
     SDL_APP_WILLENTERFOREGROUND:begin
      //writeln('SDL_APP_WILLENTERFOREGROUND');
{$if defined(fpc) and defined(android)}
      __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication',PAnsiChar(TpvApplicationRawByteString('SDL_APP_WILLENTERFOREGROUND')));
{$ifend}
     end;
     SDL_APP_DIDENTERFOREGROUND:begin
      //writeln('SDL_APP_DIDENTERFOREGROUND');
      fResourceManager.AcquireSynchronizationLock;
      try
       InitializeGraphics;
      finally
       fResourceManager.ReleaseSynchronizationLock;
      end;
      Resume;
      fActive:=true;
      fHasLastTime:=false;
{$if defined(fpc) and defined(android)}
      __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication',PAnsiChar(TpvApplicationRawByteString('SDL_APP_DIDENTERFOREGROUND')));
{$ifend}
     end;
     SDL_RENDER_TARGETS_RESET,
     SDL_RENDER_DEVICE_RESET:begin
      VulkanWaitIdle;
      if fActive then begin
       Pause;
      end;
      if fGraphicsReady then begin
       fResourceManager.AcquireSynchronizationLock;
       try
        DeinitializeGraphics;
        InitializeGraphics;
       finally
        fResourceManager.ReleaseSynchronizationLock;
       end;
      end;
      if fActive then begin
       Resume;
      end;
      fHasLastTime:=false;
     end;
     SDL_DROPFILE:begin
      if assigned(fEvent.SDLEvent.drop.FileName) then begin
       try
        if pvApplication.fAcceptDragDropFiles then begin
         fEvent.StringData:=fEvent.SDLEvent.drop.FileName;
         fInput.AddEvent(fEvent);
        end;
       finally
        SDL_free(fEvent.SDLEvent.drop.FileName);
       end;
      end;
     end;
     SDL_WINDOWEVENT:begin
      case fEvent.SDLEvent.window.event of
       SDL_WINDOWEVENT_RESIZED:begin
        fWidth:=fEvent.SDLEvent.window.Data1;
        fHeight:=fEvent.SDLEvent.window.Data2;
{$if defined(PasVulkanUseSDL2) and defined(PasVulkanUseSDL2WithVulkanSupport)}
        if fSDLVersionWithVulkanSupport then begin
         SDL_Vulkan_GetDrawableSize(fSurfaceWindow,@fWidth,@fHeight);
        end;
{$ifend}
        fCurrentWidth:=fWidth;
        fCurrentHeight:=fHeight;
        if fGraphicsReady then begin
         VulkanDebugLn('New surface dimension size detected! '+IntToStr(fWidth)+'x'+IntToStr(fHeight));
{$if true}
         if not (fAcquireVulkanBackBufferState in [TAcquireVulkanBackBufferState.RecreateSwapChain,
                                                   TAcquireVulkanBackBufferState.RecreateSurface,
                                                   TAcquireVulkanBackBufferState.RecreateDevice]) then begin
          fAcquireVulkanBackBufferState:=TAcquireVulkanBackBufferState.RecreateSwapChain;
         end;
{$else}
         fResourceManager.AcquireSynchronizationLock;
         try
          DeinitializeGraphics;
          InitializeGraphics;
         finally
          fResourceManager.ReleaseSynchronizationLock;
         end;
{$ifend}
        end;
        if assigned(fScreen) then begin
         fScreen.Resize(fWidth,fHeight);
        end;
       end;
       SDL_WINDOWEVENT_MINIMIZED,SDL_WINDOWEVENT_HIDDEN:begin
        // Window was minimized or hidden (covers Wayland compositor iconification
        // which may not set SDL_WINDOW_MINIMIZED reliably).
        // Reset timing so we do not accumulate a huge delta on restore.
        fWindowMinimizedOrHidden:=true;
        fHasLastTime:=false;
       end;
       SDL_WINDOWEVENT_RESTORED,SDL_WINDOWEVENT_SHOWN:begin
        // Window was restored or shown again — reset timing.
        fWindowMinimizedOrHidden:=false;
        fHasLastTime:=false;
       end;
      end;
     end;
     SDL_JOYDEVICEADDED:begin
      Index:=fEvent.SDLEvent.jdevice.which;
      Found:=false;
      for Counter:=0 to fInput.fJoysticks.Count-1 do begin
       Joystick:=TpvApplicationJoystick(fInput.fJoysticks.Items[Counter]);
       if assigned(Joystick) and (Joystick.fIndex=Index) then begin
        Found:=true;
        break;
       end;
      end;
      if not Found then begin
       if SDL_IsGameController(Index)<>0 then begin
        SDLGameController:=SDL_GameControllerOpen(Index);
        if assigned(SDLGameController) then begin
         SDLJoystick:=SDL_GameControllerGetJoystick(SDLGameController);
        end else begin
         SDLJoystick:=nil;
        end;
       end else begin
        SDLGameController:=nil;
        SDLJoystick:=SDL_JoystickOpen(Index);
       end;
       if assigned(SDLJoystick) then begin
        Joystick:=TpvApplicationJoystick.Create(SDL_JoystickInstanceID(SDLJoystick),SDLJoystick,SDLGameController);
        try
         Joystick.fIndex:=Index;
         Joystick.Initialize;
        finally
         try
          fInput.fJoystickIDHashMap.Add(Joystick.fID,Joystick);
         finally
          fInput.fJoysticks.Add(Joystick);
         end;
        end;
        fDoUpdateMainJoystick:=true;
       end;
      end;
     end;
     SDL_JOYDEVICEREMOVED:begin
      for Counter:=0 to fInput.fJoysticks.Count-1 do begin
       Joystick:=TpvApplicationJoystick(fInput.fJoysticks.Items[Counter]);
       if assigned(Joystick) and (Joystick.fIndex=fEvent.SDLEvent.jdevice.which) then begin
        try
         fInput.fJoystickIDHashMap.Delete(Joystick.fID);
        finally
         fInput.fJoysticks.Delete(Counter);
        end;
        fDoUpdateMainJoystick:=true;
        break;
       end;
      end;
     end;
     SDL_CONTROLLERDEVICEADDED:begin
     end;
     SDL_CONTROLLERDEVICEREMOVED:begin
     end;
     SDL_CONTROLLERDEVICEREMAPPED:begin
     end;
     SDL_KEYDOWN:begin
      OK:=true;
      case fEvent.SDLEvent.key.keysym.sym of
       SDLK_F4:begin
        if fTerminationWithAltF4 and ((fEvent.SDLEvent.key.keysym.modifier and ((KMOD_LALT or KMOD_RALT) or (KMOD_LMETA or KMOD_RMETA)))<>0) then begin
         OK:=false;
         if fEvent.SDLEvent.key.repeat_=0 then begin
          Terminate;
         end;
        end;
       end;
       SDLK_RETURN:begin
        if ((fEvent.SDLEvent.key.keysym.modifier and ((KMOD_LALT or KMOD_RALT) or (KMOD_LMETA or KMOD_RMETA)))<>0) then begin
         if fEvent.SDLEvent.key.repeat_=0 then begin
          OK:=false;
          fFullScreen:=not fFullScreen;
         end;
        end;
       end;
      end;
      if OK then begin
       if fNativeKeyRepeat then begin
        if fEvent.SDLEvent.key.repeat_=0 then begin
         fInput.AddEvent(fEvent);
        end;
        fEvent.SDLEvent.type_:=SDL_KEYTYPED;
        fInput.AddEvent(fEvent);
       end else if fEvent.SDLEvent.key.repeat_=0 then begin
        fInput.AddEvent(fEvent);
        fEvent.SDLEvent.type_:=SDL_KEYTYPED;
        fInput.AddEvent(fEvent);
        fLastPressedKeyEvent:=fEvent;
        fKeyRepeatTimeAccumulator:=fKeyRepeatInitialInterval;
       end;
      end;
     end;
     SDL_KEYUP:begin
      OK:=true;
      case fEvent.SDLEvent.key.keysym.sym of
       SDLK_F4:begin
        if fTerminationWithAltF4 and ((fEvent.SDLEvent.key.keysym.modifier and ((KMOD_LALT or KMOD_RALT) or (KMOD_LMETA or KMOD_RMETA)))<>0) then begin
         OK:=false;
        end;
       end;
       SDLK_RETURN:begin
        if ((fEvent.SDLEvent.key.keysym.modifier and ((KMOD_LALT or KMOD_RALT) or (KMOD_LMETA or KMOD_RMETA)))<>0) then begin
         OK:=false;
        end;
       end;
      end;
      if OK then begin
       if fEvent.SDLEvent.key.repeat_=0 then begin
        fInput.AddEvent(fEvent);
        fLastPressedKeyEvent.SDLEvent.type_:=0;
       end;
      end;
     end;
     SDL_TEXTINPUT:begin
      fInput.AddEvent(fEvent);
     end;
     SDL_MOUSEMOTION:begin
      fInput.AddEvent(fEvent);
     end;
     SDL_MOUSEBUTTONDOWN:begin
      fInput.AddEvent(fEvent);
     end;
     SDL_MOUSEBUTTONUP:begin
      fInput.AddEvent(fEvent);
     end;
     SDL_MOUSEWHEEL:begin
      fInput.AddEvent(fEvent);
     end;
     SDL_FINGERMOTION:begin
      fInput.AddEvent(fEvent);
     end;
     SDL_FINGERDOWN:begin
      fInput.AddEvent(fEvent);
     end;
     SDL_FINGERUP:begin
      fInput.AddEvent(fEvent);
     end;
    end;
   end;
 {$else}

   if fLastPressedKeyEvent.NativeEvent.Kind<>TpvApplicationNativeEventKind.None then begin
    if fKeyRepeatTimeAccumulator>0 then begin
     dec(fKeyRepeatTimeAccumulator,fDeltaTime);
     while fKeyRepeatTimeAccumulator<0 do begin
      inc(fKeyRepeatTimeAccumulator,fKeyRepeatInterval);
      fInput.AddEvent(fLastPressedKeyEvent);
     end;
    end;
   end;

{$if defined(Windows) and not (defined(PasVulkanUseSDL2) or defined(PasVulkanHeadless))}
   if assigned(fWin32MainFiber) then begin
    SwitchToFiber(fWin32MessageFiber);
   end else begin
    ProcessWin32APIMessages;
   end;
{$ifend}

   while fNativeEventLocalQueue.Dequeue(fEvent.NativeEvent) or
         fNativeEventQueue.Dequeue(fEvent.NativeEvent) do begin
    case fEvent.NativeEvent.Kind of
     TpvApplicationNativeEventKind.None:begin
      break;
     end;
     TpvApplicationNativeEventKind.Resize:begin
      fWidth:=fEvent.NativeEvent.ResizeWidth;
      fHeight:=fEvent.NativeEvent.ResizeHeight;
      while fNativeEventQueue.Dequeue(fEvent.NativeEvent) do begin
       if fEvent.NativeEvent.Kind=TpvApplicationNativeEventKind.Resize then begin
        fWidth:=fEvent.NativeEvent.ResizeWidth;
        fHeight:=fEvent.NativeEvent.ResizeHeight;
       end else begin
        // Reenqueue for as next event
        fNativeEventLocalQueue.Enqueue(fEvent.NativeEvent);
        break;
       end;
      end;
      fCurrentWidth:=fWidth;
      fCurrentHeight:=fHeight;
      if fGraphicsReady then begin
       VulkanDebugLn('New surface dimension size detected! '+IntToStr(fWidth)+'x'+IntToStr(fHeight));
 {$if true}
       if not (fAcquireVulkanBackBufferState in [TAcquireVulkanBackBufferState.RecreateSwapChain,
                                                 TAcquireVulkanBackBufferState.RecreateSurface,
                                                 TAcquireVulkanBackBufferState.RecreateDevice]) then begin
        fAcquireVulkanBackBufferState:=TAcquireVulkanBackBufferState.RecreateSwapChain;
       end;
 {$else}
       fResourceManager.AcquireSynchronizationLock;
       try
        DeinitializeGraphics;
        InitializeGraphics;
       finally
        fResourceManager.ReleaseSynchronizationLock;
       end;
 {$ifend}
      end;
      if assigned(fScreen) then begin
       fScreen.Resize(fWidth,fHeight);
      end;
     end;
     TpvApplicationNativeEventKind.Close:begin
      if fTerminationOnQuitEvent then begin
       VulkanWaitIdle;
       Pause;
       fResourceManager.AcquireSynchronizationLock;
       try
        DeinitializeGraphics;
       finally
        fResourceManager.ReleaseSynchronizationLock;
       end;
       Terminate;
      end else begin
       fEvent.NativeEvent.Kind:=TpvApplicationNativeEventKind.Quit;
       fInput.AddEvent(fEvent);
      end;
     end;
     TpvApplicationNativeEventKind.Destroy:begin
      if not fTerminationOnQuitEvent then begin
       VulkanWaitIdle;
       Pause;
       fResourceManager.AcquireSynchronizationLock;
       try
        DeinitializeGraphics;
       finally
        fResourceManager.ReleaseSynchronizationLock;
       end;
       Terminate;
      end;
     end;
     TpvApplicationNativeEventKind.LowMemory:begin
      LowMemory;
     end;
     TpvApplicationNativeEventKind.WillEnterBackground:begin
 {$if defined(fpc) and defined(android)}
      __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication',PAnsiChar(TpvApplicationRawByteString('SDL_APP_WILLENTERBACKGROUND')));
 {$ifend}
      fActive:=false;
      VulkanWaitIdle;
      Pause;
      fResourceManager.AcquireSynchronizationLock;
      try
       DeinitializeGraphics;
      finally
       fResourceManager.ReleaseSynchronizationLock;
      end;
      fHasLastTime:=false;
     end;
     TpvApplicationNativeEventKind.DidEnterBackground:begin
 {$if defined(fpc) and defined(android)}
      __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication',PAnsiChar(TpvApplicationRawByteString('SDL_APP_DIDENTERBACKGROUND')));
 {$ifend}
     end;
     TpvApplicationNativeEventKind.WillEnterForeground:begin
 {$if defined(fpc) and defined(android)}
      __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication',PAnsiChar(TpvApplicationRawByteString('SDL_APP_WILLENTERFOREGROUND')));
 {$ifend}
     end;
     TpvApplicationNativeEventKind.DidEnterForeground:begin
      fResourceManager.AcquireSynchronizationLock;
      try
       InitializeGraphics;
      finally
       fResourceManager.ReleaseSynchronizationLock;
      end;
      Resume;
      fActive:=true;
      fHasLastTime:=false;
 {$if defined(fpc) and defined(android)}
      __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication',PAnsiChar(TpvApplicationRawByteString('SDL_APP_DIDENTERFOREGROUND')));
 {$ifend}
     end;
     TpvApplicationNativeEventKind.GraphicsReset:begin
      VulkanWaitIdle;
      if fActive then begin
       Pause;
      end;
      if fGraphicsReady then begin
       fResourceManager.AcquireSynchronizationLock;
       try
        DeinitializeGraphics;
        InitializeGraphics;
       finally
        fResourceManager.ReleaseSynchronizationLock;
       end;
      end;
      if fActive then begin
       Resume;
      end;
      fHasLastTime:=false;
     end;
     TpvApplicationNativeEventKind.KeyDown:begin
      OK:=true;
      case fEvent.NativeEvent.KeyCode of
       KEYCODE_F4:begin
        if fTerminationWithAltF4 and ((fEvent.NativeEvent.KeyModifiers*[TpvApplicationInputKeyModifier.ALT,TpvApplicationInputKeyModifier.LALT,TpvApplicationInputKeyModifier.RALT,TpvApplicationInputKeyModifier.META,TpvApplicationInputKeyModifier.LMETA,TpvApplicationInputKeyModifier.RMETA])<>[]) then begin
         OK:=false;
         if not fEvent.NativeEvent.KeyRepeat then begin
          Terminate;
         end;
        end;
       end;
       KEYCODE_RETURN:begin
        if (fEvent.NativeEvent.KeyModifiers*[TpvApplicationInputKeyModifier.ALT,TpvApplicationInputKeyModifier.LALT,TpvApplicationInputKeyModifier.RALT,TpvApplicationInputKeyModifier.META,TpvApplicationInputKeyModifier.LMETA,TpvApplicationInputKeyModifier.RMETA])<>[] then begin
         if not fEvent.NativeEvent.KeyRepeat then begin
          OK:=false;
          fFullScreen:=not fFullScreen;
         end;
        end;
       end;
      end;
      if OK then begin
       if fNativeKeyRepeat then begin
        if not fEvent.NativeEvent.KeyRepeat then begin
         fInput.AddEvent(fEvent);
        end;
        fEvent.NativeEvent.Kind:=TpvApplicationNativeEventKind.KeyTyped;
        fInput.AddEvent(fEvent);
       end else if not fEvent.NativeEvent.KeyRepeat then begin
        fInput.AddEvent(fEvent);
        fEvent.NativeEvent.Kind:=TpvApplicationNativeEventKind.KeyTyped;
        fInput.AddEvent(fEvent);
        fLastPressedKeyEvent:=fEvent;
        fKeyRepeatTimeAccumulator:=fKeyRepeatInitialInterval;
       end;
      end;
     end;
     TpvApplicationNativeEventKind.KeyUp:begin
      OK:=true;
      case fEvent.NativeEvent.KeyCode of
       KEYCODE_F4:begin
        if fTerminationWithAltF4 and ((fEvent.NativeEvent.KeyModifiers*[TpvApplicationInputKeyModifier.ALT,TpvApplicationInputKeyModifier.LALT,TpvApplicationInputKeyModifier.RALT,TpvApplicationInputKeyModifier.META,TpvApplicationInputKeyModifier.LMETA,TpvApplicationInputKeyModifier.RMETA])<>[]) then begin
         OK:=false;
        end;
       end;
       KEYCODE_RETURN:begin
        if (fEvent.NativeEvent.KeyModifiers*[TpvApplicationInputKeyModifier.ALT,TpvApplicationInputKeyModifier.LALT,TpvApplicationInputKeyModifier.RALT,TpvApplicationInputKeyModifier.META,TpvApplicationInputKeyModifier.LMETA,TpvApplicationInputKeyModifier.RMETA])<>[] then begin
         OK:=false;
        end;
       end;
      end;
      if OK then begin
      {if not fEvent.NativeEvent.KeyRepeat then}begin
        fInput.AddEvent(fEvent);
        //writeln('6');
        fLastPressedKeyEvent.NativeEvent.Kind:=TpvApplicationNativeEventKind.None;
       end;
      end;
     end;
     TpvApplicationNativeEventKind.KeyTyped:begin
      fInput.AddEvent(fEvent);
     end;
     TpvApplicationNativeEventKind.UnicodeCharTyped:begin
      fInput.AddEvent(fEvent);
     end;
     TpvApplicationNativeEventKind.MouseButtonDown:begin
      fInput.AddEvent(fEvent);
     end;
     TpvApplicationNativeEventKind.MouseButtonUp:begin
      fInput.AddEvent(fEvent);
     end;
     TpvApplicationNativeEventKind.MouseWheel:begin
      fInput.AddEvent(fEvent);
     end;
     TpvApplicationNativeEventKind.MouseMoved:begin
      fInput.AddEvent(fEvent);
     end;
     TpvApplicationNativeEventKind.MouseEnter:begin
      fInput.AddEvent(fEvent);
     end;
     TpvApplicationNativeEventKind.MouseLeave:begin
      fInput.AddEvent(fEvent);
     end;
     TpvApplicationNativeEventKind.TouchDown:begin
      fInput.AddEvent(fEvent);
     end;
     TpvApplicationNativeEventKind.TouchUp:begin
      fInput.AddEvent(fEvent);
     end;
     TpvApplicationNativeEventKind.TouchMotion:begin
      fInput.AddEvent(fEvent);
     end;
     TpvApplicationNativeEventKind.DropFile:Begin
      fInput.AddEvent(fEvent);
     end;
     else begin
     end;
    end;
   end;
{$ifend}
   UpdateJoysticks(false);
   fInput.ProcessEvents;
  finally
   fInput.fCriticalSection.Release;
  end;

  if assigned(fOnStep) then begin
   fOnStep(self);
  end;

  if (fCurrentFullScreen<>(ord(fFullScreen) and 1)) or
     (fFullScreen and
      ((fCurrentRealFullScreen<>(ord(fUseRealFullScreen) and 1)) or
       (fUseRealFullScreen and
        ((fCurrentFullScreenWidth<>fFullScreenWidth) or
         (fCurrentFullScreenHeight<>fFullScreenHeight) or
         (fCurrentFullScreenRefreshRate<>fFullScreenRefreshRate))))) then begin
   if (Tries=0) and
      not (fAcquireVulkanBackBufferState in [TAcquireVulkanBackBufferState.RecreateSwapChain,
                                             TAcquireVulkanBackBufferState.RecreateSurface,
                                             TAcquireVulkanBackBufferState.RecreateDevice]) then begin
    VulkanDebugLn('New fullscreen setting detected!');
    fAcquireVulkanBackBufferState:=TAcquireVulkanBackBufferState.RecreateSwapChain;
   end;
{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}

   // For SDL, we can directly set fullscreen modes without restoring first as SDL handles the
   // transitions internally, avoiding common pitfalls. Any necessary intermediate steps are
   // managed by SDL itself, which simplifies the following code and improves reliability across platforms.

   // The result codes of the SDL functions are not checked here, as failures are rare and typically non-critical,
   // and SDL will often revert to a safe state automatically, so adding them would unnecessarily complicate the code.

   if fFullScreen then begin

    if fUseRealFullScreen then begin

     // Enter real fullscreen

     // Set the desired fullscreen display mode
     if (fFullScreenWidth>0) and (fFullScreenHeight>0) and (fFullScreenRefreshRate>=0) then begin
      OK:=SDL_GetWindowDisplayMode(fSurfaceWindow,@FullscreenDisplayMode)=0;
      if not OK then begin
       DisplayIndex:=SDL_GetWindowDisplayIndex(fSurfaceWindow);
       if DisplayIndex<0 then begin
        DisplayIndex:=0;
       end;
       OK:=SDL_GetCurrentDisplayMode(DisplayIndex,@FullscreenDisplayMode)=0;
       if not OK then begin
        OK:=SDL_GetDesktopDisplayMode(DisplayIndex,@FullscreenDisplayMode)=0;
        if not OK then begin
         FillChar(FullscreenDisplayMode,SizeOf(TSDL_DisplayMode),#0);
         FullscreenDisplayMode.format:=SDL_PIXELFORMAT_UNKNOWN;
         FullscreenDisplayMode.w:=fFullScreenWidth;
         FullscreenDisplayMode.h:=fFullScreenHeight;
         if fFullScreenRefreshRate>0 then begin
          FullscreenDisplayMode.refresh_rate:=fFullScreenRefreshRate;
         end else begin
          FullscreenDisplayMode.refresh_rate:=0; // Let SDL choose the default refresh rate
         end;
         FullscreenDisplayMode.driverdata:=nil;
         OK:=true;
        end;
       end;
      end;
      if OK then begin
       FullscreenDisplayMode.w:=fFullScreenWidth;
       FullscreenDisplayMode.h:=fFullScreenHeight;
       // Only set the refresh rate if a positive value is specified, otherwise let the previously obtained/default rate remain
       if fFullScreenRefreshRate>0 then begin
        FullscreenDisplayMode.refresh_rate:=fFullScreenRefreshRate;
       end;
       SDL_SetWindowSize(fSurfaceWindow,fFullScreenWidth,fFullScreenHeight);
       SDL_SetWindowDisplayMode(fSurfaceWindow,@FullscreenDisplayMode);
      end;
     end;

     // Set real fullscreen mode
     if (SDL_GetWindowFlags(fSurfaceWindow) and SDL_WINDOW_FULLSCREEN)=0 then begin
      SDL_SetWindowFullscreen(fSurfaceWindow,SDL_WINDOW_FULLSCREEN);
     end;

    end else begin

     // Enter fake fullscreen (borderless window maximized to desktop size)
     if (SDL_GetWindowFlags(fSurfaceWindow) and SDL_WINDOW_FULLSCREEN_DESKTOP)=0 then begin
      SDL_SetWindowFullscreen(fSurfaceWindow,SDL_WINDOW_FULLSCREEN_DESKTOP);
     end;

    end;

   end else begin

    // Restore windowed mode
    if (SDL_GetWindowFlags(fSurfaceWindow) and (SDL_WINDOW_FULLSCREEN or SDL_WINDOW_FULLSCREEN_DESKTOP))<>0 then begin
     SDL_SetWindowFullscreen(fSurfaceWindow,0);
    end;

   end;

{$if defined(PasVulkanUseSDL2WithVulkanSupport)}
   if fSDLVersionWithVulkanSupport then begin
    SDL_Vulkan_GetDrawableSize(fSurfaceWindow,@fWidth,@fHeight);
   end else{$ifend}begin
    SDL_GetWindowSize(fSurfaceWindow,fWidth,fHeight);
   end;
{$elseif defined(Windows) and not defined(PasVulkanHeadless)}

   // For Win32, the defensive pattern of always restoring to windowed mode first even
   // before changing fullscreen state to avoid issues is implemented below.
   //
   // This approach mitigates various driver and Windows quirks related to fullscreen transitions.
   //
   // Detailed explanation:
   //
   // The "always restore to windowed first" approach is a common and valid defensive
   // pattern for Windows fullscreen handling. Here's why:
   // Reasons for this approach:
   //
   // 1. Display mode stack issues: ChangeDisplaySettingsW maintains an internal display mode stack.
   //     Going directly from one exclusive mode to another can leave stale entries, causing issues
   //     when restoring.
   //
   // 2. Driver quirks: Some GPU drivers (especially older ones, or certain AMD/Intel integrated
   //    graphics) don't handle direct mode-to-mode transitions well. They expect the clean sequence:
   //    Exclusive => Desktop => New Exclusive.
   //
   // 3. Window style conflicts: Directly changing from real fullscreen (with changed display mode)
   //    to fake fullscreen (borderless) while keeping popup styles can cause rendering issues or black
   //    screens.
   //
   // 4. Multi-monitor edge cases: When switching between monitors or when display topology changes,
   //    going through windowed mode ensures the window is properly repositioned.
   //
   // 5. Alt-Tab / Focus loss recovery: If the app lost focus during a previous fullscreen session,
   //     a clean restore ensures predictable state.
   //
   // 6. Simplicity and predictability: This pattern simplifies the state management logic, making
   //    it easier to reason about the current window state.
   //
   // The pattern is used by:
   //
   // - Many game engines (Unity, Unreal do similar)
   // - SDL internally uses similar logic
   // - DirectX sample code often recommends this
   //
   // Potential downside:
   //
   // - Brief visual flicker during transition (window momentarily visible in windowed state)
   //
   // Alternative approaches:
   //
   // - Direct mode switching: Attempt to switch directly between exclusive modes. Risky due to
   //   driver quirks and display stack issues.
   //
   // - Persistent borderless window: Always use fake fullscreen (borderless) to avoid mode
   //   switches. Simpler but may not offer the best performance or compatibility for all apps.
   //   It's also implemented in this code as an option, where fUseRealFullScreen must be false.
   //
   // - Some engines track whether they're changing mode type (real<=>fake) vs just resolution and
   //   only restore when needed
   //
   // - DXGI's SetFullscreenState handles some of this internally for D3D apps
   //
   // Conclusion:
   //
   // While not strictly required in all cases, restoring to windowed mode first is a robust
   // defensive practice that avoids many common pitfalls with Windows fullscreen handling across
   // different hardware and driver configurations.

   if fWin32FullScreen then begin
    if fWin32RealFullScreen then begin
     OK:=ChangeDisplaySettingsW(nil,0)=DISP_CHANGE_SUCCESSFUL;
     fWin32RealFullScreen:=false;
    end else begin
     OK:=true;
    end;
    if OK then begin
     if fResizable then begin
      SetWindowLongW(fWin32Handle,GWL_STYLE,WS_VISIBLE or WS_CAPTION or WS_MINIMIZEBOX or WS_THICKFRAME or WS_MAXIMIZEBOX or WS_SYSMENU);
     end else begin
      SetWindowLongW(fWin32Handle,GWL_STYLE,WS_VISIBLE or WS_CAPTION or WS_MINIMIZEBOX or WS_SYSMENU);
     end;
     if fAcceptDragDropFiles then begin
      SetWindowLongW(fWin32Handle,GWL_EXSTYLE,WS_EX_APPWINDOW or WS_EX_ACCEPTFILES);
     end else begin
      SetWindowLongW(fWin32Handle,GWL_EXSTYLE,WS_EX_APPWINDOW);
     end;
     SetWindowPos(fWin32Handle,HWND_TOP,fWin32OldLeft,fWin32OldTop,fWin32OldWidth,fWin32OldHeight,SWP_FRAMECHANGED);
     ShowWindow(fWin32Handle,SW_SHOW);
     fWin32FullScreen:=false;
    end else begin
     fFullScreen:=true;
    end;
   end;

   // Now set the new fullscreen state, when requested
   if fFullScreen then begin
    FillChar(MonitorInfo,SizeOf(TMonitorInfo),#0);
    MonitorInfo.cbSize:=SizeOf(TMonitorInfo);
    if (not fWin32FullScreen) and
       GetWindowRect(fWin32Handle,Rect) and
       GetMonitorInfo(MonitorFromWindow(fWin32Handle,MONITOR_DEFAULTTONEAREST),@MonitorInfo) then begin
     if fUseRealFullScreen and (fFullScreenWidth>0) and (fFullScreenHeight>0) then begin
      fScreenWidth:=fFullScreenWidth;
      fScreenHeight:=fFullScreenHeight;
     end else begin
      fScreenWidth:=MonitorInfo.rcMonitor.Width;
      fScreenHeight:=MonitorInfo.rcMonitor.Height;
     end;
     fWin32OldLeft:=Rect.Left;
     fWin32OldTop:=Rect.Top;
     fWin32OldWidth:=fWidth;
     fWin32OldHeight:=fHeight;
     FillChar(devMode,SizeOf({$ifdef fpc}TDEVMODEW{$else}DEVMODEW{$endif}),#0);
     devMode.dmSize:=SizeOf({$ifdef fpc}TDEVMODEW{$else}DEVMODEW{$endif});
     devMode.dmPelsWidth:=fScreenWidth;
     devMode.dmPelsHeight:=fScreenHeight;
//   devMode.dmBitsPerPel:=32; // Don't set bitsperpel to avoid problems with HDR/10b displays and similar situations
     devMode.dmFields:=DM_PELSWIDTH or DM_PELSHEIGHT {or DM_BITSPERPEL};
     if fFullScreenRefreshRate>0 then begin
      // When a specific refresh rate is requested, set it
      devMode.dmDisplayFrequency:=fFullScreenRefreshRate;
      devMode.dmFields:=devMode.dmFields or DM_DISPLAYFREQUENCY;
     end;
     if fUseRealFullScreen then begin
      OK:=ChangeDisplaySettingsW(@devMode,CDS_FULLSCREEN)=DISP_CHANGE_SUCCESSFUL;
      fWin32RealFullScreen:=OK;
     end else begin
      OK:=true;
      fWin32RealFullScreen:=false;
     end;
     if OK then begin
      SetWindowLongW(fWin32Handle,GWL_STYLE,WS_VISIBLE or WS_POPUP or WS_CLIPCHILDREN or WS_CLIPSIBLINGS);
      if fAcceptDragDropFiles then begin
       SetWindowLongW(fWin32Handle,GWL_EXSTYLE,WS_EX_APPWINDOW or WS_EX_ACCEPTFILES);
      end else begin
       SetWindowLongW(fWin32Handle,GWL_EXSTYLE,WS_EX_APPWINDOW);
      end;
      SetWindowPos(fWin32Handle,HWND_TOP,MonitorInfo.rcMonitor.Left,MonitorInfo.rcMonitor.Top,fScreenWidth,fScreenHeight,SWP_FRAMECHANGED);
      ShowWindow(fWin32Handle,SW_SHOW);
      fWin32FullScreen:=true;
     end else begin
      fFullScreen:=false;
     end;
    end else begin
     fFullScreen:=false;
    end;

   end;

{$else}
{$ifend}
   fCurrentFullScreen:=ord(fFullScreen) and 1;
   fCurrentRealFullScreen:=ord(fUseRealFullScreen) and 1;
   fCurrentFullScreenWidth:=fFullScreenWidth;
   fCurrentFullScreenHeight:=fFullScreenHeight;
   fCurrentFullScreenRefreshRate:=fFullScreenRefreshRate;
   // Continue with a new fresh loop iteration to process possible new events,
   // like resize events triggered by the fullscreen change, before rendering the next frame
   // with the new settings, for to avoid possible issues.
   continue;
  end;

  break;

 end;

 if fGraphicsReady then begin

  if fReinitializeGraphics then begin
   try
{$if true}
    if not (fAcquireVulkanBackBufferState in [TAcquireVulkanBackBufferState.RecreateSwapChain,
                                              TAcquireVulkanBackBufferState.RecreateSurface,
                                              TAcquireVulkanBackBufferState.RecreateDevice]) then begin
     fAcquireVulkanBackBufferState:=TAcquireVulkanBackBufferState.RecreateSwapChain;
    end;
{$else}
    DeinitializeGraphics;
    InitializeGraphics;
{$ifend}
   finally
    fReinitializeGraphics:=false;
   end;
  end;

  if not fResourceManager.SynchronizationPoint then begin

   if fStayActiveRegardlessOfVisibility or IsVisibleToUser then begin

    if ShouldSkipNextFrameForRendering then begin

     fSkipNextDrawFrame:=false;

     fNowTime:=fHighResolutionTimer.GetTime;
     if fHasLastTime then begin
      fDeltaTime:=fNowTime-fLastTime;
     end else begin
      fDeltaTime:=0;
     end;
     fFloatDeltaTime:=fHighResolutionTimer.ToFloatSeconds(fDeltaTime);
     fLastTime:=fNowTime;
     fHasLastTime:=true;

     UpdateFrameTimesHistory;

     fUpdateDeltaTime:=Min(Max(fFloatDeltaTime,0.0),0.25);

     fUpdateFrameCounter:=fFrameCounter;
     fDrawFrameCounter:=fFrameCounter;

     fPreviousInFlightFrameIndex:=fCurrentInFlightFrameIndex;

     fCurrentInFlightFrameIndex:=fNextInFlightFrameIndex;

     fNextInFlightFrameIndex:=fCurrentInFlightFrameIndex+1;
     if fNextInFlightFrameIndex>=fCountInFlightFrames then begin
      fNextInFlightFrameIndex:=0;
     end;

     fDrawInFlightFrameIndex:=fCurrentInFlightFrameIndex;
     fUpdateInFlightFrameIndex:=fCurrentInFlightFrameIndex;

     Check(fUpdateDeltaTime);

     if fUseExtraUpdateThread and assigned(fUpdateThread) then begin
      fUpdateThread.Invoke;
      fUpdateThread.WaitForDone;
     end else begin
      UpdateJobFunction(nil,0);
     end;

     inc(fFrameCounter);

     FramePacingAndFrameRateLimiter;

     inc(fSwapChainImageCounterIndex);
     if fSwapChainImageCounterIndex>=fCountSwapChainImages then begin
      dec(fSwapChainImageCounterIndex,fCountSwapChainImages);
     end;

     VulkanWaitIdle;

    end else if ReadyForSwapChainLatency then begin

     case fProcessingMode of

      TpvApplicationProcessingMode.Flexible:begin

       fUpdateJob:=nil;
       try

        if fVulkanBackBufferState=TVulkanBackBufferState.Acquire then begin

         fNowTime:=fHighResolutionTimer.GetTime;
         if fHasLastTime then begin
          fDeltaTime:=fNowTime-fLastTime;
         end else begin
          fDeltaTime:=0;
         end;
         fFloatDeltaTime:=fHighResolutionTimer.ToFloatSeconds(fDeltaTime);
         fLastTime:=fNowTime;
         fHasLastTime:=true;

         UpdateFrameTimesHistory;

         fUpdateDeltaTime:=Min(Max(fFloatDeltaTime,0.0),0.25);

         fTimingCPUFrameStartTime:=fHighResolutionTimer.GetTime;

         if CanBeParallelProcessed and (fCountInFlightFrames>1) then begin

          fDrawFrameCounter:=fFrameCounter-1;

          fUpdateFrameCounter:=fFrameCounter;

          fDrawInFlightFrameIndex:=fCurrentInFlightFrameIndex;

          fUpdateInFlightFrameIndex:=fNextInFlightFrameIndex;

          Check(fUpdateDeltaTime);

          if fUseExtraUpdateThread and assigned(fUpdateThread) then begin
           fUpdateThread.Invoke;
          end else begin
           fUpdateJob:=fPasMPInstance.Acquire(UpdateJobFunction,nil,nil,PasMPJobPriorityHigh,PasMPAreaMaskUpdate,PasMPAreaMaskRender,PasMPAffinityMaskUpdateAllowMask,PasMPAffinityMaskUpdateAvoidMask);
           fPasMPInstance.Run(fUpdateJob);
          end;

         end else begin

          fUpdateFrameCounter:=fFrameCounter;

          fDrawFrameCounter:=fFrameCounter;

          fDrawInFlightFrameIndex:=fNextInFlightFrameIndex;

          fUpdateInFlightFrameIndex:=fDrawInFlightFrameIndex;

          Check(fUpdateDeltaTime);

          if fUseExtraUpdateThread and assigned(fUpdateThread) then begin
           fUpdateThread.Invoke;
           fUpdateThread.WaitForDone;
          end else begin
           UpdateJobFunction(nil,0);
          end;

         end;

         if assigned(fVulkanDevice) then begin
          StartTime:=fHighResolutionTimer.GetTime;
          while not AcquireVulkanBackBuffer do begin
           TPasMP.Yield;
          end;
          fTimingCPUAcquire:=fHighResolutionTimer.ToFloatSeconds(fHighResolutionTimer.GetTime-StartTime);
         end;

        end;

        if fVulkanBackBufferState=TVulkanBackBufferState.Present then begin
         try
          CurrentJobWorkerThread:=fPasMPInstance.JobWorkerThread;
          if assigned(CurrentJobWorkerThread) then begin
           CurrentJobWorkerThread.AreaMask:=CurrentJobWorkerThread.AreaMask or PasMPAreaMaskRender;
          end;
          StartTime:=fHighResolutionTimer.GetTime;
          BeginFrame(fUpdateDeltaTime);
          fTimingCPUBeginFrame:=fHighResolutionTimer.ToFloatSeconds(fHighResolutionTimer.GetTime-StartTime);
          DrawJobFunction(nil,0);
          StartTime:=fHighResolutionTimer.GetTime;
          FinishFrame(fSwapChainImageIndex,fVulkanWaitSemaphore,fVulkanWaitFence);
          fTimingCPUFinishFrame:=fHighResolutionTimer.ToFloatSeconds(fHighResolutionTimer.GetTime-StartTime);
          if assigned(CurrentJobWorkerThread) then begin
           CurrentJobWorkerThread.AreaMask:=CurrentJobWorkerThread.AreaMask and not PasMPAreaMaskRender;
          end;
         finally
          if assigned(fVulkanDevice) then begin
           try
            if fUpdateWaitsForGPU then begin
             StartTime:=fHighResolutionTimer.GetTime;
             if fUseExtraUpdateThread and assigned(fUpdateThread) then begin
              fUpdateThread.WaitForDone;
             end else begin
              if assigned(fUpdateJob) then begin
               try
                fPasMPInstance.WaitRelease(fUpdateJob);
               finally
                fUpdateJob:=nil;
               end;
              end;
              while TPasMPInterlocked.Read(fInUpdateJobFunction) do begin
               TPasMP.Yield;
              end;
             end;
             fTimingCPUUpdateWait:=fHighResolutionTimer.ToFloatSeconds(fHighResolutionTimer.GetTime-StartTime);
            end else begin
             fTimingCPUUpdateWait:=0.0;
            end;
           finally
            try
             StartTime:=fHighResolutionTimer.GetTime;
             PresentVulkanBackBuffer;
             fTimingCPUPresent:=fHighResolutionTimer.ToFloatSeconds(fHighResolutionTimer.GetTime-StartTime);
            finally
             PostPresent(fSwapChainImageIndex);
            end;
           end;
          end;
         end;
         inc(fFrameCounter);
         StartTime:=fHighResolutionTimer.GetTime;
         FramePacingAndFrameRateLimiter;
         fTimingCPUFramePacing:=fHighResolutionTimer.ToFloatSeconds(fHighResolutionTimer.GetTime-StartTime);
        end;

       finally
        if fUseExtraUpdateThread and assigned(fUpdateThread) then begin
         fUpdateThread.WaitForDone;
        end else begin
         if assigned(fUpdateJob) then begin
          fPasMPInstance.WaitRelease(fUpdateJob);
         end;
        end;
       end;

      end;

      else {TpvApplicationProcessingMode.Strict:}begin

       if (not assigned(fVulkanDevice)) or AcquireVulkanBackBuffer then begin

        fNowTime:=fHighResolutionTimer.GetTime;
        if fHasLastTime then begin
         fDeltaTime:=fNowTime-fLastTime;
        end else begin
         fDeltaTime:=0;
        end;
        fFloatDeltaTime:=fHighResolutionTimer.ToFloatSeconds(fDeltaTime);
        fLastTime:=fNowTime;
        fHasLastTime:=true;

        UpdateFrameTimesHistory;

        fUpdateDeltaTime:=Min(Max(fFloatDeltaTime,0.0),0.25);

        try

         fTimingCPUFrameStartTime:=fHighResolutionTimer.GetTime;

         if CanBeParallelProcessed and (fCountInFlightFrames>1) then begin

          fDrawFrameCounter:=fFrameCounter-1;

          fUpdateFrameCounter:=fFrameCounter;

          fDrawInFlightFrameIndex:=fCurrentInFlightFrameIndex-1;
          if fDrawInFlightFrameIndex<0 then begin
           inc(fDrawInFlightFrameIndex,fCountInFlightFrames);
          end;

          fUpdateInFlightFrameIndex:=fCurrentInFlightFrameIndex;

          Check(fUpdateDeltaTime);

          StartTime:=fHighResolutionTimer.GetTime;
          BeginFrame(fUpdateDeltaTime);
          fTimingCPUBeginFrame:=fHighResolutionTimer.ToFloatSeconds(fHighResolutionTimer.GetTime-StartTime);

          if fUseExtraUpdateThread and assigned(fUpdateThread) then begin
           fUpdateThread.Invoke;
           DrawJobFunction(nil,fPasMPInstance.GetJobWorkerThreadIndex);
           fUpdateThread.WaitForDone;
          end else begin
           fUpdateJob:=fPasMPInstance.Acquire(UpdateJobFunction,nil,nil,PasMPJobPriorityHigh,PasMPAreaMaskUpdate,PasMPAreaMaskRender,PasMPAffinityMaskUpdateAllowMask,PasMPAffinityMaskUpdateAvoidMask);
           try
            fPasMPInstance.Run(fUpdateJob);
            CurrentJobWorkerThread:=fPasMPInstance.JobWorkerThread;
            if assigned(CurrentJobWorkerThread) then begin
             CurrentJobWorkerThread.AreaMask:=CurrentJobWorkerThread.AreaMask or PasMPAreaMaskRender;
            end;
            DrawJobFunction(nil,fPasMPInstance.GetJobWorkerThreadIndex);
            if assigned(CurrentJobWorkerThread) then begin
             CurrentJobWorkerThread.AreaMask:=CurrentJobWorkerThread.AreaMask and not PasMPAreaMaskRender;
            end;
           finally
            try
             fPasMPInstance.WaitRelease(fUpdateJob);
            finally
             fUpdateJob:=nil;
            end;
           end;
          end;

          StartTime:=fHighResolutionTimer.GetTime;
          FinishFrame(fSwapChainImageIndex,fVulkanWaitSemaphore,fVulkanWaitFence);
          fTimingCPUFinishFrame:=fHighResolutionTimer.ToFloatSeconds(fHighResolutionTimer.GetTime-StartTime);

         end else begin

          fUpdateFrameCounter:=fFrameCounter;

          fDrawFrameCounter:=fFrameCounter;

          fDrawInFlightFrameIndex:=fCurrentInFlightFrameIndex;

          fUpdateInFlightFrameIndex:=fDrawInFlightFrameIndex;

          Check(fUpdateDeltaTime);

          if fUseExtraUpdateThread and assigned(fUpdateThread) then begin
           fUpdateThread.Invoke;
           fUpdateThread.WaitForDone;
          end else begin
           UpdateJobFunction(nil,0);
          end;

          StartTime:=fHighResolutionTimer.GetTime;
          BeginFrame(fUpdateDeltaTime);
          fTimingCPUBeginFrame:=fHighResolutionTimer.ToFloatSeconds(fHighResolutionTimer.GetTime-StartTime);

          DrawJobFunction(nil,0);

          StartTime:=fHighResolutionTimer.GetTime;
          FinishFrame(fSwapChainImageIndex,fVulkanWaitSemaphore,fVulkanWaitFence);
          fTimingCPUFinishFrame:=fHighResolutionTimer.ToFloatSeconds(fHighResolutionTimer.GetTime-StartTime);

         end;

        finally
         if assigned(fVulkanDevice) then begin
          try
           StartTime:=fHighResolutionTimer.GetTime;
           PresentVulkanBackBuffer;
           fTimingCPUPresent:=fHighResolutionTimer.ToFloatSeconds(fHighResolutionTimer.GetTime-StartTime);
          finally
           PostPresent(fSwapChainImageIndex);
          end;
         end;
        end;

        inc(fFrameCounter);

        StartTime:=fHighResolutionTimer.GetTime;
        FramePacingAndFrameRateLimiter;
        fTimingCPUFramePacing:=fHighResolutionTimer.ToFloatSeconds(fHighResolutionTimer.GetTime-StartTime);

       end;

      end;

     end;

    end;

   end else begin
    fDeltaTime:=0;
    Sleep(1);
   end;

  end;

 end else begin
  fDeltaTime:=0;
  Sleep(1);
 end;

 if assigned(fPasMPInstance.Profiler) then begin

  fPasMPInstance.Profiler.Stop(fPasMPProfilerVisibleTimePeriod);

  if assigned(fPasMPInstance.Profiler) then begin
   fPasMPProfilerHistoryCount:=fPasMPInstance.Profiler.Count;
   Move(fPasMPInstance.Profiler.History^,fPasMPProfilerHistory,Min(fPasMPProfilerHistoryCount,PasMPProfilerHistoryRingBufferSize)*SizeOf(TPasMPProfilerHistoryRingBufferItem));
  end;

 end;

end;

{$if defined(Windows) and not (defined(PasVulkanUseSDL2) or defined(PasVulkanHeadless))}

function TpvApplicationWin32WndProc(aHWnd:HWND;uMsg:UINT;wParam:WParam;lParam:LParam):LRESULT; {$ifdef cpu386}stdcall;{$endif}
var WindowPtr:LONG_PTR;
    Application:TpvApplication;
    ResultCode:TpvInt64;
begin
 if aHWnd<>0 then begin
  if uMsg=WM_CREATE then begin
   WindowPtr:=LONG_PTR(PCREATESTRUCT(lParam)^.lpCreateParams);
   SetWindowLongPtrW(aHWnd,GWLP_USERDATA,WindowPtr);
  end;
  Application:=Pointer(LONG_PTR(GetWindowLongPtrW(aHWnd,GWLP_USERDATA)));
 end else begin
  Application:=nil;
 end;
 if assigned(Application) then begin
  ResultCode:=Application.Win32ProcessEvent(uMsg,wParam,lParam);
  if ResultCode>=0 then begin
   result:=ResultCode;
   exit;
  end;
  if assigned(Application.fWin32Callback) then begin
   result:=CallWindowProcW(Application.fWin32Callback,aHWnd,uMsg,wParam,lParam);
   exit;
  end;
 end;
 if uMsg=WM_CLOSE then begin
  // We don't forward the WM_CLOSE message to prevent the OS from automatically destroying the window
  result:=0;
 end else if (uMsg=WM_SYSCOMMAND) and (wParam=SC_KEYMENU) then begin
  // Don't forward the menu system command, so that pressing ALT or F10 doesn't steal the focus
  result:=0;
 end else if (uMsg=WM_NCLBUTTONDOWN) and (wParam=HTCAPTION) then begin
  Application.fWin32NCMouseButton:=uMsg;
  Application.fWin32NCMousePos:=lParam;
  result:=0;
 end else begin
  case uMsg of
   WM_NCCREATE:begin
    if assigned(EnableNonClientDpiScaling) and not assigned(SetProcessDpiAwarenessContext) then begin
     EnableNonClientDpiScaling(aHWND);
    end;
   end;
   WM_NCMOUSEMOVE:begin
    if Application.fWin32NCMouseButton<>0 then begin
     if Application.fWin32NCMousePos<>lParam then begin
      DefWindowProcW(aHWnd,Application.fWin32NCMouseButton,HTCAPTION,Application.fWin32NCMousePos);
      Application.fWin32NCMouseButton:=0;
     end;
    end;
   end;
   WM_MOUSEMOVE:begin
    if Application.fWin32NCMouseButton<>0 then begin
     if Application.fWin32NCMousePos<>lParam then begin
      DefWindowProcW(aHWnd,Application.fWin32NCMouseButton,HTCAPTION,Application.fWin32NCMousePos);
      Application.fWin32NCMouseButton:=0;
     end;
    end;
   end;
   WM_ENTERSIZEMOVE,WM_ENTERMENULOOP:begin
    if assigned(Application.fWin32MainFiber) then begin
     SetTimer(aHWnd,1,1,nil);
    end;
   end;
   WM_EXITSIZEMOVE,WM_EXITMENULOOP:begin
    if assigned(Application.fWin32MainFiber) then begin
     KillTimer(aHWnd,1);
    end;
   end;
   WM_TIMER:begin
    if assigned(Application.fWin32MainFiber) and (wParam=1) then begin
     SwitchToFiber(Application.fWin32MainFiber);
    end;
   end;
  end;
  result:=DefWindowProcW(aHWnd,uMsg,wParam,lParam);
 end;
end;

function TpvApplication.Win32ProcessEvent(aMsg:UINT;aWParam:WParam;aLParam:LParam):TpvInt64;
var Index,FileNameLength,DroppedFileCount,CountInputs,OtherIndex:TpvSizeInt;
    PointerID,TouchID:TpvUInt32;
    NativeEvent:TpvApplicationNativeEvent;
    Rect:TRect;
    DropHandle:HDROP;
    DropPoint:TPoint;
    FileName:WideString;
    TouchInput:PpvApplicationTOUCHINPUT;
    x,y:TpvDouble;
    Point:TPoint;
 function IsTouchOrPenMouseEvent:boolean;
 var MessageExtraInfo:TpvUInt32;
 begin
  MessageExtraInfo:=GetMessageExtraInfo;
  result:=((MessageExtraInfo and $ffffff00)=$ff515700) or ((MessageExtraInfo and $82)=$82);
 end;
 procedure TranslateKeyEvent;
 const ScanCodes:array[0..255] of TpvUInt32=
        (
         KEYCODE_UNKNOWN, // $00
         KEYCODE_ESCAPE, // $01
         KEYCODE_1, // $02
         KEYCODE_2, // $03
         KEYCODE_3, // $04
         KEYCODE_4, // $05
         KEYCODE_5, // $06
         KEYCODE_6, // $07
         KEYCODE_7, // $08
         KEYCODE_8, // $09
         KEYCODE_9, // $0a
         KEYCODE_0, // $0b
         KEYCODE_MINUS, // $0c
         KEYCODE_EQUALS, // $0d
         KEYCODE_BACKSPACE, // $0e
         KEYCODE_TAB, // $0f
         KEYCODE_Q, // $10
         KEYCODE_W, // $11
         KEYCODE_E, // $12
         KEYCODE_R, // $13
         KEYCODE_T, // $14
         KEYCODE_Y, // $15
         KEYCODE_U, // $16
         KEYCODE_I, // $17
         KEYCODE_O, // $18
         KEYCODE_P, // $19
         KEYCODE_LEFTBRACKET, // $1a
         KEYCODE_RIGHTBRACKET, // $1b
         KEYCODE_RETURN, // $1c
         KEYCODE_LCTRL, // $1d
         KEYCODE_A, // $1e
         KEYCODE_S, // $1f
         KEYCODE_D, // $20
         KEYCODE_F, // $21
         KEYCODE_G, // $22
         KEYCODE_H, // $23
         KEYCODE_J, // $24
         KEYCODE_K, // $25
         KEYCODE_L, // $26
         KEYCODE_SEMICOLON, // $27
         KEYCODE_APOSTROPHE, // $28
         KEYCODE_GRAVE, // $29
         KEYCODE_LSHIFT, // $2a
         KEYCODE_BACKSLASH, // $2b
         KEYCODE_Z, // $2c
         KEYCODE_X, // $2d
         KEYCODE_C, // $2e
         KEYCODE_V, // $2f
         KEYCODE_B, // $30
         KEYCODE_N, // $31
         KEYCODE_M, // $32
         KEYCODE_COMMA, // $33
         KEYCODE_PERIOD, // $34
         KEYCODE_SLASH, // $35
         KEYCODE_RSHIFT, // $36
         KEYCODE_KP_MULTIPLY, // $37
         KEYCODE_LALT, // $38
         KEYCODE_SPACE, // $39
         KEYCODE_CAPSLOCK, // $3a
         KEYCODE_F1, // $3b
         KEYCODE_F2, // $3c
         KEYCODE_F3, // $3d
         KEYCODE_F4, // $3e
         KEYCODE_F5, // $3f
         KEYCODE_F6, // $40
         KEYCODE_F7, // $41
         KEYCODE_F8, // $42
         KEYCODE_F9, // $43
         KEYCODE_F10, // $44
         KEYCODE_NUMLOCK, // $45
         KEYCODE_SCROLLLOCK, // $46
         KEYCODE_KP7, // $47
         KEYCODE_KP8, // $48
         KEYCODE_KP9, // $49
         KEYCODE_KP_MINUS, // $4a
         KEYCODE_KP4, // $4b
         KEYCODE_KP5, // $4c
         KEYCODE_KP6, // $4d
         KEYCODE_KP_PLUS, // $4e
         KEYCODE_KP1, // $4f
         KEYCODE_KP2, // $50
         KEYCODE_KP3, // $51
         KEYCODE_KP0, // $52
         KEYCODE_KP_PERIOD, // $53
         KEYCODE_UNKNOWN, // $54
         KEYCODE_UNKNOWN, // $55
         KEYCODE_NONUSBACKSLASH, // $56
         KEYCODE_F11, // $57
         KEYCODE_F12, // $58
         KEYCODE_KP_EQUALS, // $59
         KEYCODE_UNKNOWN, // $5a
         KEYCODE_UNKNOWN, // $5b
         KEYCODE_INTERNATIONAL6, // $5c
         KEYCODE_UNKNOWN, // $5d
         KEYCODE_UNKNOWN, // $5e
         KEYCODE_UNKNOWN, // $5f
         KEYCODE_UNKNOWN, // $60
         KEYCODE_UNKNOWN, // $61
         KEYCODE_UNKNOWN, // $62
         KEYCODE_UNKNOWN, // $63
         KEYCODE_F13, // $64
         KEYCODE_F14, // $65
         KEYCODE_F15, // $66
         KEYCODE_F16, // $67
         KEYCODE_F17, // $68
         KEYCODE_F18, // $69
         KEYCODE_F19, // $6a
         KEYCODE_F20, // $6b
         KEYCODE_F21, // $6c
         KEYCODE_F22, // $6d
         KEYCODE_F23, // $6e
         KEYCODE_UNKNOWN, // $6f
         KEYCODE_INTERNATIONAL2, // $70
         KEYCODE_LANG2, // $71
         KEYCODE_LANG1, // $72
         KEYCODE_INTERNATIONAL1, // $73
         KEYCODE_UNKNOWN, // $74
         KEYCODE_UNKNOWN, // $75
         KEYCODE_F24, // $76
         KEYCODE_LANG4, // $77
         KEYCODE_LANG3, // $78
         KEYCODE_INTERNATIONAL4, // $79
         KEYCODE_UNKNOWN, // $7a
         KEYCODE_INTERNATIONAL5, // $7b
         KEYCODE_UNKNOWN, // $7c
         KEYCODE_INTERNATIONAL3, // $7d
         KEYCODE_KP_COMMA, // $7e
         KEYCODE_UNKNOWN, // $7f
         KEYCODE_UNKNOWN, // $e000
         KEYCODE_UNKNOWN, // $e001
         KEYCODE_UNKNOWN, // $e002
         KEYCODE_UNKNOWN, // $e003
         KEYCODE_UNKNOWN, // $e004
         KEYCODE_UNKNOWN, // $e005
         KEYCODE_UNKNOWN, // $e006
         KEYCODE_UNKNOWN, // $e007
         KEYCODE_UNKNOWN, // $e008
         KEYCODE_UNKNOWN, // $e009
         KEYCODE_PASTE, // $e00a
         KEYCODE_UNKNOWN, // $e00b
         KEYCODE_UNKNOWN, // $e00c
         KEYCODE_UNKNOWN, // $e00d
         KEYCODE_UNKNOWN, // $e00e
         KEYCODE_UNKNOWN, // $e00f
         KEYCODE_AUDIOPREV, // $e010
         KEYCODE_UNKNOWN, // $e011
         KEYCODE_UNKNOWN, // $e012
         KEYCODE_UNKNOWN, // $e013
         KEYCODE_UNKNOWN, // $e014
         KEYCODE_UNKNOWN, // $e015
         KEYCODE_UNKNOWN, // $e016
         KEYCODE_CUT, // $e017
         KEYCODE_COPY, // $e018
         KEYCODE_AUDIONEXT, // $e019
         KEYCODE_UNKNOWN, // $e01a
         KEYCODE_UNKNOWN, // $e01b
         KEYCODE_KP_ENTER, // $e01c
         KEYCODE_RCTRL, // $e01d
         KEYCODE_UNKNOWN, // $e01e
         KEYCODE_UNKNOWN, // $e01f
         KEYCODE_MUTE, // $e020
         KEYCODE_UNKNOWN, // $e021 // LaunchApp2
         KEYCODE_AUDIOPLAY, // $e022
         KEYCODE_UNKNOWN, // $e023
         KEYCODE_AUDIOSTOP, // $e024
         KEYCODE_UNKNOWN, // $e025
         KEYCODE_UNKNOWN, // $e026
         KEYCODE_UNKNOWN, // $e027
         KEYCODE_UNKNOWN, // $e028
         KEYCODE_UNKNOWN, // $e029
         KEYCODE_UNKNOWN, // $e02a
         KEYCODE_UNKNOWN, // $e02b
         KEYCODE_EJECT, // $e02c
         KEYCODE_UNKNOWN, // $e02d
         KEYCODE_VOLUMEDOWN, // $e02e
         KEYCODE_UNKNOWN, // $e02f
         KEYCODE_VOLUMEUP, // $e030
         KEYCODE_UNKNOWN, // $e031
         KEYCODE_AC_HOME, // $e032
         KEYCODE_UNKNOWN, // $e033
         KEYCODE_UNKNOWN, // $e034
         KEYCODE_KP_DIVIDE, // $e035
         KEYCODE_UNKNOWN, // $e036
         KEYCODE_PRINTSCREEN, // $e037
         KEYCODE_RALT, // $e038
         KEYCODE_UNKNOWN, // $e039
         KEYCODE_UNKNOWN, // $e03a
         KEYCODE_HELP, // $e03b
         KEYCODE_UNKNOWN, // $e03c
         KEYCODE_UNKNOWN, // $e03d
         KEYCODE_UNKNOWN, // $e03e
         KEYCODE_UNKNOWN, // $e03f
         KEYCODE_UNKNOWN, // $e040
         KEYCODE_UNKNOWN, // $e041
         KEYCODE_UNKNOWN, // $e042
         KEYCODE_UNKNOWN, // $e043
         KEYCODE_UNKNOWN, // $e044
         KEYCODE_NUMLOCK, // $e045
         KEYCODE_PAUSE, // $e046
         KEYCODE_HOME, // $e047
         KEYCODE_UP, // $e048
         KEYCODE_PAGEUP, // $e049
         KEYCODE_UNKNOWN, // $e04a
         KEYCODE_LEFT, // $e04b
         KEYCODE_UNKNOWN, // $e04c
         KEYCODE_RIGHT, // $e04d
         KEYCODE_UNKNOWN, // $e04e
         KEYCODE_END, // $e04f
         KEYCODE_DOWN, // $e050
         KEYCODE_PAGEDOWN, // $e051
         KEYCODE_INSERT, // $e052
         KEYCODE_DELETE, // $e053
         KEYCODE_UNKNOWN, // $e054
         KEYCODE_UNKNOWN, // $e055
         KEYCODE_UNKNOWN, // $e056
         KEYCODE_UNKNOWN, // $e057
         KEYCODE_UNKNOWN, // $e058
         KEYCODE_UNKNOWN, // $e059
         KEYCODE_UNKNOWN, // $e05a
         KEYCODE_LGUI, // $e05b
         KEYCODE_RGUI, // $e05c
         KEYCODE_APPLICATION, // $e05d
         KEYCODE_POWER, // $e05e
         KEYCODE_SLEEP, // $e05f
         KEYCODE_UNKNOWN, // $e060
         KEYCODE_UNKNOWN, // $e061
         KEYCODE_UNKNOWN, // $e062
         KEYCODE_UNKNOWN, // $e063
         KEYCODE_UNKNOWN, // $e064
         KEYCODE_AC_SEARCH, // $e065
         KEYCODE_AC_BOOKMARKS, // $e066
         KEYCODE_AC_REFRESH, // $e067
         KEYCODE_AC_STOP, // $e068
         KEYCODE_AC_FORWARD, // $e069
         KEYCODE_AC_BACK, // $e06a
         KEYCODE_APPLICATION, // $e06b
         KEYCODE_MAIL, // $e06c
         KEYCODE_MEDIASELECT, // $e06d
         KEYCODE_UNKNOWN, // $e06e
         KEYCODE_UNKNOWN, // $e06f
         KEYCODE_UNKNOWN, // $e070
         KEYCODE_UNKNOWN, // $e071
         KEYCODE_UNKNOWN, // $e072
         KEYCODE_UNKNOWN, // $e073
         KEYCODE_UNKNOWN, // $e074
         KEYCODE_UNKNOWN, // $e075
         KEYCODE_UNKNOWN, // $e076
         KEYCODE_UNKNOWN, // $e077
         KEYCODE_UNKNOWN, // $e078
         KEYCODE_UNKNOWN, // $e079
         KEYCODE_UNKNOWN, // $e07a
         KEYCODE_UNKNOWN, // $e07b
         KEYCODE_UNKNOWN, // $e07c
         KEYCODE_UNKNOWN, // $e07d
         KEYCODE_UNKNOWN, // $e07e
         KEYCODE_UNKNOWN  // $e07f
        );
 var VirtualKey:WPARAM;
     ScanCode,KeyFlags:DWORD;
     Extended:Boolean;
 begin

  NativeEvent.KeyRepeat:=(HIWORD(aLParam) and KF_REPEAT)<>0;

  VirtualKey:=aWParam;
  ScanCode:=(aLParam and $00ff0000) shr 16;
  Extended:=(aLParam and $01000000)<>0;
  KeyFlags:=aLParam shr 16;

  case VirtualKey of
   VK_SHIFT:begin
    VirtualKey:=MapVirtualKey(ScanCode,MAPVK_VSC_TO_VK_EX);
   end;
   VK_CONTROL:begin
    if Extended then begin
     VirtualKey:=VK_RCONTROL;
    end else begin
     VirtualKey:=VK_LCONTROL;
    end;
   end;
   VK_MENU:begin
    if Extended then begin
     VirtualKey:=VK_RMENU;
    end else begin
     VirtualKey:=VK_LMENU;
    end;
   end;
  end;

  case VirtualKey of
   VK_F1:begin
    NativeEvent.KeyCode:=KEYCODE_F1;
   end;
   VK_F2:begin
    NativeEvent.KeyCode:=KEYCODE_F2;
   end;
   VK_F3:begin
    NativeEvent.KeyCode:=KEYCODE_F3;
   end;
   VK_F4:begin
    NativeEvent.KeyCode:=KEYCODE_F4;
   end;
   VK_F5:begin
    NativeEvent.KeyCode:=KEYCODE_F5;
   end;
   VK_F6:begin
    NativeEvent.KeyCode:=KEYCODE_F6;
   end;
   VK_F7:begin
    NativeEvent.KeyCode:=KEYCODE_F7;
   end;
   VK_F8:begin
    NativeEvent.KeyCode:=KEYCODE_F8;
   end;
   VK_F9:begin
    NativeEvent.KeyCode:=KEYCODE_F9;
   end;
   VK_F10:begin
    NativeEvent.KeyCode:=KEYCODE_F10;
   end;
   VK_F11:begin
    NativeEvent.KeyCode:=KEYCODE_F11;
   end;
   VK_F12:begin
    NativeEvent.KeyCode:=KEYCODE_F12;
   end;
   VK_F13:begin
    NativeEvent.KeyCode:=KEYCODE_F13;
   end;
   VK_F14:begin
    NativeEvent.KeyCode:=KEYCODE_F14;
   end;
   VK_F15:begin
    NativeEvent.KeyCode:=KEYCODE_F15;
   end;
   ord('A')..ord('Z'):begin
    NativeEvent.KeyCode:=(VirtualKey-ord('A'))+KEYCODE_A;
   end;
   ord('0')..ord('9'):begin
    NativeEvent.KeyCode:=(VirtualKey-ord('0'))+KEYCODE_0;
   end;
   VK_ESCAPE:begin
    NativeEvent.KeyCode:=KEYCODE_ESCAPE;
   end;
   VK_LCONTROL:begin
    NativeEvent.KeyCode:=KEYCODE_LCTRL;
   end;
   VK_LSHIFT:begin
    NativeEvent.KeyCode:=KEYCODE_LSHIFT;
   end;
   VK_LMENU:begin
    NativeEvent.KeyCode:=KEYCODE_LALT;
   end;
   VK_LWIN:begin
    NativeEvent.KeyCode:=KEYCODE_LGUI;
   end;
   VK_RCONTROL:begin
    NativeEvent.KeyCode:=KEYCODE_RCTRL;
   end;
   VK_RSHIFT:begin
    NativeEvent.KeyCode:=KEYCODE_RSHIFT;
   end;
   VK_RMENU:begin
    NativeEvent.KeyCode:=KEYCODE_RALT;
   end;
   VK_RWIN:begin
    NativeEvent.KeyCode:=KEYCODE_RGUI;
   end;
   VK_APPS:begin
    NativeEvent.KeyCode:=KEYCODE_APPLICATION;
   end;
   VK_OEM_4:begin
    NativeEvent.KeyCode:=KEYCODE_LEFTBRACKET;
   end;
   VK_OEM_6:begin
    NativeEvent.KeyCode:=KEYCODE_RIGHTBRACKET;
   end;
   VK_OEM_1:begin
    NativeEvent.KeyCode:=KEYCODE_SEMICOLON;
   end;
   VK_OEM_COMMA:begin
    NativeEvent.KeyCode:=KEYCODE_COMMA;
   end;
   VK_OEM_PERIOD:begin
    NativeEvent.KeyCode:=KEYCODE_PERIOD;
   end;
   VK_OEM_7:begin
    NativeEvent.KeyCode:=KEYCODE_APOSTROPHE;
   end;
   VK_OEM_2:begin
    NativeEvent.KeyCode:=KEYCODE_SLASH;
   end;
   VK_OEM_5:begin
    NativeEvent.KeyCode:=KEYCODE_BACKSLASH;
   end;
   VK_OEM_3:begin
    NativeEvent.KeyCode:=KEYCODE_TILDE;
   end;
   VK_OEM_PLUS:begin
    NativeEvent.KeyCode:=KEYCODE_EQUALS;
   end;
   VK_OEM_MINUS:begin
    NativeEvent.KeyCode:=KEYCODE_MINUS;
   end;
   VK_SPACE:begin
    NativeEvent.KeyCode:=KEYCODE_SPACE;
   end;
   VK_RETURN:begin
    NativeEvent.KeyCode:=KEYCODE_RETURN;
   end;
   VK_ADD:begin
    NativeEvent.KeyCode:=KEYCODE_PLUS;
   end;
   VK_SUBTRACT:begin
    NativeEvent.KeyCode:=KEYCODE_MINUS;
   end;
   VK_MULTIPLY:begin
    NativeEvent.KeyCode:=KEYCODE_ASTERISK;
   end;
   VK_DIVIDE:begin
    NativeEvent.KeyCode:=KEYCODE_SLASH;
   end;
   VK_NUMPAD0..VK_NUMPAD9:begin
    NativeEvent.KeyCode:=(VirtualKey-VK_NUMPAD0)+KEYCODE_KP0;
   end;
   VK_BACK:begin
    NativeEvent.KeyCode:=KEYCODE_BACKSPACE;
   end;
   VK_TAB:begin
    NativeEvent.KeyCode:=KEYCODE_TAB;
   end;
   VK_PRIOR:begin
    NativeEvent.KeyCode:=KEYCODE_PAGEUP;
   end;
   VK_NEXT:begin
    NativeEvent.KeyCode:=KEYCODE_PAGEDOWN;
   end;
   VK_END:begin
    NativeEvent.KeyCode:=KEYCODE_END;
   end;
   VK_HOME:begin
    NativeEvent.KeyCode:=KEYCODE_HOME;
   end;
   VK_INSERT:begin
    NativeEvent.KeyCode:=KEYCODE_INSERT;
   end;
   VK_DELETE:begin
    NativeEvent.KeyCode:=KEYCODE_DELETE;
   end;
   VK_LEFT:begin
    NativeEvent.KeyCode:=KEYCODE_LEFT;
   end;
   VK_RIGHT:begin
    NativeEvent.KeyCode:=KEYCODE_RIGHT;
   end;
   VK_UP:begin
    NativeEvent.KeyCode:=KEYCODE_UP;
   end;
   VK_DOWN:begin
    NativeEvent.KeyCode:=KEYCODE_DOWN;
   end;
   VK_PAUSE:begin
    NativeEvent.KeyCode:=KEYCODE_PAUSE;
   end;
   {VK_OEM_102}$e2:begin
    NativeEvent.KeyCode:=KEYCODE_102ND;
   end;
   $f2:begin
    NativeEvent.KeyCode:=KEYCODE_KATAKANAHIRAGANA;
   end;
   $1c:begin
    NativeEvent.KeyCode:=KEYCODE_HENKAN;
   end;
   $1d:begin
    NativeEvent.KeyCode:=KEYCODE_MUHENKAN;
   end;
   $15:begin
    NativeEvent.KeyCode:=KEYCODE_HANGEUL;
   end;
   $19:begin
    NativeEvent.KeyCode:=KEYCODE_HANJA;
   end;
   else begin
    NativeEvent.KeyCode:=KEYCODE_UNKNOWN;
   end;
  end;

  ScanCode:=ScanCode and not $80;

  if ScanCode<>0 then begin
   if (KeyFlags and KF_EXTENDED)=KF_EXTENDED then begin
    ScanCode:=ScanCode or $e000;
   end else if ScanCode=$45 then begin
    ScanCode:=$e046;
   end;
  end else begin
   ScanCode:=MapVirtualKey(aWParam and $ffff,MAPVK_VK_TO_VSC_EX);
   if ScanCode=$e11d then begin
    ScanCode:=$e046;
   end;
  end;

  NativeEvent.ScanCode:=ScanCodes[(ScanCode and $ff) or IfThen((ScanCode and $ff00)<>0,$80,$00)];

  NativeEvent.KeyModifiers:=[];

{ FillChar(fWin32KeyState,SizeOf(fWin32KeyState),#0);

  if GetKeyboardState(fWin32KeyState) then} begin

   if HIWORD(GetAsyncKeyState(VK_MENU))<>0 then begin
    NativeEvent.KeyModifiers:=NativeEvent.KeyModifiers+[TpvApplicationInputKeyModifier.ALT];
   end;
   if HIWORD(GetAsyncKeyState(VK_LMENU))<>0 then begin
    NativeEvent.KeyModifiers:=NativeEvent.KeyModifiers+[TpvApplicationInputKeyModifier.ALT,TpvApplicationInputKeyModifier.LALT];
   end;
   if HIWORD(GetAsyncKeyState(VK_RMENU))<>0 then begin
    NativeEvent.KeyModifiers:=NativeEvent.KeyModifiers+[TpvApplicationInputKeyModifier.ALT,TpvApplicationInputKeyModifier.RALT];
   end;

   if HIWORD(GetAsyncKeyState(VK_CONTROL))<>0 then begin
    NativeEvent.KeyModifiers:=NativeEvent.KeyModifiers+[TpvApplicationInputKeyModifier.CTRL];
   end;
   if HIWORD(GetAsyncKeyState(VK_LCONTROL))<>0 then begin
    NativeEvent.KeyModifiers:=NativeEvent.KeyModifiers+[TpvApplicationInputKeyModifier.CTRL,TpvApplicationInputKeyModifier.LCTRL];
   end;
   if HIWORD(GetAsyncKeyState(VK_RCONTROL))<>0 then begin
    NativeEvent.KeyModifiers:=NativeEvent.KeyModifiers+[TpvApplicationInputKeyModifier.CTRL,TpvApplicationInputKeyModifier.RCTRL];
   end;

   if HIWORD(GetAsyncKeyState(VK_SHIFT))<>0 then begin
    NativeEvent.KeyModifiers:=NativeEvent.KeyModifiers+[TpvApplicationInputKeyModifier.SHIFT];
   end;
   if HIWORD(GetAsyncKeyState(VK_LSHIFT))<>0 then begin
    NativeEvent.KeyModifiers:=NativeEvent.KeyModifiers+[TpvApplicationInputKeyModifier.SHIFT,TpvApplicationInputKeyModifier.LSHIFT];
   end;
   if HIWORD(GetAsyncKeyState(VK_RSHIFT))<>0 then begin
    NativeEvent.KeyModifiers:=NativeEvent.KeyModifiers+[TpvApplicationInputKeyModifier.SHIFT,TpvApplicationInputKeyModifier.RSHIFT];
   end;

   if HIWORD(GetAsyncKeyState(VK_LWIN))<>0 then begin
    NativeEvent.KeyModifiers:=NativeEvent.KeyModifiers+[TpvApplicationInputKeyModifier.META,TpvApplicationInputKeyModifier.LMETA];
   end;
   if HIWORD(GetAsyncKeyState(VK_RWIN))<>0 then begin
    NativeEvent.KeyModifiers:=NativeEvent.KeyModifiers+[TpvApplicationInputKeyModifier.META,TpvApplicationInputKeyModifier.RMETA];
   end;

   if (GetAsyncKeyState(VK_CAPITAL) and $0001)<>0 then begin
    NativeEvent.KeyModifiers:=NativeEvent.KeyModifiers+[TpvApplicationInputKeyModifier.CAPS];
   end;

   if (GetAsyncKeyState(VK_NUMLOCK) and $0001)<>0 then begin
    NativeEvent.KeyModifiers:=NativeEvent.KeyModifiers+[TpvApplicationInputKeyModifier.NUM];
   end;

   if (GetAsyncKeyState(VK_SCROLL) and $0001)<>0 then begin
    NativeEvent.KeyModifiers:=NativeEvent.KeyModifiers+[TpvApplicationInputKeyModifier.SCROLL];
   end;

  end;

 end;
 procedure TranslateMouseCoord;
 var MouseCoordX,MouseCoordY,DeltaX,DeltaY:TpvInt32;
     Point:TPoint;
 begin
{ if fRelativeMouse and
     ((NativeEvent.MouseCoordX<0) or (NativeEvent.MouseCoordX>=fWidth) or
      (NativeEvent.MouseCoordY<0) or (NativeEvent.MouseCoordY>=fHeight)) then begin
   MouseCoordX:=NativeEvent.MouseCoordX;
   MouseCoordY:=NativeEvent.MouseCoordY;
   DeltaX:=((((MouseCoordX+fWidth) mod fWidth)+fWidth) mod fWidth)-MouseCoordX;
   DeltaY:=((((MouseCoordY+fHeight) mod fHeight)+fHeight) mod fHeight)-MouseCoordX;
   inc(MouseCoordX,DeltaX);
   inc(MouseCoordY,DeltaY);
   inc(fWin32MouseCoordX,DeltaX);
   inc(fWin32MouseCoordY,DeltaY);
   NativeEvent.MouseCoordX:=MouseCoordX;
   NativeEvent.MouseCoordY:=MouseCoordY;
   if GetWindowRect(pvApplication.fWin32Handle,Rect) then begin
    Windows.SetCursorPos(Rect.Left+NativeEvent.MouseCoordX,Rect.Top+NativeEvent.MouseCoordY);
   end;
  end;}
  NativeEvent.MouseCoordX:=TpvInt16(LOWORD(aLParam));
  NativeEvent.MouseCoordY:=TpvInt16(HIWORD(aLParam));
  if fRelativeMouse then begin
   NativeEvent.MouseDeltaX:=NativeEvent.MouseCoordX-((fWidth+1) shr 1);
   NativeEvent.MouseDeltaY:=NativeEvent.MouseCoordY-((fHeight+1) shr 1);
   if ((NativeEvent.MouseDeltaX<>0) or (NativeEvent.MouseDeltaY<>0)) and GetWindowRect(pvApplication.fWin32Handle,Rect) then begin
    Point.x:=(fWidth+1) shr 1;
    Point.y:=(fHeight+1) shr 1;
    if ClientToScreen(fWin32Handle,Point) then begin
     Windows.SetCursorPos(Point.x,Point.y);
    end;
   end;
  end else begin
   NativeEvent.MouseDeltaX:=NativeEvent.MouseCoordX-fWin32MouseCoordX;
   NativeEvent.MouseDeltaY:=NativeEvent.MouseCoordY-fWin32MouseCoordY;
  end;
  fWin32MouseCoordX:=NativeEvent.MouseCoordX;
  fWin32MouseCoordY:=NativeEvent.MouseCoordY;
 end;
 procedure TranslateMouseEventModifier;
 var Modifiers:TpvUInt32;
 begin
  Modifiers:=LOWORD(aWParam);
  NativeEvent.MouseKeyModifiers:=[];
  if (Modifiers and MK_CONTROL)<>0 then begin
   NativeEvent.MouseKeyModifiers:=NativeEvent.MouseKeyModifiers+[TpvApplicationInputKeyModifier.CTRL,TpvApplicationInputKeyModifier.LCTRL,TpvApplicationInputKeyModifier.RCTRL];
  end;
  if (Modifiers and MK_SHIFT)<>0 then begin
   NativeEvent.MouseKeyModifiers:=NativeEvent.MouseKeyModifiers+[TpvApplicationInputKeyModifier.SHIFT,TpvApplicationInputKeyModifier.LSHIFT,TpvApplicationInputKeyModifier.RSHIFT];
  end;
  if (Modifiers and MK_LBUTTON)<>0 then begin
   NativeEvent.MouseButtons:=NativeEvent.MouseButtons+[TpvApplicationInputPointerButton.Left];
  end;
  if (Modifiers and MK_RBUTTON)<>0 then begin
   NativeEvent.MouseButtons:=NativeEvent.MouseButtons+[TpvApplicationInputPointerButton.Right];
  end;
  if (Modifiers and MK_MBUTTON)<>0 then begin
   NativeEvent.MouseButtons:=NativeEvent.MouseButtons+[TpvApplicationInputPointerButton.Middle];
  end;
  if (Modifiers and {$ifdef fpc}MK_XBUTTON1{$else}$20{$endif})<>0 then begin
   NativeEvent.MouseButtons:=NativeEvent.MouseButtons+[TpvApplicationInputPointerButton.X1];
  end;
  if (Modifiers and {$ifdef fpc}MK_XBUTTON1{$else}$40{$endif})<>0 then begin
   NativeEvent.MouseButtons:=NativeEvent.MouseButtons+[TpvApplicationInputPointerButton.X2];
  end;
 end;
 procedure TranslateMouseEvent;
 begin
  NativeEvent.MouseButton:=TpvApplicationInputPointerButton.None;
  NativeEvent.MouseButtons:=[];
  TranslateMouseCoord;
  TranslateMouseEventModifier;
 end;
 procedure TranslateMouseButtonEvent;
 var Rect:TRect;
     Point:TPoint;
 begin
  case aMsg of
   WM_LBUTTONDOWN,
   WM_LBUTTONUP:begin
    NativeEvent.MouseButton:=TpvApplicationInputPointerButton.Left;
    NativeEvent.MouseButtons:=NativeEvent.MouseButtons+[TpvApplicationInputPointerButton.Left];
   end;
   WM_RBUTTONDOWN,
   WM_RBUTTONUP:begin
    NativeEvent.MouseButton:=TpvApplicationInputPointerButton.Right;
    NativeEvent.MouseButtons:=NativeEvent.MouseButtons+[TpvApplicationInputPointerButton.Right];
   end;
   WM_MBUTTONDOWN,
   WM_MBUTTONUP:begin
    NativeEvent.MouseButton:=TpvApplicationInputPointerButton.Middle;
    NativeEvent.MouseButtons:=NativeEvent.MouseButtons+[TpvApplicationInputPointerButton.Middle];
   end;
   WM_XBUTTONDOWN,
   WM_XBUTTONUP:begin
    if HIWORD(aWParam)={$ifdef fpc}XBUTTON1{$else}TpvUInt16($0001){$endif} then begin
     NativeEvent.MouseButton:=TpvApplicationInputPointerButton.X1;
     NativeEvent.MouseButtons:=NativeEvent.MouseButtons+[TpvApplicationInputPointerButton.X1];
    end else begin
     NativeEvent.MouseButton:=TpvApplicationInputPointerButton.X2;
     NativeEvent.MouseButtons:=NativeEvent.MouseButtons+[TpvApplicationInputPointerButton.X2];
    end;
   end;
   else begin
    NativeEvent.MouseButton:=TpvApplicationInputPointerButton.None;
   end;
  end;
  NativeEvent.MouseCoordX:=TpvInt16(LOWORD(aLParam));
  NativeEvent.MouseCoordY:=TpvInt16(HIWORD(aLParam));
  if fRelativeMouse then begin
   NativeEvent.MouseDeltaX:=NativeEvent.MouseCoordX-((fWidth+1) shr 1);
   NativeEvent.MouseDeltaY:=NativeEvent.MouseCoordY-((fHeight+1) shr 1);
   if ((NativeEvent.MouseDeltaX<>0) or (NativeEvent.MouseDeltaY<>0)) and GetWindowRect(pvApplication.fWin32Handle,Rect) then begin
    Point.x:=(fWidth+1) shr 1;
    Point.y:=(fHeight+1) shr 1;
    if ClientToScreen(fWin32Handle,Point) then begin
     Windows.SetCursorPos(Point.x,Point.y);
    end;
   end;
  end else begin
   NativeEvent.MouseDeltaX:=NativeEvent.MouseCoordX-fWin32MouseCoordX;
   NativeEvent.MouseDeltaY:=NativeEvent.MouseCoordY-fWin32MouseCoordY;
  end;
  fWin32MouseCoordX:=NativeEvent.MouseCoordX;
  fWin32MouseCoordY:=NativeEvent.MouseCoordY;
 end;
 procedure TranslateMouseWheelEvent;
 begin
  if aMsg=WM_MOUSEHWHEEL then begin
   NativeEvent.MouseScrollOffsetX:=TpvInt16(HIWORD(aWParam))/WHEEL_DELTA;
  end else begin
   NativeEvent.MouseScrollOffsetX:=0.0;
  end;
  if aMsg=WM_MOUSEWHEEL then begin
   NativeEvent.MouseScrollOffsetY:=TpvInt16(HIWORD(aWParam))/WHEEL_DELTA;
  end else begin
   NativeEvent.MouseScrollOffsetY:=0.0;
  end;
 end;
 function TranslatePointer:boolean;
 var PointerType:TpvApplicationPOINTER_INPUT_TYPE;
     PointerInfo:TpvApplicationCOMBINED_POINTER_INFO;
     Pressure:TpvFloat;
     IsNewTouchID:boolean;
 begin
  result:=false;
  begin
   Pressure:=0.0;
   PointerID:=LOWORD(aWParam);
   PointerType:=PT_POINTER;
   if not GetPointerType(PointerID,@PointerType) then begin
    PointerType:=PT_POINTER;
   end;
   case PointerType of
    PT_TOUCH:begin
     if not GetPointerTouchInfo(PointerID,@PointerInfo.pointerTouchInfo) then begin
      exit;
     end;
     Pressure:=Min(Max(PointerInfo.pointerTouchInfo.pressure/1024.0,0.0),1.0);
    end;
    PT_PEN:begin
     if not GetPointerPenInfo(PointerID,@PointerInfo.pointerPenInfo) then begin
      exit;
     end;
     if PointerInfo.pointerPenInfo.pressure=0 then begin
      Pressure:=1.0;
     end else begin
      Pressure:=Min(Max(PointerInfo.pointerPenInfo.pressure/1024.0,0.0),1.0);
     end;
    end;
    else begin
     exit;
    end;
   end;
   TouchID:=$ffffffff;
   IsNewTouchID:=not fWin32TouchIDHashMap.TryGet(PointerID,TouchID);
   if IsNewTouchID then begin
    if not fWin32TouchIDFreeList.Dequeue(TouchID) then begin
     repeat
      TouchID:=fWin32TouchIDCounter;
      inc(fWin32TouchIDCounter);
     until TouchID<>0;
    end;
    fWin32TouchIDHashMap.Add(PointerID,TouchID);
   end;
   if (TouchID<>$ffffffff) and
      (TpvSizeInt(TouchID)<length(fWin32TouchLastX)) and
      (TpvSizeInt(TouchID)<length(fWin32TouchLastY)) then begin
    Point:=PointerInfo.pointerInfo.ptPixelLocation;
    if ScreenToClient(fWin32Handle,Point) then begin
     x:=Point.x;
     y:=Point.y;
    end else begin
     x:=fWin32TouchLastX[TouchID];
     y:=fWin32TouchLastY[TouchID];
    end;
{$if false}
    writeln('Msg: ',aMsg:16,' - ',
            'Pressure: ',Pressure:1:8,' - ',
            'Flags: $',IntToHex(TpvInt64(PointerInfo.pointerInfo.pointerFlags),8),' - ',
            'InContact: ',(ord((PointerInfo.pointerInfo.pointerFlags and POINTER_FLAG_INCONTACT)<>0) and 1):1,' - ',
            'Down: ',(ord((PointerInfo.pointerInfo.pointerFlags and POINTER_FLAG_DOWN)<>0) and 1):1,' - ',
            'Up: ',(ord((PointerInfo.pointerInfo.pointerFlags and POINTER_FLAG_UP)<>0) and 1):1,' - ',
            'PointerID: ',PointerID:8,' - ',
            'TouchID: ',TouchID:8,' - ',
            '');
{$ifend}
    if (aMsg=WM_POINTERDOWN) or
       ((PointerInfo.pointerInfo.pointerFlags and POINTER_FLAG_DOWN)<>0) or
       (((PointerInfo.pointerInfo.pointerFlags and POINTER_FLAG_INCONTACT)<>0) and IsNewTouchID) then begin
     NativeEvent.Kind:=TpvApplicationNativeEventKind.TouchDown;
     fWin32TouchLastX[TouchID]:=x;
     fWin32TouchLastY[TouchID]:=y;
    end else if (aMsg=WM_POINTERUP) or
                ((PointerInfo.pointerInfo.pointerFlags and POINTER_FLAG_UP)<>0) or
                ((PointerInfo.pointerInfo.pointerFlags and POINTER_FLAG_INCONTACT)=0) then begin
     NativeEvent.Kind:=TpvApplicationNativeEventKind.TouchUp;
     fWin32TouchIDHashMap.Delete(PointerID);
     fWin32TouchIDFreeList.Enqueue(TouchID);
    end else if (PointerInfo.pointerInfo.pointerFlags and POINTER_FLAG_INCONTACT)<>0 then begin
     NativeEvent.Kind:=TpvApplicationNativeEventKind.TouchMotion;
    end else begin
     // Ignore
     exit;
    end;
    NativeEvent.TouchID:=TouchID;
    NativeEvent.TouchX:=x;
    NativeEvent.TouchY:=y;
    NativeEvent.TouchDeltaX:=x-fWin32TouchLastX[TouchID];
    NativeEvent.TouchDeltaY:=y-fWin32TouchLastY[TouchID];
    NativeEvent.TouchPressure:=Pressure;
    NativeEvent.TouchPen:=PointerType=PT_PEN;
    fWin32TouchLastX[TouchID]:=x;
    fWin32TouchLastY[TouchID]:=y;
    fNativeEventQueue.Enqueue(NativeEvent);
   end else begin
    exit;
   end;
  end;
  result:=true;
 end;
begin
 result:=-1;
 case aMsg of
  WM_SIZE:begin
   if GetClientRect(fWin32Handle,Rect) then begin
    NativeEvent.Kind:=TpvApplicationNativeEventKind.Resize;
    NativeEvent.ResizeWidth:=Rect.Right-Rect.Left;
    NativeEvent.ResizeHeight:=Rect.Bottom-Rect.Top;
    fNativeEventQueue.Enqueue(NativeEvent);
    if fCatchMouse then begin
     if GetWindowRect(fWin32Handle,Rect) then begin
      if ClientToScreen(fWin32Handle,Rect.TopLeft) and ClientToScreen(fWin32Handle,Rect.BottomRight) then begin
       ClipCursor({$ifdef fpc}Rect{$else}@Rect{$endif});
      end;
     end;
    end;
   end;
  end;
  WM_CLOSE:begin
   NativeEvent.Kind:=TpvApplicationNativeEventKind.Close;
   fNativeEventQueue.Enqueue(NativeEvent);
  end;
  WM_DESTROY:begin
   NativeEvent.Kind:=TpvApplicationNativeEventKind.Destroy;
   fNativeEventQueue.Enqueue(NativeEvent);
  end;
  WM_SETCURSOR:begin
   if LOWORD(aLParam)=HTCLIENT then begin
    SetCursor(fWin32Cursor);
   end;
  end;
  WM_DROPFILES:begin
   DropHandle:=aWParam;
   if DropHandle<>0 then begin
    FileName:='';
    try
     try
      DragQueryPoint(DropHandle,{$ifdef fpc}@DropPoint{$else}DropPoint{$endif});
      DroppedFileCount:=DragQueryFile(DropHandle,$ffffffff,nil,0);
      for Index:=0 to DroppedFileCount-1 do begin
       FileNameLength:=DragQueryFileW(DropHandle,Index,nil,0);
       if FileNameLength>0 then begin
        SetLength(FileName,FileNameLength);
        if DragQueryFileW(DropHandle,Index,PWideChar(FileName),FileNameLength+1)<>0 then begin
         NativeEvent.Kind:=TpvApplicationNativeEventKind.DropFile;
         NativeEvent.StringValue:=PUCUUTF16ToUTF8(FileName);
         fNativeEventQueue.Enqueue(NativeEvent);
        end;
       end;
      end;
     finally
      DragFinish(DropHandle);
     end;
    finally
     FileName:='';
    end;
   end;
  end;
  WM_KEYDOWN,
  WM_SYSKEYDOWN:begin
   if fWin32KeyRepeat or ((HIWORD(aLParam) and KF_REPEAT)=0) then begin
    NativeEvent.Kind:=TpvApplicationNativeEventKind.KeyDown;
    TranslateKeyEvent;
    fNativeEventQueue.Enqueue(NativeEvent);
   end;
  end;
  WM_KEYUP,
  WM_SYSKEYUP:begin
   NativeEvent.Kind:=TpvApplicationNativeEventKind.KeyUp;
   TranslateKeyEvent;
   fNativeEventQueue.Enqueue(NativeEvent);
  end;
  WM_INPUTLANGCHANGE:begin

  end;
  $109{WM_UNICHAR}:begin
   if aWParam=$ffff{UNICODE_NOCHAR} then begin
    result:=1;
   end else if aWParam>=32 then begin
    NativeEvent.Kind:=TpvApplicationNativeEventKind.UnicodeCharTyped;
    NativeEvent.CharVal:=aWParam;
    fNativeEventQueue.Enqueue(NativeEvent);
   end;
  end;
  WM_CHAR:begin
   if (TpvUInt16(aWParam)>=$d800) and (TpvUInt16(aWParam)<=$dbff) then begin
    fWin32HighSurrogate:=TpvUInt16(aWParam);
   end else if ((TpvUInt16(fWin32HighSurrogate)>=$d800) and (TpvUInt16(fWin32HighSurrogate)<=$dbff)) and
               ((TpvUInt16(aWParam)>=$dc00) and (TpvUInt16(aWParam)<=$dfff)) then begin
    fWin32LowSurrogate:=TpvUInt16(aWParam);
    NativeEvent.Kind:=TpvApplicationNativeEventKind.UnicodeCharTyped;
    NativeEvent.CharVal:=(TPUCUUTF32Char(TPUCUUTF32Char(fWin32HighSurrogate) shl 10) or
                          TPUCUUTF32Char(TPUCUUInt16(fWin32LowSurrogate) and $3ff))+$10000;
    fNativeEventQueue.Enqueue(NativeEvent);
    fWin32HighSurrogate:=0;
   end else if aWParam>=32 then begin
    NativeEvent.Kind:=TpvApplicationNativeEventKind.UnicodeCharTyped;
    NativeEvent.CharVal:=TPUCUUTF32Char(TpvUInt16(aWParam));
    fNativeEventQueue.Enqueue(NativeEvent);
   end;
  end;
  WM_RBUTTONDOWN,
  WM_LBUTTONDOWN,
  WM_MBUTTONDOWN,
  WM_XBUTTONDOWN:begin
   if not IsTouchOrPenMouseEvent then begin
    NativeEvent.Kind:=TpvApplicationNativeEventKind.MouseButtonDown;
    TranslateMouseEvent;
    TranslateMouseButtonEvent;
    fNativeEventQueue.Enqueue(NativeEvent);
   end;
  end;
  WM_RBUTTONUP,
  WM_LBUTTONUP,
  WM_MBUTTONUP,
  WM_XBUTTONUP:begin
   if not IsTouchOrPenMouseEvent then begin
    NativeEvent.Kind:=TpvApplicationNativeEventKind.MouseButtonUp;
    TranslateMouseEvent;
    TranslateMouseButtonEvent;
    fNativeEventQueue.Enqueue(NativeEvent);
   end;
  end;
  WM_MOUSEMOVE:begin
   if not IsTouchOrPenMouseEvent then begin
    NativeEvent.Kind:=TpvApplicationNativeEventKind.MouseMoved;
    NativeEvent.MouseButton:=TpvApplicationInputPointerButton.None;
    TranslateMouseEvent;
    if not fWin32MouseInside then begin
     fWin32MouseInside:=true;
     NativeEvent.Kind:=TpvApplicationNativeEventKind.MouseEnter;
    end;
    fNativeEventQueue.Enqueue(NativeEvent);
   end;
  end;
  WM_MOUSELEAVE:begin
   if not IsTouchOrPenMouseEvent then begin
    NativeEvent.Kind:=TpvApplicationNativeEventKind.MouseLeave;
    TranslateMouseEvent;
    fNativeEventQueue.Enqueue(NativeEvent);
    fWin32MouseInside:=false;
   end;
  end;
  WM_MOUSEWHEEL,
  WM_MOUSEHWHEEL:begin
   if not IsTouchOrPenMouseEvent then begin
    NativeEvent.Kind:=TpvApplicationNativeEventKind.MouseWheel;
    TranslateMouseEvent;
    TranslateMouseWheelEvent;
    fNativeEventQueue.Enqueue(NativeEvent);
   end;
  end;
{ WM_SYSCOMMAND:begin
   case aWParam of
    SC_MINIMIZE:begin
     NativeEvent.Kind:=TpvApplicationNativeEventKind.WillEnterBackground;
     fNativeEventQueue.Enqueue(NativeEvent);
     NativeEvent.Kind:=TpvApplicationNativeEventKind.DidEnterBackground;
     fNativeEventQueue.Enqueue(NativeEvent);
    end;
   end;
  end;
  WM_ACTIVATE:begin
   if (LOWORD(aWParam)=WA_INACTIVE) and (HIWORD(aWParam)<>0) then begin
    NativeEvent.Kind:=TpvApplicationNativeEventKind.WillEnterBackground;
    fNativeEventQueue.Enqueue(NativeEvent);
    NativeEvent.Kind:=TpvApplicationNativeEventKind.DidEnterBackground;
    fNativeEventQueue.Enqueue(NativeEvent);
   end else if ((LOWORD(aWParam)=WA_ACTIVE) or (LOWORD(aWParam)=WA_CLICKACTIVE)) and (HIWORD(aWParam)<>0) then begin
    NativeEvent.Kind:=TpvApplicationNativeEventKind.WillEnterForeground;
    fNativeEventQueue.Enqueue(NativeEvent);
    NativeEvent.Kind:=TpvApplicationNativeEventKind.DidEnterForeground;
    fNativeEventQueue.Enqueue(NativeEvent);
   end;
  end; }
  WM_WINDOWPOSCHANGING:begin
   if aLParam<>0 then begin
    if (PWINDOWPOS(aLParam)^.flags and SWP_SHOWWINDOW)<>0 then begin
     NativeEvent.Kind:=TpvApplicationNativeEventKind.WillEnterForeground;
     fNativeEventQueue.Enqueue(NativeEvent);
    end else if (PWINDOWPOS(aLParam)^.flags and SWP_HIDEWINDOW)<>0 then begin
     NativeEvent.Kind:=TpvApplicationNativeEventKind.WillEnterBackground;
     fNativeEventQueue.Enqueue(NativeEvent);
    end;
   end;
  end;
  WM_WINDOWPOSCHANGED:begin
   if aLParam<>0 then begin
    if (PWINDOWPOS(aLParam)^.flags and SWP_SHOWWINDOW)<>0 then begin
     NativeEvent.Kind:=TpvApplicationNativeEventKind.DidEnterForeground;
     fNativeEventQueue.Enqueue(NativeEvent);
    end else if (PWINDOWPOS(aLParam)^.flags and SWP_HIDEWINDOW)<>0 then begin
     NativeEvent.Kind:=TpvApplicationNativeEventKind.DidEnterBackground;
     fNativeEventQueue.Enqueue(NativeEvent);
    end;
   end;
  end;
  WM_POINTERUPDATE,
  WM_POINTERDOWN,
  WM_POINTERUP,
  WM_POINTERCAPTURECHANGED:begin
   if Win32HasGetPointer then begin
    if TranslatePointer then begin
     result:=0;
    end;
   end;
  end;
  WM_TOUCH:begin
   if fWin32TouchActive and not Win32HasGetPointer then begin
    CountInputs:=LOWORD(aWParam);
    if CountInputs>0 then begin
     if length(fWin32TouchInputs)<CountInputs then begin
      SetLength(fWin32TouchInputs,CountInputs);
     end;
     if GetTouchInputInfo(aLParam,CountInputs,@fWin32TouchInputs[0],CountInputs) then begin
      try
       for Index:=0 to CountInputs-1 do begin
        TouchInput:=@fWin32TouchInputs[Index];
        if (TouchInput^.dwFlags and (TOUCHEVENTF_DOWN or TOUCHEVENTF_UP or TOUCHEVENTF_MOVE))<>0 then begin
         x:=TouchInput^.x*0.01;
         y:=TouchInput^.y*0.01;
         Point.x:=trunc(x);
         Point.y:=trunc(y);
         if ScreenToClient(fWin32Handle,Point) then begin
          x:=Point.x+frac(x);
          y:=Point.y+frac(y);
          TouchID:=$ffffffff;
          if not fWin32TouchIDHashMap.TryGet(TouchInput^.dwID,TouchID) then begin
           if not fWin32TouchIDFreeList.Dequeue(TouchID) then begin
            repeat
             TouchID:=fWin32TouchIDCounter;
             inc(fWin32TouchIDCounter);
            until TouchID<>0;
           end;
           fWin32TouchIDHashMap.Add(TouchInput^.dwID,TouchID);
          end;
          if (TouchID<>$ffffffff) and
             (TpvSizeInt(TouchID)<length(fWin32TouchLastX)) and
             (TpvSizeInt(TouchID)<length(fWin32TouchLastY)) then begin
           if (TouchInput^.dwFlags and TOUCHEVENTF_DOWN)<>0 then begin
            NativeEvent.Kind:=TpvApplicationNativeEventKind.TouchDown;
            fWin32TouchLastX[TouchID]:=x;
            fWin32TouchLastY[TouchID]:=y;
           end else if (TouchInput^.dwFlags and TOUCHEVENTF_UP)<>0 then begin
            NativeEvent.Kind:=TpvApplicationNativeEventKind.TouchUp;
            fWin32TouchIDHashMap.Delete(TouchInput^.dwID);
            fWin32TouchIDFreeList.Enqueue(TouchID);
           end else{if (TouchInput^.dwFlags and TOUCHEVENTF_MOVE)<>0 then}begin
            NativeEvent.Kind:=TpvApplicationNativeEventKind.TouchMotion;
           end;
           NativeEvent.TouchID:=TouchID;
           NativeEvent.TouchX:=x;
           NativeEvent.TouchY:=y;
           NativeEvent.TouchDeltaX:=x-fWin32TouchLastX[TouchID];
           NativeEvent.TouchDeltaY:=y-fWin32TouchLastY[TouchID];
           NativeEvent.TouchPressure:=1.0; // <= TODO
           NativeEvent.TouchPen:=(TouchInput^.dwFlags and TOUCHEVENTF_PEN)<>0;
           fWin32TouchLastX[TouchID]:=x;
           fWin32TouchLastY[TouchID]:=y;
           fNativeEventQueue.Enqueue(NativeEvent);
          end;
         end;
        end;
       end;
      finally
       CloseTouchInputHandle(aLParam);
      end;
     end;
    end;
   end;
  end;
  WM_SETFOCUS:begin
   fWin32HasFocus:=true;
  end;
  WM_KILLFOCUS:begin
   fWin32HasFocus:=false;
  end;
  else begin
  end;
 end;
end;

{$ifend}

{$if defined(Windows) and not (defined(PasVulkanUseSDL2) or defined(PasVulkanHeadless))}
procedure TpvApplicationWin32GameInputOnDeviceEnumerated(callbackToken:TGameInputCallbackToken;context:TpvPointer;device:IGameInputDevice;timestamp:TpvUInt64;currentStatus,previousStatus:TGameInputDeviceStatus); {$ifdef cpu386}stdcall;{$endif}
var Application:TpvApplication;
    DeviceCallbackQueueItem:TpvApplicationWin32GameInputDeviceCallbackQueueItem;
begin
 Application:=TpvApplication(context);
 if assigned(Application) and (callbackToken=Application.fWin32GameInputDeviceCallbackToken) then begin
  DeviceCallbackQueueItem.Device:=device;
  DeviceCallbackQueueItem.Timestamp:=timestamp;
  DeviceCallbackQueueItem.CurrentStatus:=currentStatus;
  DeviceCallbackQueueItem.PreviousStatus:=previousStatus;
  Application.fWin32GameInputDeviceCallbackQueue.Enqueue(DeviceCallbackQueueItem);
 end;
end;
{$ifend}

procedure TpvApplication.Run;
var Index:TpvInt32;
    ExceptionString:String;
{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
    SDL2Flags:TpvUInt32;
    SDL2HintParameter:TpvUTF8String;
{$elseif defined(Windows) and not defined(PasVulkanHeadless)}
    ScreenDC:HDC;
{$ifend}
{$if defined(Android)}
    AndroidEnv:PJNIEnv;
    AndroidActivity,AndroidFile,AndroidNull:jobject;
    AndroidGetCacheDir,AndroidGetFilesDir,AndroidGetNoBackupFilesDir,
    AndroidGetExternalFilesDir,AndroidGetAbsolutePath:jmethodID;
    AndroidActivityClass,AndroidFileClass:jclass;
    AndroidPath:jstring;
{$ifend}
begin
 VulkanDisableFloatingPointExceptions;

{$if defined(Android)}

 AndroidEnv:=SDL_AndroidGetJNIEnv;

 AndroidActivity:=SDL_AndroidGetActivity;

 AndroidActivityClass:=AndroidEnv^.GetObjectClass(AndroidEnv,AndroidActivity);

 AndroidGetCacheDir:=AndroidEnv^.GetMethodID(AndroidEnv,AndroidActivityClass,'getCacheDir','()Ljava/io/File;');

 AndroidGetFilesDir:=AndroidEnv^.GetMethodID(AndroidEnv,AndroidActivityClass,'getFilesDir','()Ljava/io/File;');

 AndroidGetNoBackupFilesDir:=AndroidEnv^.GetMethodID(AndroidEnv,AndroidActivityClass,'getNoBackupFilesDir','()Ljava/io/File;');

 AndroidGetExternalFilesDir:=AndroidEnv^.GetMethodID(AndroidEnv,AndroidActivityClass,'getExternalFilesDir','(Ljava/lang/String;)Ljava/io/File;');

 AndroidFileClass:=AndroidEnv^.FindClass(AndroidEnv,'java/io/File');
 AndroidGetAbsolutePath:=AndroidEnv^.GetMethodID(AndroidEnv,AndroidFileClass,'getAbsolutePath','()Ljava/lang/String;');

 AndroidFile:=AndroidEnv^.CallObjectMethod(AndroidEnv,AndroidActivity,AndroidGetCacheDir);
 try
  AndroidPath:=AndroidEnv^.CallObjectMethod(AndroidEnv,AndroidFile,AndroidGetAbsolutePath);
  if assigned(AndroidPath) then begin
   try
    fCacheStoragePath:=IncludeTrailingPathDelimiter(JStringToString(AndroidEnv,AndroidPath));
    if length(fCacheStoragePath)=0 then begin
     fCacheStoragePath:=IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(GetAppConfigDir(false))+'cache');
     if not DirectoryExists(fCacheStoragePath) then begin
      CreateDir(fCacheStoragePath);
     end;
    end;
   finally
    FreeJString(AndroidEnv,AndroidPath);
   end;
  end else begin
   fCacheStoragePath:=IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(GetAppConfigDir(false))+'cache');
   if not DirectoryExists(fCacheStoragePath) then begin
    CreateDir(fCacheStoragePath);
   end;
  end;
 finally
  AndroidEnv^.DeleteLocalRef(AndroidEnv,AndroidFile);
 end;

 AndroidFile:=AndroidEnv^.CallObjectMethod(AndroidEnv,AndroidActivity,AndroidGetNoBackupFilesDir);
 try
  AndroidPath:=AndroidEnv^.CallObjectMethod(AndroidEnv,AndroidFile,AndroidGetAbsolutePath);
  if assigned(AndroidPath) then begin
   try
    fLocalStoragePath:=IncludeTrailingPathDelimiter(JStringToString(AndroidEnv,AndroidPath));
    if length(fLocalStoragePath)=0 then begin
     fLocalStoragePath:=IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(GetAppConfigDir(false))+'local');
     if not DirectoryExists(fLocalStoragePath) then begin
      CreateDir(fLocalStoragePath);
     end;
    end;
   finally
    FreeJString(AndroidEnv,AndroidPath);
   end;
  end else begin
   fLocalStoragePath:=IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(GetAppConfigDir(false))+'local');
   if not DirectoryExists(fLocalStoragePath) then begin
    CreateDir(fLocalStoragePath);
   end;
  end;
 finally
  AndroidEnv^.DeleteLocalRef(AndroidEnv,AndroidFile);
 end;

 AndroidFile:=AndroidEnv^.CallObjectMethod(AndroidEnv,AndroidActivity,AndroidGetFilesDir);
 try
  AndroidPath:=AndroidEnv^.CallObjectMethod(AndroidEnv,AndroidFile,AndroidGetAbsolutePath);
  if assigned(AndroidPath) then begin
   try
    fRoamingStoragePath:=IncludeTrailingPathDelimiter(JStringToString(AndroidEnv,AndroidPath));
    if length(fRoamingStoragePath)=0 then begin
     fRoamingStoragePath:=IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(GetAppConfigDir(false))+'local');
     if not DirectoryExists(fRoamingStoragePath) then begin
      CreateDir(fRoamingStoragePath);
     end;
    end;
   finally
    FreeJString(AndroidEnv,AndroidPath);
   end;
  end else begin
   fRoamingStoragePath:=IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(GetAppConfigDir(false))+'local');
   if not DirectoryExists(fRoamingStoragePath) then begin
    CreateDir(fRoamingStoragePath);
   end;
  end;
 finally
  AndroidEnv^.DeleteLocalRef(AndroidEnv,AndroidFile);
 end;

 AndroidNull:=nil;
 AndroidFile:=AndroidEnv^.CallObjectMethodA(AndroidEnv,AndroidActivity,AndroidGetExternalFilesDir,@AndroidNull);
 try
  AndroidPath:=AndroidEnv^.CallObjectMethod(AndroidEnv,AndroidFile,AndroidGetAbsolutePath);
  if assigned(AndroidPath) then begin
   try
    fExternalStoragePath:=IncludeTrailingPathDelimiter(JStringToString(AndroidEnv,AndroidPath));
    if length(fExternalStoragePath)=0 then begin
     fExternalStoragePath:=IncludeTrailingPathDelimiter(GetEnvironmentVariable('EXTERNAL_STORAGE'));
    end;
   finally
    FreeJString(AndroidEnv,AndroidPath);
   end;
  end else begin
   fExternalStoragePath:=IncludeTrailingPathDelimiter(GetEnvironmentVariable('EXTERNAL_STORAGE'));
  end;
 finally
  AndroidEnv^.DeleteLocalRef(AndroidEnv,AndroidFile);
 end;

{$if (defined(fpc) and defined(android)) and not defined(Release)}
 __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication',PAnsiChar('Cache storage data path: '+fCacheStoragePath));
 __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication',PAnsiChar('Local storage data path: '+fLocalStoragePath));
 __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication',PAnsiChar('Roaming storage data path: '+fRoamingStoragePath));
 __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication',PAnsiChar('External storage data path: '+fExternalStoragePath));
{$ifend}

{$elseif (defined(Windows) or defined(Linux) or defined(Unix)) and not defined(Android)}

 fCacheStoragePath:=TpvUTF8String(GetAppDataCacheStoragePath(String(fPathName)));

 fLocalStoragePath:=TpvUTF8String(GetAppDataLocalStoragePath(String(fPathName)));

 fRoamingStoragePath:=TpvUTF8String(GetAppDataRoamingStoragePath(String(fPathName)));

{$if defined(Windows)}
 fExternalStoragePath:='C:\';
{$else}
 fExternalStoragePath:='/';
{$ifend}

 pvCacheStoragePath:=fCacheStoragePath;
 pvLocalStoragePath:=fLocalStoragePath;
 pvRoamingStoragePath:=fRoamingStoragePath;

{$if not defined(Release)}
 Log(LOG_VERBOSE,'PasVulkanApplication','Cache storage data path: '+fCacheStoragePath);
 Log(LOG_VERBOSE,'PasVulkanApplication','Local storage data path: '+fLocalStoragePath);
 Log(LOG_VERBOSE,'PasVulkanApplication','Roaming storage data path: '+fRoamingStoragePath);
 Log(LOG_VERBOSE,'PasVulkanApplication','External storage data path: '+fExternalStoragePath);
{$ifend}

{$ifend}

 fVulkanPipelineCacheFileName:=TpvUTF8String(IncludeTrailingPathDelimiter(String(fCacheStoragePath)))+'vulkan_pipeline_cache.bin';

 ProcessOldPathNames;

 ReadConfig;

{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
 SDL_GetVersion(fSDLVersion);

{$if defined(PasVulkanUseSDL2WithVulkanSupport)}
 fSDLVersionWithVulkanSupport:=(fSDLVersion.Major>=3) or
                               ((fSDLVersion.Major=2) and
                                (((fSDLVersion.Minor=0) and (fSDLVersion.Patch>=6)) or
                                 (fSDLVersion.Minor>=1)
                                )
                               );
{$ifend}
{$ifend}

{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
 if GetAndroidSeparateMouseAndTouch then begin
  SDL_SetHint(SDL_HINT_ANDROID_SEPARATE_MOUSE_AND_TOUCH,'1');
 end else begin
  SDL_SetHint(SDL_HINT_ANDROID_SEPARATE_MOUSE_AND_TOUCH,'0');
 end;
 if fAndroidMouseTouchEvents then begin
  SDL_SetHint(SDL_HINT_MOUSE_TOUCH_EVENTS,'1');
 end else begin
  SDL_SetHint(SDL_HINT_MOUSE_TOUCH_EVENTS,'0');
 end;
 if fAndroidTouchMouseEvents then begin
  SDL_SetHint(SDL_HINT_TOUCH_MOUSE_EVENTS,'1');
 end else begin
  SDL_SetHint(SDL_HINT_TOUCH_MOUSE_EVENTS,'0');
 end;
 if fAndroidBlockOnPause then begin
  SDL_SetHint(SDL_HINT_ANDROID_BLOCK_ON_PAUSE,'1');
 end else begin
  SDL_SetHint(SDL_HINT_ANDROID_BLOCK_ON_PAUSE,'0');
 end;
 if fAndroidTrapBackButton then begin
  SDL_SetHint(SDL_HINT_ANDROID_TRAP_BACK_BUTTON,'1');
 end else begin
  SDL_SetHint(SDL_HINT_ANDROID_TRAP_BACK_BUTTON,'0');
 end;

 SDL2HintParameter:='';
 if TpvApplicationDisplayOrientation.LandscapeLeft in fDisplayOrientations then begin
  SDL2HintParameter:=SDL2HintParameter+'LandscapeLeft ';
 end;
 if TpvApplicationDisplayOrientation.LandscapeRight in fDisplayOrientations then begin
  SDL2HintParameter:=SDL2HintParameter+'LandscapeRight ';
 end;
 if TpvApplicationDisplayOrientation.Portrait in fDisplayOrientations then begin
  SDL2HintParameter:=SDL2HintParameter+'Portrait ';
 end;
 if TpvApplicationDisplayOrientation.PortraitUpsideDown in fDisplayOrientations then begin
  SDL2HintParameter:=SDL2HintParameter+'PortraitUpsideDown ';
 end;
 if length(SDL2HintParameter)>0 then begin
  SDL_SetHint(SDL_HINT_ORIENTATIONS,PAnsiChar(SDL2HintParameter));
 end;

  SDL_SetHint(SDL_HINT_MOUSE_NORMAL_SPEED_SCALE,'1.0');

  SDL_SetHint(SDL_HINT_MOUSE_RELATIVE_SPEED_SCALE,'1.0');

  SDL_SetHint(SDL_HINT_VIDEO_MINIMIZE_ON_FOCUS_LOSS,'0');

{$else}
{$ifend}

{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
 if fHideSystemBars then begin
  SDL_SetHint(SDL_HINT_ANDROID_HIDE_SYSTEM_BARS,'1');
 end else begin
  SDL_SetHint(SDL_HINT_ANDROID_HIDE_SYSTEM_BARS,'0');
 end;
{$else}
{$ifend}
 fCurrentHideSystemBars:=ord(fHideSystemBars);

 if WaitForReadyState then begin

{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
  SDL2Flags:=SDL_INIT_VIDEO or
             SDL_INIT_EVENTS or
             SDL_INIT_TIMER or
             SDL_INIT_JOYSTICK or
             SDL_INIT_HAPTIC or
             SDL_INIT_GAMECONTROLLER;
  if fUseAudio then begin
   SDL2Flags:=SDL2Flags or SDL_INIT_AUDIO;
  end;
  if SDL_Init(SDL2Flags)<0 then begin
   raise EpvApplication.Create('SDL','Unable to initialize SDL: '+SDL_GetError,LOG_ERROR);
  end;

{$if defined(PasVulkanUseSDL2WithVulkanSupport)}
  // Load Vulkan library globally first to ensure Mesa device selection layers and other Vulkan layers can resolve loader symbols
  Vulkan.LoadVulkanLibrary(VK_DEFAULT_LIB_NAME);

  // For faulty SDL2 >= 2.0.6 builds with corrupt or missing builtin Vulkan support
  // Note: SDL_Vulkan_LoadLibrary may be nil when SDL2 is statically linked (e.g. in Flatpak runtime).
  // In that case, check SDL_Vulkan_CreateSurface instead, which is the symbol we actually need.
  if fSDLVersionWithVulkanSupport then begin
   if assigned(SDL_Vulkan_LoadLibrary) then begin
    // Dynamic SDL2: call LoadLibrary and check result
    if SDL_Vulkan_LoadLibrary(nil) < 0 then begin
     fSDLVersionWithVulkanSupport:=false;
    end;
   end else if not assigned(SDL_Vulkan_CreateSurface) then begin
    // Neither LoadLibrary nor CreateSurface available — no real Vulkan support
    fSDLVersionWithVulkanSupport:=false;
   end;
  end;
{$ifend}

{$else}
{$ifend}

{$if defined(Unix) and not defined(Android)}
  InstallSignalHandlers;
{$ifend}

{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
  if SDL_GetCurrentDisplayMode(0,@fSDLDisplayMode)=0 then begin
   fScreenWidth:=fSDLDisplayMode.w;
   fScreenHeight:=fSDLDisplayMode.h;
  end else begin
   fScreenWidth:=-1;
   fScreenHeight:=-1;
  end;
{$elseif defined(Windows) and not defined(PasVulkanHeadless)}
  ScreenDC:=GetDC(0);
  try
{  fScreenWidth:=GetSystemMetrics(SM_CXSCREEN);
   fScreenHeight:=GetSystemMetrics(SM_CYSCREEN);}
   fScreenWidth:=GetDeviceCaps(ScreenDC,HORZRES);
   fScreenHeight:=GetDeviceCaps(ScreenDC,VERTRES);
  finally
   ReleaseDC(0,ScreenDC);
  end;
  fWin32KeyRepeat:=true;
{$else}
  fScreenWidth:=-1;
  fScreenHeight:=-1;
{$ifend}

{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
  fVideoFlags:=SDL_WINDOW_ALLOW_HIGHDPI;
{ if fMaximized then begin
   fVideoFlags:=fVideoFlags or SDL_WINDOW_MAXIMIZED;
  end;
  fCurrentMaximized:=TpvInt32(fMaximized);//}
{$if defined(PasVulkanUseSDL2WithVulkanSupport)}
  if fSDLVersionWithVulkanSupport then begin
   fVideoFlags:=fVideoFlags or SDL_WINDOW_VULKAN;
  end;
{$ifend}
  if fFullScreen then begin
{$ifndef Android}
   if (fWidth=fScreenWidth) and (fHeight=fScreenHeight) then begin
    fVideoFlags:=fVideoFlags or SDL_WINDOW_FULLSCREEN_DESKTOP;
   end else begin
    fVideoFlags:=fVideoFlags or SDL_WINDOW_FULLSCREEN;
   end;
{$endif}
   fCurrentFullscreen:=ord(true);
  end else begin
   fCurrentFullscreen:=0;
  end;
{$ifndef Android}
  if fResizable then begin
   fVideoFlags:=fVideoFlags or SDL_WINDOW_RESIZABLE;
  end;

{$endif}

{$if defined(fpc) and defined(android)}
  fVideoFlags:=fVideoFlags or SDL_WINDOW_FULLSCREEN or SDL_WINDOW_VULKAN;
  fFullScreen:=true;
  fCurrentFullscreen:=ord(true);
  fWidth:=fScreenWidth;
  fHeight:=fScreenHeight;
  __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication',PAnsiChar(TpvApplicationRawByteString('Window size: '+IntToStr(fWidth)+'x'+IntToStr(fHeight))));
{$ifend}

{$if defined(PasVulkanUseSDL2WithVulkanSupport)}
  repeat
{$ifend}
   fSurfaceWindow:=SDL_CreateWindow(PAnsiChar(TpvApplicationRawByteString(fWindowTitle)),
{$ifdef Android}
                                    SDL_WINDOWPOS_CENTERED,
                                    SDL_WINDOWPOS_CENTERED,
{$else}
                                    SDL_WINDOWPOS_UNDEFINED,
                                    SDL_WINDOWPOS_UNDEFINED,
{                                   ((fScreenWidth-fWidth)+1) div 2,
                                    ((fScreenHeight-fHeight)+1) div 2,}
{$endif}
                                    fWidth,
                                    fHeight,
                                    SDL_WINDOW_SHOWN or fVideoFlags);
   if not assigned(fSurfaceWindow) then begin
{$if defined(PasVulkanUseSDL2WithVulkanSupport)}
    // For faulty SDL2 >= 2.0.6 builds with corrupt or missing builtin Vulkan support
    if fSDLVersionWithVulkanSupport then begin
     fSDLVersionWithVulkanSupport:=false;
     fVideoFlags:=fVideoFlags and not SDL_WINDOW_VULKAN;
     continue;
    end;
{$ifend}
    raise EpvApplication.Create('SDL','Unable to initialize SDL: '+SDL_GetError,LOG_ERROR);
   end;
{$if defined(PasVulkanUseSDL2WithVulkanSupport)}
   break;
  until false;
{$ifend}
{$elseif defined(Windows) and not defined(PasVulkanHeadless)}

  if (WindowsVersionMajor>=10) and assigned(SetProcessDpiAwarenessContext) then begin // >= Windows 10
   SetProcessDpiAwarenessContext(DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2);
  end else if (WindowsVersionMajor>=6) and (WindowsVersionMinor>=3) and assigned(SetProcessDpiAwareness) then begin // >= Windows 8.1
   SetProcessDpiAwareness(PROCESS_PER_MONITOR_DPI_AWARE);
  end else if (WindowsVersionMajor>=6) and (WindowsVersionMinor>=0) and assigned(SetProcessDPIAware) then begin // >= Windows Vista
   SetProcessDPIAware;
  end;

  fWin32HInstance:=GetModuleHandleW(nil);

  Win32WindowClass.lpfnWndProc:=@TpvApplicationWin32WndProc;
  Win32WindowClass.hInstance:=fWin32HInstance;
  Win32WindowClass.hIcon:=LoadIconA(fWin32HInstance,'MAINICON');
// Win32WindowClass.hIcon:=LoadIcon(fWin32HInstance,{$ifdef fpc}'MAINICON'{$else}IDI_APPLICATION{$endif});

  fWin32WindowClass:=RegisterClassW(Win32WindowClass);
  if fWin32WindowClass=0 then begin
   raise EpvApplication.Create('Windows','Failed to register the window class.',LOG_ERROR);
  end;

  fWin32Style:=WS_VISIBLE;
  if fFullScreen then begin
   fWin32Style:=fWin32Style or WS_POPUP;
  end else begin
   fWin32Style:=fWin32Style or WS_CAPTION or WS_MINIMIZEBOX or WS_SYSMENU;
   if fResizable then begin
    fWin32Style:=fWin32Style or WS_THICKFRAME or WS_MAXIMIZEBOX;
   end;
  end;

  fWin32Rect.Left:=0;
  fWin32Rect.Top:=0;
  fWin32Rect.Width:=fWidth;
  fWin32Rect.Height:=fHeight;
  if not Fullscreen then begin
   AdjustWindowRect(fWin32Rect,fWin32Style,false);
  end;

  fWin32Title:=PUCUUTF8ToUTF16(fWindowTitle);

  fWin32Callback:=nil;

  fWin32Handle:=CreateWindowW(Win32WindowClass.lpszClassName,
                              PWideChar(fWin32Title),
                              fWin32Style,
                              ((fScreenWidth-fWidth)+1) div 2,
                              ((fScreenHeight-fHeight)+1) div 2,
                              fWin32Rect.Right-fWin32Rect.Left,
                              fWin32Rect.Bottom-fWin32Rect.Top,
                              0,
                              0,
                              fWin32HInstance,
                              self
                             );
  if fWin32Handle=0 then begin
   raise EpvApplication.Create('Windows','Failed to create the window.',LOG_ERROR);
  end;

  fCurrentFullscreen:=0;

  if fAcceptDragDropFiles then begin
   SetWindowLongW(fWin32Handle,GWL_EXSTYLE,WS_EX_APPWINDOW or WS_EX_ACCEPTFILES);
  end else begin
   SetWindowLongW(fWin32Handle,GWL_EXSTYLE,WS_EX_APPWINDOW);
  end;

  if Win32HasGetPointer then begin
   EnableMouseInPointer(false);
   fWin32TouchActive:=false;
  end else begin
   fWin32TouchActive:=RegisterTouchWindow(fWin32Handle,TWF_FINETOUCH or TWF_WANTPALM);
  end;

  fWin32TouchInputs:=nil;

  fWin32TouchIDHashMap:=TWin32TouchIDHashMap.Create(0);

  fWin32TouchIDFreeList.Initialize;

  fWin32TouchIDCounter:=0;

  if fWin32TouchActive or Win32HasGetPointer then begin
   SetPropA(fWin32Handle,
            'MicrosoftTabletPenServiceProperty',
            THANDLE(LONG_PTR($00000001 or   // TABLET_DISABLE_PRESSANDHOLD
                             $00000008 or   // TABLET_DISABLE_PENTAPFEEDBACK
                             $00000010 or   // TABLET_DISABLE_PENBARRELFEEDBACK
                             $00000100 or   // TABLET_DISABLE_TOUCHUIFORCEON
                             $00000200 or   // TABLET_DISABLE_TOUCHUIFORCEOFF
                             $00008000 or   // TABLET_DISABLE_TOUCHSWITCH
                             $00010000 or   // TABLET_DISABLE_FLICKS
                             $00080000 or   // TABLET_DISABLE_SMOOTHSCROLLING
                             $00100000 or   // TABLET_DISABLE_FLICKFALLBACKKEYS
                             $01000000)));  // TABLET_ENABLE_MULTITOUCHDATA
  end;

  fWin32HiddenCursor:=CreateCursor(fWin32HInstance,0,0,1,1,@Win32CursorMaskAND,@Win32CursorMaskXOR);

  fWin32FullScreen:=false;

  fWin32RealFullScreen:=false;

  if fVisibleMouseCursor then begin
   fWin32Cursor:=LoadCursor(0,IDC_ARROW);
  end else begin
   fWin32Cursor:=fWin32HiddenCursor;
  end;
  SetCursor(fWin32Cursor);

{ if fMaximized then begin
   ShowWindow(fWin32Handle,SW_MAXIMIZE);
  end else begin
   ShowWindow(fWin32Handle,SW_NORMAL);
  end;
  fCurrentMaximized:=TpvInt32(fMaximized);

  Windows.SetForegroundWindow(fWin32Handle);
  Windows.SetFocus(fWin32Handle);}

  fWin32GameInput:=nil;

  fWin32HasGameInput:=assigned(GameInputCreate) and (GameInputCreate(fWin32GameInput)=NO_ERROR);
  fWin32HasGameInput:=fWin32HasGameInput and assigned(fWin32GameInput);

  fWin32GameInputDeviceCallbackQueue:=TpvApplicationWin32GameInputDeviceCallbackQueue.Create;

  fWin32GameInputDeviceCallbackToken:=GAMEINPUT_INVALID_CALLBACK_TOKEN_VALUE;

  if fWin32HasGameInput then begin
   if fWin32GameInput.RegisterDeviceCallback(nil,
                                             GameInputKindGamepad,
                                             GameInputDeviceAnyStatus,
                                             GameInputAsyncEnumeration,
                                             self,
                                             TpvApplicationWin32GameInputOnDeviceEnumerated,
                                             @fWin32GameInputDeviceCallbackToken)<>NO_ERROR then begin
    fWin32GameInputDeviceCallbackToken:=GAMEINPUT_INVALID_CALLBACK_TOKEN_VALUE;
    fWin32HasGameInput:=false;
   end;
  end;

{$else}
{$ifend}

{$if defined(PasVulkanUseSDL2) and defined(PasVulkanUseSDL2WithVulkanSupport) and not defined(PasVulkanHeadless)}
  if fSDLVersionWithVulkanSupport then begin
   SDL_Vulkan_GetDrawableSize(fSurfaceWindow,@fWidth,@fHeight);
  end;
{$ifend}

  fCurrentWidth:=fWidth;
  fCurrentHeight:=fHeight;

  fCurrentPresentMode:=TpvInt32(fPresentMode);

{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
 {SDL_EventState(SDL_MOUSEMOTION,SDL_ENABLE);
  SDL_EventState(SDL_MOUSEBUTTONDOWN,SDL_ENABLE);
  SDL_EventState(SDL_MOUSEBUTTONUP,SDL_ENABLE);
  SDL_EventState(SDL_KEYDOWN,SDL_ENABLE);
  SDL_EventState(SDL_KEYUP,SDL_ENABLE);
  SDL_EventState(SDL_QUITEV,SDL_ENABLE);
  SDL_EventState(SDL_WINDOWEVENT,SDL_ENABLE);}
{$ifend}

  FillChar(fFrameTimesHistoryDeltaTimes,SizeOf(fFrameTimesHistoryDeltaTimes),#0);
  FillChar(fFrameTimesHistoryTimePoints,SizeOf(fFrameTimesHistoryTimePoints),#$ff);
  fFrameTimesHistoryIndex:=0;
  fFrameTimesHistoryCount:=0;
  fFrameTimesHistorySum:=0.0;

  fFramesPerSecond:=0.0;

  fSkipNextDrawFrame:=false;

  if fDesiredCountInFlightFrames<1 then begin
   raise EpvApplication.Create('Internal error','DesiredCountInFlightFrames must be >= 1',LOG_ERROR);
  end else begin
   fCountInFlightFrames:=fDesiredCountInFlightFrames;
  end;

  try

   CreateVulkanInstance;
   try

    fDoUpdateMainJoystick:=false;
    UpdateJoysticks(true);

    Start;
    try

     InitializeGraphics;
     try

      InitializeAudio;
      try

       try

        Load;
        try

         fLoadWasCalled:=true;

         try

          AfterCreateSwapChainWithCheck;

          fLifecycleListenerListCriticalSection.Acquire;
          try
           for Index:=0 to fLifecycleListenerList.Count-1 do begin
            if TpvApplicationLifecycleListener(fLifecycleListenerList[Index]).Resume then begin
             break;
            end;
           end;
          finally
           fLifecycleListenerListCriticalSection.Release;
          end;

          if assigned(fStartScreen) then begin
           SetScreen(fStartScreen.Create);
          end;
          try

           if assigned(fAudio) then begin
  {$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
            SDL_PauseAudio(0);
  {$else}
  {$ifend}
           end;
           try

{$if defined(Windows) and not (defined(PasVulkanUseSDL2) or defined(PasVulkanHeadless))}
           fWin32MainFiber:=LPVOID(ConvertThreadToFiberEx(nil,$1{FIBER_FLAG_FLOAT_SWITCH}));
           if not assigned(fWin32MainFiber) then begin
            raise EpvApplication.Create('Internal error','ConvertThreadToFiberEx failed',LOG_ERROR);
           end;

           fWin32MessageFiber:=LPVOID(CreateFiber(0,@TpvApplicationMessageFiberProc,self));
           if not assigned(fWin32MessageFiber) then begin
            raise EpvApplication.Create('Internal error','CreateFiber failed',LOG_ERROR);
           end;
{$ifend}
           try

            if fUseExtraUpdateThread then begin
             fUpdateThread:=TpvApplicationUpdateThread.Create(self);
            end else begin
             fUpdateThread:=nil;
            end;
            try

             while not fTerminated do begin
              ProcessMessages;
             end;

            finally
             if assigned(fUpdateThread) then begin
              try
               fUpdateThread.Shutdown;
              finally
               FreeAndNil(fUpdateThread);
              end;
             end;
            end;

           finally

{$if defined(Windows) and not (defined(PasVulkanUseSDL2) or defined(PasVulkanHeadless))}
           if assigned(fWin32MessageFiber) then begin
            DeleteFiber(fWin32MessageFiber);
            ConvertFiberToThread;
           end;
{$ifend}

           end;

           finally
            if assigned(fAudio) then begin
  {$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
             SDL_PauseAudio(1);
  {$else}
  {$ifend}
            end;
           end;

          finally

           SetScreen(nil);

           FreeAndNil(fNextScreen);
           FreeAndNil(fScreen);

          end;

          fLifecycleListenerListCriticalSection.Acquire;
          try
           for Index:=0 to fLifecycleListenerList.Count-1 do begin
            if TpvApplicationLifecycleListener(fLifecycleListenerList[Index]).Pause then begin
             break;
            end;
           end;
           for Index:=0 to fLifecycleListenerList.Count-1 do begin
            if TpvApplicationLifecycleListener(fLifecycleListenerList[Index]).Terminate then begin
             break;
            end;
           end;
          finally
           fLifecycleListenerListCriticalSection.Release;
          end;

         except
          on e:Exception do begin
           ExceptionString:=DumpExceptionCallStack(e);
{$if defined(fpc) and defined(android) and (defined(Release) or not defined(Debug))}
           __android_log_write(ANDROID_LOG_ERROR,'PasVulkanApplication',PAnsiChar(TpvApplicationRawByteString(ExceptionString)));
{$ifend}
           TpvApplication.Log(LOG_ERROR,'TpvApplication.Run',ExceptionString);
           LogCrash(ExceptionString);
           //raise;
           if fVulkanDevice.UseNVIDIADeviceDiagnostics then begin
            // Device lost notification is asynchronous to the NVIDIA display
            // driver's GPU crash handling. Give the Nsight Aftermath GPU crash dump
            // thread some time to do its work before terminating the process.
            Sleep(5000);
{$ifndef Android}
{$endif}
           end;
          end;
         end;

        finally

         VulkanWaitIdle;

         try

          ClearDelayedObjectsToFree;

         finally

          VulkanWaitIdle;

          Unload;

          ClearDelayedObjectsToFree;

         end;

        end;

       finally
        fResourceManager.Shutdown;
       end;

      finally
       DeinitializeAudio;
      end;

     finally
      DeinitializeGraphics;
     end;

    finally

     Stop;

    end;

   finally
    DestroyVulkanInstance;
   end;

  finally

{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
   if assigned(fSurfaceWindow) then begin
    SDL_DestroyWindow(fSurfaceWindow);
    fSurfaceWindow:=nil;
   end;
{$elseif defined(Windows) and not defined(PasVulkanHeadless)}

   if fWin32HasGameInput then begin
    if fWin32GameInputDeviceCallbackToken<>GAMEINPUT_INVALID_CALLBACK_TOKEN_VALUE then begin
     fWin32GameInput.UnregisterCallback(fWin32GameInputDeviceCallbackToken,1000);
    end;
   end;

   FreeAndNil(fWin32GameInputDeviceCallbackQueue);

   fWin32GameInput:=nil;

   if fWin32Icon<>0 then begin
    DestroyIcon(fWin32Icon);
   end;

   if fWin32TouchActive then begin
    UnregisterTouchWindow(fWin32Handle);
   end;

   fWin32TouchInputs:=nil;

   FreeAndNil(fWin32TouchIDHashMap);

   fWin32TouchIDFreeList.Finalize;


   if assigned(fWin32Callback) then begin

    SetWindowLongPtrW(fWin32Handle,GWLP_WNDPROC,LONG_PTR(Pointer(Addr(fWin32Callback))));

   end else begin

    DestroyWindow(fWin32Handle);

    UnregisterClassW(Win32WindowClass.lpszClassName,fWin32HInstance);

    DestroyCursor(fWin32HiddenCursor);

   end;

{$else}
{$ifend}

   SaveConfig;

  end;

 end;

{$if defined(PasVulkanUseSDL2) and defined(PasVulkanUseSDL2WithVulkanSupport) and not defined(PasVulkanHeadless)}
 if fSDLVersionWithVulkanSupport then begin
  SDL_Vulkan_UnloadLibrary;
 end;
{$ifend}

end;

procedure TpvApplication.SetFocus;
begin
{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
 if assigned(fSurfaceWindow) then begin
  SDL_RaiseWindow(fSurfaceWindow);
 end;
{$elseif defined(Windows) and not defined(PasVulkanHeadless)}
 if fWin32Handle<>0 then begin
  Windows.SetForegroundWindow(fWin32Handle);
  Windows.SetFocus(fWin32Handle);
 end;
{$ifend}
end;

procedure TpvApplication.SetupVulkanInstance(const aVulkanInstance:TpvVulkanInstance);
begin
end;

procedure TpvApplication.ChooseVulkanPhysicalDevice(var aVulkanPhysicalDevice:TpvVulkanPhysicalDevice);
begin
end;

procedure TpvApplication.SetupVulkanDevice(const aVulkanDevice:TpvVulkanDevice);
begin
end;

procedure TpvApplication.Setup;
begin
end;

procedure TpvApplication.Start;
begin
end;

procedure TpvApplication.Stop;
begin
end;

procedure TpvApplication.Load;
begin
end;

procedure TpvApplication.Unload;
begin
end;

procedure TpvApplication.Resume;
var Index:TpvInt32;
begin

 fLifecycleListenerListCriticalSection.Acquire;
 try
  for Index:=0 to fLifecycleListenerList.Count-1 do begin
   if TpvApplicationLifecycleListener(fLifecycleListenerList[Index]).Resume then begin
    break;
   end;
  end;
 finally
  fLifecycleListenerListCriticalSection.Release;
 end;

 if assigned(fScreen) then begin
  fScreen.Resume;
 end;

end;

procedure TpvApplication.Pause;
var Index:TpvInt32;
begin

 if assigned(fScreen) then begin
  fScreen.Pause;
 end;

 fLifecycleListenerListCriticalSection.Acquire;
 try
  for Index:=0 to fLifecycleListenerList.Count-1 do begin
   if TpvApplicationLifecycleListener(fLifecycleListenerList[Index]).Pause then begin
    break;
   end;
  end;
 finally
  fLifecycleListenerListCriticalSection.Release;
 end;

end;

procedure TpvApplication.LowMemory;
var Index:TpvInt32;
begin

 fLifecycleListenerListCriticalSection.Acquire;
 try
  for Index:=0 to fLifecycleListenerList.Count-1 do begin
   if TpvApplicationLifecycleListener(fLifecycleListenerList[Index]).LowMemory then begin
    break;
   end;
  end;
 finally
  fLifecycleListenerListCriticalSection.Release;
 end;

 if assigned(fScreen) then begin
  fScreen.LowMemory;
 end;

end;

procedure TpvApplication.Resize(const aWidth,aHeight:TpvInt32);
begin
 if assigned(fScreen) then begin
  fScreen.Resize(aWidth,aHeight);
 end;
end;

procedure TpvApplication.AfterCreateSwapChain;
begin
 if assigned(fScreen) then begin
  fScreen.AfterCreateSwapChain;
 end;
end;

procedure TpvApplication.BeforeDestroySwapChain;
begin
 if assigned(fScreen) then begin
  fScreen.BeforeDestroySwapChain;
 end;
end;

function TpvApplication.HandleEvent(const aEvent:TpvApplicationEvent):boolean;
begin
 if assigned(fOnEvent) and fOnEvent(self,aEvent) then begin
  result:=true;
 end else if assigned(fScreen) and fScreen.HandleEvent(aEvent) then begin
  result:=true;
 end else begin
  result:=false;
 end;
end;

function TpvApplication.KeyEvent(const aKeyEvent:TpvApplicationInputKeyEvent):boolean;
begin
 if assigned(fScreen) then begin
  result:=fScreen.KeyEvent(aKeyEvent);
 end else begin
  result:=false;
 end;
end;

function TpvApplication.PointerEvent(const aPointerEvent:TpvApplicationInputPointerEvent):boolean;
begin
 if assigned(fScreen) then begin
  result:=fScreen.PointerEvent(aPointerEvent);
 end else begin
  result:=false;
 end;
end;

function TpvApplication.Scrolled(const aRelativeAmount:TpvVector2):boolean;
begin
 if assigned(fScreen) then begin
  result:=fScreen.Scrolled(aRelativeAmount);
 end else begin
  result:=false;
 end;
end;

function TpvApplication.DragDropFileEvent(aFileName:TpvUTF8String):boolean;
begin
 if assigned(fScreen) then begin
  result:=fScreen.DragDropFileEvent(aFileName);
 end else begin
  result:=false;
 end;
end;

function TpvApplication.CanBeParallelProcessed:boolean;
begin
 if assigned(fScreen) then begin
  result:=fScreen.CanBeParallelProcessed;
 end else begin
  result:=false;
 end;
end;

procedure TpvApplication.Check(const aDeltaTime:TpvDouble);
begin
 if assigned(fScreen) then begin
  fScreen.Check(aDeltaTime);
 end;
end;

procedure TpvApplication.Update(const aDeltaTime:TpvDouble);
begin
 if assigned(fScreen) then begin
  fScreen.Update(aDeltaTime);
 end;
end;

procedure TpvApplication.BeginFrame(const aDeltaTime:TpvDouble);
begin
 if assigned(fScreen) then begin
  fScreen.BeginFrame(aDeltaTime);
 end;
end;

function TpvApplication.IsReadyForDrawOfInFlightFrameIndex(const aInFlightFrameIndex:TpvInt32):boolean;
begin
 result:=assigned(fScreen) and fScreen.IsReadyForDrawOfInFlightFrameIndex(aInFlightFrameIndex);
end;

procedure TpvApplication.DrawBlackScreen(const aSwapChainImageIndex:TpvInt32;var aWaitSemaphore:TpvVulkanSemaphore;const aWaitFence:TpvVulkanFence=nil);
var VulkanCommandBuffer:TpvVulkanCommandBuffer;
begin
 VulkanCommandBuffer:=fVulkanBlankCommandBuffers[aSwapChainImageIndex];

 VulkanCommandBuffer.Reset(TVkCommandBufferResetFlags(VK_COMMAND_BUFFER_RESET_RELEASE_RESOURCES_BIT));

 VulkanCommandBuffer.BeginRecording(TVkCommandBufferUsageFlags(VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT));

 fVulkanRenderPass.BeginRenderPass(VulkanCommandBuffer,
                                   fVulkanFrameBuffers[aSwapChainImageIndex],
                                   VK_SUBPASS_CONTENTS_INLINE,
                                   0,
                                   0,
                                   fVulkanSwapChain.Width,
                                   fVulkanSwapChain.Height);
 if assigned(fVulkanDevice.BreadcrumbBuffer) then begin
  fVulkanDevice.BreadcrumbBuffer.RenderPassHint(true);
 end;

 if assigned(fVulkanDevice.BreadcrumbBuffer) then begin
  fVulkanDevice.BreadcrumbBuffer.RenderPassHint(false);
 end;
 fVulkanRenderPass.EndRenderPass(VulkanCommandBuffer);

 VulkanCommandBuffer.EndRecording;

 VulkanCommandBuffer.Execute(fVulkanDevice.GraphicsQueue,
                             TVkPipelineStageFlags(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT),
                             aWaitSemaphore,
                             fVulkanBlankCommandBufferSemaphores[aSwapChainImageIndex],
                             aWaitFence,
                             false);

 aWaitSemaphore:=fVulkanBlankCommandBufferSemaphores[aSwapChainImageIndex];
end;

procedure TpvApplication.Draw(const aSwapChainImageIndex:TpvInt32;var aWaitSemaphore:TpvVulkanSemaphore;const aWaitFence:TpvVulkanFence=nil);
begin
 if assigned(fScreen) then begin
  fScreen.Draw(aSwapChainImageIndex,aWaitSemaphore,aWaitFence);
 end else begin
  DrawBlackScreen(aSwapChainImageIndex,aWaitSemaphore,aWaitFence);
 end;
end;

procedure TpvApplication.FinishFrame(const aSwapChainImageIndex:TpvInt32;var aWaitSemaphore:TpvVulkanSemaphore;const aWaitFence:TpvVulkanFence=nil);
begin
 if assigned(fScreen) then begin
  fScreen.FinishFrame(aSwapChainImageIndex,aWaitSemaphore,aWaitFence);
 end;
end;

procedure TpvApplication.PostPresent(const aSwapChainImageIndex:TpvInt32);
begin
 if assigned(fScreen) then begin
  fScreen.PostPresent(aSwapChainImageIndex);
 end;
end;

procedure TpvApplication.UpdateAudio;
begin
 // Runs on the audio thread (via the audio engine's UpdateHook, from inside the audio engine's critical section).
 // SetScreen holds fScreenLock across the whole screen lifecycle, which itself enters the audio engine's critical
 // section - so blocking here on fScreenLock would invert the lock order and dead-lock. Therefore only touch the
 // screen if fScreenLock can be grabbed without blocking; while a SetScreen is in progress just skip the screen
 // audio update for those few callbacks, which is harmless.
 if fScreenLock.TryEnter then begin
  try
   if assigned(fScreen) then begin
    fScreen.UpdateAudio;
   end;
  finally
   fScreenLock.Release;
  end;
 end;
end;

procedure TpvApplication.DumpVulkanMemoryManager;
var StringList:TStringList;
    Index:TpvSizeInt;
    Line:TpvUTF8String;
begin
 if assigned(fVulkanDevice) then begin
  StringList:=TStringList.Create;
  try
   fVulkanDevice.MemoryManager.Dump(StringList);
   for Index:=0 to StringList.Count-1 do begin
    Line:=StringList[Index];
    TpvApplication.Log(LOG_INFO,'TpvApplication',Line);
   end;
  finally
   FreeAndNil(StringList);
  end;
 end;
end;

function CompareDisplayModes(const a,b:PpvApplicationDisplayMode):TpvInt32;
begin
 result:=(a^.Width*a^.Height)-(b^.Width*b^.Height);
 if result=0 then begin
  result:=a^.RefreshRate-b^.RefreshRate;
 end;
end;

function TpvApplication.GetSupportedDisplayModes(const aDisplayIndex:TpvInt32=0):TpvApplicationDisplayModes;
{$if defined(PasVulkanHeadless)}
begin
 result:=nil;
end;
{$elseif defined(PasVulkanUseSDL2)}
var CountModes,Index,ResultCount:TpvInt32;
    SDLDisplayMode:TSDL_DisplayMode;
    DisplayMode:PpvApplicationDisplayMode;
    Found:Boolean;
    OtherIndex:TpvInt32;
begin
 result:=nil;
 ResultCount:=0;
 CountModes:=SDL_GetNumDisplayModes(aDisplayIndex);
 if CountModes>0 then begin
  for Index:=0 to CountModes-1 do begin
   if SDL_GetDisplayMode(aDisplayIndex,Index,@SDLDisplayMode)=0 then begin
    // Check for duplicates (same width/height, different refresh rate)
    Found:=false;
    for OtherIndex:=0 to ResultCount-1 do begin
     DisplayMode:=@result[OtherIndex];
     if (DisplayMode^.Width=SDLDisplayMode.w) and
        (DisplayMode^.Height=SDLDisplayMode.h) and
        (DisplayMode^.RefreshRate=SDLDisplayMode.refresh_rate) then begin
      Found:=true;
      break;
     end;
    end;
    if not Found then begin
     if ResultCount>=length(result) then begin
      SetLength(result,(ResultCount+1)*2);
     end;
     DisplayMode:=@result[ResultCount];
     inc(ResultCount);
     DisplayMode^.Width:=SDLDisplayMode.w;
     DisplayMode^.Height:=SDLDisplayMode.h;
     DisplayMode^.RefreshRate:=SDLDisplayMode.refresh_rate;
    end;
   end;
  end;
 end;
 SetLength(result,ResultCount);
 if length(result)>1 then begin
  UntypedDirectIntroSort(@result[0],0,length(result)-1,SizeOf(TpvApplicationDisplayMode),@CompareDisplayModes);
 end;
end;
{$elseif defined(Windows)}
var DevMode:TDeviceMode;
    Index,ResultCount:TpvInt32;
    DisplayMode:PpvApplicationDisplayMode;
    Found:Boolean;
    OtherIndex:TpvInt32;
begin
 result:=nil;
 ResultCount:=0;
 Index:=0;
 FillChar(DevMode,SizeOf(TDeviceMode),0);
 DevMode.dmSize:=SizeOf(TDeviceMode);
 while EnumDisplaySettings(nil,Index,DevMode) do begin
  // Check for duplicates (same width/height, different refresh rate/bit depth)
  Found:=false;
  for OtherIndex:=0 to ResultCount-1 do begin
   DisplayMode:=@result[OtherIndex];
   if (DisplayMode^.Width=TpvInt32(DevMode.dmPelsWidth)) and
      (DisplayMode^.Height=TpvInt32(DevMode.dmPelsHeight)) and
      (DisplayMode^.RefreshRate=TpvInt32(DevMode.dmDisplayFrequency)) then begin
    Found:=true;
    break;
   end;
  end;
  if not Found then begin
   if ResultCount>=length(result) then begin
    SetLength(result,(ResultCount+1)*2);
   end;
   DisplayMode:=@result[ResultCount];
   inc(ResultCount);
   DisplayMode^.Width:=DevMode.dmPelsWidth;
   DisplayMode^.Height:=DevMode.dmPelsHeight;
   DisplayMode^.RefreshRate:=DevMode.dmDisplayFrequency;
  end;
  inc(Index);
 end;
 SetLength(result,ResultCount);
 if length(result)>1 then begin
  UntypedDirectIntroSort(@result[0],0,length(result)-1,SizeOf(TpvApplicationDisplayMode),@CompareDisplayModes);
 end;
end;
{$else}
begin
 // Other platforms - return empty array
 result:=nil;
end;
{$ifend}

class procedure TpvApplication.Main;
begin
 pvApplication:=self.Create;
 try
  pvApplication.Setup;
  pvApplication.Run;
 finally
  FreeAndNil(pvApplication);
 end;
end;

{$if defined(fpc) and defined(android)}
function AndroidGetManufacturerName:TpvApplicationUnicodeString;
var AndroisOSBuild:jclass;
    ManufacturerID:JFieldID;
    ManufacturerStringObject:JString;
    ManufacturerStringLength:JSize;
    ManufacturerStringChars:PJChar;
begin
 result:='';
 AndroisOSBuild:=AndroidJavaEnv^.FindClass(AndroidJavaEnv,'android/os/Build');
 ManufacturerID:=AndroidJavaEnv^.GetStaticFieldID(AndroidJavaEnv,AndroisOSBuild,'MANUFACTURER','Ljava/lang/String;');
 ManufacturerStringObject:=AndroidJavaEnv^.GetStaticObjectField(AndroidJavaEnv,AndroisOSBuild,ManufacturerID);
 ManufacturerStringLength:=AndroidJavaEnv^.GetStringLength(AndroidJavaEnv,ManufacturerStringObject);
 ManufacturerStringChars:=AndroidJavaEnv^.GetStringChars(AndroidJavaEnv,ManufacturerStringObject,nil);
 if assigned(ManufacturerStringChars) then begin
  if ManufacturerStringLength>0 then begin
   SetLength(result,ManufacturerStringLength);
   Move(ManufacturerStringChars^,result[1],ManufacturerStringLength*SizeOf(WideChar));
  end;
  AndroidJavaEnv^.ReleaseStringChars(AndroidJavaEnv,ManufacturerStringObject,ManufacturerStringChars);
 end;
end;

function AndroidGetModelName:TpvApplicationUnicodeString;
var AndroisOSBuild:jclass;
    ModelID:JFieldID;
    ModelStringObject:JString;
    ModelStringLength:JSize;
    ModelStringChars:PJChar;
begin
 result:='';
 AndroisOSBuild:=AndroidJavaEnv^.FindClass(AndroidJavaEnv,'android/os/Build');
 ModelID:=AndroidJavaEnv^.GetStaticFieldID(AndroidJavaEnv,AndroisOSBuild,'MODEL','Ljava/lang/String;');
 ModelStringObject:=AndroidJavaEnv^.GetStaticObjectField(AndroidJavaEnv,AndroisOSBuild,ModelID);
 ModelStringLength:=AndroidJavaEnv^.GetStringLength(AndroidJavaEnv,ModelStringObject);
 ModelStringChars:=AndroidJavaEnv^.GetStringChars(AndroidJavaEnv,ModelStringObject,nil);
 if assigned(ModelStringChars) then begin
  if ModelStringLength>0 then begin
   SetLength(result,ModelStringLength);
   Move(ModelStringChars^,result[1],ModelStringLength*SizeOf(WideChar));
  end;
  AndroidJavaEnv^.ReleaseStringChars(AndroidJavaEnv,ModelStringObject,ModelStringChars);
 end;
end;

function AndroidGetDeviceName:TpvApplicationUnicodeString;
begin
 result:=AndroidGetManufacturerName+' '+AndroidGetModelName;
end;

{$if defined(fpc) and defined(android) and defined(PasVulkanUseSDL2)}
procedure AndroidGetAssetManager;
var Env:PJNIEnv;
    Context:JObject;
    MethodID:JMethodID;
begin
{$if (defined(fpc) and defined(android)) and not defined(Release)}
 __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Entering AndroidGetAssetManager . . .');
{$ifend}
 Env:=SDL_AndroidGetJNIEnv;
 Context:=SDL_AndroidGetActivity;
 MethodID:=Env^.GetMethodID(Env,Env^.GetObjectClass(Env,Context),'getAssets','()Landroid/content/res/AssetManager;');
 AndroidAssetManagerObject:=Env^.CallObjectMethod(Env,Context,MethodID);
 AndroidAssetManagerObject:=Env^.NewGlobalRef(Env,AndroidAssetManagerObject);
 AndroidAssetManager:=AAssetManager_fromJava(Env,AndroidAssetManagerObject);
{$if (defined(fpc) and defined(android)) and not defined(Release)}
 __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Leaving AndroidGetAssetManager . . .');
{$ifend}
end;

procedure AndroidReleaseAssetManager;
var Env:PJNIEnv;
begin
{$if (defined(fpc) and defined(android)) and not defined(Release)}
 __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Entering AndroidReleaseAssetManager . . .');
{$ifend}
 Env:=SDL_AndroidGetJNIEnv;
 Env^.DeleteGlobalRef(Env,AndroidAssetManagerObject);
{$if (defined(fpc) and defined(android)) and not defined(Release)}
 __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Leaving AndroidReleaseAssetManager . . .');
{$ifend}
end;
{$ifend}

(*function Android_JNI_GetEnv:PJNIEnv; cdecl;
begin
{$if (defined(fpc) and defined(android)) and not defined(Release)}
 __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Entering Android_JNI_GetEnv . . .');
{$ifend}
 if assigned(pvApplication) then begin
  result:=AndroidJavaEnv;
 end else begin
  result:=nil;
 end;
{$if (defined(fpc) and defined(android)) and not defined(Release)}
 __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Leaving Android_JNI_GetEnv . . .');
{$ifend}
end;*)

{$if not (defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless))}
function LibCMalloc(Size:ptruint):pointer; cdecl; external 'c' name 'malloc';
procedure LibCFree(p:pointer); cdecl; external 'c' name 'free';

{function DumpExceptionCallStack(e:Exception):string;
var i:int32;
    Frames:PPointer;
begin
 result:='Program exception! '+LineEnding+'Stack trace:'+LineEnding+LineEnding;
 if assigned(e) then begin
  result:=result+'Exception class: '+e.ClassName+LineEnding+'Message: '+E.Message+LineEnding;
 end;
 result:=result+BackTraceStrFunc(ExceptAddr);
 Frames:=ExceptFrames;
 for i:=0 to ExceptFrameCount-1 do begin
  result:=result+LineEnding+BackTraceStrFunc(Frames);
  inc(Frames);
 end;
end;}

type PLooperID=^TLooperID;
     TLooperID=
      (
       LOOPER_ID_MAIN=1,
       LOOPER_ID_INPUT,
       LOOPER_ID_USER
      );

     PAppCmd=^TAppCmd;
     TAppCmd=
      (
       APP_CMD_INPUT_CHANGED=1,
       APP_CMD_INIT_WINDOW,
       APP_CMD_TERM_WINDOW,
       APP_CMD_WINDOW_RESIZED,
       APP_CMD_WINDOW_REDRAW_NEEDED,
       APP_CMD_CONTENT_RECT_CHANGED,
       APP_CMD_GAINED_FOCUS,
       APP_CMD_LOST_FOCUS,
       APP_CMD_CONFIG_CHANGED,
       APP_CMD_LOW_MEMORY,
       APP_CMD_START,
       APP_CMD_RESUME,
       APP_CMD_SAVE_STATE,
       APP_CMD_PAUSE,
       APP_CMD_STOP,
       APP_CMD_DESTROY
      );

     PAndroidApp=^TAndroidApp;

     PAndroidPollSource=^TAndroidPollSource;
     TAndroidPollSource=packed record
      public
       fID:TLooperID;
       fApp:PAndroidApp;
       fProcess:procedure(const aApp:PAndroidApp;const aSource:PAndroidPollSource); cdecl;
     end;

     TAndroidAppThread=class(TThread)
      private
       fAndroidApp:PAndroidApp;
      protected
       procedure Execute;
      public
       constructor Create(const aAndroidApp:PAndroidApp);
     end;

     TAndroidApp=packed record
      public
       fUserData:TpvPointer;
       fActivity:PANativeActivity;
       fConfiguration:PAConfiguration;
       fSavedState:TpvPointer;
       fSavedStateSize:TPasMPUInt32;
       fLooper:PALooper;
       fInputQueue:PAInputQueue;
       fWindow:PANativeWindow;
       fContentRect:TARect;
       fActivityState:TAppCmd;
       fDestroyRequested:TPasMPBool32;
       fConditionVariableLock:TPasMPConditionVariableLock;
       fConditionVariable:TPasMPConditionVariable;
       fApplication:TpvApplication;
       fApplicationClass:TpvApplicationClass;
       fCmdPollSource:TAndroidPollSource;
       fInputPollSource:TAndroidPollSource;
       fRunning:TPasMPBool32;
       fStateSaved:TPasMPBool32;
       fDestroyed:TPasMPBool32;
       fRedrawNeeded:TPasMPBool32;
       fPendingInputQueue:PAInputQueue;
       fPendingWindow:PANativeWindow;
       fPendingContentRect:TARect;
       fMsgPipe:TFilDes;
       constructor Create(const aActivity:PANativeActivity;
                          const aApplicationClass:TpvApplicationClass;
                          const aSavedState:TpvPointer;
                          const aSavedStateSize:TpvNativeUInt);
       procedure Destroy;
       function AllocateSavedState(const aSize:TpvNativeUInt):TpvPointer;
       procedure FreeSavedState;
       procedure SendCmd(const aCmd:TAppCmd);
       procedure SetInput(const aInputQueue:PAInputQueue);
       procedure SetWindow(const aWindow:PANativeWindow);
       procedure SetActivityState(const aCmd:TAppCmd);
       procedure ProcessInputEvent(const aEvent:PAInputEvent);
       procedure ProcessCmd(const aCmd:TAppCmd);
     end;

procedure AppProcessInput(const aApp:PAndroidApp;const aSource:PAndroidPollSource); cdecl;
var Event:PAInputEvent;
    Handled,Processed:boolean;
begin
 Event:=nil;
 Processed:=false;
 while AInputQueue_getEvent(aApp^.fInputQueue,@Event)>=0 do begin
  if AInputQueue_preDispatchEvent(aApp^.fInputQueue,Event)=0 then begin
   Handled:=false;
   aApp^.ProcessInputEvent(Event);
   AInputQueue_finishEvent(aApp^.fInputQueue,Event,IfThen(Handled,1,0));
   Processed:=true;
  end;
 end;
 if not Processed then begin
  __android_log_write(ANDROID_LOG_ERROR,'PasVulkanApplication','Failure reading next input event . . .');
 end;
end;

procedure AppProcessCmd(const aApp:PAndroidApp;const aSource:PAndroidPollSource); cdecl;
var Cmd:TAppCmd;
begin
 if fpread(aApp^.fMsgPipe[0],@Cmd,SizeOf(TAppCmd))=SizeOf(TAppCmd) then begin
  case Cmd of
   APP_CMD_INPUT_CHANGED:begin
    aApp^.fConditionVariableLock.Acquire;
    try
     if assigned(aApp^.fInputQueue) then begin
      AInputQueue_detachLooper(aApp^.fInputQueue);
     end;
     aApp^.fInputQueue:=aApp^.fPendingInputQueue;
     if assigned(aApp^.fInputQueue) then begin
      AInputQueue_attachLooper(aApp^.fInputQueue,aApp^.fLooper,TpvInt32(LOOPER_ID_INPUT),nil,@aApp^.fInputPollSource);
     end;
     aApp^.fConditionVariable.Broadcast;
    finally
     aApp^.fConditionVariableLock.Release;
    end;
   end;
   APP_CMD_INIT_WINDOW:begin
    aApp^.fConditionVariableLock.Acquire;
    try
     aApp^.fWindow:=aApp^.fPendingWindow;
     aApp^.fConditionVariable.Broadcast;
    finally
     aApp^.fConditionVariableLock.Release;
    end;
   end;
   APP_CMD_TERM_WINDOW:begin
    aApp^.fConditionVariableLock.Acquire;
    try
     aApp^.fWindow:=nil;
     aApp^.fConditionVariable.Broadcast;
    finally
     aApp^.fConditionVariableLock.Release;
    end;
   end;
   APP_CMD_WINDOW_RESIZED:begin
   end;
   APP_CMD_WINDOW_REDRAW_NEEDED:begin
   end;
   APP_CMD_CONTENT_RECT_CHANGED:begin
   end;
   APP_CMD_GAINED_FOCUS:begin
   end;
   APP_CMD_LOST_FOCUS:begin
   end;
   APP_CMD_CONFIG_CHANGED:begin
    AConfiguration_fromAssetManager(aApp^.fConfiguration,aApp^.fActivity^.assetManager);
   end;
   APP_CMD_LOW_MEMORY:begin
   end;
   APP_CMD_START:begin
    aApp^.fConditionVariableLock.Acquire;
    try
     aApp^.fActivityState:=APP_CMD_START;
     aApp^.fConditionVariable.Broadcast;
    finally
     aApp^.fConditionVariableLock.Release;
    end;
   end;
   APP_CMD_RESUME:begin
    aApp^.fConditionVariableLock.Acquire;
    try
     aApp^.fActivityState:=APP_CMD_RESUME;
     aApp^.fConditionVariable.Broadcast;
    finally
     aApp^.fConditionVariableLock.Release;
    end;
   end;
   APP_CMD_SAVE_STATE:begin
    aApp^.FreeSavedState;
   end;
   APP_CMD_PAUSE:begin
    aApp^.fConditionVariableLock.Acquire;
    try
     aApp^.fActivityState:=APP_CMD_PAUSE;
     aApp^.fConditionVariable.Broadcast;
    finally
     aApp^.fConditionVariableLock.Release;
    end;
   end;
   APP_CMD_STOP:begin
    aApp^.fConditionVariableLock.Acquire;
    try
     aApp^.fActivityState:=APP_CMD_STOP;
     aApp^.fConditionVariable.Broadcast;
    finally
     aApp^.fConditionVariableLock.Release;
    end;
   end;
   APP_CMD_DESTROY:begin
    TPasMPInterlocked.Write(aApp^.fDestroyRequested,true);
   end;
  end;
  aApp^.ProcessCmd(Cmd);
  case Cmd of
   APP_CMD_INPUT_CHANGED:begin
   end;
   APP_CMD_INIT_WINDOW:begin
   end;
   APP_CMD_TERM_WINDOW:begin
    aApp^.fConditionVariableLock.Acquire;
    try
     aApp^.fWindow:=nil;
     aApp^.fConditionVariable.Broadcast;
    finally
     aApp^.fConditionVariableLock.Release;
    end;
   end;
   APP_CMD_WINDOW_RESIZED:begin
   end;
   APP_CMD_WINDOW_REDRAW_NEEDED:begin
   end;
   APP_CMD_CONTENT_RECT_CHANGED:begin
   end;
   APP_CMD_GAINED_FOCUS:begin
   end;
   APP_CMD_LOST_FOCUS:begin
   end;
   APP_CMD_CONFIG_CHANGED:begin
   end;
   APP_CMD_LOW_MEMORY:begin
   end;
   APP_CMD_START:begin
   end;
   APP_CMD_RESUME:begin
   end;
   APP_CMD_SAVE_STATE:begin
    aApp^.fConditionVariableLock.Acquire;
    try
     TPasMPInterlocked.Write(aApp^.fStateSaved,true);
     aApp^.fConditionVariable.Broadcast;
    finally
     aApp^.fConditionVariableLock.Release;
    end;
   end;
   APP_CMD_PAUSE:begin
   end;
   APP_CMD_STOP:begin
   end;
   APP_CMD_DESTROY:begin
   end;
  end;
 end else begin
  __android_log_write(ANDROID_LOG_ERROR,'PasVulkanApplication','Pipe read error . . .');
 end;
end;

procedure AndroidAppProcessMessages(const aAndroidApp:TpvPointer;const aWait:boolean);
var Events:TpvInt32;
    Source:PAndroidPollSource;
begin
 Events:=0;
 Source:=nil;
 while ALooper_pollAll(IfThen(aWait,-1,0),nil,@Events,@Source)>=0 do begin
  if assigned(Source) then begin
   Source^.fProcess(Source^.fApp,Source);
  end;
 end;
end;

constructor TAndroidAppThread.Create(const aAndroidApp:PAndroidApp);
begin
 fAndroidApp:=aAndroidApp;
 FreeOnTerminate:=true;
 inherited Create(false);
end;

procedure TAndroidAppThread.Execute;
var Looper:PALooper;
begin
 try

{$if (defined(fpc) and defined(android)) and not defined(Release)}
  __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Entering TAndroidAppThread.Execute . . .');
{$ifend}

  try

   fAndroidApp^.fConfiguration:=AConfiguration_new();
   AConfiguration_fromAssetManager(fAndroidApp^.fConfiguration,fAndroidApp^.fActivity^.assetManager);

   fAndroidApp^.fCmdPollSource.fID:=LOOPER_ID_MAIN;
   fAndroidApp^.fCmdPollSource.fApp:=fAndroidApp;
   fAndroidApp^.fCmdPollSource.fProcess:=@AppProcessCmd;

   fAndroidApp^.fInputPollSource.fID:=LOOPER_ID_INPUT;
   fAndroidApp^.fInputPollSource.fApp:=fAndroidApp;
   fAndroidApp^.fInputPollSource.fProcess:=@AppProcessInput;

   Looper:=ALooper_prepare(ALOOPER_PREPARE_ALLOW_NON_CALLBACKS);
   ALooper_addFd(Looper,fAndroidApp^.fMsgPipe[0],TpvInt32(LOOPER_ID_MAIN),ALOOPER_EVENT_INPUT,nil,@fAndroidApp^.fCmdPollSource);
   fAndroidApp^.fLooper:=Looper;

   fAndroidApp^.fApplication:=fAndroidApp^.fApplicationClass.Create;
   try
    fAndroidApp^.fApplication.fAndroidApp:=fAndroidApp;
    fAndroidApp^.fApplication.fAndroidWindow:=nil;
    fAndroidApp^.fApplication.fAndroidReady:=false;
    fAndroidApp^.fApplication.fAndroidQuit:=false;
    fAndroidApp^.fApplication.fAndroidAppProcessMessages:=AndroidAppProcessMessages;
    fAndroidApp^.fApplication.Setup;
    fAndroidApp^.fConditionVariableLock.Acquire;
    try
     TPasMPInterlocked.Write(fAndroidApp^.fRunning,true);
     fAndroidApp^.fConditionVariable.Broadcast;
    finally
     fAndroidApp^.fConditionVariableLock.Release;
    end;
    try
     fAndroidApp^.fApplication.Run;
    finally
     fAndroidApp^.fConditionVariableLock.Acquire;
     try
      TPasMPInterlocked.Write(fAndroidApp^.fRunning,false);
      fAndroidApp^.fConditionVariable.Broadcast;
     finally
      fAndroidApp^.fConditionVariableLock.Release;
     end;
    end;
   finally
    FreeAndNil(fAndroidApp^.fApplication);
   end;

  finally
{$if (defined(fpc) and defined(android)) and not defined(Release)}
   __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Leaving TAndroidAppThread.Execute . . .');
{$ifend}
  end;

 finally
  fAndroidApp^.fConditionVariableLock.Acquire;
  try
   TPasMPInterlocked.Write(fAndroidApp^.fDestroyed,true);
   fAndroidApp^.fConditionVariable.Broadcast;
  finally
   fAndroidApp^.fConditionVariableLock.Release;
  end;
 end;
end;

constructor TAndroidApp.Create(const aActivity:PANativeActivity;
                               const aApplicationClass:TpvApplicationClass;
                               const aSavedState:TpvPointer;
                               const aSavedStateSize:TpvNativeUInt);
begin
{$if (defined(fpc) and defined(android)) and not defined(Release)}
 __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Entering TAndroidApp.Create . . .');
{$ifend}
 try
  try

   FillChar(self,SizeOf(TAndroidApp),#0);

   fActivity:=aActivity;

   fConditionVariableLock:=TPasMPConditionVariableLock.Create;

   fConditionVariable:=TPasMPConditionVariable.Create;

   if assigned(aSavedState) then begin
    fSavedState:=AllocateSavedState(aSavedStateSize);
    fSavedStateSize:=aSavedStateSize;
    Move(aSavedState^,fSavedState^,aSavedStateSize);
   end;

   if fppipe(fMsgPipe)<>0 then begin
    raise Exception.Create('fppipe');
   end;

   TAndroidAppThread.Create(@self);

   fConditionVariableLock.Acquire;
   try
    while not TPasMPInterlocked.Read(fRunning) do begin
     fConditionVariable.Wait(fConditionVariableLock);
    end;
   finally
    fConditionVariableLock.Release;
   end;

  except
   on e:Exception do begin
    __android_log_write(ANDROID_LOG_FATAL,'PasVulkanApplication',PAnsiChar(TpvUTF8String(DumpExceptionCallStack(e))));
   end;
  end;
 finally
{$if (defined(fpc) and defined(android)) and not defined(Release)}
  __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Leaving TAndroidApp.Create . . .');
{$ifend}
 end;
end;

procedure TAndroidApp.Destroy;
begin
{$if (defined(fpc) and defined(android)) and not defined(Release)}
 __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Entering TAndroidApp.Destroy . . .');
{$ifend}
 try
  try

   fConditionVariableLock.Acquire;
   try
    SendCmd(APP_CMD_DESTROY);
    while not TPasMPInterlocked.Read(fDestroyed) do begin
     fConditionVariable.Wait(fConditionVariableLock);
    end;
   finally
    fConditionVariableLock.Release;
   end;

   fpclose(fMsgPipe[0]);
   fpclose(fMsgPipe[1]);

   FreeAndNil(fConditionVariable);
   FreeAndNil(fConditionVariableLock);

  except
   on e:Exception do begin
    __android_log_write(ANDROID_LOG_FATAL,'PasVulkanApplication',PAnsiChar(TpvUTF8String(DumpExceptionCallStack(e))));
   end;
  end;
 finally
{$if (defined(fpc) and defined(android)) and not defined(Release)}
  __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Leaving TAndroidApp.Destroy . . .');
{$ifend}
 end;
end;

function TAndroidApp.AllocateSavedState(const aSize:TpvNativeUInt):TpvPointer;
begin
 result:=LibCMalloc(aSize);
end;

procedure TAndroidApp.FreeSavedState;
begin
 if assigned(fSavedState) then begin
  LibCFree(fSavedState);
  fSavedState:=nil;
  fSavedStateSize:=0;
 end;
end;

procedure TAndroidApp.SendCmd(const aCmd:TAppCmd);
begin
 if fpwrite(fMsgPipe[1],aCmd,SizeOf(TAppCmd))<>SizeOf(TAppCmd) then begin
 end;
end;

procedure TAndroidApp.SetInput(const aInputQueue:PAInputQueue);
begin
 fConditionVariableLock.Acquire;
 try
  fPendingInputQueue:=aInputQueue;
  SendCmd(APP_CMD_INPUT_CHANGED);
  while fInputQueue<>fPendingInputQueue do begin
   fConditionVariable.Wait(fConditionVariableLock);
  end;
 finally
  fConditionVariableLock.Release;
 end;
end;

procedure TAndroidApp.SetWindow(const aWindow:PANativeWindow);
begin
 fConditionVariableLock.Acquire;
 try
  if assigned(fPendingWindow) then begin
   SendCmd(APP_CMD_TERM_WINDOW);
  end;
  fPendingWindow:=aWindow;
  if assigned(aWindow) then begin
   SendCmd(APP_CMD_INIT_WINDOW);
  end;
  while fWindow<>fPendingWindow do begin
   fConditionVariable.Wait(fConditionVariableLock);
  end;
 finally
  fConditionVariableLock.Release;
 end;
end;

procedure TAndroidApp.SetActivityState(const aCmd:TAppCmd);
begin
 fConditionVariableLock.Acquire;
 try
  SendCmd(aCmd);
  while fActivityState<>aCmd do begin
   fConditionVariable.Wait(fConditionVariableLock);
  end;
 finally
  fConditionVariableLock.Release;
 end;
end;

procedure TAndroidApp.ProcessInputEvent(const aEvent:PAInputEvent);
var EventType,EventSource,EventKeyCode,EventAction:TpvInt32;
begin
 if assigned(aEvent) then begin
  EventType:=AInputEvent_getType(aEvent);
  case EventType of
   AINPUT_EVENT_TYPE_KEY:begin
    EventKeyCode:=AKeyEvent_getKeyCode(aEvent);
    EventAction:=AKeyEvent_getAction(aEvent);
    if (EventKeyCode<>AKEYCODE_UNKNOWN) and
       (EventAction in [AKEY_EVENT_ACTION_DOWN,
                        AKEY_EVENT_ACTION_UP,
                        AKEY_EVENT_ACTION_MULTIPLE]) then begin

    end;
   end;
   AINPUT_EVENT_TYPE_MOTION:begin
    EventSource:=AInputEvent_getSource(aEvent);
    case EventSource of
     AINPUT_SOURCE_JOYSTICK:begin
     end;
     AINPUT_SOURCE_TOUCHSCREEN:begin
     end;
     AINPUT_SOURCE_MOUSE:begin
     end;
    end;
   end;
  end;
 end;
end;

procedure TAndroidApp.ProcessCmd(const aCmd:TAppCmd);
begin
 case aCmd of
  APP_CMD_INPUT_CHANGED:begin
  end;
  APP_CMD_INIT_WINDOW:begin
   if assigned(fApplication) then begin
    fApplication.fAndroidWindow:=fWindow;
    fApplication.fAndroidReady:=true;
   end;
  end;
  APP_CMD_TERM_WINDOW:begin
   if assigned(fApplication) then begin
    fApplication.fAndroidWindow:=nil;
    fApplication.fAndroidReady:=false;
   end;
  end;
  APP_CMD_WINDOW_RESIZED:begin
  end;
  APP_CMD_WINDOW_REDRAW_NEEDED:begin
  end;
  APP_CMD_CONTENT_RECT_CHANGED:begin
  end;
  APP_CMD_GAINED_FOCUS:begin
  end;
  APP_CMD_LOST_FOCUS:begin
  end;
  APP_CMD_CONFIG_CHANGED:begin
  end;
  APP_CMD_LOW_MEMORY:begin
  end;
  APP_CMD_START:begin
  end;
  APP_CMD_RESUME:begin
  end;
  APP_CMD_SAVE_STATE:begin
  end;
  APP_CMD_PAUSE:begin
  end;
  APP_CMD_STOP:begin
   if assigned(fApplication) then begin
    fApplication.fAndroidQuit:=true;
   end;
   ANativeActivity_finish(fActivity);
  end;
  APP_CMD_DESTROY:begin
   if assigned(fApplication) then begin
    fApplication.fAndroidQuit:=true;
   end;
  end;
 end;
end;

procedure Android_ANativeActivity_onStart(aActivity:PANativeActivity); cdecl;
begin
{$if (defined(fpc) and defined(android)) and not defined(Release)}
 __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Entering Android_ANativeActivity_onStart . . .');
{$ifend}
 try
  try
   PAndroidApp(aActivity^.instance)^.SetActivityState(APP_CMD_START);
  except
   on e:Exception do begin
    __android_log_write(ANDROID_LOG_FATAL,'PasVulkanApplication',PAnsiChar(TpvUTF8String(DumpExceptionCallStack(e))));
   end;
  end;
 finally
{$if (defined(fpc) and defined(android)) and not defined(Release)}
  __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Leaving Android_ANativeActivity_onStart . . .');
{$ifend}
 end;
end;

procedure Android_ANativeActivity_onResume(aActivity:PANativeActivity); cdecl;
begin
{$if (defined(fpc) and defined(android)) and not defined(Release)}
 __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Entering Android_ANativeActivity_onResime . . .');
{$ifend}
 try
  try
   PAndroidApp(aActivity^.instance)^.SetActivityState(APP_CMD_RESUME);
  except
   on e:Exception do begin
    __android_log_write(ANDROID_LOG_FATAL,'PasVulkanApplication',PAnsiChar(TpvUTF8String(DumpExceptionCallStack(e))));
   end;
  end;
 finally
{$if (defined(fpc) and defined(android)) and not defined(Release)}
  __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Leaving Android_ANativeActivity_onResume . . .');
{$ifend}
 end;
end;

function Android_ANativeActivity_onSaveInstanceState(aActivity:PANativeActivity;aOutSize:Psize_t):TpvPointer; cdecl;
begin
{$if (defined(fpc) and defined(android)) and not defined(Release)}
 __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Entering Android_ANativeActivity_onSaveInstanceState . . .');
{$ifend}
 try
  try
   PAndroidApp(aActivity^.instance)^.fConditionVariableLock.Acquire;
   try
    PAndroidApp(aActivity^.instance)^.fStateSaved:=false;
    PAndroidApp(aActivity^.instance)^.SendCmd(APP_CMD_SAVE_STATE);
    while not PAndroidApp(aActivity^.instance)^.fStateSaved do begin
     PAndroidApp(aActivity^.instance)^.fConditionVariable.Wait(PAndroidApp(aActivity^.instance)^.fConditionVariableLock);
    end;
    if assigned(PAndroidApp(aActivity^.instance)^.fSavedState) then begin
     result:=TPasMPInterlocked.Exchange(PAndroidApp(aActivity^.instance)^.fSavedState,nil);
     aOutSize^:=TPasMPInterlocked.Exchange(PAndroidApp(aActivity^.instance)^.fSavedStateSize,0);
    end else begin
     result:=nil;
    end;
   finally
    PAndroidApp(aActivity^.instance)^.fConditionVariableLock.Release;
   end;
  except
   on e:Exception do begin
    __android_log_write(ANDROID_LOG_FATAL,'PasVulkanApplication',PAnsiChar(TpvUTF8String(DumpExceptionCallStack(e))));
   end;
  end;
 finally
{$if (defined(fpc) and defined(android)) and not defined(Release)}
  __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Leaving Android_ANativeActivity_onSaveInstanceState . . .');
{$ifend}
 end;
end;

procedure Android_ANativeActivity_onPause(aActivity:PANativeActivity); cdecl;
begin
{$if (defined(fpc) and defined(android)) and not defined(Release)}
 __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Entering Android_ANativeActivity_onPause . . .');
{$ifend}
 try
  try
   PAndroidApp(aActivity^.instance)^.SetActivityState(APP_CMD_PAUSE);
  except
   on e:Exception do begin
    __android_log_write(ANDROID_LOG_FATAL,'PasVulkanApplication',PAnsiChar(TpvUTF8String(DumpExceptionCallStack(e))));
   end;
  end;
 finally
{$if (defined(fpc) and defined(android)) and not defined(Release)}
  __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Leaving Android_ANativeActivity_onPause . . .');
{$ifend}
 end;
end;

procedure Android_ANativeActivity_onStop(aActivity:PANativeActivity); cdecl;
begin
{$if (defined(fpc) and defined(android)) and not defined(Release)}
 __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Entering Android_ANativeActivity_onStop . .');
{$ifend}
 try
  try
   PAndroidApp(aActivity^.instance)^.SetActivityState(APP_CMD_STOP);
  except
   on e:Exception do begin
    __android_log_write(ANDROID_LOG_FATAL,'PasVulkanApplication',PAnsiChar(TpvUTF8String(DumpExceptionCallStack(e))));
   end;
  end;
 finally
{$if (defined(fpc) and defined(android)) and not defined(Release)}
  __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Leaving Android_ANativeActivity_onStop . . .');
{$ifend}
 end;
end;

procedure Android_ANativeActivity_onDestroy(aActivity:PANativeActivity); cdecl;
begin
{$if (defined(fpc) and defined(android)) and not defined(Release)}
 __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Entering Android_ANativeActivity_onDestroy . . .');
{$ifend}
 try
  try
   PAndroidApp(aActivity^.instance)^.Destroy;
   LibCFree(aActivity^.instance);
  except
   on e:Exception do begin
    __android_log_write(ANDROID_LOG_FATAL,'PasVulkanApplication',PAnsiChar(TpvUTF8String(DumpExceptionCallStack(e))));
   end;
  end;
 finally
{$if (defined(fpc) and defined(android)) and not defined(Release)}
  __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Leaving Android_ANativeActivity_onDestroy . . .');
{$ifend}
 end;
end;

procedure Android_ANativeActivity_onWindowFocusChanged(aActivity:PANativeActivity;aHasFocus:cint); cdecl;
begin
{$if (defined(fpc) and defined(android)) and not defined(Release)}
 __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Entering Android_ANativeActivity_onWindowFocusChanged . .');
{$ifend}
 try
  try
   if aHasFocus<>0 then begin
    PAndroidApp(aActivity^.instance)^.SetActivityState(APP_CMD_GAINED_FOCUS);
   end else begin
    PAndroidApp(aActivity^.instance)^.SetActivityState(APP_CMD_LOST_FOCUS);
   end;
  except
   on e:Exception do begin
    __android_log_write(ANDROID_LOG_FATAL,'PasVulkanApplication',PAnsiChar(TpvUTF8String(DumpExceptionCallStack(e))));
   end;
  end;
 finally
{$if (defined(fpc) and defined(android)) and not defined(Release)}
  __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Leaving Android_ANativeActivity_onWindowFocusChanged . . .');
{$ifend}
 end;
end;

procedure Android_ANativeActivity_onNativeWindowCreated(aActivity:PANativeActivity;aWindow:PANativeWindow); cdecl;
begin
{$if (defined(fpc) and defined(android)) and not defined(Release)}
 __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Entering Android_ANativeActivity_onNativeWindowCreated . .');
{$ifend}
 try
  try
   PAndroidApp(aActivity^.instance)^.SetWindow(aWindow);
  except
   on e:Exception do begin
    __android_log_write(ANDROID_LOG_FATAL,'PasVulkanApplication',PAnsiChar(TpvUTF8String(DumpExceptionCallStack(e))));
   end;
  end;
 finally
{$if (defined(fpc) and defined(android)) and not defined(Release)}
  __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Leaving Android_ANativeActivity_onNativeWindowCreated . . .');
{$ifend}
 end;
end;

procedure Android_ANativeActivity_onNativeWindowResized(aActivity:PANativeActivity;aWindow:PANativeWindow); cdecl;
begin
{$if (defined(fpc) and defined(android)) and not defined(Release)}
 __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Entering Android_ANativeActivity_onNativeWindowResized . .');
{$ifend}
 try
  try
   PAndroidApp(aActivity^.instance)^.SendCmd(APP_CMD_WINDOW_RESIZED);
  except
   on e:Exception do begin
    __android_log_write(ANDROID_LOG_FATAL,'PasVulkanApplication',PAnsiChar(TpvUTF8String(DumpExceptionCallStack(e))));
   end;
  end;
 finally
{$if (defined(fpc) and defined(android)) and not defined(Release)}
  __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Leaving Android_ANativeActivity_onNativeWindowResized . . .');
{$ifend}
 end;
end;

procedure Android_ANativeActivity_onNativeWindowRedrawNeeded(aActivity:PANativeActivity;aWindow:PANativeWindow); cdecl;
begin
{$if (defined(fpc) and defined(android)) and not defined(Release)}
 __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Entering Android_ANativeActivity_onNativeWindowRedrawNeeded . .');
{$ifend}
 try
  try
   PAndroidApp(aActivity^.instance)^.SendCmd(APP_CMD_WINDOW_REDRAW_NEEDED);
  except
   on e:Exception do begin
    __android_log_write(ANDROID_LOG_FATAL,'PasVulkanApplication',PAnsiChar(TpvUTF8String(DumpExceptionCallStack(e))));
   end;
  end;
 finally
{$if (defined(fpc) and defined(android)) and not defined(Release)}
  __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Leaving Android_ANativeActivity_onNativeWindowRedrawNeeded . . .');
{$ifend}
 end;
end;

procedure Android_ANativeActivity_onNativeWindowDestroyed(aActivity:PANativeActivity;aWindow:PANativeWindow); cdecl;
begin
{$if (defined(fpc) and defined(android)) and not defined(Release)}
 __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Entering Android_ANativeActivity_onNativeWindowDestroyed . .');
{$ifend}
 try
  try
   PAndroidApp(aActivity^.instance)^.SetWindow(nil);
  except
   on e:Exception do begin
    __android_log_write(ANDROID_LOG_FATAL,'PasVulkanApplication',PAnsiChar(TpvUTF8String(DumpExceptionCallStack(e))));
   end;
  end;
 finally
{$if (defined(fpc) and defined(android)) and not defined(Release)}
  __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Leaving Android_ANativeActivity_onNativeWindowDestroyed . . .');
{$ifend}
 end;
end;

procedure Android_ANativeActivity_onInputQueueCreated(aActivity:PANativeActivity;aQueue:PAInputQueue); cdecl;
begin
{$if (defined(fpc) and defined(android)) and not defined(Release)}
 __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Entering Android_ANativeActivity_onInputQueueCreated . .');
{$ifend}
 try
  try
   PAndroidApp(aActivity^.instance)^.SetInput(aQueue);
  except
   on e:Exception do begin
    __android_log_write(ANDROID_LOG_FATAL,'PasVulkanApplication',PAnsiChar(TpvUTF8String(DumpExceptionCallStack(e))));
   end;
  end;
 finally
{$if (defined(fpc) and defined(android)) and not defined(Release)}
  __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Leaving Android_ANativeActivity_onInputQueueCreated . . .');
{$ifend}
 end;
end;

procedure Android_ANativeActivity_onInputQueueDestroyed(aActivity:PANativeActivity;aQueue:PAInputQueue); cdecl;
begin
{$if (defined(fpc) and defined(android)) and not defined(Release)}
 __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Entering Android_ANativeActivity_onInputQueueDestroyed . .');
{$ifend}
 try
  try
   PAndroidApp(aActivity^.instance)^.SetInput(nil);
  except
   on e:Exception do begin
    __android_log_write(ANDROID_LOG_FATAL,'PasVulkanApplication',PAnsiChar(TpvUTF8String(DumpExceptionCallStack(e))));
   end;
  end;
 finally
{$if (defined(fpc) and defined(android)) and not defined(Release)}
  __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Leaving Android_ANativeActivity_onInputQueueDestroyed . . .');
{$ifend}
 end;
end;

procedure Android_ANativeActivity_onContentRectChanged(aActivity:PANativeActivity;aRect:PARect); cdecl;
begin
{$if (defined(fpc) and defined(android)) and not defined(Release)}
 __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Entering Android_ANativeActivity_onContentRectChanged . .');
{$ifend}
 try
  try
   PAndroidApp(aActivity^.instance)^.SendCmd(APP_CMD_CONTENT_RECT_CHANGED);
  except
   on e:Exception do begin
    __android_log_write(ANDROID_LOG_FATAL,'PasVulkanApplication',PAnsiChar(TpvUTF8String(DumpExceptionCallStack(e))));
   end;
  end;
 finally
{$if (defined(fpc) and defined(android)) and not defined(Release)}
  __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Leaving Android_ANativeActivity_onContentRectChanged . . .');
{$ifend}
 end;
end;

procedure Android_ANativeActivity_onConfigurationChanged(aActivity:PANativeActivity); cdecl;
begin
{$if (defined(fpc) and defined(android)) and not defined(Release)}
 __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Entering Android_ANativeActivity_onConfigurationChanged . .');
{$ifend}
 try
  try
   PAndroidApp(aActivity^.instance)^.SendCmd(APP_CMD_CONFIG_CHANGED);
  except
   on e:Exception do begin
    __android_log_write(ANDROID_LOG_FATAL,'PasVulkanApplication',PAnsiChar(TpvUTF8String(DumpExceptionCallStack(e))));
   end;
  end;
 finally
{$if (defined(fpc) and defined(android)) and not defined(Release)}
  __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Leaving Android_ANativeActivity_onConfigurationChanged . . .');
{$ifend}
 end;
end;

procedure Android_ANativeActivity_onLowMemory(aActivity:PANativeActivity); cdecl;
begin
{$if (defined(fpc) and defined(android)) and not defined(Release)}
 __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Entering Android_ANativeActivity_onLowMemory . .');
{$ifend}
 try
  try
   PAndroidApp(aActivity^.instance)^.SendCmd(APP_CMD_LOW_MEMORY);
  except
   on e:Exception do begin
    __android_log_write(ANDROID_LOG_FATAL,'PasVulkanApplication',PAnsiChar(TpvUTF8String(DumpExceptionCallStack(e))));
   end;
  end;
 finally
{$if (defined(fpc) and defined(android)) and not defined(Release)}
  __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Leaving Android_ANativeActivity_onLowMemory . . .');
{$ifend}
 end;
end;

procedure Android_ANativeActivity_onCreate(aActivity:PANativeActivity;aSavedState:pointer;aSavedStateSize:cuint32;const aApplicationClass:TpvApplicationClass);
begin
{$if (defined(fpc) and defined(android)) and not defined(Release)}
 __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Entering Android_ANativeActivity_onCreate . . .');
{$ifend}
 try

  try

   AndroidActivity:=aActivity;

   AndroidSavedState:=aSavedState;
   AndroidSavedStateSize:=aSavedStateSize;

   AndroidJavaVM:=aActivity^.VM;
   AndroidJavaEnv:=aActivity^.env;
   AndroidJavaObject:=aActivity^.clazz;

   AndroidAssetManager:=aActivity^.assetManager;

   AndroidInternalDataPath:=TpvUTF8String(aActivity^.internalDataPath);
   AndroidExternalDataPath:=TpvUTF8String(aActivity^.externalDataPath);
   AndroidLibraryPath:=TpvUTF8String(IncludeTrailingPathDelimiter(ExtractFilePath(aActivity^.internalDataPath))+'lib');

   aActivity^.callbacks^.onStart:=@Android_ANativeActivity_onStart;
   aActivity^.callbacks^.onResume:=@Android_ANativeActivity_onResume;
   aActivity^.callbacks^.onSaveInstanceState:=@Android_ANativeActivity_onSaveInstanceState;
   aActivity^.callbacks^.onStop:=@Android_ANativeActivity_onStop;
   aActivity^.callbacks^.onPause:=@Android_ANativeActivity_onPause;
   aActivity^.callbacks^.onDestroy:=@Android_ANativeActivity_onDestroy;
   aActivity^.callbacks^.onWindowFocusChanged:=@Android_ANativeActivity_onWindowFocusChanged;
   aActivity^.callbacks^.onNativeWindowCreated:=@Android_ANativeActivity_onNativeWindowCreated;
   aActivity^.callbacks^.onNativeWindowResized:=@Android_ANativeActivity_onNativeWindowResized;
   aActivity^.callbacks^.onNativeWindowRedrawNeeded:=@Android_ANativeActivity_onNativeWindowRedrawNeeded;
   aActivity^.callbacks^.onNativeWindowDestroyed:=@Android_ANativeActivity_onNativeWindowDestroyed;
   aActivity^.callbacks^.onInputQueueCreated:=@Android_ANativeActivity_onInputQueueCreated;
   aActivity^.callbacks^.onInputQueueDestroyed:=@Android_ANativeActivity_onInputQueueDestroyed;
   aActivity^.callbacks^.onContentRectChanged:=@Android_ANativeActivity_onContentRectChanged;
   aActivity^.callbacks^.onConfigurationChanged:=@Android_ANativeActivity_onConfigurationChanged;
   aActivity^.callbacks^.onLowMemory:=@Android_ANativeActivity_onLowMemory;

   aActivity^.instance:=LibCMalloc(SizeOf(TAndroidApp));

   PAndroidApp(aActivity^.instance)^:=TAndroidApp.Create(aActivity,aApplicationClass,aSavedState,aSavedStateSize);

  except
   on e:Exception do begin
    __android_log_write(ANDROID_LOG_FATAL,'PasVulkanApplication',PAnsiChar(TpvUTF8String(DumpExceptionCallStack(e))));
   end;
  end;
 finally
{$if (defined(fpc) and defined(android)) and not defined(Release)}
  __android_log_write(ANDROID_LOG_VERBOSE,'PasVulkanApplication','Leaving Android_ANativeActivity_onCreate . . .');
{$ifend}
 end;
end;
{$ifend}

{$ifend}

{$if defined(PasVulkanUseJCLDebug) and not defined(fpc)}
function GetExceptionStackInfoProc(P:PExceptionRecord):Pointer;
var LLines:TStringList;
    LText:String;
    LResult:PChar;
//  StackInfoList:TJclStackInfoList;
begin
 LLines:=TStringList.Create;
 try
{ StackInfoList:=TJclStackInfoList.Create(true,7,p.ExceptAddr,false,nil,nil);
  try
   StackInfoList.AddToStrings(LLines,true,true,true,true);
  finally
   FreeAndNil(StackInfoList);
  end;}
  JclLastExceptStackListToStrings(LLines,true,true,true,true);
  LText:=LLines.Text;
  LResult:=StrAlloc(Length(LText));
  StrCopy(LResult,PChar(LText));
  Result:=LResult;
 finally
  LLines.Free;
 end;
end;

function GetStackInfoStringProc(Info:Pointer):string;
begin
 Result:=string(PChar(Info));
end;

procedure CleanUpStackInfoProc(Info:Pointer);
begin
 StrDispose(PChar(Info));
end;
{$ifend}

type TExceptionOccurred=procedure(aSender:TObject;aAddr:Pointer{$ifdef fpc};aFrameCount:Longint;aFrames:PPointer{$endif});

var OldExceptProc:Pointer=nil;
    HandlingException:Boolean=false;

procedure ExceptionOccurred(aSender:TObject;aAddr:Pointer{$ifdef fpc};aFrameCount:Longint;aFrames:PPointer{$endif});
const LineEnding={$ifdef Unix}#10{$else}#13#10{$endif};
var ExceptionString:string;
begin

 if HandlingException then begin
  exit;
 end;

 HandlingException:=true;

 if assigned(aSender) and (aSender is Exception) then begin
  ExceptionString:=DumpExceptionCallStack(Exception(aSender){$ifdef fpc},aAddr,aFrameCount,aFrames{$endif});
 end else begin
{$ifdef fpc}
  ExceptionString:=DumpExceptionCallStack(Exception(nil){$ifdef fpc},aAddr,aFrameCount,aFrames{$endif});
{$else}
  ExceptionString:='Program exception at $'+IntToHex(TpvPtrUInt(aAddr),SizeOf(Pointer) shl 1)+LineEnding;
{$endif}
 end;

{$if defined(fpc) and defined(android) and (defined(Release) or not defined(Debug))}
 __android_log_write(ANDROID_LOG_ERROR,'PasVulkanApplication',PAnsiChar(TpvApplicationRawByteString(ExceptionString)));
{$ifend}
 TpvApplication.Log(LOG_ERROR,'TpvApplication',ExceptionString);

 LogCrash(ExceptionString);

 if assigned(OldExceptProc) then begin
  TExceptionOccurred(OldExceptProc)(aSender,aAddr{$ifdef fpc},aFrameCount,aFrames{$endif});
 end;

 HandlingException:=false;

end;

procedure InitializeOutputLogLevel;
var Index,Count:TpvSizeInt;
    Value:TpvInt32;
    Parameter:string;
begin

 // Set default log level
 if pvDebuggerPresent then begin
  pvOutputLogLevel:=LOG_DEBUG; // If a debugger is present, set log level to debug (errors, info, verbose and debug)
 end else begin
  pvOutputLogLevel:=LOG_INFO; // If no debugger is present, set log level to info (errors and info)
 end;

 // Parse command line parameters
 Index:=1;
 Count:=ParamCount;
 while Index<=Count do begin
  Parameter:=LowerCase(ParamStr(Index));
  inc(Index);
  if (length(Parameter)>0) and ((Parameter[1]='-') or (Parameter[1]='/')) then begin
   Delete(Parameter,1,1);
   if (length(Parameter)>0) and ((Parameter[1]='-') or (Parameter[1]='/')) then begin
    Delete(Parameter,1,1);
   end;
   if Parameter='loglevel' then begin
    if Index<=Count then begin
     Parameter:=LowerCase(ParamStr(Index));
     inc(Index);
     if Parameter='none' then begin
      pvOutputLogLevel:=LOG_NONE;
     end else if Parameter='error' then begin
      pvOutputLogLevel:=LOG_ERROR;
     end else if Parameter='info' then begin
      pvOutputLogLevel:=LOG_INFO;
     end else if Parameter='verbose' then begin
      pvOutputLogLevel:=LOG_VERBOSE;
     end else if Parameter='debug' then begin
      pvOutputLogLevel:=LOG_DEBUG;
     end else if TryStrToInt(Parameter,Value) then begin
      pvOutputLogLevel:=Value;
     end;
     break;
    end;
   end;
  end;
 end;

end;

initialization

 VulkanDisableFloatingPointExceptions;

 // Check if a debugger is present
 pvDebuggerPresent:=IsDebuggerPresent;

 // Initialize log level
 pvOutputLogLevel:=LOG_DEBUG;
 InitializeOutputLogLevel;

{$if defined(Windows) and (defined(Debug) or not defined(Release))}

 pvStdOut:=GetStdHandle(Std_Output_Handle);

  // Check if a console is existing
 if (pvStdOut=0) or (pvStdOut=Invalid_Handle_Value) then begin
  // If no console is existing and the log level is not none, create a new console
  if (pvOutputLogLevel>LOG_NONE) and not AttachConsole(ATTACH_PARENT_PROCESS) then begin
   AllocConsole;
  end;
 end;

 // If a console is existing, set the console output codepage to UTF-8 (65001) and check if it is UTF-8 afterwards for further use with a bit slower UTF-16 fallback
 if (pvStdOut<>0) and (pvStdOut<>Invalid_Handle_Value) then begin
  SetConsoleOutputCP(65001); // Set console output codepage to UTF-8 (CP_UTF8 / 65001)
  pvIsStdOutUTF8:=GetConsoleOutputCP=65001; // Check if console output codepage is UTF-8 (CP_UTF8 / 65001)
 end;

{$ifend}

{$if defined(PasVulkanUseJCLDebug) and not defined(fpc)}
 // Initialize JCL debug
//JclStackTrackingOptions:=JclStackTrackingOptions+[stRawMode,stStaticModuleList];
 if JclStartExceptionTracking then begin
{ Exception.GetExceptionStackInfoProc:=GetExceptionStackInfoProc;
  Exception.GetStackInfoStringProc:=GetStackInfoStringProc;
  Exception.CleanUpStackInfoProc:=CleanUpStackInfoProc;}
 end;
{$ifend}

 // Set exception handler and save old exception handler
 OldExceptProc:=Addr(System.ExceptProc);
 System.ExceptProc:=@ExceptionOccurred;

{$ifdef Windows}
{$ifndef PasVulkanUseSDL2}

 // Set timer resolution to 1ms
 timeBeginPeriod(1);

 // Get touchscreen API functions
 @GetPointerType:=GetProcAddress(LoadLibrary('user32.dll'),'GetPointerType');
 @GetPointerTouchInfo:=GetProcAddress(LoadLibrary('user32.dll'),'GetPointerTouchInfo');
 @GetPointerPenInfo:=GetProcAddress(LoadLibrary('user32.dll'),'GetPointerPenInfo');
 @EnableMouseInPointer:=GetProcAddress(LoadLibrary('user32.dll'),'EnableMouseInPointer');
 Win32HasGetPointer:=assigned(GetPointerType) and
                     assigned(GetPointerTouchInfo) and
                     assigned(GetPointerPenInfo) and
                     assigned(EnableMouseInPointer);

 // Get windows version API functions
 @RtlGetNtVersionNumbers:=GetProcAddress(LoadLibrary('ntdll.dll'),'RtlGetNtVersionNumbers');
 if assigned(RtlGetNtVersionNumbers) then begin
  RtlGetNtVersionNumbers(WindowsVersionMajor,WindowsVersionMinor,WindowsVersionBuildNumber);
 end;

 // Get DPI awareness API functions
 @SetProcessDPIAware:=GetProcAddress(LoadLibrary('user32.dll'),'SetProcessDPIAware');
 @SetProcessDpiAwareness:=GetProcAddress(LoadLibrary('shcore.dll'),'SetProcessDpiAwareness');
 @SetProcessDpiAwarenessContext:=GetProcAddress(LoadLibrary('user32.dll'),'SetProcessDpiAwarenessContext');
 @EnableNonClientDpiScaling:=GetProcAddress(LoadLibrary('user32.dll'),'EnableNonClientDpiScaling');

{$endif}
{$endif}

finalization

{$ifdef Windows}
 // Reset timer resolution
 timeEndPeriod(1);
{$endif}

 // Reset exception handler to old exception handler
 System.ExceptProc:=OldExceptProc;

{$if defined(PasVulkanUseJCLDebug) and not defined(fpc)}
 // Finalize JCL debug
 if JclExceptionTrackingActive then begin
  Exception.GetExceptionStackInfoProc:=nil;
  Exception.GetStackInfoStringProc:=nil;
  Exception.CleanUpStackInfoProc:=nil;
  JclStopExceptionTracking;
 end;
{$ifend}

end.
