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
unit PasVulkan.Systems.Transform;
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
     PasVulkan.Utils;

type TpvSystemTransformVisitedBitmap=array of TpvUInt32;

     TpvSystemTransformStack=array of TpvEntityID;

     TpvSystemTransform=class(TpvSystem)
      private
       fDirty:boolean;
       fCountEntityIDs:TpvEntityID;
       fVisitedBitmap:TpvSystemTransformVisitedBitmap;
       fVisitedBitmapSize:TpvSizeInt;
       fStack:TpvSystemTransformStack;
       fComponentTransformDataWrapper:TpvComponentClassDataWrapper;
       fComponentTransformClassID:TpvComponentClassID;
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
     end;

implementation

uses PasVulkan.Components.Transform;

constructor TpvSystemTransform.Create(const aWorld:TpvWorld);
begin
 inherited Create(aWorld);

 AddRequiredComponent(TpvComponentTransform);

 fComponentTransformDataWrapper:=World.Components[TpvComponentTransform];
 fComponentTransformClassID:=World.Universe.RegisteredComponentClasses.ComponentIDs[TpvComponentTransform];

 fDirty:=true;

 fVisitedBitmap:=nil;
 fVisitedBitmapSize:=0;

 fStack:=nil;
 SetLength(fStack,32);

 Flags:=(Flags+[TpvSystem.TFlag.OwnUpdate])-
        [TpvSystem.TFlag.ParallelProcessing, // non-parallel processing due to possible parent/child relation
         TpvSystem.TFlag.Secluded];

end;

destructor TpvSystemTransform.Destroy;
begin
 SetLength(fVisitedBitmap,0);
 SetLength(fStack,0);
 inherited Destroy;
end;

procedure TpvSystemTransform.Added;
begin
 inherited Added;
end;

procedure TpvSystemTransform.Removed;
begin
 inherited Removed;
end;

function TpvSystemTransform.AddEntityToSystem(const aEntityID:TpvEntityID):boolean;
begin
 result:=inherited AddEntityToSystem(aEntityID);
 fDirty:=true;
end;

function TpvSystemTransform.RemoveEntityFromSystem(const aEntityID:TpvEntityID):boolean;
begin
 result:=inherited RemoveEntityFromSystem(aEntityID);
 fDirty:=true;
end;

procedure TpvSystemTransform.InitializeUpdate;
begin
 inherited InitializeUpdate;
end;

procedure TpvSystemTransform.Update;
var EntityIndex,StackPointer,CurrentEntityID:TpvSizeInt;
    EntityID:TpvEntityID;
    Entity,
    CurrentEntity,
    ParentEntity:TpvEntity;
    ComponentTransform,ParentComponentTransform:TpvComponentTransform;
    Matrix,OtherMatrix:TpvMatrix4x4;
begin
 if fDirty then begin
  fDirty:=false;
  fCountEntityIDs:=0;
  for EntityIndex:=0 to CountEntities-1 do begin
   EntityID:=EntityIDs[EntityIndex];
   if fCountEntityIDs<=EntityID then begin
    fCountEntityIDs:=EntityID+1;
   end;
  end;
  fVisitedBitmapSize:=(fCountEntityIDs+31) shr 5;
  if length(fVisitedBitmap)<fVisitedBitmapSize then begin
   SetLength(fVisitedBitmap,fVisitedBitmapSize*2);
  end;
 end;
 if fCountEntityIDs>0 then begin
  FillChar(fVisitedBitmap[0],fVisitedBitmapSize*SizeOf(TpvUInt32),#0);
  for EntityIndex:=0 to CountEntities-1 do begin
   EntityID:=EntityIDs[EntityIndex];
   if (fVisitedBitmap[EntityID shr 5] and (TpvUInt32(1) shl (EntityID and 31)))=0 then begin
    Entity:=Entities[EntityIndex];
    ComponentTransform:=TpvComponentTransform(Entity.ComponentByClassID[fComponentTransformClassID]);
    if ComponentTransform.Parent<0 then begin
     fVisitedBitmap[EntityID shr 5]:=fVisitedBitmap[EntityID shr 5] or (TpvUInt32(1) shl (EntityID and 31));
     Matrix:=TpvMatrix4x4.CreateFromQuaternion(ComponentTransform.RawRotation);
     Matrix.Right.xyz:=Matrix.Right.xyz*ComponentTransform.RawScale.x;
     Matrix.Up.xyz:=Matrix.Up.xyz*ComponentTransform.RawScale.y;
     Matrix.Forwards.xyz:=Matrix.Forwards.xyz*ComponentTransform.RawScale.z;
     Matrix.Translation.xyz:=ComponentTransform.RawPosition.xyz;
     ComponentTransform.RawMatrix:=Matrix;
    end else begin
     StackPointer:=0;
     if length(fStack)<(StackPointer+2) then begin
      SetLength(fStack,(StackPointer+2)*2);
     end;
     fStack[StackPointer]:=EntityID;
     inc(StackPointer);
     while StackPointer>0 do begin
      dec(StackPointer);
      CurrentEntityID:=fStack[StackPointer];
      if CurrentEntityID<0 then begin
       CurrentEntityID:=-(CurrentEntityID+1);
       CurrentEntity:=World.EntityByID[CurrentEntityID];
       if assigned(CurrentEntity) then begin
        ComponentTransform:=TpvComponentTransform(CurrentEntity.ComponentByClassID[fComponentTransformClassID]);
        if assigned(ComponentTransform) then begin
         if ComponentTransform.Parent>=0 then begin
          ParentEntity:=World.EntityByID[ComponentTransform.Parent];
          if assigned(ParentEntity) then begin
           ParentComponentTransform:=TpvComponentTransform(ParentEntity.ComponentByClassID[fComponentTransformClassID]);
          end else begin
           ParentComponentTransform:=nil;
          end;
         end else begin
          ParentComponentTransform:=nil;
         end;
         if assigned(ParentComponentTransform) and
            ((ComponentTransform.Flags*[TpvComponentTransformFlag.RelativePosition,TpvComponentTransformFlag.RelativeRotation,TpvComponentTransformFlag.RelativeScale])<>[]) then begin
          if (ComponentTransform.Flags*[TpvComponentTransformFlag.RelativePosition,TpvComponentTransformFlag.RelativeRotation,TpvComponentTransformFlag.RelativeScale])=[TpvComponentTransformFlag.RelativePosition,TpvComponentTransformFlag.RelativeRotation,TpvComponentTransformFlag.RelativeScale] then begin
           Matrix:=TpvMatrix4x4.CreateFromQuaternion(ComponentTransform.RawRotation);
           Matrix.Right.xyz:=Matrix.Right.xyz*ComponentTransform.RawScale.x;
           Matrix.Up.xyz:=Matrix.Up.xyz*ComponentTransform.RawScale.y;
           Matrix.Forwards.xyz:=Matrix.Forwards.xyz*ComponentTransform.RawScale.z;
           Matrix.Translation.xyz:=ComponentTransform.RawPosition.xyz;
           ComponentTransform.RawMatrix:=ParentComponentTransform.RawMatrix*Matrix;
          end else begin
           if TpvComponentTransformFlag.RelativeRotation in ComponentTransform.Flags then begin
            Matrix:=TpvMatrix4x4.CreateFromQuaternion(ComponentTransform.RawRotation);
           end else begin
            Matrix:=TpvMatrix4x4.Identity;
           end;
           if TpvComponentTransformFlag.RelativeScale in ComponentTransform.Flags then begin
            Matrix.Right.xyz:=Matrix.Right.xyz*ComponentTransform.RawScale.x;
            Matrix.Up.xyz:=Matrix.Up.xyz*ComponentTransform.RawScale.y;
            Matrix.Forwards.xyz:=Matrix.Forwards.xyz*ComponentTransform.RawScale.z;
           end;
           if TpvComponentTransformFlag.RelativePosition in ComponentTransform.Flags then begin
            Matrix.Translation.xyz:=ComponentTransform.RawPosition.xyz;
           end;
           Matrix:=ParentComponentTransform.RawMatrix*Matrix;
           if not (TpvComponentTransformFlag.RelativeRotation in ComponentTransform.Flags) then begin
            OtherMatrix:=TpvMatrix4x4.CreateFromQuaternion(ComponentTransform.RawRotation);
            Matrix.Right:=Matrix.Right.Length*OtherMatrix.Right.Normalize;
            Matrix.Up:=Matrix.Up.Length*OtherMatrix.Up.Normalize;
            Matrix.Forwards:=Matrix.Forwards.Length*OtherMatrix.Forwards.Normalize;
           end;
           if not (TpvComponentTransformFlag.RelativeScale in ComponentTransform.Flags) then begin
            Matrix.Right.xyz:=Matrix.Right.xyz.Normalize*ComponentTransform.RawScale.x;
            Matrix.Up.xyz:=Matrix.Up.xyz.Normalize*ComponentTransform.RawScale.y;
            Matrix.Forwards.xyz:=Matrix.Forwards.xyz.Normalize*ComponentTransform.RawScale.z;
           end;
           if not (TpvComponentTransformFlag.RelativePosition in ComponentTransform.Flags) then begin
            Matrix.Translation.xyz:=ComponentTransform.RawPosition.xyz;
           end;
           ComponentTransform.RawMatrix:=Matrix;
          end;
         end else begin
          Matrix:=TpvMatrix4x4.CreateFromQuaternion(ComponentTransform.RawRotation);
          Matrix.Right.xyz:=Matrix.Right.xyz*ComponentTransform.RawScale.x;
          Matrix.Up.xyz:=Matrix.Up.xyz*ComponentTransform.RawScale.y;
          Matrix.Forwards.xyz:=Matrix.Forwards.xyz*ComponentTransform.RawScale.z;
          Matrix.Translation.xyz:=ComponentTransform.RawPosition.xyz;
          ComponentTransform.RawMatrix:=Matrix;
         end;
        end;
       end;
      end else if (CurrentEntityID<fCountEntityIDs) and
                  ((fVisitedBitmap[CurrentEntityID shr 5] and (TpvUInt32(1) shl (CurrentEntityID and 31)))=0) then begin
       fVisitedBitmap[CurrentEntityID shr 5]:=fVisitedBitmap[CurrentEntityID shr 5] or (TpvUInt32(1) shl (CurrentEntityID and 31));
       if length(fStack)<(StackPointer+2) then begin
        SetLength(fStack,(StackPointer+2)*2);
       end;
       fStack[StackPointer]:=-(CurrentEntityID+1);
       inc(StackPointer);
       CurrentEntity:=World.EntityByID[CurrentEntityID];
       if assigned(CurrentEntity) then begin
        ComponentTransform:=TpvComponentTransform(CurrentEntity.ComponentByClassID[fComponentTransformClassID]);
        if assigned(ComponentTransform) and (ComponentTransform.Parent>=0) then begin
         fStack[StackPointer]:=ComponentTransform.Parent;
         inc(StackPointer);
        end;
       end;
      end;
     end;
    end;
   end;
  end;
 end;
end;

procedure TpvSystemTransform.FinalizeUpdate;
begin
 inherited FinalizeUpdate;
end;

end.

