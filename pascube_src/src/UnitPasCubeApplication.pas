unit UnitPasCubeApplication;
{$ifdef fpc}
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
{$ifend}

interface

uses SysUtils,
     Classes,
     Vulkan,
     PasVulkan.Types,
     PasVulkan.Math,
     PasVulkan.Framework,
     PasVulkan.Application,
{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
     PasVulkan.SDL2,
{$ifend}
     UnitPasCubeScreen,
     UnitTextOverlay;

type TPasCubeApplication=class(TpvApplication)
      private
       fTextOverlay:TTextOverlay;
       fDesiredX:TpvInt32;
       fDesiredY:TpvInt32;
       fHasDesiredPosition:boolean;
       fVersion:string;
      public
       constructor Create; override;
       destructor Destroy; override;
       procedure Setup; override;
       procedure Start; override;
       procedure Stop; override;
       procedure Load; override;
       procedure Unload; override;
       procedure AfterCreateSwapChain; override;
       procedure BeforeDestroySwapChain; override;
       procedure Update(const aDeltaTime:TpvDouble); override;
       procedure Draw(const aSwapChainImageIndex:TpvInt32;var aWaitSemaphore:TpvVulkanSemaphore;const aWaitFence:TpvVulkanFence=nil); override;
      published
       property TextOverlay:TTextOverlay read fTextOverlay;
       property Version:string read fVersion write fVersion;
      end;

var Application:TPasCubeApplication=nil;

implementation

{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
function SDL_GetWindowFromID(id:TSDLUInt32):PSDL_Window; cdecl; external {$if defined(Win32)}'sdl2.dll'{$elseif defined(Win64)}'sdl264.dll'{$elseif defined(Darwin)}'SDL2'{$else}'libSDL2.so'{$ifend};
{$ifend}

constructor TPasCubeApplication.Create;
begin
 inherited Create;
 Application:=self;
 fTextOverlay:=nil;
 fDesiredX:=0;
 fDesiredY:=0;
 fHasDesiredPosition:=false;
 fVersion:='1.8.0';
end;

destructor TPasCubeApplication.Destroy;
begin
 Application:=nil;
 inherited Destroy;
end;

procedure TPasCubeApplication.Setup;
var Index:TpvInt32;
    Arg:String;
    PosX,PosY:TpvInt32;
    HasX,HasY:boolean;
begin
 if Debugging then begin
  VulkanDebugging:=true;
  VulkanValidation:=true;
 end;
 PathName:='PasCube';
 StartScreen:=TPasCubeScreen;
 VisibleMouseCursor:=true;
 CatchMouse:=false;
 HideSystemBars:=true;
 AndroidSeparateMouseAndTouch:=true;
 UseAudio:=false;
 WaitOnPreviousFrames:=false;
 VulkanAPIVersion:=VK_API_VERSION_1_0;
 Blocking:=true;
 VulkanAPIVersion:=VK_API_VERSION_1_0;
 Blocking:=true;
  PresentMode:=TpvApplicationPresentMode.Immediate;
 Width:=1280;
 Height:=720;
 fTextOverlay:=TTextOverlay.Create;
 PosX:=0;
 PosY:=0;
 HasX:=false;
 HasY:=false;
 Index:=1;
 while Index<=ParamCount do begin
  Arg:=ParamStr(Index);
  if (Arg='--x') and (Index<ParamCount) then begin
   Inc(Index);
   PosX:=StrToIntDef(ParamStr(Index),0);
   HasX:=true;
  end else if (Arg='--y') and (Index<ParamCount) then begin
   Inc(Index);
   PosY:=StrToIntDef(ParamStr(Index),0);
   HasY:=true;
  end else if (Arg='--version') and (Index<ParamCount) then begin
   Inc(Index);
   fVersion:=ParamStr(Index);
  end;
  Inc(Index);
 end;
 Title:='PasCube';
 if HasX or HasY then begin
  fDesiredX:=PosX;
  fDesiredY:=PosY;
  fHasDesiredPosition:=true;
 end;
end;

procedure TPasCubeApplication.Start;
{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
var Win:PSDL_Window;
    WinID:TSDLUInt32;
{$ifend}
begin
 inherited Start;
{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
 if fHasDesiredPosition then begin
  Win:=nil;
  for WinID:=1 to 16 do begin
   Win:=SDL_GetWindowFromID(WinID);
   if assigned(Win) then begin
    break;
   end;
  end;
  if assigned(Win) then begin
   SDL_SetWindowPosition(Win,fDesiredX,fDesiredY);
  end;
 end;
{$ifend}
end;

procedure TPasCubeApplication.Stop;
begin
 inherited Stop;
end;

procedure TPasCubeApplication.Load;
begin
 inherited Load;
 if assigned(fTextOverlay) then begin
  fTextOverlay.Load;
 end;
end;

procedure TPasCubeApplication.Unload;
begin
 if assigned(fTextOverlay) then begin
  fTextOverlay.Unload;
 end;
 inherited Unload;
end;

procedure TPasCubeApplication.AfterCreateSwapChain;
begin
 inherited AfterCreateSwapChain;
 if assigned(fTextOverlay) then begin
  fTextOverlay.AfterCreateSwapChain;
 end;
end;

procedure TPasCubeApplication.BeforeDestroySwapChain;
begin
 if assigned(fTextOverlay) then begin
  fTextOverlay.BeforeDestroySwapChain;
 end;
 inherited BeforeDestroySwapChain;
end;

procedure TPasCubeApplication.Update(const aDeltaTime:TpvDouble);
begin
 if assigned(fTextOverlay) then begin
  fTextOverlay.PreUpdate(aDeltaTime);
 end;
 inherited Update(aDeltaTime);
 if assigned(fTextOverlay) then begin
  fTextOverlay.PostUpdate(aDeltaTime);
 end;
end;

procedure TPasCubeApplication.Draw(const aSwapChainImageIndex:TpvInt32;var aWaitSemaphore:TpvVulkanSemaphore;const aWaitFence:TpvVulkanFence=nil);
begin
 inherited Draw(aSwapChainImageIndex,aWaitSemaphore,aWaitFence);
 if assigned(fTextOverlay) then begin
  fTextOverlay.Draw(aSwapChainImageIndex,aWaitSemaphore,aWaitFence);
 end;
end;

end.
