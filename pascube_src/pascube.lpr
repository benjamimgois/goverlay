program pascube;
{$ifdef fpc}
 {$mode delphi}
{$else}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=24.0}
   {$legacyifend on}
  {$ifend}
 {$endif}
{$endif}
{$if defined(win32) or defined(win64)}
 {$if defined(Debug) or not defined(Release)}
  {$apptype console}
 {$else}
  {$apptype gui}
 {$ifend}
 {$define Windows}
{$ifend}

uses
  {$if defined(fpc) and defined(PasVulkanUseSynFPCx64MM)}
   SynFPCx64MM,
  {$ifend}
  {$if defined(fpc) and defined(PasVulkanUseCMEM)}
   cmem,
  {$ifend}
  {$if defined(fpc) and defined(Unix)}
   cthreads,
   BaseUnix,
  {$elseif defined(Windows)}
   {$ifdef PasVulkanUseFastMM4}
    FastMM4,
   {$endif} 
   Windows,
  {$ifend}
  SysUtils,
  Classes,
  Vulkan,
  PasVulkan.Types,
  PasVulkan.Android,
{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
  PasVulkan.SDL2,
{$ifend}
  PasVulkan.Framework,
  PasVulkan.Application,  
  UnitPasCubeApplication;

{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
procedure SDLMain;
begin
 TPasCubeApplication.Main;
end;
{$ifend}

begin
{$if defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless)}
 SDLMain;
{$else}
 TPasCubeApplication.Main;
{$ifend}
{$if defined(fpc) and defined(Linux)}
 // Workaround for a segv-exception-issue with closed-source NVidia drivers on Linux at program exit
 fpkill(fpgetpid,9);
{$ifend}
end.
