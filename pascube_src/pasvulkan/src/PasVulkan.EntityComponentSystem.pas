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
{$m+}

interface

uses {$ifdef Windows}Windows,{$endif}SysUtils,Classes,Math,Variants,TypInfo,
     PasMP,
     PUCU,
     PasDblStrUtils,
     PasJSON,
     PasVulkan.Types,
     PasVulkan.Math,
     PasVulkan.Base64,
     PasVulkan.Collections,
     PasVulkan.DataStructures.LinkedList,
     PasVulkan.Value,
     PasVulkan.SUID;

type TpvEntityComponentSystem=class
      public
      
       type ESystemCircularDependency=class(Exception);

            ESystemSerialization=class(Exception);

            ESystemUnserialization=class(Exception);

            EDuplicateComponentInEntity=class(Exception);

            PComponentID=^TComponentID;
            TComponentID=type TpvSizeUInt;

            TComponentIDDynamicArray=array of TComponentID;

            TWorld=class;

            TSystem=class;

            TSystemList=class(TpvObjectGenericList<TSystem>)
            end;

            PEntityID=^TEntityID;
            TEntityID=type TpvUInt32;

            TEntityIDDynamicArray=array of TEntityID;

            TEntityIDList=class(TpvGenericList<TEntityID>)
            end;

            TEntityIDHelper=record helper for TEntityID
             private // first 24 bits then 8 bits, so that it is still sortable by entity index
              const IndexBits=24; // when all these bits set, then => -1
                    GenerationBits=8;
                    IndexBitsMinusOne=TpvUInt32(IndexBits-1);
                    IndexSignBitMask=TpvUInt32(1 shl IndexBitsMinusOne);
                    IndexMask=TpvUInt32((TpvUInt32(1) shl IndexBits)-1);
                    GenerationMask=TpvUInt32((TpvUInt32(1) shl GenerationBits)-1);
                    Invalid=TpvUInt32($ffffffff);
              function GetIndex:TpvInt32; inline;
              procedure SetIndex(const aIndex:TpvInt32); inline;
              function GetGeneration:TpvUInt8; inline;
              procedure SetGeneration(const aGeneration:TpvUInt8); inline;
             public
              property Index:TpvInt32 read GetIndex write SetIndex;
              property Generation:TpvUInt8 read GetGeneration write SetGeneration;
            end;

            PWorldID=^TWorldID;
            TWorldID=type TpvInt32;

            PEventID=^TEventID;
            TEventID=type TpvInt32;

            ERegisteredComponentType=class(Exception);

            TRegisteredComponentType=class
             public
              type TPath=array of TpvUTF8String;
                   TField=record
                    public
                     type TElementType=
                           (
                            EntityID,
                            Enumeration,
                            Flags,
                            Boolean,
                            SignedInteger,
                            UnsignedInteger,
                            FloatingPoint,
                            LengthPrefixedString,
                            ZeroTerminatedString,
                            Blob
                           );
                          PElementType=^TElementType;
                          TEnumerationOrFlag=record
                           Value:TpvUInt64;
                           Name:TpvUTF8String;
                           DisplayName:TpvUTF8String;
                           constructor Create(const aValue:TpvUInt64;
                                              const aName:TpvUTF8String;
                                              const aDisplayName:TpvUTF8String);
                          end;
                          TEnumerationsOrFlags=array of TEnumerationOrFlag;
                    public
                     Name:TpvUTF8String;
                     DisplayName:TpvUTF8String;
                     ElementType:TElementType;
                     ElementSize:TpvSizeInt;
                     ElementCount:TpvSizeInt;
                     Offset:TpvSizeInt;
                     Size:TpvSizeInt;
                     EnumerationsOrFlags:TEnumerationsOrFlags;
                   end;
                   PField=^TField;
                   TFields=array of TField;
             private
              fID:TComponentID;
              fName:TpvUTF8String;
              fDisplayName:TpvUTF8String;
              fPath:TPath;
              fSize:TpvSizeInt;
              fFields:TFields;
              fCountFields:TpvSizeInt;
              fDefault:TpvUInt8DynamicArray;
              fEditorWidget:TpvPointer;
             public
              constructor Create(const aName:TpvUTF8String;
                                 const aDisplayName:TpvUTF8String;
                                 const aPath:array of TpvUTF8String;
                                 const aSize:TpvSizeInt;
                                 const aDefault:TpvPointer); reintroduce;
              destructor Destroy; override;
              class function GetSetOrdValue(const Info:PTypeInfo;const SetParam):TpvUInt64; static;
              procedure Add(const aName:TpvUTF8String;
                            const aDisplayName:TpvUTF8String;
                            const aElementType:TField.TElementType;
                            const aElementSize:TpvSizeInt;
                            const aElementCount:TpvSizeInt;
                            const aOffset:TpvSizeInt;
                            const aSize:TpvSizeInt;
                            const aEnumerationsOrFlags:array of TField.TEnumerationOrFlag);
              procedure Finish;
              function SerializeToJSON(const aData:TpvPointer;const aWorld:TWorld):TPasJSONItemObject;
              procedure UnserializeFromJSON(const aJSON:TPasJSONItem;const aData:TpvPointer;const aWorld:TWorld);
              property Fields:TFields read fFields;
              property EditorWidget:TpvPointer read fEditorWidget write fEditorWidget;
              property Path:TPath read fPath;
             published
              property ID:TComponentID read fID;
              property Size:TpvSizeInt read fSize;
              property Default:TpvUInt8DynamicArray read fDefault;
            end;

            TRegisteredComponentTypeList=class(TpvObjectGenericList<TRegisteredComponentType>)
            end;

            TRegisteredComponentTypeNameHashMap=class(TpvStringHashMap<TRegisteredComponentType>)
            end;

            TComponentIDBitmap=array of TpvUInt32;

            TComponent=class
             public
              type TIndexMapArray=array of TpvSizeInt;
                   TUsedBitmap=array of TpvUInt32;
                   TPointers=array of TpvPointer;
             private
              fWorld:TWorld;
              fRegisteredComponentType:TRegisteredComponentType;
              fComponentPoolIndexToEntityIndex:TIndexMapArray;
              fEntityIndexToComponentPoolIndex:TIndexMapArray;
              fUsedBitmap:TUsedBitmap;
              fSize:TpvSizeInt;
              fPoolUnaligned:TpvPointer;
              fPool:TpvPointer;
              fPoolSize:TpvSizeInt;
              fCountPoolItems:TpvSizeInt;
              fCapacity:TpvSizeInt;
              fPoolIndexCounter:TpvSizeInt;
              fMaxEntityIndex:TpvSizeInt;
              fCountFrees:TpvSizeInt;
              fNeedToDefragment:boolean;
              fPointers:TPointers;
              fDataPointer:TpvPointer;
              procedure FinalizeComponentByPoolIndex(const aPoolIndex:TpvSizeInt);
              function GetEntityIndexByPoolIndex(const aPoolIndex:TpvSizeInt):TpvSizeInt;
              function GetComponentByPoolIndex(const aPoolIndex:TpvSizeInt):TpvPointer;
              function GetComponentByEntityIndex(const aEntityIndex:TpvSizeInt):TpvPointer;
              procedure SetMaxEntities(const aCount:TpvSizeInt);
             public
              constructor Create(const aWorld:TWorld;const aRegisteredComponentType:TRegisteredComponentType); reintroduce;
              destructor Destroy; override;
              procedure Defragment;
              procedure DefragmentIfNeeded;
              function IsComponentInEntityIndex(const aEntityIndex:TpvSizeInt):boolean;
              function GetComponentPoolIndexForEntityIndex(const aEntityIndex:TpvSizeInt):TpvSizeInt;
              function AllocateComponentForEntityIndex(const aEntityIndex:TpvSizeInt):boolean;
              function FreeComponentFromEntityIndex(const aEntityIndex:TpvSizeInt):boolean;
             public
              property Pool:TpvPointer read fPool;
              property PoolSize:TpvSizeInt read fPoolSize;
              property CountPoolItems:TpvSizeInt read fCountPoolItems;
              property EntityIndexByPoolIndex[const aPoolIndex:TpvSizeInt]:TpvSizeInt read GetEntityIndexByPoolIndex;
              property ComponentByPoolIndex[const aPoolIndex:TpvSizeInt]:pointer read GetComponentByPoolIndex;
              property ComponentByEntityIndex[const aEntityIndex:TpvSizeInt]:pointer read GetComponentByEntityIndex;
              property Pointers:TPointers read fPointers;
              property DataPointer:pointer read fDataPointer;
             published
              property RegisteredComponentType:TRegisteredComponentType read fRegisteredComponentType;
            end;

            TComponentList=TpvObjectGenericList<TpvEntityComponentSystem.TComponent>;

            TComponentIDList=class(TpvGenericList<TComponentID>)
            end;

            TEventParameter=TpvValue;
            PEventParameter=^TEventParameter;

            TEventParameters=array of TEventParameter;
            PEventParameters=^TEventParameters;

            TEvent=record
             LinkedListHead:TpvLinkedListHead;
             TimeStamp:TpvTime;
             RemainingTime:TpvTime;
             EventID:TEventID;
             EntityID:TEntityID;
             CountParameters:TpvInt32;
             Parameters:TEventParameters;
            end;
            PEvent=^TEvent;

            TEventHandler=procedure(const Event:TEvent) of object;

            TEventHandlers=array of TEventHandler;

            TEventRegistration=class
             private
              fEventID:TEventID;
              fName:TpvUTF8String;
              fActive:longbool;
              fLock:TPasMPMultipleReaderSingleWriterLock;
              fSystems:TSystemList;
              fEventHandlers:TEventHandlers;
              fCountEventHandlers:TpvInt32;
             public
              constructor Create(const aEventID:TEventID;const aName:TpvUTF8String);
              destructor Destroy; override;
              procedure Clear;
              procedure AddSystem(const aSystem:TSystem);
              procedure RemoveSystem(const aSystem:TSystem);
              procedure AddEventHandler(const aEventHandler:TEventHandler);
              procedure RemoveEventHandler(const aEventHandler:TEventHandler);
              property EventID:TEventID read fEventID;
              property Name:TpvUTF8String read fName;
              property Active:longbool read fActive;
              property Lock:TPasMPMultipleReaderSingleWriterLock read fLock;
              property SystemList:TSystemList read fSystems;
              property EventHandlers:TEventHandlers read fEventHandlers;
              property CountEventHandlers:TpvInt32 read fCountEventHandlers;
            end;

            TEventRegistrationList=class(TpvObjectGenericList<TEventRegistration>)
            end;

            TSystemEvents=array of PEvent;

            TEntityAssignOp=
             (
              Replace,
              Combine
             );

            { TEntity }

            TEntity=record
             public
              type TEntityFlag=
                    (
                     Used,
                     Active,
                     Killed
                    );
                   TFlag=TEntityFlag;
                   TFlags=set of TFlag;
             private
              fWorld:TWorld;
              fID:TEntityID;
              fSUID:TpvSUID;
              fFlags:TFlags;
              fCountComponents:TpvInt32;
              fComponentsBitmap:TComponentIDBitmap;
              fUnknownData:TObject;
              function GetActive:boolean; inline;
              procedure SetActive(const aActive:boolean); inline;
              procedure AddComponentToEntity(const aComponentID:TComponentID);
              procedure RemoveComponentFromEntity(const aComponentID:TComponentID);
             public
              procedure Assign(const aFrom:TEntity;const aAssignOp:TEntityAssignOp=TEntityAssignOp.Replace;const aEntityIDs:TEntityIDDynamicArray=nil;const aDoRefresh:boolean=true);
              procedure SynchronizeToPrefab;
              procedure Activate;
              procedure Deactivate;
              procedure Kill;
              function SerializeToJSON:TPasJSONItemObject;
              procedure UnserializeFromJSON(const aJSONRootItem:TPasJSONItem;const aCreateNewSUIDs:boolean=false);
              procedure AddComponent(const aComponentID:TComponentID;const aData:Pointer=nil;const aDataSize:TpvSizeInt=0);
              function AddComponentWithData(const aComponentID:TComponentID):Pointer;
              procedure RemoveComponent(const aComponentID:TComponentID);
              function HasComponent(const aComponentID:TComponentID):boolean;
              function GetComponent(const aComponentID:TComponentID):TpvEntityComponentSystem.TComponent;
             public
              property World:TWorld read fWorld write fWorld;
              property ID:TEntityID read fID write fID;
              property SUID:TpvSUID read fSUID write fSUID;
              property Flags:TFlags read fFlags write fFlags;
              property Active:boolean read GetActive write SetActive;
              property Components[const aComponentID:TComponentID]:TpvEntityComponentSystem.TComponent read GetComponent;
            end;

            PEntity=^TEntity;

            TEntities=array of TEntity;

            { TSystemChoreography }

            TSystemChoreography=class
             public
              type TSystemChoreographyStepSystems=array of TSystem;
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
              fWorld:TWorld;
              fPasMPInstance:TPasMP;
              fChoreographySteps:TSystemChoreographySteps;
              fChoreographyStepJobs:TSystemChoreographyStepJobs;
              fCountChoreographySteps:TpvInt32;
              fSortedSystemList:TSystemList;
              function CreateProcessEventsJob(const aSystem:TSystem;const aFirstEventIndex,aLastEventIndex:TPasMPSizeInt;const aParentJob:PPasMPJob):PPasMPJob;
              procedure ProcessEventsJobFunction(const aJob:PPasMPJob;const aThreadIndex:TpvInt32);
              procedure ChoreographyStepProcessEventsJobFunction(const aJob:PPasMPJob;const aThreadIndex:TpvInt32);
              procedure ChoreographyProcessEventsJobFunction(const aJob:PPasMPJob;const aThreadIndex:TpvInt32);
              function CreateUpdateEntitiesJob(const aSystem:TSystem;const aFirstEntityIndex,aLastEntityIndex:TPasMPSizeInt;const aParentJob:PPasMPJob):PPasMPJob;
              procedure UpdateEntitiesJobFunction(const aJob:PPasMPJob;const aThreadIndex:TpvInt32);
              procedure ChoreographyStepUpdateEntitiesJobFunction(const aJob:PPasMPJob;const aThreadIndex:TpvInt32);
              procedure ChoreographyUpdateEntitiesJobFunction(const aJob:PPasMPJob;const aThreadIndex:TpvInt32);
             public
              constructor Create(const aWorld:TWorld);
              destructor Destroy; override;
              procedure Build;
              procedure ProcessEvents;
              procedure InitializeUpdate;
              procedure Update;
              procedure FinalizeUpdate;
            end;

            { TSystem }

            TSystem=class
             public
              type TSystemFlag=
                    (
                     ParallelProcessing,
                     Secluded,
                     OwnUpdate
                    );
                   TFlag=TSystemFlag;
                   TFlags=set of TFlag;
             private
              fWorld:TWorld;
              fFlags:TFlags;
              fEntities:TEntityIDList;
              fRequiredComponents:TComponentIDList;
              fExcludedComponents:TComponentIDList;
              fRequiresSystems:TSystemList;
              fConflictsWithSystems:TSystemList;
              fNeedToSort:boolean;
              fEventsCanBeParallelProcessed:boolean;
              fEventGranularity:TpvInt32;
              fEntityGranularity:TpvInt32;
              fCountEntities:TpvInt32;
              fEvents:TSystemEvents;
              fCountEvents:TpvInt32;
              fDeltaTime:TpvTime;
             protected
              function HaveDependencyOnSystem(const aOtherSystem:TSystem):boolean;
              function HaveDependencyOnSystemOrViceVersa(const aOtherSystem:TSystem):boolean;
              function HaveCircularDependencyWithSystem(const aOtherSystem:TSystem):boolean;
              function HaveConflictWithSystem(const aOtherSystem:TSystem):boolean;
              function HaveConflictWithSystemOrViceVersa(const aOtherSystem:TSystem):boolean;
             public
              constructor Create(const aWorld:TWorld); virtual;
              destructor Destroy; override;
              procedure Added; virtual;
              procedure Removed; virtual;
              procedure SubscribeToEvent(const aEventID:TEventID);
              procedure UnsubscribeFromEvent(const aEventID:TEventID);
              procedure RequiresSystem(const aSystem:TSystem);
              procedure ConflictsWithSystem(const aSystem:TSystem);
              procedure AddRequiredComponent(const aComponentID:TComponentID);
              procedure AddExcludedComponent(const aComponentID:TComponentID);
              function FitsEntityToSystem(const aEntityID:TEntityID):boolean; virtual;
              function AddEntityToSystem(const aEntityID:TEntityID):boolean; virtual;
              function RemoveEntityFromSystem(const aEntityID:TEntityID):boolean; virtual;
              procedure SortEntities; virtual;
              procedure Finish; virtual;
              procedure ProcessEvent(const aEvent:TEvent); virtual;
              procedure ProcessEvents(const aFirstEventIndex,aLastEventIndex:TpvSizeInt); virtual;
              procedure InitializeUpdate; virtual;
              procedure Update; virtual;
              procedure UpdateEntities(const aFirstEntityIndex,aLastEntityIndex:TpvSizeInt); virtual;
              procedure FinalizeUpdate; virtual;
              procedure Store; virtual;
              procedure Interpolate(const aAlpha:TpvDouble); virtual;
              property World:TWorld read fWorld;
              property Flags:TFlags read fFlags write fFlags;
              property Entities:TEntityIDList read fEntities;
              property CountEntities:TpvInt32 read fCountEntities;
              property EventsCanBeParallelProcessed:boolean read fEventsCanBeParallelProcessed write fEventsCanBeParallelProcessed;
              property EventGranularity:TpvInt32 read fEventGranularity write fEventGranularity;
              property EntityGranularity:TpvInt32 read fEntityGranularity write fEntityGranularity;
              property Events:TSystemEvents read fEvents;
              property CountEvents:TpvInt32 read fCountEvents;
              property DeltaTime:TpvTime read fDeltaTime;
            end;

            TDelayedManagementEventType=(
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
            PDelayedManagementEventType=^TDelayedManagementEventType;

            TDelayedManagementEventData=array of TpvUInt8;

            TDelayedManagementEvent=record
             EventType:TDelayedManagementEventType;
             EntityID:TEntityID;
             ComponentID:TComponentID;
             System:TSystem;
             SUID:TpvSUID;
             Data:TDelayedManagementEventData;
             DataSize:TpvSizeInt;
             DataString:TpvRawByteString;
            end;
            PDelayedManagementEvent=^TDelayedManagementEvent;

            TDelayedManagementEvents=array of TDelayedManagementEvent;

            TDelayedManagementEventQueue=TpvDynamicQueue<TDelayedManagementEvent>;

            { TWorldEntityComponentSetQuery }

            TWorldEntityComponentSetQuery=class
             private
              fWorld:TWorld;
              fRequiredComponentBitmap:TpvEntityComponentSystem.TComponentIDBitmap;
              fExcludedComponentBitmap:TpvEntityComponentSystem.TComponentIDBitmap;
              fEntityIDs:TpvEntityComponentSystem.TEntityIDList;
              fGeneration:TpvUInt64;
             public
              constructor Create(const aWorld:TWorld;const aRequiredComponents:array of TpvEntityComponentSystem.TComponentID;const aExcludedComponents:array of TpvEntityComponentSystem.TComponentID); overload;
              constructor Create(const aWorld:TWorld;const aRequiredComponents:array of TpvEntityComponentSystem.TComponent;const aExcludedComponents:array of TpvEntityComponentSystem.TComponent); overload;
              destructor Destroy; override;
              procedure Update;
             public
              property EntityIDs:TEntityIDList read fEntityIDs;
            end;

            TWorldAssignOp=
             (
              Replace,
              Combine,
              Add
             );

            { TWorld }

            TWorld=class
             public
              type TEntityIndexFreeList=TpvGenericList<TpvSizeInt>;
                   TEntityGenerationList=array of TpvUInt8;
                   TUsedBitmap=array of TpvUInt32;
                   TOnEvent=procedure(const aWorld:TWorld;const aEvent:TEvent) of object;
                   TEventRegistrationStringIntegerPairHashMap=class(TpvStringHashMap<TpvSizeInt>);
                   TSUIDEntityIDPairHashMap=class(TpvHashMap<TpvSUID,TpvEntityComponentSystem.TEntityID>);
                   TSystemBooleanPairHashMap=class(TpvHashMap<TpvEntityComponentSystem.TSystem,longbool>);
             private
              fSUID:TpvSUID;
              fActive:TPasMPBool32;
              fKilled:TPasMPBool32;
              fPasMPInstance:TPasMP;
              fLock:TPasMPMultipleReaderSingleWriterLock;
              fGeneration:TpvUInt64;
              fComponents:TComponentList;
              fEntities:TEntities;
              fSystems:TSystemList;
              fSystemUsedMap:TSystemBooleanPairHashMap;
              fSystemChoreography:TSystemChoreography;
              fSystemChoreographyNeedToRebuild:TPasMPInt32;
              fEntityLock:TPasMPMultipleReaderSingleWriterLock;
              fEntityIndexFreeList:TEntityIndexFreeList;
              fEntityGenerationList:TEntityGenerationList;
              fEntityUsedBitmap:TUsedBitmap;
              fEntityIndexCounter:TpvSizeInt;
              fMaxEntityIndex:TpvSizeInt;
              fEntitySUIDHashMap:TSUIDEntityIDPairHashMap;
              fReservedEntityHashMapLock:TPasMPMultipleReaderSingleWriterLock;
              fReservedEntitySUIDHashMap:TSUIDEntityIDPairHashMap;
              fEventInProcessing:longbool;
              fEventRegistrationLock:TPasMPMultipleReaderSingleWriterLock;
              fEventRegistrationList:TEventRegistrationList;
              fFreeEventRegistrationList:TEventRegistrationList;
              fEventRegistrationStringIntegerPairHashMap:TEventRegistrationStringIntegerPairHashMap;
              fOnEvent:TOnEvent;
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
              fDelayedManagementEventLock:TPasMPMultipleReaderSingleWriterLock;
              fDelayedManagementEvents:TDelayedManagementEvents;
              fCountDelayedManagementEvents:TpvSizeInt;
              fDeltaTime:TpvDouble;
              procedure AddDelayedManagementEvent(const aDelayedManagementEvent:TDelayedManagementEvent);
              function GetEntityByID(const aEntityID:TEntityID):PEntity;
              function GetEntityBySUID(const aEntitySUID:TpvSUID):PEntity;
              function DoCreateEntity(const aEntityID:TEntityID;const aEntitySUID:TpvSUID):boolean;
              function DoDestroyEntity(const aEntityID:TEntityID):boolean;
              procedure ProcessEvent(const aEvent:PEvent);
              procedure ProcessEvents;
              procedure ProcessDelayedEvents(const aDeltaTime:TTime);
              function CreateEntity(const aEntityID:TEntityID;const aEntitySUID:TpvSUID):TEntityID; overload;
             public
              constructor Create(const aPasMPInstance:TPasMP=nil); reintroduce;
              destructor Destroy; override;
              procedure Kill;
              function CreateEvent(const aName:TpvUTF8String):TEventID;
              procedure DestroyEvent(const aEventID:TEventID);
              function FindEvent(const aName:TpvUTF8String):TEventID;
              procedure SubscribeToEvent(const aEventID:TEventID;const aEventHandler:TEventHandler);
              procedure UnsubscribeFromEvent(const aEventID:TEventID;const aEventHandler:TEventHandler);
              function CreateEntity(const aEntitySUID:TpvSUID):TEntityID; overload;
              function CreateEntity:TEntityID; overload;
              function HasEntity(const aEntityID:TEntityID):boolean;
              function HasEntityIndex(const aEntityIndex:TpvSizeInt):boolean;
              function IsEntityActive(const aEntityID:TEntityID):boolean;
              procedure ActivateEntity(const aEntityID:TEntityID);
              procedure DeactivateEntity(const aEntityID:TEntityID);
              procedure KillEntity(const aEntityID:TEntityID);
              procedure AddComponentToEntity(const aEntityID:TEntityID;const aComponentID:TComponentID;const aData:Pointer=nil;const aDataSize:TpvSizeInt=0);
              function AddComponentWithDataToEntity(const aEntityID:TEntityID;const aComponentID:TComponentID):Pointer;
              procedure RemoveComponentFromEntity(const aEntityID:TEntityID;const aComponentID:TComponentID);
              function HasEntityComponent(const aEntityID:TEntityID;const aComponentID:TComponentID):boolean;
              procedure AddSystem(const aSystem:TSystem);
              procedure RemoveSystem(const aSystem:TSystem);
              procedure SortSystem(const aSystem:TSystem);
              procedure Defragment;
              procedure Refresh;
              procedure QueueEvent(const aEventToQueue:TEvent;const aDeltaTime:TpvTime); overload;
              procedure QueueEvent(const aEventToQueue:TEvent); overload;
              procedure Update(const aDeltaTime:TpvTime);
              procedure Clear;
              procedure ClearEntities;
              procedure Activate;
              procedure Deactivate;
              procedure MementoSerialize(const aStream:TStream);
              procedure MementoUnserialize(const aStream:TStream);
              function SerializeToJSON(const aEntityIDs:array of TEntityID;const aRootEntityID:TEntityID=TpvUInt32($ffffffff)):TPasJSONItem;
              function UnserializeFromJSON(const aJSONRootItem:TPasJSONItem;const aCreateNewSUIDs:boolean=false):TEntityID;
              function LoadFromStream(const aStream:TStream;const aCreateNewSUIDs:boolean=false):TEntityID;
              procedure SaveToStream(const aStream:TStream;const aEntityIDs:array of TEntityID;const aRootEntityID:TEntityID=TpvUInt32($ffffffff));
              function LoadFromFile(const aFileName:TpvUTF8String;const aCreateNewSUIDs:boolean=false):TEntityID;
              procedure SaveToFile(const aFileName:TpvUTF8String;const aEntityIDs:array of TEntityID;const aRootEntityID:TEntityID=TpvUInt32($ffffffff));
              function Assign(const aFrom:TWorld;const aEntityIDs:array of TEntityID;const aRootEntityID:TEntityID=TpvUInt32($ffffffff);const aAssignOp:TWorldAssignOp=TWorldAssignOp.Replace):TEntityID;
              procedure Store;
              procedure Interpolate(const aAlpha:TpvDouble);
             public
              property SUID:TpvSUID read fSUID write fSUID;
              property Active:TPasMPBool32 read fActive write fActive;
              property Killed:TPasMPBool32 read fKilled write fKilled;
              property Components:TComponentList read fComponents;
              property CurrentTime:TpvTime read fCurrentTime;
              property OnEvent:TOnEvent read fOnEvent write fOnEvent;
              property DeltaTime:TpvDouble read fDeltaTime write fDeltaTime;
            end;

      public

       class var RegisteredComponentTypeList:TpvEntityComponentSystem.TRegisteredComponentTypeList;
       class var RegisteredComponentTypeNameHashMap:TpvEntityComponentSystem.TRegisteredComponentTypeNameHashMap;

     end;

     TpvECS=TpvEntityComponentSystem;

implementation

{ TpvEntityComponentSystem.TpvEntityIDHelper }

function TpvEntityComponentSystem.TEntityIDHelper.GetIndex:TpvInt32;
begin
 result:=(self shr GenerationBits) and IndexMask;
 result:=result or (-(ord(result=IndexMask) and 1));
end;

procedure TpvEntityComponentSystem.TEntityIDHelper.SetIndex(const aIndex:TpvInt32);
begin
 self:=(self and GenerationMask) or ((TpvUInt32(aIndex) and IndexMask) shl GenerationBits);
end;

function TpvEntityComponentSystem.TEntityIDHelper.GetGeneration:TpvUInt8;
begin
 result:=self and GenerationMask;
end;

procedure TpvEntityComponentSystem.TEntityIDHelper.SetGeneration(const aGeneration:TpvUInt8);
begin
 self:=(self and not GenerationMask) or (aGeneration and GenerationMask);
end;

{ TpvEntityComponentSystem.TpvRegisteredComponentType.TField.TEnumerationOrFlag }

constructor TpvEntityComponentSystem.TRegisteredComponentType.TField.TEnumerationOrFlag.Create(const aValue:TpvUInt64;
                                                                                               const aName:TpvUTF8String;
                                                                                               const aDisplayName:TpvUTF8String);
begin
 Value:=aValue;
 Name:=aName;
 DisplayName:=aDisplayName;
end;

{ TpvEntityComponentSystem.TRegisteredComponent }

constructor TpvEntityComponentSystem.TRegisteredComponentType.Create(const aName:TpvUTF8String;
                                                                     const aDisplayName:TpvUTF8String;
                                                                     const aPath:array of TpvUTF8String;
                                                                     const aSize:TpvSizeInt;
                                                                     const aDefault:TpvPointer);
var Index:TpvSizeInt;
begin
 inherited Create;
 fID:=RegisteredComponentTypeList.Add(self);
 RegisteredComponentTypeNameHashMap.Add(aName,self);
 fName:=aName;
 fDisplayName:=aDisplayName;
 SetLength(fPath,length(aPath));
 for Index:=0 to length(aPath)-1 do begin
  fPath[Index]:=aPath[Index];
 end;
 fSize:=aSize;
 fFields:=nil;
 fCountFields:=0;
 fEditorWidget:=nil;
 SetLength(fDefault,fSize);
 if assigned(aDefault) then begin
  Move(aDefault^,fDefault[0],fSize);
 end else begin
  FillChar(fDefault[0],fSize,#0);
 end;
end;

destructor TpvEntityComponentSystem.TRegisteredComponentType.Destroy;
begin
 fFields:=nil;
 fDefault:=nil;
 inherited Destroy;
end;

class function TpvEntityComponentSystem.TRegisteredComponentType.GetSetOrdValue(const Info:PTypeInfo;const SetParam):TpvUInt64;
begin
 result:=0;
 case GetTypeData(Info)^.OrdType of
  otSByte,otUByte:begin
   result:=TpvUInt8(SetParam);
  end;
  otSWord,otUWord:begin
   result:=TpvUInt16(SetParam);
  end;
  otSLong,otULong:begin
   result:=TpvUInt32(SetParam);
  end;
 end;
end;

procedure TpvEntityComponentSystem.TRegisteredComponentType.Add(const aName:TpvUTF8String;
                                                                const aDisplayName:TpvUTF8String;
                                                                const aElementType:TField.TElementType;
                                                                const aElementSize:TpvSizeInt;
                                                                const aElementCount:TpvSizeInt;
                                                                const aOffset:TpvSizeInt;
                                                                const aSize:TpvSizeInt;
                                                                const aEnumerationsOrFlags:array of TField.TEnumerationOrFlag);
var Index:TpvSizeInt;
    Field:TRegisteredComponentType.PField;
begin
 Index:=fCountFields;
 inc(fCountFields);
 if length(fFields)<fCountFields then begin
  SetLength(fFields,fCountFields+((fCountFields+1) shr 1));
 end;
 Field:=@fFields[Index];
 Field^.Name:=aName;
 Field^.DisplayName:=aDisplayName;
 Field^.ElementType:=aElementType;
 Field^.Offset:=aOffset;
 Field^.ElementSize:=aElementSize;
 Field^.ElementCount:=aElementCount;
 Field^.Size:=aSize;
 SetLength(Field^.EnumerationsOrFlags,length(aEnumerationsOrFlags));
 for Index:=0 to length(aEnumerationsOrFlags)-1 do begin
  Field^.EnumerationsOrFlags[Index]:=aEnumerationsOrFlags[Index];
 end;
end;

procedure TpvEntityComponentSystem.TRegisteredComponentType.Finish;
begin
 SetLength(fFields,fCountFields);
end;

function TpvEntityComponentSystem.TRegisteredComponentType.SerializeToJSON(const aData:TpvPointer;const aWorld:TWorld):TPasJSONItemObject;
 function GetElementValue(const aField:PField;
                          const aValueData:TpvPointer):TPasJSONItem;
 var Data:TpvPointer;
     EnumerationFlagIndex:TpvSizeInt;
     SignedInteger:TpvInt64;
     UnsignedInteger:TpvUInt64;
     FloatValue:TpvDouble;
     StringValue:TpvUTF8String;
     Entity:PEntity;
 begin
  result:=nil;
  Data:=aValueData;
  case aField^.ElementType of
   TRegisteredComponentType.TField.TElementType.EntityID:begin
    case aField^.ElementSize of
     1:begin
      UnsignedInteger:=PpvUInt8(Data)^;
     end;
     2:begin
      UnsignedInteger:=PpvUInt16(Data)^;
     end;
     4:begin
      UnsignedInteger:=PpvUInt32(Data)^;
     end;
     8:begin
      UnsignedInteger:=PpvUInt64(Data)^;
     end;
     else begin
      raise ERegisteredComponentType.Create('Internal error 2018-09-04-23-58-0000');
     end;
    end;
    Entity:=aWorld.GetEntityByID(UnsignedInteger);
    if assigned(Entity) then begin
     result:=TPasJSONItemString.Create(Entity^.fSUID.ToString);
    end else begin
     result:=TPasJSONItemNull.Create;
    end;
   end;
   TRegisteredComponentType.TField.TElementType.Enumeration:begin
    case aField^.ElementSize of
     1:begin
      UnsignedInteger:=PpvUInt8(Data)^;
     end;
     2:begin
      UnsignedInteger:=PpvUInt16(Data)^;
     end;
     4:begin
      UnsignedInteger:=PpvUInt32(Data)^;
     end;
     8:begin
      UnsignedInteger:=PpvUInt64(Data)^;
     end;
     else begin
      raise ERegisteredComponentType.Create('Internal error 2018-09-04-23-36-0000');
     end;
    end;
    EnumerationFlagIndex:=0;
    while EnumerationFlagIndex<length(aField^.EnumerationsOrFlags) do begin
     if aField^.EnumerationsOrFlags[EnumerationFlagIndex].Value=UnsignedInteger then begin
      result:=TPasJSONItemString.Create(aField^.EnumerationsOrFlags[EnumerationFlagIndex].Name);
      break;
     end;
     inc(EnumerationFlagIndex);
    end;
    if EnumerationFlagIndex>=length(aField^.EnumerationsOrFlags) then begin
     result:=TPasJSONItemString.Create('');
    end;
   end;
   TRegisteredComponentType.TField.TElementType.Flags:begin
    case aField^.ElementSize of
     1:begin
      UnsignedInteger:=PpvUInt8(Data)^;
     end;
     2:begin
      UnsignedInteger:=PpvUInt16(Data)^;
     end;
     4:begin
      UnsignedInteger:=PpvUInt32(Data)^;
     end;
     8:begin
      UnsignedInteger:=PpvUInt64(Data)^;
     end;
     else begin
      raise ERegisteredComponentType.Create('Internal error 2018-09-04-23-36-0000');
     end;
    end;
    result:=TPasJSONItemArray.Create;
    for EnumerationFlagIndex:=0 to length(aField^.EnumerationsOrFlags)-1 do begin
     if (aField^.EnumerationsOrFlags[EnumerationFlagIndex].Value and UnsignedInteger)<>0 then begin
      TPasJSONItemArray(result).Add(TPasJSONItemString.Create(aField^.EnumerationsOrFlags[EnumerationFlagIndex].Name));
     end;
    end;
   end;
   TRegisteredComponentType.TField.TElementType.Boolean:begin
    case aField^.ElementSize of
     1:begin
      UnsignedInteger:=PpvUInt8(Data)^;
     end;
     2:begin
      UnsignedInteger:=PpvUInt16(Data)^;
     end;
     4:begin
      UnsignedInteger:=PpvUInt32(Data)^;
     end;
     8:begin
      UnsignedInteger:=PpvUInt64(Data)^;
     end;
     else begin
      raise ERegisteredComponentType.Create('Internal error 2018-09-05-00-25-0000');
     end;
    end;
    result:=TPasJSONItemBoolean.Create(UnsignedInteger<>0);
   end;
   TRegisteredComponentType.TField.TElementType.SignedInteger:begin
    case aField^.ElementSize of
     1:begin
      SignedInteger:=PpvInt8(Data)^;
     end;
     2:begin
      SignedInteger:=PpvInt16(Data)^;
     end;
     4:begin
      SignedInteger:=PpvInt32(Data)^;
     end;
     8:begin
      SignedInteger:=PpvInt64(Data)^;
     end;
     else begin
      raise ERegisteredComponentType.Create('Internal error 2018-09-05-00-15-0001');
     end;
    end;
    if abs(SignedInteger)<TpvUInt64($0010000000000000) then begin
     result:=TPasJSONItemNumber.Create(SignedInteger);
    end else begin
     result:=TPasJSONItemString.Create(IntToStr(SignedInteger));
    end;
   end;
   TRegisteredComponentType.TField.TElementType.UnsignedInteger:begin
    case aField^.ElementSize of
     1:begin
      UnsignedInteger:=PpvUInt8(Data)^;
     end;
     2:begin
      UnsignedInteger:=PpvUInt16(Data)^;
     end;
     4:begin
      UnsignedInteger:=PpvUInt32(Data)^;
     end;
     8:begin
      UnsignedInteger:=PpvUInt64(Data)^;
     end;
     else begin
      raise ERegisteredComponentType.Create('Internal error 2018-09-05-00-15-0000');
     end;
    end;
    if UnsignedInteger<TpvUInt64($0010000000000000) then begin
     result:=TPasJSONItemNumber.Create(UnsignedInteger);
    end else begin
     result:=TPasJSONItemString.Create(IntToStr(UnsignedInteger));
    end;
   end;
   TRegisteredComponentType.TField.TElementType.FloatingPoint:begin
    case aField^.ElementSize of
     2:begin
      FloatValue:=PpvHalfFloat(Data)^.ToFloat;
     end;
     4:begin
      FloatValue:=PpvFloat(Data)^;
     end;
     8:begin
      FloatValue:=PpvDouble(Data)^;
     end;
     else begin
      raise ERegisteredComponentType.Create('Internal error 2018-09-05-00-22-0000');
     end;
    end;
    result:=TPasJSONItemNumber.Create(FloatValue);
   end;
   TRegisteredComponentType.TField.TElementType.LengthPrefixedString:begin
    UnsignedInteger:=PpvUInt8(Data)^;
    StringValue:='';
    if UnsignedInteger>0 then begin
     SetLength(StringValue,UnsignedInteger);
     Move(PAnsiChar(Data)[1],StringValue[1],UnsignedInteger);
    end;
    result:=TPasJSONItemString.Create(StringValue);
   end;
   TRegisteredComponentType.TField.TElementType.ZeroTerminatedString:begin
    StringValue:=PAnsiChar(Data);
    result:=TPasJSONItemString.Create(StringValue);
   end;
   TRegisteredComponentType.TField.TElementType.Blob:begin
    result:=TPasJSONItemString.Create(TpvBase64.Encode(Data^,aField^.ElementSize));
   end;
   else begin
    raise ERegisteredComponentType.Create('Internal error 2018-09-05-00-11-0000');
   end;
  end;
 end;
 function GetFieldValue(const aField:PField;
                        const aData:TpvPointer):TPasJSONItem;
 var ElementIndex:TpvSizeInt;
 begin
  if aField^.ElementCount>1 then begin
   result:=TPasJSONItemArray.Create;
   for ElementIndex:=0 to aField^.ElementCount-1 do begin
    TPasJSONItemArray(result).Add(GetElementValue(aField,@PpvUInt8Array(aData)^[aField^.Offset+(ElementIndex*aField^.ElementSize)]));
   end;
  end else begin
   result:=GetElementValue(aField,@PpvUInt8Array(aData)^[aField^.Offset]);
  end;
 end;
var FieldIndex:TpvSizeInt;
    Field:PField;
begin
 result:=TPasJSONItemObject.Create;
 try
  for FieldIndex:=0 to fCountFields-1 do begin
   Field:=@fFields[FieldIndex];
   result.Add(Field^.Name,GetFieldValue(Field,aData));
  end;
 except
  FreeAndNil(result);
  raise;
 end;
end;

procedure TpvEntityComponentSystem.TRegisteredComponentType.UnserializeFromJSON(const aJSON:TPasJSONItem;const aData:TpvPointer;const aWorld:TWorld);
 procedure SetField(const aField:PField;
                    const aData:TpvPointer;
                    const aJSONItemValue:TPasJSONItem);
 var EnumerationFlagIndex,ArrayItemIndex:TpvSizeInt;
     Code:TpvInt32;
     ArrayJSONItemValue:TPasJSONItem;
     SignedInteger:TpvInt64;
     UnsignedInteger:TpvUInt64;
     FloatValue:TpvDouble;
     StringValue:TpvUTF8String;
     Stream:TMemoryStream;
     Entity:PEntity;
 begin
  case aField^.ElementType of
   TRegisteredComponentType.TField.TElementType.EntityID:begin
    if aJSONItemValue is TPasJSONItemNumber then begin
     UnsignedInteger:=trunc(TPasJSONItemNumber(aJSONItemValue).Value);
    end else if aJSONItemValue is TPasJSONItemString then begin
     StringValue:=TPasJSONItemString(aJSONItemValue).Value;
     Entity:=aWorld.GetEntityBySUID(TpvSUID.CreateFromString(StringValue));
     if assigned(Entity) then begin
      UnsignedInteger:=Entity^.fID;
     end else begin
      UnsignedInteger:=TEntityID.Invalid;
     end;
    end else if aJSONItemValue is TPasJSONItemBoolean then begin
     UnsignedInteger:=ord(TPasJSONItemBoolean(aJSONItemValue).Value) and 1;
    end else begin
     UnsignedInteger:=TEntityID.Invalid;
    end;
    case aField^.ElementSize of
     1:begin
      PpvUInt8(aData)^:=UnsignedInteger;
     end;
     2:begin
      PpvUInt16(aData)^:=UnsignedInteger;
     end;
     4:begin
      PpvUInt32(aData)^:=UnsignedInteger;
     end;
     8:begin
      PpvUInt64(aData)^:=UnsignedInteger;
     end;
     else begin
      raise ERegisteredComponentType.Create('Internal error 2018-09-05-01-24-0000');
     end;
    end;
   end;
   TRegisteredComponentType.TField.TElementType.Enumeration:begin
    if aJSONItemValue is TPasJSONItemString then begin
     StringValue:=TPasJSONItemString(aJSONItemValue).Value;
    end else begin
     StringValue:='';
    end;
    UnsignedInteger:=0;
    for EnumerationFlagIndex:=0 to length(aField^.EnumerationsOrFlags)-1 do begin
     if aField^.EnumerationsOrFlags[EnumerationFlagIndex].Name=StringValue then begin
      UnsignedInteger:=aField^.EnumerationsOrFlags[EnumerationFlagIndex].Value;
      break;
     end;
    end;
    case aField^.ElementSize of
     1:begin
      PpvUInt8(aData)^:=UnsignedInteger;
     end;
     2:begin
      PpvUInt16(aData)^:=UnsignedInteger;
     end;
     4:begin
      PpvUInt32(aData)^:=UnsignedInteger;
     end;
     8:begin
      PpvUInt64(aData)^:=UnsignedInteger;
     end;
     else begin
      raise ERegisteredComponentType.Create('Internal error 2018-09-05-01-29-0000');
     end;
    end;
   end;
   TRegisteredComponentType.TField.TElementType.Flags:begin
    UnsignedInteger:=0;
    if aJSONItemValue is TPasJSONItemArray then begin
     for ArrayItemIndex:=0 to TPasJSONItemArray(aJSONItemValue).Count-1 do begin
      ArrayJSONItemValue:=TPasJSONItemArray(aJSONItemValue).Items[ArrayItemIndex];
      if assigned(ArrayJSONItemValue) then begin
       if ArrayJSONItemValue is TPasJSONItemString then begin
        StringValue:=TPasJSONItemString(ArrayJSONItemValue).Value;
       end else begin
        StringValue:='';
       end;
       for EnumerationFlagIndex:=0 to length(aField^.EnumerationsOrFlags)-1 do begin
        if aField^.EnumerationsOrFlags[EnumerationFlagIndex].Name=StringValue then begin
         UnsignedInteger:=UnsignedInteger or aField^.EnumerationsOrFlags[EnumerationFlagIndex].Value;
        end;
       end;
      end;
     end;
    end;
    case aField^.ElementSize of
     1:begin
      PpvUInt8(aData)^:=UnsignedInteger;
     end;
     2:begin
      PpvUInt16(aData)^:=UnsignedInteger;
     end;
     4:begin
      PpvUInt32(aData)^:=UnsignedInteger;
     end;
     8:begin
      PpvUInt64(aData)^:=UnsignedInteger;
     end;
     else begin
      raise ERegisteredComponentType.Create('Internal error 2018-09-05-01-33-0000');
     end;
    end;
   end;
   TRegisteredComponentType.TField.TElementType.Boolean:begin
    if aJSONItemValue is TPasJSONItemNumber then begin
     UnsignedInteger:=trunc(TPasJSONItemNumber(aJSONItemValue).Value) and 1;
    end else if aJSONItemValue is TPasJSONItemString then begin
     UnsignedInteger:=StrToIntDef(TPasJSONItemString(aJSONItemValue).Value,0) and 1;
    end else if aJSONItemValue is TPasJSONItemBoolean then begin
     UnsignedInteger:=ord(TPasJSONItemBoolean(aJSONItemValue).Value) and 1;
    end else begin
     UnsignedInteger:=0;
    end;
    case aField^.ElementSize of
     1:begin
      PpvUInt8(aData)^:=UnsignedInteger;
     end;
     2:begin
      PpvUInt16(aData)^:=UnsignedInteger;
     end;
     4:begin
      PpvUInt32(aData)^:=UnsignedInteger;
     end;
     8:begin
      PpvUInt64(aData)^:=UnsignedInteger;
     end;
     else begin
      raise ERegisteredComponentType.Create('Internal error 2018-09-05-01-37-0000');
     end;
    end;
   end;
   TRegisteredComponentType.TField.TElementType.SignedInteger:begin
    if aJSONItemValue is TPasJSONItemNumber then begin
     SignedInteger:=trunc(TPasJSONItemNumber(aJSONItemValue).Value);
    end else if aJSONItemValue is TPasJSONItemString then begin
     SignedInteger:=StrToIntDef(TPasJSONItemString(aJSONItemValue).Value,0);
    end else if aJSONItemValue is TPasJSONItemBoolean then begin
     SignedInteger:=ord(TPasJSONItemBoolean(aJSONItemValue).Value) and 1;
    end else begin
     SignedInteger:=0;
    end;
    case aField^.ElementSize of
     1:begin
      PpvInt8(aData)^:=SignedInteger;
     end;
     2:begin
      PpvInt16(aData)^:=SignedInteger;
     end;
     4:begin
      PpvInt32(aData)^:=SignedInteger;
     end;
     8:begin
      PpvInt64(aData)^:=SignedInteger;
     end;
     else begin
      raise ERegisteredComponentType.Create('Internal error 2018-09-05-01-38-0000');
     end;
    end;
   end;
   TRegisteredComponentType.TField.TElementType.UnsignedInteger:begin
    if aJSONItemValue is TPasJSONItemNumber then begin
     UnsignedInteger:=trunc(TPasJSONItemNumber(aJSONItemValue).Value);
    end else if aJSONItemValue is TPasJSONItemString then begin
     UnsignedInteger:=StrToIntDef(TPasJSONItemString(aJSONItemValue).Value,0);
    end else if aJSONItemValue is TPasJSONItemBoolean then begin
     UnsignedInteger:=ord(TPasJSONItemBoolean(aJSONItemValue).Value) and 1;
    end else begin
     UnsignedInteger:=0;
    end;
    case aField^.ElementSize of
     1:begin
      PpvUInt8(aData)^:=UnsignedInteger;
     end;
     2:begin
      PpvUInt16(aData)^:=UnsignedInteger;
     end;
     4:begin
      PpvUInt32(aData)^:=UnsignedInteger;
     end;
     8:begin
      PpvUInt64(aData)^:=UnsignedInteger;
     end;
     else begin
      raise ERegisteredComponentType.Create('Internal error 2018-09-05-01-38-0001');
     end;
    end;
   end;
   TRegisteredComponentType.TField.TElementType.FloatingPoint:begin
    if aJSONItemValue is TPasJSONItemNumber then begin
     FloatValue:=TPasJSONItemNumber(aJSONItemValue).Value;
    end else if aJSONItemValue is TPasJSONItemString then begin
     FloatValue:=0.0;
     Val(TPasJSONItemString(aJSONItemValue).Value,FloatValue,Code);
     if Code<>0 then begin
     end;
    end else if aJSONItemValue is TPasJSONItemBoolean then begin
     FloatValue:=ord(TPasJSONItemBoolean(aJSONItemValue).Value) and 1;
    end else begin
     FloatValue:=0.0;
    end;
    case aField^.ElementSize of
     2:begin
      PpvHalfFloat(aData)^:=FloatValue;
     end;
     4:begin
      PpvFloat(aData)^:=FloatValue;
     end;
     8:begin
      PpvDouble(aData)^:=FloatValue;
     end;
     else begin
      raise ERegisteredComponentType.Create('Internal error 2018-09-05-01-38-0002');
     end;
    end;
   end;
   TRegisteredComponentType.TField.TElementType.LengthPrefixedString:begin
    if aJSONItemValue is TPasJSONItemString then begin
     StringValue:=TPasJSONItemString(aJSONItemValue).Value;
    end else begin
     StringValue:='';
    end;
    if length(StringValue)>(aField^.ElementSize-1) then begin
     SetLength(StringValue,aField^.ElementSize-1);
    end;
    PpvUInt8(aData)^:=length(StringValue);
    if length(StringValue)>0 then begin
     Move(StringValue[1],PAnsiChar(aData)[1],length(StringValue));
    end;
   end;
   TRegisteredComponentType.TField.TElementType.ZeroTerminatedString:begin
    if aJSONItemValue is TPasJSONItemString then begin
     StringValue:=TPasJSONItemString(aJSONItemValue).Value;
    end else begin
     StringValue:='';
    end;
    if length(StringValue)>(aField^.ElementSize-1) then begin
     SetLength(StringValue,aField^.ElementSize-1);
    end;
    if length(StringValue)>0 then begin
     Move(StringValue[1],PAnsiChar(aData)[0],length(StringValue));
    end;
    PAnsiChar(aData)[length(StringValue)]:=#0;
   end;
   TRegisteredComponentType.TField.TElementType.Blob:begin
    if aJSONItemValue is TPasJSONItemString then begin
     StringValue:=TPasJSONItemString(aJSONItemValue).Value;
    end else begin
     StringValue:='';
    end;
    Stream:=TMemoryStream.Create;
    try
     if TpvBase64.Decode(TpvRawByteString(StringValue),Stream) then begin
      FillChar(aData^,Min(Stream.Size,aField^.ElementSize),#0);
      if Stream.Size>0 then begin
       Move(Stream.Memory^,aData^,Min(Stream.Size,aField^.ElementSize));
      end;
     end else begin
      raise ERegisteredComponentType.Create('Internal error 2018-09-05-00-53-0001');
     end;
    finally
     FreeAndNil(Stream);
    end;
   end;
   else begin
    raise ERegisteredComponentType.Create('Internal error 2018-09-05-00-53-0000');
   end;
  end;
 end;
var FieldIndex,ElementIndex:TpvSizeInt;
    Field:PField;
    Data:TpvPointer;
    JSONItemObject:TPasJSONItemObject;
    ValueJSONItem:TPasJSONItem;
    ValueJSONItemArray:TPasJSONItemArray;
begin
 if assigned(aJSON) and (aJSON is TPasJSONItemObject) then begin
  JSONItemObject:=TPasJSONItemObject(aJSON);
  for FieldIndex:=0 to fCountFields-1 do begin
   Field:=@fFields[FieldIndex];
   Data:=@PpvUInt8Array(aData)^[Field^.Offset];
   ValueJSONItem:=JSONItemObject.Properties[Field^.Name];
   if assigned(ValueJSONItem) then begin
    if Field^.ElementCount>1 then begin
     if ValueJSONItem is TPasJSONItemArray then begin
      ValueJSONItemArray:=TPasJSONItemArray(ValueJSONItem);
     end else begin
      ValueJSONItemArray:=TPasJSONItemArray.Create;
      ValueJSONItemArray.Add(ValueJSONItem);
     end;
     try
      for ElementIndex:=0 to Min(Field^.ElementCount,ValueJSONItemArray.Count)-1 do begin
       SetField(Field,@PpvUInt8Array(Data)^[ElementIndex*Field^.ElementSize],ValueJSONItemArray.Items[ElementIndex]);
      end;
      for ElementIndex:=ValueJSONItemArray.Count to Field^.ElementCount-1 do begin
       FillChar(PpvUInt8Array(Data)^[ElementIndex*Field^.ElementSize],Field^.ElementSize,#0);
      end;
     finally
      if ValueJSONItemArray<>ValueJSONItem then begin
       FreeAndNil(ValueJSONItemArray);
      end;
     end;
    end else begin
     SetField(Field,Data,ValueJSONItem);
    end;
   end else begin
    if Field^.ElementType=TRegisteredComponentType.TField.TElementType.EntityID then begin
     FillChar(Data^,Field^.Size,#$ff);
    end else begin
     FillChar(Data^,Field^.Size,#0);
    end;
   end;
  end;
 end else begin
  raise ERegisteredComponentType.Create('Internal error 2018-09-05-01-08-0000');
 end;
end;

{ TpvEntityComponentSystem.TComponent }

constructor TpvEntityComponentSystem.TComponent.Create(const aWorld:TWorld;const aRegisteredComponentType:TRegisteredComponentType);
begin
 inherited Create;

 fWorld:=aWorld;

 fRegisteredComponentType:=aRegisteredComponentType;

 fSize:=fRegisteredComponentType.fSize;

 fPoolUnaligned:=nil;

 fPool:=nil;

 fPoolSize:=0;

 fCountPoolItems:=0;

 fCapacity:=0;

 fPoolIndexCounter:=0;

 fMaxEntityIndex:=-1;

 fCountFrees:=0;

 fNeedToDefragment:=false;

 fEntityIndexToComponentPoolIndex:=nil;

 fComponentPoolIndexToEntityIndex:=nil;

 fPointers:=nil;

 fDataPointer:=nil;

 fUsedBitmap:=nil;

end;

destructor TpvEntityComponentSystem.TComponent.Destroy;
begin

 if assigned(fPoolUnaligned) then begin
  FreeMem(fPoolUnaligned);
 end;

 fPointers:=nil;

 fEntityIndexToComponentPoolIndex:=nil;

 fComponentPoolIndexToEntityIndex:=nil;

 fPointers:=nil;

 fUsedBitmap:=nil;

 inherited Destroy;

end;

procedure TpvEntityComponentSystem.TComponent.FinalizeComponentByPoolIndex(const aPoolIndex:TpvSizeInt);
begin
end;

procedure TpvEntityComponentSystem.TComponent.SetMaxEntities(const aCount:TpvSizeInt);
var OldCount:TpvSizeInt;
begin
 OldCount:=length(fPointers);
 if OldCount<aCount then begin
  SetLength(fPointers,aCount+((aCount+1) shr 1));
  FillChar(fPointers[OldCount],(length(fPointers)-OldCount)*SizeOf(TpvPointer),#0);
  fDataPointer:=@fPointers[0];
 end;
end;

procedure TpvEntityComponentSystem.TComponent.Defragment;
 function CompareFunction(const a,b:TpvSizeInt):TpvSizeInt;
 begin
  if (a>=0) and (b>=0) then begin
   result:=a-b;
  end else if a<>b then begin
   if a<0 then begin
    result:=1;
   end else begin
    result:=-1;
   end;
  end else begin
   result:=0;
  end;
 end;
 procedure IntroSort(Left,Right:TpvSizeInt);
 type PByteArray=^TByteArray;
      TByteArray=array[0..$3fffffff] of byte;
      PStackItem=^TStackItem;
      TStackItem=record
       Left,Right,Depth:TpvSizeInt;
      end;
 var Depth,i,j,Middle,Size,Parent,Child,TempPoolIndex,PivotPoolIndex:TpvSizeInt;
     Items,Pivot,Temp:TpvPointer;
     StackItem:PStackItem;
     Stack:array[0..31] of TStackItem;
 begin
  if Left<Right then begin
   GetMem(Temp,fSize);
   GetMem(Pivot,fSize);
   try
    Items:=fPool;
    StackItem:=@Stack[0];
    StackItem^.Left:=Left;
    StackItem^.Right:=Right;
    StackItem^.Depth:=IntLog2((Right-Left)+1) shl 1;
    inc(StackItem);
    while TpvPtrUInt(TpvPointer(StackItem))>TpvPtrUInt(TpvPointer(@Stack[0])) do begin
     dec(StackItem);
     Left:=StackItem^.Left;
     Right:=StackItem^.Right;
     Depth:=StackItem^.Depth;
     if (Right-Left)<16 then begin
      // Insertion sort
      for i:=Left+1 to Right do begin
       j:=i-1;
       if (j>=Left) and (CompareFunction(fComponentPoolIndexToEntityIndex[j],fComponentPoolIndexToEntityIndex[i])>0) then begin
        Move(PByteArray(Items)^[i*fSize],Temp^,fSize);
        TempPoolIndex:=fComponentPoolIndexToEntityIndex[i];
        repeat
         Move(PByteArray(Items)^[j*fSize],PByteArray(Items)^[(j+1)*fSize],fSize);
         fComponentPoolIndexToEntityIndex[j+1]:=fComponentPoolIndexToEntityIndex[j];
         dec(j);
        until not ((j>=Left) and (CompareFunction(fComponentPoolIndexToEntityIndex[j],TempPoolIndex)>0));
        Move(Temp^,PByteArray(Items)^[(j+1)*fSize],fSize);
        fComponentPoolIndexToEntityIndex[j+1]:=TempPoolIndex;
       end;
      end;
     end else begin
      if (Depth=0) or (TpvPtrUInt(TpvPointer(StackItem))>=TpvPtrUInt(TpvPointer(@Stack[high(Stack)-1]))) then begin
       // Heap sort
       Size:=(Right-Left)+1;
       i:=Size div 2;
       TempPoolIndex:=0;
       repeat
        if i>Left then begin
         dec(i);
         Move(PByteArray(Items)^[(Left+i)*fSize],Temp^,fSize);
         TempPoolIndex:=fComponentPoolIndexToEntityIndex[Left+i];
        end else begin
         if Size=0 then begin
          break;
         end else begin
          dec(Size);
          Move(PByteArray(Items)^[(Left+Size)*fSize],Temp^,fSize);
          Move(PByteArray(Items)^[Left*fSize],PByteArray(Items)^[(Left+Size)*fSize],fSize);
          TempPoolIndex:=fComponentPoolIndexToEntityIndex[Left+Size];
          fComponentPoolIndexToEntityIndex[Left+Size]:=fComponentPoolIndexToEntityIndex[Left];
         end;
        end;
        Parent:=i;
        Child:=(i*2)+1;
        while Child<Size do begin
         if ((Child+1)<Size) and (CompareFunction(fComponentPoolIndexToEntityIndex[(Left+Child)+1],fComponentPoolIndexToEntityIndex[Left+Child])>0) then begin
          inc(Child);
         end;
         if CompareFunction(fComponentPoolIndexToEntityIndex[Left+Child],TempPoolIndex)>0 then begin
          Move(PByteArray(Items)^[(Left+Child)*fSize],PByteArray(Items)^[(Left+Parent)*fSize],fSize);
          fComponentPoolIndexToEntityIndex[Left+Parent]:=fComponentPoolIndexToEntityIndex[Left+Child];
          Parent:=Child;
          Child:=(Parent*2)+1;
         end else begin
          break;
         end;
        end;
        Move(Temp^,PByteArray(fPool)^[(Left+Parent)*fSize],fSize);
        fComponentPoolIndexToEntityIndex[Left+Parent]:=TempPoolIndex;
       until false;
      end else begin
       // Quick sort width median-of-three optimization
       Middle:=Left+((Right-Left) shr 1);
       if (Right-Left)>3 then begin
        if CompareFunction(fComponentPoolIndexToEntityIndex[Left],fComponentPoolIndexToEntityIndex[Middle])>0 then begin
         Move(PByteArray(Items)^[Left*fSize],Temp^,fSize);
         Move(PByteArray(Items)^[Middle*fSize],PByteArray(Items)^[Left*fSize],fSize);
         Move(Temp^,PByteArray(Items)^[Middle*fSize],fSize);
         TempPoolIndex:=fComponentPoolIndexToEntityIndex[Left];
         fComponentPoolIndexToEntityIndex[Left]:=fComponentPoolIndexToEntityIndex[Middle];
         fComponentPoolIndexToEntityIndex[Middle]:=TempPoolIndex;
        end;
        if CompareFunction(fComponentPoolIndexToEntityIndex[Left],fComponentPoolIndexToEntityIndex[Right])>0 then begin
         Move(PByteArray(Items)^[Left*fSize],Temp^,fSize);
         Move(PByteArray(Items)^[Right*fSize],PByteArray(Items)^[Left*fSize],fSize);
         Move(Temp^,PByteArray(Items)^[Right*fSize],fSize);
         TempPoolIndex:=fComponentPoolIndexToEntityIndex[Left];
         fComponentPoolIndexToEntityIndex[Left]:=fComponentPoolIndexToEntityIndex[Right];
         fComponentPoolIndexToEntityIndex[Right]:=TempPoolIndex;
        end;
        if CompareFunction(fComponentPoolIndexToEntityIndex[Middle],fComponentPoolIndexToEntityIndex[Right])>0 then begin
         Move(PByteArray(Items)^[Middle*fSize],Temp^,fSize);
         Move(PByteArray(Items)^[Right*fSize],PByteArray(Items)^[Middle*fSize],fSize);
         Move(Temp^,PByteArray(Items)^[Right*fSize],fSize);
         TempPoolIndex:=fComponentPoolIndexToEntityIndex[Middle];
         fComponentPoolIndexToEntityIndex[Middle]:=fComponentPoolIndexToEntityIndex[Right];
         fComponentPoolIndexToEntityIndex[Right]:=TempPoolIndex;
        end;
       end;
       Move(PByteArray(Items)^[Middle*fSize],Pivot^,fSize);
       PivotPoolIndex:=fComponentPoolIndexToEntityIndex[Middle];
       i:=Left;
       j:=Right;
       repeat
        while (i<Right) and (CompareFunction(fComponentPoolIndexToEntityIndex[i],PivotPoolIndex)<0) do begin
         inc(i);
        end;
        while (j>=i) and (CompareFunction(fComponentPoolIndexToEntityIndex[j],PivotPoolIndex)>0) do begin
         dec(j);
        end;
        if i>j then begin
         break;
        end else begin
         if i<>j then begin
          Move(PByteArray(Items)^[i*fSize],Temp^,fSize);
          Move(PByteArray(Items)^[j*fSize],PByteArray(Items)^[i*fSize],fSize);
          Move(Temp^,PByteArray(Items)^[j*fSize],fSize);
          TempPoolIndex:=fComponentPoolIndexToEntityIndex[i];
          fComponentPoolIndexToEntityIndex[i]:=fComponentPoolIndexToEntityIndex[j];
          fComponentPoolIndexToEntityIndex[j]:=TempPoolIndex;
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
   finally
    FreeMem(Pivot);
    FreeMem(Temp);
   end;
  end;
 end;
var Index,OtherIndex:TpvSizeInt;
    NeedToSort:boolean;
begin
 NeedToSort:=false;
 for Index:=0 to fPoolIndexCounter-2 do begin
  if fComponentPoolIndexToEntityIndex[Index]>fComponentPoolIndexToEntityIndex[Index+1] then begin
   NeedToSort:=true;
   break;
  end;
 end;
 if NeedToSort then begin
  IntroSort(0,fPoolIndexCounter-1);
  for Index:=0 to fMaxEntityIndex do begin
   fEntityIndexToComponentPoolIndex[Index]:=-1;
  end;
  for Index:=0 to fPoolIndexCounter-1 do begin
   OtherIndex:=fComponentPoolIndexToEntityIndex[Index];
   if OtherIndex>=0 then begin
    fEntityIndexToComponentPoolIndex[OtherIndex]:=Index;
   end;
  end;
  for Index:=0 to fMaxEntityIndex do begin
   OtherIndex:=fEntityIndexToComponentPoolIndex[Index];
   if OtherIndex>=0 then begin
    fPointers[Index]:=TpvPointer(TpvPtrUInt(TpvPtrUInt(fPool)+TpvPtrUInt(TpvPtrUInt(OtherIndex)*TpvPtrUInt(fSize))));
   end else begin
    fPointers[Index]:=nil;
   end;
  end;
  fCountFrees:=0;
  fNeedToDefragment:=false;
 end;
end;

procedure TpvEntityComponentSystem.TComponent.DefragmentIfNeeded;
begin
 if fNeedToDefragment then begin
  fNeedToDefragment:=false;
  Defragment;
 end;
end;

function TpvEntityComponentSystem.TComponent.GetComponentPoolIndexForEntityIndex(const aEntityIndex:TpvSizeInt):TpvSizeInt;
begin
 if (aEntityIndex>=0) and
    (aEntityIndex<=fMaxEntityIndex) and
    ((fUsedBitmap[aEntityIndex shr 5] and TpvUInt32(TpvUInt32(1) shl TpvUInt32(aEntityIndex and 31)))<>0) then begin
  result:=fEntityIndexToComponentPoolIndex[aEntityIndex];
 end else begin
  result:=-1;
 end;
end;

function TpvEntityComponentSystem.TComponent.IsComponentInEntityIndex(const aEntityIndex:TpvSizeInt):boolean;
begin
 result:=(aEntityIndex>=0) and
         (aEntityIndex<=fMaxEntityIndex) and
         ((fUsedBitmap[aEntityIndex shr 5] and TpvUInt32(TpvUInt32(1) shl TpvUInt32(aEntityIndex and 31)))<>0) and
         (fEntityIndexToComponentPoolIndex[aEntityIndex]>=0);
end;

function TpvEntityComponentSystem.TComponent.GetEntityIndexByPoolIndex(const aPoolIndex:TpvSizeInt):TpvSizeInt;
begin
 if (aPoolIndex>=0) and
    (aPoolIndex<fPoolIndexCounter) then begin
  result:=fComponentPoolIndexToEntityIndex[aPoolIndex];
 end else begin
  result:=-1;
 end;
end;

function TpvEntityComponentSystem.TComponent.GetComponentByPoolIndex(const aPoolIndex:TpvSizeInt):TpvPointer;
begin
 if (aPoolIndex>=0) and
    (aPoolIndex<fPoolIndexCounter) then begin
  result:=TpvPointer(TpvPtrUInt(TpvPtrUInt(fPool)+TpvPtrUInt(TpvPtrUInt(aPoolIndex)*TpvPtrUInt(fSize))));
 end else begin
  result:=nil;
 end;
end;

function TpvEntityComponentSystem.TComponent.GetComponentByEntityIndex(const aEntityIndex:TpvSizeInt):TpvPointer;
var PoolIndex:TpvSizeInt;
begin
 result:=nil;
 if (aEntityIndex>=0) and
    (aEntityIndex<=fMaxEntityIndex) and
    ((fUsedBitmap[aEntityIndex shr 5] and TpvUInt32(TpvUInt32(1) shl TpvUInt32(aEntityIndex and 31)))<>0) then begin
  PoolIndex:=fComponentPoolIndexToEntityIndex[aEntityIndex];
  if (PoolIndex>=0) and
     (PoolIndex<fPoolIndexCounter) then begin
   result:=TpvPointer(TpvPtrUInt(TpvPtrUInt(fPool)+TpvPtrUInt(TpvPtrUInt(PoolIndex)*TpvPtrUInt(fSize))));
  end;
 end;
end;

function TpvEntityComponentSystem.TComponent.AllocateComponentForEntityIndex(const aEntityIndex:TpvSizeInt):boolean;
var Index,PoolIndex,NewMaxEntityIndex,OldCapacity,OldCount,Count,OtherIndex,
    OldPoolSize,NewPoolSize:TpvSizeInt;
    Bitmap:PpvUInt32;
    OldPoolAlignmentOffset:TpvPtrUInt;
begin

 result:=false;

 if (aEntityIndex>=0) and
    not ((aEntityIndex<=fMaxEntityIndex) and
         (fEntityIndexToComponentPoolIndex[aEntityIndex]>=0)) then begin

  if fMaxEntityIndex<aEntityIndex then begin
   NewMaxEntityIndex:=(aEntityIndex+1)*2;
   SetLength(fEntityIndexToComponentPoolIndex,NewMaxEntityIndex+1);
   for Index:=fMaxEntityIndex+1 to NewMaxEntityIndex do begin
    fEntityIndexToComponentPoolIndex[Index]:=-1;
   end;
   fMaxEntityIndex:=NewMaxEntityIndex;
  end;

  PoolIndex:=fPoolIndexCounter;
  inc(fPoolIndexCounter);

  if fCapacity<fPoolIndexCounter then begin
   OldCapacity:=fCapacity;
   fCapacity:=fPoolIndexCounter*2;
   SetLength(fComponentPoolIndexToEntityIndex,fCapacity);
   for Index:=OldCapacity to fCapacity-1 do begin
    fComponentPoolIndexToEntityIndex[Index]:=-1;
   end;
  end;

  NewPoolSize:=TpvSizeInt(fCapacity)*TpvSizeInt(fSize);
  if fPoolSize<NewPoolSize then begin
   OldPoolSize:=fPoolSize;
   fPoolSize:=NewPoolSize*2;
   if assigned(fPoolUnaligned) then begin
    OldPoolAlignmentOffset:=TpvPtrUInt(TpvPtrUInt(fPool)-TpvPtrUInt(fPoolUnaligned));
    ReallocMem(fPoolUnaligned,fPoolSize+(4096*2));
    fPool:=TpvPointer(TpvPtrUInt(TpvPtrUInt(TpvPtrUInt(fPoolUnaligned)+4095) and not 4095));
    if OldPoolAlignmentOffset<>TpvPtrUInt(TpvPtrUInt(fPool)-TpvPtrUInt(fPoolUnaligned)) then begin
     // Move the old existent data to the new alignment offset
     Move(TpvPointer(TpvPtrUInt(TpvPtrUInt(fPoolUnaligned)+TpvPtrUInt(OldPoolAlignmentOffset)))^,fPool^,fPoolSize);
    end;
    if OldPoolSize<fPoolSize then begin
     FillChar(TpvPointer(TpvPtrUInt(TpvPtrUInt(fPool)+TpvPtrUInt(OldPoolSize)))^,fPoolSize-OldPoolSize,#0);
    end;
    for Index:=0 to fMaxEntityIndex do begin
     OtherIndex:=fEntityIndexToComponentPoolIndex[Index];
     if OtherIndex>=0 then begin
      fPointers[Index]:=TpvPointer(TpvPtrUInt(TpvPtrUInt(fPool)+TpvPtrUInt(TpvPtrUInt(OtherIndex)*TpvPtrUInt(fSize))));
     end else begin
      fPointers[Index]:=nil;
     end;
    end;
   end else begin
    GetMem(fPoolUnaligned,fPoolSize+(4096*2));
    fPool:=TpvPointer(TpvPtrUInt(TpvPtrUInt(TpvPtrUInt(fPoolUnaligned)+4095) and not 4095));
    FillChar(fPool^,fPoolSize,#0);
   end;
  end;

  OldCount:=length(fUsedBitmap);
  Count:=((fMaxEntityIndex+1)+31) shr 5;
  if OldCount<Count then begin
   SetLength(fUsedBitmap,Count+((Count+1) shr 1));
   for Index:=OldCount to length(fUsedBitmap)-1 do begin
    fUsedBitmap[Index]:=0;
   end;
  end;

  OldCount:=length(fPointers);
  Count:=fMaxEntityIndex+1;
  if OldCount<Count then begin
   SetLength(fPointers,Count+((Count+1) shr 1));
   for Index:=OldCount to length(fPointers)-1 do begin
    fPointers[Index]:=nil;
   end;
   fDataPointer:=@fPointers[0];
  end;

  fEntityIndexToComponentPoolIndex[aEntityIndex]:=PoolIndex;
  fComponentPoolIndexToEntityIndex[PoolIndex]:=aEntityIndex;

  fPointers[aEntityIndex]:=TpvPointer(TpvPtrUInt(TpvPtrUInt(fPool)+TpvPtrUInt(TpvPtrUInt(PoolIndex)*TpvPtrUInt(fSize))));

//FillChar(TpvPointer(TpvPtrUInt(TpvPtrUInt(fPool)+TpvPtrUInt(TpvPtrUInt(PoolIndex)*TpvPtrUInt(fSize))))^,fSize,#0);

  Bitmap:=@fUsedBitmap[aEntityIndex shr 5];
  Bitmap^:=Bitmap^ or TpvUInt32(TpvUInt32(1) shl TpvUInt32(aEntityIndex and 31));

  result:=true;

 end;

end;

function TpvEntityComponentSystem.TComponent.FreeComponentFromEntityIndex(const aEntityIndex:TpvSizeInt):boolean;
var PoolIndex,OtherPoolIndex,OtherEntityID:longint;
    Mask:TpvUInt32;
    Bitmap:PpvUInt32;
begin
 result:=false;
 Bitmap:=@fUsedBitmap[aEntityIndex shr 5];
 Mask:=TpvUInt32(TpvUInt32(1) shl TpvUInt32(aEntityIndex and 31));
 if (aEntityIndex>=0) and
    (aEntityIndex<=fMaxEntityIndex) and
    ((Bitmap^ and Mask)<>0) and
    (fEntityIndexToComponentPoolIndex[aEntityIndex]>=0) then begin
  Bitmap^:=Bitmap^ and not Mask;
  PoolIndex:=fEntityIndexToComponentPoolIndex[aEntityIndex];
  FinalizeComponentByPoolIndex(PoolIndex);
  fPointers[aEntityIndex]:=nil;
  dec(fPoolIndexCounter);
  if fPoolIndexCounter>0 then begin
   OtherPoolIndex:=fPoolIndexCounter;
   OtherEntityID:=fComponentPoolIndexToEntityIndex[OtherPoolIndex];
   fEntityIndexToComponentPoolIndex[OtherEntityID]:=PoolIndex;
   fComponentPoolIndexToEntityIndex[PoolIndex]:=OtherEntityID;
   fComponentPoolIndexToEntityIndex[OtherPoolIndex]:=-1;
   Move(TpvPointer(TpvPtrUInt(TpvPtrUInt(fPool)+TpvPtrUInt(TpvPtrUInt(OtherPoolIndex)*TpvPtrUInt(fSize))))^,
        TpvPointer(TpvPtrUInt(TpvPtrUInt(fPool)+TpvPtrUInt(TpvPtrUInt(PoolIndex)*TpvPtrUInt(fSize))))^,
        fSize);
   fPointers[OtherEntityID]:=TpvPointer(TpvPtrUInt(TpvPtrUInt(fPool)+TpvPtrUInt(TpvPtrUInt(PoolIndex)*TpvPtrUInt(fSize))));
  end else begin
   fComponentPoolIndexToEntityIndex[PoolIndex]:=-1;
  end;
  fEntityIndexToComponentPoolIndex[aEntityIndex]:=-1;
  inc(fCountFrees);
  if fCountFrees>(fPoolIndexCounter shr 2) then begin
   fNeedToDefragment:=true;
  end;
  result:=true;
 end;
end;

{ TpvEntityComponentSystem.TEntity }

function TpvEntityComponentSystem.TEntity.GetActive:boolean;
begin
 result:=TFlag.Active in fFlags;
end;

procedure TpvEntityComponentSystem.TEntity.SetActive(const aActive:boolean);
begin
 if aActive<>(TFlag.Active in fFlags) then begin
  if aActive then begin
   Include(fFlags,TFlag.Active);
  end else begin
   Exclude(fFlags,TFlag.Active);
  end;
 end;
end;

procedure TpvEntityComponentSystem.TEntity.AddComponentToEntity(const aComponentID:TComponentID);
var BitmapIndex,BitIndex,OldCount:TpvSizeInt;
begin
 BitmapIndex:=aComponentID shr 5;
 BitIndex:=aComponentID and 31;
 fCountComponents:=Max(fCountComponents,aComponentID+1);
 if length(fComponentsBitmap)<=BitmapIndex then begin
  OldCount:=length(fComponentsBitmap);
  SetLength(fComponentsBitmap,(BitmapIndex+1)+((BitmapIndex+2) shr 1));
  FillChar(fComponentsBitmap[OldCount],(length(fComponentsBitmap)-OldCount)*SizeOf(UInt32),#0);
 end;
 fComponentsBitmap[BitIndex]:=fComponentsBitmap[BitIndex] or (TpvUInt32(1) shl BitIndex);
end;

procedure TpvEntityComponentSystem.TEntity.RemoveComponentFromEntity(const aComponentID:TComponentID);
var Index,BitmapIndex,BitIndex,OldCount:TpvSizeInt;
begin
 BitmapIndex:=aComponentID shr 5;
 BitIndex:=aComponentID and 31;
 fCountComponents:=Max(fCountComponents,aComponentID+1);
 if length(fComponentsBitmap)<=BitmapIndex then begin
  OldCount:=length(fComponentsBitmap);
  SetLength(fComponentsBitmap,(BitmapIndex+1)+((BitmapIndex+2) shr 1));
  FillChar(fComponentsBitmap[OldCount],(length(fComponentsBitmap)-OldCount)*SizeOf(UInt32),#0);
 end;
 fComponentsBitmap[BitIndex]:=fComponentsBitmap[BitIndex] and not (TpvUInt32(1) shl BitIndex);
end;

procedure TpvEntityComponentSystem.TEntity.Assign(const aFrom:TEntity;const aAssignOp:TEntityAssignOp=TEntityAssignOp.Replace;const aEntityIDs:TEntityIDDynamicArray=nil;const aDoRefresh:boolean=true);
var EntityComponentBitmapIndex,EntityComponentIndex:TpvInt32;
    EntityComponentBitmapValue:TpvUInt32;
    EntityComponent:TpvEntityComponentSystem.TComponent;
    EntityComponentID:TpvEntityComponentSystem.TComponentID;
    a,b:TpvPointer;
begin

 for EntityComponentBitmapIndex:=0 to length(aFrom.fComponentsBitmap)-1 do begin
  EntityComponentBitmapValue:=aFrom.fComponentsBitmap[EntityComponentBitmapIndex];
  while EntityComponentBitmapValue<>0 do begin
   EntityComponentIndex:=TPasMPMath.BitScanForward32(EntityComponentBitmapValue);
   EntityComponentBitmapValue:=EntityComponentBitmapValue and not (EntityComponentBitmapValue-1);
   if EntityComponentIndex<fWorld.fComponents.Count then begin
    EntityComponent:=fWorld.fComponents[EntityComponentIndex];
    if assigned(EntityComponent) then begin
     EntityComponentID:=EntityComponent.fRegisteredComponentType.fID;
     if not HasComponent(EntityComponentID) then begin
      AddComponent(EntityComponentID);
      fWorld.Refresh;
     end;
     a:=EntityComponent.GetComponentByEntityIndex(aFrom.fID.Index);
     b:=EntityComponent.GetComponentByEntityIndex(fID.Index);
     Move(a^,b^,EntityComponent.RegisteredComponentType.Size);
    end;
   end;
  end;
 end;

 if aAssignOp=TEntityAssignOp.Replace then begin
  for EntityComponentBitmapIndex:=0 to length(fComponentsBitmap)-1 do begin
   EntityComponentBitmapValue:=fComponentsBitmap[EntityComponentBitmapIndex];
   while EntityComponentBitmapValue<>0 do begin
    EntityComponentIndex:=TPasMPMath.BitScanForward32(EntityComponentBitmapValue);
    EntityComponentBitmapValue:=EntityComponentBitmapValue and not (EntityComponentBitmapValue-1);
    if EntityComponentIndex<fWorld.fComponents.Count then begin
     EntityComponentID:=EntityComponent.fRegisteredComponentType.fID;
     if not aFrom.HasComponent(EntityComponentID) then begin
      RemoveComponent(EntityComponentID);
     end;
    end;
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
              
procedure TpvEntityComponentSystem.TEntity.SynchronizeToPrefab;
begin
end;

procedure TpvEntityComponentSystem.TEntity.Activate;
begin
 if assigned(fWorld) then begin
  fWorld.ActivateEntity(fID);
 end;
end;

procedure TpvEntityComponentSystem.TEntity.Deactivate;
begin
 if assigned(fWorld) then begin
  fWorld.DeactivateEntity(fID);
 end;
end;

procedure TpvEntityComponentSystem.TEntity.Kill;
begin
 if assigned(fWorld) then begin
  fWorld.KillEntity(fID);
 end;
end;

function TpvEntityComponentSystem.TEntity.SerializeToJSON:TPasJSONItemObject;
var ComponentBitmapIndex,ComponentIndex:TpvSizeInt;
    ComponentBitmapValue:TpvUInt32;
    ComponentObjectItem:TPasJSONItemObject;
    Component:TpvEntityComponentSystem.TComponent;
    ComponentID:TpvEntityComponentSystem.TComponentID;
    ComponentData:Pointer;
begin

 result:=TPasJSONItemObject.Create;

 ComponentObjectItem:=TPasJSONItemObject.Create;
 try
  for ComponentBitmapIndex:=0 to length(fComponentsBitmap)-1 do begin
   ComponentBitmapValue:=fComponentsBitmap[ComponentBitmapIndex];
   while ComponentBitmapValue<>0 do begin
    ComponentIndex:=TPasMPMath.BitScanForward32(ComponentBitmapValue);
    ComponentBitmapValue:=ComponentBitmapValue and not (ComponentBitmapValue-1);
    if ComponentIndex<fWorld.fComponents.Count then begin
     ComponentID:=Component.fRegisteredComponentType.fID;
     if HasComponent(ComponentID) then begin
      ComponentData:=Component.GetComponentByEntityIndex(fID.Index);
      result.Add(Component.RegisteredComponentType.fName,Component.RegisteredComponentType.SerializeToJSON(ComponentData,fWorld));
     end;
    end;
   end;
  end;
 finally
  result.Add('components',ComponentObjectItem);
 end;

end;

procedure TpvEntityComponentSystem.TEntity.UnserializeFromJSON;
var Index:TpvSizeInt;
    RootObjectItem,ComponentsObjectItem:TPasJSONItemObject;
    ComponentsItem,ComponentDataItem:TPasJSONItem;
    ComponentID:TpvEntityComponentSystem.TComponentID;
    ComponentData:Pointer;
    ComponentName:TpvUTF8String;
    RegisteredComponentType:TRegisteredComponentType;
begin
 if assigned(aJSONRootItem) and (aJSONRootItem is TPasJSONItemObject) then begin
  RootObjectItem:=TPasJSONItemObject(aJSONRootItem);
  ComponentsItem:=RootObjectItem.Properties['components'];
  if assigned(ComponentsItem) and (ComponentsItem is TPasJSONItemObject) then begin
   ComponentsObjectItem:=TPasJSONItemObject(ComponentsItem);
   for Index:=0 to ComponentsObjectItem.Count-1 do begin
    ComponentName:=ComponentsObjectItem.Keys[Index];
    ComponentDataItem:=ComponentsObjectItem.Values[Index];
    if (length(ComponentName)>0) and assigned(ComponentDataItem) and (ComponentDataItem is TPasJSONItemObject) then begin
     RegisteredComponentType:=TpvEntityComponentSystem.RegisteredComponentTypeNameHashMap[ComponentName];
     if assigned(RegisteredComponentType) then begin
      ComponentID:=RegisteredComponentType.fID;
      if ComponentID<fWorld.fComponents.Count then begin
       ComponentData:=fWorld.AddComponentWithDataToEntity(fID,ComponentID);
       if assigned(ComponentData) then begin
        RegisteredComponentType.UnserializeFromJSON(ComponentDataItem,ComponentData,fWorld);
       end;
      end;
     end;
    end;
   end;
  end;
 end;
end;

procedure TpvEntityComponentSystem.TEntity.AddComponent(const aComponentID:TComponentID;const aData:Pointer;const aDataSize:TpvSizeInt);
begin
 if assigned(fWorld) then begin
  fWorld.AddComponentToEntity(fID,aComponentID,aData,aDataSize);
 end;
end;

function TpvEntityComponentSystem.TEntity.AddComponentWithData(const aComponentID:TComponentID):Pointer;
begin
 if assigned(fWorld) then begin
  result:=fWorld.AddComponentWithDataToEntity(fID,aComponentID);
 end else begin
  result:=nil;
 end;
end;

procedure TpvEntityComponentSystem.TEntity.RemoveComponent(const aComponentID:TComponentID);
begin
 if assigned(fWorld) then begin
  fWorld.RemoveComponentFromEntity(fID,aComponentID);
 end;
end;

function TpvEntityComponentSystem.TEntity.HasComponent(const aComponentID:TComponentID):boolean;
begin
 result:=assigned(fWorld) and World.HasEntityComponent(fID,aComponentID);
end;

function TpvEntityComponentSystem.TEntity.GetComponent(const aComponentID:TComponentID):TpvEntityComponentSystem.TComponent;
begin
 if assigned(fWorld) and World.HasEntityComponent(fID,aComponentID) then begin
  result:=fWorld.fComponents[aComponentID];
 end else begin
  result:=nil;
 end;
end;

{ TpvEntityComponentSystem.TEventRegistration }

constructor TpvEntityComponentSystem.TEventRegistration.Create(const aEventID:TpvEntityComponentSystem.TEventID;const aName:TpvUTF8String);
begin
 inherited Create;
 fEventID:=aEventID;
 fName:=aName;
 fActive:=false;
 fLock:=TPasMPMultipleReaderSingleWriterLock.Create;
 fSystems:=TSystemList.Create;
 fSystems.OwnsObjects:=false;
 fEventHandlers:=nil;
 fCountEventHandlers:=0;
end;

destructor TpvEntityComponentSystem.TEventRegistration.Destroy;
begin
 fName:='';
 fEventHandlers:=nil;
 FreeAndNil(fSystems);
 FreeAndNil(fLock);
 inherited Destroy;
end;

procedure TpvEntityComponentSystem.TEventRegistration.Clear;
begin
 fLock.AcquireWrite;
 try
  fName:='';
  fActive:=false;
  fSystems.Clear;
  fEventHandlers:=nil;
  fCountEventHandlers:=0;
 finally
  fLock.ReleaseWrite;
 end;
end;

procedure TpvEntityComponentSystem.TEventRegistration.AddSystem(const aSystem:TSystem);
begin
 fLock.AcquireRead;
 try
  if fSystems.IndexOf(aSystem)<0 then begin
   fLock.ReadToWrite;
   try
    fSystems.Add(aSystem);
   finally
    fLock.WriteToRead;
   end;
  end;
 finally
  fLock.ReleaseRead;
 end;
end;

procedure TpvEntityComponentSystem.TEventRegistration.RemoveSystem(const aSystem:TSystem);
var Index:TpvSizeInt;
begin
 fLock.AcquireRead;
 try
  Index:=fSystems.IndexOf(aSystem);
  if Index>=0 then begin
   fLock.ReadToWrite;
   try
    fSystems.Delete(Index);
   finally
    fLock.WriteToRead;
   end;
  end;
 finally
  fLock.ReleaseRead;
 end;
end;

procedure TpvEntityComponentSystem.TEventRegistration.AddEventHandler(const aEventHandler:TEventHandler);
var Index:TpvSizeInt;
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
     SetLength(fEventHandlers,fCountEventHandlers+((fCountEventHandlers+1) shr 1));
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

procedure TpvEntityComponentSystem.TEventRegistration.RemoveEventHandler(const aEventHandler:TEventHandler);
var Index:TpvSizeInt;
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
      Move(fEventHandlers[Index+1],fEventHandlers[Index],fCountEventHandlers*SizeOf(TEventHandler)); // for to be keep the ordering
//    fEventHandlers[Index]:=fEventHandlers[fCountEventHandlers]; // for to be faster, but with changing the ordering of the last item to the deleted item position
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

{ TpvEntityComponentSystem.TSystemChoreography }

constructor TpvEntityComponentSystem.TSystemChoreography.Create(const aWorld:TWorld);
begin
 inherited Create;
 fWorld:=aWorld;
 fPasMPInstance:=fWorld.fPasMPInstance;
 fChoreographySteps:=nil;
 fChoreographyStepJobs:=nil;
 fCountChoreographySteps:=0;
 fSortedSystemList:=TSystemList.Create;
 fSortedSystemList.OwnsObjects:=false;
end;

destructor TpvEntityComponentSystem.TSystemChoreography.Destroy;
begin
 fChoreographySteps:=nil;
 fChoreographyStepJobs:=nil;
 FreeAndNil(fSortedSystemList);
 inherited Destroy;
end;

procedure TpvEntityComponentSystem.TSystemChoreography.Build;
var Systems:TSystemList;
    Index,OtherIndex,SystemIndex:TpvInt32;
    Done,Stop:boolean;
    System,OtherSystem:TSystem;
    ChoreographyStep:PSystemChoreographyStep;
begin
 Systems:=fSortedSystemList;

 Systems.Clear;

 // Fill in
 for Index:=0 to fWorld.fSystems.Count-1 do begin
  Systems.Add(fWorld.fSystems.Items[Index]);
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
      raise ESystemCircularDependency.Create(System.ClassName+' have circular dependency with '+OtherSystem.ClassName);
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
   Stop:=TpvEntityComponentSystem.TSystem.TFlag.Secluded in OtherSystem.fFlags;
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
      System:TpvEntityComponentSystem.TSystem;
      FirstEventIndex:TPasMPSizeInt;
      LastEventIndex:TPasMPSizeInt;
     end;

function TpvEntityComponentSystem.TSystemChoreography.CreateProcessEventsJob(const aSystem:TSystem;const aFirstEventIndex,aLastEventIndex:TPasMPSizeInt;const aParentJob:PPasMPJob):PPasMPJob;
var Data:PSystemChoreographyProcessEventsJobData;
begin
 result:=fPasMPInstance.Acquire(ProcessEventsJobFunction,nil,nil);
 Data:=PSystemChoreographyProcessEventsJobData(pointer(@result^.Data));
 Data^.System:=aSystem;
 Data^.FirstEventIndex:=aFirstEventIndex;
 Data^.LastEventIndex:=aFirstEventIndex;
end;

procedure TpvEntityComponentSystem.TSystemChoreography.ProcessEventsJobFunction(const aJob:PPasMPJob;const aThreadIndex:TpvInt32);
var Data:PSystemChoreographyProcessEventsJobData;
    MidEventIndex,Count:TpvSizeInt;
begin
 Data:=@aJob^.Data;
 if Data^.FirstEventIndex<=Data^.LastEventIndex then begin
  Count:=Data^.LastEventIndex-Data^.FirstEventIndex;
  if (fPasMPInstance.CountJobWorkerThreads<2) or
     (not (TpvEntityComponentSystem.TSystem.TFlag.ParallelProcessing in Data.System.fFlags)) or
     ((Count<=Data^.System.fEventGranularity) or (Count<4)) then begin
   Data^.System.ProcessEvents(Data^.FirstEventIndex,Data^.LastEventIndex);
  end else begin
   MidEventIndex:=Data^.FirstEventIndex+((Data^.LastEventIndex-Data^.FirstEventIndex) shr 1);
   fPasMPInstance.Invoke(
    [
     CreateProcessEventsJob(Data^.System,Data^.FirstEventIndex,MidEventIndex-1,aJob),
     CreateProcessEventsJob(Data^.System,MidEventIndex,Data^.LastEventIndex,aJob)
    ]
   );
  end;
 end;
end;

procedure TpvEntityComponentSystem.TSystemChoreography.ChoreographyStepProcessEventsJobFunction(const aJob:PPasMPJob;const aThreadIndex:TpvInt32);
var Data:PSystemChoreographyStepProcessEventsJobData;
    ChoreographyStep:PSystemChoreographyStep;
    SystemIndex:TpvSizeInt;
    System:TpvEntityComponentSystem.TSystem;
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
 fPasMPInstance.Invoke(ChoreographyStep^.Jobs);
end;

procedure TpvEntityComponentSystem.TSystemChoreography.ChoreographyProcessEventsJobFunction(const aJob:PPasMPJob;const aThreadIndex:TpvInt32);
var ChoreographyStepJob:PPasMPJob;
    ChoreographyStepJobData:PSystemChoreographyStepProcessEventsJobData;
    StepIndex:TpvSizeInt;
    ChoreographyStep:PSystemChoreographyStep;
begin
 for StepIndex:=0 to fCountChoreographySteps-1 do begin
  ChoreographyStep:=@fChoreographySteps[StepIndex];
  ChoreographyStepJob:=fPasMPInstance.Acquire(ChoreographyStepProcessEventsJobFunction,nil,nil);
  ChoreographyStepJobData:=PSystemChoreographyStepProcessEventsJobData(pointer(@ChoreographyStepJob^.Data));
  ChoreographyStepJobData^.ChoreographyStep:=ChoreographyStep;
  fChoreographyStepJobs[StepIndex]:=ChoreographyStepJob;
  fPasMPInstance.Invoke(fChoreographyStepJobs[StepIndex]);
 end;
end;

procedure TpvEntityComponentSystem.TSystemChoreography.ProcessEvents;
begin
 fPasMPInstance.Invoke(fPasMPInstance.Acquire(ChoreographyProcessEventsJobFunction,nil,nil));
end;

procedure TpvEntityComponentSystem.TSystemChoreography.InitializeUpdate;
var StepIndex,SystemIndex:TpvSizeInt;
    ChoreographyStep:PSystemChoreographyStep;
    System:TSystem;
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
      System:TpvEntityComponentSystem.TSystem;
      FirstEntityIndex:TpvSizeInt;
      LastEntityIndex:TpvSizeInt;
     end;

function TpvEntityComponentSystem.TSystemChoreography.CreateUpdateEntitiesJob(const aSystem:TSystem;const aFirstEntityIndex,aLastEntityIndex:TPasMPSizeInt;const aParentJob:PPasMPJob):PPasMPJob;
var Data:PSystemChoreographyUpdateEntitiesJobData;
begin
 result:=fPasMPInstance.Acquire(UpdateEntitiesJobFunction,nil,nil);
 Data:=PSystemChoreographyUpdateEntitiesJobData(pointer(@result^.Data));
 Data^.System:=aSystem;
 Data^.FirstEntityIndex:=aFirstEntityIndex;
 Data^.LastEntityIndex:=aLastEntityIndex;
end;

procedure TpvEntityComponentSystem.TSystemChoreography.UpdateEntitiesJobFunction(const aJob:PPasMPJob;const aThreadIndex:TpvInt32);
var Data:PSystemChoreographyUpdateEntitiesJobData;
    MidEntityIndex,Count:TpvSizeInt;
begin
 Data:=@aJob^.Data;
 if Data^.FirstEntityIndex<=Data^.LastEntityIndex then begin
  Count:=Data^.LastEntityIndex-Data^.FirstEntityIndex;
  if (TpvEntityComponentSystem.TSystem.TFlag.OwnUpdate in Data.System.fFlags) or
     (not (TpvEntityComponentSystem.TSystem.TFlag.ParallelProcessing in Data.System.fFlags)) or
     (fPasMPInstance.CountJobWorkerThreads<2) or
     ((Count<=Data^.System.fEntityGranularity) or (Count<4)) then begin
   if TpvEntityComponentSystem.TSystem.TFlag.OwnUpdate in Data.System.fFlags then begin
    Data^.System.Update;
   end else begin
    Data^.System.UpdateEntities(Data^.FirstEntityIndex,Data^.LastEntityIndex);
   end;
  end else begin
   MidEntityIndex:=Data^.FirstEntityIndex+((Data^.LastEntityIndex-Data^.FirstEntityIndex) shr 1);
   fPasMPInstance.Invoke(
    [
     CreateUpdateEntitiesJob(Data^.System,Data^.FirstEntityIndex,MidEntityIndex-1,aJob),
     CreateUpdateEntitiesJob(Data^.System,MidEntityIndex,Data^.LastEntityIndex,aJob)
    ]
   );
  end;
 end;
end;

procedure TpvEntityComponentSystem.TSystemChoreography.ChoreographyStepUpdateEntitiesJobFunction(const aJob:PPasMPJob;const aThreadIndex:TpvInt32);
var Data:PSystemChoreographyStepUpdateEntitiesJobData;
    ChoreographyStep:PSystemChoreographyStep;
    SystemIndex:TpvSizeInt;
    System:TSystem;
begin
 Data:=@aJob^.Data;
 ChoreographyStep:=Data^.ChoreographyStep;
 for SystemIndex:=0 to ChoreographyStep^.Count-1 do begin
  System:=ChoreographyStep^.Systems[SystemIndex];
  ChoreographyStep^.Jobs[SystemIndex]:=CreateUpdateEntitiesJob(System,0,System.fCountEntities-1,aJob);
 end;
 fPasMPInstance.Invoke(ChoreographyStep^.Jobs);
end;

procedure TpvEntityComponentSystem.TSystemChoreography.ChoreographyUpdateEntitiesJobFunction(const aJob:PPasMPJob;const aThreadIndex:TpvInt32);
var ChoreographyStepJob:PPasMPJob;
    ChoreographyStepJobData:PSystemChoreographyStepUpdateEntitiesJobData;
    StepIndex:TpvSizeInt;
    ChoreographyStep:PSystemChoreographyStep;
begin
 for StepIndex:=0 to fCountChoreographySteps-1 do begin
  ChoreographyStep:=@fChoreographySteps[StepIndex];
  ChoreographyStepJob:=fPasMPInstance.Acquire(ChoreographyStepUpdateEntitiesJobFunction,nil,nil);
  ChoreographyStepJobData:=PSystemChoreographyStepUpdateEntitiesJobData(pointer(@ChoreographyStepJob^.Data));
  ChoreographyStepJobData^.ChoreographyStep:=ChoreographyStep;
  fChoreographyStepJobs[StepIndex]:=ChoreographyStepJob;
  fPasMPInstance.Invoke(fChoreographyStepJobs[StepIndex]);
 end;
end;

procedure TpvEntityComponentSystem.TSystemChoreography.Update;
begin
 fPasMPInstance.Invoke(fPasMPInstance.Acquire(ChoreographyUpdateEntitiesJobFunction,nil,nil));
end;

procedure TpvEntityComponentSystem.TSystemChoreography.FinalizeUpdate;
var StepIndex,SystemIndex:TpvSizeInt;
    ChoreographyStep:PSystemChoreographyStep;
    System:TSystem;
begin
 for StepIndex:=0 to fCountChoreographySteps-1 do begin
  ChoreographyStep:=@fChoreographySteps[StepIndex];
  for SystemIndex:=0 to ChoreographyStep^.Count-1 do begin
   System:=ChoreographyStep^.Systems[SystemIndex];
   System.FinalizeUpdate;
  end;
 end;
end;

{ TpvEntityComponentSystem.TSystem }

constructor TpvEntityComponentSystem.TSystem.Create(const aWorld:TWorld);
begin
 inherited Create;
 fWorld:=aWorld;
 fFlags:=[];
 fEntities:=TEntityIDList.Create;
 fRequiredComponents:=TComponentIDList.Create;
 fExcludedComponents:=TComponentIDList.Create;
 fRequiresSystems:=TSystemList.Create;
 fRequiresSystems.OwnsObjects:=false;
 fConflictsWithSystems:=TSystemList.Create;
 fConflictsWithSystems.OwnsObjects:=false;
 fNeedToSort:=true;
 fEventsCanBeParallelProcessed:=false;
 fEventGranularity:=256;
 fEntityGranularity:=256;
 fCountEntities:=0;
 fEvents:=nil;
 fCountEvents:=0;
end;

destructor TpvEntityComponentSystem.TSystem.Destroy;
begin
 FreeAndNil(fExcludedComponents);
 FreeAndNil(fRequiredComponents);
 FreeAndNil(fRequiresSystems);
 FreeAndNil(fConflictsWithSystems);
 FreeAndNil(fEntities);
 fEvents:=nil;
 inherited Destroy;
end;

procedure TpvEntityComponentSystem.TSystem.Added;
begin
end;

procedure TpvEntityComponentSystem.TSystem.Removed;
begin
end;

procedure TpvEntityComponentSystem.TSystem.SubscribeToEvent(const aEventID:TEventID);
var EventRegistration:TEventRegistration;
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

procedure TpvEntityComponentSystem.TSystem.UnsubscribeFromEvent(const aEventID:TEventID);
var EventRegistration:TEventRegistration;
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

function TpvEntityComponentSystem.TSystem.HaveDependencyOnSystem(const aOtherSystem:TSystem):boolean;
begin
 result:=assigned(aOtherSystem) and (fRequiresSystems.IndexOf(aOtherSystem)>=0);
end;

function TpvEntityComponentSystem.TSystem.HaveDependencyOnSystemOrViceVersa(const aOtherSystem:TSystem):boolean;
begin
 result:=assigned(aOtherSystem) and ((fRequiresSystems.IndexOf(aOtherSystem)>=0) or (aOtherSystem.fRequiresSystems.IndexOf(self)>=0));
end;

function TpvEntityComponentSystem.TSystem.HaveCircularDependencyWithSystem(const aOtherSystem:TSystem):boolean;
var VisitedList,StackList:TList;
    Index:TpvSizeInt;
    System,RequiredSystem:TSystem;
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

function TpvEntityComponentSystem.TSystem.HaveConflictWithSystem(const aOtherSystem:TSystem):boolean;
begin
 result:=assigned(aOtherSystem) and (fConflictsWithSystems.IndexOf(aOtherSystem)>=0);
end;

function TpvEntityComponentSystem.TSystem.HaveConflictWithSystemOrViceVersa(const aOtherSystem:TSystem):boolean;
begin
 result:=assigned(aOtherSystem) and ((fConflictsWithSystems.IndexOf(aOtherSystem)>=0) or (aOtherSystem.fConflictsWithSystems.IndexOf(self)>=0));
end;

procedure TpvEntityComponentSystem.TSystem.RequiresSystem(const aSystem:TSystem);
begin
 if fRequiresSystems.IndexOf(aSystem)<0 then begin
  fRequiresSystems.Add(aSystem);
 end;
end;

procedure TpvEntityComponentSystem.TSystem.ConflictsWithSystem(const aSystem:TSystem);
begin
 if fConflictsWithSystems.IndexOf(aSystem)<0 then begin
  fConflictsWithSystems.Add(aSystem);
 end;
end;

procedure TpvEntityComponentSystem.TSystem.AddRequiredComponent(const aComponentID:TComponentID);
begin
 if fRequiredComponents.IndexOf(aComponentID)<0 then begin
  fRequiredComponents.Add(aComponentID);
 end;
end;

procedure TpvEntityComponentSystem.TSystem.AddExcludedComponent(const aComponentID:TComponentID);
begin
 if fExcludedComponents.IndexOf(aComponentID)<0 then begin
  fExcludedComponents.Add(aComponentID);
 end;
end;

function TpvEntityComponentSystem.TSystem.FitsEntityToSystem(const aEntityID:TEntityID):boolean;
var Index:TpvSizeInt;
begin
 result:=fWorld.HasEntity(aEntityID);
 if result then begin
  for Index:=0 to fExcludedComponents.Count-1 do begin
   if fWorld.HasEntityComponent(aEntityID,fExcludedComponents.Items[Index]) then begin
    result:=false;
    exit;
   end;
  end;
  for Index:=0 to fRequiredComponents.Count-1 do begin
   if not fWorld.HasEntityComponent(aEntityID,fRequiredComponents.Items[Index]) then begin
    result:=false;
    exit;
   end;
  end;
 end;
end;

function TpvEntityComponentSystem.TSystem.AddEntityToSystem(const aEntityID:TEntityID):boolean;
begin
 if fEntities.IndexOf(aEntityID)<0 then begin
  fEntities.Add(aEntityID);
  inc(fCountEntities);
  fNeedToSort:=true;
  result:=true;
 end else begin
  result:=false;
 end;
end;

function TpvEntityComponentSystem.TSystem.RemoveEntityFromSystem(const aEntityID:TEntityID):boolean;
var Index:TpvSizeInt;
begin
 Index:=fEntities.IndexOf(aEntityID);
 if Index>=0 then begin
  fEntities.Delete(Index);
  dec(fCountEntities);
  result:=true;
 end else begin
  result:=false;
 end;
end;

procedure TpvEntityComponentSystem.TSystem.SortEntities;
begin
 if fNeedToSort then begin
  fNeedToSort:=false;
  fEntities.Sort;
 end;
end;

procedure TpvEntityComponentSystem.TSystem.Finish;
begin
end;

procedure TpvEntityComponentSystem.TSystem.ProcessEvent(const aEvent: TEvent);
begin
end;

procedure TpvEntityComponentSystem.TSystem.ProcessEvents(const aFirstEventIndex,aLastEventIndex:TpvSizeInt);
var EntityIndex:TpvSizeInt;
    Event:TpvEntityComponentSystem.PEvent;
begin
 for EntityIndex:=aFirstEventIndex to aLastEventIndex do begin
  Event:=fEvents[EntityIndex];
  if assigned(Event) then begin
   ProcessEvent(Event^);
  end;
 end;
end;

procedure TpvEntityComponentSystem.TSystem.InitializeUpdate;
begin
end;

procedure TpvEntityComponentSystem.TSystem.Update;
begin
end;

procedure TpvEntityComponentSystem.TSystem.UpdateEntities(const aFirstEntityIndex,aLastEntityIndex:TpvSizeInt);
begin
end;

procedure TpvEntityComponentSystem.TSystem.FinalizeUpdate;
begin
end;

procedure TpvEntityComponentSystem.TSystem.Store;
begin
end;

procedure TpvEntityComponentSystem.TSystem.Interpolate(const aAlpha:TpvDouble);
begin
end;

{ TpvEntityComponentSystem.TWorldEntityComponentSetQuery }

constructor TpvEntityComponentSystem.TWorldEntityComponentSetQuery.Create(const aWorld:TWorld;const aRequiredComponents:array of TpvEntityComponentSystem.TComponentID;const aExcludedComponents:array of TpvEntityComponentSystem.TComponentID);
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
  MaxComponentIDPlusOne:=Max(MaxComponentIDPlusOne,TpvSizeInt(aRequiredComponents[Index]+1));
 end;
 for Index:=0 to length(aExcludedComponents)-1 do begin
  MaxComponentIDPlusOne:=Max(MaxComponentIDPlusOne,TpvSizeInt(aExcludedComponents[Index]+1));
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

constructor TpvEntityComponentSystem.TWorldEntityComponentSetQuery.Create(const aWorld:TWorld;const aRequiredComponents:array of TpvEntityComponentSystem.TComponent;const aExcludedComponents:array of TpvEntityComponentSystem.TComponent);
var Index:TpvSizeInt;
    RequiredComponents:array of TpvEntityComponentSystem.TComponentID;
    ExcludedComponents:array of TpvEntityComponentSystem.TComponentID;
begin
 RequiredComponents:=nil;
 try
  ExcludedComponents:=nil;
  try
   SetLength(RequiredComponents,length(aRequiredComponents));
   for Index:=0 to length(aRequiredComponents)-1 do begin
    RequiredComponents[Index]:=aRequiredComponents[Index].fRegisteredComponentType.fID;
   end;
   SetLength(ExcludedComponents,length(aExcludedComponents));
   for Index:=0 to length(aExcludedComponents)-1 do begin
    ExcludedComponents[Index]:=aExcludedComponents[Index].fRegisteredComponentType.fID;
   end;
   Create(aWorld,RequiredComponents,ExcludedComponents);
  finally
   ExcludedComponents:=nil;
  end;
 finally
  RequiredComponents:=nil;
 end;
end;

destructor TpvEntityComponentSystem.TWorldEntityComponentSetQuery.Destroy;
begin
 fRequiredComponentBitmap:=nil;
 fExcludedComponentBitmap:=nil;
 fEntityIDs:=nil;
 inherited Destroy;
end;

procedure TpvEntityComponentSystem.TWorldEntityComponentSetQuery.Update;
var Index,BitmapEntityIndex,EntityIndex,OtherIndex,CommonBitmapSize,CommonComponentBitmapSize:TpvSizeInt;
    Value:TpvUInt64;
    EntityUsedBitmapValue:TpvUInt32;
    Entity:TpvEntityComponentSystem.PEntity;
    OK:boolean;
begin

 if fGeneration<>fWorld.fGeneration then begin

  try

   CommonBitmapSize:=Min(length(fRequiredComponentBitmap),length(fExcludedComponentBitmap));

   fEntityIDs.ClearNoFree;

   BitmapEntityIndex:=0;

   // Iterate over all used entity bitmap values with bittwiddling per bit scan forward to find the next set lowest bit
   for Index:=0 to Min(length(fWorld.fEntityUsedBitmap),(fWorld.fMaxEntityIndex+31) shr 5)-1 do begin

    EntityUsedBitmapValue:=fWorld.fEntityUsedBitmap[Index];

    // Iterate over all set bits in the used entity bitmap value
    while EntityUsedBitmapValue<>0 do begin

     EntityIndex:=BitmapEntityIndex+TPasMPMath.BitScanForward32(EntityUsedBitmapValue);
     EntityUsedBitmapValue:=EntityUsedBitmapValue and (EntityUsedBitmapValue-1);

     Entity:=@fWorld.fEntities[EntityIndex];

     OK:=true;

     CommonComponentBitmapSize:=Min(CommonBitmapSize,length(Entity^.fComponentsBitmap));

     for OtherIndex:=0 to CommonComponentBitmapSize-1 do begin
      Value:=Entity^.fComponentsBitmap[OtherIndex];
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
       fEntityIDs.Add(Entity^.fID);
      end;

     end;

    end;

    inc(BitmapEntityIndex,32);

   end;

  finally
   fGeneration:=fWorld.fGeneration;
  end;

 end;

end;

{ TpvEntityComponentSystem.TWorld }

constructor TpvEntityComponentSystem.TWorld.Create(const aPasMPInstance:TPasMP);
var Index:TpvSizeInt;
begin

 inherited Create;

 fSUID:=TpvSUID.Create;

 if assigned(aPasMPInstance) then begin
  fPasMPInstance:=aPasMPInstance;
 end else begin
  fPasMPInstance:=TPasMP.GetGlobalInstance;
 end;

 fGeneration:=0;

 fActive:=false;

 fKilled:=false;

 fLock:=TPasMPMultipleReaderSingleWriterLock.Create;

 fEntitySUIDHashMap:=TpvEntityComponentSystem.TWorld.TSUIDEntityIDPairHashMap.Create(0);

 fReservedEntityHashMapLock:=TPasMPMultipleReaderSingleWriterLock.Create;

 fReservedEntitySUIDHashMap:=TpvEntityComponentSystem.TWorld.TSUIDEntityIDPairHashMap.Create(0);

 fComponents:=TComponentList.Create;
 fComponents.OwnsObjects:=true;

 for Index:=0 to RegisteredComponentTypeList.Count-1 do begin
  fComponents.Add(TpvEntityComponentSystem.TComponent.Create(self,RegisteredComponentTypeList.Items[Index]));
 end;

 fEntities:=nil;

 fEntityLock:=TPasMPMultipleReaderSingleWriterLock.Create;

 fEntityIndexFreeList:=TEntityIndexFreeList.Create;

 fEntityGenerationList:=nil;

 fEntityUsedBitmap:=nil;

 fEntityIndexCounter:=1;

 fMaxEntityIndex:=-1;

 fEventListLock:=TPasMPMultipleReaderSingleWriterLock.Create;

 fEventList:=TList.Create;

 fDelayedEventQueueLock:=TPasMPMultipleReaderSingleWriterLock.Create;

 LinkedListInitialize(@fDelayedEventQueue);

 fEventQueueLock:=TPasMPMultipleReaderSingleWriterLock.Create;

 LinkedListInitialize(@fEventQueue);

 LinkedListInitialize(@fDelayedFreeEventQueue);

 fFreeEventQueueLock:=TPasMPMultipleReaderSingleWriterLock.Create;

 LinkedListInitialize(@fFreeEventQueue);

 fCurrentTime:=0.0;

 fSystems:=TSystemList.Create;
 fSystems.OwnsObjects:=false;

 fSystemUsedMap:=TSystemBooleanPairHashMap.Create(false);

 fSystemChoreography:=TSystemChoreography.Create(self);

 fSystemChoreographyNeedToRebuild:=0;

 fEventInProcessing:=false;

 fEventRegistrationLock:=TPasMPMultipleReaderSingleWriterLock.Create;

 fEventRegistrationList:=TEventRegistrationList.Create;
 fEventRegistrationList.OwnsObjects:=false;

 fFreeEventRegistrationList:=TEventRegistrationList.Create;
 fFreeEventRegistrationList.OwnsObjects:=false;

 fEventRegistrationStringIntegerPairHashMap:=TEventRegistrationStringIntegerPairHashMap.Create(-1);

 fOnEvent:=nil;

 fDelayedManagementEventLock:=TPasMPMultipleReaderSingleWriterLock.Create;

 fDelayedManagementEvents:=nil;

 fCountDelayedManagementEvents:=0;

end;

destructor TpvEntityComponentSystem.TWorld.Destroy;
var Index:TpvSizeInt;
    Event:TpvEntityComponentSystem.PEvent;
begin

 fEventRegistrationList.OwnsObjects:=true;
 FreeAndNil(fEventRegistrationList);

 fFreeEventRegistrationList.OwnsObjects:=true;
 FreeAndNil(fFreeEventRegistrationList);

 FreeAndNil(fEventRegistrationLock);

 FreeAndNil(fEventRegistrationStringIntegerPairHashMap);

 FreeAndNil(fSystemChoreography);

 FreeAndNil(fSystemUsedMap);

 FreeAndNil(fSystems);

 FreeAndNil(fComponents);

 fEntities:=nil;

 FreeAndNil(fEntityIndexFreeList);

 fEntityGenerationList:=nil;

 fEntityUsedBitmap:=nil;

 FreeAndNil(fDelayedManagementEventLock);

 fDelayedManagementEvents:=nil;

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

 FreeAndNil(fEntitySUIDHashMap);

 FreeAndNil(fReservedEntitySUIDHashMap);

 FreeAndNil(fReservedEntityHashMapLock);

 FreeAndNil(fEntityLock);

 FreeAndNil(fLock);

 inherited Destroy;

end;

procedure TpvEntityComponentSystem.TWorld.Kill;
begin
 fKilled:=true;
end;

function TpvEntityComponentSystem.TWorld.CreateEvent(const aName:TpvUTF8String):TEventID;
var EventRegistration:TEventRegistration;
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
    EventRegistration:=TEventRegistration.Create(fEventRegistrationList.Count,aName);
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

procedure TpvEntityComponentSystem.TWorld.DestroyEvent(const aEventID:TEventID);
var EventRegistration:TEventRegistration;
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

function TpvEntityComponentSystem.TWorld.FindEvent(const aName:TpvUTF8String):TEventID;
begin
 fEventRegistrationLock.AcquireRead;
 try
  result:=fEventRegistrationStringIntegerPairHashMap.Values[aName];
 finally
  fEventRegistrationLock.ReleaseRead;
 end;
end;

procedure TpvEntityComponentSystem.TWorld.SubscribeToEvent(const aEventID:TEventID;const aEventHandler:TEventHandler);
var EventRegistration:TEventRegistration;
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

procedure TpvEntityComponentSystem.TWorld.UnsubscribeFromEvent(const aEventID:TEventID;const aEventHandler:TEventHandler);
var EventRegistration:TEventRegistration;
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

procedure TpvEntityComponentSystem.TWorld.AddDelayedManagementEvent(const aDelayedManagementEvent:TDelayedManagementEvent);
var DelayedManagementEventIndex:TpvSizeInt;
begin
 fDelayedManagementEventLock.AcquireWrite;
 try
  DelayedManagementEventIndex:=fCountDelayedManagementEvents;
  inc(fCountDelayedManagementEvents);
  if length(fDelayedManagementEvents)<fCountDelayedManagementEvents then begin
   SetLength(fDelayedManagementEvents,fCountDelayedManagementEvents+((fCountDelayedManagementEvents+1) shr 1));
  end;
  fDelayedManagementEvents[DelayedManagementEventIndex]:=aDelayedManagementEvent;
 finally
  fDelayedManagementEventLock.ReleaseWrite;
 end;
end;

function TpvEntityComponentSystem.TWorld.GetEntityByID(const aEntityID:TpvEntityComponentSystem.TEntityID):TpvEntityComponentSystem.PEntity;
var EntityIndex:TpvInt32;
begin
 EntityIndex:=aEntityID.Index;
 if (EntityIndex>=0) and
    (EntityIndex<=fMaxEntityIndex) and
    ((fEntityUsedBitmap[EntityIndex shr 5] and TpvUInt32(TpvUInt32(1) shl TpvUInt32(EntityIndex and 31)))<>0) then begin
  result:=@fEntities[EntityIndex];
  if result^.fID<>aEntityID then begin
   result:=nil;
  end;
 end else begin
  result:=nil;
 end;
end;

function TpvEntityComponentSystem.TWorld.GetEntityBySUID(const aEntitySUID:TpvSUID):TpvEntityComponentSystem.PEntity;
begin
 result:=nil;
end;

function TpvEntityComponentSystem.TWorld.DoCreateEntity(const aEntityID:TEntityID;const aEntitySUID:TpvSUID):boolean;
var EntityIndex,Index,OldCount,Count:TpvInt32;
    Bitmap:PpvInt32;
    Entity:PEntity;
begin

 result:=false;

 fLock.AcquireRead;
 try

  fLock.ReadToWrite;
  try

   EntityIndex:=aEntityID.Index;

   if fMaxEntityIndex<EntityIndex then begin

    fMaxEntityIndex:=EntityIndex;

    for Index:=0 to fComponents.Count-1 do begin
     fComponents[Index].SetMaxEntities(fMaxEntityIndex);
    end;

    OldCount:=length(fEntities);
    Count:=fEntityIndexCounter;
    if OldCount<Count then begin
     SetLength(fEntities,Count+((Count+1) shr 1));
     for Index:=OldCount to length(fEntities)-1 do begin
      Entity:=@fEntities[Index];
      Entity^.fWorld:=self;
      Entity^.fID:=0;
      Entity^.fFlags:=[];
      Entity^.fSUID:=TpvSUID.Null;
      Entity^.fUnknownData:=nil;
      Entity^.fCountComponents:=0;
      Entity^.fComponentsBitmap:=nil;
     end;
    end;

    OldCount:=length(fEntityGenerationList);
    Count:=fEntityIndexCounter;
    if OldCount<Count then begin
     SetLength(fEntityGenerationList,Count+((Count+1) shr 1));
     for Index:=OldCount to length(fEntityGenerationList)-1 do begin
      fEntityGenerationList[Index]:=0;
     end;
    end;

    OldCount:=length(fEntityUsedBitmap);
    Count:=(fEntityIndexCounter+31) shr 5;
    if OldCount<Count then begin
     SetLength(fEntityUsedBitmap,Count+((Count+1) shr 1));
     for Index:=OldCount to length(fEntityUsedBitmap)-1 do begin
      fEntityUsedBitmap[Index]:=0;
     end;
    end;

   end;

   Bitmap:=@fEntityUsedBitmap[EntityIndex shr 5];
   Bitmap^:=Bitmap^ or TpvUInt32(TpvUInt32(1) shl TpvUInt32(EntityIndex and 31));

   Entity:=@fEntities[EntityIndex];
   Entity^.fWorld:=self;
   Entity^.fID:=aEntityID;
   Entity^.fFlags:=[TEntity.TFlag.Used];
   Entity^.fSUID:=aEntitySUID;
   Entity^.fUnknownData:=nil;
   Entity^.fCountComponents:=0;
   Entity^.fComponentsBitmap:=nil;

   fEntitySUIDHashMap.Add(aEntitySUID,aEntityID);

   result:=true;

  finally
   fLock.WriteToRead;
  end;

 finally
  fLock.ReleaseRead;
 end;

end;

function TpvEntityComponentSystem.TWorld.DoDestroyEntity(const aEntityID:TEntityID):boolean;
var EntityIndex:TpvInt32;
    Index:TpvSizeInt;
    Bitmap:PpvUInt32;
    Mask:TpvUInt32;
    Entity:PEntity;
begin
 fLock.AcquireRead;
 try
  EntityIndex:=aEntityID.Index;
  Bitmap:=@fEntityUsedBitmap[EntityIndex shr 5];
  Mask:=TpvUInt32(TpvUInt32(1) shl TpvUInt32(EntityIndex and 31));
  if (EntityIndex>=0) and (EntityIndex<fEntityIndexCounter) and ((Bitmap^ and Mask)<>0) then begin
   fLock.ReadToWrite;
   try
    Bitmap:=@fEntityUsedBitmap[EntityIndex shr 5]; // the pointer of fEntityIDUsedBitmap could be changed already here by an another CPU thread, so reload it
    Bitmap^:=Bitmap^ and not Mask;
    for Index:=0 to fComponents.Count-1 do begin
     fComponents[Index].FreeComponentFromEntityIndex(EntityIndex);
    end;
    Entity:=@fEntities[EntityIndex];
    fEntitySUIDHashMap.Delete(Entity^.SUID);
    fReservedEntityHashMapLock.AcquireWrite;
    try
     fReservedEntitySUIDHashMap.Delete(Entity^.SUID);
    finally
     fReservedEntityHashMapLock.ReleaseWrite;
    end;
    Entity^.Flags:=[];
    FreeAndNil(Entity^.fUnknownData);
    Entity^.fCountComponents:=0;
    Entity^.fComponentsBitmap:=nil;
    fEntityLock.AcquireWrite;
    try
     fEntityIndexFreeList.Add(EntityIndex);
     inc(fEntityGenerationList[EntityIndex]);
    finally
     fEntityLock.ReleaseWrite;
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

function TpvEntityComponentSystem.TWorld.CreateEntity(const aEntityID:TpvEntityComponentSystem.TEntityID;const aEntitySUID:TpvSUID):TpvEntityComponentSystem.TEntityID;
var DelayedManagementEvent:TDelayedManagementEvent;
    Index,OldCount,Count:TpvSizeInt;
    EntitySUID:PpvSUID;
    AutoGeneratedSUID:TpvSUID;
    SUIDIsUnused:boolean;
begin
 result:=0;
 fReservedEntityHashMapLock.AcquireRead;
 try
  if SUID=TpvSUID.Null then begin
   repeat
    AutoGeneratedSUID:=TpvSUID.Create;
   until not fReservedEntitySUIDHashMap.ExistKey(AutoGeneratedSUID);
   EntitySUID:=@AutoGeneratedSUID;
   SUIDIsUnused:=true;
  end else begin
   EntitySUID:=@SUID;
   SUIDIsUnused:=not fReservedEntitySUIDHashMap.ExistKey(EntitySUID^);
  end;
  if SUIDIsUnused then begin
   result:=aEntityID;
   if aEntityID.Index<=0 then begin
    fReservedEntityHashMapLock.ReadToWrite;
    try
     fEntityLock.AcquireWrite;
     try
      if fEntityIndexFreeList.Count>0 then begin
       result.Index:=fEntityIndexFreeList.Items[fEntityIndexFreeList.Count-1];
       fEntityIndexFreeList.Delete(fEntityIndexFreeList.Count-1);
      end else begin
       result.Index:=fEntityIndexCounter;
       inc(fEntityIndexCounter);
      end;
      OldCount:=length(fEntityGenerationList);
      Count:=fEntityIndexCounter;
      if OldCount<Count then begin
       SetLength(fEntityGenerationList,Count+((Count+1) shr 1));
       for Index:=OldCount to length(fEntityGenerationList)-1 do begin
        fEntityGenerationList[Index]:=0;
       end;
      end;
      result.Generation:=fEntityGenerationList[Index] and $ff;
     finally
      fEntityLock.ReleaseWrite;
     end;
     fReservedEntitySUIDHashMap.Add(EntitySUID^,result);
    finally
     fReservedEntityHashMapLock.WriteToRead;
    end;
   end else begin
    fReservedEntityHashMapLock.ReadToWrite;
    try
     fEntityLock.AcquireWrite;
     try
      if fEntityIndexFreeList.IndexOf(result.Index)>=0 then begin
       fEntityIndexFreeList.Remove(result.Index);
      end;
      fEntityIndexCounter:=Max(fEntityIndexCounter,result.Index+1);
     finally
      fEntityLock.ReleaseWrite;
     end;
     fReservedEntitySUIDHashMap.Add(EntitySUID^,result);
    finally
     fReservedEntityHashMapLock.WriteToRead;
    end;
   end;
  end;
 finally
  fReservedEntityHashMapLock.ReleaseRead;
 end;
 if result.Index>=0 then begin
  DelayedManagementEvent.EventType:=TpvEntityComponentSystem.TDelayedManagementEventType.CreateEntity;
  DelayedManagementEvent.EntityID:=result;
  DelayedManagementEvent.SUID:=EntitySUID^;
  AddDelayedManagementEvent(DelayedManagementEvent);
 end;
end;

function TpvEntityComponentSystem.TWorld.CreateEntity(const aEntitySUID:TpvSUID):TpvEntityComponentSystem.TEntityID;
var DelayedManagementEvent:TDelayedManagementEvent;
    Index,OldCount,Count:TpvSizeInt;
    EntitySUID:PpvSUID;
    SUID,AutoGeneratedSUID:TpvSUID;
    SUIDIsUnused:boolean;
begin
 result:=0;
 fReservedEntityHashMapLock.AcquireRead;
 try
  SUID:=aEntitySUID;
  if SUID=TpvSUID.Null then begin
   repeat
    AutoGeneratedSUID:=TpvSUID.Create;
   until not fReservedEntitySUIDHashMap.ExistKey(AutoGeneratedSUID);
   EntitySUID:=@AutoGeneratedSUID;
   SUIDIsUnused:=true;
  end else begin
   EntitySUID:=@SUID;
   SUIDIsUnused:=not fReservedEntitySUIDHashMap.ExistKey(EntitySUID^);
  end;
  if SUIDIsUnused then begin
   fReservedEntityHashMapLock.ReadToWrite;
   try
    fEntityLock.AcquireWrite;
    try
     if fEntityIndexFreeList.Count>0 then begin
      result.Index:=fEntityIndexFreeList.Items[fEntityIndexFreeList.Count-1];
      fEntityIndexFreeList.Delete(fEntityIndexFreeList.Count-1);
     end else begin
      result.Index:=fEntityIndexCounter;
      inc(fEntityIndexCounter);
     end;
     OldCount:=length(fEntityGenerationList);
     Count:=fEntityIndexCounter;
     if OldCount<Count then begin
      SetLength(fEntityGenerationList,Count+((Count+1) shr 1));
      for Index:=OldCount to length(fEntityGenerationList)-1 do begin
       fEntityGenerationList[Index]:=0;
      end;
     end;
     result.Generation:=fEntityGenerationList[Index] and $ff;
    finally
     fEntityLock.ReleaseWrite;
    end;
    fReservedEntitySUIDHashMap.Add(EntitySUID^,result);
   finally
    fReservedEntityHashMapLock.WriteToRead;
   end;
  end;
 finally
  fReservedEntityHashMapLock.ReleaseRead;
 end;
 if result<>0 then begin
  DelayedManagementEvent.EventType:=TpvEntityComponentSystem.TDelayedManagementEventType.CreateEntity;
  DelayedManagementEvent.EntityID:=result;
  DelayedManagementEvent.SUID:=EntitySUID^;
  AddDelayedManagementEvent(DelayedManagementEvent);
 end;
end;

function TpvEntityComponentSystem.TWorld.CreateEntity:TEntityID;
begin
 result:=CreateEntity(TpvSUID.Null);
end;

function TpvEntityComponentSystem.TWorld.HasEntity(const aEntityID:TpvEntityComponentSystem.TEntityID):boolean;
var EntityIndex:TpvInt32;
begin
 EntityIndex:=aEntityID.Index;
 fLock.AcquireRead;
 try
  result:=(EntityIndex>=0) and
          (EntityIndex<=fMaxEntityIndex) and
          ((fEntityUsedBitmap[EntityIndex shr 5] and TpvUInt32(TpvUInt32(1) shl TpvUInt32(EntityIndex and 31)))<>0) and
          (fEntities[EntityIndex].fID=aEntityID);
 finally
  fLock.ReleaseRead;
 end;
end;

function TpvEntityComponentSystem.TWorld.HasEntityIndex(const aEntityIndex:TpvSizeInt):boolean;
begin
 fLock.AcquireRead;
 try
  result:=(aEntityIndex>=0) and
          (aEntityIndex<=fMaxEntityIndex) and
          ((fEntityUsedBitmap[aEntityIndex shr 5] and TpvUInt32(TpvUInt32(1) shl TpvUInt32(aEntityIndex and 31)))<>0) and
          (fEntities[aEntityIndex].fID.Index=aEntityIndex);
 finally
  fLock.ReleaseRead;
 end;
end;

function TpvEntityComponentSystem.TWorld.IsEntityActive(const aEntityID:TpvEntityComponentSystem.TEntityID):boolean;
var EntityIndex:TpvInt32;
begin
 EntityIndex:=aEntityID.Index;
 fLock.AcquireRead;
 try
  result:=(EntityIndex>=0) and
          (EntityIndex<=fMaxEntityIndex) and
          ((fEntityUsedBitmap[EntityIndex shr 5] and TpvUInt32(TpvUInt32(1) shl TpvUInt32(EntityIndex and 31)))<>0) and
          (fEntities[EntityIndex].fID=aEntityID) and
          (TpvEntityComponentSystem.TEntity.TFlag.Active in fEntities[EntityIndex].fFlags);
 finally
  fLock.ReleaseRead;
 end;
end;

procedure TpvEntityComponentSystem.TWorld.ActivateEntity(const aEntityID:TEntityID);
var DelayedManagementEvent:TDelayedManagementEvent;
begin
 DelayedManagementEvent.EventType:=TpvEntityComponentSystem.TDelayedManagementEventType.ActivateEntity;
 DelayedManagementEvent.EntityID:=aEntityID;
 AddDelayedManagementEvent(DelayedManagementEvent);
end;

procedure TpvEntityComponentSystem.TWorld.DeactivateEntity(const aEntityID:TEntityID);
var DelayedManagementEvent:TDelayedManagementEvent;
begin
 DelayedManagementEvent.EventType:=TpvEntityComponentSystem.TDelayedManagementEventType.DeactivateEntity;
 DelayedManagementEvent.EntityID:=aEntityID;
 AddDelayedManagementEvent(DelayedManagementEvent);
end;

procedure TpvEntityComponentSystem.TWorld.KillEntity(const aEntityID:TEntityID);
var DelayedManagementEvent:TDelayedManagementEvent;
begin
 DelayedManagementEvent.EventType:=TpvEntityComponentSystem.TDelayedManagementEventType.DeactivateEntity;
 DelayedManagementEvent.EntityID:=aEntityID;
 AddDelayedManagementEvent(DelayedManagementEvent);
 DelayedManagementEvent.EventType:=TpvEntityComponentSystem.TDelayedManagementEventType.KillEntity;
 AddDelayedManagementEvent(DelayedManagementEvent);
end;

procedure TpvEntityComponentSystem.TWorld.AddComponentToEntity(const aEntityID:TEntityID;const aComponentID:TComponentID;const aData:Pointer;const aDataSize:TpvSizeInt);
var DelayedManagementEvent:TDelayedManagementEvent;
begin
 DelayedManagementEvent.EventType:=TpvEntityComponentSystem.TDelayedManagementEventType.AddComponentToEntity;
 DelayedManagementEvent.EntityID:=aEntityID;
 DelayedManagementEvent.ComponentID:=aComponentID;
 DelayedManagementEvent.Data:=nil;
 DelayedManagementEvent.DataSize:=aDataSize;
 if aDataSize>0 then begin
  SetLength(DelayedManagementEvent.Data,aDataSize);
  Move(aData^,DelayedManagementEvent.Data[0],aDataSize);
 end;
 AddDelayedManagementEvent(DelayedManagementEvent);
end;

function TpvEntityComponentSystem.TWorld.AddComponentWithDataToEntity(const aEntityID:TEntityID;const aComponentID:TComponentID):Pointer;
var Component:TpvEntityComponentSystem.TComponent;
    DelayedManagementEvent:TDelayedManagementEvent;
begin
 if aComponentID<fComponents.Count then begin
  Component:=fComponents[aComponentID];
  DelayedManagementEvent.EventType:=TpvEntityComponentSystem.TDelayedManagementEventType.AddComponentToEntity;
  DelayedManagementEvent.EntityID:=aEntityID;
  DelayedManagementEvent.ComponentID:=aComponentID;
  DelayedManagementEvent.Data:=nil;
  DelayedManagementEvent.DataSize:=Component.fRegisteredComponentType.fSize;
  SetLength(DelayedManagementEvent.Data,Component.fRegisteredComponentType.fSize);
  FillChar(DelayedManagementEvent.Data[0],Component.fRegisteredComponentType.fSize,#0);
  AddDelayedManagementEvent(DelayedManagementEvent);
  result:=@DelayedManagementEvent.Data[0];
 end else begin
  result:=nil;
 end;
end;

procedure TpvEntityComponentSystem.TWorld.RemoveComponentFromEntity(const aEntityID:TEntityID;const aComponentID:TComponentID);
var DelayedManagementEvent:TDelayedManagementEvent;
begin
 DelayedManagementEvent.EventType:=TpvEntityComponentSystem.TDelayedManagementEventType.RemoveComponentFromEntity;
 DelayedManagementEvent.EntityID:=aEntityID;
 DelayedManagementEvent.ComponentID:=aComponentID;
 AddDelayedManagementEvent(DelayedManagementEvent);
end;

function TpvEntityComponentSystem.TWorld.HasEntityComponent(const aEntityID:TEntityID;const aComponentID:TComponentID):boolean;
var EntityIndex:TpvInt32;
begin
 EntityIndex:=aEntityID.Index;
 fLock.AcquireRead;
 try
  result:=(EntityIndex>=0) and
          (EntityIndex<=fMaxEntityIndex) and
          ((fEntityUsedBitmap[EntityIndex shr 5] and TpvUInt32(TpvUInt32(1) shl TpvUInt32(EntityIndex and 31)))<>0) and
          (fEntities[EntityIndex].fID=aEntityID) and
          fComponents[aComponentID].IsComponentInEntityIndex(EntityIndex);
 finally
  fLock.ReleaseRead;
 end;
end;

procedure TpvEntityComponentSystem.TWorld.AddSystem(const aSystem:TSystem);
var DelayedManagementEvent:TDelayedManagementEvent;
begin
 DelayedManagementEvent.EventType:=TpvEntityComponentSystem.TDelayedManagementEventType.AddSystem;
 DelayedManagementEvent.System:=aSystem;
 AddDelayedManagementEvent(DelayedManagementEvent);
end;

procedure TpvEntityComponentSystem.TWorld.RemoveSystem(const aSystem:TSystem);
var DelayedManagementEvent:TDelayedManagementEvent;
begin
 DelayedManagementEvent.EventType:=TpvEntityComponentSystem.TDelayedManagementEventType.RemoveSystem;
 DelayedManagementEvent.System:=aSystem;
 AddDelayedManagementEvent(DelayedManagementEvent);
end;

procedure TpvEntityComponentSystem.TWorld.SortSystem(const aSystem:TSystem);
var DelayedManagementEvent:TDelayedManagementEvent;
begin
 DelayedManagementEvent.EventType:=TpvEntityComponentSystem.TDelayedManagementEventType.SortSystem;
 DelayedManagementEvent.System:=aSystem;
 AddDelayedManagementEvent(DelayedManagementEvent);
end;

function TWorldDefragmentCompare(const a,b:pointer):TpvInt32;
begin
 result:=TpvPtrInt(TpvPtrUInt(a))-TpvPtrInt(TpvPtrUInt(b));
end;

type TWorldDefragmentListEntities=class
      private
       fItems:array of TpvEntityComponentSystem.TEntity;
       fCount:TpvInt32;
       function GetItem(const aIndex:TpvInt32):TpvEntityComponentSystem.TEntity; inline;
       procedure SetItem(const aIndex:TpvInt32;const aItem:TpvEntityComponentSystem.TEntity); inline;
      public
       constructor Create(const aCount:TpvInt32);
       destructor Destroy; override;
       procedure MemorySwap(aA,aB:pointer;aSize:TpvInt32);
       function CompareItem(const aIndex,aWithIndex:TpvSizeInt):TpvInt32; inline;
       procedure Exchange(const aIndex,aWithIndex:TpvSizeInt); virtual;
       procedure Sort;
       property Items[const aIndex:TpvInt32]:TpvEntityComponentSystem.TEntity read GetItem write SetItem;
       property Count:TpvInt32 read fCount;
     end;

constructor TWorldDefragmentListEntities.Create(const aCount:TpvInt32);
begin
 inherited Create;
 fItems:=nil;
 fCount:=aCount;
 SetLength(fItems,fCount);
 if fCount>0 then begin
  FillChar(fItems[0],fCount*SizeOf(TObject),#0);
 end;
end;

destructor TWorldDefragmentListEntities.Destroy;
begin
 SetLength(fItems,0);
 inherited Destroy;
end;

function TWorldDefragmentListEntities.GetItem(const aIndex:TpvInt32):TpvEntityComponentSystem.TEntity;
begin
 result:=fItems[aIndex];
end;

procedure TWorldDefragmentListEntities.SetItem(const aIndex:TpvInt32;const aItem:TpvEntityComponentSystem.TEntity);
begin
 fItems[aIndex]:=aItem;
end;

procedure TWorldDefragmentListEntities.MemorySwap(aA,aB:pointer;aSize:TpvInt32);
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

function TWorldDefragmentListEntities.CompareItem(const aIndex,aWithIndex:TpvSizeInt):TpvInt32;
begin
 result:=TpvPtrInt(TpvPtrUInt(Pointer(@fItems[aIndex])))-TpvPtrInt(TpvPtrUInt(Pointer(@fItems[aWithIndex])));
end;

procedure TWorldDefragmentListEntities.Exchange(const aIndex,aWithIndex:TpvSizeInt);
begin
 MemorySwap(@fItems[aIndex],@fItems[aWithIndex],SizeOf(TpvEntityComponentSystem.TEntity));
end;

procedure TWorldDefragmentListEntities.Sort;
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

procedure TpvEntityComponentSystem.TWorld.Defragment;
 procedure DefragmentComponents;
 var ComponentIndex:TpvSizeInt;
 begin
  for ComponentIndex:=0 to fComponents.Count-1 do begin
   fComponents[ComponentIndex].Defragment;
  end;
 end;
 procedure DefragmentEntities;
 begin
 end;
begin
 DefragmentComponents;
 DefragmentEntities;
end;

procedure TpvEntityComponentSystem.TWorld.Refresh;
var DelayedManagementEventIndex,Index,EntityIndex:TpvSizeInt;
    DelayedManagementEvent:PDelayedManagementEvent;
    EntityID:TEntityID;
    Entity:PEntity;
    Component:TpvEntityComponentSystem.TComponent;
    System:TpvEntityComponentSystem.TSystem;
    EntitiesWereAdded,EntitiesWereRemoved,WasActive:boolean;
    Data:Pointer;
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

    TpvEntityComponentSystem.TDelayedManagementEventType.CreateEntity:begin

     EntityID:=DelayedManagementEvent^.EntityID;
     EntityIndex:=EntityID.Index;
     if (EntityIndex>=0) and (EntityIndex<fEntityIndexCounter) then begin
      DoCreateEntity(EntityID,DelayedManagementEvent^.SUID);
     end;

    end;

    TpvEntityComponentSystem.TDelayedManagementEventType.ActivateEntity:begin

     EntityID:=DelayedManagementEvent^.EntityID;
     EntityIndex:=EntityID.Index;
     if (EntityIndex>=0) and
        (EntityIndex<fEntityIndexCounter) and
        ((fEntityUsedBitmap[EntityIndex shr 5] and TpvUInt32(TpvUInt32(1) shl TpvUInt32(EntityIndex and 31)))<>0) and
        not (TpvEntityComponentSystem.TEntity.TFlag.Active in fEntities[EntityIndex].Flags) then begin
      for Index:=0 to fSystems.Count-1 do begin
       System:=fSystems.Items[Index];
       if System.FitsEntityToSystem(EntityID) then begin
        System.AddEntityToSystem(EntityID);
        EntitiesWereAdded:=true;
       end;
      end;
      Include(fEntities[EntityID].fFlags,TpvEntityComponentSystem.TEntity.TFlag.Active);

     end;

    end;

    TpvEntityComponentSystem.TDelayedManagementEventType.DeactivateEntity:begin

     EntityID:=DelayedManagementEvent^.EntityID;
     EntityIndex:=EntityID.Index;
     if (EntityIndex>=0) and
        (EntityIndex<fEntityIndexCounter) and
        ((fEntityUsedBitmap[EntityIndex shr 5] and TpvUInt32(TpvUInt32(1) shl TpvUInt32(EntityIndex and 31)))<>0) and
        (TpvEntityComponentSystem.TEntity.TFlag.Active in fEntities[EntityIndex].Flags) then begin
      Exclude(fEntities[EntityID].fFlags,TpvEntityComponentSystem.TEntity.TFlag.Active);
      for Index:=0 to fSystems.Count-1 do begin
       System:=fSystems.Items[Index];
       System.RemoveEntityFromSystem(EntityID);
       EntitiesWereRemoved:=true;
      end;
     end;

    end;

    TpvEntityComponentSystem.TDelayedManagementEventType.KillEntity:begin

     EntityID:=DelayedManagementEvent^.EntityID;
     EntityIndex:=EntityID.Index;
     if (EntityIndex>=0) and
        (EntityIndex<fEntityIndexCounter) and
        ((fEntityUsedBitmap[EntityIndex shr 5] and TpvUInt32(TpvUInt32(1) shl TpvUInt32(EntityIndex and 31)))<>0) then begin
      for Index:=0 to fSystems.Count-1 do begin
       System:=fSystems.Items[Index];
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

    TpvEntityComponentSystem.TDelayedManagementEventType.AddComponentToEntity:begin

     EntityID:=DelayedManagementEvent^.EntityID;
     EntityIndex:=EntityID.Index;
     if (EntityIndex>=0) and
        (EntityIndex<fEntityIndexCounter) and
        ((fEntityUsedBitmap[EntityIndex shr 5] and TpvUInt32(TpvUInt32(1) shl TpvUInt32(EntityIndex and 31)))<>0) then begin
      if{(DelayedManagementEvent^.ComponentID>=0) and}(DelayedManagementEvent^.ComponentID<fComponents.Count) then begin
       Component:=fComponents[DelayedManagementEvent^.ComponentID];
      end else begin
       Component:=nil;
      end;
      if assigned(Component) and (not Component.IsComponentInEntityIndex(EntityIndex)) and Component.AllocateComponentForEntityIndex(EntityIndex) then begin
       WasActive:=TpvEntityComponentSystem.TEntity.TFlag.Active in fEntities[EntityIndex].Flags;
       if WasActive then begin
        for Index:=0 to fSystems.Count-1 do begin
         System:=fSystems.Items[Index];
         System.RemoveEntityFromSystem(EntityID);
         EntitiesWereRemoved:=true;
        end;
       end;
       Entity:=@fEntities[EntityIndex];
       Entity^.AddComponentToEntity(DelayedManagementEvent^.ComponentID);
       Data:=Component.GetComponentByEntityIndex(EntityIndex);
       if DelayedManagementEvent^.DataSize>0 then begin
        if DelayedManagementEvent^.DataSize<Component.RegisteredComponentType.fSize then begin
         FillChar(Data^,Component.RegisteredComponentType.fSize,#0);
        end;
        Move(DelayedManagementEvent^.Data[0],Data^,Min(DelayedManagementEvent^.DataSize,Component.RegisteredComponentType.fSize));
       end else begin
        FillChar(Data^,Component.RegisteredComponentType.fSize,#0);
       end;
       if WasActive then begin
        for Index:=0 to fSystems.Count-1 do begin
         System:=TSystem(fSystems.Items[Index]);
         if System.FitsEntityToSystem(EntityID) then begin
          System.AddEntityToSystem(EntityID);
          EntitiesWereAdded:=true;
         end;
        end;
       end;
      end;
     end;

     DelayedManagementEvent^.Data:=nil;
     DelayedManagementEvent^.DataSize:=0;

    end;

    TpvEntityComponentSystem.TDelayedManagementEventType.RemoveComponentFromEntity:begin

     EntityID:=DelayedManagementEvent^.EntityID;
     EntityIndex:=EntityID.Index;
     if (EntityIndex>=0) and
        (EntityIndex<fEntityIndexCounter) and
        ((fEntityUsedBitmap[EntityIndex shr 5] and TpvUInt32(TpvUInt32(1) shl TpvUInt32(EntityIndex and 31)))<>0) then begin
      if{(DelayedManagementEvent^.ComponentID>=0) and}(DelayedManagementEvent^.ComponentID<fComponents.Count) then begin
       Component:=fComponents[DelayedManagementEvent^.ComponentID];
      end else begin
       Component:=nil;
      end;
      if assigned(Component) and Component.IsComponentInEntityIndex(EntityIndex) and Component.FreeComponentFromEntityIndex(EntityIndex) then begin
       WasActive:=TpvEntityComponentSystem.TEntity.TFlag.Active in fEntities[EntityIndex].Flags;
       if WasActive then begin
        for Index:=0 to fSystems.Count-1 do begin
         System:=fSystems.Items[Index];
         System.RemoveEntityFromSystem(EntityID);
         EntitiesWereRemoved:=true;
        end;
       end;
       Entity:=@fEntities[EntityIndex];
       Entity^.RemoveComponentFromEntity(DelayedManagementEvent^.ComponentID);
       if WasActive then begin
        for Index:=0 to fSystems.Count-1 do begin
         System:=TSystem(fSystems.Items[Index]);
         if System.FitsEntityToSystem(EntityID) then begin
          System.AddEntityToSystem(EntityID);
          EntitiesWereAdded:=true;
         end;
        end;
       end;
      end;
     end;

    end;

    TpvEntityComponentSystem.TDelayedManagementEventType.AddSystem:begin

     System:=DelayedManagementEvent^.System;
     if not fSystemUsedMap.Values[System] then begin
      fSystemUsedMap.Add(System,true);
      fSystems.Add(System);
      InterlockedExchange(fSystemChoreographyNeedToRebuild,-1);
      for EntityIndex:=0 to fEntityIndexCounter-1 do begin
       if (EntityIndex>=0) and
           (EntityIndex<fEntityIndexCounter) and
           ((fEntityUsedBitmap[EntityIndex shr 5] and TpvUInt32(TpvUInt32(1) shl longword(EntityIndex and 31)))<>0) and
           (TpvEntityComponentSystem.TEntity.TFlag.Active in fEntities[EntityIndex].Flags) and
           System.FitsEntityToSystem(fEntities[EntityIndex].fID) then begin
        System.AddEntityToSystem(fEntities[EntityIndex].fID);
        EntitiesWereAdded:=true;
       end;
      end;
      System.Added;
     end;

    end;

    TpvEntityComponentSystem.TDelayedManagementEventType.RemoveSystem:begin

     System:=DelayedManagementEvent^.System;
     if fSystemUsedMap.Values[System] then begin
      System.Removed;
      fSystemUsedMap.Delete(System);
      fSystems.Remove(System);
      InterlockedExchange(fSystemChoreographyNeedToRebuild,-1);
     end;

    end;

    TpvEntityComponentSystem.TDelayedManagementEventType.SortSystem:begin

     System:=DelayedManagementEvent^.System;
     if fSystemUsedMap.Values[System] then begin
      System.SortEntities;
     end;

    end;

    else begin
     Assert(false);
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

procedure TpvEntityComponentSystem.TWorld.ProcessEvent(const aEvent:PEvent);
var EventHandlerIndex,SystemIndex,EventIndex:TpvInt32;
    EventRegistration:TpvEntityComponentSystem.TEventRegistration;
    EventID:TpvEntityComponentSystem.TEventID;
    EventHandler:TpvEntityComponentSystem.TEventHandler;
    System:TpvEntityComponentSystem.TSystem;
    LocalSystemList:TpvEntityComponentSystem.TSystemList;
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

procedure TpvEntityComponentSystem.TWorld.ProcessEvents;
var CurrentEvent:TpvEntityComponentSystem.PEvent;
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

procedure TpvEntityComponentSystem.TWorld.ProcessDelayedEvents(const aDeltaTime:TTime);
var CurrentEvent,NextEvent:TpvEntityComponentSystem.PEvent;
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

procedure TpvEntityComponentSystem.TWorld.QueueEvent(const aEventToQueue:TpvEntityComponentSystem.TEvent;const aDeltaTime:TpvTime);
var ParameterIndex:TpvSizeInt;
    Event:TpvEntityComponentSystem.PEvent;
begin
 fFreeEventQueueLock.AcquireWrite;
 try
  Event:=LinkedListPopFront(@fFreeEventQueue);
 finally
  fFreeEventQueueLock.ReleaseWrite;
 end;
 if not assigned(Event) then begin
  GetMem(Event,SizeOf(TEvent));
  FillChar(Event^,SizeOf(TEvent),#0);
  fEventListLock.AcquireWrite;
  try
   fEventList.Add(Event);
  finally
   fEventListLock.ReleaseWrite;
  end;
 end;
 LinkedListInitialize(pointer(Event));
 if aDeltaTime>0 then begin
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
 Event^.TimeStamp:=fCurrentTime+aDeltaTime;
 Event^.RemainingTime:=aDeltaTime;
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

procedure TpvEntityComponentSystem.TWorld.QueueEvent(const aEventToQueue:TpvEntityComponentSystem.TEvent);
begin
 QueueEvent(aEventToQueue,1.0e-18); // one femtosecond
end;

procedure TpvEntityComponentSystem.TWorld.Update(const aDeltaTime:TpvTime);
var SystemIndex:TpvSizeInt;
    System:TSystem;
begin

 fDeltaTime:=aDeltaTime;

 for SystemIndex:=0 to fSystems.Count-1 do begin
  System:=fSystems.Items[SystemIndex];
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

procedure TpvEntityComponentSystem.TWorld.Clear;
var EntityIndex,SystemIndex:TpvSizeInt;
begin
 fLock.AcquireRead;
 try
  if fEntityIndexCounter>0 then begin
   fLock.ReleaseRead;
   try
    for EntityIndex:=0 to fEntityIndexCounter-1 do begin
     if (fEntityUsedBitmap[EntityIndex shr 5] and TpvUInt32(TpvUInt32(1) shl TpvUInt32(EntityIndex and 31)))<>0 then begin
      KillEntity(fEntities[EntityIndex].fID);
     end;
    end;
    Refresh;
   finally
    fLock.AcquireRead;
   end;
  end;
  if fSystems.Count>0 then begin
   fLock.ReleaseRead;
   try
    for SystemIndex:=0 to fSystems.Count-1 do begin
     RemoveSystem(fSystems.Items[SystemIndex]);
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
 fEntityIndexCounter:=0;
 fEntitySUIDHashMap.Clear;
 fReservedEntitySUIDHashMap.Clear;
 fEntityIndexFreeList.Clear;
end;

procedure TpvEntityComponentSystem.TWorld.ClearEntities;
var EntityIndex:TpvSizeInt;
begin
 fLock.AcquireRead;
 try
  if fEntityIndexCounter>0 then begin
   fLock.ReleaseRead;
   try
    for EntityIndex:=0 to fEntityIndexCounter-1 do begin
     if (fEntityUsedBitmap[EntityIndex shr 5] and TpvUInt32(TpvUInt32(1) shl TpvUInt32(EntityIndex and 31)))<>0 then begin
      KillEntity(fEntities[EntityIndex].fID);
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
 fEntityIndexCounter:=0;
 fEntitySUIDHashMap.Clear;
 fReservedEntitySUIDHashMap.Clear;
 fEntityIndexFreeList.Clear;
end;

procedure TpvEntityComponentSystem.TWorld.Activate;
begin
 fActive:=true;
end;

procedure TpvEntityComponentSystem.TWorld.Deactivate;
begin
 fActive:=false;
end;

procedure TpvEntityComponentSystem.TWorld.MementoSerialize(const aStream:TStream);
var EntityIndex,ComponentIndex:TpvInt32;
    ComponentID:TComponentID;
    BitCounter:TpvInt32;
    BitTag:TpvUInt8;
    BitPosition:TpvInt64;
    EntityID:TEntityID;
    Entity:PEntity;
    Component:TpvEntityComponentSystem.TComponent;
    BufferedStream:TStream;
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
 procedure WriteUInt8(const aValue:TpvUInt8);
 begin
  if BufferedStream.Write(aValue,SizeOf(TpvUInt8))<>SizeOf(TpvUInt8) then begin
   raise EInOutError.Create('Stream write error');
  end;
 end;
 procedure WriteInt32(const aValue:TpvInt32);
 begin
  if BufferedStream.Write(aValue,SizeOf(TpvInt32))<>SizeOf(TpvInt32) then begin
   raise EInOutError.Create('Stream write error');
  end;
 end;
begin
 Refresh;
 BufferedStream:=TMemoryStream.Create;
 try
  BitTag:=0;
  BitCounter:=8;
  BitPosition:=-1;
  if BufferedStream.Write(fSUID,SizeOf(TpvSUID))<>SizeOf(TpvSUID) then begin
   raise EInOutError.Create('Stream write error');
  end;
  WriteInt32(fEntityIndexCounter);
  for EntityIndex:=0 to fEntityIndexCounter-1 do begin
   if (EntityIndex>=0) and
      (EntityIndex<=fMaxEntityIndex) and
      ((fEntityUsedBitmap[EntityIndex shr 5] and TpvUInt32(TpvUInt32(1) shl TpvUInt32(EntityIndex and 31)))<>0) then begin
    EntityID:=fEntities[EntityIndex].fID;
    WriteBit(true);
    Entity:=@fEntities[EntityID];
    WriteUInt8(EntityID.Generation);
    WriteBit(Entity^.Active);
    BufferedStream.Write(Entity^.fSUID,SizeOf(TpvSUID));
    WriteInt32(Entity^.fCountComponents);
    for ComponentIndex:=0 to Entity^.fCountComponents-1 do begin
     ComponentID:=ComponentIndex;
     if{(DelayedManagementEvent^.ComponentID>=0) and}(ComponentID<fComponents.Count) then begin
      Component:=fComponents[ComponentID];
     end else begin
      Component:=nil;
     end;
     if assigned(Component) then begin
      WriteBit(true);
      BufferedStream.Write(Component.ComponentByEntityIndex[EntityIndex]^,Component.fSize);
     end else begin
      WriteBit(false);
     end;
    end;
   end else begin
    WriteBit(false);
   end;
  end;
  FlushBits;
  BufferedStream.Seek(0,soBeginning);
  aStream.CopyFrom(BufferedStream,BufferedStream.Size);
 finally
  BufferedStream.Free;
 end;
end;

procedure TpvEntityComponentSystem.TWorld.MementoUnserialize(const aStream:TStream);
var ComponentID:TComponentID;
    EntityIndex,LocalEntityCounter,CountEntityComponents,
    EntityComponentIndex,BitCounter:TpvInt32;
    BitTag,Generation:TpvUInt8;
    EntityID:TEntityID;
    Entity:PEntity;
    Component:TpvEntityComponentSystem.TComponent;
    BufferedStream:TStream;
    TempSUID:TpvSUID;
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
 function ReadUInt8:TpvUInt8;
 begin
  if BufferedStream.Read(result,SizeOf(TpvUInt8))<>SizeOf(TpvUInt8) then begin
   raise EInOutError.Create('Stream read error');
  end;
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
 BufferedStream:=TMemoryStream.Create;
 try
  BufferedStream.CopyFrom(aStream,aStream.Size);
  BufferedStream.Seek(0,soBeginning);
  BitTag:=0;
  BitCounter:=8;
  if BufferedStream.Read(TempSUID,SizeOf(TpvSUID))<>SizeOf(TpvSUID) then begin
   raise EInOutError.Create('Stream read error');
  end;
  LocalEntityCounter:=ReadInt32;
  for EntityIndex:=0 to Max(LocalEntityCounter,fEntityIndexCounter)-1 do begin
   if EntityIndex<LocalEntityCounter then begin
    HasNewEntity:=ReadBit;
   end else begin
    HasNewEntity:=false;
   end;
   if HasNewEntity then begin
    Generation:=ReadUInt8;
    IsActive:=ReadBit;
    if BufferedStream.Read(TempSUID,SizeOf(TpvSUID))<>SizeOf(TpvSUID) then begin
     raise EInOutError.Create('Stream read error');
    end;
    if (EntityIndex>=0) and
       (EntityIndex<=fMaxEntityIndex) and
       ((fEntityUsedBitmap[EntityIndex shr 5] and TpvUInt32(TpvUInt32(1) shl TpvUInt32(EntityIndex and 31)))<>0) then begin
     Entity:=@fEntities[EntityIndex];
     EntityID:=Entity^.ID;
     if Generation<>EntityID.Generation then begin
      fEntitySUIDHashMap.Delete(Entity.fSUID);
      Entity.fSUID:=TempSUID;
      fEntitySUIDHashMap.Add(Entity.fSUID,EntityID);
      Entity^.ID.Generation:=Generation;
      EntityID:=Entity^.ID;
     end;
     if TempSUID<>Entity.fSUID then begin
      fEntitySUIDHashMap.Delete(Entity.fSUID);
      Entity.fSUID:=TempSUID;
      fEntitySUIDHashMap.Add(Entity.fSUID,EntityID);
     end;
    end else begin
     EntityID.Index:=EntityIndex;
     EntityID.Generation:=Generation;
     EntityID:=CreateEntity(EntityID,TempSUID);
     Refresh;
     Entity:=@fEntities[EntityIndex];
    end;
    CountEntityComponents:=ReadInt32;
    for EntityComponentIndex:=0 to Max(CountEntityComponents,Entity.fCountComponents)-1 do begin
     if EntityComponentIndex<CountEntityComponents then begin
      HasNewComponent:=ReadBit;
     end else begin
      HasNewComponent:=false;
     end;
     if HasNewComponent then begin
      ComponentID:=EntityComponentIndex;
      if{(ComponentID>=0) and}(ComponentID<fComponents.Count) then begin
       Component:=fComponents[ComponentID];
      end else begin
       Component:=nil;
      end;
      if assigned(Component) then begin
       if not Component.IsComponentInEntityIndex(EntityIndex) then begin
        AddComponentToEntity(EntityID,ComponentID);
        Refresh;
       end;
       BufferedStream.Read(Component.ComponentByEntityIndex[EntityIndex]^,Component.fSize);
      end;
     end else if EntityComponentIndex<Entity.fCountComponents then begin
      ComponentID:=EntityComponentIndex;
      if{(ComponentID>=0) and}(ComponentID<fComponents.Count) then begin
       Component:=fComponents[ComponentID];
      end else begin
       Component:=nil;
      end;
      if assigned(Component) then begin
       if Component.IsComponentInEntityIndex(EntityIndex) then begin
        RemoveComponentFromEntity(EntityID,ComponentID);
        Refresh;
       end;
      end;
     end;
    end;
    if IsActive then begin
     ActivateEntity(EntityID);
    end else begin
     DeactivateEntity(EntityID);
    end;
    Refresh;
   end else begin
    if (EntityIndex>=0) and
       (EntityIndex<=fMaxEntityIndex) and
       ((fEntityUsedBitmap[EntityIndex shr 5] and TpvUInt32(TpvUInt32(1) shl TpvUInt32(EntityIndex and 31)))<>0) then begin
     Entity:=@fEntities[EntityIndex];
     EntityID:=Entity^.ID;
     KillEntity(EntityID);
     Refresh;
    end;
   end;
  end;
  Refresh;
 finally
  BufferedStream.Free;
 end;
 inc(fGeneration);
end;

function TpvEntityComponentSystem.TWorld.SerializeToJSON(const aEntityIDs:array of TEntityID;const aRootEntityID:TEntityID):TPasJSONItem;
var RootObjectItem,EntitesObjectItem:TPasJSONItemObject;
    EntityIndex:TpvInt32;
    Entity:PEntity;
    EntityID:TEntityID;
begin
 RootObjectItem:=TPasJSONItemObject.Create;
 result:=RootObjectItem;
 if (aRootEntityID<>TEntityID.Invalid) and HasEntity(aRootEntityID) then begin
  Entity:=GetEntityByID(aRootEntityID);
  if assigned(Entity) then begin
   RootObjectItem.Add('root',TPasJSONItemString.Create(TPasJSONUTF8String(Entity.SUID.ToString)));
  end;
 end;
 //RootObjectItem.Add('SUID',TPasJSONItemString.Create(TPasJSONUTF8String(GetSUID.ToString)));
 EntitesObjectItem:=TPasJSONItemObject.Create;
 try
  if length(aEntityIDs)>0 then begin
   for EntityIndex:=0 to length(aEntityIDs)-1 do begin
    EntityID:=aEntityIDs[EntityIndex];
    if HasEntity(EntityID) then begin
     Entity:=GetEntityByID(EntityID);
     if assigned(Entity) then begin
      EntitesObjectItem.Add(Entity^.fSUID.ToString,Entity^.SerializeToJSON);
     end;
    end;
   end;
  end else begin
   for EntityIndex:=0 to length(aEntityIDs)-1 do begin
    if HasEntityIndex(EntityIndex) then begin
     Entity:=@fEntities[EntityIndex];
     if assigned(Entity) then begin
      EntitesObjectItem.Add(Entity^.fSUID.ToString,Entity^.SerializeToJSON);
     end;
    end;
   end;
  end;
 finally
  RootObjectItem.Add('entities',EntitesObjectItem);
 end;
end;

function TpvEntityComponentSystem.TWorld.UnserializeFromJSON(const aJSONRootItem:TPasJSONItem;const aCreateNewSUIDs:boolean):TEntityID;
type TSUIDIntegerPairHashMap=TpvHashMap<TpvSUID,TpvInt32>;
     TParentObjectNames=TpvGenericList<TPasJSONUTF8String>;
var RootSUID:TpvUTF8String;
    EntitySUID:TpvSUID;
    Entity:PEntity;
    RootObjectItem,EntityObjectItem,EntitiesObjectItem:TPasJSONItemObject;
    RootObjectItemIndex,EntitiesObjectItemIndex:TpvSizeInt;
    RootObjectItemKey,EntitiesObjectItemKey:TPasJSONUTF8String;
    RootObjectItemValue,EntitiesObjectItemValue:TPasJSONItem;
    EntityID:TEntityID;
    EntitySUIDHashMap:TSUIDIntegerPairHashMap;
    EntityIDs:array of TEntityID;
    ParentObjectNames:TParentObjectNames;
    WorldName:TpvUTF8String;
begin

 result:=TEntityID.Invalid;

 if assigned(aJSONRootItem) and (aJSONRootItem is TPasJSONItemObject) then begin

  EntityIDs:=nil;
  try

   ParentObjectNames:=TParentObjectNames.Create;
   try

    EntitySUIDHashMap:=TSUIDIntegerPairHashMap.Create(-1);
    try

     EntitiesObjectItem:=nil;

     RootSUID:='';
     
     RootObjectItem:=TPasJSONItemObject(aJSONRootItem);
     for RootObjectItemIndex:=0 to RootObjectItem.Count-1 do begin
      RootObjectItemKey:=RootObjectItem.Keys[RootObjectItemIndex];
      RootObjectItemValue:=RootObjectItem.Values[RootObjectItemIndex];
      if (length(RootObjectItemKey)>0) and assigned(RootObjectItemValue) then begin
       if RootObjectItemKey='root' then begin
        if RootObjectItemValue is TPasJSONItemString then begin
         RootSUID:=TpvUTF8String(TPasJSONItemString(RootObjectItemValue).Value);
        end;
       end else if RootObjectItemKey='suid' then begin
{       if RootObjectItemValue is TPasJSONItemString then begin
         WorldSUID:=TpvSUID.CreateFromString(TpvUTF8String(TPasJSONItemString(RootObjectItemValue).Value));
         if WorldSUID.UInt64s[0]<>0 then begin
         end;
        end;}
       end else if RootObjectItemKey='name' then begin
        WorldName:=TpvUTF8String(TPasJSONItemString(RootObjectItemValue).Value);
        if length(WorldName)>0 then begin
        end;
       end else if RootObjectItemKey='entities' then begin
        if RootObjectItemValue is TPasJSONItemObject then begin
         EntitiesObjectItem:=TPasJSONItemObject(RootObjectItemValue);
        end;
       end; 
      end;
     end; 

     if assigned(EntitiesObjectItem) then begin

      SetLength(EntityIDs,EntitiesObjectItem.Count);

      for EntitiesObjectItemIndex:=0 to EntitiesObjectItem.Count-1 do begin
       EntityIDs[EntitiesObjectItemIndex]:=TEntityID.Invalid;
      end;

      for EntitiesObjectItemIndex:=0 to EntitiesObjectItem.Count-1 do begin
       EntitiesObjectItemKey:=EntitiesObjectItem.Keys[EntitiesObjectItemIndex];
       EntitiesObjectItemValue:=EntitiesObjectItem.Values[EntitiesObjectItemIndex];
       if (length(EntitiesObjectItemKey)>0) and assigned(EntitiesObjectItemValue) then begin
        if RootObjectItemValue is TPasJSONItemObject then begin
         EntitySUID:=TpvSUID.CreateFromString(TpvUTF8String(RootObjectItemKey));
         if aCreateNewSUIDs then begin
          EntityID:=CreateEntity;
         end else begin
          EntityID:=CreateEntity(EntitySUID);
         end;
         if EntityID<>TEntityID.Invalid then begin
          Refresh;
          Entity:=GetEntityByID(EntityID);
          if assigned(Entity) then begin
           EntityIDs[RootObjectItemIndex]:=EntityID;
           EntitySUIDHashMap.Add(EntitySUID,EntityID);
          end else begin
           raise ESystemUnserialization.Create('Internal error 2016-01-19-20-30-0000');
          end;
         end else begin
          raise ESystemUnserialization.Create('Internal error 2016-01-19-20-30-0001');
         end;
        end;
       end;
      end;
     end;

     Refresh;

     if length(RootSUID)>0 then begin
      Entity:=GetEntityBySUID(TpvSUID.CreateFromString(RootSUID));
      if assigned(Entity) then begin
       result:=Entity^.ID;
      end;
     end;

    finally
     EntitySUIDHashMap.Free;
    end;

   finally
    ParentObjectNames.Free;
   end;

  finally
   EntityIDs:=nil;
  end;

 end;
 inc(fGeneration);

end;

function TpvEntityComponentSystem.TWorld.LoadFromStream(const aStream:TStream;const aCreateNewSUIDs:boolean):TEntityID;
var s:TPasJSONRawByteString;
    l:TpvInt64;
begin
 s:='';
 try
  l:=aStream.Size-aStream.Position;
  if l>0 then begin
   SetLength(s,l*SizeOf(AnsiChar));
   if aStream.Read(s[1],l*SizeOf(AnsiChar))<>(l*SizeOf(AnsiChar)) then begin
    raise EInOutError.Create('Stream read error');
   end;
   result:=UnserializeFromJSON(TPasJSON.Parse(s),aCreateNewSUIDs);
  end else begin
   result:=TEntityID.Invalid;
  end;
 finally
  s:='';
 end;
end;

procedure TpvEntityComponentSystem.TWorld.SaveToStream(const aStream:TStream;const aEntityIDs:array of TEntityID;const aRootEntityID:TEntityID);
var s:TPasJSONRawByteString;
    l:TpvInt64;
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

function TpvEntityComponentSystem.TWorld.LoadFromFile(const aFileName:TpvUTF8String;const aCreateNewSUIDs:boolean):TEntityID;
var FileStream:TFileStream;
begin
 FileStream:=TFileStream.Create(aFileName,fmOpenRead or fmShareDenyWrite);
 try
  result:=LoadFromStream(FileStream,aCreateNewSUIDs);
 finally
  FileStream.Free;
 end;
end;

procedure TpvEntityComponentSystem.TWorld.SaveToFile(const aFileName:TpvUTF8String;const aEntityIDs:array of TEntityID;const aRootEntityID:TEntityID);
var FileStream:TFileStream;
begin
 FileStream:=TFileStream.Create(aFileName,fmCreate);
 try
  SaveToStream(FileStream,aEntityIDs,aRootEntityID);
 finally
  FileStream.Free;
 end;
end;

function TpvEntityComponentSystem.TWorld.Assign(const aFrom:TWorld;const aEntityIDs:array of TEntityID;const aRootEntityID:TEntityID;const aAssignOp:TWorldAssignOp):TEntityID;
type TProcessBitmap=array of TpvUInt32;
var FromEntityID,EntityID:TEntityID;
    Index:TpvInt32;
    FromEntity,Entity:PEntity;
    NewEntityIDs:TEntityIDDynamicArray;
    FromEntityProcessBitmap:TProcessBitmap;
    DoRefresh:boolean;
begin

 result:=TEntityID.Invalid;

 FromEntityProcessBitmap:=nil;
 try

  if length(aEntityIDs)>0 then begin
   SetLength(FromEntityProcessBitmap,(aFrom.fMaxEntityIndex+31) shr 5);
   FillChar(FromEntityProcessBitmap[0],length(FromEntityProcessBitmap)*SizeOf(TpvUInt32),#0);
   for Index:=0 to length(aEntityIDs)-1 do begin
    EntityID:=aEntityIDs[Index];
    if{(EntityID>=0) and}(EntityID.Index<=aFrom.fMaxEntityIndex) then begin
     FromEntityProcessBitmap[EntityID.Index shr 5]:=FromEntityProcessBitmap[EntityID.Index shr 5] or (TpvUInt32(1) shl (EntityID.Index and 31));
    end;
   end;
  end;

  if aAssignOp=TWorldAssignOp.Replace then begin
   DoRefresh:=false;
   for Index:=0 to fMaxEntityIndex do begin
    if HasEntityIndex(Index) then begin
     Entity:=@fEntities[Index];
     if assigned(Entity) then begin
      EntityID:=Entity^.fID;
      FromEntity:=aFrom.GetEntityBySUID(Entity^.SUID);
      if (not assigned(FromEntity)) or
         (assigned(FromEntity) and
          ((length(FromEntityProcessBitmap)>0) and
           (({(FromEntity.ID.Index>=0) and}(FromEntity^.ID.Index<=aFrom.fMaxEntityIndex)) and
            ((FromEntityProcessBitmap[FromEntity^.ID.Index shr 5] and (TpvUInt32(1) shl (FromEntity^.ID.Index and 31)))=0)))) then begin
       Entity^.Kill;
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

   SetLength(NewEntityIDs,aFrom.fMaxEntityIndex+1);

   DoRefresh:=false;
   for Index:=0 to aFrom.fMaxEntityIndex do begin
    if aFrom.HasEntityIndex(Index) then begin
     FromEntity:=@aFrom.fEntities[Index];
     FromEntityID:=FromEntity^.fID;
     if assigned(FromEntity) and
        ((length(FromEntityProcessBitmap)=0) or
         (({(Index>=0) and}(Index<=aFrom.fMaxEntityIndex)) and
          ((FromEntityProcessBitmap[Index shr 5] and (TpvUInt32(1) shl (Index and 31)))<>0))) then begin
      if aAssignOp=TWorldAssignOp.Add then begin
       EntityID:=CreateEntity;
       DoRefresh:=true;
      end else begin
       Entity:=GetEntityBySUID(FromEntity^.SUID);
       if assigned(Entity) then begin
        EntityID:=Entity^.ID;
       end else begin
        EntityID:=CreateEntity(FromEntity^.SUID);
        DoRefresh:=true;
       end;
      end;
      NewEntityIDs[Index]:=EntityID;
      if (aRootEntityID<>TEntityID.Invalid) and (aRootEntityID=FromEntityID) then begin
       result:=EntityID;
      end;
     end else begin
      NewEntityIDs[Index]:=TEntityID.Invalid;
     end;
    end else begin
     NewEntityIDs[Index]:=TEntityID.Invalid;
    end;
   end;
   if DoRefresh then begin
    Refresh;
   end;

   FromEntityProcessBitmap:=nil;

   for Index:=0 to Min(aFrom.fMaxEntityIndex,Length(NewEntityIDs)-1) do begin
    EntityID:=NewEntityIDs[Index];
    if EntityID<>TEntityID.Invalid then begin
     FromEntity:=@aFrom.fEntities[Index];
     Entity:=GetEntityByID(EntityID);
     if aAssignOp in [TWorldAssignOp.Replace,TWorldAssignOp.Add] then begin
      Entity.Assign(FromEntity^,TEntityAssignOp.Replace,NewEntityIDs,false);
     end else begin
      Entity.Assign(FromEntity^,TEntityAssignOp.Combine,NewEntityIDs,false);
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

procedure TpvEntityComponentSystem.TWorld.Store;
var System:TpvEntityComponentSystem.TSystem;
begin
 for System in fSystemChoreography.fSortedSystemList do begin
  System.Store;
 end;
end;

procedure TpvEntityComponentSystem.TWorld.Interpolate(const aAlpha:TpvDouble);
var System:TpvEntityComponentSystem.TSystem;
begin
 for System in fSystemChoreography.fSortedSystemList do begin
  System.Interpolate(aAlpha);
 end;
end;

initialization

 TpvEntityComponentSystem.RegisteredComponentTypeList:=TpvEntityComponentSystem.TRegisteredComponentTypeList.Create;
 TpvEntityComponentSystem.RegisteredComponentTypeList.OwnsObjects:=true;

 TpvEntityComponentSystem.RegisteredComponentTypeNameHashMap:=TpvEntityComponentSystem.TRegisteredComponentTypeNameHashMap.Create(nil);

finalization

 FreeAndNil(TpvEntityComponentSystem.RegisteredComponentTypeList);

 FreeAndNil(TpvEntityComponentSystem.RegisteredComponentTypeNameHashMap);

end.

