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
unit PasVulkan.Components.Prefab.Instance;
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

uses SysUtils,
     Classes,
     Math,
     TypInfo,
     PasVulkan.Types,
     PasVulkan.PooledObject,
     PasVulkan.Collections,
     PasVulkan.EntityComponentSystem;

type TpvComponentPrefabInstanceEntityComponentProperty=class(TpvPooledObject)
      public
       type TpvComponentPrefabInstanceEntityComponentPropertyFlag=
             (
              cpiecpfOverwritten
             );
            TpvComponentPrefabInstanceEntityComponentPropertyFlags=set of TpvComponentPrefabInstanceEntityComponentPropertyFlag;
      private
       fFlags:TpvComponentPrefabInstanceEntityComponentPropertyFlags;
       fComponentClass:TpvComponentClass;
       fPropInfo:PPropInfo;
      public
       constructor Create;
       destructor Destroy; override;
       property PropInfo:PPropInfo read fPropInfo write fPropInfo;
      published
       property Flags:TpvComponentPrefabInstanceEntityComponentPropertyFlags read fFlags write fFlags;
       property ComponentClass:TpvComponentClass read fComponentClass write fComponentClass;
     end;

     TpvComponentPrefabInstanceEntityComponentPropertyList=class(TpvObjectGenericList<TpvComponentPrefabInstanceEntityComponentProperty>)
      public
       constructor Create;
       destructor Destroy; override;
       function IndexOfComponentClassProperty(const aComponentClass:TpvComponentClass;const aPropInfo:PPropInfo):TpvInt32;
       function AddComponentClassProperty(const aComponentClass:TpvComponentClass;const aPropInfo:PPropInfo):TpvInt32;
       procedure RemoveComponentClassProperty(const aComponentClass:TpvComponentClass;const aPropInfo:PPropInfo);
     end;

     TpvComponentPrefabInstanceEntityComponent=class(TpvPooledObject)
      public
       type TpvComponentPrefabInstanceEntityComponentFlag=
             (
              cpiecfOverwritten
             );
            TpvComponentPrefabInstanceEntityComponentFlags=set of TpvComponentPrefabInstanceEntityComponentFlag;
      private
       fFlags:TpvComponentPrefabInstanceEntityComponentFlags;
       fpvComponentClass:TpvComponentClass;
      public
       constructor Create;
       destructor Destroy; override;
      published
       property Flags:TpvComponentPrefabInstanceEntityComponentFlags read fFlags write fFlags;
       property pvComponentClass:TpvComponentClass read fpvComponentClass write fpvComponentClass;
     end;

     TpvComponentPrefabInstanceEntityComponentList=class(TpvObjectGenericList<TpvComponentPrefabInstanceEntityComponent>)
      public
       constructor Create;
       destructor Destroy; override;
       function IndexOfpvComponentClass(const aComponentClass:TpvComponentClass):TpvInt32;
       function AddpvComponentClass(const aComponentClass:TpvComponentClass):TpvInt32;
       procedure RemovepvComponentClass(const aComponentClass:TpvComponentClass);
     end;

     TpvComponentPrefabInstance=class(TpvComponent)
      public
       type TpvComponentPrefabInstanceFlag=
             (
              cpifRoot
             );
            TpvComponentPrefabInstanceFlags=set of TpvComponentPrefabInstanceFlag;
      private
       fFlags:TpvComponentPrefabInstanceFlags;
       fSourceWorld:TpvUUID;
       fSourceEntity:TpvUUID;
       fEntityComponents:TpvComponentPrefabInstanceEntityComponentList;
       fEntityComponentProperties:TpvComponentPrefabInstanceEntityComponentPropertyList;
       function GetSourceWorld:TpvUUIDString;
       procedure SetSourceWorld(const aSourceWorld:TpvUUIDString);
       function GetSourceEntity:TpvUUIDString;
       procedure SetSourceEntity(const aSourceEntity:TpvUUIDString);
      public
       constructor Create; override;
       destructor Destroy; override;
       class function ClassPath:string; override;
       class function ClassUUID:TpvUUID; override;
      public
       property SourceWorldUUID:TpvUUID read fSourceWorld write fSourceWorld;
       property SourceEntityUUID:TpvUUID read fSourceEntity write fSourceEntity;
      published
       property Flags:TpvComponentPrefabInstanceFlags read fFlags write fFlags;
       property SourceWorld:TpvUUIDString read GetSourceWorld write SetSourceWorld;
       property SourceEntity:TpvUUIDString read GetSourceEntity write SetSourceEntity;
       property EntityComponents:TpvComponentPrefabInstanceEntityComponentList read fEntityComponents write fEntityComponents;
       property EntityComponentProperties:TpvComponentPrefabInstanceEntityComponentPropertyList read fEntityComponentProperties write fEntityComponentProperties;
     end;

implementation

constructor TpvComponentPrefabInstanceEntityComponentProperty.Create;
begin
 inherited Create;
 fFlags:=[];
 fComponentClass:=nil;
 fPropInfo:=nil;
end;

destructor TpvComponentPrefabInstanceEntityComponentProperty.Destroy;
begin
 inherited Destroy;
end;

constructor TpvComponentPrefabInstanceEntityComponentPropertyList.Create;
begin
 inherited Create;
 OwnsObjects:=true;
end;

destructor TpvComponentPrefabInstanceEntityComponentPropertyList.Destroy;
begin
 inherited Destroy;
end;

function TpvComponentPrefabInstanceEntityComponentPropertyList.IndexOfComponentClassProperty(const aComponentClass:TpvComponentClass;const aPropInfo:PPropInfo):TpvInt32;
var Index:longint;
    Item:TpvComponentPrefabInstanceEntityComponentProperty;
begin
 for Index:=0 to Count-1 do begin
  Item:=Items[Index];
  if (Item.fComponentClass=aComponentClass) and (Item.fPropInfo=aPropInfo) then begin
   result:=Index;
   exit;
  end;
 end;
 result:=-1;
end;

function TpvComponentPrefabInstanceEntityComponentPropertyList.AddComponentClassProperty(const aComponentClass:TpvComponentClass;const aPropInfo:PPropInfo):TpvInt32;
var Index:longint;
    Item:TpvComponentPrefabInstanceEntityComponentProperty;
begin
 for Index:=0 to Count-1 do begin
  Item:=Items[Index];
  if (Item.fComponentClass=aComponentClass) and (Item.fPropInfo=aPropInfo) then begin
   result:=Index;
   exit;
  end;
 end;
 Item:=TpvComponentPrefabInstanceEntityComponentProperty.Create;
 result:=Add(Item);
 Item.fFlags:=[];
 Item.fComponentClass:=aComponentClass;
 Item.fPropInfo:=aPropInfo;
end;

procedure TpvComponentPrefabInstanceEntityComponentPropertyList.RemoveComponentClassProperty(const aComponentClass:TpvComponentClass;const aPropInfo:PPropInfo);
var Index:longint;
    Item:TpvComponentPrefabInstanceEntityComponentProperty;
begin
 for Index:=0 to Count-1 do begin
  Item:=Items[Index];
  if (Item.fComponentClass=aComponentClass) and (Item.fPropInfo=aPropInfo) then begin
   Delete(Index);
   break;
  end;
 end;
end;

constructor TpvComponentPrefabInstanceEntityComponent.Create;
begin
 inherited Create;
 fFlags:=[];
 fpvComponentClass:=nil;
end;

destructor TpvComponentPrefabInstanceEntityComponent.Destroy;
begin
 inherited Destroy;
end;

constructor TpvComponentPrefabInstanceEntityComponentList.Create;
begin
 inherited Create;
 OwnsObjects:=true;
end;

destructor TpvComponentPrefabInstanceEntityComponentList.Destroy;
begin
 inherited Destroy;
end;

function TpvComponentPrefabInstanceEntityComponentList.IndexOfpvComponentClass(const aComponentClass:TpvComponentClass):TpvInt32;
var Index:longint;
    Item:TpvComponentPrefabInstanceEntityComponent;
begin
 for Index:=0 to Count-1 do begin
  Item:=Items[Index];
  if Item.fpvComponentClass=aComponentClass then begin
   result:=Index;
   exit;
  end;
 end;
 result:=-1;
end;

function TpvComponentPrefabInstanceEntityComponentList.AddpvComponentClass(const aComponentClass:TpvComponentClass):TpvInt32;
var Index:longint;
    Item:TpvComponentPrefabInstanceEntityComponent;
begin
 for Index:=0 to Count-1 do begin
  Item:=Items[Index];
  if Item.fpvComponentClass=aComponentClass then begin
   result:=Index;
   exit;
  end;
 end;
 Item:=TpvComponentPrefabInstanceEntityComponent.Create;
 result:=Add(Item);
 Item.fFlags:=[];
 Item.fpvComponentClass:=aComponentClass;
end;

procedure TpvComponentPrefabInstanceEntityComponentList.RemovepvComponentClass(const aComponentClass:TpvComponentClass);
var Index:longint;
    Item:TpvComponentPrefabInstanceEntityComponent;
begin
 for Index:=0 to Count-1 do begin
  Item:=Items[Index];
  if Item.fpvComponentClass=aComponentClass then begin
   Delete(Index);
   break;
  end;
 end;
end;

constructor TpvComponentPrefabInstance.Create;
begin
 inherited Create;
 fFlags:=[];
 fSourceWorld.UInt64s[0]:=TpvUInt64($0000000000000000);
 fSourceWorld.UInt64s[1]:=TpvUInt64($0000000000000000);
 fSourceEntity.UInt64s[0]:=TpvUInt64($0000000000000000);
 fSourceEntity.UInt64s[1]:=TpvUInt64($0000000000000000);
 fEntityComponents:=TpvComponentPrefabInstanceEntityComponentList.Create;
 fEntityComponentProperties:=TpvComponentPrefabInstanceEntityComponentPropertyList.Create;
end;

destructor TpvComponentPrefabInstance.Destroy;
begin
 fEntityComponents.Free;
 fEntityComponentProperties.Free;
 inherited Destroy;
end;

class function TpvComponentPrefabInstance.ClassPath:string;
begin
 result:='Prefab\Instance';
end;

class function TpvComponentPrefabInstance.ClassUUID:TpvUUID;
begin
 result.UInt64s[0]:=TpvUInt64($21e33b3614414331);
 result.UInt64s[1]:=TpvUInt64($b1ca03cdfd78ef38);
end;

function TpvComponentPrefabInstance.GetSourceWorld:TpvUUIDString;
begin
 result:=fSourceWorld.ToString;
end;

procedure TpvComponentPrefabInstance.SetSourceWorld(const aSourceWorld:TpvUUIDString);
begin
 fSourceWorld:=TpvUUID.CreateFromString(aSourceWorld);
end;

function TpvComponentPrefabInstance.GetSourceEntity:TpvUUIDString;
begin
 result:=fSourceEntity.ToString;
end;

procedure TpvComponentPrefabInstance.SetSourceEntity(const aSourceEntity:TpvUUIDString);
begin
 fSourceEntity:=TpvUUID.CreateFromString(aSourceEntity);
end;

end.
