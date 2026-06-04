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
unit PasVulkan.Systems.Scene3DGroup;
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

uses SysUtils,Classes,PasMP,
     PasVulkan.Application,
     PasVulkan.Framework,
     PasVulkan.Types,
     PasVulkan.Math,
     PasVulkan.PooledObject,
     PasVulkan.EntityComponentSystem.BaseComponents,
     PasVulkan.EntityComponentSystem,
     PasVulkan.Utils;

type TpvSystemScene3DGroup=class;

     TpvSystemScene3DGroupEntityTransform=class
      private
       fMatrix:TpvMatrix4x4;
       fStatic:boolean;
      public
       constructor Create;
       destructor Destroy; override;
       procedure Assign(const aFrom:TpvSystemScene3DGroupEntityTransform); reintroduce;
       procedure InterpolateFrom(const aFromA,aFromB:TpvSystemScene3DGroupEntityTransform;const aStateInterpolation:TpvFloat);
       property Matrix:TpvMatrix4x4 read fMatrix write fMatrix;
       property Static:boolean read fStatic write fStatic;
     end;

     TpvSystemScene3DGroupEntity=class(TpvPooledObject)
      private
       fRenderer:TpvSystemScene3DGroup;
       fEntityID:TpvEntityID;
       fSeen:longbool;
       fDeleted:longbool;
       fTransform:TpvSystemScene3DGroupEntityTransform;
      public
       constructor Create(const aRenderer:TpvSystemScene3DGroup;const aEntityID:TpvEntityID);
       destructor Destroy; override;
       procedure Clear;
       procedure Assign(const aFrom:TpvSystemScene3DGroupEntity); reintroduce;
       procedure Interpolate(const aFromA,aFromB:TpvSystemScene3DGroupEntity;const aStateInterpolation:TpvFloat);
       property Render:TpvSystemScene3DGroup read fRenderer;
       property EntityID:TpvEntityID read fEntityID;
       property Seen:longbool read fSeen write fSeen;
       property Deleted:longbool read fDeleted write fDeleted;
     end;

     TpvSystemScene3DGroupEntityArray=array of TpvSystemScene3DGroupEntity;

     TpvSystemScene3DGroupEntities=class
      private
       fRenderer:TpvSystemScene3DGroup;
       fEntities:TpvSystemScene3DGroupEntityArray;
       fCriticalSection:TPasMPCriticalSection;
       function GetMaxEntityID:TpvEntityID;
       function GetEntity(const aEntityID:TpvEntityID):TpvSystemScene3DGroupEntity; inline;
       procedure SetEntity(const aEntityID:TpvEntityID;const aEntity:TpvSystemScene3DGroupEntity); inline;
      public
       constructor Create(const aRenderer:TpvSystemScene3DGroup);
       destructor Destroy; override;
       procedure Clear;
       property Entities[const pEntityID:TpvEntityID]:TpvSystemScene3DGroupEntity read GetEntity write SetEntity; default;
       property MaxEntityID:TpvEntityID read GetMaxEntityID;
     end;

     TpvSystemScene3DGroup=class(TpvSystem)
      private
       fPasMP:TPasMP;
//     fRenderer:TRenderer;
       fComponentTransformClassDataWrapper:TpvComponentClassDataWrapper;
       fComponentTransformClassID:TpvComponentClassID;
       fLastEntities:TpvSystemScene3DGroupEntities;
       fCurrentEntities:TpvSystemScene3DGroupEntities;
       fRenderableEntities:array[0..MaxInFlightFrames-1] of TpvSystemScene3DGroupEntities;
       fCurrentRenderableEntities:TpvSystemScene3DGroupEntities;
       fLastEntityIDs:TpvSystemEntityIDs;
       fCurrentEntityIDs:TpvSystemEntityIDs;
       fRenderableEntityIDs:array[0..MaxInFlightFrames-1] of TpvSystemEntityIDs;
       fLastRenderableEntityIDs:TpvSystemEntityIDs;
       fCurrentRenderableEntityIDs:TpvSystemEntityIDs;
       fStateInterpolation:TpvFloat;
       procedure FinalizeUpdateLastParallelForJobFunction(const aJob:PPasMPJob;const aThreadIndex:TPasMPInt32;const aData:pointer;const aFromIndex,aToIndex:TPasMPNativeInt);
       procedure FinalizeUpdateCurrentParallelForJobFunction(const aJob:PPasMPJob;const aThreadIndex:TPasMPInt32;const aData:pointer;const aFromIndex,aToIndex:TPasMPNativeInt);
       procedure PrepareRenderCurrentParallelForJobFunction(const aJob:PPasMPJob;const aThreadIndex:TPasMPInt32;const aData:pointer;const aFromIndex,aToIndex:TPasMPNativeInt);
       procedure PrepareRenderLastParallelForJobFunction(const aJob:PPasMPJob;const aThreadIndex:TPasMPInt32;const aData:pointer;const aFromIndex,aToIndex:TPasMPNativeInt);
      public
       constructor Create(const AWorld:TpvWorld); override;
       destructor Destroy; override;
       procedure Added; override;
       procedure Removed; override;
       function AddEntityToSystem(const aEntityID:TpvEntityID):boolean; override;
       function RemoveEntityFromSystem(const aEntityID:TpvEntityID):boolean; override;
       procedure ProcessEvent(const aEvent:TpvEvent); override;
       procedure InitializeUpdate; override;
       procedure UpdateEntities(const aFirstEntityIndex,aLastEntityIndex:TpvInt32); override;
       procedure FinalizeUpdate; override;
       procedure PrepareRender(const aPrepareInFlightFrameIndex:TpvInt32;const aStateInterpolation:TpvFloat);
       procedure Render(const aInFlightFrameIndex:TpvInt32);
     end;

implementation

uses PasVulkan.Components.Scene3DGroup,
     PasVulkan.Components.Transform;

constructor TpvSystemScene3DGroupEntityTransform.Create;
begin
 inherited Create;
end;

destructor TpvSystemScene3DGroupEntityTransform.Destroy;
begin
 inherited Destroy;
end;

procedure TpvSystemScene3DGroupEntityTransform.Assign(const aFrom:TpvSystemScene3DGroupEntityTransform);
begin
 fMatrix:=aFrom.fMatrix;
 fStatic:=aFrom.fStatic;
end;

procedure TpvSystemScene3DGroupEntityTransform.InterpolateFrom(const aFromA,aFromB:TpvSystemScene3DGroupEntityTransform;const aStateInterpolation:TpvFloat);
begin
 fMatrix:=aFromA.fMatrix.Slerp(aFromB.fMatrix,aStateInterpolation);
 fStatic:=aFromB.fStatic;
end;

constructor TpvSystemScene3DGroupEntity.Create(const aRenderer:TpvSystemScene3DGroup;const aEntityID:TpvEntityID);
begin
 inherited Create;
 fRenderer:=aRenderer;
 fEntityID:=aEntityID;
 fSeen:=true;
 fDeleted:=false;
 fTransform:=nil;
end;

destructor TpvSystemScene3DGroupEntity.Destroy;
begin
 fTransform.Free;
 inherited Destroy;
end;

procedure TpvSystemScene3DGroupEntity.Clear;
begin
 FreeAndNil(fTransform);
end;

procedure TpvSystemScene3DGroupEntity.Assign(const aFrom:TpvSystemScene3DGroupEntity);
begin
 begin
  if assigned(aFrom.fTransform) then begin
   if not assigned(fTransform) then begin
    fTransform:=TpvSystemScene3DGroupEntityTransform.Create;
   end;
   fTransform.Assign(aFrom.fTransform);
  end else if assigned(fTransform) then begin
   FreeAndNil(fTransform);
  end;
 end;
end;

procedure TpvSystemScene3DGroupEntity.Interpolate(const aFromA,aFromB:TpvSystemScene3DGroupEntity;const aStateInterpolation:TpvFloat);
begin
 begin
  if assigned(aFromB.fTransform) then begin
   if not assigned(fTransform) then begin
    fTransform:=TpvSystemScene3DGroupEntityTransform.Create;
   end;
   if assigned(aFromA.fTransform) and assigned(aFromB.fTransform) then begin
    fTransform.InterpolateFrom(aFromA.fTransform,aFromB.fTransform,aStateInterpolation);
   end else begin
    fTransform.Assign(aFromB.fTransform);
   end;
  end else if assigned(fTransform) then begin
   FreeAndNil(fTransform);
  end;
 end;
end;

constructor TpvSystemScene3DGroupEntities.Create(const aRenderer:TpvSystemScene3DGroup);
var Index:TpvInt32;
begin
 inherited Create;
 fRenderer:=aRenderer;
 fEntities:=nil;
 SetLength(fEntities,4096);
 for Index:=0 to length(fEntities)-1 do begin
  fEntities[Index]:=nil;
 end;
 fCriticalSection:=TPasMPCriticalSection.Create;
end;

destructor TpvSystemScene3DGroupEntities.Destroy;
begin
 Clear;
 SetLength(fEntities,0);
 fCriticalSection.Free;
 inherited Destroy;
end;

procedure TpvSystemScene3DGroupEntities.Clear;
var Index:TpvInt32;
begin
 for Index:=0 to length(fEntities)-1 do begin
  FreeAndNil(fEntities[Index]);
 end;
end;

function TpvSystemScene3DGroupEntities.GetMaxEntityID:TpvEntityID;
begin
 result:=length(fEntities)-1;
end;

function TpvSystemScene3DGroupEntities.GetEntity(const aEntityID:TpvEntityID):TpvSystemScene3DGroupEntity;
begin
 if (aEntityID>=0) and (aEntityID<length(fEntities)) then begin
  result:=fEntities[aEntityID];
 end else begin
  result:=nil;
 end;
end;

procedure TpvSystemScene3DGroupEntities.SetEntity(const aEntityID:TpvEntityID;const aEntity:TpvSystemScene3DGroupEntity);
var Index,Old:TpvInt32;
begin
 if aEntityID>=0 then begin
  if length(fEntities)<=aEntityID then begin
   fCriticalSection.Acquire;
   try
    Old:=length(fEntities);
    if Old<=aEntityID then begin
     SetLength(fEntities,(aEntityID+1)*2);
     for Index:=Old to length(fEntities)-1 do begin
      fEntities[Index]:=nil;
     end;
    end;
   finally
    fCriticalSection.Release;
   end;
  end;
  fEntities[aEntityID]:=aEntity;
 end;
end;

constructor TpvSystemScene3DGroup.Create(const AWorld:TpvWorld);
var Index:TpvInt32;
begin

 inherited Create(AWorld);

 fPasMP:=pvApplication.PasMPInstance;

 AddRequiredComponent(TpvComponentScene3DGroup);

 fLastEntities:=TpvSystemScene3DGroupEntities.Create(self);
 fCurrentEntities:=TpvSystemScene3DGroupEntities.Create(self);
 for Index:=low(fRenderableEntities) to high(fRenderableEntities) do begin
  fRenderableEntities[Index]:=TpvSystemScene3DGroupEntities.Create(self);
 end;

 fLastEntityIDs:=TpvSystemEntityIDs.Create;
 fCurrentEntityIDs:=TpvSystemEntityIDs.Create;
 for Index:=low(fRenderableEntityIDs) to high(fRenderableEntityIDs) do begin
  fRenderableEntityIDs[Index]:=TpvSystemEntityIDs.Create;
 end;

 fLastRenderableEntityIDs:=TpvSystemEntityIDs.Create;

 Flags:=(Flags+[TpvSystem.TSystemFlag.ParallelProcessing])-[TpvSystem.TSystemFlag.Secluded];

 EntityGranularity:=1024;

 fComponentTransformClassDataWrapper:=World.Components[TpvComponentTransform];
 fComponentTransformClassID:=World.Universe.RegisteredComponentClasses.ComponentIDs[TpvComponentTransform];

end;

destructor TpvSystemScene3DGroup.Destroy;
var Index:TpvInt32;
begin

 fLastEntities.Free;
 fCurrentEntities.Free;
 for Index:=low(fRenderableEntities) to high(fRenderableEntities) do begin
  FreeAndNil(fRenderableEntities[Index]);
 end;

 fLastEntityIDs.Free;
 fCurrentEntityIDs.Free;
 for Index:=low(fRenderableEntityIDs) to high(fRenderableEntityIDs) do begin
  FreeAndNil(fRenderableEntityIDs[Index]);
 end;

 FreeAndNil(fLastRenderableEntityIDs);

 inherited Destroy;
end;

procedure TpvSystemScene3DGroup.Added;
begin
 inherited Added;
end;

procedure TpvSystemScene3DGroup.Removed;
begin
 inherited Removed;
end;

function TpvSystemScene3DGroup.AddEntityToSystem(const aEntityID:TpvEntityID):boolean;
begin
 result:=inherited AddEntityToSystem(aEntityID);
end;

function TpvSystemScene3DGroup.RemoveEntityFromSystem(const aEntityID:TpvEntityID):boolean;
begin
 result:=inherited RemoveEntityFromSystem(aEntityID);
end;

procedure TpvSystemScene3DGroup.ProcessEvent(const aEvent:TpvEvent);
begin

end;

procedure TpvSystemScene3DGroup.InitializeUpdate;
var TempEntities:TpvSystemScene3DGroupEntities;
    TempEntityIDs:TpvSystemEntityIDs;
begin

 TempEntities:=fLastEntities;
 fLastEntities:=fCurrentEntities;
 fCurrentEntities:=TempEntities;

 TempEntityIDs:=fLastEntityIDs;
 fLastEntityIDs:=fCurrentEntityIDs;
 fCurrentEntityIDs:=TempEntityIDs;

 fCurrentEntityIDs.Assign(EntityIDs);

 inherited InitializeUpdate;
end;

procedure TpvSystemScene3DGroup.UpdateEntities(const aFirstEntityIndex,aLastEntityIndex:TpvInt32);
var Index:TpvInt32;
    EntityID:TpvEntityID;
    Entity:TpvEntity;
    pvSystemScene3DGroupEntity:TpvSystemScene3DGroupEntity;
    ComponentTransform:TpvComponentTransform;
    EntityTransform:TpvSystemScene3DGroupEntityTransform;
begin

 for Index:=aFirstEntityIndex to aLastEntityIndex do begin

  EntityID:=EntityIDs[Index];

  Entity:=Entities[Index];

  pvSystemScene3DGroupEntity:=fCurrentEntities.Entities[EntityID];
  if not assigned(pvSystemScene3DGroupEntity) then begin
   pvSystemScene3DGroupEntity:=TpvSystemScene3DGroupEntity.Create(self,EntityID);
   fCurrentEntities.Entities[EntityID]:=pvSystemScene3DGroupEntity;
  end;

  begin
   ComponentTransform:=TpvComponentTransform(Entity.ComponentByClassID[fComponentTransformClassID]);
   if assigned(ComponentTransform) then begin
    if not assigned(pvSystemScene3DGroupEntity.fTransform) then begin
     pvSystemScene3DGroupEntity.fTransform:=TpvSystemScene3DGroupEntityTransform.Create;
    end;
    EntityTransform:=pvSystemScene3DGroupEntity.fTransform;
    EntityTransform.fMatrix:=ComponentTransform.RawMatrix;
    EntityTransform.fStatic:=TpvComponentTransformFlag.Static in ComponentTransform.Flags;
   end else begin
    if assigned(pvSystemScene3DGroupEntity.fTransform) then begin
     FreeAndNil(pvSystemScene3DGroupEntity.fTransform);
    end;
   end;
  end;

  pvSystemScene3DGroupEntity.Seen:=true;

 end;

 inherited UpdateEntities(aFirstEntityIndex,aLastEntityIndex);

end;

procedure TpvSystemScene3DGroup.FinalizeUpdateLastParallelForJobFunction(const aJob:PPasMPJob;const aThreadIndex:TPasMPInt32;const aData:pointer;const aFromIndex,aToIndex:TPasMPNativeInt);
var EntityIndex:TpvInt32;
    EntityID:TpvEntityID;
    CurrentpvSystemScene3DGroupEntity:TpvSystemScene3DGroupEntity;
begin
 for EntityIndex:=aFromIndex downto aToIndex do begin
  EntityID:=fLastEntityIDs[EntityIndex];
  CurrentpvSystemScene3DGroupEntity:=fCurrentEntities.Entities[EntityID];
  if assigned(CurrentpvSystemScene3DGroupEntity) and not CurrentpvSystemScene3DGroupEntity.Seen then begin
   CurrentpvSystemScene3DGroupEntity.Free;
   fCurrentEntities.Entities[EntityID]:=nil;
  end;
 end;
end;

procedure TpvSystemScene3DGroup.FinalizeUpdateCurrentParallelForJobFunction(const aJob:PPasMPJob;const aThreadIndex:TPasMPInt32;const aData:pointer;const aFromIndex,aToIndex:TPasMPNativeInt);
var EntityIndex:TpvInt32;
    EntityID:TpvEntityID;
    CurrentpvSystemScene3DGroupEntity:TpvSystemScene3DGroupEntity;
begin
 for EntityIndex:=aFromIndex downto aToIndex do begin
  EntityID:=fCurrentEntityIDs[EntityIndex];
  CurrentpvSystemScene3DGroupEntity:=fCurrentEntities.Entities[EntityID];
  if assigned(CurrentpvSystemScene3DGroupEntity) then begin
   CurrentpvSystemScene3DGroupEntity.Seen:=false;
  end;
 end;
end;

procedure TpvSystemScene3DGroup.FinalizeUpdate;
begin
 fPasMP.ParallelFor(nil,0,fLastEntityIDs.Count-1,FinalizeUpdateLastParallelForJobFunction,1024);
 fPasMP.ParallelFor(nil,0,fCurrentEntityIDs.Count-1,FinalizeUpdateCurrentParallelForJobFunction,1024);
 inherited FinalizeUpdate;
end;

procedure TpvSystemScene3DGroup.PrepareRenderCurrentParallelForJobFunction(const aJob:PPasMPJob;const aThreadIndex:TPasMPInt32;const aData:pointer;const aFromIndex,aToIndex:TPasMPNativeInt);
var EntityIndex:TpvInt32;
    EntityID:TpvEntityID;
    RenderableScene3DGroupEntity:TpvSystemScene3DGroupEntity;
    LastpvSystemScene3DGroupEntity:TpvSystemScene3DGroupEntity;
    CurrentScene3DGroupEntity:TpvSystemScene3DGroupEntity;
    RenderableEntities:TpvSystemScene3DGroupEntities;
begin
 RenderableEntities:=fCurrentRenderableEntities;
 for EntityIndex:=aFromIndex to aToIndex do begin
  EntityID:=fCurrentRenderableEntityIDs[EntityIndex];
  RenderableScene3DGroupEntity:=RenderableEntities.Entities[EntityID];
  LastpvSystemScene3DGroupEntity:=fLastEntities.Entities[EntityID];
  CurrentScene3DGroupEntity:=fCurrentEntities.Entities[EntityID];
  if assigned(CurrentScene3DGroupEntity) then begin
   if not assigned(RenderableScene3DGroupEntity) then begin
    RenderableScene3DGroupEntity:=TpvSystemScene3DGroupEntity.Create(self,EntityID);
    RenderableEntities.Entities[EntityID]:=RenderableScene3DGroupEntity;
   end;
   if assigned(LastpvSystemScene3DGroupEntity) then begin
    RenderableScene3DGroupEntity.Interpolate(LastpvSystemScene3DGroupEntity,
                                             CurrentScene3DGroupEntity,
                                             fStateInterpolation);
   end else begin
    RenderableScene3DGroupEntity.Assign(CurrentScene3DGroupEntity);
   end;
   RenderableScene3DGroupEntity.Seen:=true;
   RenderableScene3DGroupEntity.Deleted:=false;
  end;
 end;
end;

procedure TpvSystemScene3DGroup.PrepareRenderLastParallelForJobFunction(const aJob:PPasMPJob;const aThreadIndex:TPasMPInt32;const aData:pointer;const aFromIndex,aToIndex:TPasMPNativeInt);
var EntityIndex:TpvInt32;
    EntityID:TpvEntityID;
    RenderableScene3DGroupEntity:TpvSystemScene3DGroupEntity;
    RenderableEntities:TpvSystemScene3DGroupEntities;
begin
 RenderableEntities:=fCurrentRenderableEntities;
 for EntityIndex:=aFromIndex to aToIndex do begin
  EntityID:=fLastRenderableEntityIDs[EntityIndex];
  RenderableScene3DGroupEntity:=RenderableEntities.Entities[EntityID];
  if assigned(RenderableScene3DGroupEntity) then begin
   if RenderableScene3DGroupEntity.Seen then begin
    RenderableScene3DGroupEntity.Seen:=false;
   end else begin
    RenderableScene3DGroupEntity.Free;
    RenderableEntities.Entities[EntityID]:=nil;
   end;
  end;
 end;
end;

procedure TpvSystemScene3DGroup.PrepareRender(const aPrepareInFlightFrameIndex:TpvInt32;const aStateInterpolation:TpvFloat);
begin
 fCurrentRenderableEntities:=fRenderableEntities[aPrepareInFlightFrameIndex];
 fCurrentRenderableEntityIDs:=fRenderableEntityIDs[aPrepareInFlightFrameIndex];
 fStateInterpolation:=aStateInterpolation;
 fLastRenderableEntityIDs.Assign(fCurrentRenderableEntityIDs);
 fCurrentRenderableEntityIDs.Assign(fCurrentEntityIDs);
 fPasMP.ParallelFor(nil,0,fCurrentRenderableEntityIDs.Count-1,PrepareRenderCurrentParallelForJobFunction,1024);
 fPasMP.ParallelFor(nil,0,fLastRenderableEntityIDs.Count-1,PrepareRenderLastParallelForJobFunction,1024);
end;

procedure TpvSystemScene3DGroup.Render(const aInFlightFrameIndex:TpvInt32);
begin

end;

initialization
end.

