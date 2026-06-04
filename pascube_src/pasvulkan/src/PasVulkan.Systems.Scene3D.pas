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
unit PasVulkan.Systems.Scene3D;
{$i PasVulkan.inc}
{$ifndef fpc}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=24.0}
   {$legacyifend on}
  {$ifend}
 {$endif}
{$endif}
{$m+}

interface

uses SysUtils,Classes,
     PasVulkan.Types,
     PasVulkan.Math,
     PasVulkan.EntityComponentSystem.BaseComponents,
     PasVulkan.EntityComponentSystem,
     PasVulkan.Utils,
     PasVulkan.Scene3D;

type TpvSystemScene3D=class(TpvSystem)
      private
       fScene3D:TpvScene3D;
       fComponentScene3DDataWrapper:TpvComponentClassDataWrapper;
       fComponentScene3DClassID:TpvComponentClassID;
      public
       constructor Create(const aWorld:TpvWorld); override;
       destructor Destroy; override;
       procedure Added; override;
       procedure Removed; override;
       function AddEntityToSystem(const aEntityID:TpvEntityID):boolean; override;
       function RemoveEntityFromSystem(const aEntityID:TpvEntityID):boolean; override;
       procedure InitializeUpdate; override;
       procedure Update; override;
       procedure FinalizeUpdate; override;
      public
       property Scene3D:TpvScene3D read fScene3D write fScene3D;
     end;

implementation

uses PasVulkan.Components.Scene3D;

constructor TpvSystemScene3D.Create(const aWorld:TpvWorld);
begin
 inherited Create(aWorld);

 AddRequiredComponent(TpvComponentScene3D);

 fComponentScene3DDataWrapper:=World.Components[TpvComponentScene3D];
 fComponentScene3DClassID:=World.Universe.RegisteredComponentClasses.ComponentIDs[TpvComponentScene3D];

 Flags:=(Flags+[TpvSystem.TFlag.OwnUpdate])-
        [TpvSystem.TFlag.ParallelProcessing, // non-parallel processing due to possible parent/child relation
         TpvSystem.TFlag.Secluded];

 fScene3D:=nil;

end;

destructor TpvSystemScene3D.Destroy;
begin
 inherited Destroy;
end;

procedure TpvSystemScene3D.Added;
begin
 inherited Added;
end;

procedure TpvSystemScene3D.Removed;
begin
 inherited Removed;
end;

function TpvSystemScene3D.AddEntityToSystem(const aEntityID:TpvEntityID):boolean;
begin
 result:=inherited AddEntityToSystem(aEntityID);
end;

function TpvSystemScene3D.RemoveEntityFromSystem(const aEntityID:TpvEntityID):boolean;
begin
 result:=inherited RemoveEntityFromSystem(aEntityID);
end;

procedure TpvSystemScene3D.InitializeUpdate;
begin
 inherited InitializeUpdate;
end;

procedure TpvSystemScene3D.Update;
begin
end;

procedure TpvSystemScene3D.FinalizeUpdate;
begin
 inherited FinalizeUpdate;
end;

end.

