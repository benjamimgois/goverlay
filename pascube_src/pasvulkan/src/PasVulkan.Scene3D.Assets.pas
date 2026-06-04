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
unit PasVulkan.Scene3D.Assets;
{$i PasVulkan.inc}
{$ifndef fpc}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=24.0}
   {$legacyifend on}
  {$ifend}
 {$endif}
{$endif}
{$m+}
{$if defined(Win32) or defined(Win64)}
 {$define Windows}
{$ifend}

{$if defined(Windows) or defined(fpc)}
 {$define UseResources}
{$else}
 {$undef UseResources}
{$ifend}

interface

uses PasVulkan.Types,PasVulkan.Archive.SPK;

{$if defined(UseResources)}
function get_pasvulkan_scene3dshaders_spk_data:pointer;
function get_pasvulkan_scene3dshaders_spk_size:TpvUInt32;
{$else}
function get_pasvulkan_scene3dshaders_spk_data:pointer; cdecl; external name 'get_pasvulkan_scene3dshaders_spk_data';
function get_pasvulkan_scene3dshaders_spk_size:TpvUInt32; cdecl; external name 'get_pasvulkan_scene3dshaders_spk_size';
{$ifend}

implementation

{$if defined(UseResources)}

{$if defined(Windows)}
uses Windows;
{$else}
type HRSRC=TFPResourceHMODULE;
{$ifend}

{$r assets\shaders\scene3d\scene3dshaders.res}

var Scene3DShadersData:Pointer=nil;
    Scene3DShadersSize:TpvUInt32=0;

function get_pasvulkan_scene3dshaders_spk_data:pointer;
begin
 result:=Scene3DShadersData;
end;

function get_pasvulkan_scene3dshaders_spk_size:TpvUInt32;
begin
 result:=Scene3DShadersSize;
end;

procedure InitializeScene3DShaders;
var Resource:HRSRC;
    LoadedResource:HGLOBAL;
    DataSize:TpvUInt32;
    DataPointer:pointer;
begin
 Resource:=FindResource(HInstance,'SCENE3DSHADERS',RT_RCDATA);
 if Resource<>0 then begin
  DataSize:=SizeofResource(HInstance,Resource);
  if DataSize>0 then begin
   LoadedResource:=LoadResource(HInstance,Resource);
   if LoadedResource<>0 then begin
    DataPointer:=LockResource(LoadedResource);
    if assigned(DataPointer) then begin
     try 
      GetMem(Scene3DShadersData,DataSize);
      if assigned(Scene3DShadersData) then begin
       Move(DataPointer^,Scene3DShadersData^,DataSize);
       Scene3DShadersSize:=DataSize;
      end;
     finally 
      UnlockResource(LoadedResource);
     end; 
    end;
   end;
  end;
 end;
end;

procedure FinalizeScene3DShaders;
begin
 if assigned(Scene3DShadersData) then begin
  try
   FreeMem(Scene3DShadersData);
  finally 
   Scene3DShadersData:=nil;
  end; 
 end;
 Scene3DShadersSize:=0;
end; 

{$else}
{$if defined(Linux) and defined(cpu386)}
 {$l assets/shaders/scene3d/scene3dshaders_spk_x86_32_linux.o}
{$elseif defined(Linux) and (defined(cpuamd64) or defined(cpux86_64))}
 {$l assets/shaders/scene3d/scene3dshaders_spk_x86_64_linux.o}
{$elseif defined(Linux) and defined(cpuarm)}
 {$l assets/shaders/scene3d/scene3dshaders_spk_arm32_linux.o}
{$elseif defined(Linux) and defined(cpuaarch64)}
 {$l assets/shaders/scene3d/scene3dshaders_spk_aarch64_linux.o}
{$elseif defined(Windows) and defined(cpu386)}
 {$l assets/shaders/scene3d/scene3dshaders_spk_x86_32_windows.o}
{$elseif defined(Windows) and (defined(cpuamd64) or defined(cpux86_64))}
 {$l assets/shaders/scene3d/scene3dshaders_spk_x86_64_windows.o}
{$elseif defined(Windows) and defined(cpuaarch64)}
 {$l assets/shaders/scene3d/scene3dshaders_spk_aarch64_windows.o}
{$elseif defined(Android) and defined(cpuarm)}
 {$l assets/shaders/scene3d/scene3dshaders_spk_arm32_android.o}
{$elseif defined(Android) and defined(cpuaarch64)}
 {$l assets/shaders/scene3d/scene3dshaders_spk_aarch64_android.o}
{$elseif defined(Android) and defined(cpu386)}
 {$l assets/shaders/scene3d/scene3dshaders_spk_x86_32_android.o}
{$elseif defined(Android) and (defined(cpuamd64) or defined(cpux86_64))}
 {$l assets/shaders/scene3d/scene3dshaders_spk_x86_64_android.o}
{$ifend}
{$ifend}

initialization
{$if defined(UseResources)}
 InitializeScene3DShaders;
{$ifend}
finalization
{$if defined(UseResources)}
 FinalizeScene3DShaders;
{$ifend}
end.
