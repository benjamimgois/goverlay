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
unit PasVulkan.EntityComponentSystem;
{$i PasVulkan.inc}
{$ifndef fpc}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=24.0}
   {$legacyifend on}
  {$ifend}
 {$endif}
{$endif}

interface

uses {$ifdef Windows}Windows,{$endif}SysUtils,Classes,Math,Variants,TypInfo,
     PasMP,PUCU,PasJSON,
     PasDblStrUtils,
     PasVulkan.Types,
     PasVulkan.Collections,
     PasVulkan.IDManager,
     PasVulkan.Streams,
     PasVulkan.Resources,
     PasVulkan.DataStructures.LinkedList,
     PasVulkan.PooledObject,
     PasVulkan.Value;

type EpvSystemCircularDependency=class(Exception);

     EpvSystemSerialization=class(Exception);

     EpvSystemUnserialization=class(Exception);

     EpvDuplicateComponentInEntity=class(Exception);

     TpvUniverse=class;

     TpvWorld=class;

     TpvSystem=class;

     TpvSystemClass=class of TpvSystem;

     TpvSystemList=class;

     TpvSystemClassList=class;

     TpvEntity=class;

     TpvComponentClassID=type TpvInt32;
     PpvComponentClassID=^TpvComponentClassID;

     TpvComponentClassIDs=array of TpvComponentClassID;

     TpvEntityID=type TpvInt32;
     PpvEntityID=^TpvEntityID;

     TpvEntityIDs=array of TpvEntityID;

     TpvComponentDataEntityIDs=class(TpvGenericList<TpvEntityID>);

     TpvEntityUUIDHashMap=class(TpvHashMap<TpvUUID,TpvEntity>);

     TpvWorldID=type TpvInt32;
     PpvWorldID=^TpvWorldID;

     TpvEventID=type TpvInt32;
     PEventID=^TpvEventID;

     TpvEventParameter=TpvValue;
     PpvEventParameter=^TpvEventParameter;

     TpvEventParameters=array of TpvEventParameter;
     PpvEventParameters=^TpvEventParameters;

     TpvEvent=record
      LinkedListHead:TpvLinkedListHead;
      TimeStamp:TpvTime;
      RemainingTime:TpvTime;
      EventID:TpvEventID;
      EntityID:TpvEntityID;
      CountParameters:TpvInt32;
      Parameters:TpvEventParameters;
     end;
     PpvEvent=^TpvEvent;

     TpvEventHandler=procedure(const aEvent:TpvEvent) of object;

     TpvEventHandlers=array of TpvEventHandler;

     TpvEventRegistration=class
      private
       fEventID:TpvEventID;
       fName:TpvUTF8String;
       fActive:longbool;
       fLock:TPasMPMultipleReaderSingleWriterLock;
       fSystemList:TList;
       fEventHandlers:TpvEventHandlers;
       fCountEventHandlers:TpvInt32;
      public
       constructor Create(const aEventID:TpvEventID;const aName:TpvUTF8String);
       destructor Destroy; override;
       procedure Clear;
       procedure AddSystem(const aSystem:TpvSystem);
       procedure RemoveSystem(const aSystem:TpvSystem);
       procedure AddEventHandler(const aEventHandler:TpvEventHandler);
       procedure RemoveEventHandler(const aEventHandler:TpvEventHandler);
       property EventID:TpvEventID read fEventID;
       property Name:TpvUTF8String read fName;
       property Active:longbool read fActive;
       property Lock:TPasMPMultipleReaderSingleWriterLock read fLock;
       property SystemList:TList read fSystemList;
       property EventHandlers:TpvEventHandlers read fEventHandlers;
       property CountEventHandlers:TpvInt32 read fCountEventHandlers;
     end;

     TpvSystemEvents=array of PpvEvent;

     TpvComponentClassNameID=record
      Name:shortstring;
      ID:TpvComponentClassID;
     end;
     PpvComponentClassNameID=^TpvComponentClassNameID;

     TpvComponent=class(TpvPooledObject)
      private
       class procedure SetClassID(const aID:TpvComponentClassID);
      public
       constructor Create; virtual;
       destructor Destroy; override;
       class function ClassID:TpvComponentClassID; inline;
       class function ClassPath:string; virtual;
       class function ClassUUID:TpvUUID; virtual;
       class function ClassInstanceMemoryCopyable:boolean; virtual;
       class function HasSpecialJSONSerialization:boolean; virtual;
       function SpecialJSONSerialization:TPasJSONItem; virtual;
       procedure SpecialJSONUnserialization(const aJSONItem:TPasJSONItem); virtual;
       function BinarySerializationSize:TpvSizeInt; virtual;
       procedure BinarySerialize(const aStream:TStream); virtual;
       procedure BinaryUnserialize(const aStream:TStream); virtual;
       procedure MementoSerialize(const aStream:TStream); virtual;
       procedure MementoUnserialize(const aStream:TStream); virtual;
       procedure Assign(const aFrom:TpvComponent;const aEntityIDs:TpvEntityIDs=nil); virtual;
     end;

     TpvComponentClass=class of TpvComponent;

     TpvComponentList=class(TList)
      private
       function GetComponent(const aIndex:TpvInt32):TpvComponent; inline;
       procedure SetComponent(const aIndex:TpvInt32;const aComponent:TpvComponent); inline;
      public
       constructor Create;
       destructor Destroy; override;
       property Items[const aIndex:TpvInt32]:TpvComponent read GetComponent write SetComponent; default;
     end;

     TpvComponentClassDataWrapper=class(TpvPooledObject)
      private
       fWorld:TpvWorld;
       fComponentClass:TpvComponentClass;
       fComponentClassID:TpvComponentClassID;
       function GetComponentByEntityID(const aEntityID:TpvEntityID):TpvComponent;
      public
       constructor Create(const aWorld:TpvWorld;const aComponentClass:TpvComponentClass);
       destructor Destroy; override;
       property ComponentByEntityID[const aEntityID:TpvEntityID]:TpvComponent read GetComponentByEntityID; default;
     end;

     TpvRegisteredComponentClassList=class(TList)
      public
       type TRegisteredComponentClassListNameIndexHashMap=TpvStringHashMap<TpvInt32>;
            TRegisteredComponentClassListUUIDIndexHashMap=TpvHashMap<TpvUUID,TpvInt32>;
            TRegisteredComponentClassListComponentIDHashMap=TpvHashMap<pointer,TpvComponentClassID>;
      private
       fComponentClassNameStringIntegerPairHashMap:TRegisteredComponentClassListNameIndexHashMap;
       fComponentClassUUIDIntegerPairHashMap:TRegisteredComponentClassListUUIDIndexHashMap;
       fComponentIDHashMap:TRegisteredComponentClassListComponentIDHashMap;
       fCountDeleted:TpvInt32;
       function GetComponentClass(const aIndex:TpvInt32):TpvComponentClass; inline;
       procedure SetComponentClass(const aIndex:TpvInt32;const aComponentClass:TpvComponentClass); inline;
       function GetComponentClassByName(const aComponentClassName:TpvUTF8String):TpvComponentClass; inline;
       procedure SetComponentClassByName(const aComponentClassName:TpvUTF8String;const aComponentClass:TpvComponentClass); inline;
       function GetComponentClassByUUID(const aComponentClassUUID:TpvUUID):TpvComponentClass; inline;
       procedure SetComponentClassByUUID(const aComponentClassUUID:TpvUUID;const aComponentClass:TpvComponentClass); inline;
       function GetComponentClassID(const aComponentClass:TpvComponentClass):TpvComponentClassID; inline;
      public
       constructor Create;
       destructor Destroy; override;
       function Add(const aComponentClass:TpvComponentClass):TpvComponentClassID; reintroduce;
       procedure Remove(const aComponentClass:TpvComponentClass); reintroduce;
       property Items[const aIndex:TpvInt32]:TpvComponentClass read GetComponentClass write SetComponentClass; default;
       property ComponentByID[const aIndex:TpvInt32]:TpvComponentClass read GetComponentClass write SetComponentClass;
       property ComponentByName[const aComponentClassName:TpvUTF8String]:TpvComponentClass read GetComponentClassByName write SetComponentClassByName;
       property ComponentByUUID[const aComponentClassUUID:TpvUUID]:TpvComponentClass read GetComponentClassByUUID write SetComponentClassByUUID;
       property ComponentIDs[const aComponentClass:TpvComponentClass]:TpvComponentClassID read GetComponentClassID;
     end;

     TpvEntityIDManager=class(TpvGenericIDManager<TpvEntityID>);

     TpvEntityComponents=array of TpvComponent;

     TpvEntityAssignOp=
      (
       Replace,
       Combine
      );

     TpvEntity=class(TpvPooledObject)
      public
       type TEntityFlag=
             (
              Used,
              Active,
              Killed,
              PrefabSynchronized
             );
            TEntityFlags=set of TEntityFlag;
            TFlag=TEntityFlag;
            TFlags=TEntityFlags;
            TComponentBitmap=array of TpvUInt64;
      private
       fWorld:TpvWorld;
       fID:TpvEntityID;
       fUUID:TpvUUID;
       fFlags:TEntityFlags;
       fComponents:TpvEntityComponents;
       fComponentBitmap:TComponentBitmap;
{$ifdef PasVulkanEditor}
       fTreeNode:pointer;
{$endif}
       fUnknownData:TPasJSONItemObject;
       procedure AddComponentToEntity(const aComponent:TpvComponent);
       procedure RemoveComponentFromEntity(const aComponent:TpvComponent);
       function GetComponentByClass(const aComponentClass:TpvComponentClass):TpvComponent; inline;
       function GetComponentByClassID(const aComponentClassID:TpvComponentClassID):TpvComponent; inline;
      public
       constructor Create(const aWorld:TpvWorld);
       destructor Destroy; override;
       procedure Assign(const aFrom:TpvEntity;const aAssignOp:TpvEntityAssignOp=TpvEntityAssignOp.Replace;const aEntityIDs:TpvEntityIDs=nil;const aDoRefresh:boolean=true);
       procedure SynchronizeToPrefab;
       function Active:boolean; inline;
       procedure Activate; inline;
       procedure Deactivate; inline;
       procedure Kill; inline;
       procedure AddComponent(const aComponent:TpvComponent); inline;
       procedure RemoveComponent(const aComponentClass:TpvComponentClass); overload; inline;
       procedure RemoveComponent(const aComponentClassID:TpvComponentClassID); overload; inline;
       function HasComponent(const aComponentClass:TpvComponentClass):boolean; overload; inline;
       function HasComponent(const aComponentClassID:TpvComponentClassID):boolean; overload; inline;
       function GetComponent(const aComponentClass:TpvComponentClass):TpvComponent; overload; inline;
       function GetComponent(const aComponentClassID:TpvComponentClassID):TpvComponent; overload; inline;
       property World:TpvWorld read fWorld;
       property UUID:TpvUUID read fUUID write fUUID;
       property Flags:TEntityFlags read fFlags write fFlags;
{$ifdef PasVulkanEditor}
       property TreeNode:pointer read fTreeNode write fTreeNode;
{$endif}
       property RawComponents:TpvEntityComponents read fComponents;
       property ComponentByClass[const ComponentClass:TpvComponentClass]:TpvComponent read GetComponentByClass; default;
       property ComponentByClassID[const ComponentClassID:TpvComponentClassID]:TpvComponent read GetComponentByClassID;
      published
       property ID:TpvEntityID read fID;
     end;

     TpvEntities=array of TpvEntity;

     TpvEntityClass=class of TpvEntity;

     TpvEntityList=class(TList)
      public
       type TEntityListIDEntityHashMap=TpvHashMap<TpvEntityID,TpvEntity>;
            TEntityListUUIDIDHashMap=TpvHashMap<TpvUUID,TpvInt32>;
      private
       fIDEntityHashMap:TEntityListIDEntityHashMap;
       fUUIDIDHashMap:TEntityListUUIDIDHashMap;
       function GetEntity(const aIndex:TpvInt32):TpvEntity; inline;
       procedure SetEntity(const aIndex:TpvInt32;const aEntity:TpvEntity); inline;
       function GetEntityByID(const aEntityID:TpvEntityID):TpvEntity; inline;
       function GetEntityByUUID(const aEntityUUID:TpvUUID):TpvEntity; inline;
      public
       constructor Create;
       destructor Destroy; override;
       property Items[const aIndex:TpvInt32]:TpvEntity read GetEntity write SetEntity; default;
       property EntityByID[const aEntityID:TpvEntityID]:TpvEntity read GetEntityByID;
       property EntityByUUID[const aEntityUUID:TpvUUID]:TpvEntity read GetEntityByUUID;
     end;

     TpvSystemComponentClassList=class(TpvGenericList<pointer>);

     TpvSystemEntityIDs=class
      private
       fEntityIDs:TpvEntityIDs;
       fCount:TpvInt32;
       fSorted:boolean;
       function GetEntityID(const aIndex:TpvInt32):TpvEntityID; inline;
      public
       constructor Create;
       destructor Destroy; override;
       procedure Clear;
       procedure Assign(const aFrom:TpvSystemEntityIDs);
       function IndexOf(const aEntityID:TpvEntityID):TpvInt32;
       function Add(const aEntityID:TpvEntityID):TpvInt32;
       procedure Insert(const aIndex:TpvInt32;const aEntityID:TpvEntityID);
       procedure Delete(const aIndex:TpvInt32);
       procedure Sort;
       property Items[const aIndex:TpvInt32]:TpvEntityID read GetEntityID; default;
       property Count:TpvInt32 read fCount;
     end;

     TpvSystemEntities=class
      private
       fEntities:TpvEntities;
       fCount:TpvInt32;
       fSorted:boolean;
       function GetEntity(const aIndex:TpvInt32):TpvEntity; inline;
      public
       constructor Create;
       destructor Destroy; override;
       procedure Clear;
       procedure Assign(const aFrom:TpvSystemEntities);
       function IndexOf(const aEntity:TpvEntity):TpvInt32;
       function Add(const aEntity:TpvEntity):TpvInt32;
       procedure Insert(const aIndex:TpvInt32;const aEntity:TpvEntity);
       procedure Delete(const aIndex:TpvInt32);
       procedure Sort;
       property Items[const aIndex:TpvInt32]:TpvEntity read GetEntity; default;
       property Count:TpvInt32 read fCount;
     end;

     { TpvSystem }

     TpvSystem=class(TpvObject)
      public
       type TSystemFlag=
             (
              ParallelProcessing,
              Secluded,
              OwnUpdate
             );
            TSystemFlags=set of TSystemFlag;
            TFlag=TSystemFlag;
            TFlags=TSystemFlags;
      private
       fWorld:TpvWorld;
       fFlags:TSystemFlags;
       fEntityIDs:TpvSystemEntityIDs;
       fEntities:TpvSystemEntities;
       fRequiredComponentClasses:TpvSystemComponentClassList;
       fExcludedComponentClasses:TpvSystemComponentClassList;
       fRequiresSystems:TList;
       fConflictsWithSystems:TList;
       fNeedToSort:boolean;
       fEventsCanBeParallelProcessed:boolean;
       fEventGranularity:TpvInt32;
       fEntityGranularity:TpvInt32;
       fCountEntities:TpvInt32;
       fEvents:TpvSystemEvents;
       fCountEvents:TpvInt32;
       fDeltaTime:TpvTime;
      protected
       function HaveDependencyOnSystem(const aOtherSystem:TpvSystem):boolean;
       function HaveDependencyOnSystemOrViceVersa(const aOtherSystem:TpvSystem):boolean;
       function HaveCircularDependencyWithSystem(const aOtherSystem:TpvSystem):boolean;
       function HaveConflictWithSystem(const aOtherSystem:TpvSystem):boolean;
       function HaveConflictWithSystemOrViceVersa(const aOtherSystem:TpvSystem):boolean;
      public
       constructor Create(const AWorld:TpvWorld); virtual;
       destructor Destroy; override;
       procedure Added; virtual;
       procedure Removed; virtual;
       procedure SubscribeToEvent(const aEventID:TpvEventID);
       procedure UnsubscribeFromEvent(const aEventID:TpvEventID);
       procedure RequiresSystem(const aSystem:TpvSystem);
       procedure ConflictsWithSystem(const aSystem:TpvSystem);
       procedure AddRequiredComponent(const aComponentClass:TpvComponentClass); overload;
       procedure AddExcludedComponent(const aComponentClass:TpvComponentClass); overload;
       function FitsEntityToSystem(const aEntityID:TpvEntityID):boolean; virtual;
       function AddEntityToSystem(const aEntityID:TpvEntityID):boolean; virtual;
       function RemoveEntityFromSystem(const aEntityID:TpvEntityID):boolean; virtual;
       procedure SortEntities; virtual;
       procedure Finish; virtual;
       procedure ProcessEvent(const aEvent:TpvEvent); virtual;
       procedure ProcessEvents(const aFirstEventIndex,aLastEventIndex:TpvInt32); virtual;
       procedure InitializeUpdate; virtual;
       procedure Update; virtual;
       procedure UpdateEntities(const aFirstEntityIndex,aLastEntityIndex:TpvInt32); virtual;
       procedure FinalizeUpdate; virtual;
       procedure Store; virtual;
       procedure Interpolate(const aAlpha:TpvDouble); virtual;
       property World:TpvWorld read fWorld;
       property Flags:TSystemFlags read fFlags write fFlags;
       property EntityIDs:TpvSystemEntityIDs read fEntityIDs;
       property Entities:TpvSystemEntities read fEntities;
       property CountEntities:TpvInt32 read fCountEntities;
       property EventsCanBeParallelProcessed:boolean read fEventsCanBeParallelProcessed write fEventsCanBeParallelProcessed;
       property EventGranularity:TpvInt32 read fEventGranularity write fEventGranularity;
       property EntityGranularity:TpvInt32 read fEntityGranularity write fEntityGranularity;
       property Events:TpvSystemEvents read fEvents;
       property CountEvents:TpvInt32 read fCountEvents;
       property DeltaTime:TpvTime read fDeltaTime;
     end;

     TpvSystemChoreography=class
      public
       type TSystemChoreographyStepSystems=array of TpvSystem;
            TSystemChoreographyStepJobs=array of PPasMPJob;
            PSystemChoreographyStep=^TSystemChoreographyStep;
            TSystemChoreographyStep=record
             Systems:TSystemChoreographyStepSystems;
             Jobs:TSystemChoreographyStepJobs;
             Count:TpvInt32;
            end;
            TSystemChoreographySteps=array of TSystemChoreographyStep;
            PSystemChoreographyStepProcessEventsJobData=^TSystemChoreographyStepProcessEventsJobData;
            TSystemChoreographyStepProcessEventsJobData=record
             ChoreographyStep:PSystemChoreographyStep;
            end;
            PSystemChoreographyStepUpdateEntitiesJobData=^TSystemChoreographyStepUpdateEntitiesJobData;
            TSystemChoreographyStepUpdateEntitiesJobData=record
             ChoreographyStep:PSystemChoreographyStep;
            end;
      private
       fWorld:TpvWorld;
       fPasMP:TPasMP;
       fChoreographySteps:TSystemChoreographySteps;
       fChoreographyStepJobs:TSystemChoreographyStepJobs;
       fCountChoreographySteps:TpvInt32;
       fSortedSystemList:TList;
       function CreateProcessEventsJob(const aSystem:TpvSystem;const aFirstEventIndex,aLastEventIndex:TpvInt32;const aParentJob:PPasMPJob):PPasMPJob;
       procedure ProcessEventsJobFunction(const aJob:PPasMPJob;const aThreadIndex:TpvInt32);
       procedure ChoreographyStepProcessEventsJobFunction(const aJob:PPasMPJob;const aThreadIndex:TpvInt32);
       procedure ChoreographyProcessEventsJobFunction(const aJob:PPasMPJob;const aThreadIndex:TpvInt32);
       function CreateUpdateEntitiesJob(const aSystem:TpvSystem;const aFirstEntityIndex,aLastEntityIndex:TpvInt32;const aParentJob:PPasMPJob):PPasMPJob;
       procedure UpdateEntitiesJobFunction(const aJob:PPasMPJob;const aThreadIndex:TpvInt32);
       procedure ChoreographyStepUpdateEntitiesJobFunction(const aJob:PPasMPJob;const aThreadIndex:TpvInt32);
       procedure ChoreographyUpdateEntitiesJobFunction(const aJob:PPasMPJob;const aThreadIndex:TpvInt32);
      public
       constructor Create(const aWorld:TpvWorld);
       destructor Destroy; override;
       procedure Build;
       procedure ProcessEvents;
       procedure InitializeUpdate;
       procedure Update;
       procedure FinalizeUpdate;
     end;

     TpvSystemList=class(TList)
      private
       function GetSystem(const aIndex:TpvInt32):TpvSystem; inline;
       procedure SetSystem(const aIndex:TpvInt32;const ASystem:TpvSystem); inline;
      public
       constructor Create;
       destructor Destroy; override;
       property Items[const aIndex:TpvInt32]:TpvSystem read GetSystem write SetSystem; default;
     end;

     TpvSystemClassList=class(TList)
      private
       function GetSystemClass(const aIndex:TpvInt32):TpvSystemClass; inline;
       procedure SetSystemClass(const aIndex:TpvInt32;const ASystemClass:TpvSystemClass); inline;
      public
       constructor Create;
       destructor Destroy; override;
       property Items[const aIndex:TpvInt32]:TpvSystemClass read GetSystemClass write SetSystemClass; default;
     end;

     TpvWorldIDManager=class(TpvGenericIDManager<TpvWorldID>);

     TpvDelayedManagementEventType=
      (
       None,
       CreateEntity,
       ActivateEntity,
       DeactivateEntity,
       KillEntity,
       AddComponentToEntity,
       RemoveComponentFromEntity,
       AddSystem,
       RemoveSystem,
       SortSystem
      );

     TpvDelayedManagementEventData=array of TpvUInt8;

     TpvDelayedManagementEvent=record
      EventType:TpvDelayedManagementEventType;
      EntityID:TpvEntityID;
      Component:TpvComponent;
      ComponentClass:TpvComponentClass;
      System:TpvSystem;
      UUID:TpvUUID;
      Data:TpvDelayedManagementEventData;
      DataSize:TpvInt32;
      DataString:RawByteString;
     end;
     PpvDelayedManagementEvent=^TpvDelayedManagementEvent;

     TpvDelayedManagementEvents=array of TpvDelayedManagementEvent;

     TpvEntityIDUsedBitmap=array of TpvUInt32;

     TpvWorldOnEvent=procedure(const aWorld:TpvWorld;const aEvent:TpvEvent) of object;

     TpvMetaWorld=class(TpvMetaResource)
      protected
       function GetResource:IpvResource; override;
      public
       constructor Create; override;
       constructor CreateNew(const aFileName:TpvUTF8String); override;
       destructor Destroy; override;
       procedure LoadFromStream(const aStream:TStream); override;
       function Clone(const aFileName:TpvUTF8String=''):TpvMetaResource; override;
       procedure Rename(const aFileName:TpvUTF8String); override;
       procedure Delete; override;
     end;

     IpvWorld=interface(IpvResource)['{2D61324B-7381-4036-8B7D-0CBCD4A88E0F}']
     end;

     TpvWorldAssignOp=
      (
       Replace,
       Combine,
       Add
      );

     { TpvWorldEntityComponentSetQuery }
     TpvWorldEntityComponentSetQuery=class
      private
       fEntityIDs: TpvEntityIDs;
       fWorld:TpvWorld;
       fRequiredComponentBitmap:TpvEntity.TComponentBitmap;
       fExcludedComponentBitmap:TpvEntity.TComponentBitmap;
       fGeneration:TpvUInt64;
       fEntityID:TpvEntityIDs;
      public
       constructor Create(const aWorld:TpvWorld;const aRequiredComponents:array of TpvComponentClassID;const aExcludedComponents:array of TpvComponentClassID); overload;
       constructor Create(const aWorld:TpvWorld;const aRequiredComponents:array of TpvComponentClass;const aExcludedComponents:array of TpvComponentClass); overload;
       destructor Destroy; override;
       procedure Update;
      public
       property EntityID:TpvEntityIDs read fEntityIDs;
     end;

     { TpvWorld }
     TpvWorld=class(TpvResource,IpvWorld)
      public
       type TWorldEventRegistrationStringIntegerPairHashMap=class(TpvStringHashMap<TpvInt32>);
            TWorldUUIDIndexHashMap=class(TpvHashMap<TpvUUID,TpvEntityID>);
            TWorldEntityIDFreeList=class(TpvGenericList<TpvEntityID>);
            TWorldSystemBooleanHashMap=class(TpvHashMap<TpvSystem,boolean>);
            TWorldComponentClassDataWrappers=array of TpvComponentClassDataWrapper;
      public
       fUniverse:TpvUniverse;
       fID:TpvWorldID;
       fGeneration:TpvUInt64;
       fActive:longbool;
       fKilled:longbool;
       fSortKey:TpvInt32;
{$ifdef PasVulkanEditor}
       fTabsheet:pointer;
       fForm:pointer;
{$endif}
       fLock:TPasMPMultipleReaderSingleWriterLock;
       fComponentClassDataWrappers:TWorldComponentClassDataWrappers;
       fEntities:TpvEntities;
       fEntityUUIDHashMap:TWorldUUIDIndexHashMap;
       fReservedEntityUUIDHashMap:TWorldUUIDIndexHashMap;
       fDelayedManagementEventLock:TPasMPMultipleReaderSingleWriterLock;
       fReservedEntityHashMapLock:TPasMPMultipleReaderSingleWriterLock;
       fEntityIDLock:TPasMPMultipleReaderSingleWriterLock;
       fEntityIDFreeList:TWorldEntityIDFreeList;
       fEntityIDCounter:TpvInt32;
       fEntityIDMax:TpvInt32;
       fEntityIDUsedBitmap:TpvEntityIDUsedBitmap;
       fSystemList:TList;
       fSystemPointerIntegerPairHashMap:TWorldSystemBooleanHashMap;
       fSystemChoreography:TpvSystemChoreography;
       fSystemChoreographyNeedToRebuild:TpvInt32;
       fDelayedManagementEvents:TpvDelayedManagementEvents;
       fCountDelayedManagementEvents:TpvInt32;
       fEventListLock:TPasMPMultipleReaderSingleWriterLock;
       fEventList:TList;
       fDelayedEventQueueLock:TPasMPMultipleReaderSingleWriterLock;
       fDelayedEventQueue:TpvLinkedListHead;
       fEventQueueLock:TPasMPMultipleReaderSingleWriterLock;
       fEventQueue:TpvLinkedListHead;
       fDelayedFreeEventQueue:TpvLinkedListHead;
       fFreeEventQueueLock:TPasMPMultipleReaderSingleWriterLock;
       fFreeEventQueue:TpvLinkedListHead;
       fCurrentTime:TpvTime;
       fEventInProcessing:longbool;
       fEventRegistrationLock:TPasMPMultipleReaderSingleWriterLock;
       fEventRegistrationList:TList;
       fFreeEventRegistrationList:TList;
       fEventRegistrationStringIntegerPairHashMap:TWorldEventRegistrationStringIntegerPairHashMap;
       fOnEvent:TpvWorldOnEvent;
       function GetUUID:TpvUUID;
       procedure AddDelayedManagementEvent(const aDelayedManagementEvent:TpvDelayedManagementEvent); {$ifdef caninline}inline;{$endif}
       function GetComponentClassDataWrapper(const aComponentClass:TpvComponentClass):TpvComponentClassDataWrapper;
       function GetEntityByID(const aEntityID:TpvEntityID):TpvEntity;
       function GetEntityByUUID(const aEntityUUID:TpvUUID):TpvEntity;
       function DoCreateEntity(const aEntityID:TpvEntityID;const aEntityUUID:TpvUUID):boolean;
       function DoDestroyEntity(const aEntityID:TpvEntityID):boolean;
       procedure ProcessEvent(const aEvent:PpvEvent);
       procedure ProcessEvents;
       procedure ProcessDelayedEvents(const aDeltaTime:TpvTime);
       function CreateEntity(const aEntityID:TpvEntityID;const aEntityUUID:TpvUUID):TpvEntityID; overload;
      protected
      public
       constructor Create(const aResourceManager:TpvResourceManager;const aParent:TpvResource=nil;const aMetaResource:TpvMetaResource=nil;const aParallelLoadable:TpvResource.TParallelLoadable=TpvResource.TParallelLoadable.None); override;
       destructor Destroy; override;
       class function GetMetaResourceClass:TpvMetaResourceClass; override;
       procedure Kill;
       function CreateEvent(const aName:TpvUTF8String):TpvEventID;
       procedure DestroyEvent(const aEventID:TpvEventID);
       function FindEvent(const aName:TpvUTF8String):TpvEventID;
       procedure SubscribeToEvent(const aEventID:TpvEventID;const aEventHandler:TpvEventHandler);
       procedure UnsubscribeFromEvent(const aEventID:TpvEventID;const aEventHandler:TpvEventHandler);
       function CreateEntity(const aEntityUUID:TpvUUID):TpvEntityID; overload;
       function CreateEntity:TpvEntityID; overload;
       function HasEntity(const aEntityID:TpvEntityID):boolean; {$ifdef caninline}inline;{$endif}
       function IsEntityActive(const aEntityID:TpvEntityID):boolean; {$ifdef caninline}inline;{$endif}
       procedure ActivateEntity(const aEntityID:TpvEntityID); {$ifdef caninline}inline;{$endif}
       procedure DeactivateEntity(const aEntityID:TpvEntityID); {$ifdef caninline}inline;{$endif}
       procedure KillEntity(const aEntityID:TpvEntityID); {$ifdef caninline}inline;{$endif}
       procedure AddComponentToEntity(const aEntityID:TpvEntityID;const aComponent:TpvComponent);
       procedure RemoveComponentFromEntity(const aEntityID:TpvEntityID;const aComponentClass:TpvComponentClass); overload;
       procedure RemoveComponentFromEntity(const aEntityID:TpvEntityID;const aComponentClassID:TpvComponentClassID); overload;
       function HasEntityComponent(const aEntityID:TpvEntityID;const aComponentClass:TpvComponentClass):boolean; overload;
       function HasEntityComponent(const aEntityID:TpvEntityID;const aComponentClassID:TpvComponentClassID):boolean; overload;
       procedure AddSystem(const aSystem:TpvSystem);
       procedure RemoveSystem(const aSystem:TpvSystem);
       procedure SortSystem(const aSystem:TpvSystem);
       procedure Defragment;
       procedure Refresh;
       procedure QueueEvent(const aEventToQueue:TpvEvent;const aDeltaTime:TpvTime=0.0); overload;
       procedure Update(const aDeltaTime:TpvTime);
       procedure Clear;
       procedure ClearEntities;
       procedure Activate;
       procedure Deactivate;
       procedure MementoSerialize(const aStream:TStream);
       procedure MementoUnserialize(const aStream:TStream);
       function SerializeToJSON(const aEntityIDs:array of TpvEntityID;const aRootEntityID:TpvEntityID=-1):TPasJSONItem;
       function UnserializeFromJSON(const aJSONRootItem:TPasJSONItem;const aCreateNewUUIDs:boolean=false):TpvEntityID;
       function LoadFromStream(const aStream:TStream;const aCreateNewUUIDs:boolean=false):TpvEntityID;
       procedure SaveToStream(const aStream:TStream;const aEntityIDs:array of TpvEntityID;const aRootEntityID:TpvEntityID=-1);
       function LoadFromFile(const aFileName:TpvUTF8String;const aCreateNewUUIDs:boolean=false):TpvEntityID;
       procedure SaveToFile(const aFileName:TpvUTF8String;const aEntityIDs:array of TpvEntityID;const aRootEntityID:TpvEntityID=-1);
       function Assign(const aFrom:TpvWorld;const aEntityIDs:array of TpvEntityID;const aRootEntityID:TpvEntityID=-1;const aAssignOp:TpvWorldAssignOp=TpvWorldAssignOp.Replace):TpvEntityID;
       procedure Store;
       procedure Interpolate(const aAlpha:TpvDouble);
       property Universe:TpvUniverse read fUniverse;
       property ID:TpvWorldID read fID;
       property UUID:TpvUUID read GetUUID;
       property Active:longbool read fActive write fActive;
       property Killed:longbool read fKilled write fKilled;
       property SortKey:TpvInt32 read fSortKey write fSortKey;
{$ifdef PasVulkanEditor}
       property Tabsheet:pointer read fTabsheet write fTabsheet;
       property Form:pointer read fForm write fForm;
{$endif}
       property Components[const ComponentClass:TpvComponentClass]:TpvComponentClassDataWrapper read GetComponentClassDataWrapper;
       property Entities:TpvEntities read fEntities;
       property EntityByID[const ID:TpvEntityID]:TpvEntity read GetEntityByID;
       property EntityByUUID[const UUID:TpvUUID]:TpvEntity read GetEntityByUUID;
       property EntityIDCapacity:TpvInt32 read fEntityIDCounter;
       property CurrentTime:TpvTime read fCurrentTime;
       property OnEvent:TpvWorldOnEvent read fOnEvent write fOnEvent;
     end;

     TpvSortedWorldList=class(TList)
      private
       function GetWorld(const aIndex:TpvInt32):TpvWorld; inline;
       procedure SetWorld(const aIndex:TpvInt32;const AWorld:TpvWorld); inline;
      public
       constructor Create;
       destructor Destroy; override;
       property Items[const aIndex:TpvInt32]:TpvWorld read GetWorld write SetWorld; default;
     end;

     TpvWorldListIDWorldHashMap=class(TpvHashMap<TpvWorldID,TpvWorld>);

     TpvWorldListUUIDWorldHashMap=class(TpvHashMap<TpvUUID,TpvWorld>);

     TpvWorldListFileNameWorldHashMap=class(TpvStringHashMap<TpvWorld>);

     TpvWorldList=class(TList)
      private
       fIDWorldHashMap:TpvWorldListIDWorldHashMap;
       fUUIDWorldHashMap:TpvWorldListUUIDWorldHashMap;
       fFileNameWorldHashMap:TpvWorldListFileNameWorldHashMap;
       function GetWorld(const aIndex:TpvInt32):TpvWorld; inline;
       procedure SetWorld(const aIndex:TpvInt32;const aWorld:TpvWorld); inline;
       function GetWorldByID(const aID:TpvWorldID):TpvWorld; inline;
       function GetWorldByUUID(const aUUID:TpvUUID):TpvWorld; inline;
       function GetWorldByFileName(const aFileName:TpvUTF8String):TpvWorld; inline;
      public
       constructor Create;
       destructor Destroy; override;
       property Items[const aIndex:TpvInt32]:TpvWorld read GetWorld write SetWorld; default;
       property WorldByID[const aID:TpvWorldID]:TpvWorld read GetWorldByID;
       property WorldByUUID[const aUUID:TpvUUID]:TpvWorld read GetWorldByUUID;
       property WorldByFileName[const aFileName:TpvUTF8String]:TpvWorld read GetWorldByFileName;
     end;

     { TpvUniverse }

     TpvUniverse=class(TpvObject)
      private
       fRegisteredComponentClasses:TpvRegisteredComponentClassList;
       fWorlds:TpvWorldList;
       fWorldIDManager:TpvWorldIDManager;
      public
       constructor Create;
       destructor Destroy; override;
       class procedure GlobalInitialize; static;
       class procedure GlobalFinalize; static;
       procedure RegisterComponent(const aComponentClass:TpvComponentClass);
       procedure UnregisterComponent(const aComponentClass:TpvComponentClass);
       procedure ScanWorlds;
       procedure Initialize;
       procedure Finalize;
       property RegisteredComponentClasses:TpvRegisteredComponentClassList read fRegisteredComponentClasses;
       property Worlds:TpvWorldList read fWorlds;
     end;

var AvailableComponents:TList=nil;

procedure AddAvailableComponent(const aComponentClass:TpvComponentClass);

implementation

uses PasVulkan.Application,
     PasVulkan.Utils,
     PasVulkan.EntityComponentSystem.BaseComponents,
     PasVulkan.Components.Prefab.Instance;

function RoundUpToPowerOfTwo(Value:TpvPtrUInt):TpvPtrUInt;
begin
 dec(Value);
 Value:=Value or (Value shr 1);
 Value:=Value or (Value shr 2);
 Value:=Value or (Value shr 4);
 Value:=Value or (Value shr 8);
 Value:=Value or (Value shr 16);
{$ifdef CPU64}
 Value:=Value or (Value shr 32);
{$endif}
 result:=Value+1;
end;

function IntLog2(x:TpvUInt32):TpvUInt32; {$ifdef cpu386}assembler; {$ifdef fpc}nostackframe;{$else}register;{$endif}
asm
 test eax,eax
 jz @Done
 bsr eax,eax
 @Done:
end;{$else}{$ifdef cpux86_64}assembler; {$ifdef fpc}nostackframe;{$else}register;{$endif}
asm
{$ifdef Windows}
 mov eax,ecx
{$else}
 mov eax,edi
{$endif}
 test eax,eax
 jz @Done
 bsr eax,eax
 @Done:
end;
{$else}
begin
 x:=x or (x shr 1);
 x:=x or (x shr 2);
 x:=x or (x shr 4);
 x:=x or (x shr 8);
 x:=x or (x shr 16);
 x:=x shr 1;
 x:=x-((x shr 1) and $55555555);
 x:=((x shr 2) and $33333333)+(x and $33333333);
 x:=((x shr 4)+x) and $0f0f0f0f;
 x:=x+(x shr 8);
 x:=x+(x shr 16);
 result:=x and $3f;
end;
{$endif}
{$endif}

constructor TpvEventRegistration.Create(const aEventID:TpvEventID;const aName:TpvUTF8String);
begin
 inherited Create;
 fEventID:=aEventID;
 fName:=aName;
 fActive:=false;
 fLock:=TPasMPMultipleReaderSingleWriterLock.Create;
 fSystemList:=TList.Create;
 fEventHandlers:=nil;
 fCountEventHandlers:=0;
end;

destructor TpvEventRegistration.Destroy;
begin
 fName:='';
 SetLength(fEventHandlers,0);
 fSystemList.Free;
 fLock.Free;
 inherited Destroy;
end;

procedure TpvEventRegistration.Clear;
begin
 fLock.AcquireWrite;
 try
  fName:='';
  fActive:=false;
  fSystemList.Clear;
  SetLength(fEventHandlers,0);
  fCountEventHandlers:=0;
 finally
  fLock.ReleaseWrite;
 end;
end;

procedure TpvEventRegistration.AddSystem(const aSystem:TpvSystem);
begin
 fLock.AcquireRead;
 try
  if fSystemList.IndexOf(aSystem)<0 then begin
   fLock.ReadToWrite;
   try
    fSystemList.Add(aSystem);
   finally
    fLock.WriteToRead;
   end;
  end;
 finally
  fLock.ReleaseRead;
 end;
end;

procedure TpvEventRegistration.RemoveSystem(const aSystem:TpvSystem);
var Index:TpvInt32;
begin
 fLock.AcquireRead;
 try
  Index:=fSystemList.IndexOf(aSystem);
  if Index>=0 then begin
   fLock.ReadToWrite;
   try
    fSystemList.Delete(Index);
   finally
    fLock.WriteToRead;
   end;
  end;
 finally
  fLock.ReleaseRead;
 end;
end;

procedure TpvEventRegistration.AddEventHandler(const aEventHandler:TpvEventHandler);
var Index:TpvInt32;
    Found:boolean;
begin
 Found:=false;
 fLock.AcquireRead;
 try
  for Index:=0 to fCountEventHandlers-1 do begin
   if (TMethod(fEventHandlers[Index]).Code=TMethod(aEventHandler).Code) and
      (TMethod(fEventHandlers[Index]).Data=TMethod(aEventHandler).Data) then begin
    Found:=true;
    break;
   end;
  end;
  if not Found then begin
   fLock.ReadToWrite;
   try
    Index:=fCountEventHandlers;
    inc(fCountEventHandlers);
    if length(fEventHandlers)<fCountEventHandlers then begin
     SetLength(fEventHandlers,fCountEventHandlers*2);
    end;
    fEventHandlers[Index]:=aEventHandler;
   finally
    fLock.WriteToRead;
   end;
  end;
 finally
  fLock.ReleaseRead;
 end;
end;

procedure TpvEventRegistration.RemoveEventHandler(const aEventHandler:TpvEventHandler);
var Index:TpvInt32;
begin
 fLock.AcquireRead;
 try
  for Index:=0 to fCountEventHandlers-1 do begin
   if (TMethod(fEventHandlers[Index]).Code=TMethod(aEventHandler).Code) and
      (TMethod(fEventHandlers[Index]).Data=TMethod(aEventHandler).Data) then begin
    fLock.ReadToWrite;
    try
     dec(fCountEventHandlers);
     if fCountEventHandlers>0 then begin
      Move(fEventHandlers[Index+1],fEventHandlers[Index],fCountEventHandlers*SizeOf(TpvEventHandler)); // for to be keep the ordering
//    fEventHandlers[Index]:=fEventHandlers[fCountEventHandlers]; // for to be faster
     end;
    finally
     fLock.WriteToRead;
    end;
    break;
   end;
  end;
 finally
  fLock.ReleaseRead;
 end;
end;

constructor TpvComponent.Create;
begin
 inherited Create;
end;

destructor TpvComponent.Destroy;
begin
 inherited Destroy;
end;

class function TpvComponent.ClassID:TpvComponentClassID;
begin
 result:=PpvPooledObjectClassMetaInfo(pointer(GetClassMetaInfo))^.ID;
end;

class procedure TpvComponent.SetClassID(const aID:TpvComponentClassID);
begin
 PpvPooledObjectClassMetaInfo(pointer(GetClassMetaInfo))^.ID:=aID;
end;

class function TpvComponent.ClassPath:string;
begin
 result:='';
end;

class function TpvComponent.ClassUUID:TpvUUID;
begin
 result:=TpvUUID.Null;
end;

class function TpvComponent.ClassInstanceMemoryCopyable:boolean;
begin
 result:=false;
end;

class function TpvComponent.HasSpecialJSONSerialization:boolean;
begin
 result:=false;
end;

function TpvComponent.SpecialJSONSerialization:TPasJSONItem;
begin
 result:=nil;
end;

procedure TpvComponent.SpecialJSONUnserialization(const aJSONItem:TPasJSONItem);
begin
end;

function TpvComponent.BinarySerializationSize:TpvSizeInt;
begin
 result:=0;
end;

procedure TpvComponent.BinarySerialize(const aStream:TStream);
begin
end;

procedure TpvComponent.BinaryUnserialize(const aStream:TStream);
begin
end;

procedure TpvComponent.MementoSerialize(const aStream:TStream);
var TemporaryStream:TMemoryStream;
    MappedStream:TpvSimpleBufferedStream;
 procedure WriteInt64Ex(const aValue:TpvInt64);
 begin
  aStream.Write(aValue,SizeOf(TpvInt64));
 end;
 procedure WriteInt8(const aValue:TpvInt8);
 begin
  MappedStream.Write(aValue,SizeOf(TpvInt8));
 end;
 procedure WriteInt16(const aValue:TpvInt16);
 begin
  MappedStream.Write(aValue,SizeOf(TpvInt16));
 end;
 procedure WriteInt32(const aValue:TpvInt32);
 begin
  MappedStream.Write(aValue,SizeOf(TpvInt32));
 end;
 procedure WriteInt64(const aValue:TpvInt64);
 begin
  MappedStream.Write(aValue,SizeOf(TpvInt64));
 end;
 procedure WriteUInt8(const aValue:TpvUInt8);
 begin
  MappedStream.Write(aValue,SizeOf(TpvUInt8));
 end;
 procedure WriteUInt16(const aValue:TpvUInt16);
 begin
  MappedStream.Write(aValue,SizeOf(TpvUInt16));
 end;
 procedure WriteUInt32(const aValue:TpvUInt32);
 begin
  MappedStream.Write(aValue,SizeOf(TpvUInt32));
 end;
 procedure WriteUInt64(const aValue:TpvUInt64);
 begin
  MappedStream.Write(aValue,SizeOf(TpvUInt64));
 end;
 procedure WriteFloat(const aValue:TpvFloat);
 begin
  MappedStream.Write(aValue,SizeOf(TpvFloat));
 end;
 procedure WriteDouble(const aValue:TpvDouble);
 begin
  MappedStream.Write(aValue,SizeOf(TpvDouble));
 end;
 procedure WriteString(const aValue:UnicodeString);
 var s:UTF8String;
 begin
  s:=PUCUUTF16ToUTF8(aValue);
  WriteInt32(length(s));
  if length(s)>0 then begin
   MappedStream.Write(s[1],length(s)*SizeOf(AnsiChar));
  end;
 end;
 procedure SerializeObject(const AObject:TObject);
 var PropCount,Index,SubIndex:TpvInt32;
     Value32:TpvUInt32;
     PropList:PPropList;
     PropInfo:PPropInfo;
     EntityID:TpvEntityID;
     EntityIDs:TpvComponentDataEntityIDs;
     PrefabInstanceEntityComponentPropertyList:TpvComponentPrefabInstanceEntityComponentPropertyList;
     PrefabInstanceEntityComponentProperty:TpvComponentPrefabInstanceEntityComponentProperty;
 begin
  if assigned(AObject) then begin
   PropList:=nil;
   try
    PropCount:=TypInfo.GetPropList(AObject,PropList);
    if PropCount>0 then begin
     for Index:=0 to PropCount-1 do begin
      PropInfo:=PropList^[Index];
      if assigned(PropInfo^.PropType) then begin
       //WriteInt32(TpvInt32(PropInfo^.PropType^.Kind));
       if PropInfo^.PropType=TypeInfo(TpvEntityID) then begin
        EntityID:=TypInfo.GetInt64Prop(AObject,PropInfo);
        WriteInt32(EntityID);
       end else if PropInfo^.PropType=TypeInfo(TpvComponentDataEntityIDs) then begin
        EntityIDs:=TpvComponentDataEntityIDs(TypInfo.GetObjectProp(AObject,PropInfo));
        if assigned(EntityIDs) then begin
         WriteInt32(EntityIDs.Count);
         for SubIndex:=0 to EntityIDs.Count-1 do begin
          EntityID:=EntityIDs.Items[SubIndex];
          WriteInt32(EntityID);
         end;
        end else begin
         WriteInt32(0);
        end;
       end else if PropInfo^.PropType=TypeInfo(TpvComponentPrefabInstanceEntityComponentPropertyList) then begin
        PrefabInstanceEntityComponentPropertyList:=TpvComponentPrefabInstanceEntityComponentPropertyList(TypInfo.GetObjectProp(AObject,PropInfo));
        if assigned(PrefabInstanceEntityComponentPropertyList) then begin
         WriteInt32(PrefabInstanceEntityComponentPropertyList.Count);
         for SubIndex:=0 to PrefabInstanceEntityComponentPropertyList.Count-1 do begin
          PrefabInstanceEntityComponentProperty:=PrefabInstanceEntityComponentPropertyList.Items[SubIndex];
          Value32:=0;
          if TpvComponentPrefabInstanceEntityComponentProperty.TpvComponentPrefabInstanceEntityComponentPropertyFlag.cpiecpfOverwritten in PrefabInstanceEntityComponentProperty.Flags then begin
           Value32:=Value32 or 1;
          end;
          WriteUInt32(Value32);
{$ifdef cpu64}
          WriteUInt64(TpvPtrInt(pointer(PrefabInstanceEntityComponentProperty.ComponentClass)));
          WriteUInt64(TpvPtrInt(pointer(PrefabInstanceEntityComponentProperty.PropInfo)));
{$else}
          WriteUInt32(TpvPtrInt(pointer(PrefabInstanceEntityComponentProperty.ComponentClass)));
          WriteUInt32(TpvPtrInt(pointer(PrefabInstanceEntityComponentProperty.PropInfo)));
{$endif}
         end;
        end else begin
         WriteInt32(0);
        end;
       end else begin
        case PropInfo^.PropType^.Kind of
         tkUnknown:begin
         end;
         tkInteger:begin
          if PropInfo^.PropType=TypeInfo(TpvInt8) then begin
           WriteInt8(TypInfo.GetOrdProp(AObject,PropInfo));
          end else if PropInfo^.PropType=TypeInfo(TpvUInt8) then begin
           WriteUInt8(TypInfo.GetOrdProp(AObject,PropInfo));
          end else if PropInfo^.PropType=TypeInfo(TpvInt16) then begin
           WriteInt16(TypInfo.GetOrdProp(AObject,PropInfo));
          end else if PropInfo^.PropType=TypeInfo(TpvUInt16) then begin
           WriteUInt16(TypInfo.GetOrdProp(AObject,PropInfo));
          end else if PropInfo^.PropType=TypeInfo(TpvInt32) then begin
           WriteInt32(TypInfo.GetOrdProp(AObject,PropInfo));
          end else if PropInfo^.PropType=TypeInfo(TpvUInt32) then begin
           WriteUInt32(TypInfo.GetOrdProp(AObject,PropInfo));
          end else if PropInfo^.PropType=TypeInfo(TpvInt64) then begin
           WriteInt64(TypInfo.GetOrdProp(AObject,PropInfo));
          end else begin
           WriteUInt64(TypInfo.GetOrdProp(AObject,PropInfo));
          end;
         end;
         tkInt64:begin
          WriteInt64(TypInfo.GetInt64Prop(AObject,PropInfo));
         end;
{$ifdef fpc}
         tkQWord:begin
          WriteUInt64(TypInfo.GetOrdProp(AObject,PropInfo));
         end;
{$endif}
         tkChar:begin
          WriteUInt8(word(TypInfo.GetOrdProp(AObject,PropInfo)));
         end;
         tkWChar{$ifdef fpc},tkUChar{$endif}:begin
          WriteUInt16(word(TypInfo.GetOrdProp(AObject,PropInfo)));
         end;
         tkEnumeration:begin
          WriteInt64(TypInfo.GetOrdProp(AObject,PropInfo));
         end;
         tkFloat:begin
          if {$ifdef fpc}GetTypeData(PropInfo^.PropType)^.FloatType=ftSingle{$else}GetTypeData(PropInfo^.PropType^)^.FloatType=ftSingle{$endif} then begin
           WriteFloat(TypInfo.GetFloatProp(AObject,PropInfo));
          end else begin
           WriteDouble(TypInfo.GetFloatProp(AObject,PropInfo));
          end;
         end;
         tkSet:begin
          WriteInt64(TypInfo.GetOrdProp(AObject,PropInfo));
         end;
         {$ifdef fpc}tkSString,{$endif}tkLString,{$ifdef fpc}tkAString,{$endif}tkWString,tkUString:begin
          WriteString(TypInfo.GetUnicodeStrProp(AObject,PropInfo));
         end;
         tkClass:begin
          SerializeObject(TypInfo.GetObjectProp(AObject,PropInfo));
         end;
{$ifdef fpc}
         tkBool:begin
          WriteUInt8(TypInfo.GetOrdProp(AObject,PropInfo));
         end;
{$endif}
         else begin
         end;
        end;
       end;
      end;
     end;
    end;
   finally
    if assigned(PropList) then begin
     FreeMem(PropList);
    end;
   end;
  end;
 end;
begin
 if ClassInstanceMemoryCopyable then begin
  aStream.WriteBuffer(pointer(self)^,InstanceSize);
 end else begin
  TemporaryStream:=TMemoryStream.Create;
  try
   MappedStream:=TpvSimpleBufferedStream.Create(TemporaryStream,false,4096);
   try
    SerializeObject(self);
   finally
    MappedStream.Free;
   end;
   WriteInt64Ex(TemporaryStream.Size);
   if TemporaryStream.Seek(0,soBeginning)=0 then begin
    aStream.CopyFrom(TemporaryStream,TemporaryStream.Size);
   end;
  finally
   TemporaryStream.Free;
  end;
 end;
end;

procedure TpvComponent.MementoUnserialize(const aStream:TStream);
var MappedStream:TpvChunkStream;
 function ReadInt64Ex:TpvInt64;
 begin
  if aStream.Read(result,SizeOf(TpvInt64))<>SizeOf(TpvInt64) then begin
   raise EInOutError.Create('Stream read error');
  end;
 end;
 function ReadInt8:TpvInt32;
 begin
  MappedStream.ReadWithCheck(result,SizeOf(TpvInt8));
 end;
 function ReadInt16:TpvInt32;
 begin
  MappedStream.ReadWithCheck(result,SizeOf(TpvInt16));
 end;
 function ReadInt32:TpvInt32;
 begin
  MappedStream.ReadWithCheck(result,SizeOf(TpvInt32));
 end;
 function ReadInt64:TpvInt64;
 begin
  MappedStream.ReadWithCheck(result,SizeOf(TpvInt64));
 end;
 function ReadUInt8:TpvUInt8;
 begin
  MappedStream.ReadWithCheck(result,SizeOf(TpvUInt8));
 end;
 function ReadUInt16:TpvUInt16;
 begin
  MappedStream.ReadWithCheck(result,SizeOf(TpvUInt16));
 end;
 function ReadUInt32:TpvUInt32;
 begin
  MappedStream.ReadWithCheck(result,SizeOf(TpvUInt32));
 end;
 function ReadUInt64:TpvUInt64;
 begin
  MappedStream.ReadWithCheck(result,SizeOf(TpvUInt64));
 end;
 function ReadFloat:TpvFloat;
 begin
  MappedStream.ReadWithCheck(result,SizeOf(TpvFloat));
 end;
 function ReadDouble:TpvDouble;
 begin
  MappedStream.ReadWithCheck(result,SizeOf(TpvDouble));
 end;
 function ReadString:UnicodeString;
 var s:UTF8String;
 begin
  s:='';
  SetLength(s,ReadInt32);
  if length(s)>0 then begin
   MappedStream.ReadWithCheck(s[1],length(s)*SizeOf(AnsiChar));
  end;
  result:=PUCUUTF8ToUTF16(s);
 end;
 procedure UnserializeObject(const AObject:TObject);
 var PropCount,Index,SubIndex,Count:TpvInt32;
     Value32:TpvUInt32;
     PropList:PPropList;
     PropInfo:PPropInfo;
     EntityID:TpvEntityID;
     EntityIDs:TpvComponentDataEntityIDs;
     PrefabInstanceEntityComponentPropertyList:TpvComponentPrefabInstanceEntityComponentPropertyList;
     PrefabInstanceEntityComponentProperty:TpvComponentPrefabInstanceEntityComponentProperty;
     SubObject:TObject;
 begin
  if assigned(AObject) then begin
   PropList:=nil;
   try
    PropCount:=TypInfo.GetPropList(AObject,PropList);
    if PropCount>0 then begin
     for Index:=0 to PropCount-1 do begin
      PropInfo:=PropList^[Index];
      if assigned(PropInfo^.PropType) then begin
       {if TpvInt32(PropInfo^.PropType^.Kind)<>ReadInt32 then begin
        raise EInOutError.Create('Corrupt stream');
       end;}
       if PropInfo^.PropType=TypeInfo(TpvEntityID) then begin
        EntityID:=ReadInt32;
        TypInfo.SetInt64Prop(AObject,PropInfo,EntityID);
       end else if PropInfo^.PropType=TypeInfo(TpvComponentDataEntityIDs) then begin
        EntityIDs:=TpvComponentDataEntityIDs(TypInfo.GetObjectProp(AObject,PropInfo));
        if assigned(EntityIDs) then begin
         EntityIDs.Clear;
        end else begin
         EntityIDs:=TpvComponentDataEntityIDs.Create;
         TypInfo.SetObjectProp(AObject,PropInfo,EntityIDs);
        end;
        Count:=ReadInt32;
        for SubIndex:=0 to Count-1 do begin
         EntityID:=ReadInt32;
         EntityIDs.Add(EntityID);
        end;
       end else if PropInfo^.PropType=TypeInfo(TpvComponentPrefabInstanceEntityComponentPropertyList) then begin
        PrefabInstanceEntityComponentPropertyList:=TpvComponentPrefabInstanceEntityComponentPropertyList(TypInfo.GetObjectProp(AObject,PropInfo));
        if assigned(PrefabInstanceEntityComponentPropertyList) then begin
         PrefabInstanceEntityComponentPropertyList.Clear;
        end else begin
         PrefabInstanceEntityComponentPropertyList:=TpvComponentPrefabInstanceEntityComponentPropertyList.Create;
         TypInfo.SetObjectProp(AObject,PropInfo,PrefabInstanceEntityComponentPropertyList);
        end;
        Count:=ReadInt32;
        for SubIndex:=0 to Count-1 do begin
         PrefabInstanceEntityComponentProperty:=TpvComponentPrefabInstanceEntityComponentProperty.Create;
         PrefabInstanceEntityComponentPropertyList.Add(PrefabInstanceEntityComponentProperty);
         Value32:=ReadUInt32;
         PrefabInstanceEntityComponentProperty.Flags:=[];
         if (Value32 and 1)<>0 then begin
          PrefabInstanceEntityComponentProperty.Flags:=PrefabInstanceEntityComponentProperty.Flags+[TpvComponentPrefabInstanceEntityComponentProperty.TpvComponentPrefabInstanceEntityComponentPropertyFlag.cpiecpfOverwritten];
         end;
{$ifdef cpu64}
         PrefabInstanceEntityComponentProperty.ComponentClass:=pointer(TpvPtrInt(ReadUInt64));
         PrefabInstanceEntityComponentProperty.PropInfo:=pointer(TpvPtrInt(ReadUInt64));
{$else}
         PrefabInstanceEntityComponentProperty.ComponentClass:=pointer(TpvPtrInt(ReadUInt32));
         PrefabInstanceEntityComponentProperty.PropInfo:=pointer(TpvPtrInt(ReadUInt32));
{$endif}
        end;
       end else begin
        case PropInfo^.PropType^.Kind of
         tkUnknown:begin
         end;
         tkInteger:begin
          if PropInfo^.PropType=TypeInfo(TpvInt8) then begin
           TypInfo.SetOrdProp(AObject,PropInfo,ReadInt8);
          end else if PropInfo^.PropType=TypeInfo(TpvUInt8) then begin
           TypInfo.SetOrdProp(AObject,PropInfo,ReadUInt8);
          end else if PropInfo^.PropType=TypeInfo(TpvInt16) then begin
           TypInfo.SetOrdProp(AObject,PropInfo,ReadInt16);
          end else if PropInfo^.PropType=TypeInfo(TpvUInt16) then begin
           TypInfo.SetOrdProp(AObject,PropInfo,ReadUInt16);
          end else if PropInfo^.PropType=TypeInfo(TpvInt32) then begin
           TypInfo.SetOrdProp(AObject,PropInfo,ReadInt32);
          end else if PropInfo^.PropType=TypeInfo(TpvUInt32) then begin
           TypInfo.SetOrdProp(AObject,PropInfo,ReadUInt32);
          end else if PropInfo^.PropType=TypeInfo(TpvInt64) then begin
           TypInfo.SetOrdProp(AObject,PropInfo,ReadInt64);
          end else begin
           TypInfo.SetOrdProp(AObject,PropInfo,ReadUInt64);
          end;
         end;
         tkInt64:begin
          TypInfo.SetInt64Prop(AObject,PropInfo,ReadInt64);
         end;
{$ifdef fpc}
         tkQWord:begin
          TypInfo.SetOrdProp(AObject,PropInfo,ReadUInt64);
         end;
{$endif}
         tkChar:begin
          TypInfo.SetOrdProp(AObject,PropInfo,ReadUInt8);
         end;
         tkWChar{$ifdef fpc},tkUChar{$endif}:begin
          TypInfo.SetOrdProp(AObject,PropInfo,ReadUInt16);
         end;
         tkEnumeration:begin
          TypInfo.SetOrdProp(AObject,PropInfo,ReadInt64);
         end;
         tkFloat:begin
          if {$ifdef fpc}GetTypeData(PropInfo^.PropType)^.FloatType=ftSingle{$else}GetTypeData(PropInfo^.PropType^)^.FloatType=ftSingle{$endif} then begin
           TypInfo.SetFloatProp(AObject,PropInfo,ReadFloat);
          end else begin
           TypInfo.SetFloatProp(AObject,PropInfo,ReadDouble);
          end;
         end;
         tkSet:begin
          TypInfo.SetOrdProp(AObject,PropInfo,ReadInt64);
         end;
         {$ifdef fpc}tkSString,{$endif}tkLString,{$ifdef fpc}tkAString,{$endif}tkWString,tkUString:begin
          TypInfo.SetUnicodeStrProp(AObject,PropInfo,ReadString);
         end;
         tkClass:begin
          SubObject:=TypInfo.GetObjectProp(AObject,PropInfo);
          if not assigned(SubObject) then begin
           SubObject:=TypInfo.GetObjectPropClass(AObject,PropInfo^.Name).Create;
           TypInfo.SetObjectProp(AObject,PropInfo,SubObject);
          end;
          UnserializeObject(SubObject);
         end;
{$ifdef fpc}
         tkBool:begin
          TypInfo.SetOrdProp(AObject,PropInfo,ReadUInt8);
         end;
{$endif}
         else begin
         end;
        end;
       end;
      end;
     end;
    end;
   finally
    if assigned(PropList) then begin
     FreeMem(PropList);
    end;
   end;
  end;
 end;
var Offset,Size:TpvInt64;
begin
 if ClassInstanceMemoryCopyable then begin
  aStream.ReadBuffer(pointer(self)^,InstanceSize);
 end else begin
  Size:=ReadInt64Ex;
  Offset:=aStream.Position;
  MappedStream:=TpvChunkStream.Create(aStream,Offset,Size,true);
  try
   MappedStream.Seek(0,soBeginning);
   UnserializeObject(self);
  finally
   MappedStream.Free;
  end;
  if aStream.Seek(Offset+Size,soBeginning)<>(Offset+Size) then begin
   raise EInOutError.Create('Stream seek error');
  end;
 end;
end;

procedure TpvComponent.Assign(const aFrom:TpvComponent;const aEntityIDs:TpvEntityIDs=nil);
 procedure CopyProperties;
 var PropCount,PropIndex,ItemIndex:TpvInt32;
     EntityID:TpvEntityID;
     PropList:PPropList;
     PropInfo:PPropInfo;
     SrcEntityIDs,DstEntityIDs:TpvComponentDataEntityIDs;
     SubSrcObject,SubDstObject:TObject;
     ComponentClass:TpvComponentClass;
 begin
  ComponentClass:=TpvComponentClass(ClassType);
  try
   PropCount:=TypInfo.GetPropList({$ifdef fpc}ComponentClass{$else}self{$endif},PropList);
   if PropCount>0 then begin
    for PropIndex:=0 to PropCount-1 do begin
     PropInfo:=PropList^[PropIndex];
     if assigned(PropInfo^.PropType) then begin
      if PropInfo^.PropType=TypeInfo(TpvEntityID) then begin
       EntityID:=TypInfo.GetInt64Prop(aFrom,PropInfo);
       if (EntityID>=0) and (EntityID<length(aEntityIDs)) then begin
        EntityID:=aEntityIDs[EntityID];
       end;
       TypInfo.SetInt64Prop(self,PropInfo,EntityID);
      end else if PropInfo^.PropType=TypeInfo(TpvComponentDataEntityIDs) then begin
       SrcEntityIDs:=TpvComponentDataEntityIDs(TypInfo.GetObjectProp(aFrom,PropInfo));
       DstEntityIDs:=TpvComponentDataEntityIDs(TypInfo.GetObjectProp(self,PropInfo));
       if assigned(DstEntityIDs) then begin
        DstEntityIDs.Clear;
       end else begin
        DstEntityIDs:=TpvComponentDataEntityIDs.Create;
        TypInfo.SetObjectProp(self,PropInfo,DstEntityIDs);
       end;
       if assigned(SrcEntityIDs) then begin
        for ItemIndex:=0 to SrcEntityIDs.Count-1 do begin
         EntityID:=SrcEntityIDs.Items[ItemIndex];
         if (EntityID>=0) and (EntityID<length(aEntityIDs)) then begin
          EntityID:=aEntityIDs[EntityID];
         end;
         DstEntityIDs.Add(EntityID);
        end;
       end;
      end else begin
       case PropInfo^.PropType^.Kind of
        tkUnknown:begin
        end;
        tkInteger:begin
         TypInfo.SetOrdProp(self,PropInfo,TypInfo.GetOrdProp(aFrom,PropInfo));
        end;
        tkInt64:begin
         TypInfo.SetInt64Prop(self,PropInfo,TypInfo.GetInt64Prop(aFrom,PropInfo));
        end;
{$ifdef fpc}
        tkQWord:begin
         TypInfo.SetOrdProp(self,PropInfo,TypInfo.GetOrdProp(aFrom,PropInfo));
        end;
{$endif}
        tkChar:begin
         TypInfo.SetOrdProp(self,PropInfo,TypInfo.GetOrdProp(aFrom,PropInfo));
        end;
        tkWChar{$ifdef fpc},tkUChar{$endif}:begin
         TypInfo.SetOrdProp(self,PropInfo,TypInfo.GetOrdProp(aFrom,PropInfo));
        end;
        tkEnumeration:begin
         TypInfo.SetOrdProp(self,PropInfo,TypInfo.GetOrdProp(aFrom,PropInfo));
        end;
        tkFloat:begin
         TypInfo.SetFloatProp(self,PropInfo,TypInfo.GetFloatProp(aFrom,PropInfo));
        end;
        tkSet:begin
         TypInfo.SetOrdProp(self,PropInfo,TypInfo.GetOrdProp(aFrom,PropInfo));
        end;
        {$ifdef fpc}tkSString,{$endif}tkLString,{$ifdef fpc}tkAString,{$endif}tkWString,tkUString:begin
         TypInfo.SetUnicodeStrProp(self,PropInfo,TypInfo.GetUnicodeStrProp(aFrom,PropInfo));
        end;
        tkClass:begin
         SubSrcObject:=TypInfo.GetObjectProp(aFrom,PropInfo);
         if assigned(SubSrcObject) then begin
          if SubSrcObject is TPersistent then begin
           SubDstObject:=TypInfo.GetObjectProp(self,PropInfo);
           if not assigned(SubDstObject) then begin
            SubDstObject:=TypInfo.GetObjectPropClass(self,PropInfo^.Name).Create;
            TypInfo.SetObjectProp(self,PropInfo,SubDstObject);
           end;
           TPersistent(SubDstObject).Assign(TPersistent(SubSrcObject));
          end;
         end;
        end;
{$ifdef fpc}
        tkBool:begin
         TypInfo.SetOrdProp(self,PropInfo,TypInfo.GetOrdProp(aFrom,PropInfo));
        end;
{$endif}
        else begin
        end;
       end;
      end;
     end;
    end;
   end;
  finally
   if assigned(PropList) then begin
    FreeMem(PropList);
   end;
  end;
 end;
begin
 if assigned(aFrom) and (aFrom is TpvComponent) then begin
  if ClassInstanceMemoryCopyable and (aFrom.ClassType=ClassType) then begin
   Move(pointer(aFrom)^,pointer(self)^,InstanceSize);
  end else begin
   CopyProperties;
  end;
 end;
end;

constructor TpvComponentList.Create;
begin
 inherited Create;
end;

destructor TpvComponentList.Destroy;
begin
 inherited Destroy;
end;

function TpvComponentList.GetComponent(const aIndex:TpvInt32):TpvComponent;
begin
 result:=pointer(inherited Items[aIndex]);
end;

procedure TpvComponentList.SetComponent(const aIndex:TpvInt32;const aComponent:TpvComponent);
begin
 inherited Items[aIndex]:=pointer(aComponent);
end;

constructor TpvComponentClassDataWrapper.Create(const aWorld:TpvWorld;const aComponentClass:TpvComponentClass);
begin
 inherited Create;
 fWorld:=aWorld;
 fComponentClass:=TpvComponentClass(aComponentClass);
 fComponentClassID:=fComponentClass.ClassID;
end;

destructor TpvComponentClassDataWrapper.Destroy;
begin
 inherited Destroy;
end;

function TpvComponentClassDataWrapper.GetComponentByEntityID(const aEntityID:TpvEntityID):TpvComponent;
var Entity:TpvEntity;
begin
 Entity:=fWorld.EntityByID[aEntityID];
 if assigned(Entity) then begin
  result:=Entity.GetComponent(fComponentClass);
 end else begin
  result:=nil;
 end;
end;

constructor TpvRegisteredComponentClassList.Create;
begin
 inherited Create;
 fComponentClassNameStringIntegerPairHashMap:=TRegisteredComponentClassListNameIndexHashMap.Create(-1);
 fComponentClassUUIDIntegerPairHashMap:=TRegisteredComponentClassListUUIDIndexHashMap.Create(-1);
 fComponentIDHashMap:=TRegisteredComponentClassListComponentIDHashMap.Create(-1);
 fCountDeleted:=0;
end;

destructor TpvRegisteredComponentClassList.Destroy;
begin
 fComponentClassNameStringIntegerPairHashMap.Free;
 fComponentClassUUIDIntegerPairHashMap.Free;
 fComponentIDHashMap.Free;
 inherited Destroy;
end;

function TpvRegisteredComponentClassList.GetComponentClass(const aIndex:TpvInt32):TpvComponentClass;
begin
 result:=pointer(inherited Items[aIndex]);
end;

procedure TpvRegisteredComponentClassList.SetComponentClass(const aIndex:TpvInt32;const aComponentClass:TpvComponentClass);
begin
 inherited Items[aIndex]:=pointer(aComponentClass);
end;

function TpvRegisteredComponentClassList.GetComponentClassByName(const aComponentClassName:TpvUTF8String):TpvComponentClass;
var Index:TpvInt32;
begin
 Index:=fComponentClassNameStringIntegerPairHashMap.Values[LowerCase(aComponentClassName)];
 if Index>=0 then begin
  result:=GetComponentClass(Index);
 end else begin
  result:=nil;
 end;
end;

function TpvRegisteredComponentClassList.GetComponentClassByUUID(const aComponentClassUUID:TpvUUID):TpvComponentClass;
var Index:TpvInt32;
begin
 Index:=fComponentClassUUIDIntegerPairHashMap.Values[aComponentClassUUID];
 if Index>=0 then begin
  result:=GetComponentClass(Index);
 end else begin
  result:=nil;
 end;
end;

procedure TpvRegisteredComponentClassList.SetComponentClassByName(const aComponentClassName:TpvUTF8String;const aComponentClass:TpvComponentClass);
begin
 SetComponentClass(fComponentClassNameStringIntegerPairHashMap.Values[LowerCase(aComponentClassName)],aComponentClass);
end;

procedure TpvRegisteredComponentClassList.SetComponentClassByUUID(const aComponentClassUUID:TpvUUID;const aComponentClass:TpvComponentClass);
begin
 SetComponentClass(fComponentClassUUIDIntegerPairHashMap.Values[aComponentClassUUID],aComponentClass);
end;

function TpvRegisteredComponentClassList.GetComponentClassID(const aComponentClass:TpvComponentClass):TpvComponentClassID;
begin
 result:=fComponentIDHashMap.Values[aComponentClass];
end;

function TpvRegisteredComponentClassList.Add(const aComponentClass:TpvComponentClass):TpvComponentClassID;
begin
 Assert(assigned(aComponentClass));
 aComponentClass.InitializeObjectClassMetaInfo;
 if fCountDeleted>0 then begin
  dec(fCountDeleted);
  result:=inherited IndexOf(nil);
 end else begin
  result:=-1;
 end;
 if result>=0 then begin
  inherited Items[result]:=aComponentClass;
 end else begin
  result:=inherited Add(aComponentClass);
 end;
 fComponentClassNameStringIntegerPairHashMap.Add(LowerCase(aComponentClass.ClassName),result);
 fComponentClassUUIDIntegerPairHashMap.Add(aComponentClass.ClassUUID,result);
 fComponentIDHashMap.Add(aComponentClass,result);
 aComponentClass.SetClassID(result);
end;

procedure TpvRegisteredComponentClassList.Remove(const aComponentClass:TpvComponentClass);
var ComponentClassID:TpvComponentClassID;
begin
 Assert(assigned(aComponentClass));
 aComponentClass.InitializeObjectClassMetaInfo;
 ComponentClassID:=inherited IndexOf(aComponentClass);
 if ComponentClassID>=0 then begin
  fComponentClassNameStringIntegerPairHashMap.Delete(LowerCase(aComponentClass.ClassName));
  fComponentClassUUIDIntegerPairHashMap.Delete(aComponentClass.ClassUUID);
  fComponentIDHashMap.Delete(aComponentClass);
  aComponentClass.SetClassID(-1);
  inherited Items[ComponentClassID]:=nil;
  inc(fCountDeleted);
 end;
end;

constructor TpvEntity.Create(const aWorld:TpvWorld);
begin
 inherited Create;
 fWorld:=aWorld;
 fFlags:=[];
 fComponents:=nil;
 fComponentBitmap:=nil;
end;

destructor TpvEntity.Destroy;
begin
 fComponents:=nil;
 fComponentBitmap:=nil;
 inherited Destroy;
end;

procedure TpvEntity.Assign(const aFrom:TpvEntity;const aAssignOp:TpvEntityAssignOp=TpvEntityAssignOp.Replace;const aEntityIDs:TpvEntityIDs=nil;const aDoRefresh:boolean=true);
var FromEntityComponentIndex,EntityComponentIndex:TpvInt32;
    FromEntityComponent,EntityComponent:TpvComponent;
    FromEntityComponentClass:TpvComponentClass;
begin

 for FromEntityComponentIndex:=0 to length(aFrom.fComponents)-1 do begin
  FromEntityComponent:=aFrom.fComponents[FromEntityComponentIndex];
  if assigned(FromEntityComponent) and (FromEntityComponent is TpvComponent) then begin
   FromEntityComponentClass:=TpvComponentClass(FromEntityComponent.ClassType);
   if assigned(FromEntityComponentClass) then begin
    if HasComponent(FromEntityComponentClass) then begin
     EntityComponent:=GetComponent(FromEntityComponentClass);
    end else begin
     EntityComponent:=FromEntityComponentClass.Create;
     AddComponent(EntityComponent);
    end;
    EntityComponent.Assign(FromEntityComponent,aEntityIDs);
   end;
  end;
 end;

 if aAssignOp=TpvEntityAssignOp.Replace then begin
  for EntityComponentIndex:=0 to length(fComponents)-1 do begin
   if assigned(fComponents[EntityComponentIndex]) and
      not ((FromEntityComponentIndex<length(aFrom.fComponents)) and
           assigned(aFrom.fComponents[FromEntityComponentIndex])) then begin
    RemoveComponent(EntityComponentIndex);
   end;
  end;
 end;

 if aFrom.Active then begin
  Activate;
 end;

 if aDoRefresh then begin
  World.Refresh;
 end;

end;

procedure TpvEntity.SynchronizeToPrefab;
var PrefabEntityComponentIndex,PropIndex,PropCount,PrefabInstanceEntityComponentPropertyIndex,ItemIndex:TpvInt32;
    PrefabMetaResource:TpvMetaResource;
    PrefabWorld:IpvResource;
    PrefabWorldInstance:TpvWorld;
    PrefabEntity:TpvEntity;
    PrefabEntityComponent:TpvComponent;
    PrefabEntityComponentClass:TpvComponentClass;
    EntityComponent:TpvComponent;
    PropList:PPropList;
    PropInfo:PPropInfo;
    ComponentPrefabInstance:TpvComponentPrefabInstance;
    PrefabInstanceEntityComponentPropertyList:TpvComponentPrefabInstanceEntityComponentPropertyList;
    PrefabInstanceEntityComponentProperty:TpvComponentPrefabInstanceEntityComponentProperty;
    SrcEntityIDs,DstEntityIDs:TpvComponentDataEntityIDs;
    SubSrcObject,SubDstObject:TObject;
begin
 if not (TEntityFlag.PrefabSynchronized in fFlags) then begin
  Include(fFlags,TEntityFlag.PrefabSynchronized);
  ComponentPrefabInstance:=TpvComponentPrefabInstance(GetComponent(TpvComponentPrefabInstance));
  if assigned(ComponentPrefabInstance) then begin
   PrefabMetaResource:=pvApplication.ResourceManager.MetaResourceByUUID[ComponentPrefabInstance.SourceWorldUUID];
   if assigned(PrefabMetaResource) and (PrefabMetaResource is TpvMetaWorld) then begin
    PrefabWorld:=PrefabMetaResource.Resource;
    if assigned(PrefabWorld) then begin
     try
      PrefabWorldInstance:=TpvWorld(PrefabWorld.GetReferenceCountedObject);
      PrefabEntity:=PrefabWorldInstance.GetEntityByUUID(ComponentPrefabInstance.SourceEntityUUID);
      if assigned(PrefabEntity) then begin
       PrefabEntity.SynchronizeToPrefab;
       PrefabInstanceEntityComponentPropertyList:=ComponentPrefabInstance.EntityComponentProperties;
       for PrefabEntityComponentIndex:=0 to length(PrefabEntity.fComponents)-1 do begin
        PrefabEntityComponent:=PrefabEntity.fComponents[PrefabEntityComponentIndex];
        if assigned(PrefabEntityComponent) and (PrefabEntityComponent is TpvComponent) then begin
         PrefabEntityComponentClass:=TpvComponentClass(PrefabEntityComponent.ClassType);
         if assigned(PrefabEntityComponentClass) then begin
          if HasComponent(PrefabEntityComponentClass) then begin
           EntityComponent:=GetComponent(PrefabEntityComponentClass);
          end else begin
           EntityComponent:=PrefabEntityComponentClass.Create;
           AddComponent(EntityComponent);
           PropList:=nil;
           try
            PropCount:=TypInfo.GetPropList({$ifdef fpc}PrefabEntityComponentClass{$else}EntityComponent{$endif},PropList);
            if PropCount>0 then begin
             for PropIndex:=0 to PropCount-1 do begin
              PropInfo:=PropList^[PropIndex];
              if assigned(PropInfo^.PropType) then begin
               PrefabInstanceEntityComponentPropertyList.RemoveComponentClassProperty(PrefabEntityComponentClass,PropInfo);
              end;
             end;
            end;
           finally
            if assigned(PropList) then begin
             FreeMem(PropList);
            end;
           end;
          end;
          PropList:=nil;
          try
           PropCount:=TypInfo.GetPropList({$ifdef fpc}PrefabEntityComponentClass{$else}EntityComponent{$endif},PropList);
           if PropCount>0 then begin
            for PropIndex:=0 to PropCount-1 do begin
             PropInfo:=PropList^[PropIndex];
             if assigned(PropInfo^.PropType) then begin
              PrefabInstanceEntityComponentPropertyIndex:=PrefabInstanceEntityComponentPropertyList.IndexOfComponentClassProperty(PrefabEntityComponentClass,PropInfo);
              if PrefabInstanceEntityComponentPropertyIndex<0 then begin
               PrefabInstanceEntityComponentPropertyIndex:=PrefabInstanceEntityComponentPropertyList.AddComponentClassProperty(PrefabEntityComponentClass,PropInfo);
              end;
              if PrefabInstanceEntityComponentPropertyIndex>=0 then begin
               PrefabInstanceEntityComponentProperty:=PrefabInstanceEntityComponentPropertyList.Items[PrefabInstanceEntityComponentPropertyIndex];
               if assigned(PrefabInstanceEntityComponentProperty.ComponentClass) and
                  assigned(PrefabInstanceEntityComponentProperty.PropInfo) then begin
                if not (TpvComponentPrefabInstanceEntityComponentProperty.TpvComponentPrefabInstanceEntityComponentPropertyFlag.cpiecpfOverwritten in PrefabInstanceEntityComponentProperty.Flags) then begin
                 PropInfo:=PrefabInstanceEntityComponentProperty.PropInfo;
                 if PropInfo^.PropType=TypeInfo(TpvEntityID) then begin
                  TypInfo.SetInt64Prop(EntityComponent,PropInfo,TypInfo.GetInt64Prop(PrefabEntityComponent,PropInfo));
                 end else if PropInfo^.PropType=TypeInfo(TpvComponentDataEntityIDs) then begin
                  SrcEntityIDs:=TpvComponentDataEntityIDs(TypInfo.GetObjectProp(PrefabEntityComponent,PropInfo));
                  DstEntityIDs:=TpvComponentDataEntityIDs(TypInfo.GetObjectProp(EntityComponent,PropInfo));
                  if assigned(DstEntityIDs) then begin
                   DstEntityIDs.Clear;
                  end else begin
                   DstEntityIDs:=TpvComponentDataEntityIDs.Create;
                   TypInfo.SetObjectProp(EntityComponent,PropInfo,DstEntityIDs);
                  end;
                  if assigned(SrcEntityIDs) then begin
                   for ItemIndex:=0 to SrcEntityIDs.Count-1 do begin
                    DstEntityIDs.Add(SrcEntityIDs.Items[ItemIndex]);
                   end;
                  end;
                 end else begin
                  case PropInfo^.PropType^.Kind of
                   tkUnknown:begin
                   end;
                   tkInteger:begin
                    TypInfo.SetOrdProp(EntityComponent,PropInfo,TypInfo.GetOrdProp(PrefabEntityComponent,PropInfo));
                   end;
                   tkInt64:begin
                    TypInfo.SetInt64Prop(EntityComponent,PropInfo,TypInfo.GetInt64Prop(PrefabEntityComponent,PropInfo));
                   end;
{$ifdef fpc}
                   tkQWord:begin
                    TypInfo.SetOrdProp(EntityComponent,PropInfo,TypInfo.GetOrdProp(PrefabEntityComponent,PropInfo));
                   end;
{$endif}
                   tkChar:begin
                    TypInfo.SetOrdProp(EntityComponent,PropInfo,TypInfo.GetOrdProp(PrefabEntityComponent,PropInfo));
                   end;
                   tkWChar{$ifdef fpc},tkUChar{$endif}:begin
                    TypInfo.SetOrdProp(EntityComponent,PropInfo,TypInfo.GetOrdProp(PrefabEntityComponent,PropInfo));
                   end;
                   tkEnumeration:begin
                    TypInfo.SetOrdProp(EntityComponent,PropInfo,TypInfo.GetOrdProp(PrefabEntityComponent,PropInfo));
                   end;
                   tkFloat:begin
                    TypInfo.SetFloatProp(EntityComponent,PropInfo,TypInfo.GetFloatProp(PrefabEntityComponent,PropInfo));
                   end;
                   tkSet:begin
                    TypInfo.SetOrdProp(EntityComponent,PropInfo,TypInfo.GetOrdProp(PrefabEntityComponent,PropInfo));
                   end;
                   {$ifdef fpc}tkSString,{$endif}tkLString,{$ifdef fpc}tkAString,{$endif}tkWString,tkUString:begin
                    TypInfo.SetUnicodeStrProp(EntityComponent,PropInfo,TypInfo.GetUnicodeStrProp(PrefabEntityComponent,PropInfo));
                   end;
                   tkClass:begin
                    SubSrcObject:=TypInfo.GetObjectProp(PrefabEntityComponent,PropInfo);
                    if assigned(SubSrcObject) then begin
                     if SubSrcObject is TPersistent then begin
                      SubDstObject:=TypInfo.GetObjectProp(EntityComponent,PropInfo);
                      if not assigned(SubDstObject) then begin
                       SubDstObject:=TypInfo.GetObjectPropClass(EntityComponent,PropInfo^.Name).Create;
                       TypInfo.SetObjectProp(EntityComponent,PropInfo,SubDstObject);
                      end;
                      TPersistent(SubDstObject).Assign(TPersistent(SubSrcObject));
                     end;
                    end;
                   end;
{$ifdef fpc}
                   tkBool:begin
                    TypInfo.SetOrdProp(EntityComponent,PropInfo,TypInfo.GetOrdProp(PrefabEntityComponent,PropInfo));
                   end;
{$endif}
                   else begin
                   end;
                  end;
                 end;
                end;
               end;
              end;
             end;
            end;
           end;
          finally
           if assigned(PropList) then begin
            FreeMem(PropList);
           end;
          end;
         end;
        end;
       end;
      end;
     finally
      PrefabWorld:=nil;
     end;
    end;
   end;
  end;
 end;
end;

procedure TpvEntity.AddComponentToEntity(const aComponent:TpvComponent);
var Index,OldCount,NewCount,BitmapIndex:TpvInt32;
    ID:TpvComponentClassID;
begin
 ID:=aComponent.ClassID;
 if (ID>=0) and (ID<length(fComponents)) and assigned(fComponents[ID]) then begin
  raise EpvDuplicateComponentInEntity.Create('Duplicate component "'+ClassName+'" in entity');
 end else begin
  if ID>=0 then begin
   begin
    OldCount:=length(fComponents);
    if OldCount<=ID then begin
     NewCount:=RoundUpToPowerOfTwo(ID+1);
     SetLength(fComponents,NewCount);
     for Index:=OldCount to NewCount-1 do begin
      fComponents[Index]:=nil;
     end;
    end;
    fComponents[ID]:=aComponent;
   end;
   begin
    OldCount:=length(fComponentBitmap);
    BitmapIndex:=(fID+63) shr 6;
    if OldCount<=BitmapIndex then begin
     NewCount:=RoundUpToPowerOfTwo(BitmapIndex+1);
     SetLength(fComponentBitmap,NewCount);
     FillChar(fComponentBitmap[OldCount],(NewCount-OldCount)*SizeOf(TpvUInt64),#0);
    end;
    fComponentBitmap[BitmapIndex]:=fComponentBitmap[BitmapIndex] or (TpvUInt64(1) shl (fID and 63));
   end;
  end;
 end;
end;

procedure TpvEntity.RemoveComponentFromEntity(const aComponent:TpvComponent);
var ID:TpvComponentClassID;
    BitmapIndex:TpvInt32;
begin
 ID:=aComponent.ClassID;
 if (ID>=0) and (ID<length(fComponents)) then begin
  fComponents[ID]:=nil;
 end;
 begin
  BitmapIndex:=(fID+63) shr 6;
  if BitmapIndex<=length(fComponentBitmap) then begin
   fComponentBitmap[BitmapIndex]:=fComponentBitmap[BitmapIndex] and not (TpvUInt64(1) shl (fID and 63));
  end;
 end;
end;

function TpvEntity.Active:boolean;
begin
 result:=fWorld.IsEntityActive(fID);
end;

procedure TpvEntity.Activate;
begin
 fWorld.ActivateEntity(fID);
end;

procedure TpvEntity.Deactivate;
begin
 fWorld.DeactivateEntity(fID);
end;

procedure TpvEntity.Kill;
begin
 fWorld.KillEntity(fID);
end;

procedure TpvEntity.AddComponent(const aComponent:TpvComponent);
begin
 fWorld.AddComponentToEntity(fID,aComponent);
end;

procedure TpvEntity.RemoveComponent(const aComponentClass:TpvComponentClass);
begin
 fWorld.RemoveComponentFromEntity(fID,aComponentClass);
end;

procedure TpvEntity.RemoveComponent(const aComponentClassID:TpvComponentClassID);
begin
 fWorld.RemoveComponentFromEntity(fID,fWorld.fUniverse.RegisteredComponentClasses.ComponentByID[aComponentClassID]);
end;

function TpvEntity.HasComponent(const aComponentClass:TpvComponentClass):boolean;
var ComponentClassID:TpvComponentClassID;
begin
 ComponentClassID:=aComponentClass.ClassID;
 result:=(ComponentClassID>=0) and (ComponentClassID<length(fComponents)) and assigned(fComponents[ComponentClassID]);
end;

function TpvEntity.HasComponent(const aComponentClassID:TpvComponentClassID):boolean;
begin
 result:=(aComponentClassID>=0) and (aComponentClassID<length(fComponents)) and assigned(fComponents[aComponentClassID]);
end;

function TpvEntity.GetComponent(const aComponentClass:TpvComponentClass):TpvComponent;
var ComponentClassID:TpvComponentClassID;
begin
 ComponentClassID:=aComponentClass.ClassID;
 if (ComponentClassID>=0) and (ComponentClassID<length(fComponents)) then begin
  result:=fComponents[ComponentClassID];
 end else begin
  result:=nil;
 end;
end;

function TpvEntity.GetComponent(const aComponentClassID:TpvComponentClassID):TpvComponent;
begin
 if (aComponentClassID>=0) and (aComponentClassID<length(fComponents)) then begin
  result:=fComponents[aComponentClassID];
 end else begin
  result:=nil;
 end;
end;

function TpvEntity.GetComponentByClass(const aComponentClass:TpvComponentClass):TpvComponent;
var ComponentClassID:TpvComponentClassID;
begin
 ComponentClassID:=aComponentClass.ClassID;
 if (ComponentClassID>=0) and (ComponentClassID<length(fComponents)) then begin
  result:=fComponents[ComponentClassID];
 end else begin
  result:=nil;
 end;
end;

function TpvEntity.GetComponentByClassID(const aComponentClassID:TpvComponentClassID):TpvComponent;
begin
 if (aComponentClassID>=0) and (aComponentClassID<length(fComponents)) then begin
  result:=fComponents[aComponentClassID];
 end else begin
  result:=nil;
 end;
end;

constructor TpvEntityList.Create;
begin
 inherited Create;
 fIDEntityHashMap:=TEntityListIDEntityHashMap.Create(nil);
 fUUIDIDHashMap:=TEntityListUUIDIDHashMap.Create(-1);
end;

destructor TpvEntityList.Destroy;
begin
 fUUIDIDHashMap.Free;
 fIDEntityHashMap.Free;
 inherited Destroy;
end;

function TpvEntityList.GetEntity(const aIndex:TpvInt32):TpvEntity;
begin
 if (aIndex>=0) and (aIndex<Count) then begin
  result:=pointer(inherited Items[aIndex]);
 end else begin
  result:=nil;
 end;
end;

procedure TpvEntityList.SetEntity(const aIndex:TpvInt32;const aEntity:TpvEntity);
begin
 inherited Items[aIndex]:=pointer(aEntity);
end;

function TpvEntityList.GetEntityByID(const aEntityID:TpvEntityID):TpvEntity;
begin
 result:=fIDEntityHashMap.Values[aEntityID];
end;

function TpvEntityList.GetEntityByUUID(const aEntityUUID:TpvUUID):TpvEntity;
begin
 result:=GetEntityByID(fUUIDIDHashMap.Values[aEntityUUID]);
end;

constructor TpvSystemEntityIDs.Create;
begin
 inherited Create;
 fEntityIDs:=nil;
 fCount:=0;
 fSorted:=false;
end;

destructor TpvSystemEntityIDs.Destroy;
begin
 SetLength(fEntityIDs,0);
 inherited Destroy;
end;

procedure TpvSystemEntityIDs.Clear;
begin
 fCount:=0;
 fSorted:=false;
end;

procedure TpvSystemEntityIDs.Assign(const aFrom:TpvSystemEntityIDs);
begin
 fCount:=aFrom.fCount;
 if fCount>0 then begin
  if length(fEntityIDs)<fCount then begin
   SetLength(fEntityIDs,fCount*2);
  end;
  Move(aFrom.fEntityIDs[0],fEntityIDs[0],fCount*SizeOf(TpvEntityID));
  fSorted:=aFrom.fSorted;
 end;
end;

function TpvSystemEntityIDs.IndexOf(const aEntityID:TpvEntityID):TpvInt32;
var Index,LowerIndexBound,UpperIndexBound,Difference:TpvInt32;
begin
 result:=-1;
 if fSorted then begin
  LowerIndexBound:=0;
  UpperIndexBound:=fCount-1;
  while LowerIndexBound<=UpperIndexBound do begin
   Index:=LowerIndexBound+((UpperIndexBound-LowerIndexBound) shr 1);
   Difference:=fEntityIDs[Index]-aEntityID;
   if Difference=0 then begin
    result:=Index;
    exit;
   end else if Difference<0 then begin
    LowerIndexBound:=Index+1;
   end else begin
    UpperIndexBound:=Index-1;
   end;
  end;
 end else begin
  for Index:=0 to fCount-1 do begin
   if fEntityIDs[Index]=aEntityID then begin
    result:=Index;
    exit;
   end;
  end;
 end;
end;

function TpvSystemEntityIDs.Add(const aEntityID:TpvEntityID):TpvInt32;
begin
 result:=fCount;
 inc(fCount);
 if length(fEntityIDs)<fCount then begin
  SetLength(fEntityIDs,fCount*2);
 end;
 fEntityIDs[result]:=aEntityID;
 fSorted:=false;
end;

procedure TpvSystemEntityIDs.Insert(const aIndex:TpvInt32;const aEntityID:TpvEntityID);
begin
 if aIndex>=0 then begin
  if aIndex<fCount then begin
   inc(fCount);
   if length(fEntityIDs)<fCount then begin
    SetLength(fEntityIDs,fCount*2);
   end;
   Move(fEntityiDs[aIndex],fEntityIDs[aIndex+1],(fCount-(aIndex+1))*SizeOf(TpvEntityID));
  end else begin
   fCount:=aIndex+1;
   if length(fEntityIDs)<fCount then begin
    SetLength(fEntityIDs,fCount*2);
   end;
  end;
  fEntityIDs[aIndex]:=aEntityID;
 end;
 fSorted:=false;
end;

procedure TpvSystemEntityIDs.Delete(const aIndex:TpvInt32);
begin
 if (aIndex>=0) and (aIndex<fCount) then begin
  Move(fEntityIDs[aIndex],fEntityIDs[aIndex-1],(fCount-aIndex)*SizeOf(TpvEntityID));
  dec(fCount);
 end;
end;

function TpvSystemEntityIDs.GetEntityID(const aIndex:TpvInt32):TpvEntityID;
begin
 result:=fEntityIDs[aIndex];
end;

function TSystemEntityIDsSortCompare(const a,b:pointer):TpvInt32;
begin
 result:=TpvEntityID(a^)-TpvEntityID(b^);
end;

procedure TpvSystemEntityIDs.Sort;
begin
 if (fCount>1) and not fSorted then begin
  UntypedDirectIntroSort(pointer(@fEntityIDs[0]),0,fCount-1,SizeOf(TpvEntityID),TSystemEntityIDsSortCompare);
  fSorted:=true;
 end;
end;

constructor TpvSystemEntities.Create;
begin
 inherited Create;
 fEntities:=nil;
 fCount:=0;
 fSorted:=false;
end;

destructor TpvSystemEntities.Destroy;
begin
 SetLength(fEntities,0);
 inherited Destroy;
end;

procedure TpvSystemEntities.Clear;
begin
 fCount:=0;
 fSorted:=false;
end;

procedure TpvSystemEntities.Assign(const aFrom:TpvSystemEntities);
begin
 fCount:=aFrom.fCount;
 if fCount>0 then begin
  if length(fEntities)<fCount then begin
   SetLength(fEntities,fCount*2);
  end;
  Move(aFrom.fEntities[0],fEntities[0],fCount*SizeOf(TpvEntity));
  fSorted:=aFrom.fSorted;
 end;
end;

function TpvSystemEntities.IndexOf(const aEntity:TpvEntity):TpvInt32;
var Index,LowerIndexBound,UpperIndexBound,Difference:TpvInt32;
begin
 result:=-1;
 if fSorted and assigned(aEntity) then begin
  LowerIndexBound:=0;
  UpperIndexBound:=fCount-1;
  while LowerIndexBound<=UpperIndexBound do begin
   Index:=LowerIndexBound+((UpperIndexBound-LowerIndexBound) shr 1);
   Difference:=fEntities[Index].fID-aEntity.fID;
   if Difference=0 then begin
    result:=Index;
    exit;
   end else if Difference<0 then begin
    LowerIndexBound:=Index+1;
   end else begin
    UpperIndexBound:=Index-1;
   end;
  end;
 end else begin
  for Index:=0 to fCount-1 do begin
   if fEntities[Index]=aEntity then begin
    result:=Index;
    exit;
   end;
  end;
 end;
end;

function TpvSystemEntities.Add(const aEntity:TpvEntity):TpvInt32;
begin
 result:=fCount;
 inc(fCount);
 if length(fEntities)<fCount then begin
  SetLength(fEntities,fCount*2);
 end;
 fEntities[result]:=aEntity;
 fSorted:=false;
end;

procedure TpvSystemEntities.Insert(const aIndex:TpvInt32;const aEntity:TpvEntity);
begin
 if aIndex>=0 then begin
  if aIndex<fCount then begin
   inc(fCount);
   if length(fEntities)<fCount then begin
    SetLength(fEntities,fCount*2);
   end;
   Move(fEntities[aIndex],fEntities[aIndex+1],(fCount-(aIndex+1))*SizeOf(TpvEntity));
  end else begin
   fCount:=aIndex+1;
   if length(fEntities)<fCount then begin
    SetLength(fEntities,fCount*2);
   end;
  end;
  fEntities[aIndex]:=aEntity;
 end;
 fSorted:=false;
end;

procedure TpvSystemEntities.Delete(const aIndex:TpvInt32);
begin
 if (aIndex>=0) and (aIndex<fCount) then begin
  Move(fEntities[aIndex],fEntities[aIndex-1],(fCount-aIndex)*SizeOf(TpvEntity));
  dec(fCount);
 end;
end;

function TpvSystemEntities.GetEntity(const aIndex:TpvInt32):TpvEntity;
begin
 result:=fEntities[aIndex];
end;

function TSystemEntitiesSortCompare(const a,b:pointer):TpvInt32;
begin
 result:=TpvEntity(a).fID-TpvEntity(b).fID;
end;

procedure TpvSystemEntities.Sort;
begin
 if (fCount>1) and not fSorted then begin
  UntypedDirectIntroSort(pointer(@fEntities[0]),0,fCount-1,SizeOf(TpvEntity),TSystemEntitiesSortCompare);
  fSorted:=true;
 end;
end;

constructor TpvSystem.Create(const AWorld: TpvWorld);
begin
 inherited Create;
 fWorld:=aWorld;
 fFlags:=[];
 fEntityIDs:=TpvSystemEntityIDs.Create;
 fEntities:=TpvSystemEntities.Create;
 fRequiredComponentClasses:=TpvSystemComponentClassList.Create;
 fExcludedComponentClasses:=TpvSystemComponentClassList.Create;
 fRequiresSystems:=TList.Create;
 fConflictsWithSystems:=TList.Create;
 fNeedToSort:=true;
 fEventsCanBeParallelProcessed:=false;
 fEventGranularity:=256;
 fEntityGranularity:=256;
 fCountEntities:=0;
 fEvents:=nil;
 fCountEvents:=0;
end;

destructor TpvSystem.Destroy;
begin
 fExcludedComponentClasses.Free;
 fRequiredComponentClasses.Free;
 fRequiresSystems.Free;
 fConflictsWithSystems.Free;
 fEntityIDs.Free;
 fEntities.Free;
 SetLength(fEvents,0);
 inherited Destroy;
end;

procedure TpvSystem.Added;
begin
end;

procedure TpvSystem.Removed;
begin
end;

procedure TpvSystem.SubscribeToEvent(const aEventID:TpvEventID);
var EventRegistration:TpvEventRegistration;
begin
 fWorld.fEventRegistrationLock.AcquireWrite;
 try
  if (aEventID>=0) and (aEventID<fWorld.fEventRegistrationList.Count) then begin
   EventRegistration:=fWorld.fEventRegistrationList.Items[aEventID];
   if EventRegistration.fActive then begin
    EventRegistration.AddSystem(self);
   end;
  end;
 finally
  fWorld.fEventRegistrationLock.ReleaseWrite;
 end;
end;

procedure TpvSystem.UnsubscribeFromEvent(const aEventID:TpvEventID);
var EventRegistration:TpvEventRegistration;
begin
 fWorld.fEventRegistrationLock.AcquireWrite;
 try
  if (aEventID>=0) and (aEventID<fWorld.fEventRegistrationList.Count) then begin
   EventRegistration:=fWorld.fEventRegistrationList.Items[aEventID];
   if EventRegistration.fActive then begin
    EventRegistration.RemoveSystem(self);
   end;
  end;
 finally
  fWorld.fEventRegistrationLock.ReleaseWrite;
 end;
end;

function TpvSystem.HaveDependencyOnSystem(const aOtherSystem:TpvSystem):boolean;
begin
 result:=assigned(aOtherSystem) and (fRequiresSystems.IndexOf(aOtherSystem)>=0);
end;

function TpvSystem.HaveDependencyOnSystemOrViceVersa(const aOtherSystem:TpvSystem):boolean;
begin
 result:=assigned(aOtherSystem) and ((fRequiresSystems.IndexOf(aOtherSystem)>=0) or (aOtherSystem.fRequiresSystems.IndexOf(self)>=0));
end;

function TpvSystem.HaveCircularDependencyWithSystem(const aOtherSystem:TpvSystem):boolean;
var VisitedList,StackList:TList;
    Index:TpvInt32;
    System,RequiredSystem:TpvSystem;
begin
 result:=false;
 if assigned(aOtherSystem) then begin
  VisitedList:=TList.Create;
  try
   StackList:=TList.Create;
   try
    StackList.Add(aOtherSystem);
    while (StackList.Count>0) and not result do begin
     System:=StackList.Items[StackList.Count-1];
     StackList.Delete(StackList.Count-1);
     VisitedList.Add(System);
     for Index:=0 to System.fRequiresSystems.Count-1 do begin
      RequiredSystem:=System.fRequiresSystems.Items[Index];
      if RequiredSystem=self then begin
       result:=true;
       break;
      end else if VisitedList.IndexOf(RequiredSystem)<0 then begin
       StackList.Add(RequiredSystem);
      end;
     end;
    end;
   finally
    StackList.Free;
   end;
  finally
   VisitedList.Free;
  end;
 end;
end;

function TpvSystem.HaveConflictWithSystem(const aOtherSystem:TpvSystem):boolean;
begin
 result:=assigned(aOtherSystem) and (fConflictsWithSystems.IndexOf(aOtherSystem)>=0);
end;

function TpvSystem.HaveConflictWithSystemOrViceVersa(const aOtherSystem:TpvSystem):boolean;
begin
 result:=assigned(aOtherSystem) and ((fConflictsWithSystems.IndexOf(aOtherSystem)>=0) or (aOtherSystem.fConflictsWithSystems.IndexOf(self)>=0));
end;

procedure TpvSystem.RequiresSystem(const aSystem:TpvSystem);
begin
 if fRequiresSystems.IndexOf(aSystem)<0 then begin
  fRequiresSystems.Add(aSystem);
 end;
end;

procedure TpvSystem.ConflictsWithSystem(const aSystem:TpvSystem);
begin
 if fConflictsWithSystems.IndexOf(aSystem)<0 then begin
  fConflictsWithSystems.Add(aSystem);
 end;
end;

procedure TpvSystem.AddRequiredComponent(const aComponentClass:TpvComponentClass);
begin
 if assigned(aComponentClass) and (fRequiredComponentClasses.IndexOf(aComponentClass)<0) then begin
  fRequiredComponentClasses.Add(aComponentClass);
 end;
end;

procedure TpvSystem.AddExcludedComponent(const aComponentClass:TpvComponentClass);
begin
 if assigned(aComponentClass) and (fExcludedComponentClasses.IndexOf(aComponentClass)<0) then begin
  fExcludedComponentClasses.Add(aComponentClass);
 end;
end;

function TpvSystem.FitsEntityToSystem(const aEntityID:TpvEntityID):boolean;
var Index:TpvInt32;
begin
 result:=fWorld.HasEntity(aEntityID);
 if result then begin
  for Index:=0 to fExcludedComponentClasses.Count-1 do begin
   if fWorld.HasEntityComponent(aEntityID,fExcludedComponentClasses.Items[Index]) then begin
    result:=false;
    exit;
   end;
  end;
  for Index:=0 to fRequiredComponentClasses.Count-1 do begin
   if not fWorld.HasEntityComponent(aEntityID,fRequiredComponentClasses.Items[Index]) then begin
    result:=false;
    exit;
   end;
  end;
 end;
end;

function TpvSystem.AddEntityToSystem(const aEntityID:TpvEntityID):boolean;
begin
 if fEntityIDs.IndexOf(aEntityID)<0 then begin
  fEntities.Insert(fEntityIDs.Add(aEntityID),fWorld.GetEntityByID(aEntityID));
  inc(fCountEntities);
  fNeedToSort:=true;
  result:=true;
 end else begin
  result:=false;
 end;
end;

function TpvSystem.RemoveEntityFromSystem(const aEntityID:TpvEntityID):boolean;
var Index:TpvInt32;
begin
 Index:=fEntityIDs.IndexOf(aEntityID);
 if Index>=0 then begin
  fEntityIDs.Delete(Index);
  fEntities.Delete(Index);
  dec(fCountEntities);
  result:=true;
 end else begin
  result:=false;
 end;
end;

procedure TpvSystem.SortEntities;
var Index:TpvInt32;
begin
 if fNeedToSort then begin
  fNeedToSort:=false;
  fEntityIDs.Sort;
  for Index:=0 to fEntityIDs.Count-1 do begin
   fEntities.fEntities[Index]:=fWorld.GetEntityByID(fEntityIDs[Index]);
  end;
  fEntities.fSorted:=fEntityIDs.fSorted;
 end;
end;

procedure TpvSystem.Finish;
begin
end;

procedure TpvSystem.ProcessEvent(const aEvent:TpvEvent);
begin
end;

procedure TpvSystem.ProcessEvents(const aFirstEventIndex,aLastEventIndex:TpvInt32);
var EntityIndex:TpvInt32;
    Event:PpvEvent;
begin
 for EntityIndex:=aFirstEventIndex to aLastEventIndex do begin
  Event:=fEvents[EntityIndex];
  if assigned(Event) then begin
   ProcessEvent(Event^);
  end;
 end;
end;

procedure TpvSystem.InitializeUpdate;
begin
end;

procedure TpvSystem.Update;
begin
end;

procedure TpvSystem.UpdateEntities(const aFirstEntityIndex,aLastEntityIndex:TpvInt32);
begin
end;

procedure TpvSystem.FinalizeUpdate;
begin
end;

procedure TpvSystem.Store;
begin

end;

procedure TpvSystem.Interpolate(const aAlpha:TpvDouble);
begin

end;

constructor TpvSystemChoreography.Create(const aWorld:TpvWorld);
begin
 inherited Create;
 fWorld:=aWorld;
 fPasMP:=pvApplication.PasMPInstance;
 fChoreographySteps:=nil;
 fChoreographyStepJobs:=nil;
 fCountChoreographySteps:=0;
 fSortedSystemList:=TList.Create;
end;

destructor TpvSystemChoreography.Destroy;
begin
 SetLength(fChoreographySteps,0);
 SetLength(fChoreographyStepJobs,0);
 fSortedSystemList.Free;
 inherited Destroy;
end;

procedure TpvSystemChoreography.Build;
var Systems:TList;
    Index,OtherIndex,SystemIndex:TpvInt32;
    Done,Stop:boolean;
    System,OtherSystem:TpvSystem;
    ChoreographyStep:PSystemChoreographyStep;
begin
 Systems:=fSortedSystemList;

 Systems.Clear;

 // Fill in
 for Index:=0 to fWorld.fSystemList.Count-1 do begin
  Systems.Add(fWorld.fSystemList.Items[Index]);
 end;

 // Resolve dependencies with "stable" topological sorting a la naive bubble sort with a bad
 // execution time (but that fact does not matter at so few systems), and not with Kahn's or
 // Tarjan's algorithms, because the result must be in a stable sort order
 repeat
  Done:=true;
  for Index:=0 to Systems.Count-1 do begin
   System:=Systems.Items[Index];
   for OtherIndex:=0 to Index-1 do begin
    OtherSystem:=Systems.Items[OtherIndex];
    if OtherSystem.HaveDependencyOnSystem(System) then begin
     if OtherSystem.HaveCircularDependencyWithSystem(System) then begin
      raise EpvSystemCircularDependency.Create(System.ClassName+' have circular dependency with '+OtherSystem.ClassName);
     end else begin
      Systems.Exchange(Index,OtherIndex);
      Done:=false;
      break;
     end;
    end;
   end;
   if not Done then begin
    break;
   end;
  end;
 until Done;

 // Construct dependency conflict-free choreography
 fCountChoreographySteps:=0;
 Index:=0;
 while Index<Systems.Count do begin
  System:=Systems.Items[Index];
  inc(Index);
  inc(fCountChoreographySteps);
  if fCountChoreographySteps>length(fChoreographySteps) then begin
   SetLength(fChoreographySteps,fCountChoreographySteps*2);
  end;
  ChoreographyStep:=@fChoreographySteps[fCountChoreographySteps-1];
  ChoreographyStep^.Count:=1;
  SetLength(ChoreographyStep^.Systems,ChoreographyStep^.Count);
  SetLength(ChoreographyStep^.Jobs,ChoreographyStep^.Count);
  ChoreographyStep^.Systems[0]:=System;
  while Index<Systems.Count do begin
   OtherSystem:=Systems.Items[Index];
   Stop:=TpvSystem.TSystemFlag.Secluded in OtherSystem.fFlags;
   if not Stop then begin
    for SystemIndex:=0 to ChoreographyStep^.Count-1 do begin
     System:=ChoreographyStep^.Systems[SystemIndex];
     if System.HaveDependencyOnSystemOrViceVersa(OtherSystem) or
        System.HaveConflictWithSystemOrViceVersa(OtherSystem) then begin
      Stop:=true;
      break;
     end;
    end;
   end;
   if Stop then begin
    break;
   end else begin
    inc(Index);
    inc(ChoreographyStep^.Count);
    if ChoreographyStep^.Count>length(ChoreographyStep^.Systems) then begin
     SetLength(ChoreographyStep^.Systems,ChoreographyStep^.Count*2);
    end;
    ChoreographyStep^.Systems[ChoreographyStep^.Count-1]:=OtherSystem;
   end;
  end;
 end;
 SetLength(fChoreographyStepJobs,fCountChoreographySteps);

end;

type PSystemChoreographyProcessEventsJobData=^TSystemChoreographyProcessEventsJobData;
     TSystemChoreographyProcessEventsJobData=record
      System:TpvSystem;
      FirstEventIndex:TpvInt32;
      LastEventIndex:TpvInt32;
     end;

function TpvSystemChoreography.CreateProcessEventsJob(const aSystem:TpvSystem;const aFirstEventIndex,aLastEventIndex:TpvInt32;const aParentJob:PPasMPJob):PPasMPJob;
var Data:PSystemChoreographyProcessEventsJobData;
begin
 result:=fPasMP.Acquire(ProcessEventsJobFunction,nil,nil);
 Data:=PSystemChoreographyProcessEventsJobData(pointer(@result^.Data));
 Data^.System:=aSystem;
 Data^.FirstEventIndex:=aFirstEventIndex;
 Data^.LastEventIndex:=aFirstEventIndex;
end;

procedure TpvSystemChoreography.ProcessEventsJobFunction(const aJob:PPasMPJob;const aThreadIndex:TpvInt32);
var Data:PSystemChoreographyProcessEventsJobData;
    MidEventIndex,Count:TpvInt32;
begin
 Data:=@aJob^.Data;
 if Data^.FirstEventIndex<=Data^.LastEventIndex then begin
  Count:=Data^.LastEventIndex-Data^.FirstEventIndex;
  if (fPasMP.CountJobWorkerThreads<2) or
     (not (TpvSystem.TSystemFlag.ParallelProcessing in Data.System.fFlags)) or
     ((Count<=Data^.System.fEventGranularity) or (Count<4)) then begin
   Data^.System.ProcessEvents(Data^.FirstEventIndex,Data^.LastEventIndex);
  end else begin
   MidEventIndex:=Data^.FirstEventIndex+((Data^.LastEventIndex-Data^.FirstEventIndex) shr 1);
   fPasMP.Invoke([CreateProcessEventsJob(Data^.System,Data^.FirstEventIndex,MidEventIndex-1,aJob),
                      CreateProcessEventsJob(Data^.System,MidEventIndex,Data^.LastEventIndex,aJob)]);
  end;
 end;
end;

procedure TpvSystemChoreography.ChoreographyStepProcessEventsJobFunction(const aJob:PPasMPJob;const aThreadIndex:TpvInt32);
var Data:PSystemChoreographyStepProcessEventsJobData;
    ChoreographyStep:PSystemChoreographyStep;
    SystemIndex:TpvInt32;
    System:TpvSystem;
begin
 Data:=@aJob^.Data;
 ChoreographyStep:=Data^.ChoreographyStep;
 for SystemIndex:=0 to ChoreographyStep^.Count-1 do begin
  System:=ChoreographyStep^.Systems[SystemIndex];
  if System.fEventsCanBeParallelProcessed then begin
   ChoreographyStep^.Jobs[SystemIndex]:=CreateProcessEventsJob(System,0,System.fCountEvents-1,aJob);
  end else begin
   ChoreographyStep^.Jobs[SystemIndex]:=nil;
  end;
 end;
 fPasMP.Invoke(ChoreographyStep^.Jobs);
end;

procedure TpvSystemChoreography.ChoreographyProcessEventsJobFunction(const aJob:PPasMPJob;const aThreadIndex:TpvInt32);
var ChoreographyStepJob:PPasMPJob;
    ChoreographyStepJobData:PSystemChoreographyStepProcessEventsJobData;
    StepIndex:TpvInt32;
    ChoreographyStep:PSystemChoreographyStep;
begin
 for StepIndex:=0 to fCountChoreographySteps-1 do begin
  ChoreographyStep:=@fChoreographySteps[StepIndex];
  ChoreographyStepJob:=fPasMP.Acquire(ChoreographyStepProcessEventsJobFunction,nil,nil);
  ChoreographyStepJobData:=PSystemChoreographyStepProcessEventsJobData(pointer(@ChoreographyStepJob^.Data));
  ChoreographyStepJobData^.ChoreographyStep:=ChoreographyStep;
  fChoreographyStepJobs[StepIndex]:=ChoreographyStepJob;
  fPasMP.Invoke(fChoreographyStepJobs[StepIndex]);
 end;
end;

procedure TpvSystemChoreography.ProcessEvents;
begin
 fPasMP.Invoke(fPasMP.Acquire(ChoreographyProcessEventsJobFunction,nil,nil));
end;

procedure TpvSystemChoreography.InitializeUpdate;
var StepIndex,SystemIndex:TpvInt32;
    ChoreographyStep:PSystemChoreographyStep;
    System:TpvSystem;
begin
 for StepIndex:=0 to fCountChoreographySteps-1 do begin
  ChoreographyStep:=@fChoreographySteps[StepIndex];
  for SystemIndex:=0 to ChoreographyStep^.Count-1 do begin
   System:=ChoreographyStep^.Systems[SystemIndex];
   System.InitializeUpdate;
  end;
 end;
end;

type PSystemChoreographyUpdateEntitiesJobData=^TSystemChoreographyUpdateEntitiesJobData;
     TSystemChoreographyUpdateEntitiesJobData=record
      System:TpvSystem;
      FirstEntityIndex:TpvInt32;
      LastEntityIndex:TpvInt32;
     end;

function TpvSystemChoreography.CreateUpdateEntitiesJob(const aSystem:TpvSystem;const aFirstEntityIndex,aLastEntityIndex:TpvInt32;const aParentJob:PPasMPJob):PPasMPJob;
var Data:PSystemChoreographyUpdateEntitiesJobData;
begin
 result:=fPasMP.Acquire(UpdateEntitiesJobFunction,nil,nil);
 Data:=PSystemChoreographyUpdateEntitiesJobData(pointer(@result^.Data));
 Data^.System:=aSystem;
 Data^.FirstEntityIndex:=aFirstEntityIndex;
 Data^.LastEntityIndex:=aLastEntityIndex;
end;

procedure TpvSystemChoreography.UpdateEntitiesJobFunction(const aJob:PPasMPJob;const aThreadIndex:TpvInt32);
var Data:PSystemChoreographyUpdateEntitiesJobData;
    MidEntityIndex,Count:TpvInt32;
begin
 Data:=@aJob^.Data;
 if Data^.FirstEntityIndex<=Data^.LastEntityIndex then begin
  Count:=Data^.LastEntityIndex-Data^.FirstEntityIndex;
  if (TpvSystem.TSystemFlag.OwnUpdate in Data.System.fFlags) or
     (not (TpvSystem.TSystemFlag.ParallelProcessing in Data.System.fFlags)) or
     (fPasMP.CountJobWorkerThreads<2) or
     ((Count<=Data^.System.fEntityGranularity) or (Count<4)) then begin
   if TpvSystem.TSystemFlag.OwnUpdate in Data.System.fFlags then begin
    Data^.System.Update;
   end else begin
    Data^.System.UpdateEntities(Data^.FirstEntityIndex,Data^.LastEntityIndex);
   end;
  end else begin
   MidEntityIndex:=Data^.FirstEntityIndex+((Data^.LastEntityIndex-Data^.FirstEntityIndex) shr 1);
   fPasMP.Invoke([CreateUpdateEntitiesJob(Data^.System,Data^.FirstEntityIndex,MidEntityIndex-1,aJob),
                  CreateUpdateEntitiesJob(Data^.System,MidEntityIndex,Data^.LastEntityIndex,aJob)]);
  end;
 end;
end;

procedure TpvSystemChoreography.ChoreographyStepUpdateEntitiesJobFunction(const aJob:PPasMPJob;const aThreadIndex:TpvInt32);
var Data:PSystemChoreographyStepUpdateEntitiesJobData;
    ChoreographyStep:PSystemChoreographyStep;
    SystemIndex:TpvInt32;
    System:TpvSystem;
begin
 Data:=@aJob^.Data;
 ChoreographyStep:=Data^.ChoreographyStep;
 for SystemIndex:=0 to ChoreographyStep^.Count-1 do begin
  System:=ChoreographyStep^.Systems[SystemIndex];
  ChoreographyStep^.Jobs[SystemIndex]:=CreateUpdateEntitiesJob(System,0,System.fCountEntities-1,aJob);
 end;
 fPasMP.Invoke(ChoreographyStep^.Jobs);
end;

procedure TpvSystemChoreography.ChoreographyUpdateEntitiesJobFunction(const aJob:PPasMPJob;const aThreadIndex:TpvInt32);
var ChoreographyStepJob:PPasMPJob;
    ChoreographyStepJobData:PSystemChoreographyStepUpdateEntitiesJobData;
    StepIndex:TpvInt32;
    ChoreographyStep:PSystemChoreographyStep;
begin
 for StepIndex:=0 to fCountChoreographySteps-1 do begin
  ChoreographyStep:=@fChoreographySteps[StepIndex];
  ChoreographyStepJob:=fPasMP.Acquire(ChoreographyStepUpdateEntitiesJobFunction,nil,nil);
  ChoreographyStepJobData:=PSystemChoreographyStepUpdateEntitiesJobData(pointer(@ChoreographyStepJob^.Data));
  ChoreographyStepJobData^.ChoreographyStep:=ChoreographyStep;
  fChoreographyStepJobs[StepIndex]:=ChoreographyStepJob;
  fPasMP.Invoke(fChoreographyStepJobs[StepIndex]);
 end;
end;

procedure TpvSystemChoreography.Update;
begin
 fPasMP.Invoke(fPasMP.Acquire(ChoreographyUpdateEntitiesJobFunction,nil,nil));
end;

procedure TpvSystemChoreography.FinalizeUpdate;
var StepIndex,SystemIndex:TpvInt32;
    ChoreographyStep:PSystemChoreographyStep;
    System:TpvSystem;
begin
 for StepIndex:=0 to fCountChoreographySteps-1 do begin
  ChoreographyStep:=@fChoreographySteps[StepIndex];
  for SystemIndex:=0 to ChoreographyStep^.Count-1 do begin
   System:=ChoreographyStep^.Systems[SystemIndex];
   System.FinalizeUpdate;
  end;
 end;
end;

constructor TpvSystemList.Create;
begin
 inherited Create;
end;

destructor TpvSystemList.Destroy;
begin
 inherited Destroy;
end;

function TpvSystemList.GetSystem(const aIndex:TpvInt32):TpvSystem;
begin
 result:=pointer(inherited Items[aIndex]);
end;

procedure TpvSystemList.SetSystem(const aIndex:TpvInt32;const ASystem:TpvSystem);
begin
 inherited Items[aIndex]:=pointer(ASystem);
end;

constructor TpvSystemClassList.Create;
begin
 inherited Create;
end;

destructor TpvSystemClassList.Destroy;
begin
 inherited Destroy;
end;

function TpvSystemClassList.GetSystemClass(const aIndex:TpvInt32):TpvSystemClass;
begin
 result:=pointer(inherited Items[aIndex]);
end;

procedure TpvSystemClassList.SetSystemClass(const aIndex:TpvInt32;const ASystemClass:TpvSystemClass);
begin
 inherited Items[aIndex]:=pointer(ASystemClass);
end;

constructor TpvMetaWorld.Create;
begin
 inherited Create;
end;

constructor TpvMetaWorld.CreateNew(const aFileName:TpvUTF8String);
var World:TpvWorld;
begin
 inherited CreateNew(aFileName);
 World:=TpvWorld.Create(pvApplication.ResourceManager,nil,self);
 try
  if length(aFileName)>0 then begin
   World.SaveToFile(aFileName,[],-1);
  end;
 finally
  World.Free;
 end;
end;

destructor TpvMetaWorld.Destroy;
begin
 inherited Destroy;
end;

function TpvMetaWorld.GetResource:IpvResource;
var Stream:TStream;
begin
 fResourceLock.Acquire;
 try
  result:=fResource;
  if not assigned(result) then begin
   result:=TpvWorld.Create(pvApplication.ResourceManager,nil,self);
   if assigned(result) then begin
    Stream:=pvApplication.Assets.GetAssetStream('worlds/'+ExtractFileName(fFileName));
    if not assigned(Stream) then begin
     Stream:=TFileStream.Create(fFileName,fmOpenRead or fmShareDenyWrite);
    end;
    if assigned(Stream) then begin
     try
      TpvWorld(result.GetReferenceCountedObject).LoadFromStream(Stream,false);
     finally
      Stream.Free;
     end;
    end;
   end;
  end;
 finally
  fResourceLock.Release;
 end;
end;

procedure TpvMetaWorld.LoadFromStream(const aStream:TStream);
var s:TPasJSONRawByteString;
    l:Int64;
    RootItem:TPasJSONItem;
begin
 s:='';
 try
  l:=aStream.Size-aStream.Position;
  if l>0 then begin
   SetLength(s,l*SizeOf(AnsiChar));
   if aStream.Read(s[1],l*SizeOf(AnsiChar))<>(l*SizeOf(AnsiChar)) then begin
    raise EInOutError.Create('Stream read error');
   end;
   RootItem:=TPasJSON.Parse(s);
   if assigned(RootItem) then begin
    try
     if RootItem is TPasJSONItemObject then begin
      SetUUID(TpvUUID.CreateFromString(TPasJSON.GetString(TPasJSONItemObject(RootItem).Properties['uuid'],fUUID.ToString)));
     end;
    finally
     RootItem.Free;
    end;
   end;
  end;
 finally
  s:='';
 end;
end;

function TpvMetaWorld.Clone(const aFileName:TpvUTF8String=''):TpvMetaResource;
var World:IpvResource;
    WorldInstance,ClonedWorld:TpvWorld;
    Stream:TStream;
begin
 result:=inherited Clone(aFileName);
 World:=GetResource;
 if assigned(World) then begin
  WorldInstance:=TpvWorld(World.GetReferenceCountedObject);
  try
   Stream:=TMemoryStream.Create;
   try
    WorldInstance.SaveToStream(Stream,[],-1);
    Stream.Seek(0,soBeginning);
    ClonedWorld:=TpvWorld.Create(pvApplication.ResourceManager,nil,TpvMetaWorld(result));
    try
     ClonedWorld.LoadFromStream(Stream,false);
     if length(aFileName)>0 then begin
      ClonedWorld.SaveToFile(aFileName,[],-1);
     end;
    finally
     ClonedWorld.Free;
    end;
   finally
    Stream.Free;
   end;
  finally
   World:=nil;
  end;
 end;
end;

procedure TpvMetaWorld.Rename(const aFileName:TpvUTF8String);
begin
 inherited Rename(aFileName);
end;

procedure TpvMetaWorld.Delete;
begin
 inherited Delete;
end;

{ TpvWorldEntityComponentSetQuery }

constructor TpvWorldEntityComponentSetQuery.Create(const aWorld:TpvWorld;const aRequiredComponents:array of TpvComponentClassID;const aExcludedComponents:array of TpvComponentClassID);
var MaxComponentIDPlusOne,Index,BitmapSize:TpvSizeInt;
begin

 inherited Create;

 fRequiredComponentBitmap:=nil;
 fExcludedComponentBitmap:=nil;
 fEntityIDs:=nil;

 fGeneration:=High(TpvUInt64);

 // Find the maximum component ID plus one
 MaxComponentIDPlusOne:=0;
 for Index:=0 to length(aRequiredComponents)-1 do begin
  MaxComponentIDPlusOne:=Max(MaxComponentIDPlusOne,aRequiredComponents[Index]+1);
 end;
 for Index:=0 to length(aExcludedComponents)-1 do begin
  MaxComponentIDPlusOne:=Max(MaxComponentIDPlusOne,aExcludedComponents[Index]+1);
 end;

 // Calculate the bitmap size
 BitmapSize:=(MaxComponentIDPlusOne+63) shr 6;

 // Initialize the and component bitmap with the required components
 SetLength(fRequiredComponentBitmap,BitmapSize);
 FillChar(fRequiredComponentBitmap[0],BitmapSize*SizeOf(TpvUInt64),#0);
 for Index:=0 to length(aRequiredComponents)-1 do begin
  fRequiredComponentBitmap[aRequiredComponents[Index] shr 6]:=fRequiredComponentBitmap[aRequiredComponents[Index] shr 6] or (TpvUInt64(1) shl (aRequiredComponents[Index] and 63));
 end;

 // Initialize the and not component bitmap with the excluded components
 SetLength(fExcludedComponentBitmap,BitmapSize);
 FillChar(fExcludedComponentBitmap[0],BitmapSize*SizeOf(TpvUInt64),#0);
 for Index:=0 to length(fExcludedComponentBitmap)-1 do begin
  fExcludedComponentBitmap[aExcludedComponents[Index] shr 6]:=fExcludedComponentBitmap[aExcludedComponents[Index] shr 6] or (TpvUInt64(1) shl (aExcludedComponents[Index] and 63));
 end;

end;

constructor TpvWorldEntityComponentSetQuery.Create(const aWorld:TpvWorld;const aRequiredComponents:array of TpvComponentClass;const aExcludedComponents:array of TpvComponentClass);
var Index:TpvSizeInt;
    RequiredComponents:array of TpvComponentClassID;
    ExcludedComponents:array of TpvComponentClassID;
begin
 RequiredComponents:=nil;
 try
  ExcludedComponents:=nil;
  try
   SetLength(RequiredComponents,length(aRequiredComponents));
   for Index:=0 to length(aRequiredComponents)-1 do begin
    RequiredComponents[Index]:=aRequiredComponents[Index].ClassID;
   end;
   SetLength(ExcludedComponents,length(aExcludedComponents));
   for Index:=0 to length(aExcludedComponents)-1 do begin
    ExcludedComponents[Index]:=aExcludedComponents[Index].ClassID;
   end;
   Create(aWorld,RequiredComponents,ExcludedComponents);
  finally
   ExcludedComponents:=nil;
  end;
 finally
  RequiredComponents:=nil;
 end;
end;

destructor TpvWorldEntityComponentSetQuery.Destroy;
begin
 fRequiredComponentBitmap:=nil;
 fExcludedComponentBitmap:=nil;
 fEntityIDs:=nil;
 inherited Destroy;
end;

procedure TpvWorldEntityComponentSetQuery.Update;
var Index,BitmapEntityIndex,EntityIndex,OtherIndex,Count,CommonBitmapSize,CommonComponentBitmapSize:TpvSizeInt;
    Value:TpvUInt64;
    EntityIDUsedBitmapValue:TpvUInt32;
    Entity:TpvEntity;
    OK:boolean;
begin
 
 if fGeneration<>fWorld.fGeneration then begin

  try

   CommonBitmapSize:=Min(length(fRequiredComponentBitmap),length(fExcludedComponentBitmap));

   Count:=0;
   try

    BitmapEntityIndex:=0;

    // Iterate over all used entity bitmap values with bittwiddling per bit scan forward to find the next set lowest bit
    for Index:=0 to Min(length(fWorld.fEntityIDUsedBitmap),(fWorld.fEntityIDCounter+31) shr 5)-1 do begin

     EntityIDUsedBitmapValue:=fWorld.fEntityIDUsedBitmap[Index];

     // Iterate over all set bits in the used entity bitmap value
     while EntityIDUsedBitmapValue<>0 do begin

      EntityIndex:=BitmapEntityIndex+TPasMPMath.BitScanForward32(EntityIDUsedBitmapValue);
      EntityIDUsedBitmapValue:=EntityIDUsedBitmapValue and (EntityIDUsedBitmapValue-1);

      Entity:=fWorld.fEntities[EntityIndex];

      OK:=true;

      CommonComponentBitmapSize:=Min(CommonBitmapSize,length(Entity.fComponentBitmap));

      for OtherIndex:=0 to CommonComponentBitmapSize-1 do begin
       Value:=Entity.fComponentBitmap[OtherIndex];
       if ((Value and fRequiredComponentBitmap[OtherIndex])<>fRequiredComponentBitmap[OtherIndex]) or
          ((Value and fExcludedComponentBitmap[OtherIndex])<>0) then begin
        OK:=false;
        break;
       end;
      end;

      if OK then begin

       for OtherIndex:=CommonComponentBitmapSize to CommonBitmapSize-1 do begin
        if fRequiredComponentBitmap[OtherIndex]<>0 then begin
         OK:=false;
         break;
        end;
       end;

       if OK then begin
        if Count>=length(fEntityIDs) then begin
         SetLength(fEntityIDs,(Count+1)+((Count+1) shr 1));
        end;
        fEntityIDs[Count]:=Entity.fID;
        inc(Count);
       end;

      end;

     end;

     inc(BitmapEntityIndex,32);

    end;

   finally
    SetLength(fEntityIDs,Count);
   end;

  finally
   fGeneration:=fWorld.fGeneration;
  end;

 end;

end;

{ TpvWorld }
constructor TpvWorld.Create(const aResourceManager:TpvResourceManager;const aParent:TpvResource;const aMetaResource:TpvMetaResource;const aParallelLoadable:TpvResource.TParallelLoadable);
begin
 inherited Create(aResourceManager,aParent,aMetaResource,aParallelLoadable);
 fUniverse:=TpvUniverse(pvApplication.Universe);
 fID:=fUniverse.fWorldIDManager.AllocateID;
 fUniverse.fWorlds.Add(self);
 fUniverse.fWorlds.fIDWorldHashMap.Add(fID,self);
 fUniverse.fWorlds.fUUIDWorldHashMap.Add(UUID,self);
 fGeneration:=0;
 fActive:=false;
 fKilled:=false;
 fSortKey:=0;
{$ifdef PasVulkanEditor}
 fTabsheet:=nil;
 fForm:=nil;
{$endif}
 fLock:=TPasMPMultipleReaderSingleWriterLock.Create;
 fComponentClassDataWrappers:=nil;
 fEntities:=nil;
 fEntityUUIDHashMap:=TWorldUUIDIndexHashMap.Create(-1);
 fReservedEntityUUIDHashMap:=TWorldUUIDIndexHashMap.Create(-1);
 fDelayedManagementEventLock:=TPasMPMultipleReaderSingleWriterLock.Create;
 fReservedEntityHashMapLock:=TPasMPMultipleReaderSingleWriterLock.Create;
 fEntityIDLock:=TPasMPMultipleReaderSingleWriterLock.Create;
 fEntityIDFreeList:=TWorldEntityIDFreeList.Create;
 fEntityIDCounter:=0;
 fEntityIDMax:=-1;
 fEntityIDUsedBitmap:=nil;
 fSystemList:=TList.Create;
 fSystemPointerIntegerPairHashMap:=TWorldSystemBooleanHashMap.Create(false);
 fSystemChoreography:=TpvSystemChoreography.Create(self);
 fSystemChoreographyNeedToRebuild:=0;
 fDelayedManagementEvents:=nil;
 fCountDelayedManagementEvents:=0;
 fEventListLock:=TPasMPMultipleReaderSingleWriterLock.Create;
 fEventList:=TList.Create;
 fDelayedEventQueueLock:=TPasMPMultipleReaderSingleWriterLock.Create;
 LinkedListInitialize(@fDelayedEventQueue);
 fEventQueueLock:=TPasMPMultipleReaderSingleWriterLock.Create;
 LinkedListInitialize(@fEventQueue);
 LinkedListInitialize(@fDelayedFreeEventQueue);
 fFreeEventQueueLock:=TPasMPMultipleReaderSingleWriterLock.Create;
 LinkedListInitialize(@fFreeEventQueue);
 fCurrentTime:=0;
 fOnEvent:=nil;
 fEventInProcessing:=false;
 fEventRegistrationLock:=TPasMPMultipleReaderSingleWriterLock.Create;
 fEventRegistrationList:=TList.Create;
 fFreeEventRegistrationList:=TList.Create;
 fEventRegistrationStringIntegerPairHashMap:=TWorldEventRegistrationStringIntegerPairHashMap.Create(-1);
end;

destructor TpvWorld.Destroy;
var Index:TpvInt32;
    Event:PpvEvent;
begin

 Clear;

 fUniverse.fWorlds.fIDWorldHashMap.Delete(fID);
 fUniverse.fWorlds.fUUIDWorldHashMap.Delete(UUID);
 fUniverse.fWorlds.Remove(self);

 fSystemChoreography.Free;

 fSystemList.Free;

 fSystemPointerIntegerPairHashMap.Free;

 fEntityUUIDHashMap.Free;

 fReservedEntityUUIDHashMap.Free;

 fEntityIDFreeList.Free;

 fDelayedManagementEventLock.Free;

 SetLength(fEntities,0);

 SetLength(fEntityIDUsedBitmap,0);

 SetLength(fDelayedManagementEvents,0);

 for Index:=0 to length(fComponentClassDataWrappers)-1 do begin
  fComponentClassDataWrappers[Index].Free;
 end;
 SetLength(fComponentClassDataWrappers,0);

 for Index:=0 to fEventList.Count-1 do begin
  Event:=fEventList.Items[Index];
  if assigned(Event) then begin
   Finalize(Event^);
   FreeMem(Event);
  end;
 end;
 fEventList.Free;

 fEventListLock.Free;

 fDelayedEventQueueLock.Free;

 fEventQueueLock.Free;

 fFreeEventQueueLock.Free;

 fEntityIDLock.Free;

 fReservedEntityHashMapLock.Free;

 fLock.Free;

 for Index:=0 to fEventRegistrationList.Count-1 do begin
  TpvEventRegistration(fEventRegistrationList.Items[Index]).Free;
 end;

 fEventRegistrationList.Free;

 fFreeEventRegistrationList.Free;

 fEventRegistrationStringIntegerPairHashMap.Free;

 fEventRegistrationLock.Free;

 fUniverse.fWorldIDManager.FreeID(fID);

 inherited Destroy;
end;

class function TpvWorld.GetMetaResourceClass:TpvMetaResourceClass;
begin
 result:=TpvMetaWorld;
end;

procedure TpvWorld.Kill;
begin
 fKilled:=true;
end;

function TpvWorld.CreateEvent(const aName:TpvUTF8String):TpvEventID;
var EventRegistration:TpvEventRegistration;
begin
 fEventRegistrationLock.AcquireWrite;
 try
  result:=fEventRegistrationStringIntegerPairHashMap.Values[aName];
  if result<0 then begin
   if fFreeEventRegistrationList.Count>0 then begin
    EventRegistration:=fFreeEventRegistrationList[fFreeEventRegistrationList.Count-1];
    fFreeEventRegistrationList.Delete(fFreeEventRegistrationList.Count-1);
    EventRegistration.Clear;
    EventRegistration.fName:=aName;
   end else begin
    EventRegistration:=TpvEventRegistration.Create(fEventRegistrationList.Count,aName);
    fEventRegistrationList.Add(EventRegistration);
   end;
   EventRegistration.fActive:=true;
   result:=EventRegistration.fEventID;
   fEventRegistrationStringIntegerPairHashMap.Add(aName,result);
  end;
 finally
  fEventRegistrationLock.ReleaseWrite;
 end;
end;

procedure TpvWorld.DestroyEvent(const aEventID:TpvEventID);
var EventRegistration:TpvEventRegistration;
begin
 fEventRegistrationLock.AcquireWrite;
 try
  if (aEventID>=0) and (aEventID<fEventRegistrationList.Count) then begin
   EventRegistration:=fEventRegistrationList.Items[aEventID];
   if EventRegistration.fActive then begin
    fEventRegistrationStringIntegerPairHashMap.Delete(EventRegistration.fName);
    EventRegistration.fActive:=false;
    EventRegistration.fName:='';
    EventRegistration.Clear;
    fFreeEventRegistrationList.Add(EventRegistration);
   end;
  end;
 finally
  fEventRegistrationLock.ReleaseWrite;
 end;
end;

function TpvWorld.FindEvent(const aName:TpvUTF8String):TpvEventID;
begin
 fEventRegistrationLock.AcquireRead;
 try
  result:=fEventRegistrationStringIntegerPairHashMap.Values[aName];
 finally
  fEventRegistrationLock.ReleaseRead;
 end;
end;

procedure TpvWorld.SubscribeToEvent(const aEventID:TpvEventID;const aEventHandler:TpvEventHandler);
var EventRegistration:TpvEventRegistration;
begin
 fEventRegistrationLock.AcquireWrite;
 try
  if (aEventID>=0) and (aEventID<fEventRegistrationList.Count) then begin
   EventRegistration:=fEventRegistrationList.Items[aEventID];
   if EventRegistration.fActive then begin
    EventRegistration.AddEventHandler(aEventHandler);
   end;
  end;
 finally
  fEventRegistrationLock.ReleaseWrite;
 end;
end;

procedure TpvWorld.UnsubscribeFromEvent(const aEventID:TpvEventID;const aEventHandler:TpvEventHandler);
var EventRegistration:TpvEventRegistration;
begin
 fEventRegistrationLock.AcquireWrite;
 try
  if (aEventID>=0) and (aEventID<fEventRegistrationList.Count) then begin
   EventRegistration:=fEventRegistrationList.Items[aEventID];
   if EventRegistration.fActive then begin
    EventRegistration.RemoveEventHandler(aEventHandler);
   end;
  end;
 finally
  fEventRegistrationLock.ReleaseWrite;
 end;
end;

procedure TpvWorld.AddDelayedManagementEvent(const aDelayedManagementEvent:TpvDelayedManagementEvent);
var DelayedManagementEventIndex:TpvInt32;
begin
 fDelayedManagementEventLock.AcquireWrite;
 try
  DelayedManagementEventIndex:=fCountDelayedManagementEvents;
  inc(fCountDelayedManagementEvents);
  if length(fDelayedManagementEvents)<fCountDelayedManagementEvents then begin
   SetLength(fDelayedManagementEvents,fCountDelayedManagementEvents*2);
  end;
  fDelayedManagementEvents[DelayedManagementEventIndex]:=aDelayedManagementEvent;
 finally
  fDelayedManagementEventLock.ReleaseWrite;
 end;
end;

function TpvWorld.GetComponentClassDataWrapper(const aComponentClass:TpvComponentClass):TpvComponentClassDataWrapper;
var Index,OldCount,NewCount:TpvInt32;
    ID:TpvComponentClassID;
begin
 result:=nil;
 fLock.AcquireRead;
 try
  if assigned(aComponentClass) then begin
   ID:=aComponentClass.ClassID;
   if ID>=0 then begin
    OldCount:=length(fComponentClassDataWrappers);
    if OldCount<=ID then begin
     NewCount:=RoundUpToPowerOfTwo(ID+1);
     SetLength(fComponentClassDataWrappers,NewCount);
     for Index:=OldCount to NewCount-1 do begin
      fComponentClassDataWrappers[Index]:=nil;
     end;
    end;
    result:=fComponentClassDataWrappers[ID];
    if not assigned(result) then begin
     result:=TpvComponentClassDataWrapper.Create(self,aComponentClass);
     fComponentClassDataWrappers[ID]:=result;
    end;
   end;
  end;
 finally
  fLock.ReleaseRead;
 end;
end;

function TpvWorld.GetEntityByID(const aEntityID:TpvEntityID):TpvEntity;
begin
 if (aEntityID>=0) and
    (aEntityID<fEntityIDCounter) and
    ((fEntityIDUsedBitmap[aEntityID shr 5] and TpvUInt32(TpvUInt32(1) shl TpvUInt32(aEntityID and 31)))<>0) then begin
  result:=fEntities[aEntityID];
 end else begin
  result:=nil;
 end;
end;

function TpvWorld.GetEntityByUUID(const aEntityUUID:TpvUUID):TpvEntity;
begin
 result:=GetEntityByID(fEntityUUIDHashMap.Values[aEntityUUID]);
end;

function TpvWorld.DoCreateEntity(const aEntityID:TpvEntityID;const aEntityUUID:TpvUUID):boolean;
var Index,OldCount,Count:TpvInt32;
    Bitmap:plongword;
    Entity:TpvEntity;
begin

 result:=false;

 fLock.AcquireRead;
 try

  fLock.ReadToWrite;
  try

   if fEntityIDMax<aEntityID then begin

    fEntityIDMax:=aEntityID;

{   for Index:=0 to fComponentDataStoreList.Count-1 do begin
     TpvComponentClass(fComponentDataStoreList[Index]).SetNewMaxEntities(fEntityIDCounter);
    end;}

    OldCount:=length(fEntities);
    Count:=fEntityIDCounter;
    if OldCount<Count then begin
     SetLength(fEntities,Count*2);
     for Index:=OldCount to length(fEntities)-1 do begin
      fEntities[Index]:=nil;
     end;
    end;

    OldCount:=length(fEntityIDUsedBitmap);
    Count:=(fEntityIDCounter+31) shr 5;
    if OldCount<Count then begin
     SetLength(fEntityIDUsedBitmap,Count*2);
     for Index:=OldCount to length(fEntityIDUsedBitmap)-1 do begin
      fEntityIDUsedBitmap[Index]:=0;
     end;
    end;

   end;

   Bitmap:=@fEntityIDUsedBitmap[aEntityID shr 5];
   Bitmap^:=Bitmap^ or TpvUInt32(TpvUInt32(1) shl TpvUInt32(aEntityID and 31));

   fEntities[aEntityID]:=TpvEntity.Create(self);
   Entity:=fEntities[aEntityID];
   Entity.fID:=aEntityID;
   Entity.fFlags:=[TpvEntity.TEntityFlag.Used];
   Entity.fUUID:=aEntityUUID;
{$ifdef PasVulkanEditor}
   Entity.fTreeNode:=nil;
{$endif}
   Entity.fUnknownData:=nil;

   fEntityUUIDHashMap.Add(aEntityUUID,aEntityID);

   result:=true;

  finally
   fLock.WriteToRead;
  end;

 finally
  fLock.ReleaseRead;
 end;

end;

function TpvWorld.DoDestroyEntity(const aEntityID:TpvEntityID):boolean;
var Index:TpvInt32;
    Bitmap:plongword;
    Mask:TpvUInt32;
    Entity:TpvEntity;
    Component:TpvComponent;
begin
 fLock.AcquireRead;
 try
  Bitmap:=@fEntityIDUsedBitmap[aEntityID shr 5];
  Mask:=TpvUInt32(TpvUInt32(1) shl TpvUInt32(aEntityID and 31));
  if (aEntityID>=0) and (aEntityID<fEntityIDCounter) and ((Bitmap^ and Mask)<>0) then begin
   fLock.ReadToWrite;
   try
    Bitmap:=@fEntityIDUsedBitmap[aEntityID shr 5]; // the pointer of fEntityIDUsedBitmap could be changed already here by an another CPU thread, so reload it
    Bitmap^:=Bitmap^ and not Mask;
    Entity:=fEntities[aEntityID];
    for Index:=0 to length(Entity.fComponents)-1 do begin
     Component:=Entity.fComponents[Index];
     if assigned(Component) then begin
      Entity.RemoveComponentFromEntity(Component);
      Component.Free;
     end;
    end;
    fEntityUUIDHashMap.Delete(Entity.UUID);
    fReservedEntityHashMapLock.AcquireWrite;
    try
     fReservedEntityUUIDHashMap.Delete(Entity.UUID);
    finally
     fReservedEntityHashMapLock.ReleaseWrite;
    end;
    Entity.Flags:=[];
    FreeAndNil(Entity.fUnknownData);
    fEntityIDLock.AcquireWrite;
    try
     fEntityIDFreeList.Add(aEntityID);
    finally
     fEntityIDLock.ReleaseWrite;
    end;
   finally
    fLock.WriteToRead;
   end;
   result:=true;
  end else begin
   result:=false;
  end;
 finally
  fLock.ReleaseRead;
 end;
end;

function TpvWorld.CreateEntity(const aEntityID:TpvEntityID;const aEntityUUID:TpvUUID):TpvEntityID;
var DelayedManagementEvent:TpvDelayedManagementEvent;
    EntityUUID:PpvUUID;
    AutoGeneratedUUID:TpvUUID;
    UUIDIsUnused:boolean;
begin
 result:=-1;
 fReservedEntityHashMapLock.AcquireRead;
 try
  if (aEntityUUID.UInt64s[0]=0) and (aEntityUUID.UInt64s[1]=0) then begin
   repeat
    AutoGeneratedUUID:=TpvUUID.Create;
   until fReservedEntityUUIDHashMap.Values[AutoGeneratedUUID]<0;
   EntityUUID:=@AutoGeneratedUUID;
   UUIDIsUnused:=true;
  end else begin
   EntityUUID:=@aEntityUUID;
   UUIDIsUnused:=fReservedEntityUUIDHashMap.Values[EntityUUID^]<0;
  end;
  if UUIDIsUnused then begin
   result:=aEntityID;
   if aEntityID<0 then begin
    fReservedEntityHashMapLock.ReadToWrite;
    try
     fEntityIDLock.AcquireWrite;
     try
      if fEntityIDFreeList.Count>0 then begin
       result:=fEntityIDFreeList.Items[fEntityIDFreeList.Count-1];
       fEntityIDFreeList.Delete(fEntityIDFreeList.Count-1);
      end else begin
       result:=fEntityIDCounter;
       inc(fEntityIDCounter);
      end;
     finally
      fEntityIDLock.ReleaseWrite;
     end;
     fReservedEntityUUIDHashMap.Add(EntityUUID^,result);
    finally
     fReservedEntityHashMapLock.WriteToRead;
    end;
   end else begin
    fReservedEntityHashMapLock.ReadToWrite;
    try
     fEntityIDLock.AcquireWrite;
     try
      if fEntityIDFreeList.IndexOf(result)>=0 then begin
       fEntityIDFreeList.Remove(result);
      end;
      fEntityIDCounter:=Max(fEntityIDCounter,result+1);
     finally
      fEntityIDLock.ReleaseWrite;
     end;
     fReservedEntityUUIDHashMap.Add(EntityUUID^,result);
    finally
     fReservedEntityHashMapLock.WriteToRead;
    end;
   end;
  end;
 finally
  fReservedEntityHashMapLock.ReleaseRead;
 end;
 if result>=0 then begin
  DelayedManagementEvent.EventType:=TpvDelayedManagementEventType.CreateEntity;
  DelayedManagementEvent.EntityID:=result;
  DelayedManagementEvent.UUID:=EntityUUID^;
  AddDelayedManagementEvent(DelayedManagementEvent);
 end;
end;

function TpvWorld.CreateEntity(const aEntityUUID:TpvUUID):TpvEntityID;
var DelayedManagementEvent:TpvDelayedManagementEvent;
    EntityUUID:PpvUUID;
    AutoGeneratedUUID:TpvUUID;
    UUIDIsUnused:boolean;
begin
 result:=-1;
 fReservedEntityHashMapLock.AcquireRead;
 try
  if (aEntityUUID.UInt64s[0]=0) and (aEntityUUID.UInt64s[1]=0) then begin
   repeat
    AutoGeneratedUUID:=TpvUUID.Create;
   until fReservedEntityUUIDHashMap.Values[AutoGeneratedUUID]<0;
   EntityUUID:=@AutoGeneratedUUID;
   UUIDIsUnused:=true;
  end else begin
   EntityUUID:=@aEntityUUID;
   UUIDIsUnused:=fReservedEntityUUIDHashMap.Values[EntityUUID^]<0;
  end;
  if UUIDIsUnused then begin
   fReservedEntityHashMapLock.ReadToWrite;
   try
    fEntityIDLock.AcquireWrite;
    try
     if fEntityIDFreeList.Count>0 then begin
      result:=fEntityIDFreeList.Items[fEntityIDFreeList.Count-1];
      fEntityIDFreeList.Delete(fEntityIDFreeList.Count-1);
     end else begin
      result:=fEntityIDCounter;
      inc(fEntityIDCounter);
     end;
    finally
     fEntityIDLock.ReleaseWrite;
    end;
    fReservedEntityUUIDHashMap.Add(EntityUUID^,result);
   finally
    fReservedEntityHashMapLock.WriteToRead;
   end;
  end;
 finally
  fReservedEntityHashMapLock.ReleaseRead;
 end;
 if result>=0 then begin
  DelayedManagementEvent.EventType:=TpvDelayedManagementEventType.CreateEntity;
  DelayedManagementEvent.EntityID:=result;
  DelayedManagementEvent.UUID:=EntityUUID^;
  AddDelayedManagementEvent(DelayedManagementEvent);
 end;
end;

function TpvWorld.CreateEntity:TpvEntityID;
begin
 result:=CreateEntity(TpvUUID.Null);
end;

function TpvWorld.HasEntity(const aEntityID:TpvEntityID):boolean;
begin
 fLock.AcquireRead;
 try
  result:=(aEntityID>=0) and
          (aEntityID<fEntityIDCounter) and
          ((fEntityIDUsedBitmap[aEntityID shr 5] and TpvUInt32(TpvUInt32(1) shl TpvUInt32(aEntityID and 31)))<>0);
 finally
  fLock.ReleaseRead;
 end;
end;

function TpvWorld.IsEntityActive(const aEntityID:TpvEntityID):boolean;
begin
 fLock.AcquireRead;
 try
  result:=(aEntityID>=0) and
          (aEntityID<fEntityIDCounter) and
          ((fEntityIDUsedBitmap[aEntityID shr 5] and TpvUInt32(TpvUInt32(1) shl TpvUInt32(aEntityID and 31)))<>0) and
          (TpvEntity.TEntityFlag.Active in fEntities[aEntityID].Flags);
 finally
  fLock.ReleaseRead;
 end;
end;

procedure TpvWorld.ActivateEntity(const aEntityID:TpvEntityID);
var DelayedManagementEvent:TpvDelayedManagementEvent;
begin
 DelayedManagementEvent.EventType:=TpvDelayedManagementEventType.ActivateEntity;
 DelayedManagementEvent.EntityID:=aEntityID;
 AddDelayedManagementEvent(DelayedManagementEvent);
end;

procedure TpvWorld.DeactivateEntity(const aEntityID:TpvEntityID);
var DelayedManagementEvent:TpvDelayedManagementEvent;
begin
 DelayedManagementEvent.EventType:=TpvDelayedManagementEventType.DeactivateEntity;
 DelayedManagementEvent.EntityID:=aEntityID;
 AddDelayedManagementEvent(DelayedManagementEvent);
end;

procedure TpvWorld.KillEntity(const aEntityID:TpvEntityID);
var DelayedManagementEvent:TpvDelayedManagementEvent;
begin
 DelayedManagementEvent.EventType:=TpvDelayedManagementEventType.DeactivateEntity;
 DelayedManagementEvent.EntityID:=aEntityID;
 AddDelayedManagementEvent(DelayedManagementEvent);
 DelayedManagementEvent.EventType:=TpvDelayedManagementEventType.KillEntity;
 AddDelayedManagementEvent(DelayedManagementEvent);
end;

procedure TpvWorld.AddComponentToEntity(const aEntityID:TpvEntityID;const aComponent:TpvComponent);
var DelayedManagementEvent:TpvDelayedManagementEvent;
begin
 DelayedManagementEvent.EventType:=TpvDelayedManagementEventType.AddComponentToEntity;
 DelayedManagementEvent.EntityID:=aEntityID;
 DelayedManagementEvent.Component:=aComponent;
 AddDelayedManagementEvent(DelayedManagementEvent);
end;

procedure TpvWorld.RemoveComponentFromEntity(const aEntityID:TpvEntityID;const aComponentClass:TpvComponentClass);
var DelayedManagementEvent:TpvDelayedManagementEvent;
begin
 DelayedManagementEvent.EventType:=TpvDelayedManagementEventType.RemoveComponentFromEntity;
 DelayedManagementEvent.EntityID:=aEntityID;
 DelayedManagementEvent.ComponentClass:=TpvComponentClass(aComponentClass);
 AddDelayedManagementEvent(DelayedManagementEvent);
end;

procedure TpvWorld.RemoveComponentFromEntity(const aEntityID:TpvEntityID;const aComponentClassID:TpvComponentClassID);
var DelayedManagementEvent:TpvDelayedManagementEvent;
begin
 DelayedManagementEvent.EventType:=TpvDelayedManagementEventType.RemoveComponentFromEntity;
 DelayedManagementEvent.EntityID:=aEntityID;
 DelayedManagementEvent.ComponentClass:=TpvComponentClass(fUniverse.RegisteredComponentClasses.ComponentByID[aComponentClassID]);
 AddDelayedManagementEvent(DelayedManagementEvent);
end;

function TpvWorld.HasEntityComponent(const aEntityID:TpvEntityID;const aComponentClass:TpvComponentClass):boolean;
begin
 fLock.AcquireRead;
 try
  result:=(aEntityID>=0) and
          (aEntityID<fEntityIDCounter) and
          ((fEntityIDUsedBitmap[aEntityID shr 5] and TpvUInt32(TpvUInt32(1) shl TpvUInt32(aEntityID and 31)))<>0) and
          fEntities[aEntityID].HasComponent(aComponentClass);
 finally
  fLock.ReleaseRead;
 end;
end;

function TpvWorld.HasEntityComponent(const aEntityID:TpvEntityID;const aComponentClassID:TpvComponentClassID):boolean;
begin
 fLock.AcquireRead;
 try
  result:=(aEntityID>=0) and
          (aEntityID<fEntityIDCounter) and
          ((fEntityIDUsedBitmap[aEntityID shr 5] and TpvUInt32(TpvUInt32(1) shl TpvUInt32(aEntityID and 31)))<>0) and
          fEntities[aEntityID].HasComponent(aComponentClassID);
 finally
  fLock.ReleaseRead;
 end;
end;

procedure TpvWorld.AddSystem(const aSystem:TpvSystem);
var DelayedManagementEvent:TpvDelayedManagementEvent;
begin
 DelayedManagementEvent.EventType:=TpvDelayedManagementEventType.AddSystem;
 DelayedManagementEvent.System:=aSystem;
 AddDelayedManagementEvent(DelayedManagementEvent);
end;

procedure TpvWorld.RemoveSystem(const aSystem:TpvSystem);
var DelayedManagementEvent:TpvDelayedManagementEvent;
begin
 DelayedManagementEvent.EventType:=TpvDelayedManagementEventType.RemoveSystem;
 DelayedManagementEvent.System:=aSystem;
 AddDelayedManagementEvent(DelayedManagementEvent);
end;

procedure TpvWorld.SortSystem(const aSystem:TpvSystem);
var DelayedManagementEvent:TpvDelayedManagementEvent;
begin
 DelayedManagementEvent.EventType:=TpvDelayedManagementEventType.SortSystem;
 DelayedManagementEvent.System:=aSystem;
 AddDelayedManagementEvent(DelayedManagementEvent);
end;

function TWorldDefragmentCompare(const a,b:pointer):TpvInt32;
begin
 result:=TpvPtrInt(TpvPtrUInt(a))-TpvPtrInt(TpvPtrUInt(b));
end;

type TWorldDefragmentList=class
      private
       fItems:array of TObject;
       fCount:TpvInt32;
       function GetItem(const aIndex:TpvInt32):TObject; inline;
       procedure SetItem(const aIndex:TpvInt32;const aItem:TObject); inline;
      public
       constructor Create(const aCount:TpvInt32);
       destructor Destroy; override;
       procedure MemorySwap(aA,aB:pointer;aSize:TpvInt32);
       function CompareItem(const aIndex,pWithIndex:TpvSizeInt):TpvInt32; inline;
       procedure Exchange(const aIndex,pWithIndex:TpvSizeInt); virtual;
       procedure Sort;
       property Items[const aIndex:TpvInt32]:TObject read GetItem write SetItem;
       property Count:TpvInt32 read fCount;
     end;

constructor TWorldDefragmentList.Create(const aCount:TpvInt32);
begin
 inherited Create;
 fItems:=nil;
 fCount:=aCount;
 SetLength(fItems,fCount);
 if fCount>0 then begin
  FillChar(fItems[0],fCount*SizeOf(TObject),#0);
 end;
end;

destructor TWorldDefragmentList.Destroy;
begin
 SetLength(fItems,0);
 inherited Destroy;
end;

function TWorldDefragmentList.GetItem(const aIndex:TpvInt32):TObject;
begin
 result:=fItems[aIndex];
end;

procedure TWorldDefragmentList.SetItem(const aIndex:TpvInt32;const aItem:TObject);
begin
 fItems[aIndex]:=aItem;
end;

procedure TWorldDefragmentList.MemorySwap(aA,aB:pointer;aSize:TpvInt32);
var Temp:TpvInt32;
begin
 while aSize>=SizeOf(TpvInt32) do begin
  Temp:=TpvUInt32(aA^);
  TpvUInt32(aA^):=TpvUInt32(aB^);
  TpvUInt32(aB^):=Temp;
  inc(TpvPtrUInt(aA),SizeOf(TpvUInt32));
  inc(TpvPtrUInt(aB),SizeOf(TpvUInt32));
  dec(aSize,SizeOf(TpvUInt32));
 end;
 while aSize>=SizeOf(TpvUInt8) do begin
  Temp:=TpvUInt8(aA^);
  TpvUInt8(aA^):=TpvUInt8(aB^);
  TpvUInt8(aB^):=Temp;
  inc(TpvPtrUInt(aA),SizeOf(TpvUInt8));
  inc(TpvPtrUInt(aB),SizeOf(TpvUInt8));
  dec(aSize,SizeOf(TpvUInt8));
 end;
end;

function TWorldDefragmentList.CompareItem(const aIndex,pWithIndex:TpvSizeInt):TpvInt32;
begin
 result:=TpvPtrInt(TpvPtrUInt(TObject(fItems[aIndex])))-TpvPtrInt(TpvPtrUInt(TObject(fItems[pWithIndex])));
end;

procedure TWorldDefragmentList.Exchange(const aIndex,pWithIndex:TpvSizeInt);
begin
end;

procedure TWorldDefragmentList.Sort;
type PByteArray=^TByteArray;
     TByteArray=array[0..$3fffffff] of TpvUInt8;
     PStackItem=^TStackItem;
     TStackItem=record
      Left,Right,Depth:TpvInt32;
     end;
var Left,Right,Depth,i,j,Middle,Size,Parent,Child,Pivot,iA,iB,iC:TpvInt32;
    StackItem:PStackItem;
    Stack:array[0..31] of TStackItem;
begin
 if fCount>1 then begin
  StackItem:=@Stack[0];
  StackItem^.Left:=0;
  StackItem^.Right:=fCount-1;
  StackItem^.Depth:=IntLog2(fCount) shl 1;
  inc(StackItem);
  while TpvPtrUInt(pointer(StackItem))>TpvPtrUInt(pointer(@Stack[0])) do begin
   dec(StackItem);
   Left:=StackItem^.Left;
   Right:=StackItem^.Right;
   Depth:=StackItem^.Depth;
   Size:=(Right-Left)+1;
   if Size<16 then begin
    // Insertion sort
    iA:=Left;
    iB:=iA+1;
    while iB<=Right do begin
     iC:=iB;
     while (iA>=Left) and
           (iC>=Left) and
           (CompareItem(iA,iC)>0) do begin
      Exchange(iA,iC);
      dec(iA);
      dec(iC);
     end;
     iA:=iB;
     inc(iB);
    end;
   end else begin
    if (Depth=0) or (TpvPtrUInt(pointer(StackItem))>=TpvPtrUInt(pointer(@Stack[high(Stack)-1]))) then begin
     // Heap sort
     i:=Size div 2;
     repeat
      if i>0 then begin
       dec(i);
      end else begin
       dec(Size);
       if Size>0 then begin
        Exchange(Left+Size,Left);
       end else begin
        break;
       end;
      end;
      Parent:=i;
      repeat
       Child:=(Parent*2)+1;
       if Child<Size then begin
        if (Child<(Size-1)) and (CompareItem(Left+Child,Left+Child+1)<0) then begin
         inc(Child);
        end;
        if CompareItem(Left+Parent,Left+Child)<0 then begin
         Exchange(Left+Parent,Left+Child);
         Parent:=Child;
         continue;
        end;
       end;
       break;
      until false;
     until false;
    end else begin
     // Quick sort width median-of-three optimization
     Middle:=Left+((Right-Left) shr 1);
     if (Right-Left)>3 then begin
      if CompareItem(Left,Middle)>0 then begin
       Exchange(Left,Middle);
      end;
      if CompareItem(Left,Right)>0 then begin
       Exchange(Left,Right);
      end;
      if CompareItem(Middle,Right)>0 then begin
       Exchange(Middle,Right);
      end;
     end;
     Pivot:=Middle;
     i:=Left;
     j:=Right;
     repeat
      while (i<Right) and (CompareItem(i,Pivot)<0) do begin
       inc(i);
      end;
      while (j>=i) and (CompareItem(j,Pivot)>0) do begin
       dec(j);
      end;
      if i>j then begin
       break;
      end else begin
       if i<>j then begin
        Exchange(i,j);
        if Pivot=i then begin
         Pivot:=j;
        end else if Pivot=j then begin
         Pivot:=i;
        end;
       end;
       inc(i);
       dec(j);
      end;
     until false;
     if i<Right then begin
      StackItem^.Left:=i;
      StackItem^.Right:=Right;
      StackItem^.Depth:=Depth-1;
      inc(StackItem);
     end;
     if Left<j then begin
      StackItem^.Left:=Left;
      StackItem^.Right:=j;
      StackItem^.Depth:=Depth-1;
      inc(StackItem);
     end;
    end;
   end;
  end;
 end;
end;

type TWorldDefragmentListComponents=class(TWorldDefragmentList)
      private
       fEntities:TpvEntities;
      public
       procedure Exchange(const aIndex,pWithIndex:TpvSizeInt); override;
     end;

procedure TWorldDefragmentListComponents.Exchange(const aIndex,pWithIndex:TpvSizeInt);
var a,b:TpvComponent;
    t:TpvEntity;
begin

 a:=TpvComponent(fItems[aIndex]);
 b:=TpvComponent(fItems[pWithIndex]);
 MemorySwap(a,b,a.ClassType.InstanceSize);
 fItems[aIndex]:=b;
 fItems[pWithIndex]:=a;

 t:=fEntities[aIndex];
 fEntities[aIndex]:=fEntities[pWithIndex];
 fEntities[pWithIndex]:=t;

end;

type TWorldDefragmentListEntities=class(TWorldDefragmentList)
      public
       procedure Exchange(const aIndex,pWithIndex:TpvSizeInt); override;
     end;

procedure TWorldDefragmentListEntities.Exchange(const aIndex,pWithIndex:TpvSizeInt);
var a,b:TpvEntity;
begin
 a:=TpvEntity(fItems[aIndex]);
 b:=TpvEntity(fItems[pWithIndex]);
 MemorySwap(a,b,TpvEntity.InstanceSize);
 fItems[aIndex]:=b;
 fItems[pWithIndex]:=a;
end;

procedure TpvWorld.Defragment;
 procedure DefragmentComponents;
 var EntityID:TpvEntityID;
     ComponentClassID:TpvComponentClassID;
     ComponentIndex,EntityIndex,Count:TpvInt32;
     LastComponent,CurrentComponent:TpvComponent;
     CurrentEntity:TpvEntity;
     Components:TWorldDefragmentListComponents;
     MustDo:boolean;
 begin
  for ComponentIndex:=0 to fUniverse.RegisteredComponentClasses.Count-1 do begin
   ComponentClassID:=ComponentIndex;

   LastComponent:=nil;
   MustDo:=false;
   Count:=0;
   for EntityID:=0 to fEntityIDCounter-1 do begin
    CurrentEntity:=fEntities[EntityID];
    if assigned(CurrentEntity) then begin
     CurrentComponent:=CurrentEntity.ComponentByClassID[ComponentClassID];
     if assigned(CurrentComponent) then begin
      inc(Count);
      if TpvPtrUInt(LastComponent)>TpvPtrUInt(CurrentComponent) then begin
       MustDo:=true;
      end;
      LastComponent:=CurrentComponent;
     end;
    end;
   end;

   if MustDo and (Count>0) then begin

    Components:=TWorldDefragmentListComponents.Create(Count);
    try

     SetLength(Components.fEntities,Count);
     Count:=0;
     for EntityID:=0 to fEntityIDCounter-1 do begin
      CurrentEntity:=fEntities[EntityID];
      if assigned(CurrentEntity) then begin
       CurrentComponent:=CurrentEntity.ComponentByClassID[ComponentClassID];
       if assigned(CurrentComponent) then begin
        Components.fItems[Count]:=TObject(CurrentComponent);
        Components.fEntities[Count]:=CurrentEntity;
        inc(Count);
       end;
      end;
     end;

     Components.Sort;

     for EntityIndex:=0 to Components.Count-1 do begin
      CurrentEntity:=Components.fEntities[EntityIndex];
      CurrentEntity.RawComponents[ComponentClassID]:=pointer(Components.fItems[EntityIndex]);
     end;

    finally
     Components.Free;
    end;

   end;

  end;

 end;
 procedure DefragmentEntities;
 var EntityID:TpvEntityID;
     EntityIndex,SystemIndex,Count:TpvInt32;
     LastEntity,CurrentEntity:TpvEntity;
     Entities:TWorldDefragmentListEntities;
     MustDo:boolean;
     System:TpvSystem;
 begin

  Count:=0;
  LastEntity:=nil;
  MustDo:=false;
  for EntityID:=0 to fEntityIDCounter-1 do begin
   CurrentEntity:=fEntities[EntityID];
   if assigned(CurrentEntity) then begin
    inc(Count);
    if TpvPtrUInt(LastEntity)>TpvPtrUInt(CurrentEntity) then begin
     MustDo:=true;
    end;
    LastEntity:=CurrentEntity;
   end;
  end;

  if MustDo and (Count>1) then begin

   Entities:=TWorldDefragmentListEntities.Create(Count);
   try

    Count:=0;
    for EntityID:=0 to fEntityIDCounter-1 do begin
     CurrentEntity:=fEntities[EntityID];
     if assigned(CurrentEntity) then begin
      Entities.fItems[Count]:=CurrentEntity;
      inc(Count);
     end;
    end;

    Entities.Sort;

    Count:=0;
    for EntityID:=0 to fEntityIDCounter-1 do begin
     if assigned(fEntities[EntityID]) then begin
      fEntities[EntityID]:=TpvEntity(Entities.fItems[Count]);
      inc(Count);
     end;
    end;

    for SystemIndex:=0 to fSystemList.Count-1 do begin
     System:=TpvSystem(fSystemList.Items[SystemIndex]);
     for EntityIndex:=0 to System.fCountEntities-1 do begin
      System.fEntities.fEntities[EntityIndex]:=EntityByID[System.fEntityIDs[EntityIndex]];
     end;
    end;

   finally
    Entities.Free;
   end;

  end;

 end;
begin
 DefragmentComponents;
 DefragmentEntities;
end;

procedure TpvWorld.Refresh;
var DelayedManagementEventIndex,Index:TpvInt32;
    DelayedManagementEvent:PpvDelayedManagementEvent;
    EntityID:TpvEntityID;
    Entity:TpvEntity;
    Component:TpvComponent;
    ComponentClass:TpvComponentClass;
    System:TpvSystem;
    EntitiesWereAdded,EntitiesWereRemoved,WasActive:boolean;
begin

 EntitiesWereAdded:=false;
 EntitiesWereRemoved:=false;

 fDelayedManagementEventLock.AcquireRead;
 try

  DelayedManagementEventIndex:=0;
  while DelayedManagementEventIndex<fCountDelayedManagementEvents do begin
   DelayedManagementEvent:=@fDelayedManagementEvents[DelayedManagementEventIndex];
   inc(DelayedManagementEventIndex);
   inc(fGeneration);
   case DelayedManagementEvent^.EventType of
    TpvDelayedManagementEventType.CreateEntity:begin
     EntityID:=DelayedManagementEvent^.EntityID;
     if (EntityID>=0) and (EntityID<fEntityIDCounter) then begin
      DoCreateEntity(EntityID,DelayedManagementEvent^.UUID);
     end;
    end;
    TpvDelayedManagementEventType.ActivateEntity:begin
     EntityID:=DelayedManagementEvent^.EntityID;
     if (EntityID>=0) and
        (EntityID<fEntityIDCounter) and
        ((fEntityIDUsedBitmap[EntityID shr 5] and TpvUInt32(TpvUInt32(1) shl TpvUInt32(EntityID and 31)))<>0) and
        not (TpvEntity.TEntityFlag.Active in fEntities[EntityID].Flags) then begin
      for Index:=0 to fSystemList.Count-1 do begin
       System:=TpvSystem(fSystemList.Items[Index]);
       if System.FitsEntityToSystem(EntityID) then begin
        System.AddEntityToSystem(EntityID);
        EntitiesWereAdded:=true;
       end;
      end;
      Include(fEntities[EntityID].fFlags,TpvEntity.TEntityFlag.Active);
     end;
    end;
    TpvDelayedManagementEventType.DeactivateEntity:begin
     EntityID:=DelayedManagementEvent^.EntityID;
     if (EntityID>=0) and
        (EntityID<fEntityIDCounter) and
        ((fEntityIDUsedBitmap[EntityID shr 5] and TpvUInt32(TpvUInt32(1) shl TpvUInt32(EntityID and 31)))<>0) and
        (TpvEntity.TEntityFlag.Active in fEntities[EntityID].Flags) then begin
      Exclude(fEntities[EntityID].fFlags,TpvEntity.TEntityFlag.Active);
      for Index:=0 to fSystemList.Count-1 do begin
       System:=TpvSystem(fSystemList.Items[Index]);
       System.RemoveEntityFromSystem(EntityID);
       EntitiesWereRemoved:=true;
      end;
     end;
    end;
    TpvDelayedManagementEventType.KillEntity:begin
     EntityID:=DelayedManagementEvent^.EntityID;
     if (EntityID>=0) and
        (EntityID<fEntityIDCounter) and
        ((fEntityIDUsedBitmap[EntityID shr 5] and TpvUInt32(TpvUInt32(1) shl TpvUInt32(EntityID and 31)))<>0) then begin
      for Index:=0 to fSystemList.Count-1 do begin
       System:=TpvSystem(fSystemList.Items[Index]);
       System.RemoveEntityFromSystem(EntityID);
       EntitiesWereRemoved:=true;
      end;
      fDelayedManagementEventLock.ReleaseRead;
      try
       DoDestroyEntity(EntityID);
      finally
       fDelayedManagementEventLock.AcquireRead;
      end;
     end;
    end;
    TpvDelayedManagementEventType.AddComponentToEntity:begin
     EntityID:=DelayedManagementEvent^.EntityID;
     if (EntityID>=0) and
        (EntityID<fEntityIDCounter) and
        ((fEntityIDUsedBitmap[EntityID shr 5] and TpvUInt32(TpvUInt32(1) shl TpvUInt32(EntityID and 31)))<>0) then begin
      Component:=DelayedManagementEvent^.Component;
      if assigned(Component) then begin
       WasActive:=TpvEntity.TEntityFlag.Active in fEntities[EntityID].Flags;
       if WasActive then begin
        for Index:=0 to fSystemList.Count-1 do begin
         System:=TpvSystem(fSystemList.Items[Index]);
         System.RemoveEntityFromSystem(EntityID);
         EntitiesWereRemoved:=true;
        end;
       end;
       Entity:=fEntities[EntityID];
       Entity.AddComponentToEntity(Component);
       if WasActive then begin
        for Index:=0 to fSystemList.Count-1 do begin
         System:=TpvSystem(fSystemList.Items[Index]);
         if System.FitsEntityToSystem(EntityID) then begin
          System.AddEntityToSystem(EntityID);
          EntitiesWereAdded:=true;
         end;
        end;
       end;
      end;
     end;
    end;
    TpvDelayedManagementEventType.RemoveComponentFromEntity:begin
     EntityID:=DelayedManagementEvent^.EntityID;
     if (EntityID>=0) and
        (EntityID<fEntityIDCounter) and
        ((fEntityIDUsedBitmap[EntityID shr 5] and TpvUInt32(TpvUInt32(1) shl TpvUInt32(EntityID and 31)))<>0) then begin
      ComponentClass:=DelayedManagementEvent^.ComponentClass;
      if assigned(ComponentClass) then begin
       WasActive:=TpvEntity.TEntityFlag.Active in fEntities[EntityID].Flags;
       if WasActive then begin
        for Index:=0 to fSystemList.Count-1 do begin
         System:=TpvSystem(fSystemList.Items[Index]);
         System.RemoveEntityFromSystem(EntityID);
         EntitiesWereRemoved:=true;
        end;
       end;
       Entity:=fEntities[EntityID];
       if assigned(Entity) then begin
        Component:=Entity.GetComponent(ComponentClass);
        if assigned(Component) then begin
         Entity.RemoveComponentFromEntity(Component);
         Component.Free;
        end;
       end;
       if WasActive then begin
        for Index:=0 to fSystemList.Count-1 do begin
         System:=TpvSystem(fSystemList.Items[Index]);
         if System.FitsEntityToSystem(EntityID) then begin
          System.AddEntityToSystem(EntityID);
          EntitiesWereAdded:=true;
         end;
        end;
       end;
      end;
     end;
    end;
    TpvDelayedManagementEventType.AddSystem:begin
     System:=DelayedManagementEvent^.System;
     if not fSystemPointerIntegerPairHashMap.Values[System] then begin
      fSystemPointerIntegerPairHashMap.Add(System,true);
      fSystemList.Add(System);
      InterlockedExchange(fSystemChoreographyNeedToRebuild,-1);
      for EntityID:=0 to fEntityIDCounter-1 do begin
       if (EntityID>=0) and
           (EntityID<fEntityIDCounter) and
           ((fEntityIDUsedBitmap[EntityID shr 5] and TpvUInt32(TpvUInt32(1) shl TpvUInt32(EntityID and 31)))<>0) and
           (TpvEntity.TEntityFlag.Active in fEntities[EntityID].Flags) and
           System.FitsEntityToSystem(EntityID) then begin
        System.AddEntityToSystem(EntityID);
        EntitiesWereAdded:=true;
       end;
      end;
      System.Added;
     end;
    end;
    TpvDelayedManagementEventType.RemoveSystem:begin
     System:=DelayedManagementEvent^.System;
     if fSystemPointerIntegerPairHashMap.Values[System] then begin
      System.Removed;
      fSystemPointerIntegerPairHashMap.Delete(System);
      fSystemList.Remove(System);
      InterlockedExchange(fSystemChoreographyNeedToRebuild,-1);
     end;
    end;
    TpvDelayedManagementEventType.SortSystem:begin
     System:=DelayedManagementEvent^.System;
     if fSystemPointerIntegerPairHashMap.Values[System] then begin
      System.SortEntities;
     end;
    end;
   end;
  end;
  fDelayedManagementEventLock.ReadToWrite;
  try
   fCountDelayedManagementEvents:=0;
  finally
   fDelayedManagementEventLock.WriteToRead;
  end;
 finally
  fDelayedManagementEventLock.ReleaseRead;
 end;

 if EntitiesWereAdded then begin
 end;

 if EntitiesWereRemoved then begin
 end;

end;

procedure TpvWorld.ProcessEvent(const aEvent:PpvEvent);
var EventHandlerIndex,SystemIndex,EventIndex:TpvInt32;
    EventRegistration:TpvEventRegistration;
    EventID:TpvEventID;
    EventHandler:TpvEventHandler;
    System:TpvSystem;
    LocalSystemList:TList;
begin
 fEventRegistrationLock.AcquireWrite;
 try
  EventID:=aEvent^.EventID;
  if (EventID>=0) and (EventID<fEventRegistrationList.Count) then begin
   EventRegistration:=fEventRegistrationList.Items[EventID];
   if EventRegistration.fActive then begin
    LocalSystemList:=EventRegistration.SystemList;
    for SystemIndex:=0 to LocalSystemList.Count-1 do begin
     System:=LocalSystemList.Items[SystemIndex];
     if assigned(System) then begin
      if System.fEventsCanBeParallelProcessed then begin
       EventIndex:=System.fCountEvents;
       inc(System.fCountEvents);
       if length(System.fEvents)<System.fCountEvents then begin
        SetLength(System.fEvents,System.fCountEvents*2);
       end;
       System.fEvents[EventIndex]:=aEvent;
      end else begin
       System.ProcessEvent(aEvent^);
      end;
     end;
    end;
    for EventHandlerIndex:=0 to EventRegistration.fCountEventHandlers-1 do begin
     EventHandler:=EventRegistration.fEventHandlers[EventHandlerIndex];
     if assigned(EventHandler) then begin
      fEventRegistrationLock.ReleaseWrite;
      try
       EventRegistration.Lock.AcquireRead;
       try
        EventHandler(aEvent^);
       finally
        EventRegistration.Lock.ReleaseRead;
       end;
      finally
       fEventRegistrationLock.AcquireWrite;
      end;
     end;
    end;
   end;
  end;
 finally
  fEventRegistrationLock.ReleaseWrite;
 end;
end;

procedure TpvWorld.ProcessEvents;
var CurrentEvent:PpvEvent;
    LocalEventQueue:TpvLinkedListHead;
begin
 LinkedListInitialize(@LocalEventQueue);
 repeat
  fEventQueueLock.AcquireWrite;
  try
   LinkedListSpliceTailInitialize(@LocalEventQueue,@fEventQueue);
  finally
   fEventQueueLock.ReleaseWrite;
  end;
  CurrentEvent:=LinkedListPopFront(@LocalEventQueue);
  if assigned(CurrentEvent) then begin
   repeat
    ProcessEvent(CurrentEvent);
    LinkedListPushBack(@fDelayedFreeEventQueue,pointer(CurrentEvent));
    CurrentEvent:=LinkedListPopFront(@LocalEventQueue);
   until not assigned(CurrentEvent);
  end else begin
   break;
  end;
 until false;
end;

procedure TpvWorld.ProcessDelayedEvents(const aDeltaTime:TpvTime);
var CurrentEvent,NextEvent:PpvEvent;
begin
 fDelayedEventQueueLock.AcquireWrite;
 fEventQueueLock.AcquireWrite;
 try
  if not LinkedListEmpty(@fDelayedEventQueue) then begin
   CurrentEvent:=LinkedListHead(@fDelayedEventQueue);
   repeat
    NextEvent:=LinkedListNext(@fDelayedEventQueue,pointer(CurrentEvent));
    CurrentEvent^.RemainingTime:=CurrentEvent^.RemainingTime-aDeltaTime;
    if CurrentEvent^.RemainingTime<=0.0 then begin
     LinkedListRemove(pointer(CurrentEvent));
     LinkedListPushBack(@fEventQueue,pointer(CurrentEvent));
    end;
    CurrentEvent:=NextEvent;
   until not assigned(CurrentEvent);
  end;
 finally
  fEventQueueLock.ReleaseWrite;
  fDelayedEventQueueLock.ReleaseWrite;
 end;
 if not LinkedListEmpty(@fDelayedFreeEventQueue) then begin
  fFreeEventQueueLock.AcquireWrite;
  try
   LinkedListSpliceTailInitialize(@fFreeEventQueue,@fDelayedFreeEventQueue);
  finally
   fFreeEventQueueLock.ReleaseWrite;
  end;
 end;
end;

procedure TpvWorld.QueueEvent(const aEventToQueue:TpvEvent;const aDeltaTime:TpvTime);
var ParameterIndex:TpvInt32;
    Event:PpvEvent;
begin
 fFreeEventQueueLock.AcquireWrite;
 try
  Event:=LinkedListPopFront(@fFreeEventQueue);
 finally
  fFreeEventQueueLock.ReleaseWrite;
 end;
 if not assigned(Event) then begin
  GetMem(Event,SizeOf(TpvEvent));
  FillChar(Event^,SizeOf(TpvEvent),#0);
  System.Initialize(Event^);
  fEventListLock.AcquireWrite;
  try
   fEventList.Add(Event);
  finally
   fEventListLock.ReleaseWrite;
  end;
 end;
 LinkedListInitialize(pointer(Event));
 if aDeltaTime>=0.0 then begin
  fDelayedEventQueueLock.AcquireWrite;
  try
   LinkedListPushBack(@fDelayedEventQueue,pointer(Event));
  finally
   fDelayedEventQueueLock.ReleaseWrite;
  end;
 end else begin
  fEventQueueLock.AcquireWrite;
  try
   LinkedListPushBack(@fEventQueue,pointer(Event));
  finally
   fEventQueueLock.ReleaseWrite;
  end;
 end;
 Event^.TimeStamp:=fCurrentTime+Max(0.0,aDeltaTime);
 Event^.RemainingTime:=Max(0.0,aDeltaTime);
 Event^.EventID:=aEventToQueue.EventID;
 Event^.EntityID:=aEventToQueue.EntityID;
 Event^.CountParameters:=aEventToQueue.CountParameters;
 if length(Event^.Parameters)<Event^.CountParameters then begin
  SetLength(Event^.Parameters,Event^.CountParameters*2);
 end;
 for ParameterIndex:=0 to Event^.CountParameters-1 do begin
  Event^.Parameters[ParameterIndex]:=aEventToQueue.Parameters[ParameterIndex];
 end;
 if assigned(fOnEvent) then begin
  fOnEvent(self,Event^);
 end;
end;

procedure TpvWorld.Update(const aDeltaTime:TpvTime);
var SystemIndex:TpvInt32;
    System:TpvSystem;
begin
 for SystemIndex:=0 to self.fSystemList.Count-1 do begin
  System:=TpvSystem(fSystemList.Items[SystemIndex]);
  System.fCountEvents:=0;
  System.fDeltaTime:=aDeltaTime;
 end;
 ProcessEvents;
 if InterlockedCompareExchange(fSystemChoreographyNeedToRebuild,0,-1)<0 then begin
  fSystemChoreography.Build;
 end;
 fSystemChoreography.ProcessEvents;
 fSystemChoreography.InitializeUpdate;
 fSystemChoreography.Update;
 fSystemChoreography.FinalizeUpdate;
 fCurrentTime:=fCurrentTime+aDeltaTime;
 ProcessDelayedEvents(aDeltaTime);
 Refresh;
end;

procedure TpvWorld.Clear;
var Index:TpvInt32;
begin
 fLock.AcquireRead;
 try
  if fEntityIDCounter>0 then begin
   fLock.ReleaseRead;
   try
    for Index:=0 to fEntityIDCounter-1 do begin
     if (fEntityIDUsedBitmap[Index shr 5] and TpvUInt32(TpvUInt32(1) shl TpvUInt32(Index and 31)))<>0 then begin
      KillEntity(Index);
     end;
    end;
    Refresh;
   finally
    fLock.AcquireRead;
   end;
  end;
  if fSystemList.Count>0 then begin
   fLock.ReleaseRead;
   try
    for Index:=0 to fSystemList.Count-1 do begin
     RemoveSystem(fSystemList.Items[Index]);
    end;
    Refresh;
   finally
    fLock.AcquireRead;
   end;
  end;
 finally
  fLock.ReleaseRead;
 end;
 inc(fGeneration);
 fEntityIDCounter:=0;
 fEntityUUIDHashMap.Clear;
 fReservedEntityUUIDHashMap.Clear;
 fEntityIDFreeList.Clear;
end;

procedure TpvWorld.ClearEntities;
var Index:TpvInt32;
begin
 fLock.AcquireRead;
 try
  if fEntityIDCounter>0 then begin
   fLock.ReleaseRead;
   try
    for Index:=0 to fEntityIDCounter-1 do begin
     if (fEntityIDUsedBitmap[Index shr 5] and TpvUInt32(TpvUInt32(1) shl TpvUInt32(Index and 31)))<>0 then begin
      KillEntity(Index);
     end;
    end;
    Refresh;
   finally
    fLock.AcquireRead;
   end;
  end;
 finally
  fLock.ReleaseRead;
 end;
 inc(fGeneration);
 fEntityIDCounter:=0;
 fEntityUUIDHashMap.Clear;
 fReservedEntityUUIDHashMap.Clear;
 fEntityIDFreeList.Clear;
end;

procedure TpvWorld.Activate;
begin
 fActive:=true;
end;

procedure TpvWorld.Deactivate;
begin
 fActive:=false;
end;

type TWorldMementoBitmapArray=array of TpvUInt32;

     TWorldMementoBitmap=class
      private
       fBitmap:TWorldMementoBitmapArray;
       fCount:TpvInt32;
       function GetBit(const aIndex:TpvInt32):boolean;
       procedure SetBit(const aIndex:TpvInt32;const aValue:boolean);
      public
       constructor Create(const aCount:TpvInt32); reintroduce;
       destructor Destroy; override;
       procedure LoadFromStream(const aStream:TStream);
       procedure SaveToStream(const aStream:TStream);
       property Bits[const aIndex:TpvInt32]:boolean read GetBit write SetBit; default;
      published
       property Count:TpvInt32 read fCount;
     end;

constructor TWorldMementoBitmap.Create(const aCount:TpvInt32);
begin
 inherited Create;
 fBitmap:=nil;
 fCount:=aCount;
 SetLength(fBitmap,(fCount+31) shr 5);
 if aCount>0 then begin
  FillChar(fBitmap[0],((fCount+31) shr 5)*SizeOf(TpvUInt32),#0);
 end;
end;

destructor TWorldMementoBitmap.Destroy;
begin
 SetLength(fBitmap,0);
 inherited Destroy;
end;

function TWorldMementoBitmap.GetBit(const aIndex:TpvInt32):boolean;
begin
 result:=((aIndex>=0) and (aIndex<fCount)) and
         ((fBitmap[aIndex shr 5] and (TpvUInt32(1) shl (aIndex and 31)))<>0);
end;

procedure TWorldMementoBitmap.SetBit(const aIndex:TpvInt32;const aValue:boolean);
begin
 if (aIndex>=0) and (aIndex<fCount) then begin
  if aValue then begin
   fBitmap[aIndex shr 5]:=fBitmap[aIndex shr 5] or (TpvUInt32(1) shl (aIndex and 31));
  end else begin
   fBitmap[aIndex shr 5]:=fBitmap[aIndex shr 5] and not (TpvUInt32(1) shl (aIndex and 31));
  end;
 end;
end;

procedure TWorldMementoBitmap.LoadFromStream(const aStream:TStream);
begin
 if fCount>0 then begin
  if aStream.Read(fBitmap[0],((fCount+31) shr 5)*SizeOf(TpvUInt32))<>(((fCount+31) shr 5)*SizeOf(TpvUInt32)) then begin
   raise EInOutError.Create('Stream read error');
  end;
 end;
end;

procedure TWorldMementoBitmap.SaveToStream(const aStream:TStream);
begin
 if fCount>0 then begin
  if aStream.Write(fBitmap[0],((fCount+31) shr 5)*SizeOf(TpvUInt32))<>(((fCount+31) shr 5)*SizeOf(TpvUInt32)) then begin
   raise EInOutError.Create('Stream write error');
  end;
 end;
end;

procedure TpvWorld.MementoSerialize(const aStream:TStream);
var ComponentClassID,BitCounter:TpvInt32;
    BitTag:TpvUInt8;
    BitPosition:TpvInt64;
    EntityID:TpvEntityID;
    Entity:TpvEntity;
    Component:TpvComponent;
    BufferedStream:TpvSimpleBufferedStream;
 procedure WriteBit(const aValue:boolean);
 var OldPosition:TpvInt64;
 begin
  if BitCounter>=8 then begin
   if BitPosition>=0 then begin
    OldPosition:=BufferedStream.Position;
    if BufferedStream.Seek(BitPosition,soBeginning)<>BitPosition then begin
     raise EInOutError.Create('Stream seek error');
    end;
    if BufferedStream.Write(BitTag,SizeOf(TpvUInt8))<>SizeOf(TpvUInt8) then begin
     raise EInOutError.Create('Stream write error');
    end;
    if BufferedStream.Seek(OldPosition,soBeginning)<>OldPosition then begin
     raise EInOutError.Create('Stream seek error');
    end;
   end;
   BitTag:=0;
   BitCounter:=0;
   BitPosition:=BufferedStream.Position;
   if BufferedStream.Write(BitTag,SizeOf(TpvUInt8))<>SizeOf(TpvUInt8) then begin
    raise EInOutError.Create('Stream write error');
   end;
  end;
  if aValue then begin
   BitTag:=BitTag or (TpvUInt8(1) shl BitCounter);
  end else begin
   BitTag:=BitTag and not (TpvUInt8(1) shl BitCounter);
  end;
  inc(BitCounter);
 end;
 procedure FlushBits;
 var OldPosition:TpvInt64;
 begin
  if BitPosition>=0 then begin
   OldPosition:=BufferedStream.Position;
   if BufferedStream.Seek(BitPosition,soBeginning)<>BitPosition then begin
    raise EInOutError.Create('Stream seek error');
   end;
   if BufferedStream.Write(BitTag,SizeOf(TpvUInt8))<>SizeOf(TpvUInt8) then begin
    raise EInOutError.Create('Stream write error');
   end;
   if BufferedStream.Seek(OldPosition,soBeginning)<>OldPosition then begin
    raise EInOutError.Create('Stream seek error');
   end;
  end;
 end;
 procedure WriteInt32(const aValue:TpvInt32);
 begin
  if BufferedStream.Write(aValue,SizeOf(TpvInt32))<>SizeOf(TpvInt32) then begin
   raise EInOutError.Create('Stream write error');
  end;
 end;
var WorldUUID:TpvUUID;
begin
 Refresh;
 BufferedStream:=TpvSimpleBufferedStream.Create(aStream,false,65536);
 try
  BitTag:=0;
  BitCounter:=8;
  BitPosition:=-1;
  if assigned(MetaResource) then begin
   WorldUUID:=MetaResource.UUID;
  end else begin
   WorldUUID:=TpvUUID.Null;
  end;
  if BufferedStream.Write(WorldUUID,SizeOf(TpvUUID))<>SizeOf(TpvUUID) then begin
   raise EInOutError.Create('Stream write error');
  end;
  WriteInt32(fEntityIDCounter);
  for EntityID:=0 to fEntityIDCounter-1 do begin
   if HasEntity(EntityID) then begin
    WriteBit(true);
    Entity:=EntityByID[EntityID];
    WriteBit(Entity.Active);
    BufferedStream.Write(Entity.fUUID,SizeOf(TpvUUID));
    WriteInt32(length(Entity.fComponents));
    for ComponentClassID:=0 to length(Entity.fComponents)-1 do begin
     Component:=Entity.fComponents[ComponentClassID];
     if assigned(Component) then begin
      WriteBit(true);
      Component.MementoSerialize(BufferedStream);
     end else begin
      WriteBit(false);
     end;
    end;
   end else begin
    WriteBit(false);
   end;
  end;
  FlushBits;
 finally
  BufferedStream.Free;
 end;
end;

procedure TpvWorld.MementoUnserialize(const aStream:TStream);
var ComponentClassID,LocalEntityCounter,ComponentClassCount,BitCounter:TpvInt32;
    BitTag:TpvUInt8;
    EntityID:TpvEntityID;
    Entity:TpvEntity;
    Component:TpvComponent;
    ComponentClass:TpvComponentClass;
    BufferedStream:TpvSimpleBufferedStream;
    TempUUID:TpvUUID;
    HasNewEntity,IsActive,HasNewComponent:boolean;
 function ReadBit:boolean;
 begin
  if BitCounter>=8 then begin
   BitTag:=0;
   BitCounter:=0;
   if BufferedStream.Read(BitTag,SizeOf(TpvUInt8))<>SizeOf(TpvUInt8) then begin
    raise EInOutError.Create('Stream write error');
   end;
  end;
  result:=(BitTag and (TpvUInt8(1) shl BitCounter))<>0;
  inc(BitCounter);
 end;
 function ReadInt32:TpvInt32;
 begin
  if BufferedStream.Read(result,SizeOf(TpvInt32))<>SizeOf(TpvInt32) then begin
   raise EInOutError.Create('Stream read error');
  end;
 end;
begin
 Refresh;
 aStream.Seek(0,soBeginning);
 BufferedStream:=TpvSimpleBufferedStream.Create(aStream,false,65536);
 try
  BitTag:=0;
  BitCounter:=8;
  if BufferedStream.Read(TempUUID,SizeOf(TpvUUID))<>SizeOf(TpvUUID) then begin
   raise EInOutError.Create('Stream read error');
  end;
  LocalEntityCounter:=ReadInt32;
  for EntityID:=0 to Max(LocalEntityCounter,fEntityIDCounter)-1 do begin
   if EntityID<LocalEntityCounter then begin
    HasNewEntity:=ReadBit;
   end else begin
    HasNewEntity:=false;
   end;
   if HasNewEntity then begin
    IsActive:=ReadBit;
    if BufferedStream.Read(TempUUID,SizeOf(TpvUUID))<>SizeOf(TpvUUID) then begin
     raise EInOutError.Create('Stream read error');
    end;
    if HasEntity(EntityID) then begin
     Entity:=EntityByID[EntityID];
     if TempUUID<>Entity.fUUID then begin
      fEntityUUIDHashMap.Delete(Entity.fUUID);
      Entity.fUUID:=TempUUID;
      fEntityUUIDHashMap.Add(Entity.fUUID,EntityID);
     end;
    end else begin
     CreateEntity(EntityID,TempUUID);
     Refresh;
     Entity:=EntityByID[EntityID];
    end;
    ComponentClassCount:=ReadInt32;
    for ComponentClassID:=0 to Max(ComponentClassCount,length(Entity.fComponents))-1 do begin
     if ComponentClassID<ComponentClassCount then begin
      HasNewComponent:=ReadBit;
     end else begin
      HasNewComponent:=false;
     end;
     if HasNewComponent then begin
      if ComponentClassID<length(Entity.fComponents) then begin
       Component:=Entity.fComponents[ComponentClassID];
      end else begin
       Component:=nil;
      end;
      if not assigned(Component) then begin
       ComponentClass:=TpvComponentClass(fUniverse.fRegisteredComponentClasses[ComponentClassID]);
       Component:=ComponentClass.Create;
       Entity.AddComponent(Component);
      end;
      Component.MementoUnserialize(BufferedStream);
     end else if ComponentClassID<length(Entity.fComponents) then begin
      Component:=Entity.fComponents[ComponentClassID];
      if assigned(Component) then begin
       Entity.RemoveComponentFromEntity(Component);
      end;
     end;
    end;
    if IsActive then begin
     ActivateEntity(EntityID);
    end;
   end else if HasEntity(EntityID) then begin
    KillEntity(EntityID);
   end;
  end;
  Refresh;
 finally
  BufferedStream.Free;
 end;
 inc(fGeneration);
end;

function TpvWorld.SerializeToJSON(const aEntityIDs:array of TpvEntityID;const aRootEntityID:TpvEntityID=-1):TPasJSONItem;
 function SerializeObjectToJSON(const AObject:TObject):TPasJSONItem;
 var PropCount,Index,SubIndex:TpvInt32;
     PropList:PPropList;
     PropInfo:PPropInfo;
     EntityID:TpvEntityID;
     EntityIDs:TpvComponentDataEntityIDs;
     Entity:TpvEntity;
     PrefabInstanceEntityComponentPropertyList:TpvComponentPrefabInstanceEntityComponentPropertyList;
     PrefabInstanceEntityComponentProperty:TpvComponentPrefabInstanceEntityComponentProperty;
     ItemObject,ItemArrayObject:TPasJSONItemObject;
     ItemArray:TPasJSONItemArray;
     ItemValue:TPasJSONItem;
 begin
  if assigned(AObject) then begin
   ItemObject:=TPasJSONItemObject.Create;
   result:=ItemObject;
   PropList:=nil;
   try
    PropCount:=TypInfo.GetPropList(AObject,PropList);
    if PropCount>0 then begin
     for Index:=0 to PropCount-1 do begin
      PropInfo:=PropList^[Index];
      if assigned(PropInfo^.PropType) then begin
       ItemValue:=nil;
       if PropInfo^.PropType=TypeInfo(TpvEntityID) then begin
        EntityID:=TypInfo.GetInt64Prop(AObject,PropInfo);
        if HasEntity(EntityID) then begin
         Entity:=EntityByID[EntityID];
         if assigned(Entity) then begin
          ItemValue:=TPasJSONItemString.Create(TPasJSONUTF8String(Entity.UUID.ToString));
         end else begin
          ItemValue:=TPasJSONItemNull.Create;
         end;
        end else begin
         ItemValue:=TPasJSONItemNull.Create;
        end;
       end else if PropInfo^.PropType=TypeInfo(TpvComponentDataEntityIDs) then begin
        ItemArray:=TPasJSONItemArray.Create;
        ItemValue:=ItemArray;
        EntityIDs:=TpvComponentDataEntityIDs(TypInfo.GetObjectProp(AObject,PropInfo));
        if assigned(EntityIDs) then begin
         for SubIndex:=0 to EntityIDs.Count-1 do begin
          EntityID:=EntityIDs.Items[SubIndex];
          if HasEntity(EntityID) then begin
           Entity:=EntityByID[EntityID];
           if assigned(Entity) then begin
            ItemArray.Add(TPasJSONItemString.Create(TPasJSONUTF8String(Entity.UUID.ToString)));
           end else begin
            ItemArray.Add(TPasJSONItemNull.Create);
           end;
          end else begin
           ItemArray.Add(TPasJSONItemNull.Create);
          end;
         end;
        end;
       end else if PropInfo^.PropType=TypeInfo(TpvComponentPrefabInstanceEntityComponentPropertyList) then begin
        ItemArray:=TPasJSONItemArray.Create;
        ItemValue:=ItemArray;
        PrefabInstanceEntityComponentPropertyList:=TpvComponentPrefabInstanceEntityComponentPropertyList(TypInfo.GetObjectProp(AObject,PropInfo));
        if assigned(PrefabInstanceEntityComponentPropertyList) then begin
         for SubIndex:=0 to PrefabInstanceEntityComponentPropertyList.Count-1 do begin
          PrefabInstanceEntityComponentProperty:=PrefabInstanceEntityComponentPropertyList.Items[SubIndex];
          if assigned(PrefabInstanceEntityComponentProperty) and
             assigned(PrefabInstanceEntityComponentProperty.ComponentClass) and
             assigned(PrefabInstanceEntityComponentProperty.PropInfo) then begin
           ItemArrayObject:=TPasJSONItemObject.Create;
           ItemArray.Add(ItemArrayObject);
           ItemArrayObject.Add('component',TPasJSONItemString.Create(PrefabInstanceEntityComponentProperty.ComponentClass.ClassUUID.ToString));
           ItemArrayObject.Add('property',TPasJSONItemString.Create(PrefabInstanceEntityComponentProperty.PropInfo^.Name));
           ItemArrayObject.Add('overwritten',TPasJSONItemBoolean.Create(TpvComponentPrefabInstanceEntityComponentProperty.TpvComponentPrefabInstanceEntityComponentPropertyFlag.cpiecpfOverwritten in PrefabInstanceEntityComponentProperty.Flags));
          end;
         end;
        end;
       end else begin
        case PropInfo^.PropType^.Kind of
         tkUnknown:begin
          ItemValue:=TPasJSONItemNull.Create;
         end;
         tkInteger:begin
          ItemValue:=TPasJSONItemNumber.Create(TypInfo.GetOrdProp(AObject,PropInfo));
         end;
         tkChar,tkWChar{$ifdef fpc},tkUChar{$endif}:begin
          ItemValue:=TPasJSONItemString.Create(TPasJSONUTF8String({$ifdef fpc}UnicodeChar{$else}WideChar{$endif}(word(TypInfo.GetOrdProp(AObject,PropInfo)))));
         end;
         tkEnumeration:begin
          ItemValue:=TPasJSONItemString.Create(TPasJSONUTF8String(TypInfo.GetEnumProp(AObject,PropInfo)));
         end;
         tkFloat:begin
          ItemValue:=TPasJSONItemNumber.Create(TypInfo.GetFloatProp(AObject,PropInfo));
         end;
         tkSet:begin
          ItemValue:=TPasJSONItemString.Create(TPasJSONUTF8String(TypInfo.GetSetProp(AObject,PropInfo,false)));
         end;
         {$ifdef fpc}tkSString,{$endif}tkLString,{$ifdef fpc}tkAString,{$endif}tkWString,tkUString:begin
          ItemValue:=TPasJSONItemString.Create(TPasJSONUTF8String(TypInfo.GetUnicodeStrProp(AObject,PropInfo)));
         end;
         tkClass:begin
          ItemValue:=SerializeObjectToJSON(TypInfo.GetObjectProp(AObject,PropInfo));
         end;
{$ifdef fpc}
         tkBool:begin
          ItemValue:=TPasJSONItemBoolean.Create(TypInfo.GetOrdProp(AObject,PropInfo)<>0);
         end;
{$endif}
         tkInt64{$ifdef fpc},tkQWord{$endif}:begin
          ItemValue:=TPasJSONItemString.Create(TPasJSONUTF8String(IntToStr(TypInfo.GetInt64Prop(AObject,PropInfo))));
         end;
         else begin
          ItemValue:=TPasJSONItemNull.Create;
         end;
        end;
       end;
       if not assigned(ItemValue) then begin
        ItemValue:=TPasJSONItemNull.Create;
       end;
       ItemObject.Add(TPasJSONUTF8String(PropInfo^.Name),ItemValue);
      end;
     end;
    end;
   finally
    if assigned(PropList) then begin
     FreeMem(PropList);
    end;
   end;
  end else begin
   result:=TPasJSONItemNull.Create;
  end;
 end;
 procedure SerializeEntityToJSON(const RootObjectItem:TPasJSONItemObject;const Entity:TpvEntity);
 type PByteArray=^TByteArray;
      TByteArray=array[0..$3fffffff] of byte;
 var ComponentClassIndex:TpvInt32;
     EntityID:TpvEntityID;
     EntityObjectItem:TPasJSONItemObject;
     ComponentClass:TpvComponentClass;
     Component:TpvComponent;
 begin
  EntityID:=Entity.ID;
  EntityObjectItem:=TPasJSONItemObject.Create;
  RootObjectItem.Add(TPasJSONUTF8String(Entity.UUID.ToString),EntityObjectItem);
  for ComponentClassIndex:=0 to fUniverse.fRegisteredComponentClasses.Count-1 do begin
   ComponentClass:=TpvComponentClass(fUniverse.fRegisteredComponentClasses.Items[ComponentClassIndex]);
   if HasEntityComponent(EntityID,ComponentClass) then begin
    Component:=Entity.ComponentByClass[ComponentClass];
    if assigned(Component) then begin
     if ComponentClass.HasSpecialJSONSerialization then begin
      EntityObjectItem.Add(TPasJSONUTF8String(ComponentClass.ClassUUID.ToString),Component.SpecialJSONSerialization);
     end else begin
      EntityObjectItem.Add(TPasJSONUTF8String(ComponentClass.ClassUUID.ToString),SerializeObjectToJSON(Component));
     end;
    end;
   end;
  end;
  if assigned(Entity.fUnknownData) then begin
   EntityObjectItem.Merge(Entity.fUnknownData);
  end;
 end;
var RootObjectItem:TPasJSONItemObject;
    EntityIndex:TpvInt32;
    Entity:TpvEntity;
    EntityID:TpvEntityID;
begin
 RootObjectItem:=TPasJSONItemObject.Create;
 result:=RootObjectItem;
 if (aRootEntityID>=0) and HasEntity(aRootEntityID) then begin
  Entity:=EntityByID[aRootEntityID];
  if assigned(Entity) then begin
   RootObjectItem.Add('root',TPasJSONItemString.Create(TPasJSONUTF8String(Entity.UUID.ToString)));
  end;
 end;
 RootObjectItem.Add('uuid',TPasJSONItemString.Create(TPasJSONUTF8String(GetUUID.ToString)));
 if length(aEntityIDs)>0 then begin
  for EntityIndex:=0 to length(aEntityIDs)-1 do begin
   EntityID:=aEntityIDs[EntityIndex];
   if HasEntity(EntityID) then begin
    Entity:=EntityByID[EntityID];
    if assigned(Entity) then begin
     SerializeEntityToJSON(RootObjectItem,Entity);
    end;
   end;
  end;
 end else begin
  for EntityID:=0 to fEntityIDMax do begin
   if HasEntity(EntityID) then begin
    Entity:=EntityByID[EntityID];
    if assigned(Entity) then begin
     SerializeEntityToJSON(RootObjectItem,Entity);
    end;
   end;
  end;
 end;
end;

function TpvWorld.UnserializeFromJSON(const aJSONRootItem:TPasJSONItem;const aCreateNewUUIDs:boolean=false):TpvEntityID;
type TUUIDIntegerPairHashMap=TpvHashMap<TpvUUID,TpvInt32>;
     TParentObjectNames=TpvGenericList<TPasJSONUTF8String>;
var RootUUID:TpvUUIDString;
    WorldUUID,EntityUUID,ComponentUUID:TpvUUID;
    Entity:TpvEntity;
    RootObjectItem,EntityObjectItem:TPasJSONItemObject;
    RootObjectItemIndex,EntityObjectItemIndex:TpvInt32;
    RootObjectItemKey,EntityObjectItemKey:TPasJSONUTF8String;
    RootObjectItemValue,EntityObjectItemValue,TempItem:TPasJSONItem;
    EntityID:TpvEntityID;
    Component:TpvComponent;
    ComponentClass:TpvComponentClass;
    EntityUUIDHashMap:TUUIDIntegerPairHashMap;
    EntityIDs:array of TpvInt32;
    ParentObjectNames:TParentObjectNames;
    WorldName:TpvUTF8String;
 procedure UnserializeObjectFromJSON(const AObject:TObject;const SourceItem:TPasJSONItem);
 var SourceItemObject,SubObject,TempObjectItem,TempObject:TPasJSONItemObject;
     PropCount,Index,SubIndex:TpvInt32;
     PropList:PPropList;
     PropInfo:PPropInfo;
     ItemKey:AnsiString;
     ItemValue,TempItem:TPasJSONItem;
     OK:TPasDblStrUtilsBoolean;
     NewObject:TObject;
     DataUUID:TpvUUID;
     DataEntityID:TpvEntityID;
     DataEntityIDs:TpvComponentDataEntityIDs;
     DataEntity:TpvEntity;
     PrefabInstanceEntityComponentPropertyList:TpvComponentPrefabInstanceEntityComponentPropertyList;
     PrefabInstanceEntityComponentProperty:TpvComponentPrefabInstanceEntityComponentProperty;
 begin
  if assigned(AObject) and assigned(SourceItem) and (SourceItem is TPasJSONItemObject) then begin
   SourceItemObject:=TPasJSONItemObject(SourceItem);
   PropList:=nil;
   try
    PropCount:=TypInfo.GetPropList(AObject,PropList);
    for Index:=0 to SourceItemObject.Count-1 do begin
     ItemValue:=SourceItemObject.Values[Index];
     if assigned(ItemValue) then begin
      OK:=false;
      PropInfo:=nil;
      ItemKey:=AnsiString(LowerCase(SourceItemObject.Keys[Index]));
      for SubIndex:=0 to PropCount-1 do begin
       if LowerCase(PropList^[SubIndex].Name)=ItemKey then begin
        PropInfo:=PropList^[SubIndex];
        break;
       end;
      end;
      if assigned(PropInfo) then begin
       if PropInfo^.PropType=TypeInfo(TpvEntityID) then begin
        if ItemValue is TPasJSONItemString then begin
         DataUUID:=TpvUUID.CreateFromString(TpvUUIDString(TPasJSONItemString(ItemValue).Value));
         DataEntityID:=EntityUUIDHashMap.Values[DataUUID];
         if DataEntityID<0 then begin
          DataEntity:=EntityByUUID[DataUUID];
          if assigned(DataEntity) then begin
           DataEntityID:=DataEntity.ID;
          end;
         end;
         if DataEntityID>=0 then begin
          TypInfo.SetOrdProp(AObject,PropInfo,DataEntityID);
         end else begin
          TypInfo.SetOrdProp(AObject,PropInfo,-1);
         end;
         OK:=true;
        end;
       end else if PropInfo^.PropType=TypeInfo(TpvComponentDataEntityIDs) then begin
        if ItemValue is TPasJSONItemArray then begin
         DataEntityIDs:=TpvComponentDataEntityIDs(TypInfo.GetObjectProp(AObject,PropInfo));
         if assigned(DataEntityIDs) then begin
          for SubIndex:=0 to TPasJSONItemArray(ItemValue).Count-1 do begin
           TempItem:=TPasJSONItemArray(ItemValue).Items[SubIndex];
           if assigned(TempItem) and (TempItem is TPasJSONItemString) then begin
            DataUUID:=TpvUUID.CreateFromString(TpvUUIDString(TPasJSONItemString(TempItem).Value));
            DataEntityID:=EntityUUIDHashMap.Values[DataUUID];
            if DataEntityID<0 then begin
             DataEntity:=EntityByUUID[DataUUID];
             if assigned(DataEntity) then begin
              DataEntityID:=DataEntity.ID;
             end;
            end;
            if DataEntityID>=0 then begin
             DataEntityIDs.Add(DataEntityID);
            end;
           end;
          end;
          OK:=true;
         end;
        end;
       end else if PropInfo^.PropType=TypeInfo(TpvComponentPrefabInstanceEntityComponentPropertyList) then begin
        if ItemValue is TPasJSONItemArray then begin
         PrefabInstanceEntityComponentPropertyList:=TpvComponentPrefabInstanceEntityComponentPropertyList(TypInfo.GetObjectProp(AObject,PropInfo));
         if assigned(PrefabInstanceEntityComponentPropertyList) then begin
          PrefabInstanceEntityComponentPropertyList.Clear;
         end else begin
          PrefabInstanceEntityComponentPropertyList:=TpvComponentPrefabInstanceEntityComponentPropertyList.Create;
          TypInfo.SetObjectProp(AObject,PropInfo,PrefabInstanceEntityComponentPropertyList);
         end;
         for SubIndex:=0 to TPasJSONItemArray(ItemValue).Count-1 do begin
          TempItem:=TPasJSONItemArray(ItemValue).Items[SubIndex];
          if assigned(TempItem) and (TempItem is TPasJSONItemObject) then begin
           TempObject:=TPasJSONItemObject(TempItem);
           PrefabInstanceEntityComponentProperty:=TpvComponentPrefabInstanceEntityComponentProperty.Create;
           try
            PrefabInstanceEntityComponentProperty.Flags:=[];
            if TPasJSON.GetBoolean(TempObject.Properties['overwritten'],false) then begin
             PrefabInstanceEntityComponentProperty.Flags:=PrefabInstanceEntityComponentProperty.Flags+[TpvComponentPrefabInstanceEntityComponentProperty.TpvComponentPrefabInstanceEntityComponentPropertyFlag.cpiecpfOverwritten];
            end;
            PrefabInstanceEntityComponentProperty.ComponentClass:=TpvComponentClass(fUniverse.fRegisteredComponentClasses.ComponentByUUID[TpvUUID.CreateFromString(TpvUUIDString(TPasJSON.GetString(TempObject.Properties['overwritten'],'')))]);
            if assigned(PrefabInstanceEntityComponentProperty.ComponentClass) then begin
             PrefabInstanceEntityComponentProperty.PropInfo:=GetPropInfo(PrefabInstanceEntityComponentProperty.ComponentClass,TPAsJSON.GetString(TempObject.Properties['property'],''));
             if assigned(PrefabInstanceEntityComponentProperty.PropInfo) then begin
              PrefabInstanceEntityComponentPropertyList.Add(PrefabInstanceEntityComponentProperty);
             end else begin
              FreeAndNil(PrefabInstanceEntityComponentProperty);
             end;
            end else begin
             FreeAndNil(PrefabInstanceEntityComponentProperty);
            end;
           except
            PrefabInstanceEntityComponentProperty.Free;
            raise;
           end;
          end;
         end;
         OK:=true;
        end;
       end else begin
        case PropInfo^.PropType^.Kind of
         tkUnknown:begin
         end;
         tkInteger:begin
          if ItemValue is TPasJSONItemBoolean then begin
           TypInfo.SetOrdProp(AObject,PropInfo,ord(TPasJSONItemBoolean(ItemValue).Value));
           OK:=true;
          end else if ItemValue is TPasJSONItemNumber then begin
           TypInfo.SetOrdProp(AObject,PropInfo,trunc(TPasJSONItemNumber(ItemValue).Value));
           OK:=true;
          end else if ItemValue is TPasJSONItemString then begin
           try
            TypInfo.SetOrdProp(AObject,PropInfo,StrToInt(String(TPasJSONItemString(ItemValue).Value)));
            OK:=true;
           except
           end;
          end;
         end;
         tkChar,tkWChar{$ifdef fpc},tkUChar{$endif}:begin
          ItemValue:=TPasJSONItemString.Create(TPasJSONUTF8String({$ifdef fpc}UnicodeChar{$else}WideChar{$endif}(word(TypInfo.GetOrdProp(AObject,PropInfo)))));
         end;
         tkEnumeration:begin
          if ItemValue is TPasJSONItemString then begin
           try
            TypInfo.SetEnumProp(AObject,PropInfo,String(TPasJSONItemString(ItemValue).Value));
            OK:=true;
           except
           end;
          end;
         end;
         tkFloat:begin
          if ItemValue is TPasJSONItemBoolean then begin
           TypInfo.SetFloatProp(AObject,PropInfo,ord(TPasJSONItemBoolean(ItemValue).Value));
           OK:=true;
          end else if ItemValue is TPasJSONItemNumber then begin
           TypInfo.SetFloatProp(AObject,PropInfo,TPasJSONItemNumber(ItemValue).Value);
           OK:=true;
          end else if ItemValue is TPasJSONItemString then begin
           TypInfo.SetFloatProp(AObject,PropInfo,ConvertStringToDouble(String(TPasJSONItemString(ItemValue).Value),rmNearest,@OK,-1));
          end;
         end;
         tkSet:begin
          if ItemValue is TPasJSONItemString then begin
           try
            TypInfo.SetSetProp(AObject,PropInfo,String(TPasJSONItemString(ItemValue).Value));
            OK:=true;
           except
           end;
          end;
         end;
         {$ifdef fpc}tkSString,{$endif}tkLString,{$ifdef fpc}tkAString,{$endif}tkWString,tkUString:begin
          if ItemValue is TPasJSONItemBoolean then begin
           TypInfo.SetUnicodeStrProp(AObject,PropInfo,UnicodeString(IntToStr(ord(TPasJSONItemBoolean(ItemValue).Value) and 1)));
           OK:=true;
          end else if ItemValue is TPasJSONItemNumber then begin
           TypInfo.SetUnicodeStrProp(AObject,PropInfo,UnicodeString(ConvertDoubleToString(TPasJSONItemNumber(ItemValue).Value,omStandard,0)));
           OK:=true;
          end else if ItemValue is TPasJSONItemString then begin
           TypInfo.SetUnicodeStrProp(AObject,PropInfo,UnicodeString(TPasJSONItemString(ItemValue).Value));
           OK:=true;
          end;
         end;
         tkClass:begin
          NewObject:=TypInfo.GetObjectProp(AObject,PropInfo);
          if assigned(NewObject) then begin
           UnserializeObjectFromJSON(NewObject,ItemValue);
           OK:=true;
          end;
         end;
{$ifdef fpc}
         tkBool:begin
          if ItemValue is TPasJSONItemBoolean then begin
           TypInfo.SetOrdProp(AObject,PropInfo,ord(TPasJSONItemBoolean(ItemValue).Value));
           OK:=true;
          end else if ItemValue is TPasJSONItemNumber then begin
           TypInfo.SetOrdProp(AObject,PropInfo,trunc(TPasJSONItemNumber(ItemValue).Value) and 1);
           OK:=true;
          end else if ItemValue is TPasJSONItemString then begin
           if TPasJSONItemString(ItemValue).Value='true' then begin
            TypInfo.SetOrdProp(AObject,PropInfo,1);
           end else if TPasJSONItemString(ItemValue).Value='false' then begin
            TypInfo.SetOrdProp(AObject,PropInfo,0);
           end else begin
            try
             TypInfo.SetOrdProp(AObject,PropInfo,StrToInt(String(TPasJSONItemString(ItemValue).Value)) and 1);
             OK:=true;
            except
            end;
           end;
          end;
         end;
{$endif}
         tkInt64{$ifdef fpc},tkQWord{$endif}:begin
          if ItemValue is TPasJSONItemBoolean then begin
           TypInfo.SetInt64Prop(AObject,PropInfo,ord(TPasJSONItemBoolean(ItemValue).Value));
           OK:=true;
          end else if ItemValue is TPasJSONItemNumber then begin
           TypInfo.SetInt64Prop(AObject,PropInfo,trunc(TPasJSONItemNumber(ItemValue).Value));
           OK:=true;
          end else if ItemValue is TPasJSONItemString then begin
           try
            TypInfo.SetInt64Prop(AObject,PropInfo,StrToInt(String(TPasJSONItemString(ItemValue).Value)));
            OK:=true;
           except
           end;
          end;
         end;
         else begin
         end;
        end;
       end;
      end;
      if not OK then begin
       if not assigned(Entity.fUnknownData) then begin
        Entity.fUnknownData:=TPasJSONItemObject.Create;
       end;
       SubObject:=Entity.fUnknownData;
       TempItem:=nil;
       for SubIndex:=0 to ParentObjectNames.Count-1 do begin
        TempItem:=SubObject[ParentObjectNames[SubIndex]];
        if not assigned(TempItem) then begin
         TempItem:=TPasJSONItem(TPasJSONItemObject.Create);
         SubObject.Add(ParentObjectNames[SubIndex],TempItem);
        end;
        if assigned(TempItem) and (TempItem is TPasJSONItemObject) then begin
         SubObject:=TPasJSONItemObject(TempItem);
        end else begin
         break;
        end;
       end;
       if assigned(TempItem) and (TempItem is TPasJSONItemObject) then begin
        TempObjectItem:=TPasJSONItemObject(TempItem);
        TempItem:=TempObjectItem.Properties[TPasJSONUTF8String(ItemKey)];
        if not assigned(TempItem) then begin
         TempItem:=TPasJSONItem(ItemValue.ClassType.Create);
         TempObjectItem.Add(TPasJSONUTF8String(ItemKey),TempItem);
        end;
        if assigned(TempItem) then begin
         TempItem.Merge(ItemValue);
        end else begin
         raise EpvSystemUnserialization.Create('Internal error 2016-06-04-05-17-0000');
        end;
       end;
      end;
     end;
    end;
   finally
    if assigned(PropList) then begin
     FreeMem(PropList);
    end;
   end;
  end;
 end;
var OK:boolean;
begin
 result:=-1;
 if assigned(aJSONRootItem) and (aJSONRootItem is TPasJSONItemObject) then begin
  EntityIDs:=nil;
  try
   ParentObjectNames:=TParentObjectNames.Create;
   try
    EntityUUIDHashMap:=TUUIDIntegerPairHashMap.Create(-1);
    try
     RootUUID:='';
     RootObjectItem:=TPasJSONItemObject(aJSONRootItem);
     SetLength(EntityIDs,RootObjectItem.Count);
     for RootObjectItemIndex:=0 to RootObjectItem.Count-1 do begin
      RootObjectItemKey:=RootObjectItem.Keys[RootObjectItemIndex];
      RootObjectItemValue:=RootObjectItem.Values[RootObjectItemIndex];
      if (length(RootObjectItemKey)>0) and assigned(RootObjectItemValue) then begin
       if RootObjectItemKey='root' then begin
        if RootObjectItemValue is TPasJSONItemString then begin
         RootUUID:=TpvUUIDString(TPasJSONItemString(RootObjectItemValue).Value);
        end;
       end else if RootObjectItemKey='uuid' then begin
        if RootObjectItemValue is TPasJSONItemString then begin
         WorldUUID:=TpvUUID.CreateFromString(TpvUUIDString(TPasJSONItemString(RootObjectItemValue).Value));
         if WorldUUID.UInt64s[0]<>0 then begin
         end;
        end;
       end else if RootObjectItemKey='name' then begin
        WorldName:=TpvUUIDString(TPasJSONItemString(RootObjectItemValue).Value);
        if length(WorldName)>0 then begin
        end;
       end else if {pFullLoad and}
                   (length(RootObjectItemKey)=38) and
                   (RootObjectItemKey[1]='{') and
                   (RootObjectItemKey[10]='-') and
                   (RootObjectItemKey[15]='-') and
                   (RootObjectItemKey[20]='-') and
                   (RootObjectItemKey[25]='-') and
                   (RootObjectItemKey[38]='}') then begin
        if RootObjectItemValue is TPasJSONItemObject then begin
         EntityUUID:=TpvUUID.CreateFromString(TpvUUIDString(RootObjectItemKey));
         if aCreateNewUUIDs then begin
          EntityID:=CreateEntity;
         end else begin
          EntityID:=CreateEntity(EntityUUID);
         end;
         if EntityID>=0 then begin
          Refresh;
          Entity:=EntityByID[EntityID];
          if assigned(Entity) then begin
           EntityIDs[RootObjectItemIndex]:=EntityID;
           EntityUUIDHashMap.Add(EntityUUID,EntityID);
          end else begin
           raise EpvSystemUnserialization.Create('Internal error 2016-01-19-20-30-0000');
          end;
         end else begin
          raise EpvSystemUnserialization.Create('Internal error 2016-01-19-20-30-0001');
         end;
        end;
       end;
      end;
     end;
     Refresh;
     {if pFullLoad then} begin
      for RootObjectItemIndex:=0 to RootObjectItem.Count-1 do begin
       RootObjectItemKey:=RootObjectItem.Keys[RootObjectItemIndex];
       RootObjectItemValue:=RootObjectItem.Values[RootObjectItemIndex];
       if (length(RootObjectItemKey)>0) and assigned(RootObjectItemValue) then begin
        if RootObjectItemKey='root' then begin
         if RootObjectItemValue is TPasJSONItemString then begin
          RootUUID:=TpvUUIDString(TPasJSONItemString(RootObjectItemValue).Value);
         end;
        end else if (length(RootObjectItemKey)=38) and
                    (RootObjectItemKey[1]='{') and
                    (RootObjectItemKey[10]='-') and
                    (RootObjectItemKey[15]='-') and
                    (RootObjectItemKey[20]='-') and
                    (RootObjectItemKey[25]='-') and
                    (RootObjectItemKey[38]='}') then begin
         if RootObjectItemValue is TPasJSONItemObject then begin
          EntityID:=EntityIDs[RootObjectItemIndex];
          if EntityID>=0 then begin
           Refresh;
           if HasEntity(EntityID) then begin
            EntityObjectItem:=TPasJSONItemObject(RootObjectItemValue);
            for EntityObjectItemIndex:=0 to EntityObjectItem.Count-1 do begin
             EntityObjectItemKey:=EntityObjectItem.Keys[EntityObjectItemIndex];
             EntityObjectItemValue:=EntityObjectItem.Values[EntityObjectItemIndex];
             if (length(EntityObjectItemKey)>0) and assigned(EntityObjectItemValue) and (EntityObjectItemValue is TPasJSONItemObject) then begin
              OK:=false;
              if (length(EntityObjectItemKey)=38) and
                 (EntityObjectItemKey[1]='{') and
                 (EntityObjectItemKey[10]='-') and
                 (EntityObjectItemKey[15]='-') and
                 (EntityObjectItemKey[20]='-') and
                 (EntityObjectItemKey[25]='-') and
                 (EntityObjectItemKey[38]='}') then begin
               ComponentUUID:=TpvUUID.CreateFromString(EntityObjectItemKey);
               if ComponentUUID<>TpvUUID.Null then begin
                ComponentClass:=TpvComponentClass(fUniverse.fRegisteredComponentClasses.ComponentByUUID[ComponentUUID]);
                if assigned(ComponentClass) then begin
                 Component:=ComponentClass.Create;
                 AddComponentToEntity(EntityID,Component);
                 Refresh;
                 if HasEntityComponent(EntityID,ComponentClass) then begin
                  Entity:=EntityByID[EntityID];
                  if assigned(Entity) then begin
                   ParentObjectNames.Add(EntityObjectItemKey);
                   if ComponentClass.HasSpecialJSONSerialization then begin
                    Component.SpecialJSONUnserialization(EntityObjectItemValue);
                   end else begin
                    UnserializeObjectFromJSON(Component,EntityObjectItemValue);
                   end;
                   ParentObjectNames.Delete(ParentObjectNames.Count-1);
                   OK:=true;
                  end;
                 end;
                end;
               end;
              end;
              if assigned(EntityObjectItemValue) and not OK then begin
               Entity:=EntityByID[EntityID];
               if assigned(Entity) then begin
                if not assigned(Entity.fUnknownData) then begin
                 Entity.fUnknownData:=TPasJSONItemObject.Create;
                end;
                TempItem:=Entity.fUnknownData[EntityObjectItemKey];
                if not assigned(TempItem) then begin
                 TempItem:=TPasJSONItem(EntityObjectItemValue.ClassType.Create);
                 Entity.fUnknownData.Add(EntityObjectItemKey,TempItem);
                end;
                TempItem.Merge(EntityObjectItemValue);
               end else begin
                raise EpvSystemUnserialization.Create('Internal error 2016-06-04-04-39-0000');
               end;
              end;
             end;
            end;
            Entity:=EntityByID[EntityID];
            if assigned(Entity) then begin
             Entity.Activate;
            end;
           end;
          end;
         end;
        end;
       end;
      end;
      Refresh;
      if length(RootUUID)>0 then begin
       Entity:=EntityByUUID[TpvUUID.CreateFromString(RootUUID)];
       if assigned(Entity) then begin
        result:=Entity.ID;
       end;
      end;
     end;
    finally
     EntityUUIDHashMap.Free;
    end;
   finally
    ParentObjectNames.Free;
   end;
  finally
   SetLength(EntityIDs,0);
  end;
 end;
 inc(fGeneration);
end;

function TpvWorld.GetUUID:TpvUUID;
begin
 if assigned(MetaResource) then begin
  result:=MetaResource.UUID;
 end else begin
  result:=TpvUUID.Null;
 end;
end;

function TpvWorld.LoadFromStream(const aStream:TStream;const aCreateNewUUIDs:boolean=false):TpvEntityID;
var s:TPasJSONRawByteString;
    l:Int64;
begin
 s:='';
 try
  l:=aStream.Size-aStream.Position;
  if l>0 then begin
   SetLength(s,l*SizeOf(AnsiChar));
   if aStream.Read(s[1],l*SizeOf(AnsiChar))<>(l*SizeOf(AnsiChar)) then begin
    raise EInOutError.Create('Stream read error');
   end;
   result:=UnserializeFromJSON(TPasJSON.Parse(s),aCreateNewUUIDs);
  end else begin
   result:=-1;
  end;
 finally
  s:='';
 end;
end;

procedure TpvWorld.SaveToStream(const aStream:TStream;const aEntityIDs:array of TpvEntityID;const aRootEntityID:TpvEntityID=-1);
var s:TPasJSONRawByteString;
    l:Int64;
begin
 s:=TPasJSON.Stringify(SerializeToJSON(aEntityIDs,aRootEntityID),true);
 l:=length(s);
 if l>0 then begin
  try
   if aStream.Write(s[1],l*SizeOf(AnsiChar))<>(l*SizeOf(AnsiChar)) then begin
    raise EInOutError.Create('Stream write error');
   end;
  finally
   s:='';
  end;
 end;
end;

function TpvWorld.LoadFromFile(const aFileName:TpvUTF8String;const aCreateNewUUIDs:boolean=false):TpvEntityID;
var FileStream:TFileStream;
begin
 FileStream:=TFileStream.Create(aFileName,fmOpenRead or fmShareDenyWrite);
 try
  result:=LoadFromStream(FileStream,aCreateNewUUIDs);
 finally
  FileStream.Free;
 end;
end;

procedure TpvWorld.SaveToFile(const aFileName:TpvUTF8String;const aEntityIDs:array of TpvEntityID;const aRootEntityID:TpvEntityID=-1);
var FileStream:TFileStream;
begin
 FileStream:=TFileStream.Create(aFileName,fmCreate);
 try
  SaveToStream(FileStream,aEntityIDs,aRootEntityID);
 finally
  FileStream.Free;
 end;
end;

function TpvWorld.Assign(const aFrom:TpvWorld;const aEntityIDs:array of TpvEntityID;const aRootEntityID:TpvEntityID=-1;const aAssignOp:TpvWorldAssignOp=TpvWorldAssignOp.Replace):TpvEntityID;
type TProcessBitmap=array of TpvUInt32;
var FromEntityID,EntityID,Index:TpvInt32;
    FromEntity,Entity:TpvEntity;
    NewEntityIDs:TpvEntityIDs;
    FromEntityProcessBitmap:TProcessBitmap;
    DoRefresh,Found:boolean;
begin

 result:=-1;

 FromEntityProcessBitmap:=nil;
 try

  if length(aEntityIDs)>0 then begin
   SetLength(FromEntityProcessBitmap,(aFrom.fEntityIDCounter+31) shr 5);
   FillChar(FromEntityProcessBitmap[0],length(FromEntityProcessBitmap)*SizeOf(TpvUInt32),#0);
   for Index:=0 to length(aEntityIDs)-1 do begin
    EntityID:=aEntityIDs[Index];
    if (EntityID>=0) and (EntityID<aFrom.fEntityIDCounter) then begin
     FromEntityProcessBitmap[EntityID shr 5]:=FromEntityProcessBitmap[EntityID shr 5] or (TpvUInt32(1) shl (EntityID and 31));
    end;
   end;
  end;

  if aAssignOp=TpvWorldAssignOp.Replace then begin
   DoRefresh:=false;
   for EntityID:=0 to fEntityIDCounter-1 do begin
    if HasEntity(EntityID) then begin
     Entity:=EntityByID[EntityID];
     if assigned(Entity) then begin
      FromEntity:=aFrom.EntityByUUID[Entity.UUID];
      if (not assigned(FromEntity)) or
         (assigned(FromEntity) and
          ((length(FromEntityProcessBitmap)>0) and
           (((FromEntity.ID>=0) and (FromEntity.ID<aFrom.fEntityIDCounter)) and
            ((FromEntityProcessBitmap[FromEntity.ID shr 5] and (TpvUInt32(1) shl (FromEntity.ID and 31)))=0)))) then begin
       Entity.Kill;
       DoRefresh:=true;
      end;
     end;
    end;
   end;
   if DoRefresh then begin
    Refresh;
   end;
  end;

  NewEntityIDs:=nil;
  try

   SetLength(NewEntityIDs,aFrom.fEntityIDCounter);

   DoRefresh:=false;
   for FromEntityID:=0 to aFrom.fEntityIDCounter-1 do begin
    if aFrom.HasEntity(FromEntityID) then begin
     FromEntity:=aFrom.EntityByID[FromEntityID];
     if assigned(FromEntity) and
        ((length(FromEntityProcessBitmap)=0) or
         (((FromEntity.ID>=0) and (FromEntity.ID<aFrom.fEntityIDCounter)) and
          ((FromEntityProcessBitmap[FromEntity.ID shr 5] and (TpvUInt32(1) shl (FromEntity.ID and 31)))<>0))) then begin
      if aAssignOp=TpvWorldAssignOp.Add then begin
       EntityID:=CreateEntity;
       DoRefresh:=true;
      end else begin
       Entity:=EntityByUUID[FromEntity.UUID];
       if assigned(Entity) then begin
        EntityID:=Entity.ID;
       end else begin
        EntityID:=CreateEntity(FromEntity.UUID);
        DoRefresh:=true;
       end;
      end;
      NewEntityIDs[FromEntityID]:=EntityID;
      if (aRootEntityID>=0) and (aRootEntityID=FromEntityID) then begin
       result:=EntityID;
      end;
     end else begin
      NewEntityIDs[FromEntityID]:=-1;
     end;
    end else begin
     NewEntityIDs[FromEntityID]:=-1;
    end;
   end;
   if DoRefresh then begin
    Refresh;
   end;

   FromEntityProcessBitmap:=nil;

   for FromEntityID:=0 to aFrom.fEntityIDCounter-1 do begin
    EntityID:=NewEntityIDs[FromEntityID];
    if EntityID>=0 then begin
     FromEntity:=aFrom.EntityByID[FromEntityID];
     Entity:=EntityByID[EntityID];
     if aAssignOp in [TpvWorldAssignOp.Replace,TpvWorldAssignOp.Add] then begin
      Entity.Assign(FromEntity,TpvEntityAssignOp.Replace,NewEntityIDs,false);
     end else begin
      Entity.Assign(FromEntity,TpvEntityAssignOp.Combine,NewEntityIDs,false);
     end;
    end;
   end;

  finally
   SetLength(NewEntityIDs,0);
  end;

  inc(fGeneration);
  Refresh;

 finally
  SetLength(FromEntityProcessBitmap,0);
 end;

end;

procedure TpvWorld.Store;
var System:TpvSystem;
begin
 for System in fSystemChoreography.fSortedSystemList do begin
  System.Store;
 end;
end;

procedure TpvWorld.Interpolate(const aAlpha:TpvDouble);
var System:TpvSystem;
begin
 for System in fSystemChoreography.fSortedSystemList do begin
  System.Interpolate(aAlpha);
 end;
end;

constructor TpvSortedWorldList.Create;
begin
 inherited Create;
end;

destructor TpvSortedWorldList.Destroy;
begin
 inherited Destroy;
end;

function TpvSortedWorldList.GetWorld(const aIndex:TpvInt32):TpvWorld;
begin
 if (aIndex>=0) and (aIndex<Count) then begin
  result:=pointer(inherited Items[aIndex]);
 end else begin
  result:=nil;
 end;
end;

procedure TpvSortedWorldList.SetWorld(const aIndex:TpvInt32;const AWorld:TpvWorld);
begin
 inherited Items[aIndex]:=pointer(AWorld);
end;

constructor TpvWorldList.Create;
begin
 inherited Create;
 fIDWorldHashMap:=TpvWorldListIDWorldHashMap.Create(nil);
 fUUIDWorldHashMap:=TpvWorldListUUIDWorldHashMap.Create(nil);
 fFileNameWorldHashMap:=TpvWorldListFileNameWorldHashMap.Create(nil);
end;

destructor TpvWorldList.Destroy;
begin
 fIDWorldHashMap.Free;
 fUUIDWorldHashMap.Free;
 fFileNameWorldHashMap.Free;
 inherited Destroy;
end;

function TpvWorldList.GetWorld(const aIndex:TpvInt32):TpvWorld;
begin
 if (aIndex>=0) and (aIndex<Count) then begin
  result:=pointer(inherited Items[aIndex]);
 end else begin
  result:=nil;
 end;
end;

procedure TpvWorldList.SetWorld(const aIndex:TpvInt32;const aWorld:TpvWorld);
begin
 inherited Items[aIndex]:=pointer(aWorld);
end;

function TpvWorldList.GetWorldByID(const aID:TpvWorldID):TpvWorld;
begin
 result:=fIDWorldHashMap.Values[aID];
end;

function TpvWorldList.GetWorldByUUID(const aUUID:TpvUUID):TpvWorld;
begin
 result:=fUUIDWorldHashMap.Values[aUUID];
end;

function TpvWorldList.GetWorldByFileName(const aFileName:TpvUTF8String):TpvWorld;
begin
 result:=fFileNameWorldHashMap.Values[{NormalizePathForHashing}(aFileName)];
end;

constructor TpvUniverse.Create;
begin
 inherited Create;
 fRegisteredComponentClasses:=TpvRegisteredComponentClassList.Create;
 fWorlds:=TpvWorldList.Create;
 fWorldIDManager:=TpvWorldIDManager.Create;
 RegisterBaseComponents(self);
end;

destructor TpvUniverse.Destroy;
var Index:TpvInt32;
begin
 for Index:=fWorlds.Count-1 downto 0 do begin
  fWorlds[Index].Free;
 end;
 fWorlds.Free;
 fWorldIDManager.Free;
 fRegisteredComponentClasses.Free;
 inherited Destroy;
end;

class procedure TpvUniverse.GlobalInitialize;
begin
 if assigned(pvApplication) and not assigned(pvApplication.Universe) then begin
  pvApplication.Universe:=TpvUniverse.Create;
 end;
end;

class procedure TpvUniverse.GlobalFinalize;
begin
 if assigned(pvApplication) and assigned(pvApplication.Universe) then begin
  try
   pvApplication.Universe.Free;
  finally
   pvApplication.Universe:=nil;
  end;
 end;
end;

procedure TpvUniverse.RegisterComponent(const aComponentClass:TpvComponentClass);
begin
 fRegisteredComponentClasses.Add(aComponentClass);
end;

procedure TpvUniverse.UnregisterComponent(const aComponentClass:TpvComponentClass);
begin
 fRegisteredComponentClasses.Remove(aComponentClass);
end;

procedure TpvUniverse.ScanWorlds;
var Index:TpvInt32;
    Application:TpvApplication;
    AssetManager:TpvApplicationAssets;
    FileNameList:TpvApplicationAssets.TFileNameList;
    FileName:TpvUTF8String;
    MetaWorld:TpvMetaWorld;
    Stream:TStream;
begin
 Application:=pvApplication;
 if assigned(Application) then begin
  for Index:=fWorlds.Count-1 downto 0 do begin
   fWorlds[Index].Free;
  end;
  AssetManager:=Application.Assets;
  if assigned(AssetManager) then begin
   FileNameList:=AssetManager.GetDirectoryFileList('worlds',false);
   if length(FileNameList)>0 then begin
    try
     for Index:=0 to length(FileNameList)-1 do begin
      FileName:=FileNameList[Index];
      if LowerCase(ExtractFileExt(FileName))='.world' then begin
       FileName:='worlds/'+FileName;
       if AssetManager.ExistAsset(FileName) then begin
        Stream:=AssetManager.GetAssetStream(FileName);
        if assigned(Stream) then begin
         try
          Stream.Seek(0,soBeginning);
          MetaWorld:=TpvMetaWorld.Create;
          MetaWorld.LoadFromStream(Stream);
          MetaWorld.FileName:=IncludeTrailingPathDelimiter(AssetManager.BasePath)+FileName;
          MetaWorld.AssetName:=ChangeFileExt(FileName,'');
         finally
          FreeAndNil(Stream);
         end;
        end;
       end;
      end;
     end;
    finally
     FileNameList:=nil;
    end;
   end;
  end;
 end;
end;

procedure TpvUniverse.Initialize;
begin
 ScanWorlds;
end;

procedure TpvUniverse.Finalize;
begin
end;

procedure AddAvailableComponent(const aComponentClass:TpvComponentClass);
begin
 if not assigned(AvailableComponents) then begin
  AvailableComponents:=TList.Create;
 end;
 AvailableComponents.Add(aComponentClass);
end;

initialization
 if not assigned(AvailableComponents) then begin
  AvailableComponents:=TList.Create;
 end;
finalization
 FreeAndNil(AvailableComponents);
end.

