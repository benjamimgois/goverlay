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
unit PasVulkan.PasRISCVEmulator;
{$i PasVulkan.inc}
{$ifndef fpc}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=24.0}
   {$legacyifend on}
  {$ifend}
 {$endif}
{$endif}
{$m+}
(*{$ifdef fpc}
 {$mode delphi}
 {$ifdef cpu386}
  {$asmmode intel}
 {$endif}
 {$ifdef cpuamd64}
  {$asmmode intel}
 {$endif}
{$else}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=24.0}
   {$legacyifend on}
  {$ifend}
 {$endif}
{$endif}
{$if defined(Win32) or defined(Win64)}
 {$define Windows}
{$ifend}*)

{$rangechecks off}
{$overflowchecks off}

{$if defined(fpc)}
 {$optimization level1}
{$ifend}

interface

uses SysUtils,
     Classes,
     Math,
     Vulkan,
     PUCU,
     PasMP,
     {$ifdef unix}
     pthreads,
     {$endif}
     PasVulkan.Types,
     PasVulkan.Collections,
     PasVulkan.Math,
     PasVulkan.Framework,
     PasVulkan.Application,
     PasVulkan.Sprites,
     PasVulkan.Canvas,
     PasVulkan.Font,
     PasVulkan.TrueTypeFont,
     PasVulkan.HighResolutionTimer,
     PasRISCV,
     PasTerm,
     VGAFont;

type { TpvPasRISCVEmulatorMachineInstance }
     TpvPasRISCVEmulatorMachineInstance=class(TPasMPThread)
      public
       const KERNEL_OFFSET=$200000;
             FontWidth=8;
             FontHeight=16;
             ScreenWidth=640;
             ScreenHeight=400;
             MaxScreenWidth=2048;
             MaxScreenHeight=2048;
       type TFrameBuffer=array[0..(MaxScreenWidth*MaxScreenHeight)-1] of TpvUInt32;
            TFrameBufferItem=record
             Width:TpvInt32;
             Height:TpvInt32;
             Active:Boolean;
             Data:TFrameBuffer;
            end;
            PFrameBufferItem=^TFrameBufferItem;
            TFrameBufferItems=array[0..3] of TFrameBufferItem;
            TIntegers=array of TpvInt32;
            TVSockTestProtocol=class(TPasRISCV.TVirtIOVSockDevice.TVSockManager.TConnection)
             public
              type TMessageHeader=packed record
                    Magic:TPasRISCVUInt32;
                    MsgType:TPasRISCVUInt32;
                    Length:TPasRISCVUInt32;
                   end;
              const MESSAGE_MAGIC=TPasRISCVUInt32($52564d54); // 'RVMT'
                    MSG_PING=0;
                    MSG_PONG=1;
                    MSG_ECHO_REQ=2;
                    MSG_ECHO_RESP=3;
                    MSG_INFO_REQ=4;
                    MSG_INFO_RESP=5;
                    MSG_DONE=6;
             private
              fReceiveBuffer:TPasMPSingleProducerSingleConsumerRingBuffer;
              fPendingHeader:TMessageHeader;
              fHasPendingHeader:Boolean;
             protected
              procedure OnConnect; override;
              procedure OnReceive(const aData:Pointer;const aSize:TPasRISCVUInt32;const aFlags:TPasRISCVUInt32); override;
              procedure OnDisconnect; override;
             public
              constructor Create(const aManager:TPasRISCV.TVirtIOVSockDevice.TVSockManager;const aTag:Pointer;const aLocalPort,aRemotePort:TPasRISCVUInt32;const aRemoteCID:TPasRISCVUInt64;const aSocketType:TPasRISCVUInt16); override;
              destructor Destroy; override;
              procedure SendMessage(const aMsgType:TPasRISCVUInt32;const aData:Pointer;const aSize:TPasRISCVUInt32);
              procedure ProcessMessage(const aMsgType:TPasRISCVUInt32;const aData:Pointer;const aSize:TPasRISCVUInt32);
              procedure ProcessMessages;
            end;
            TVSockTestProtocolList=TpvObjectGenericList<TVSockTestProtocol>;
      private
       f9PFileSystem:TPasRISCV9PFileSystem;
       fFUSEFileSystem:TPasRISCVFUSEFileSystem;
//     fEthernetDevice:TPasRISCVEthernetDevice;
       fNextFrameTime:TpvHighResolutionTime;
       fFrameBufferItems:TFrameBufferItems;
       fFrameBufferReadIndex:TpvInt32;
       fFrameBufferWriteIndex:TpvInt32;
       fXCacheIntegers:TIntegers;
       fVSockManager:TPasRISCV.TVirtIOVSockDevice.TVSockManager;
       fActiveTestConnections:TVSockTestProtocolList;
       fActiveTestConnectionsLock:TPasMPCriticalSection;
      protected
       fMachineConfiguration:TPasRISCV.TConfiguration;
       fMachine:TPasRISCV;
       fVirtIOGPUVirGL:Boolean;
       procedure ConfigureMachine; virtual; abstract;
       function GetBIOSFileName:TpvRawByteString; virtual; abstract;
       function GetKernelFileName:TpvRawByteString; virtual; abstract;
       function GetINITRDFileName:TpvRawByteString; virtual; abstract;
       function GetVirtIOBlockImageFileName:TpvRawByteString; virtual; abstract;
       function GetNVMeImageFileName:TpvRawByteString; virtual; abstract;
{$ifdef PasRISCVVirtIOGPUVulkanVenus}
       procedure OnScanoutUpdate(const aScanoutID:TPasRISCVUInt32;const aPixels:Pointer;const aWidth,aHeight,aStride,aFormat:TPasRISCVUInt32);
{$endif}
       procedure AfterMachineCreate; virtual;
       procedure PreBoot; virtual;
       procedure ResetFrameBuffer;
       procedure Execute; override;
      public
       constructor Create; virtual;
       destructor Destroy; override;
       procedure Shutdown; virtual;
       procedure Boot; virtual;
       procedure OnReboot;
       procedure OnNewFrame;
       function TransferFrame(const aFrameBuffer:Pointer;out aActive:Boolean):boolean;
       property Machine:TPasRISCV read fMachine;
       property MachineConfiguration:TPasRISCV.TConfiguration read fMachineConfiguration;
       property VirtIOGPUVirGL:Boolean read fVirtIOGPUVirGL write fVirtIOGPUVirGL;
       property NextFrameTime:TpvHighResolutionTime read fNextFrameTime write fNextFrameTime;
       property VSockManager:TPasRISCV.TVirtIOVSockDevice.TVSockManager read fVSockManager;
       property ActiveTestConnections:TVSockTestProtocolList read fActiveTestConnections;
       property ActiveTestConnectionsLock:TPasMPCriticalSection read fActiveTestConnectionsLock;
     end;

     { TpvPasRISCVEmulatorRenderer }
     TpvPasRISCVEmulatorRenderer=class
      public
       type TFlag=
             (
              Centered,
              CenterToNearestPixel,
              Scaled,
              ScaleToNearest
             );
            PFlag=^TFlag;
            TFlags=set of TFlag;
      private
       fGraphicsFrameBuffer:TpvPasRISCVEmulatorMachineInstance.TFrameBuffer;
       fSerialConsoleTerminalFrameBuffer:TpvPasRISCVEmulatorMachineInstance.TFrameBuffer;
       fFrameBuffers:array[0..MaxInFlightFrames-1] of TpvPasRISCVEmulatorMachineInstance.TFrameBuffer;
       fFrameBufferTextureBuffers:array[0..MaxInFlightFrames-1] of TpvVulkanBuffer;
       fFrameBufferTextures:array[0..MaxInFlightFrames-1] of TpvVulkanTexture;
       fFrameBufferGeneration:TpvUInt64;
       fFrameBufferGenerations:array[0..MaxInFlightFrames-1] of TpvUInt64;
       fFrameBufferTextureGenerations:array[0..MaxInFlightFrames-1] of TpvUInt64;
       fFrameBufferTextureSampler:TpvVulkanSampler;
       fVulkanDevice:TpvVulkanDevice;
       fVulkanGraphicsCommandPool:TpvVulkanCommandPool;
       fVulkanGraphicsCommandBuffer:TpvVulkanCommandBuffer;
       fVulkanGraphicsCommandBufferFence:TpvVulkanFence;
       fVulkanTransferCommandPool:TpvVulkanCommandPool;
       fVulkanTransferCommandBuffer:TpvVulkanCommandBuffer;
       fVulkanTransferCommandBufferFence:TpvVulkanFence;
       fVulkanCanvas:TpvCanvas;
       fReady:TPasMPBool32;
       fLastSerialConsoleMode:Boolean;
       fSerialConsoleMode:Boolean;
       fMouseButtons:TpvUInt32;
       fLastGamepadValid:boolean;
       fLastGamepadButtons:TpvUInt32;
       fLastGamepadAxes:array[0..7] of TpvInt32;
       fSelectedIndex:TpvInt32;
       fStartY:TpvFloat;
       fTime:TpvDouble;
       fTerm:TPasTerm;
       fTerminalFrameBufferSnapshot:TPasTerm.TFrameBufferSnapshot;
       fMachineInstance:TpvPasRISCVEmulatorMachineInstance;
       fUARTOutputBuffer:array[0..65535] of AnsiChar;
       fContentGeneration:TpvUInt64;
       fRenderGeneration:array[0..MaxInFlightFrames-1] of TpvUInt64;
       fTextureGeneration:TpvUInt64;
       fFlags:TFlags;
       procedure DrawBackground(const aSender:TPasTerm);
       procedure DrawCodePoint(const aSender:TPasTerm;const aCodePoint:TPasTerm.TFrameBufferCodePoint;const aColumn,aRow:TPasTermSizeInt);
       procedure DrawCursor(const aSender:TPasTerm;const aColumn,aRow:TPasTermSizeInt);
      public
       constructor Create;
       destructor Destroy; override;
       procedure CreateVulkanResources(const aDevice:TpvVulkanDevice);
       procedure DestroyVulkanResources;
       procedure SetMachineInstance(const aMachineInstance:TpvPasRISCVEmulatorMachineInstance);
       procedure ShutdownMachineInstance;
       function HandleKeyEvent(const aKeyEvent:TpvApplicationInputKeyEvent):boolean;
       function HandlePointerEvent(const aPointerEvent:TpvApplicationInputPointerEvent):boolean;
       function HandleScrolled(const aRelativeAmount:TpvVector2):boolean;
       procedure UpdateGameControllers;
       procedure UpdateEmulatorState;
       procedure RecordFrameBufferUpload(const aCommandBuffer:TpvVulkanCommandBuffer;const aInFlightFrameIndex:TpvSizeInt);
       procedure RenderToCanvas(const aInFlightFrameIndex:TpvSizeInt;const aCanvasWidth,aCanvasHeight:TpvFloat);
       property GraphicsFrameBuffer:TpvPasRISCVEmulatorMachineInstance.TFrameBuffer read fGraphicsFrameBuffer;
       property SerialConsoleTerminalFrameBuffer:TpvPasRISCVEmulatorMachineInstance.TFrameBuffer read fSerialConsoleTerminalFrameBuffer;
       property VulkanDevice:TpvVulkanDevice read fVulkanDevice;
       property VulkanGraphicsCommandPool:TpvVulkanCommandPool read fVulkanGraphicsCommandPool;
       property VulkanGraphicsCommandBuffer:TpvVulkanCommandBuffer read fVulkanGraphicsCommandBuffer;
       property VulkanGraphicsCommandBufferFence:TpvVulkanFence read fVulkanGraphicsCommandBufferFence;
       property VulkanTransferCommandPool:TpvVulkanCommandPool read fVulkanTransferCommandPool;
       property VulkanTransferCommandBuffer:TpvVulkanCommandBuffer read fVulkanTransferCommandBuffer;
       property VulkanTransferCommandBufferFence:TpvVulkanFence read fVulkanTransferCommandBufferFence;
       property VulkanCanvas:TpvCanvas read fVulkanCanvas;
       property FrameBufferTextureSampler:TpvVulkanSampler read fFrameBufferTextureSampler;
       property MachineInstance:TpvPasRISCVEmulatorMachineInstance read fMachineInstance;
       property Ready:TPasMPBool32 read fReady write fReady;
       property SerialConsoleMode:Boolean read fSerialConsoleMode write fSerialConsoleMode;
       property FrameBufferGeneration:TpvUInt64 read fFrameBufferGeneration;
       property ContentGeneration:TpvUInt64 read fContentGeneration;
       property Term:TPasTerm read fTerm;
       property TerminalFrameBufferSnapshot:TPasTerm.TFrameBufferSnapshot read fTerminalFrameBufferSnapshot;
       property Time:TpvDouble read fTime write fTime;
       function GetFrameBufferTexture(const aIndex:TpvSizeInt):TpvVulkanTexture;
       function GetFrameBufferTextureBuffer(const aIndex:TpvSizeInt):TpvVulkanBuffer;
       function GetFrameBufferGenerationValue(const aIndex:TpvSizeInt):TpvUInt64;
       function GetFrameBufferTextureGeneration(const aIndex:TpvSizeInt):TpvUInt64;
       function GetRenderGeneration(const aIndex:TpvSizeInt):TpvUInt64;
       procedure SetRenderGeneration(const aIndex:TpvSizeInt;const aValue:TpvUInt64);
      published
       property TextureGeneration:TpvUInt64 read fTextureGeneration write fTextureGeneration;
       property Flags:TFlags read fFlags write fFlags;
     end;

function MapKeyCodeToHIDKeyCode(const aKeyCode:TpvUInt32):TpvUInt32;
function MapKeyCodeToEVDEVKeyCode(const aKeyCode:TpvUInt32):TpvUInt32;
procedure ResizeRGB32(Src:pointer;SrcWidth,SrcHeight:TpvInt32;Dst:pointer;DstWidth,DstHeight:TpvInt32;var XCache:TpvPasRISCVEmulatorMachineInstance.TIntegers);
function ConvertColor(const c:TPasTermUInt32):TpvVector4;

implementation

function MapKeyCodeToHIDKeyCode(const aKeyCode:TpvUInt32):TpvUInt32;
begin
 case aKeyCode of
  KEYCODE_A:begin
   result:=TPasRISCV.THID.KEY_A;
  end;
  KEYCODE_B:begin
   result:=TPasRISCV.THID.KEY_B;
  end;
  KEYCODE_C:begin
   result:=TPasRISCV.THID.KEY_C;
  end;
  KEYCODE_D:begin
   result:=TPasRISCV.THID.KEY_D;
  end;
  KEYCODE_E:begin
   result:=TPasRISCV.THID.KEY_E;
  end;
  KEYCODE_F:begin
   result:=TPasRISCV.THID.KEY_F;
  end;
  KEYCODE_G:begin
   result:=TPasRISCV.THID.KEY_G;
  end;
  KEYCODE_H:begin
   result:=TPasRISCV.THID.KEY_H;
  end;
  KEYCODE_I:begin
   result:=TPasRISCV.THID.KEY_I;
  end;
  KEYCODE_J:begin
   result:=TPasRISCV.THID.KEY_J;
  end;
  KEYCODE_K:begin
   result:=TPasRISCV.THID.KEY_K;
  end;
  KEYCODE_L:begin
   result:=TPasRISCV.THID.KEY_L;
  end;
  KEYCODE_M:begin
   result:=TPasRISCV.THID.KEY_M;
  end;
  KEYCODE_N:begin
   result:=TPasRISCV.THID.KEY_N;
  end;
  KEYCODE_O:begin
   result:=TPasRISCV.THID.KEY_O;
  end;
  KEYCODE_P:begin
   result:=TPasRISCV.THID.KEY_P;
  end;
  KEYCODE_Q:begin
   result:=TPasRISCV.THID.KEY_Q;
  end;
  KEYCODE_R:begin
   result:=TPasRISCV.THID.KEY_R;
  end;
  KEYCODE_S:begin
   result:=TPasRISCV.THID.KEY_S;
  end;
  KEYCODE_T:begin
   result:=TPasRISCV.THID.KEY_T;
  end;
  KEYCODE_U:begin
   result:=TPasRISCV.THID.KEY_U;
  end;
  KEYCODE_V:begin
   result:=TPasRISCV.THID.KEY_V;
  end;
  KEYCODE_W:begin
   result:=TPasRISCV.THID.KEY_W;
  end;
  KEYCODE_X:begin
   result:=TPasRISCV.THID.KEY_X;
  end;
  KEYCODE_Y:begin
   result:=TPasRISCV.THID.KEY_Y;
  end;
  KEYCODE_Z:begin
   result:=TPasRISCV.THID.KEY_Z;
  end;
  KEYCODE_1:begin
   result:=TPasRISCV.THID.KEY_1;
  end;
  KEYCODE_2:begin
   result:=TPasRISCV.THID.KEY_2;
  end;
  KEYCODE_3:begin
   result:=TPasRISCV.THID.KEY_3;
  end;
  KEYCODE_4:begin
   result:=TPasRISCV.THID.KEY_4;
  end;
  KEYCODE_5:begin
   result:=TPasRISCV.THID.KEY_5;
  end;
  KEYCODE_6:begin
   result:=TPasRISCV.THID.KEY_6;
  end;
  KEYCODE_7:begin
   result:=TPasRISCV.THID.KEY_7;
  end;
  KEYCODE_8:begin
   result:=TPasRISCV.THID.KEY_8;
  end;
  KEYCODE_9:begin
   result:=TPasRISCV.THID.KEY_9;
  end;
  KEYCODE_0:begin
   result:=TPasRISCV.THID.KEY_0;
  end;
  KEYCODE_RETURN:begin
   result:=TPasRISCV.THID.KEY_RETURN;
  end;
  KEYCODE_ESCAPE:begin
   result:=TPasRISCV.THID.KEY_ESCAPE;
  end;
  KEYCODE_BACKSPACE:begin
   result:=TPasRISCV.THID.KEY_BACKSPACE;
  end;
  KEYCODE_TAB:begin
   result:=TPasRISCV.THID.KEY_TAB;
  end;
  KEYCODE_SPACE:begin
   result:=TPasRISCV.THID.KEY_SPACE;
  end;
  KEYCODE_MINUS:begin
   result:=TPasRISCV.THID.KEY_MINUS;
  end;
  KEYCODE_EQUALS:begin
   result:=TPasRISCV.THID.KEY_EQUAL;
  end;
  KEYCODE_LEFTBRACE:begin
   result:=TPasRISCV.THID.KEY_LEFTBRACE;
  end;
  KEYCODE_RIGHTBRACE:begin
   result:=TPasRISCV.THID.KEY_RIGHTBRACE;
  end;
  KEYCODE_BACKSLASH:begin
   result:=TPasRISCV.THID.KEY_BACKSLASH;
  end;
  KEYCODE_TILDE:begin
   result:=TPasRISCV.THID.KEY_HASHTILDE;
  end;
  KEYCODE_SEMICOLON:begin
   result:=TPasRISCV.THID.KEY_SEMICOLON;
  end;
  KEYCODE_APOSTROPHE:begin
   result:=TPasRISCV.THID.KEY_APOSTROPHE;
  end;
  KEYCODE_GRAVE:begin
   result:=TPasRISCV.THID.KEY_GRAVE;
  end;
  KEYCODE_COMMA:begin
   result:=TPasRISCV.THID.KEY_COMMA;
  end;
  KEYCODE_PERIOD:begin
   result:=TPasRISCV.THID.KEY_DOT;
  end;
  KEYCODE_SLASH:begin
   result:=TPasRISCV.THID.KEY_SLASH;
  end;
  KEYCODE_CAPSLOCK:begin
   result:=TPasRISCV.THID.KEY_CAPSLOCK;
  end;
  KEYCODE_F1:begin
   result:=TPasRISCV.THID.KEY_F1;
  end;
  KEYCODE_F2:begin
   result:=TPasRISCV.THID.KEY_F2;
  end;
  KEYCODE_F3:begin
   result:=TPasRISCV.THID.KEY_F3;
  end;
  KEYCODE_F4:begin
   result:=TPasRISCV.THID.KEY_F4;
  end;
  KEYCODE_F5:begin
   result:=TPasRISCV.THID.KEY_F5;
  end;
  KEYCODE_F6:begin
   result:=TPasRISCV.THID.KEY_F6;
  end;
  KEYCODE_F7:begin
   result:=TPasRISCV.THID.KEY_F7;
  end;
  KEYCODE_F8:begin
   result:=TPasRISCV.THID.KEY_F8;
  end;
  KEYCODE_F9:begin
   result:=TPasRISCV.THID.KEY_F9;
  end;
  KEYCODE_F10:begin
   result:=TPasRISCV.THID.KEY_F10;
  end;
  KEYCODE_F11:begin
   result:=TPasRISCV.THID.KEY_F11;
  end;
  KEYCODE_F12:begin
   result:=TPasRISCV.THID.KEY_F12;
  end;
  KEYCODE_SYSREQ:begin
   result:=TPasRISCV.THID.KEY_SYSRQ;
  end;
  KEYCODE_SCROLLLOCK:begin
   result:=TPasRISCV.THID.KEY_SCROLLLOCK;
  end;
  KEYCODE_PAUSE:begin
   result:=TPasRISCV.THID.KEY_PAUSE;
  end;
  KEYCODE_INSERT:begin
   result:=TPasRISCV.THID.KEY_INSERT;
  end;
  KEYCODE_HOME:begin
   result:=TPasRISCV.THID.KEY_HOME;
  end;
  KEYCODE_PAGEUP:begin
   result:=TPasRISCV.THID.KEY_PAGEUP;
  end;
  KEYCODE_DELETE:begin
   result:=TPasRISCV.THID.KEY_DELETE;
  end;
  KEYCODE_END:begin
   result:=TPasRISCV.THID.KEY_END;
  end;
  KEYCODE_PAGEDOWN:begin
   result:=TPasRISCV.THID.KEY_PAGEDOWN;
  end;
  KEYCODE_RIGHT:begin
   result:=TPasRISCV.THID.KEY_RIGHT;
  end;
  KEYCODE_LEFT:begin
   result:=TPasRISCV.THID.KEY_LEFT;
  end;
  KEYCODE_DOWN:begin
   result:=TPasRISCV.THID.KEY_DOWN;
  end;
  KEYCODE_UP:begin
   result:=TPasRISCV.THID.KEY_UP;
  end;
  KEYCODE_NUMLOCK:begin
   result:=TPasRISCV.THID.KEY_NUMLOCK;
  end;
  KEYCODE_KP_DIVIDE:begin
   result:=TPasRISCV.THID.KEY_KPSLASH;
  end;
  KEYCODE_KP_MULTIPLY:begin
   result:=TPasRISCV.THID.KEY_KPASTERISK;
  end;
  KEYCODE_KP_MINUS:begin
   result:=TPasRISCV.THID.KEY_KPMINUS;
  end;
  KEYCODE_KP_PLUS:begin
   result:=TPasRISCV.THID.KEY_KPPLUS;
  end;
  KEYCODE_KP_ENTER:begin
   result:=TPasRISCV.THID.KEY_KPENTER;
  end;
  KEYCODE_KP1:begin
   result:=TPasRISCV.THID.KEY_KP1;
  end;
  KEYCODE_KP2:begin
   result:=TPasRISCV.THID.KEY_KP2;
  end;
  KEYCODE_KP3:begin
   result:=TPasRISCV.THID.KEY_KP3;
  end;
  KEYCODE_KP4:begin
   result:=TPasRISCV.THID.KEY_KP4;
  end;
  KEYCODE_KP5:begin
   result:=TPasRISCV.THID.KEY_KP5;
  end;
  KEYCODE_KP6:begin
   result:=TPasRISCV.THID.KEY_KP6;
  end;
  KEYCODE_KP7:begin
   result:=TPasRISCV.THID.KEY_KP7;
  end;
  KEYCODE_KP8:begin
   result:=TPasRISCV.THID.KEY_KP8;
  end;
  KEYCODE_KP9:begin
   result:=TPasRISCV.THID.KEY_KP9;
  end;
  KEYCODE_KP0:begin
   result:=TPasRISCV.THID.KEY_KP0;
  end;
  KEYCODE_KP_PERIOD:begin
   result:=TPasRISCV.THID.KEY_KPDOT;
  end;
  KEYCODE_102ND:begin
   result:=TPasRISCV.THID.KEY_102ND;
  end;
{ KEYCODE_LMETA:begin
   result:=TPasRISCV.THID.KEY_COMPOSE;
  end;}
  KEYCODE_POWER:begin
   result:=TPasRISCV.THID.KEY_POWER;
  end;
  KEYCODE_KP_EQUALS:begin
   result:=TPasRISCV.THID.KEY_KPEQUAL;
  end;
  KEYCODE_F13:begin
   result:=TPasRISCV.THID.KEY_F13;
  end;
  KEYCODE_F14:begin
   result:=TPasRISCV.THID.KEY_F14;
  end;
  KEYCODE_F15:begin
   result:=TPasRISCV.THID.KEY_F15;
  end;
  KEYCODE_F16:begin
   result:=TPasRISCV.THID.KEY_F16;
  end;
  KEYCODE_F17:begin
   result:=TPasRISCV.THID.KEY_F17;
  end;
  KEYCODE_F18:begin
   result:=TPasRISCV.THID.KEY_F18;
  end;
  KEYCODE_F19:begin
   result:=TPasRISCV.THID.KEY_F19;
  end;
  KEYCODE_F20:begin
   result:=TPasRISCV.THID.KEY_F20;
  end;
  KEYCODE_F21:begin
   result:=TPasRISCV.THID.KEY_F21;
  end;
  KEYCODE_F22:begin
   result:=TPasRISCV.THID.KEY_F22;
  end;
  KEYCODE_F23:begin
   result:=TPasRISCV.THID.KEY_F23;
  end;
  KEYCODE_F24:begin
   result:=TPasRISCV.THID.KEY_F24;
  end;
  KEYCODE_AC_BOOKMARKS:begin
   result:=TPasRISCV.THID.KEY_OPEN;
  end;
  KEYCODE_HELP:begin
   result:=TPasRISCV.THID.KEY_HELP;
  end;
  KEYCODE_MENU:begin
   result:=TPasRISCV.THID.KEY_MENU;
  end;
{ KEYCODE_FRONT:begin
   result:=TPasRISCV.THID.KEY_FRONT;
  end;}
  KEYCODE_STOP:begin
   result:=TPasRISCV.THID.KEY_STOP;
  end;
  KEYCODE_AGAIN:begin
   result:=TPasRISCV.THID.KEY_AGAIN;
  end;
  KEYCODE_UNDO:begin
   result:=TPasRISCV.THID.KEY_UNDO;
  end;
  KEYCODE_CUT:begin
   result:=TPasRISCV.THID.KEY_CUT;
  end;
  KEYCODE_COPY:begin
   result:=TPasRISCV.THID.KEY_COPY;
  end;
  KEYCODE_PASTE:begin
   result:=TPasRISCV.THID.KEY_PASTE;
  end;
  KEYCODE_FIND:begin
   result:=TPasRISCV.THID.KEY_FIND;
  end;
  KEYCODE_MUTE:begin
   result:=TPasRISCV.THID.KEY_MUTE;
  end;
  KEYCODE_VOLUMEUP:begin
   result:=TPasRISCV.THID.KEY_VOLUMEUP;
  end;
  KEYCODE_VOLUMEDOWN:begin
   result:=TPasRISCV.THID.KEY_VOLUMEDOWN;
  end;
  KEYCODE_KP_COMMA:begin
   result:=TPasRISCV.THID.KEY_KPCOMMA;
  end;
{KEYCODE_RO:begin
   result:=TPasRISCV.THID.KEY_RO;
  end;}
  KEYCODE_KATAKANAHIRAGANA:begin
   result:=TPasRISCV.THID.KEY_KATAKANAHIRAGANA;
  end;
{ KEYCODE_YEN:begin
   result:=TPasRISCV.THID.KEY_YEN;
  end;}
  KEYCODE_HENKAN:begin
   result:=TPasRISCV.THID.KEY_HENKAN;
  end;
  KEYCODE_MUHENKAN:begin
   result:=TPasRISCV.THID.KEY_MUHENKAN;
  end;
{ KEYCODE_KPJPCOMMA:begin
   result:=TPasRISCV.THID.KEY_KPJPCOMMA;
  end}
  KEYCODE_HANGEUL:begin
   result:=TPasRISCV.THID.KEY_HANGEUL;
  end;
  KEYCODE_HANJA:begin
   result:=TPasRISCV.THID.KEY_HANJA;
  end;
{ KEYCODE_KATAKANA:begin
   result:=TPasRISCV.THID.KEY_KATAKANA;
  end;
  KEYCODE_HIRAGANA:begin
   result:=TPasRISCV.THID.KEY_HIRAGANA;
  end
  KEYCODE_ZENKAKUHANKAKU:begin
   result:=TPasRISCV.THID.KEY_ZENKAKUHANKAKU;
  end;}
  KEYCODE_KP_LEFTPAREN:begin
   result:=TPasRISCV.THID.KEY_KPLEFTPAREN;
  end;
  KEYCODE_KP_RIGHTPAREN:begin
   result:=TPasRISCV.THID.KEY_KPRIGHTPAREN;
  end;
  KEYCODE_LCTRL:begin
   result:=TPasRISCV.THID.KEY_LEFTCTRL;
  end;
  KEYCODE_LSHIFT:begin
   result:=TPasRISCV.THID.KEY_LEFTSHIFT;
  end;
  KEYCODE_LALT:begin
   result:=TPasRISCV.THID.KEY_LEFTALT;
  end;
  KEYCODE_LGUI:begin
   result:=TPasRISCV.THID.KEY_LEFTMETA;
  end;
  KEYCODE_RCTRL:begin
   result:=TPasRISCV.THID.KEY_RIGHTCTRL;
  end;
  KEYCODE_RSHIFT:begin
   result:=TPasRISCV.THID.KEY_RIGHTSHIFT;
  end;
  KEYCODE_RALT:begin
   result:=TPasRISCV.THID.KEY_RIGHTALT;
  end;
  KEYCODE_RGUI:begin
   result:=TPasRISCV.THID.KEY_RIGHTMETA;
  end;
  KEYCODE_AUDIOPLAY:begin
   result:=TPasRISCV.THID.KEY_MEDIA_PLAYPAUSE;
  end;
  KEYCODE_AC_STOP:begin
   result:=TPasRISCV.THID.KEY_MEDIA_STOPCD;
  end;
  KEYCODE_AUDIOPREV:begin
   result:=TPasRISCV.THID.KEY_MEDIA_PREVIOUSSONG;
  end;
  KEYCODE_AUDIONEXT:begin
   result:=TPasRISCV.THID.KEY_MEDIA_NEXTSONG;
  end;
  KEYCODE_EJECT:begin
   result:=TPasRISCV.THID.KEY_MEDIA_EJECTCD;
  end;
{KEYCODE_VOLUMEUP:begin
   result:=TPasRISCV.THID.KEY_MEDIA_VOLUMEUP;
  end;
  KEYCODE_VOLUMEDOWN:begin
   result:=TPasRISCV.THID.KEY_MEDIA_VOLUMEDOWN;
  end;}
{ KEYCODE_MUTE:begin
   result:=TPasRISCV.THID.KEY_MEDIA_MUTE;
  end;}
  KEYCODE_WWW:begin
   result:=TPasRISCV.THID.KEY_MEDIA_WWW;
  end;
  KEYCODE_AC_BACK:begin
   result:=TPasRISCV.THID.KEY_MEDIA_BACK;
  end;
  KEYCODE_AC_FORWARD:begin
   result:=TPasRISCV.THID.KEY_MEDIA_FORWARD;
  end;
  KEYCODE_AUDIOSTOP:begin
   result:=TPasRISCV.THID.KEY_MEDIA_STOP;
  end;
  KEYCODE_AC_SEARCH:begin
   result:=TPasRISCV.THID.KEY_MEDIA_FIND;
  end;
{ KEYCODE_MEDIA_SCROLLUP:begin
   result:=TPasRISCV.THID.KEY_MEDIA_SCROLLUP;
  end;
  KEYCODE_MEDIA_SCROLLDOWN:begin
   result:=TPasRISCV.THID.KEY_MEDIA_SCROLLDOWN;
  end;}
  KEYCODE_MEDIASELECT:begin
   result:=TPasRISCV.THID.KEY_MEDIA_EDIT;
  end;
  KEYCODE_SLEEP:begin
   result:=TPasRISCV.THID.KEY_MEDIA_SLEEP;
  end;
{ KEYCODE_AC_COFFEE:begin
   result:=TPasRISCV.THID.KEY_MEDIA_COFFEE;
  end;}
  KEYCODE_AC_REFRESH:begin
   result:=TPasRISCV.THID.KEY_MEDIA_REFRESH;
  end;
  KEYCODE_CALCULATOR:begin
   result:=TPasRISCV.THID.KEY_MEDIA_CALC;
  end;
  else begin
   result:=TPasRISCV.THID.KEY_NONE;
  end;
 end;
end;

function MapKeyCodeToEVDEVKeyCode(const aKeyCode:TpvUInt32):TpvUInt32;
begin
 case aKeyCode of
  KEYCODE_A:begin
   result:=TPasRISCV.TEVDEV.KEY_A;
  end;
  KEYCODE_B:begin
   result:=TPasRISCV.TEVDEV.KEY_B;
  end;
  KEYCODE_C:begin
   result:=TPasRISCV.TEVDEV.KEY_C;
  end;
  KEYCODE_D:begin
   result:=TPasRISCV.TEVDEV.KEY_D;
  end;
  KEYCODE_E:begin
   result:=TPasRISCV.TEVDEV.KEY_E;
  end;
  KEYCODE_F:begin
   result:=TPasRISCV.TEVDEV.KEY_F;
  end;
  KEYCODE_G:begin
   result:=TPasRISCV.TEVDEV.KEY_G;
  end;
  KEYCODE_H:begin
   result:=TPasRISCV.TEVDEV.KEY_H;
  end;
  KEYCODE_I:begin
   result:=TPasRISCV.TEVDEV.KEY_I;
  end;
  KEYCODE_J:begin
   result:=TPasRISCV.TEVDEV.KEY_J;
  end;
  KEYCODE_K:begin
   result:=TPasRISCV.TEVDEV.KEY_K;
  end;
  KEYCODE_L:begin
   result:=TPasRISCV.TEVDEV.KEY_L;
  end;
  KEYCODE_M:begin
   result:=TPasRISCV.TEVDEV.KEY_M;
  end;
  KEYCODE_N:begin
   result:=TPasRISCV.TEVDEV.KEY_N;
  end;
  KEYCODE_O:begin
   result:=TPasRISCV.TEVDEV.KEY_O;
  end;
  KEYCODE_P:begin
   result:=TPasRISCV.TEVDEV.KEY_P;
  end;
  KEYCODE_Q:begin
   result:=TPasRISCV.TEVDEV.KEY_Q;
  end;
  KEYCODE_R:begin
   result:=TPasRISCV.TEVDEV.KEY_R;
  end;
  KEYCODE_S:begin
   result:=TPasRISCV.TEVDEV.KEY_S;
  end;
  KEYCODE_T:begin
   result:=TPasRISCV.TEVDEV.KEY_T;
  end;
  KEYCODE_U:begin
   result:=TPasRISCV.TEVDEV.KEY_U;
  end;
  KEYCODE_V:begin
   result:=TPasRISCV.TEVDEV.KEY_V;
  end;
  KEYCODE_W:begin
   result:=TPasRISCV.TEVDEV.KEY_W;
  end;
  KEYCODE_X:begin
   result:=TPasRISCV.TEVDEV.KEY_X;
  end;
  KEYCODE_Y:begin
   result:=TPasRISCV.TEVDEV.KEY_Y;
  end;
  KEYCODE_Z:begin
   result:=TPasRISCV.TEVDEV.KEY_Z;
  end;
  KEYCODE_1:begin
   result:=TPasRISCV.TEVDEV.KEY_1;
  end;
  KEYCODE_2:begin
   result:=TPasRISCV.TEVDEV.KEY_2;
  end;
  KEYCODE_3:begin
   result:=TPasRISCV.TEVDEV.KEY_3;
  end;
  KEYCODE_4:begin
   result:=TPasRISCV.TEVDEV.KEY_4;
  end;
  KEYCODE_5:begin
   result:=TPasRISCV.TEVDEV.KEY_5;
  end;
  KEYCODE_6:begin
   result:=TPasRISCV.TEVDEV.KEY_6;
  end;
  KEYCODE_7:begin
   result:=TPasRISCV.TEVDEV.KEY_7;
  end;
  KEYCODE_8:begin
   result:=TPasRISCV.TEVDEV.KEY_8;
  end;
  KEYCODE_9:begin
   result:=TPasRISCV.TEVDEV.KEY_9;
  end;
  KEYCODE_0:begin
   result:=TPasRISCV.TEVDEV.KEY_0;
  end;
  KEYCODE_RETURN:begin
   result:=TPasRISCV.TEVDEV.KEY_ENTER;
  end;
  KEYCODE_ESCAPE:begin
   result:=TPasRISCV.TEVDEV.KEY_ESC;
  end;
  KEYCODE_BACKSPACE:begin
   result:=TPasRISCV.TEVDEV.KEY_BACKSPACE;
  end;
  KEYCODE_TAB:begin
   result:=TPasRISCV.TEVDEV.KEY_TAB;
  end;
  KEYCODE_SPACE:begin
   result:=TPasRISCV.TEVDEV.KEY_SPACE;
  end;
  KEYCODE_MINUS:begin
   result:=TPasRISCV.TEVDEV.KEY_MINUS;
  end;
  KEYCODE_EQUALS:begin
   result:=TPasRISCV.TEVDEV.KEY_EQUAL;
  end;
  KEYCODE_LEFTBRACKET,KEYCODE_LEFTBRACE:begin
   result:=TPasRISCV.TEVDEV.KEY_LEFTBRACE;
  end;
  KEYCODE_RIGHTBRACKET,KEYCODE_RIGHTBRACE:begin
   result:=TPasRISCV.TEVDEV.KEY_RIGHTBRACE;
  end;
  KEYCODE_BACKSLASH:begin
   result:=TPasRISCV.TEVDEV.KEY_BACKSLASH;
  end;
{ KEYCODE_TILDE:begin
   result:=TPasRISCV.TEVDEV.KEY_HASHTILDE;
  end;}
  KEYCODE_SEMICOLON:begin
   result:=TPasRISCV.TEVDEV.KEY_SEMICOLON;
  end;
  KEYCODE_APOSTROPHE:begin
   result:=TPasRISCV.TEVDEV.KEY_APOSTROPHE;
  end;
  KEYCODE_GRAVE:begin
   result:=TPasRISCV.TEVDEV.KEY_GRAVE;
  end;
  KEYCODE_COMMA:begin
   result:=TPasRISCV.TEVDEV.KEY_COMMA;
  end;
  KEYCODE_PERIOD:begin
   result:=TPasRISCV.TEVDEV.KEY_DOT;
  end;
  KEYCODE_SLASH:begin
   result:=TPasRISCV.TEVDEV.KEY_SLASH;
  end;
  KEYCODE_CAPSLOCK:begin
   result:=TPasRISCV.TEVDEV.KEY_CAPSLOCK;
  end;
  KEYCODE_F1:begin
   result:=TPasRISCV.TEVDEV.KEY_F1;
  end;
  KEYCODE_F2:begin
   result:=TPasRISCV.TEVDEV.KEY_F2;
  end;
  KEYCODE_F3:begin
   result:=TPasRISCV.TEVDEV.KEY_F3;
  end;
  KEYCODE_F4:begin
   result:=TPasRISCV.TEVDEV.KEY_F4;
  end;
  KEYCODE_F5:begin
   result:=TPasRISCV.TEVDEV.KEY_F5;
  end;
  KEYCODE_F6:begin
   result:=TPasRISCV.TEVDEV.KEY_F6;
  end;
  KEYCODE_F7:begin
   result:=TPasRISCV.TEVDEV.KEY_F7;
  end;
  KEYCODE_F8:begin
   result:=TPasRISCV.TEVDEV.KEY_F8;
  end;
  KEYCODE_F9:begin
   result:=TPasRISCV.TEVDEV.KEY_F9;
  end;
  KEYCODE_F10:begin
   result:=TPasRISCV.TEVDEV.KEY_F10;
  end;
  KEYCODE_F11:begin
   result:=TPasRISCV.TEVDEV.KEY_F11;
  end;
  KEYCODE_F12:begin
   result:=TPasRISCV.TEVDEV.KEY_F12;
  end;
  KEYCODE_SYSREQ:begin
   result:=TPasRISCV.TEVDEV.KEY_SYSRQ;
  end;
  KEYCODE_SCROLLLOCK:begin
   result:=TPasRISCV.TEVDEV.KEY_SCROLLLOCK;
  end;
  KEYCODE_PAUSE:begin
   result:=TPasRISCV.TEVDEV.KEY_PAUSE;
  end;
  KEYCODE_INSERT:begin
   result:=TPasRISCV.TEVDEV.KEY_INSERT;
  end;
  KEYCODE_HOME:begin
   result:=TPasRISCV.TEVDEV.KEY_HOME;
  end;
  KEYCODE_PAGEUP:begin
   result:=TPasRISCV.TEVDEV.KEY_PAGEUP;
  end;
  KEYCODE_DELETE:begin
   result:=TPasRISCV.TEVDEV.KEY_DELETE;
  end;
  KEYCODE_END:begin
   result:=TPasRISCV.TEVDEV.KEY_END;
  end;
  KEYCODE_PAGEDOWN:begin
   result:=TPasRISCV.TEVDEV.KEY_PAGEDOWN;
  end;
  KEYCODE_RIGHT:begin
   result:=TPasRISCV.TEVDEV.KEY_RIGHT;
  end;
  KEYCODE_LEFT:begin
   result:=TPasRISCV.TEVDEV.KEY_LEFT;
  end;
  KEYCODE_DOWN:begin
   result:=TPasRISCV.TEVDEV.KEY_DOWN;
  end;
  KEYCODE_UP:begin
   result:=TPasRISCV.TEVDEV.KEY_UP;
  end;
  KEYCODE_NUMLOCK:begin
   result:=TPasRISCV.TEVDEV.KEY_NUMLOCK;
  end;
  KEYCODE_KP_DIVIDE:begin
   result:=TPasRISCV.TEVDEV.KEY_KPSLASH;
  end;
  KEYCODE_KP_MULTIPLY:begin
   result:=TPasRISCV.TEVDEV.KEY_KPASTERISK;
  end;
  KEYCODE_KP_MINUS:begin
   result:=TPasRISCV.TEVDEV.KEY_KPMINUS;
  end;
  KEYCODE_KP_PLUS:begin
   result:=TPasRISCV.TEVDEV.KEY_KPPLUS;
  end;
  KEYCODE_KP_ENTER:begin
   result:=TPasRISCV.TEVDEV.KEY_KPENTER;
  end;
  KEYCODE_KP1:begin
   result:=TPasRISCV.TEVDEV.KEY_KP1;
  end;
  KEYCODE_KP2:begin
   result:=TPasRISCV.TEVDEV.KEY_KP2;
  end;
  KEYCODE_KP3:begin
   result:=TPasRISCV.TEVDEV.KEY_KP3;
  end;
  KEYCODE_KP4:begin
   result:=TPasRISCV.TEVDEV.KEY_KP4;
  end;
  KEYCODE_KP5:begin
   result:=TPasRISCV.TEVDEV.KEY_KP5;
  end;
  KEYCODE_KP6:begin
   result:=TPasRISCV.TEVDEV.KEY_KP6;
  end;
  KEYCODE_KP7:begin
   result:=TPasRISCV.TEVDEV.KEY_KP7;
  end;
  KEYCODE_KP8:begin
   result:=TPasRISCV.TEVDEV.KEY_KP8;
  end;
  KEYCODE_KP9:begin
   result:=TPasRISCV.TEVDEV.KEY_KP9;
  end;
  KEYCODE_KP0:begin
   result:=TPasRISCV.TEVDEV.KEY_KP0;
  end;
  KEYCODE_KP_PERIOD:begin
   result:=TPasRISCV.TEVDEV.KEY_KPDOT;
  end;
  KEYCODE_102ND:begin
   result:=TPasRISCV.TEVDEV.KEY_102ND;
  end;
{ KEYCODE_LMETA:begin
   result:=TPasRISCV.TEVDEV.KEY_COMPOSE;
  end;}
  KEYCODE_POWER:begin
   result:=TPasRISCV.TEVDEV.KEY_POWER;
  end;
  KEYCODE_KP_EQUALS:begin
   result:=TPasRISCV.TEVDEV.KEY_KPEQUAL;
  end;
  KEYCODE_F13:begin
   result:=TPasRISCV.TEVDEV.KEY_F13;
  end;
  KEYCODE_F14:begin
   result:=TPasRISCV.TEVDEV.KEY_F14;
  end;
  KEYCODE_F15:begin
   result:=TPasRISCV.TEVDEV.KEY_F15;
  end;
  KEYCODE_F16:begin
   result:=TPasRISCV.TEVDEV.KEY_F16;
  end;
  KEYCODE_F17:begin
   result:=TPasRISCV.TEVDEV.KEY_F17;
  end;
  KEYCODE_F18:begin
   result:=TPasRISCV.TEVDEV.KEY_F18;
  end;
  KEYCODE_F19:begin
   result:=TPasRISCV.TEVDEV.KEY_F19;
  end;
  KEYCODE_F20:begin
   result:=TPasRISCV.TEVDEV.KEY_F20;
  end;
  KEYCODE_F21:begin
   result:=TPasRISCV.TEVDEV.KEY_F21;
  end;
  KEYCODE_F22:begin
   result:=TPasRISCV.TEVDEV.KEY_F22;
  end;
  KEYCODE_F23:begin
   result:=TPasRISCV.TEVDEV.KEY_F23;
  end;
  KEYCODE_F24:begin
   result:=TPasRISCV.TEVDEV.KEY_F24;
  end;
  KEYCODE_AC_BOOKMARKS:begin
   result:=TPasRISCV.TEVDEV.KEY_OPEN;
  end;
  KEYCODE_HELP:begin
   result:=TPasRISCV.TEVDEV.KEY_HELP;
  end;
  KEYCODE_MENU:begin
   result:=TPasRISCV.TEVDEV.KEY_MENU;
  end;
{ KEYCODE_FRONT:begin
   result:=TPasRISCV.TEVDEV.KEY_FRONT;
  end;}
  KEYCODE_STOP:begin
   result:=TPasRISCV.TEVDEV.KEY_STOP;
  end;
  KEYCODE_AGAIN:begin
   result:=TPasRISCV.TEVDEV.KEY_AGAIN;
  end;
  KEYCODE_UNDO:begin
   result:=TPasRISCV.TEVDEV.KEY_UNDO;
  end;
  KEYCODE_CUT:begin
   result:=TPasRISCV.TEVDEV.KEY_CUT;
  end;
  KEYCODE_COPY:begin
   result:=TPasRISCV.TEVDEV.KEY_COPY;
  end;
  KEYCODE_PASTE:begin
   result:=TPasRISCV.TEVDEV.KEY_PASTE;
  end;
  KEYCODE_FIND:begin
   result:=TPasRISCV.TEVDEV.KEY_FIND;
  end;
  KEYCODE_MUTE:begin
   result:=TPasRISCV.TEVDEV.KEY_MUTE;
  end;
  KEYCODE_VOLUMEUP:begin
   result:=TPasRISCV.TEVDEV.KEY_VOLUMEUP;
  end;
  KEYCODE_VOLUMEDOWN:begin
   result:=TPasRISCV.TEVDEV.KEY_VOLUMEDOWN;
  end;
  KEYCODE_KP_COMMA:begin
   result:=TPasRISCV.TEVDEV.KEY_KPCOMMA;
  end;
{KEYCODE_RO:begin
   result:=TPasRISCV.TEVDEV.KEY_RO;
  end;}
  KEYCODE_KATAKANAHIRAGANA:begin
   result:=TPasRISCV.TEVDEV.KEY_KATAKANAHIRAGANA;
  end;
{ KEYCODE_YEN:begin
   result:=TPasRISCV.TEVDEV.KEY_YEN;
  end;}
  KEYCODE_HENKAN:begin
   result:=TPasRISCV.TEVDEV.KEY_HENKAN;
  end;
  KEYCODE_MUHENKAN:begin
   result:=TPasRISCV.TEVDEV.KEY_MUHENKAN;
  end;
{ KEYCODE_KPJPCOMMA:begin
   result:=TPasRISCV.TEVDEV.KEY_KPJPCOMMA;
  end}
  KEYCODE_HANGEUL:begin
   result:=TPasRISCV.TEVDEV.KEY_HANGEUL;
  end;
  KEYCODE_HANJA:begin
   result:=TPasRISCV.TEVDEV.KEY_HANJA;
  end;
{ KEYCODE_KATAKANA:begin
   result:=TPasRISCV.TEVDEV.KEY_KATAKANA;
  end;
  KEYCODE_HIRAGANA:begin
   result:=TPasRISCV.TEVDEV.KEY_HIRAGANA;
  end
  KEYCODE_ZENKAKUHANKAKU:begin
   result:=TPasRISCV.TEVDEV.KEY_ZENKAKUHANKAKU;
  end;}
  KEYCODE_KP_LEFTPAREN:begin
   result:=TPasRISCV.TEVDEV.KEY_KPLEFTPAREN;
  end;
  KEYCODE_KP_RIGHTPAREN:begin
   result:=TPasRISCV.TEVDEV.KEY_KPRIGHTPAREN;
  end;
  KEYCODE_LCTRL:begin
   result:=TPasRISCV.TEVDEV.KEY_LEFTCTRL;
  end;
  KEYCODE_LSHIFT:begin
   result:=TPasRISCV.TEVDEV.KEY_LEFTSHIFT;
  end;
  KEYCODE_LALT:begin
   result:=TPasRISCV.TEVDEV.KEY_LEFTALT;
  end;
  KEYCODE_LGUI:begin
   result:=TPasRISCV.TEVDEV.KEY_LEFTMETA;
  end;
  KEYCODE_RCTRL:begin
   result:=TPasRISCV.TEVDEV.KEY_RIGHTCTRL;
  end;
  KEYCODE_RSHIFT:begin
   result:=TPasRISCV.TEVDEV.KEY_RIGHTSHIFT;
  end;
  KEYCODE_RALT:begin
   result:=TPasRISCV.TEVDEV.KEY_RIGHTALT;
  end;
  KEYCODE_RGUI:begin
   result:=TPasRISCV.TEVDEV.KEY_RIGHTMETA;
  end;
  KEYCODE_AUDIOPLAY:begin
   result:=TPasRISCV.TEVDEV.KEY_PLAY;
  end;
  KEYCODE_AC_STOP:begin
   result:=TPasRISCV.TEVDEV.KEY_STOP;
  end;
  KEYCODE_AUDIOPREV:begin
   result:=TPasRISCV.TEVDEV.KEY_PREVIOUSSONG;
  end;
  KEYCODE_AUDIONEXT:begin
   result:=TPasRISCV.TEVDEV.KEY_NEXTSONG;
  end;
  KEYCODE_EJECT:begin
   result:=TPasRISCV.TEVDEV.KEY_EJECTCD;
  end;
{KEYCODE_VOLUMEUP:begin
   result:=TPasRISCV.TEVDEV.KEY_MEDIA_VOLUMEUP;
  end;
  KEYCODE_VOLUMEDOWN:begin
   result:=TPasRISCV.TEVDEV.KEY_MEDIA_VOLUMEDOWN;
  end;}
{ KEYCODE_MUTE:begin
   result:=TPasRISCV.TEVDEV.KEY_MEDIA_MUTE;
  end;}
  KEYCODE_WWW:begin
   result:=TPasRISCV.TEVDEV.KEY_WWW;
  end;
  KEYCODE_AC_BACK:begin
   result:=TPasRISCV.TEVDEV.KEY_BACK;
  end;
  KEYCODE_AC_FORWARD:begin
   result:=TPasRISCV.TEVDEV.KEY_FORWARD;
  end;
  KEYCODE_AUDIOSTOP:begin
   result:=TPasRISCV.TEVDEV.KEY_STOP;
  end;
  KEYCODE_AC_SEARCH:begin
   result:=TPasRISCV.TEVDEV.KEY_SEARCH;
  end;
{ KEYCODE_MEDIA_SCROLLUP:begin
   result:=TPasRISCV.TEVDEV.KEY_MEDIA_SCROLLUP;
  end;
  KEYCODE_MEDIA_SCROLLDOWN:begin
   result:=TPasRISCV.TEVDEV.KEY_MEDIA_SCROLLDOWN;
  end;}
  KEYCODE_MEDIASELECT:begin
   result:=TPasRISCV.TEVDEV.KEY_MEDIA;
  end;
  KEYCODE_SLEEP:begin
   result:=TPasRISCV.TEVDEV.KEY_SLEEP;
  end;
{ KEYCODE_AC_COFFEE:begin
   result:=TPasRISCV.TEVDEV.KEY_MEDIA_COFFEE;
  end;}
  KEYCODE_AC_REFRESH:begin
   result:=TPasRISCV.TEVDEV.KEY_REFRESH;
  end;
  KEYCODE_CALCULATOR:begin
   result:=TPasRISCV.TEVDEV.KEY_CALC;
  end;
  else begin
   result:=TPasRISCV.TEVDEV.KEY_UNKNOWN;
  end;
 end;
end;

procedure ResizeRGB32(Src:pointer;SrcWidth,SrcHeight:TpvInt32;Dst:pointer;DstWidth,DstHeight:TpvInt32;var XCache:TpvPasRISCVEmulatorMachineInstance.TIntegers);
type PLongwords=^TLongwords;
     TLongwords=array[0..65535] of TpvUInt32;
var DstX,DstY,SrcX,SrcY:TpvInt32;
    r,g,b,w,Pixel,SrcR,SrcG,SrcB,SrcA,Weight,xUL,xUR,xLL,xLR,
    RedBlue,Green,Remainder,WeightX,WeightY:TpvUInt32;
    TempSrc,TempDst:PLongwords;
    UpsampleX,UpsampleY:longbool;
    WeightShift,xa,xb,xc,xd,ya,yb,yc,yd:TpvInt32;
    SourceTexelsPerOutPixel,WeightPerPixel,AccumlatorPerPixel,WeightDivider,fw,fh:single;
begin
 if (SrcWidth=(DstWidth*2)) and (SrcHeight=(DstHeight*2)) then begin
  Remainder:=0;
  TempDst:=pointer(Dst);
  for DstY:=0 to DstHeight-1 do begin
   SrcY:=DstY*2;
   TempSrc:=pointer(@pansichar(Src)[(SrcY*SrcWidth) shl 2]);
   for DstX:=0 to DstWidth-1 do begin
    xUL:=TempSrc^[0];
    xUR:=TempSrc^[1];
    xLL:=TempSrc^[SrcWidth];
    xLR:=TempSrc^[SrcWidth+1];
    RedBlue:=(xUL and $00ff00ff)+(xUR and $00ff00ff)+(xLL and $00ff00ff)+(xLR and $00ff00ff)+(Remainder and $00ff00ff);
    Green:=(xUL and $0000ff00)+(xUR and $0000ff00)+(xLL and $0000ff00)+(xLR and $0000ff00)+(Remainder and $0000ff00);
    Remainder:=(RedBlue and $00030003) or (Green and $00000300);
    TempDst[0]:=(((RedBlue and $03fc03fc) or (Green and $0003fc00)) shr 2) or TpvUInt32($ff000000);
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
   if length(XCache)<TpvInt32(DstWidth) then begin
    SetLength(XCache,TpvInt32(DstWidth));
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
     WeightX:=TpvUInt32(TpvInt32(256-(xa and $ff)));
     WeightY:=TpvUInt32(TpvInt32(256-(ya and $ff)));
     for SrcY:=0 to 1 do begin
      for SrcX:=0 to 1 do begin
       Pixel:=TempSrc^[(SrcY*SrcWidth)+SrcX];
       SrcR:=(Pixel shr 0) and $ff;
       SrcG:=(Pixel shr 8) and $ff;
       SrcB:=(Pixel shr 16) and $ff;
       Weight:=(WeightX*WeightY) shr WeightShift;
       inc(r,SrcR*Weight);
       inc(g,SrcG*Weight);
       inc(b,SrcB*Weight);
       WeightX:=256-WeightX;
      end;
      WeightY:=256-WeightY;
     end;
     TempDst^[0]:=(((r shr 16) and $ff) or ((g shr 8) and $ff00) or (b and $ff0000)) or TpvUInt32($ff000000);
     TempDst:=pointer(@TempDst^[1]);
    end;
   end;
  end else begin
   if length(XCache)<(TpvInt32(DstWidth)*2) then begin
    SetLength(XCache,TpvInt32(DstWidth)*2);
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
       inc(PAnsiChar(TempSrc),SizeOf(TpvUInt32));
       SrcR:=(Pixel shr 0) and $ff;
       SrcG:=(Pixel shr 8) and $ff;
       SrcB:=(Pixel shr 16) and $ff;
       Weight:=(WeightX*WeightY) shr WeightShift;
       inc(r,SrcR*Weight);
       inc(g,SrcG*Weight);
       inc(b,SrcB*Weight);
       inc(w,Weight);
      end;
     end;
     if w>0 then begin
      TempDst^[0]:=(((r div w) and $ff) or (((g div w) shl 8) and $ff00) or (((b div w) shl 16) and $ff0000)) or TpvUInt32($ff000000);
     end else begin
      TempDst^[0]:=TpvUInt32($ff000000);
     end;
     TempDst:=pointer(@TempDst^[1]);
    end;
   end;
  end;
 end;
end;

function ConvertColor(const c:TPasTermUInt32):TpvVector4;
begin
 result.r:=((c shr 0) and $ff)/$ff;
 result.g:=((c shr 8) and $ff)/$ff;
 result.b:=((c shr 16) and $ff)/$ff;
 result.a:=1.0;
end;

{ TpvPasRISCVEmulatorMachineInstance.TVSockTestProtocol }

constructor TpvPasRISCVEmulatorMachineInstance.TVSockTestProtocol.Create(const aManager:TPasRISCV.TVirtIOVSockDevice.TVSockManager;const aTag:Pointer;const aLocalPort,aRemotePort:TPasRISCVUInt32;const aRemoteCID:TPasRISCVUInt64;const aSocketType:TPasRISCVUInt16);
begin
 inherited Create(aManager,aTag,aLocalPort,aRemotePort,aRemoteCID,aSocketType);
 fReceiveBuffer:=TPasMPSingleProducerSingleConsumerRingBuffer.Create(4 shl 20);
 fHasPendingHeader:=false;
 FillChar(fPendingHeader,SizeOf(fPendingHeader),#0);
end;

destructor TpvPasRISCVEmulatorMachineInstance.TVSockTestProtocol.Destroy;
begin
 FreeAndNil(fReceiveBuffer);
 inherited Destroy;
end;

procedure TpvPasRISCVEmulatorMachineInstance.TVSockTestProtocol.OnConnect;
begin
 TpvPasRISCVEmulatorMachineInstance(Tag).fActiveTestConnectionsLock.Acquire;
 try
  TpvPasRISCVEmulatorMachineInstance(Tag).fActiveTestConnections.Add(self);
 finally
  TpvPasRISCVEmulatorMachineInstance(Tag).fActiveTestConnectionsLock.Release;
 end;
 Accept;
end;

procedure TpvPasRISCVEmulatorMachineInstance.TVSockTestProtocol.OnReceive(const aData:Pointer;const aSize:TPasRISCVUInt32;const aFlags:TPasRISCVUInt32);
begin
 fReceiveBuffer.WriteAsMuchAsPossible(aData,aSize);
end;

procedure TpvPasRISCVEmulatorMachineInstance.TVSockTestProtocol.OnDisconnect;
begin
 TpvPasRISCVEmulatorMachineInstance(Tag).fActiveTestConnectionsLock.Acquire;
 try
  TpvPasRISCVEmulatorMachineInstance(Tag).fActiveTestConnections.Remove(self);
 finally
  TpvPasRISCVEmulatorMachineInstance(Tag).fActiveTestConnectionsLock.Release;
 end;
end;

procedure TpvPasRISCVEmulatorMachineInstance.TVSockTestProtocol.SendMessage(const aMsgType:TPasRISCVUInt32;const aData:Pointer;const aSize:TPasRISCVUInt32);
var Header:TMessageHeader;
begin
 Header.Magic:=MESSAGE_MAGIC;
 Header.MsgType:=aMsgType;
 Header.Length:=aSize;
 SendData(@Header,SizeOf(Header));
 if aSize>0 then begin
  SendData(aData,aSize);
 end;
end;

procedure TpvPasRISCVEmulatorMachineInstance.TVSockTestProtocol.ProcessMessage(const aMsgType:TPasRISCVUInt32;const aData:Pointer;const aSize:TPasRISCVUInt32);
begin
 case aMsgType of
  MSG_PING:begin
   SendMessage(MSG_PONG,nil,0);
  end;
  MSG_ECHO_REQ:begin
   SendMessage(MSG_ECHO_RESP,aData,aSize);
  end;
  MSG_INFO_REQ:begin
   SendMessage(MSG_INFO_RESP,nil,0);
  end;
  MSG_DONE:begin
   Close;
  end;
  else begin
  end;
 end;
end;

procedure TpvPasRISCVEmulatorMachineInstance.TVSockTestProtocol.ProcessMessages;
var PayloadBuffer:TPasRISCVUInt8DynamicArray;
    PayloadSize:TPasRISCVUInt32;
begin
 repeat
  if not fHasPendingHeader then begin
   if fReceiveBuffer.AvailableForRead<SizeOf(TMessageHeader) then begin
    break;
   end;
   fReceiveBuffer.Read(@fPendingHeader,SizeOf(TMessageHeader));
   if fPendingHeader.Magic<>MESSAGE_MAGIC then begin
    Close;
    break;
   end;
   fHasPendingHeader:=true;
  end;
  PayloadSize:=fPendingHeader.Length;
  if fReceiveBuffer.AvailableForRead<TPasMPInt32(PayloadSize) then begin
   break;
  end;
  PayloadBuffer:=nil;
  if PayloadSize>0 then begin
   SetLength(PayloadBuffer,PayloadSize);
   fReceiveBuffer.Read(@PayloadBuffer[0],PayloadSize);
  end;
  fHasPendingHeader:=false;
  if PayloadSize>0 then begin
   ProcessMessage(fPendingHeader.MsgType,@PayloadBuffer[0],PayloadSize);
  end else begin
   ProcessMessage(fPendingHeader.MsgType,nil,0);
  end;
 until false;
end;

{ TpvPasRISCVEmulatorMachineInstance }

constructor TpvPasRISCVEmulatorMachineInstance.Create;
var Stream:TStream;
    BIOSFile,KernelFile,INITRDFile,VirtIOBlockFile,NVMeFile:TpvRawByteString;
begin

 fXCacheIntegers:=nil;

 fMachineConfiguration:=TPasRISCV.TConfiguration.Create;

 ConfigureMachine;

 fVirtIOGPUVirGL:=fMachineConfiguration.VirtIOGPUVirGL;

 fNextFrameTime:=0;

 BIOSFile:=GetBIOSFileName;
 if FileExists(BIOSFile) then begin
  fMachineConfiguration.LoadBIOSFromFile(BIOSFile);
 end else if pvApplication.Assets.ExistAsset('riscv/'+BIOSFile) then begin
  Stream:=pvApplication.Assets.GetAssetStream('riscv/'+BIOSFile);
  if assigned(Stream) then begin
   try
    fMachineConfiguration.LoadBIOSFromStream(Stream);
   finally
    FreeAndNil(Stream);
   end;
  end;
 end;

 KernelFile:=GetKernelFileName;
 if FileExists(KernelFile) then begin
  fMachineConfiguration.LoadKernelFromFile(KernelFile);
 end else if pvApplication.Assets.ExistAsset('riscv/'+KernelFile) then begin
  Stream:=pvApplication.Assets.GetAssetStream('riscv/'+KernelFile);
  if assigned(Stream) then begin
   try
    fMachineConfiguration.LoadKernelFromStream(Stream);
   finally
    FreeAndNil(Stream);
   end;
  end;
 end;

 INITRDFile:=GetINITRDFileName;
 if FileExists(INITRDFile) then begin
  fMachineConfiguration.LoadINITRDFromFile(INITRDFile);
 end else if pvApplication.Assets.ExistAsset('riscv/'+INITRDFile) then begin
  Stream:=pvApplication.Assets.GetAssetStream('riscv/'+INITRDFile);
  if assigned(Stream) then begin
   try
    fMachineConfiguration.LoadINITRDFromStream(Stream);
   finally
    FreeAndNil(Stream);
   end;
  end;
 end;

 VirtIOBlockFile:=GetVirtIOBlockImageFileName;
 fMachineConfiguration.VirtIOBlockEnabled:=(length(VirtIOBlockFile)>0) and
                                           (FileExists(VirtIOBlockFile) or
                                            FileExists(IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(pvApplication.Assets.BasePath)+'riscv')+VirtIOBlockFile) or
                                            pvApplication.Assets.ExistAsset('riscv/'+VirtIOBlockFile));

 NVMeFile:=GetNVMeImageFileName;
 fMachineConfiguration.NVMeEnabled:=(length(NVMeFile)>0) and
                                    (FileExists(NVMeFile) or
                                     FileExists(IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(pvApplication.Assets.BasePath)+'riscv')+NVMeFile) or
                                     pvApplication.Assets.ExistAsset('riscv/'+NVMeFile));

 fMachine:=TPasRISCV.Create(fMachineConfiguration);

{$if (defined(fpc) and defined(unix)) or defined(Windows)}
 f9PFileSystem:=TPasRISCV9PFileSystemNative.Create(IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(pvApplication.Assets.BasePath)+'riscv')+'extern');
{$else}
 f9PFileSystem:=nil;
{$ifend}
 fMachine.VirtIO9PDevice.FileSystem:=f9PFileSystem;

{$if (defined(fpc) and defined(unix)) or defined(Windows)}
 fFUSEFileSystem:=TPasRISCVFUSEFileSystemNative.Create(IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(pvApplication.Assets.BasePath)+'riscv')+'extern');
{$else}
 fFUSEFileSystem:=nil;
{$ifend}
 fMachine.VirtIOFSDevice.FileSystem:=fFUSEFileSystem;

(*{$if defined(fpc) and defined(unix)}
 if not assigned(fMachine.VirtIONetDevice.EthernetDevice) then begin
  fEthernetDevice:=TPasRISCVEthernetDeviceTUN.Create;
  TPasRISCVEthernetDeviceTUN(fEthernetDevice).Open('tap0');
  fMachine.VirtIONetDevice.EthernetDevice:=fEthernetDevice;
 end else begin
  fEthernetDevice:=nil;
 end;
{$else}
 fEthernetDevice:=nil;
{$ifend}*)

 pvApplication.Audio.Lock;
 try
  pvApplication.Audio.OnFillBuffer:=fMachine.SoundIO.OutputAudioFillBufferCallback;
 finally
  pvApplication.Audio.Unlock;
 end;

 AfterMachineCreate;

 fMachine.FrameBufferDevice.Active:=true;

 fMachine.OnReboot:=OnReboot;
 fMachine.OnNewFrame:=OnNewFrame;
{$ifdef PasRISCVVirtIOGPUVulkanVenus}
 if assigned(fMachine.VirtIOGPUDevice) then begin
  fMachine.VirtIOGPUDevice.OnScanoutUpdate:=OnScanoutUpdate;
 end;
{$endif}

 fActiveTestConnections:=TVSockTestProtocolList.Create(false);

 fActiveTestConnectionsLock:=TPasMPCriticalSection.Create;

 if assigned(fMachine.VirtIOVSockDevice) then begin
  fVSockManager:=TPasRISCV.TVirtIOVSockDevice.TVSockManager.Create(fMachine.VirtIOVSockDevice);
  fVSockManager.RegisterPort(1337,TVSockTestProtocol,self);
  fMachine.VirtIOVSockDevice.Manager:=fVSockManager;
 end else begin
  fVSockManager:=nil;
 end;

 inherited Create(false);
end;

destructor TpvPasRISCVEmulatorMachineInstance.Destroy;
begin
 Shutdown;
 pvApplication.Audio.Lock;
 try
  pvApplication.Audio.OnFillBuffer:=nil;
 finally
  pvApplication.Audio.Unlock;
 end;
 fMachine.VirtIO9PDevice.FileSystem:=nil;
(*begin
  if assigned(fEthernetDevice) then begin
   fEthernetDevice.Shutdown;
  end;
  fMachine.VirtIONetDevice.EthernetDevice:=nil;
 end;*)
 if assigned(fMachine.VirtIONetDevice.EthernetDevice) then begin
  fMachine.VirtIONetDevice.EthernetDevice.Shutdown;
 end;
 if assigned(fVSockManager) then begin
  try
   if assigned(fMachine.VirtIOVSockDevice) then begin
    fMachine.VirtIOVSockDevice.Manager:=nil;
   end;
  finally
   FreeAndNil(fVSockManager);
  end;
 end;
 FreeAndNil(fActiveTestConnections);
 FreeAndNil(fActiveTestConnectionsLock);
 FreeAndNil(fMachine);
 FreeAndNil(fMachineConfiguration);
 FreeAndNil(fFUSEFileSystem);
 FreeAndNil(f9PFileSystem);
//FreeAndNil(fEthernetDevice);
 fXCacheIntegers:=nil;
 inherited Destroy;
end;

procedure TpvPasRISCVEmulatorMachineInstance.AfterMachineCreate;
begin
 // Default: do nothing. Override to set e.g. FrameBufferDevice.AutomaticRefresh:=true
end;

procedure TpvPasRISCVEmulatorMachineInstance.PreBoot;
begin
 // Default: do nothing. Override to detach streams before reset etc.
end;

procedure TpvPasRISCVEmulatorMachineInstance.Shutdown;
begin
 if not Finished then begin
  Terminate;
  if assigned(fMachine) then begin
   fMachine.PowerOff;
   fMachine.WakeUp;
  end;
  WaitFor;
 end;
end;

procedure TpvPasRISCVEmulatorMachineInstance.Execute;
begin
{$if declared(NameThreadForDebugging)}
 NameThreadForDebugging('TpvPasRISCVEmulatorMachineInstance');
{$ifend}
 Priority:=TThreadPriority.tpHighest;
 SetExceptionMask([exInvalidOp,exDenormalized,exZeroDivide,exOverflow,exUnderflow,exPrecision]);
 Boot;
 fMachine.Run;
end;

procedure TpvPasRISCVEmulatorMachineInstance.ResetFrameBuffer;
begin
 fFrameBufferReadIndex:=0;
 fFrameBufferWriteIndex:=0;
end;

procedure TpvPasRISCVEmulatorMachineInstance.Boot;
var Stream:TStream;
    VirtIOBlockFile,NVMeFile:TpvRawByteString;
begin

 PreBoot;

 fMachine.Reset;

 VirtIOBlockFile:=GetVirtIOBlockImageFileName;
 if assigned(fMachine.VirtIOBlockDevice) then begin
  if FileExists(VirtIOBlockFile) then begin
   Stream:=TPasRISCVFileMappedStream.Create(VirtIOBlockFile,fmOpenReadWrite,true);
   if assigned(Stream) then begin
    try
     fMachine.VirtIOBlockDevice.AttachStream(Stream);
    except
     FreeAndNil(Stream);
    end;
   end;
  end else if FileExists(IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(pvApplication.Assets.BasePath)+'riscv')+VirtIOBlockFile) then begin
   Stream:=TPasRISCVFileMappedStream.Create(IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(pvApplication.Assets.BasePath)+'riscv')+VirtIOBlockFile,fmOpenReadWrite,true);
   if assigned(Stream) then begin
    try
     fMachine.VirtIOBlockDevice.AttachStream(Stream);
    except
     FreeAndNil(Stream);
    end;
   end;
  end else if pvApplication.Assets.ExistAsset('riscv/'+VirtIOBlockFile) then begin
   Stream:=pvApplication.Assets.GetAssetStream('riscv/'+VirtIOBlockFile);
   if assigned(Stream) then begin
    try
     fMachine.VirtIOBlockDevice.LoadFromStream(Stream);
    finally
     FreeAndNil(Stream);
    end;
   end;
  end;
 end;

 NVMeFile:=GetNVMeImageFileName;
 if assigned(fMachine.NVMeDevice) then begin
  if FileExists(NVMeFile) then begin
   Stream:=TPasRISCVFileMappedStream.Create(NVMeFile,fmOpenReadWrite,true);
   if assigned(Stream) then begin
    try
     fMachine.NVMeDevice.AttachStream(Stream);
    except
     FreeAndNil(Stream);
    end;
   end;
  end else if FileExists(IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(pvApplication.Assets.BasePath)+'riscv')+NVMeFile) then begin
   Stream:=TPasRISCVFileMappedStream.Create(IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(pvApplication.Assets.BasePath)+'riscv')+NVMeFile,fmOpenReadWrite,true);
   if assigned(Stream) then begin
    try
     fMachine.NVMeDevice.AttachStream(Stream);
    except
     FreeAndNil(Stream);
    end;
   end;
  end else if pvApplication.Assets.ExistAsset('riscv/'+NVMeFile) then begin
   Stream:=pvApplication.Assets.GetAssetStream('riscv/'+NVMeFile);
   if assigned(Stream) then begin
    try
     fMachine.NVMeDevice.LoadFromStream(Stream);
    finally
     FreeAndNil(Stream);
    end;
   end;
  end;
 end;

end;

procedure TpvPasRISCVEmulatorMachineInstance.OnReboot;
begin
 Boot;
end;

procedure TpvPasRISCVEmulatorMachineInstance.OnNewFrame;
var LocalReadIndex,LocalWriteIndex:TpvInt32;
    FrameBufferItem:PFrameBufferItem;
begin
 fMachine.FrameBufferDevice.Lock.AcquireRead;
 try
{$if not (defined(CPU386) or defined(CPUx86_64))}
  TPasMPMemoryBarrier.ReadWrite;
{$ifend}
  LocalReadIndex:=fFrameBufferReadIndex;
{$if defined(CPU386) or defined(CPUx86_64)}
  TPasMPMemoryBarrier.ReadDependency;
{$else}
  TPasMPMemoryBarrier.Read;
{$ifend}
  LocalWriteIndex:=(fFrameBufferWriteIndex+1) and 3;
  if LocalWriteIndex<>LocalReadIndex then begin
   FrameBufferItem:=@fFrameBufferItems[fFrameBufferWriteIndex];
   FrameBufferItem^.Width:=fMachine.FrameBufferDevice.Width;
   FrameBufferItem^.Height:=fMachine.FrameBufferDevice.Height;
   FrameBufferItem^.Active:=fMachine.FrameBufferDevice.Active;
   if fMachine.FrameBufferDevice.Active then begin
    Move(fMachine.FrameBufferDevice.OutputData[0],FrameBufferItem^.Data[0],FrameBufferItem^.Width*FrameBufferItem^.Height*SizeOf(TpvUInt32));
   end else begin
    FillChar(FrameBufferItem^.Data[0],FrameBufferItem^.Width*FrameBufferItem^.Height*SizeOf(TpvUInt32),#0);
   end;
{$ifdef CPU386}
   asm
    mfence
   end;
{$else}
   TPasMPMemoryBarrier.ReadWrite;
{$endif}
   fFrameBufferWriteIndex:=LocalWriteIndex;
  end;
 finally
  fMachine.FrameBufferDevice.Lock.ReleaseRead;
 end;
end;

{$ifdef PasRISCVVirtIOGPUVulkanVenus}
procedure TpvPasRISCVEmulatorMachineInstance.OnScanoutUpdate(const aScanoutID:TPasRISCVUInt32;const aPixels:Pointer;const aWidth,aHeight,aStride,aFormat:TPasRISCVUInt32);
var LocalReadIndex,LocalWriteIndex:TpvInt32;
    FrameBufferItem:PFrameBufferItem;
    SrcRow,DstRow:PByte;
    Row:TPasRISCVUInt32;
begin
 if aScanoutID=0 then begin
{$if not (defined(CPU386) or defined(CPUx86_64))}
  TPasMPMemoryBarrier.ReadWrite;
{$ifend}
  LocalReadIndex:=fFrameBufferReadIndex;
{$if defined(CPU386) or defined(CPUx86_64)}
  TPasMPMemoryBarrier.ReadDependency;
{$else}
  TPasMPMemoryBarrier.Read;
{$ifend}
  LocalWriteIndex:=(fFrameBufferWriteIndex+1) and 3;
  if LocalWriteIndex<>LocalReadIndex then begin
   FrameBufferItem:=@fFrameBufferItems[fFrameBufferWriteIndex];
   FrameBufferItem^.Width:=aWidth;
   FrameBufferItem^.Height:=aHeight;
   FrameBufferItem^.Active:=true;
   SrcRow:=aPixels;
   DstRow:=@FrameBufferItem^.Data[0];
   for Row:=0 to aHeight-1 do begin
    Move(SrcRow^,DstRow^,aWidth*SizeOf(TPasRISCVUInt32));
    inc(SrcRow,aStride);
    inc(DstRow,aWidth*SizeOf(TPasRISCVUInt32));
   end;
{$ifdef CPU386}
   asm
    mfence
   end;
{$else}
   TPasMPMemoryBarrier.ReadWrite;
{$endif}
   fFrameBufferWriteIndex:=LocalWriteIndex;
  end;
 end;
end;
{$endif}

function TpvPasRISCVEmulatorMachineInstance.TransferFrame(const aFrameBuffer:Pointer;out aActive:Boolean):boolean;
var LocalReadIndex,LocalWriteIndex,Count,Index:TpvInt32;
    FrameBufferItem:PFrameBufferItem;
    SrcPixel,DstPixel:PPasRISCVUInt32;
begin
{$if not (defined(CPU386) or defined(CPUx86_64))}
 TPasMPMemoryBarrier.ReadWrite;
{$ifend}
 LocalReadIndex:=fFrameBufferReadIndex;
{$if defined(CPU386) or defined(CPUx86_64)}
 TPasMPMemoryBarrier.ReadDependency;
{$else}
 TPasMPMemoryBarrier.Read;
{$ifend}
 LocalWriteIndex:=fFrameBufferWriteIndex;
 if LocalReadIndex<>LocalWriteIndex then begin
  if LocalWriteIndex>=LocalReadIndex then begin
   Count:=LocalWriteIndex-LocalReadIndex;
  end else begin
   Count:=(Length(fFrameBufferItems)-LocalReadIndex)+LocalWriteIndex;
  end;
  if Count>0 then begin
   if Count>1 then begin
    LocalReadIndex:=(LocalReadIndex+(Count-1)) and 3;
{$ifdef CPU386}
    asm
     mfence
    end;
{$else}
    TPasMPMemoryBarrier.ReadWrite;
{$endif}
    fFrameBufferReadIndex:=LocalReadIndex;
   end;
   FrameBufferItem:=@fFrameBufferItems[LocalReadIndex];
   aActive:=FrameBufferItem^.Active;
   if (FrameBufferItem^.Width=ScreenWidth) and (FrameBufferItem^.Height=ScreenHeight) then begin
    SrcPixel:=Pointer(@FrameBufferItem^.Data[0]);
    DstPixel:=Pointer(aFrameBuffer);
    for Index:=1 to FrameBufferItem^.Width*FrameBufferItem^.Height do begin
     DstPixel^:=SrcPixel^ or TPasRISCVUInt32($ff000000);
     inc(SrcPixel);
     inc(DstPixel);
    end;
   end else begin
    ResizeRGB32(@FrameBufferItem^.Data[0],FrameBufferItem^.Width,FrameBufferItem^.Height,
                aFrameBuffer,ScreenWidth,ScreenHeight,
                fXCacheIntegers);
   end;
{$ifdef CPU386}
   asm
    mfence
   end;
{$else}
   TPasMPMemoryBarrier.ReadWrite;
{$endif}
   fFrameBufferReadIndex:=(LocalReadIndex+1) and 3;
   result:=true;
  end else begin
   result:=false;
  end;
 end else begin
  result:=false;
 end;
end;

{ TpvPasRISCVEmulatorRenderer }

constructor TpvPasRISCVEmulatorRenderer.Create;
var Index:TpvSizeInt;
begin
 inherited Create;
 fVulkanDevice:=nil;
 fMachineInstance:=nil;
 fSelectedIndex:=-1;
 fReady:=false;
 fSerialConsoleMode:=false;
 fLastSerialConsoleMode:=not fSerialConsoleMode;
 fMouseButtons:=0;
 fLastGamepadValid:=false;
 fLastGamepadButtons:=0;
 for Index:=0 to length(fLastGamepadAxes)-1 do begin
  fLastGamepadAxes[Index]:=0;
 end;
 fFlags:=[TFlag.Centered,TFlag.Scaled,TFlag.ScaleToNearest];
 fTime:=0.48;
 fTerm:=TPasTerm.Create(80,25);
 fTerm.OnDrawBackground:=DrawBackground;
 fTerm.OnDrawCodePoint:=DrawCodePoint;
 fTerm.OnDrawCursor:=DrawCursor;
 DrawBackground(fTerm);
 fTerminalFrameBufferSnapshot:=TPasTerm.TFrameBufferSnapshot.Create(fTerm);
 fTerminalFrameBufferSnapshot.Update;
 fContentGeneration:=0;
 for Index:=0 to MaxInFlightFrames-1 do begin
  fRenderGeneration[Index]:=High(TpvUInt64);
 end;
 fTextureGeneration:=High(TpvUInt64);
end;

destructor TpvPasRISCVEmulatorRenderer.Destroy;
begin
 FreeAndNil(fTerminalFrameBufferSnapshot);
 FreeAndNil(fTerm);
 inherited Destroy;
end;

procedure TpvPasRISCVEmulatorRenderer.CreateVulkanResources(const aDevice:TpvVulkanDevice);
var Index:TpvSizeInt;
begin
 fVulkanDevice:=aDevice;
{$ifdef PasRISCVVirtIOGPUVulkanVenus}
 if assigned(fMachineInstance) and
    assigned(fMachineInstance.Machine) and
    assigned(fMachineInstance.Machine.VirtIOGPUDevice) then begin
  fMachineInstance.Machine.VirtIOGPUDevice.SetVulkanDevice(aDevice);
 end;
{$endif}

 fVulkanGraphicsCommandPool:=TpvVulkanCommandPool.Create(aDevice,
                                                         aDevice.GraphicsQueueFamilyIndex,
                                                         TVkCommandPoolCreateFlags(VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT));

 fVulkanGraphicsCommandBuffer:=TpvVulkanCommandBuffer.Create(fVulkanGraphicsCommandPool,VK_COMMAND_BUFFER_LEVEL_PRIMARY);

 fVulkanGraphicsCommandBufferFence:=TpvVulkanFence.Create(aDevice);

 fVulkanTransferCommandPool:=TpvVulkanCommandPool.Create(aDevice,
                                                         aDevice.TransferQueueFamilyIndex,
                                                         TVkCommandPoolCreateFlags(VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT));

 fVulkanTransferCommandBuffer:=TpvVulkanCommandBuffer.Create(fVulkanTransferCommandPool,VK_COMMAND_BUFFER_LEVEL_PRIMARY);

 fVulkanTransferCommandBufferFence:=TpvVulkanFence.Create(aDevice);

 fFrameBufferTextureSampler:=TpvVulkanSampler.Create(aDevice,
                                                     VK_FILTER_LINEAR,
                                                     VK_FILTER_LINEAR,
                                                     VK_SAMPLER_MIPMAP_MODE_LINEAR,
                                                     VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE,
                                                     VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE,
                                                     VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE,
                                                     0.0,
                                                     false,
                                                     0.0,
                                                     false,
                                                     VK_COMPARE_OP_ALWAYS,
                                                     0.0,
                                                     1000.0,
                                                     VK_BORDER_COLOR_INT_OPAQUE_BLACK,
                                                     false,
                                                     VK_SAMPLER_REDUCTION_MODE_WEIGHTED_AVERAGE);

 for Index:=0 to pvApplication.CountInFlightFrames-1 do begin
  fFrameBufferTextures[Index]:=TpvVulkanTexture.CreateSimple2DTarget(aDevice,
                                                                     aDevice.GraphicsQueue,
                                                                     fVulkanGraphicsCommandBuffer,
                                                                     fVulkanGraphicsCommandBufferFence,
                                                                     true,
                                                                     VK_FORMAT_R8G8B8A8_SRGB,
                                                                     VK_FORMAT_UNDEFINED,
                                                                     TpvPasRISCVEmulatorMachineInstance.ScreenWidth,
                                                                     TpvPasRISCVEmulatorMachineInstance.ScreenHeight,
                                                                     [TpvVulkanTextureUsageFlag.General,TpvVulkanTextureUsageFlag.Sampled,TpvVulkanTextureUsageFlag.TransferDst,TpvVulkanTextureUsageFlag.TransferSrc],
                                                                     VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                                                                     0,
                                                                     'TpvPasRISCVEmulatorRenderer.FrameBufferTextures['+IntToStr(Index)+']'
                                                                    );
  fFrameBufferTextures[Index].Sampler:=fFrameBufferTextureSampler;
  fFrameBufferTextures[Index].UpdateDescriptorImageInfo;
  fFrameBufferGenerations[Index]:=High(TpvUInt64);
  fFrameBufferTextureGenerations[Index]:=High(TpvUInt64);
  fFrameBufferTextureBuffers[Index]:=TpvVulkanBuffer.Create(aDevice,
                                                            SizeOf(TpvPasRISCVEmulatorMachineInstance.TFrameBuffer),
                                                            TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) or TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_SRC_BIT),
                                                            TVkSharingMode(VK_SHARING_MODE_EXCLUSIVE),
                                                            [],
                                                            0,
                                                            TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT) or TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT) or TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_COHERENT_BIT) or TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_CACHED_BIT),
                                                            0,
                                                            0,
                                                            0,
                                                            0,
                                                            0,
                                                            0,
                                                            [TpvVulkanBufferFlag.PersistentMappedIfPossible,TpvVulkanBufferFlag.PreferDedicatedAllocation],
                                                            0,
                                                            0,
                                                            'fFrameBufferTextureBuffers['+IntToStr(Index)+']');
 end;

 fFrameBufferGeneration:=0;

 fVulkanCanvas:=TpvCanvas.Create(aDevice,
                                 pvApplication.VulkanPipelineCache,
                                 MaxInFlightFrames);
end;

procedure TpvPasRISCVEmulatorRenderer.DestroyVulkanResources;
var Index:TpvSizeInt;
begin
 FreeAndNil(fVulkanCanvas);
 for Index:=0 to pvApplication.CountInFlightFrames-1 do begin
  FreeAndNil(fFrameBufferTextureBuffers[Index]);
  FreeAndNil(fFrameBufferTextures[Index]);
 end;
 FreeAndNil(fFrameBufferTextureSampler);
 FreeAndNil(fVulkanTransferCommandBufferFence);
 FreeAndNil(fVulkanTransferCommandBuffer);
 FreeAndNil(fVulkanTransferCommandPool);
 FreeAndNil(fVulkanGraphicsCommandBufferFence);
 FreeAndNil(fVulkanGraphicsCommandBuffer);
 FreeAndNil(fVulkanGraphicsCommandPool);
{$ifdef PasRISCVVirtIOGPUVulkanVenus}
 if assigned(fMachineInstance) and
    assigned(fMachineInstance.Machine) and
    assigned(fMachineInstance.Machine.VirtIOGPUDevice) then begin
  fMachineInstance.Machine.VirtIOGPUDevice.SetVulkanDevice(nil);
 end;
{$endif}
 fVulkanDevice:=nil;
end;

procedure TpvPasRISCVEmulatorRenderer.SetMachineInstance(const aMachineInstance:TpvPasRISCVEmulatorMachineInstance);
begin
 fMachineInstance:=aMachineInstance;
{$ifdef PasRISCVVirtIOGPUVulkanVenus}
 if assigned(fVulkanDevice) and
    assigned(aMachineInstance) and
    assigned(aMachineInstance.Machine) and
    assigned(aMachineInstance.Machine.VirtIOGPUDevice) then begin
  aMachineInstance.Machine.VirtIOGPUDevice.SetVulkanDevice(fVulkanDevice);
 end;
{$endif}
end;

procedure TpvPasRISCVEmulatorRenderer.ShutdownMachineInstance;
begin
 if assigned(fMachineInstance) then begin
  fMachineInstance.Shutdown;
  FreeAndNil(fMachineInstance);
 end;
end;

procedure TpvPasRISCVEmulatorRenderer.DrawBackground(const aSender:TPasTerm);
var Index:TpvSizeInt;
begin
 for Index:=0 to (TpvPasRISCVEmulatorMachineInstance.ScreenWidth*TpvPasRISCVEmulatorMachineInstance.ScreenHeight)-1 do begin
  fSerialConsoleTerminalFrameBuffer[Index]:=TpvUInt32($ff000000);
 end;
end;

procedure TpvPasRISCVEmulatorRenderer.DrawCodePoint(const aSender:TPasTerm;const aCodePoint:TPasTerm.TFrameBufferCodePoint;const aColumn,aRow:TPasTermSizeInt);
var Page,CharIndex,Color:TpvUInt32;
    Font8Char:PVGAFont8Char;
    Font16Char:PVGAFont16Char;
    BaseX,BaseY,x,y,ox,oy:TpvInt32;
begin
 if aCodePoint.CodePoint<=$1ffff then begin
  Page:=VGAFontMapPageMap[aCodePoint.CodePoint shr 8];
  if Page<>0 then begin
   CharIndex:=VGAFontMapPages[Page-1,aCodePoint.CodePoint and $ff];
   if (CharIndex and TpvUInt32($03000000))<>0 then begin
    if (CharIndex and TpvUInt32($01000000))<>0 then begin
     Font8Char:=@VGAFont8Chars[CharIndex and TpvUInt32($00ffffff)];
     BaseX:=aColumn*8;
     BaseY:=aRow*16;
     if (BaseX>=0) and ((BaseX+8)<=TpvPasRISCVEmulatorMachineInstance.ScreenWidth) and (BaseY>=0) and ((BaseY+16)<=TpvPasRISCVEmulatorMachineInstance.ScreenHeight) then begin
      for y:=0 to 15 do begin
       oy:=BaseY+y;
       for x:=0 to 7 do begin
        ox:=BaseX+x;
        if (Font8Char^[y] and (1 shl x))<>0 then begin
         Color:=aCodePoint.ForegroundColor;
        end else begin
         Color:=aCodePoint.BackgroundColor;
        end;
        fSerialConsoleTerminalFrameBuffer[(oy*TpvPasRISCVEmulatorMachineInstance.ScreenWidth)+ox]:=Color or $ff000000;
       end;
      end;
     end;
    end else if (CharIndex and TpvUInt32($02000000))<>0 then begin
     Font16Char:=@VGAFont16Chars[CharIndex and TpvUInt32($00ffffff)];
     BaseX:=aColumn*8;
     BaseY:=aRow*16;
     if (BaseX>=0) and ((BaseX+16)<=TpvPasRISCVEmulatorMachineInstance.ScreenWidth) and (BaseY>=0) and ((BaseY+16)<=TpvPasRISCVEmulatorMachineInstance.ScreenHeight) then begin
      for y:=0 to 15 do begin
       oy:=BaseY+y;
       for x:=0 to 15 do begin
        ox:=BaseX+x;
        if (Font16Char^[y] and (1 shl x))<>0 then begin
         Color:=aCodePoint.ForegroundColor;
        end else begin
         Color:=aCodePoint.BackgroundColor;
        end;
        fSerialConsoleTerminalFrameBuffer[(oy*TpvPasRISCVEmulatorMachineInstance.ScreenWidth)+ox]:=Color or $ff000000;
       end;
      end;
     end;
    end;
   end else begin
    BaseX:=aColumn*8;
    BaseY:=aRow*16;
    if (BaseX>=0) and ((BaseX+8)<=TpvPasRISCVEmulatorMachineInstance.ScreenWidth) and (BaseY>=0) and ((BaseY+16)<=TpvPasRISCVEmulatorMachineInstance.ScreenHeight) then begin
     Color:=aCodePoint.BackgroundColor;
     for y:=0 to 15 do begin
      oy:=BaseY+y;
      for x:=0 to 7 do begin
       ox:=BaseX+x;
       fSerialConsoleTerminalFrameBuffer[(oy*TpvPasRISCVEmulatorMachineInstance.ScreenWidth)+ox]:=Color or $ff000000;
      end;
     end;
    end;
   end;
  end;
 end;
end;

procedure TpvPasRISCVEmulatorRenderer.DrawCursor(const aSender:TPasTerm;const aColumn,aRow:TPasTermSizeInt);
var CodePoint:TPasTerm.TFrameBufferCodePoint;
    t:TPasTermUInt32;
begin
 CodePoint:=aSender.GetCodePoint(aColumn,aRow,true);
 t:=CodePoint.ForegroundColor;
 CodePoint.ForegroundColor:=CodePoint.BackgroundColor;
 CodePoint.BackgroundColor:=t;
 DrawCodePoint(aSender,CodePoint,aColumn,aRow);
end;

function TpvPasRISCVEmulatorRenderer.HandleKeyEvent(const aKeyEvent:TpvApplicationInputKeyEvent):boolean;
 procedure Send(const u:TpvRawByteString);
 var c:AnsiChar;
 begin
  if length(u)>0 then begin
   for c in u do begin
    fMachineInstance.Machine.UARTDevice.InputQueue.Enqueue(c);
    fMachineInstance.Machine.UARTDevice.Notify;
   end;
   fMachineInstance.Machine.WakeUp;
  end;
 end;
var c:AnsiChar;
    u,m:TpvRawByteString;
    v:TPasTermUInt8;
begin
 result:=false;
 if not assigned(fMachineInstance) then begin
  exit;
 end;
 if (aKeyEvent.KeyModifiers*[TpvApplicationInputKeyModifier.ALT,TpvApplicationInputKeyModifier.CTRL,TpvApplicationInputKeyModifier.SHIFT])=[TpvApplicationInputKeyModifier.CTRL] then begin
  case aKeyEvent.KeyCode of
   KEYCODE_F12:begin
    case aKeyEvent.KeyEventType of
     TpvApplicationInputKeyEventType.Down:begin
      fSerialConsoleMode:=not fSerialConsoleMode;
     end;
     else begin
     end;
    end;
    result:=true;
    exit;
   end;
  end;
 end;
 if fSerialConsoleMode then begin
  case aKeyEvent.KeyEventType of
   TpvApplicationInputKeyEventType.Typed:begin
    v:=0;
    if TpvApplicationInputKeyModifier.SHIFT in aKeyEvent.KeyModifiers then begin
     v:=v or 1;
    end;
    if TpvApplicationInputKeyModifier.ALT in aKeyEvent.KeyModifiers then begin
     v:=v or 2;
    end;
    if TpvApplicationInputKeyModifier.CTRL in aKeyEvent.KeyModifiers then begin
     v:=v or 4;
    end;
    if TpvApplicationInputKeyModifier.META in aKeyEvent.KeyModifiers then begin
     v:=v or 8;
    end;
    if v<>0 then begin
     m:=IntToStr(v+1);
    end else begin
     m:='';
    end;
    case aKeyEvent.KeyCode of
     KEYCODE_UP:begin
      if length(m)>0 then begin
       if m='3' then begin m:='5'; end;
       Send(#$1b'[1;'+m+'A');
      end else if TpvApplicationInputKeyModifier.SHIFT in aKeyEvent.KeyModifiers then begin
       Send(#$1b'OA');
      end else if TpvApplicationInputKeyModifier.CTRL in aKeyEvent.KeyModifiers then begin
       Send(#$1b'OA');
      end else begin
       Send(#$1b'[A');
      end;
     end;
     KEYCODE_DOWN:begin
      if length(m)>0 then begin
       if m='3' then begin m:='5'; end;
       Send(#$1b'[1;'+m+'B');
      end else if TpvApplicationInputKeyModifier.SHIFT in aKeyEvent.KeyModifiers then begin
       Send(#$1b'OB');
      end else if TpvApplicationInputKeyModifier.CTRL in aKeyEvent.KeyModifiers then begin
       Send(#$1b'OB');
      end else begin
       Send(#$1b'[B');
      end;
     end;
     KEYCODE_RIGHT:begin
      if length(m)>0 then begin
       if m='3' then begin m:='5'; end;
       Send(#$1b'[1;'+m+'C');
      end else if TpvApplicationInputKeyModifier.SHIFT in aKeyEvent.KeyModifiers then begin
       Send(#$1b'OC');
      end else if TpvApplicationInputKeyModifier.CTRL in aKeyEvent.KeyModifiers then begin
       Send(#$1b'OC');
      end else begin
       Send(#$1b'[C');
      end;
     end;
     KEYCODE_LEFT:begin
      if length(m)>0 then begin
       if m='3' then begin m:='5'; end;
       Send(#$1b'[1;'+m+'D');
      end else if TpvApplicationInputKeyModifier.SHIFT in aKeyEvent.KeyModifiers then begin
       Send(#$1b'OD');
      end else if TpvApplicationInputKeyModifier.CTRL in aKeyEvent.KeyModifiers then begin
       Send(#$1b'OD');
      end else begin
       Send(#$1b'[D');
      end;
     end;
     KEYCODE_HOME:begin
      if length(m)>0 then begin
       Send(#$1b'[1;'+m+'~');
      end else begin
       Send(#$1b'[1~');
      end;
     end;
     KEYCODE_END:begin
      if length(m)>0 then begin
       Send(#$1b'[4;'+m+'~');
      end else begin
       Send(#$1b'[4~');
      end;
     end;
     KEYCODE_PAGEDOWN:begin
      if length(m)>0 then begin
       Send(#$1b'[6;'+m+'~');
      end else begin
       Send(#$1b'[6~');
      end;
     end;
     KEYCODE_PAGEUP:begin
      if length(m)>0 then begin
       Send(#$1b'[5;'+m+'~');
      end else begin
       Send(#$1b'[5~');
      end;
     end;
     KEYCODE_F1:begin
      if length(m)>0 then begin Send(#$1b'[1;'+m+'P'); end else begin Send(#$1b'[[A'); end;
     end;
     KEYCODE_F2:begin
      if length(m)>0 then begin Send(#$1b'[1;'+m+'Q'); end else begin Send(#$1b'[[B'); end;
     end;
     KEYCODE_F3:begin
      if length(m)>0 then begin Send(#$1b'[1;'+m+'R'); end else begin Send(#$1b'[[C'); end;
     end;
     KEYCODE_F4:begin
      if length(m)>0 then begin Send(#$1b'[1;'+m+'S'); end else begin Send(#$1b'[[D'); end;
     end;
     KEYCODE_F5:begin
      if length(m)>0 then begin Send(#$1b'[15;'+m+'~'); end else begin Send(#$1b'[[E'); end;
     end;
     KEYCODE_F6:begin
      if length(m)>0 then begin Send(#$1b'[17;'+m+'~'); end else begin Send(#$1b'[17~'); end;
     end;
     KEYCODE_F7:begin
      if length(m)>0 then begin Send(#$1b'[18;'+m+'~'); end else begin Send(#$1b'[18~'); end;
     end;
     KEYCODE_F8:begin
      if length(m)>0 then begin Send(#$1b'[19;'+m+'~'); end else begin Send(#$1b'[19~'); end;
     end;
     KEYCODE_F9:begin
      if length(m)>0 then begin Send(#$1b'[20;'+m+'~'); end else begin Send(#$1b'[20~'); end;
     end;
     KEYCODE_F10:begin
      if length(m)>0 then begin Send(#$1b'[21;'+m+'~'); end else begin Send(#$1b'[21~'); end;
     end;
     KEYCODE_F11:begin
      if length(m)>0 then begin Send(#$1b'[23;'+m+'~'); end else begin Send(#$1b'[23~'); end;
     end;
     KEYCODE_F12:begin
      if length(m)>0 then begin Send(#$1b'[24;'+m+'~'); end else begin Send(#$1b'[24~'); end;
     end;
     KEYCODE_TAB:begin
      if TpvApplicationInputKeyModifier.SHIFT in aKeyEvent.KeyModifiers then begin
       Send(#$1b'[Z');
      end else begin
       Send(#9);
      end;
     end;
     KEYCODE_BACKSPACE:begin
      if TpvApplicationInputKeyModifier.SHIFT in aKeyEvent.KeyModifiers then begin
       Send(#$7f);
      end else if TpvApplicationInputKeyModifier.CTRL in aKeyEvent.KeyModifiers then begin
       Send(#$8);
      end else begin
       Send(#$7f);
      end;
     end;
     KEYCODE_KP_ENTER,
     KEYCODE_RETURN:begin
      if TpvApplicationInputKeyModifier.ALT in aKeyEvent.KeyModifiers then begin
       Send(#$1b#10);
      end else begin
       Send(#10);
      end;
     end;
     KEYCODE_ESCAPE:begin
      if TpvApplicationInputKeyModifier.ALT in aKeyEvent.KeyModifiers then begin
       Send(#$1b);
      end else begin
       Send(#$1b#$1b);
      end;
     end;
     KEYCODE_DELETE:begin
      if length(m)>0 then begin
       Send(#$1b'[3;'+m+'~');
      end else begin
       Send(#$1b'[3~');
      end;
     end;
     KEYCODE_INSERT:begin
      if length(m)>0 then begin
       Send(#$1b'[2;'+m+'~');
      end else begin
       Send(#$1b'[2~');
      end;
     end;
     KEYCODE_A..KEYCODE_Z:begin
      if TpvApplicationInputKeyModifier.CTRL in aKeyEvent.KeyModifiers then begin
       Send(Chr((aKeyEvent.KeyCode-KEYCODE_A)+1));
      end;
     end;
    end;
   end;
   TpvApplicationInputKeyEventType.Unicode:begin
    if (TpvApplicationInputKeyModifier.CTRL in aKeyEvent.KeyModifiers) and
       (((aKeyEvent.KeyCode>=ord('a')) or (aKeyEvent.KeyCode<=ord('z'))) or
        ((aKeyEvent.KeyCode>=ord('A')) or (aKeyEvent.KeyCode<=ord('Z'))) or
        (aKeyEvent.KeyCode=ord('@'))) then begin
    end else begin
     Send(PUCUUTF32CharToUTF8(aKeyEvent.KeyCode));
    end;
   end;
   TpvApplicationInputKeyEventType.Down:begin
    fMachineInstance.Machine.RawKeyboardDevice.KeyDown(aKeyEvent.ScanCode);
   end;
   TpvApplicationInputKeyEventType.Up:begin
    fMachineInstance.Machine.RawKeyboardDevice.KeyUp(aKeyEvent.ScanCode);
   end;
  end;
 end else begin
  if not fMachineInstance.Machine.FrameBufferDevice.AutomaticRefresh then begin
   case aKeyEvent.KeyEventType of
    TpvApplicationInputKeyEventType.Down:begin
     fMachineInstance.Machine.RawKeyboardDevice.KeyDown(aKeyEvent.ScanCode);
    end;
    TpvApplicationInputKeyEventType.Up:begin
     fMachineInstance.Machine.RawKeyboardDevice.KeyUp(aKeyEvent.ScanCode);
    end;
    else begin
    end;
   end;
  end;
  case aKeyEvent.KeyEventType of
   TpvApplicationInputKeyEventType.Down,
   TpvApplicationInputKeyEventType.Up:begin
    if assigned(fMachineInstance.Machine.I2CHIDKeyboardBusDevice) then begin
     fMachineInstance.Machine.I2CHIDKeyboardBusDevice.HandleKeyboard(MapKeyCodeToHIDKeyCode(aKeyEvent.ScanCode),aKeyEvent.KeyEventType=TpvApplicationInputKeyEventType.Down);
    end;
    if assigned(fMachineInstance.Machine.PS2KeyboardDevice) then begin
     fMachineInstance.Machine.PS2KeyboardDevice.HandleKeyboard(MapKeyCodeToHIDKeyCode(aKeyEvent.ScanCode),aKeyEvent.KeyEventType=TpvApplicationInputKeyEventType.Down);
    end;
    if assigned(fMachineInstance.Machine.VirtIOInputKeyboardDevice) then begin
     fMachineInstance.Machine.VirtIOInputKeyboardDevice.HandleKeyboard(MapKeyCodeToEVDEVKeyCode(aKeyEvent.ScanCode),aKeyEvent.KeyEventType=TpvApplicationInputKeyEventType.Down);
    end;
   end;
   else begin
   end;
  end;
 end;
 result:=true;
end;

function TpvPasRISCVEmulatorRenderer.HandlePointerEvent(const aPointerEvent:TpvApplicationInputPointerEvent):boolean;
var Index:TpvInt32;
    cy:TpvFloat;
    Scale:TpvFloat;
    OffsetX:TpvFloat;
    OffsetY:TpvFloat;
    CanvasWidth:TpvFloat;
    CanvasHeight:TpvFloat;
begin
 result:=false;
 if fReady then begin
  if fSerialConsoleMode then begin
   case aPointerEvent.PointerEventType of
    TpvApplicationInputPointerEventType.Down:begin
    end;
    TpvApplicationInputPointerEventType.Up:begin
    end;
    TpvApplicationInputPointerEventType.Motion:begin
    end;
    TpvApplicationInputPointerEventType.Drag:begin
    end;
   end;
  end else begin
   CanvasWidth:=pvApplication.Width;
   CanvasHeight:=pvApplication.Height;
   if TFlag.Scaled in fFlags then begin
    if TFlag.ScaleToNearest in fFlags then begin
     if (CanvasWidth/CanvasHeight)<(TpvPasRISCVEmulatorMachineInstance.ScreenWidth/TpvPasRISCVEmulatorMachineInstance.ScreenHeight) then begin
      Scale:=Max(1.0,Floor(CanvasWidth/TpvPasRISCVEmulatorMachineInstance.ScreenWidth));
     end else begin
      Scale:=Max(1.0,Floor(CanvasHeight/TpvPasRISCVEmulatorMachineInstance.ScreenHeight));
     end;
    end else begin
     if (CanvasWidth/CanvasHeight)<(TpvPasRISCVEmulatorMachineInstance.ScreenWidth/TpvPasRISCVEmulatorMachineInstance.ScreenHeight) then begin
      Scale:=CanvasWidth/TpvPasRISCVEmulatorMachineInstance.ScreenWidth;
     end else begin
      Scale:=CanvasHeight/TpvPasRISCVEmulatorMachineInstance.ScreenHeight;
     end;
    end;
   end else begin
    Scale:=1.0;
   end;
   if TFlag.Centered in fFlags then begin
    OffsetX:=(CanvasWidth-(TpvPasRISCVEmulatorMachineInstance.ScreenWidth*Scale))*0.5;
    OffsetY:=(CanvasHeight-(TpvPasRISCVEmulatorMachineInstance.ScreenHeight*Scale))*0.5;
    if TFlag.CenterToNearestPixel in fFlags then begin
     OffsetX:=Round(OffsetX);
     OffsetY:=Round(OffsetY);
    end;
   end else begin
    OffsetX:=0.0;
    OffsetY:=0.0;
   end;
   if assigned(fMachineInstance.Machine.PS2MouseDevice) then begin
    if (aPointerEvent.RelativePosition.x<>0) or (aPointerEvent.RelativePosition.y<>0) then begin
     fMachineInstance.Machine.PS2MouseDevice.RelativeMove(round(aPointerEvent.RelativePosition.x/Scale),round(aPointerEvent.RelativePosition.y/Scale));
    end;
    case aPointerEvent.PointerEventType of
     TpvApplicationInputPointerEventType.Down:begin
      case aPointerEvent.Button of
       TpvApplicationInputPointerButton.Left:begin
        fMachineInstance.Machine.PS2MouseDevice.ButtonPress(TPasRISCV.TPS2MouseDevice.BTN_LEFT);
       end;
       TpvApplicationInputPointerButton.Right:begin
        fMachineInstance.Machine.PS2MouseDevice.ButtonPress(TPasRISCV.TPS2MouseDevice.BTN_RIGHT);
       end;
       TpvApplicationInputPointerButton.Middle:begin
        fMachineInstance.Machine.PS2MouseDevice.ButtonPress(TPasRISCV.TPS2MouseDevice.BTN_MIDDLE);
       end;
       else begin
       end;
      end;
     end;
     TpvApplicationInputPointerEventType.Up:begin
      case aPointerEvent.Button of
       TpvApplicationInputPointerButton.Left:begin
        fMachineInstance.Machine.PS2MouseDevice.ButtonRelease(TPasRISCV.TPS2MouseDevice.BTN_LEFT);
       end;
       TpvApplicationInputPointerButton.Right:begin
        fMachineInstance.Machine.PS2MouseDevice.ButtonRelease(TPasRISCV.TPS2MouseDevice.BTN_RIGHT);
       end;
       TpvApplicationInputPointerButton.Middle:begin
        fMachineInstance.Machine.PS2MouseDevice.ButtonRelease(TPasRISCV.TPS2MouseDevice.BTN_MIDDLE);
       end;
       else begin
       end;
      end;
     end;
     TpvApplicationInputPointerEventType.Motion:begin
     end;
     else begin
     end;
    end;
   end;
   case aPointerEvent.PointerEventType of
    TpvApplicationInputPointerEventType.Down,
    TpvApplicationInputPointerEventType.Up,
    TpvApplicationInputPointerEventType.Motion:begin
     case aPointerEvent.PointerEventType of
      TpvApplicationInputPointerEventType.Down:begin
       case aPointerEvent.Button of
        TpvApplicationInputPointerButton.Left:begin
         fMouseButtons:=fMouseButtons or 1;
        end;
        TpvApplicationInputPointerButton.Right:begin
         fMouseButtons:=fMouseButtons or 2;
        end;
        TpvApplicationInputPointerButton.Middle:begin
         fMouseButtons:=fMouseButtons or 4;
        end;
        else begin
        end;
       end;
      end;
      TpvApplicationInputPointerEventType.Up:begin
       case aPointerEvent.Button of
        TpvApplicationInputPointerButton.Left:begin
         fMouseButtons:=fMouseButtons and not 1;
        end;
        TpvApplicationInputPointerButton.Right:begin
         fMouseButtons:=fMouseButtons and not 2;
        end;
        TpvApplicationInputPointerButton.Middle:begin
         fMouseButtons:=fMouseButtons and not 4;
        end;
        else begin
        end;
       end;
      end;
     end;
     if assigned(fMachineInstance.Machine.VirtIOInputTabletDevice) then begin
      fMachineInstance.Machine.VirtIOInputTabletDevice.HandleMouse(round(((aPointerEvent.Position.x-OffsetX)/(TpvPasRISCVEmulatorMachineInstance.ScreenWidth*Scale))*32767),round(((aPointerEvent.Position.y-OffsetY)/(TpvPasRISCVEmulatorMachineInstance.ScreenHeight*Scale))*32767),0,fMouseButtons);
     end else if assigned(fMachineInstance.Machine.VirtIOInputMouseDevice) then begin
      fMachineInstance.Machine.VirtIOInputMouseDevice.HandleMouse(round(aPointerEvent.RelativePosition.x/Scale),round(aPointerEvent.RelativePosition.y/Scale),0,fMouseButtons);
     end;
    end;
    TpvApplicationInputPointerEventType.Drag:begin
    end;
   end;
  end;
 end;
end;

function TpvPasRISCVEmulatorRenderer.HandleScrolled(const aRelativeAmount:TpvVector2):boolean;
begin
 result:=false;
 if not assigned(fMachineInstance) then begin
  exit;
 end;
if fReady and not fSerialConsoleMode then begin
  if assigned(fMachineInstance.Machine.PS2MouseDevice) then begin
   fMachineInstance.Machine.PS2MouseDevice.Scroll(round(aRelativeAmount.x+aRelativeAmount.y));
  end;
  if assigned(fMachineInstance.Machine.VirtIOInputMouseDevice) then begin
   fMachineInstance.Machine.VirtIOInputMouseDevice.HandleMouse(0,0,round(aRelativeAmount.x+aRelativeAmount.y),fMouseButtons);
  end;
 end;
end;

procedure TpvPasRISCVEmulatorRenderer.UpdateGameControllers;
var Index:TpvSizeInt;
    Joystick,SelectedJoystick:TpvApplicationJoystick;
    Device:TPasRISCV.TVirtIOInputGamepadDevice;
    Buttons:TpvUInt32;
    Axes:array[0..7] of TpvInt32;
    LeftTriggerValue,RightTriggerValue:TpvFloat;
    Changed:boolean;
 function ScaleStick(const aValue:TpvFloat):TpvInt32;
 begin
  result:=Round(aValue*TPasRISCV.TVirtIOInputDevice.GAMEPAD_ABS_MAX);
  if result<TPasRISCV.TVirtIOInputDevice.GAMEPAD_ABS_MIN then begin
   result:=TPasRISCV.TVirtIOInputDevice.GAMEPAD_ABS_MIN;
  end else if result>TPasRISCV.TVirtIOInputDevice.GAMEPAD_ABS_MAX then begin
   result:=TPasRISCV.TVirtIOInputDevice.GAMEPAD_ABS_MAX;
  end;
 end;
 function ScaleTrigger(const aValue:TpvFloat):TpvInt32;
 begin
  result:=Round(aValue*TPasRISCV.TVirtIOInputDevice.GAMEPAD_TRIGGER_MAX);
  if result<0 then begin
   result:=0;
  end else if result>TPasRISCV.TVirtIOInputDevice.GAMEPAD_TRIGGER_MAX then begin
   result:=TPasRISCV.TVirtIOInputDevice.GAMEPAD_TRIGGER_MAX;
  end;
 end;
 procedure SetButton(const aBit:TpvInt32;const aDown:boolean);
 begin
  if aDown then begin
   Buttons:=Buttons or (TpvUInt32(1) shl aBit);
  end;
 end;
begin

 if not (assigned(fMachineInstance) and assigned(fMachineInstance.Machine)) then begin
  exit;
 end;

 Device:=fMachineInstance.Machine.VirtIOInputGamepadDevice;
 if (not assigned(Device)) or fSerialConsoleMode or not fReady then begin
  exit;
 end;

 // Pick the first attached SDL game controller (well-defined button/axis layout)
 SelectedJoystick:=nil;
 for Index:=0 to pvApplication.Input.GetJoystickCount-1 do begin
  Joystick:=pvApplication.Input.GetJoystickByIndex(Index);
  if assigned(Joystick) and Joystick.IsGameController and Joystick.IsGameControllerAttached then begin
   SelectedJoystick:=Joystick;
   break;
  end;
 end;

 if not assigned(SelectedJoystick) then begin
  fLastGamepadValid:=false;
  exit;
 end;

 LeftTriggerValue:=SelectedJoystick.GetGameControllerAxis(GAME_CONTROLLER_AXIS_TRIGGERLEFT);
 RightTriggerValue:=SelectedJoystick.GetGameControllerAxis(GAME_CONTROLLER_AXIS_TRIGGERRIGHT);
 
// Axes: framework already normalizes to evdev convention (Y up = negative); sticks -1..1, triggers 0..1
 Axes[0]:=ScaleStick(SelectedJoystick.GetGameControllerAxis(GAME_CONTROLLER_AXIS_LEFTX));
 Axes[1]:=ScaleStick(SelectedJoystick.GetGameControllerAxis(GAME_CONTROLLER_AXIS_LEFTY));
 Axes[2]:=ScaleStick(SelectedJoystick.GetGameControllerAxis(GAME_CONTROLLER_AXIS_RIGHTX));
 Axes[3]:=ScaleStick(SelectedJoystick.GetGameControllerAxis(GAME_CONTROLLER_AXIS_RIGHTY));
 Axes[4]:=ScaleTrigger(LeftTriggerValue);
 Axes[5]:=ScaleTrigger(RightTriggerValue);
 
// D-pad -> hat axes (-1/0/1); evdev convention: down/right = +1
 Axes[6]:=(ord(SelectedJoystick.GetGameControllerButton(GAME_CONTROLLER_BUTTON_DPAD_RIGHT)) and 1)-
          (ord(SelectedJoystick.GetGameControllerButton(GAME_CONTROLLER_BUTTON_DPAD_LEFT)) and 1);
 Axes[7]:=(ord(SelectedJoystick.GetGameControllerButton(GAME_CONTROLLER_BUTTON_DPAD_DOWN)) and 1)-
          (ord(SelectedJoystick.GetGameControllerButton(GAME_CONTROLLER_BUTTON_DPAD_UP)) and 1);

 // Buttons in GamepadButtonList order: SOUTH,EAST,NORTH,WEST,TL,TR,TL2,TR2,SELECT,START,MODE,THUMBL,THUMBR
 Buttons:=0;
 SetButton(0,SelectedJoystick.GetGameControllerButton(GAME_CONTROLLER_BUTTON_A));
 SetButton(1,SelectedJoystick.GetGameControllerButton(GAME_CONTROLLER_BUTTON_B));
 SetButton(2,SelectedJoystick.GetGameControllerButton(GAME_CONTROLLER_BUTTON_X));
 SetButton(3,SelectedJoystick.GetGameControllerButton(GAME_CONTROLLER_BUTTON_Y));
 SetButton(4,SelectedJoystick.GetGameControllerButton(GAME_CONTROLLER_BUTTON_LEFTSHOULDER));
 SetButton(5,SelectedJoystick.GetGameControllerButton(GAME_CONTROLLER_BUTTON_RIGHTSHOULDER));
 SetButton(6,LeftTriggerValue>0.5);  // BTN_TL2 (digital left trigger)
 SetButton(7,RightTriggerValue>0.5); // BTN_TR2 (digital right trigger)
 SetButton(8,SelectedJoystick.GetGameControllerButton(GAME_CONTROLLER_BUTTON_BACK));
 SetButton(9,SelectedJoystick.GetGameControllerButton(GAME_CONTROLLER_BUTTON_START));
 SetButton(10,SelectedJoystick.GetGameControllerButton(GAME_CONTROLLER_BUTTON_GUIDE));
 SetButton(11,SelectedJoystick.GetGameControllerButton(GAME_CONTROLLER_BUTTON_LEFTSTICK));
 SetButton(12,SelectedJoystick.GetGameControllerButton(GAME_CONTROLLER_BUTTON_RIGHTSTICK));

 // HandleGamepad re-emits every axis on each call, so only forward on an actual state change
 // to avoid flooding the event queue with redundant SYN reports each frame.
 Changed:=(not fLastGamepadValid) or (Buttons<>fLastGamepadButtons);
 if not Changed then begin
  for Index:=0 to length(Axes)-1 do begin
   if Axes[Index]<>fLastGamepadAxes[Index] then begin
    Changed:=true;
    break;
   end;
  end;
 end;

 if Changed then begin
  Device.HandleGamepad(Axes[0],Axes[1],Axes[2],Axes[3],Axes[4],Axes[5],Axes[6],Axes[7],Buttons);
  fLastGamepadButtons:=Buttons;
  for Index:=0 to length(Axes)-1 do begin
   fLastGamepadAxes[Index]:=Axes[Index];
  end;
  fLastGamepadValid:=true;
 end;

end;

procedure TpvPasRISCVEmulatorRenderer.UpdateEmulatorState;
var Index:TpvSizeInt;
    IncomingChars:TpvInt32;
    Updated,FrameBufferActive,FrameBufferGenerationDirty:boolean;
    VSockTestProtocol:TpvPasRISCVEmulatorMachineInstance.TVSockTestProtocol;
begin
 UpdateGameControllers;


 if assigned(fMachineInstance) and
    assigned(fMachineInstance.Machine) and
    assigned(fMachineInstance.Machine.PS2KeyboardDevice) then begin
  fMachineInstance.Machine.PS2KeyboardDevice.Update;
 end;

 if assigned(fMachineInstance) and
    assigned(fMachineInstance.Machine) and
    assigned(fMachineInstance.Machine.FrameBufferDevice) and
    fMachineInstance.Machine.FrameBufferDevice.AutomaticRefresh and
    (fMachineInstance.NextFrameTime<=pvApplication.HighResolutionTimer.GetTime) then begin
  if fMachineInstance.Machine.FrameBufferDevice.CheckDirtyAndFlush then begin
   fMachineInstance.Machine.FrameBufferDevice.UpdateOutputData;
   fMachineInstance.OnNewFrame;
  end;
  fMachineInstance.NextFrameTime:=pvApplication.HighResolutionTimer.GetTime+(pvApplication.HighResolutionTimer.SecondInterval div 60);
 end;

 Updated:=false;
 FrameBufferGenerationDirty:=false;
 if assigned(fMachineInstance) then begin
  if fMachineInstance.TransferFrame(@fGraphicsFrameBuffer,FrameBufferActive) then begin
   if FrameBufferActive then begin
    FrameBufferGenerationDirty:=true;
   end else begin
    fTerm.Refresh;
   end;
  end;
  repeat
   IncomingChars:=fMachineInstance.Machine.UARTDevice.OutputRingBuffer.AvailableForRead;
   if IncomingChars>0 then begin
    IncomingChars:=fMachineInstance.Machine.UARTDevice.OutputRingBuffer.ReadAsMuchAsPossible(@fUARTOutputBuffer,Min(IncomingChars,SizeOf(fUARTOutputBuffer)));
    if IncomingChars>0 then begin
     system.write(copy(fUARTOutputBuffer,0,IncomingChars));
     fTerm.Write(@fUARTOutputBuffer,IncomingChars);
     Updated:=true;
    end;
   end else begin
    break;
   end;
  until false;
 end;
 if Updated then begin
  fTerminalFrameBufferSnapshot.Update;
  FrameBufferGenerationDirty:=true;
 end;
 if fLastSerialConsoleMode<>fSerialConsoleMode then begin
  fLastSerialConsoleMode:=fSerialConsoleMode;
  FrameBufferGenerationDirty:=true;
 end;
 if FrameBufferGenerationDirty then begin
  inc(fFrameBufferGeneration);
 end;
 if fFrameBufferGenerations[pvApplication.UpdateInFlightFrameIndex]<>fFrameBufferGeneration then begin
  fFrameBufferGenerations[pvApplication.UpdateInFlightFrameIndex]:=fFrameBufferGeneration;
  if fSerialConsoleMode then begin
   fFrameBuffers[pvApplication.UpdateInFlightFrameIndex]:=fSerialConsoleTerminalFrameBuffer;
  end else begin
   fFrameBuffers[pvApplication.UpdateInFlightFrameIndex]:=fGraphicsFrameBuffer;
  end;
  inc(fContentGeneration);
 end;

 if assigned(fMachineInstance.fActiveTestConnectionsLock) and
    assigned(fMachineInstance.fActiveTestConnections) then begin
  fMachineInstance.fActiveTestConnectionsLock.Acquire;
  try
   Index:=fMachineInstance.fActiveTestConnections.Count;
   while Index>0 do begin
    dec(Index);
    VSockTestProtocol:=fMachineInstance.fActiveTestConnections[Index];
    VSockTestProtocol.ProcessMessages;
   end;
  finally
   fMachineInstance.fActiveTestConnectionsLock.Release;
  end;
 end;

end;

procedure TpvPasRISCVEmulatorRenderer.RecordFrameBufferUpload(const aCommandBuffer:TpvVulkanCommandBuffer;const aInFlightFrameIndex:TpvSizeInt);
var MemoryBarrier:TVkMemoryBarrier;
    ImageMemoryBarrier:TVkImageMemoryBarrier;
    BufferImageCopy:TVkBufferImageCopy;
begin

 if fFrameBufferTextureGenerations[aInFlightFrameIndex]<>fFrameBufferGenerations[aInFlightFrameIndex] then begin
  fFrameBufferTextureGenerations[aInFlightFrameIndex]:=fFrameBufferGenerations[aInFlightFrameIndex];

  pvApplication.VulkanDevice.MemoryStaging.Upload(fVulkanDevice.TransferQueue,
                                                  fVulkanTransferCommandBuffer,
                                                  fVulkanTransferCommandBufferFence,
                                                  fFrameBuffers[aInFlightFrameIndex][0],
                                                  fFrameBufferTextureBuffers[aInFlightFrameIndex],
                                                  0,
                                                  SizeOf(TpvPasRISCVEmulatorMachineInstance.TFrameBuffer)
                                                 );

  fVulkanDevice.DebugUtils.CmdBufLabelBegin(aCommandBuffer,'ComputerCoreRenderCanvasUpload',[0.5,1.0,0.25,1.0]);

  FillChar(MemoryBarrier,SizeOf(TVkMemoryBarrier),#0);
  MemoryBarrier.sType:=VK_STRUCTURE_TYPE_MEMORY_BARRIER;
  MemoryBarrier.pNext:=nil;
  MemoryBarrier.srcAccessMask:=TVkAccessFlags(VK_ACCESS_MEMORY_WRITE_BIT);
  MemoryBarrier.dstAccessMask:=TVkAccessFlags(VK_ACCESS_TRANSFER_READ_BIT);
  fVulkanDevice.Commands.CmdPipelineBarrier(aCommandBuffer.Handle,
                                            TVkPipelineStageFlags(VK_PIPELINE_STAGE_TRANSFER_BIT),
                                            TVkPipelineStageFlags(VK_PIPELINE_STAGE_TRANSFER_BIT),
                                            0,
                                            1,
                                            @MemoryBarrier,
                                            0,
                                            nil,
                                            0,
                                            nil);

  // Transform from UNDEFINED to TRANSFER_DST_OPTIMAL
  FillChar(ImageMemoryBarrier,SizeOf(TVkImageMemoryBarrier),#0);
  ImageMemoryBarrier.sType:=VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
  ImageMemoryBarrier.pNext:=nil;
  ImageMemoryBarrier.srcAccessMask:=TVkAccessFlags(VK_ACCESS_MEMORY_WRITE_BIT);
  ImageMemoryBarrier.dstAccessMask:=TVkAccessFlags(VK_ACCESS_TRANSFER_WRITE_BIT);
  ImageMemoryBarrier.oldLayout:=TVkImageLayout(VK_IMAGE_LAYOUT_UNDEFINED);
  ImageMemoryBarrier.newLayout:=TVkImageLayout(VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL);
  ImageMemoryBarrier.srcQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
  ImageMemoryBarrier.dstQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
  ImageMemoryBarrier.image:=fFrameBufferTextures[aInFlightFrameIndex].Image.Handle;
  ImageMemoryBarrier.subresourceRange.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
  ImageMemoryBarrier.subresourceRange.baseMipLevel:=0;
  ImageMemoryBarrier.subresourceRange.levelCount:=1;
  ImageMemoryBarrier.subresourceRange.baseArrayLayer:=0;
  ImageMemoryBarrier.subresourceRange.layerCount:=1;
  fVulkanDevice.Commands.CmdPipelineBarrier(aCommandBuffer.Handle,
                                            TVkPipelineStageFlags(VK_PIPELINE_STAGE_HOST_BIT),
                                            TVkPipelineStageFlags(VK_PIPELINE_STAGE_TRANSFER_BIT),
                                            0,
                                            0,
                                            nil,
                                            0,
                                            nil,
                                            1,
                                            @ImageMemoryBarrier);

  // Copy from buffer to image
  FillChar(BufferImageCopy,SizeOf(TVkBufferImageCopy),#0);
  BufferImageCopy.bufferOffset:=0;
  BufferImageCopy.bufferRowLength:=0;
  BufferImageCopy.bufferImageHeight:=0;
  BufferImageCopy.imageSubresource.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
  BufferImageCopy.imageSubresource.mipLevel:=0;
  BufferImageCopy.imageSubresource.baseArrayLayer:=0;
  BufferImageCopy.imageSubresource.layerCount:=1;
  BufferImageCopy.imageOffset.x:=0;
  BufferImageCopy.imageOffset.y:=0;
  BufferImageCopy.imageOffset.z:=0;
  BufferImageCopy.imageExtent.width:=TpvPasRISCVEmulatorMachineInstance.ScreenWidth;
  BufferImageCopy.imageExtent.height:=TpvPasRISCVEmulatorMachineInstance.ScreenHeight;
  BufferImageCopy.imageExtent.depth:=1;
  if assigned(fVulkanDevice.BreadcrumbBuffer) then begin
   fVulkanDevice.BreadcrumbBuffer.BeginBreadcrumb(aCommandBuffer.Handle,TpvVulkanBreadcrumbType.CopyBuffer,'ComputerCoreCopyBufferToImage');
  end;
  fVulkanDevice.Commands.CmdCopyBufferToImage(aCommandBuffer.Handle,
                                              fFrameBufferTextureBuffers[aInFlightFrameIndex].Handle,
                                              fFrameBufferTextures[aInFlightFrameIndex].Image.Handle,
                                              TVkImageLayout(VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL),
                                              1,
                                              @BufferImageCopy);
  if assigned(fVulkanDevice.BreadcrumbBuffer) then begin
   fVulkanDevice.BreadcrumbBuffer.EndBreadcrumb(aCommandBuffer.Handle);
  end;

  // Transform from TRANSFER_DST_OPTIMAL to SHADER_READ_ONLY_OPTIMAL
  FillChar(ImageMemoryBarrier,SizeOf(TVkImageMemoryBarrier),#0);
  ImageMemoryBarrier.sType:=VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
  ImageMemoryBarrier.pNext:=nil;
  ImageMemoryBarrier.srcAccessMask:=TVkAccessFlags(VK_ACCESS_TRANSFER_WRITE_BIT);
  ImageMemoryBarrier.dstAccessMask:=TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT);
  ImageMemoryBarrier.oldLayout:=TVkImageLayout(VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL);
  ImageMemoryBarrier.newLayout:=TVkImageLayout(VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL);
  ImageMemoryBarrier.srcQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
  ImageMemoryBarrier.dstQueueFamilyIndex:=VK_QUEUE_FAMILY_IGNORED;
  ImageMemoryBarrier.image:=fFrameBufferTextures[aInFlightFrameIndex].Image.Handle;
  ImageMemoryBarrier.subresourceRange.aspectMask:=TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
  ImageMemoryBarrier.subresourceRange.baseMipLevel:=0;
  ImageMemoryBarrier.subresourceRange.levelCount:=1;
  ImageMemoryBarrier.subresourceRange.baseArrayLayer:=0;
  ImageMemoryBarrier.subresourceRange.layerCount:=1;
  fVulkanDevice.Commands.CmdPipelineBarrier(aCommandBuffer.Handle,
                                            TVkPipelineStageFlags(VK_PIPELINE_STAGE_TRANSFER_BIT),
                                            TVkPipelineStageFlags(VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT),
                                            0,
                                            0,
                                            nil,
                                            0,
                                            nil,
                                            1,
                                            @ImageMemoryBarrier);

  fVulkanDevice.DebugUtils.CmdBufLabelEnd(aCommandBuffer);

 end;

end;

procedure TpvPasRISCVEmulatorRenderer.RenderToCanvas(const aInFlightFrameIndex:TpvSizeInt;const aCanvasWidth,aCanvasHeight:TpvFloat);
var Scale:TpvFloat;
begin
 fVulkanCanvas.Start(aInFlightFrameIndex);

 if TFlag.Scaled in fFlags then begin
  if TFlag.ScaleToNearest in fFlags then begin
   if (aCanvasWidth/aCanvasHeight)<(TpvPasRISCVEmulatorMachineInstance.ScreenWidth/TpvPasRISCVEmulatorMachineInstance.ScreenHeight) then begin
    Scale:=Max(1.0,Floor(aCanvasWidth/TpvPasRISCVEmulatorMachineInstance.ScreenWidth));
   end else begin
    Scale:=Max(1.0,Floor(aCanvasHeight/TpvPasRISCVEmulatorMachineInstance.ScreenHeight));
   end;
  end else begin
   if (aCanvasWidth/aCanvasHeight)<(TpvPasRISCVEmulatorMachineInstance.ScreenWidth/TpvPasRISCVEmulatorMachineInstance.ScreenHeight) then begin
    Scale:=aCanvasWidth/TpvPasRISCVEmulatorMachineInstance.ScreenWidth;
   end else begin
    Scale:=aCanvasHeight/TpvPasRISCVEmulatorMachineInstance.ScreenHeight;
   end;
  end;
 end else begin
  Scale:=1.0;
 end;

 if TFlag.Centered in fFlags then begin
  if TFlag.CenterToNearestPixel in fFlags then begin
{  fVulkanCanvas.ViewMatrix:=TpvMatrix4x4.CreateTranslation(-TpvPasRISCVEmulatorMachineInstance.ScreenWidth*0.5,-TpvPasRISCVEmulatorMachineInstance.ScreenHeight*0.5,0.0)*
                             TpvMatrix4x4.CreateScale(Scale,Scale,1.0)*
                             TpvMatrix4x4.CreateTranslation(Round(aCanvasWidth*0.5),Round(aCanvasHeight*0.5),0.0);}
   fVulkanCanvas.ViewMatrix:=TpvMatrix4x4.CreateScale(Scale,Scale,1.0)*
                             TpvMatrix4x4.CreateTranslation(Round((aCanvasWidth-(TpvPasRISCVEmulatorMachineInstance.ScreenWidth*Scale))*0.5),
                                                            Round((aCanvasHeight-(TpvPasRISCVEmulatorMachineInstance.ScreenHeight*Scale))*0.5),
                                                            0.0);
  end else begin
   fVulkanCanvas.ViewMatrix:=TpvMatrix4x4.CreateTranslation(-TpvPasRISCVEmulatorMachineInstance.ScreenWidth*0.5,-TpvPasRISCVEmulatorMachineInstance.ScreenHeight*0.5,0.0)*
                             TpvMatrix4x4.CreateScale(Scale,Scale,1.0)*
                             TpvMatrix4x4.CreateTranslation(aCanvasWidth*0.5,aCanvasHeight*0.5,0);
  end;
 end else begin
  fVulkanCanvas.ViewMatrix:=TpvMatrix4x4.CreateScale(Scale,Scale,1.0);
 end;

 fVulkanCanvas.BlendingMode:=TpvCanvasBlendingMode.None;
 fVulkanCanvas.Color:=ConvertSRGBToLinear(TpvVector4.Create(1.0,1.0,1.0,1.0));
 fVulkanCanvas.DrawTexturedRectangle(fFrameBufferTextures[aInFlightFrameIndex],
                                     TpvRect.CreateAbsolute(0.0,0.0,TpvPasRISCVEmulatorMachineInstance.ScreenWidth,TpvPasRISCVEmulatorMachineInstance.ScreenHeight));

 fVulkanCanvas.Stop;
end;

function TpvPasRISCVEmulatorRenderer.GetFrameBufferTexture(const aIndex:TpvSizeInt):TpvVulkanTexture;
begin
 result:=fFrameBufferTextures[aIndex];
end;

function TpvPasRISCVEmulatorRenderer.GetFrameBufferTextureBuffer(const aIndex:TpvSizeInt):TpvVulkanBuffer;
begin
 result:=fFrameBufferTextureBuffers[aIndex];
end;

function TpvPasRISCVEmulatorRenderer.GetFrameBufferGenerationValue(const aIndex:TpvSizeInt):TpvUInt64;
begin
 result:=fFrameBufferGenerations[aIndex];
end;

function TpvPasRISCVEmulatorRenderer.GetFrameBufferTextureGeneration(const aIndex:TpvSizeInt):TpvUInt64;
begin
 result:=fFrameBufferTextureGenerations[aIndex];
end;

function TpvPasRISCVEmulatorRenderer.GetRenderGeneration(const aIndex:TpvSizeInt):TpvUInt64;
begin
 result:=fRenderGeneration[aIndex];
end;

procedure TpvPasRISCVEmulatorRenderer.SetRenderGeneration(const aIndex:TpvSizeInt;const aValue:TpvUInt64);
begin
 fRenderGeneration[aIndex]:=aValue;
end;

initialization
end.
