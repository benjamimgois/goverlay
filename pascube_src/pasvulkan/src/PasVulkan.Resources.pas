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
unit PasVulkan.Resources;
{$i PasVulkan.inc}
{$ifndef fpc}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=24.0}
   {$legacyifend on}
  {$ifend}
 {$endif}
{$endif}
{$scopedenums on}
{$m+}

{$if defined(cpu386) or defined(cpuamd64) or defined(cpux86_64) or defined(cpux64)}
 {$define WordReadsAndWritesAreAtomic}
{$else}
 {$undef WordReadsAndWritesAreAtomic}
{$ifend}

interface

uses {$ifdef Windows}
      Windows,
     {$endif}
     SysUtils,
     Classes,
     syncobjs,
     Math,
     PasMP,
     PasJSON,
     PasVulkan.PooledObject,
     PasVulkan.Types,
     PasVulkan.Collections,
     PasVulkan.IDManager,
     PasVulkan.HighResolutionTimer;

type EpvResource=class(Exception);

     EpvResourceClass=class(EpvResource);

     EpvResourceClassNull=class(EpvResourceClass);

     EpvResourceClassMismatch=class(EpvResourceClass);

     TpvResourceManager=class;

     TpvResource=class;

     TpvResourceArray=array of TpvResource;

     TpvResourceHandle=TpvInt32;

     TpvResourceClass=class of TpvResource;

     TpvResourceClassType=class;

     TpvResourceWaitForMode=
      (
       Auto,
       Process,
       JustWait
      );

     TpvResourceBackgroundLoader=class;

     IpvResource=interface(IpvReferenceCountedObject)['{AD2C0315-C8AF-4D79-876E-1FA42FB869F9}']
      function GetResource:TpvResource;
      function GetResourceClass:TpvResourceClass;
      function WaitFor(const aWaitForMode:TpvResourceWaitForMode=TpvResourceWaitForMode.Auto):boolean;
     end;

     TpvResourceOnFinish=procedure(const aResource:TpvResource;const aSuccess:boolean) of object;

     TpvMetaResource=class;

     TpvMetaResourceClass=class of TpvMetaResource;

     TpvMetaResource=class //(TpvPooledObject)
      private
      protected
       fUUID:TpvUUID;
       fResourceLock:TPasMPSlimReaderWriterLock;
       fResource:TpvResource;
       fFileName:TpvUTF8String;
       fAssetName:TpvUTF8String;
       fName:TpvUTF8String;
       fTemporary:boolean;
      public
       constructor CreateTemporary; reintroduce; virtual;
      protected
       procedure SetUUID(const pUUID:TpvUUID);
       procedure SetFileName(const pFileName:TpvUTF8String);
       procedure SetAssetName(const pAssetName:TpvUTF8String);
       function GetResource:IpvResource; virtual;
      public
       constructor Create; reintroduce; virtual;
       constructor CreateNew(const pFileName:TpvUTF8String); reintroduce; virtual;
       destructor Destroy; override;
       function HasResourceInstance:boolean; virtual;
       procedure LoadFromStream(const pStream:TStream); virtual;
       procedure LoadFromFile(const pFileName:TpvUTF8String); virtual;
       function Clone(const pFileName:TpvUTF8String):TpvMetaResource; virtual;
       procedure Rename(const pFileName:TpvUTF8String); virtual;
       procedure Delete; virtual;
       property UUID:TpvUUID read fUUID write SetUUID;
       property Resource:IpvResource read GetResource;
       property FileName:TpvUTF8String read fFileName write SetFileName;
       property AssetName:TpvUTF8String read fAssetName write SetAssetName;
       property Name:TpvUTF8String read fName write fName;
       property Temporary:boolean read fTemporary write fTemporary;
     end;

     { TpvResource }

     TpvResource=class(TpvReferenceCountedObject,IpvResource)
      public
       type TAsyncLoadState=
             (
              None,
              Done,
              Queued,
              Loading,
              Success,
              Fail
             );
            PAsyncLoadState=^TAsyncLoadState;
            TParallelLoadable=
             (
              None,
              SameType,
              Always
             );
            PParallelLoadable=^TParallelLoadable;
       const VirtualFileNamePrefix:TpvUTF8String='virtual://';
      private
       fResourceManager:TpvResourceManager;
       fParent:TpvResource;
       fParents:TpvResourceArray;
       fResourceClassType:TpvResourceClassType;
       fHandle:TpvResourceHandle;
       fCreationIndex:TpvUInt64;
       fFileName:TpvUTF8String;
       fAsyncLoadState:TAsyncLoadState;
       fLoaded:boolean;
       fIsOnDelayedToFreeResourcesList:TPasMPBool32;
       fMemoryUsage:TpvUInt64;
       fMetaData:TPasJSONItem;
       fMetaResource:TpvMetaResource;
       fInstanceInterface:IpvResource;
       fOnFinish:TpvResourceOnFinish;
       fReleaseFrameDelay:TPasMPInt32; // for resources with frame-wise in-flight data stuff
       fIsAsset:boolean;
       fAssetBasePath:TpvUTF8String;
       fParallelLoadable:TParallelLoadable;
       procedure SetFileName(const aFileName:TpvUTF8String);
      protected
       function _AddRef:TpvInt32; override; {$ifdef Windows}stdcall{$else}cdecl{$endif};
       function _Release:TpvInt32; override; {$ifdef Windows}stdcall{$else}cdecl{$endif};
      public
       constructor Create(const aResourceManager:TpvResourceManager;const aParent:TpvResource=nil;const aMetaResource:TpvMetaResource=nil;const aParallelLoadable:TpvResource.TParallelLoadable=TpvResource.TParallelLoadable.None); reintroduce; virtual;
       destructor Destroy; override;
       procedure PrepareDeferredFree; virtual;
       procedure DeferredFree; virtual;
       procedure AfterConstruction; override;
       procedure BeforeDestruction; override;
       class function GetMetaResourceClass:TpvMetaResourceClass; virtual;
       function GetResource:TpvResource;
       function GetResourceClass:TpvResourceClass;
       function WaitFor(const aWaitForMode:TpvResourceWaitForMode=TpvResourceWaitForMode.Auto):boolean;
       function CreateNewFileStreamFromFileName(const aFileName:TpvUTF8String):TStream; virtual;
       function GetStreamFromFileName(const aFileName:TpvUTF8String):TStream; virtual;
       function LoadMetaData(const aStream:TStream):boolean; overload; virtual;
       function SaveMetaData(const aStream:TStream):boolean; overload; virtual;
       function LoadMetaData:boolean; overload; virtual;
       function SaveMetaData:boolean; overload; virtual;
       function BeginLoad(const aStream:TStream):boolean; virtual;
       function EndLoad:boolean; virtual;
       function Load(const aStream:TStream):boolean; virtual;
       function Save:boolean; virtual;
       procedure MarkAsLoaded; virtual;
       function LoadFromFileName(const aFileName:TpvUTF8String):boolean; virtual;
       function SaveToFileName(const aFileName:TpvUTF8String):boolean; virtual;
      public
       property InstanceInterface:IpvResource read fInstanceInterface;
       property MemoryUsage:TpvUInt64 read fMemoryUsage write fMemoryUsage;
      published
       property ResourceManager:TpvResourceManager read fResourceManager;
       property Parent:TpvResource read fParent;
       property ResourceClassType:TpvResourceClassType read fResourceClassType;
       property Handle:TpvResourceHandle read fHandle;
       property FileName:TpvUTF8String read fFileName write SetFileName;
       property AsyncLoadState:TAsyncLoadState read fAsyncLoadState write fAsyncLoadState;
       property Loaded:boolean read fLoaded write fLoaded;
       property MetaData:TPasJSONItem read fMetaData write fMetaData;
       property MetaResource:TpvMetaResource read fMetaResource write fMetaResource;
       property OnFinish:TpvResourceOnFinish read fOnFinish write fOnFinish;
       property ReleaseFrameDelay:TPasMPInt32 read fReleaseFrameDelay write fReleaseFrameDelay;
       property IsAsset:boolean read fIsAsset;
       property AssetBasePath:TpvUTF8String read fAssetBasePath;
     end;

     { TpvResourceDependencyNode }
     TpvResourceDependencyNode=class
      private
       fResource:TpvResource;
       fRemainingDependencyCount:TPasMPInt32;
       fDependentNodes:TpvDynamicArray<TpvResourceDependencyNode>;
      public
       constructor Create(const aResource:TpvResource);
       destructor Destroy; override;
       function DecrementDependencyCount:TpvInt32;
       procedure AddDependent(const aDependentNode:TpvResourceDependencyNode);
       property Resource:TpvResource read fResource;
       property RemainingDependencyCount:TPasMPInt32 read fRemainingDependencyCount;
     end;

     TpvResourceDependencyNodes=TpvDynamicArrayList<TpvResourceDependencyNode>;

     { TpvResourceDependencyDirectedAcyclicGraph }
     TpvResourceDependencyDirectedAcyclicGraph=class
      private
       type TNodesByResourceMap=TpvHashMap<TpvResource,TpvResourceDependencyNode>;
      private
       fNodesByResource:TNodesByResourceMap;
       fNodesByResourceCount:TPasMPInt32;
       fReadyToLoadNodes:TpvResourceDependencyNodes;
       fGraphLock:TPasMPMultipleReaderSingleWriterLock;
       fReadyNodesLock:TPasMPMultipleReaderSingleWriterLock;
      public
       constructor Create;
       destructor Destroy; override;
       function AddNode(const aResource:TpvResource;const aParentResource:TpvResource):TpvResourceDependencyNode;
       procedure MarkNodeComplete(const aNode:TpvResourceDependencyNode);
       function TakeReadyNodes(const aReadyNodes:TpvResourceDependencyNodes):boolean;
       function HasPendingNodes:Boolean;
     end;

     { TpvResourceBackgroundLoaderThread }
     TpvResourceBackgroundLoaderThread=class(TPasMPThread)
      public 
       const StateIdle=0;         // Thread is idle
             StateReady=1;        // Work is ready and waiting to be processed
             StateProcessing=2;   // Work is processing
             StateLocked=3;       // Locked by main thread
      private
       fEvent:TPasMPEvent;
       fResourceManager:TpvResourceManager;
       fBackgroundLoader:TpvResourceBackgroundLoader;
       fState:TPasMPUInt32;
       fLastWasWorking:TPasMPBool32;
      protected
       procedure Execute; override;
      public
       constructor Create(const aBackgroundLoader:TpvResourceBackgroundLoader); reintroduce;
       destructor Destroy; override;
       procedure Shutdown;
       function SynchronizationPoint:Boolean;
     end;

     { TpvResourceBackgroundLoader }

     TpvResourceBackgroundLoader=class
      public
       type TQueueItem=class
             public
              type TResourcArray=TpvDynamicArray<TpvResource>;
             private
              fResourceBackgroundLoader:TpvResourceBackgroundLoader;
              fResource:TpvResource;
              fSuccess:Boolean;
              fStream:TStream;
              fAutoFinalizeAfterLoad:TPasMPBool32;
             public
              constructor Create(const aResourceBackgroundLoader:TpvResourceBackgroundLoader;const aResource:TpvResource); reintroduce;
              destructor Destroy; override;
            end;
           TQueueItems=TpvDynamicArray<TQueueItem>;
           TQueueItemResourceMap=class(TpvHashMap<TpvResource,TQueueItem>);
           TQueueItemStringMap=class(TpvStringHashMap<TQueueItem>);
      private
       fResourceManager:TpvResourceManager;
       fPasMPInstance:TPasMP;
       fBackgroundLoaderThread:TpvResourceBackgroundLoaderThread;
       fEvent:TPasMPEvent;
       fLock:TPasMPSpinLock;
       fCountQueueItems:TPasMPInt32;
       fQueueItems:TQueueItems;
       fQueueItemLock:TPasMPSpinLock;
       fQueueItemResourceMap:TQueueItemResourceMap;
       fQueueItemResourceMapLock:TPasMPSpinLock;
       fToProcessQueueItems:TQueueItems;
       fRootJob:PPasMPJob;
       fDependencyGraph:TpvResourceDependencyDirectedAcyclicGraph;
      private
       procedure HandleLoadDependencyBatchMethod(const aJob:PPasMPJob;const aThreadIndex:TPasMPInt32;const aData:pointer;const aFromIndex,aToIndex:TPasMPNativeInt);
       procedure ProcessLoadingWithDirectedAcyclicGraph;
       procedure ProcessLoadingWithDirectedAcyclicGraphJobMethod(const aJob:PPasMPJob;const aThreadIndex:TPasMPInt32);
       function QueueResource(const aResource:TpvResource;const aParent:TpvResource):boolean;
       procedure FinalizeQueueItem(const aQueueItem:TQueueItem);
       procedure WaitForResource(const aResource:TpvResource;const aWaitForMode:TpvResourceWaitForMode=TpvResourceWaitForMode.Auto);
       function ProcessIteration(const aStartTime:TpvHighResolutionTime;const aTimeout:TpvInt64):boolean;
       function HasResourcesToFinish:boolean;
       function Process(const aTimeout:TpvInt64=5):boolean;
       function WaitForResources(const aTimeout:TpvInt64=-1):boolean;
       function GetCountOfQueuedResources:TpvSizeInt;
      private
       procedure PasMPProcess;
      public
       constructor Create(const aResourceManager:TpvResourceManager); reintroduce;
       destructor Destroy; override;
       procedure Shutdown;
      public
       property PasMPInstance:TPasMP read fPasMPInstance;
     end;

     TpvResourceClassType=class
      private
       type TResourceList=class(TpvObjectGenericList<TpvResource>);
            TResourceStringMap=class(TpvStringHashMap<TpvResource>);
      private
       fResourceManager:TpvResourceManager;
       fResourceClass:TpvResourceClass;
       fResourceListLock:TPasMPSlimReaderWriterLock;
       fResourceList:TResourceList;
       fResourceFileNameMapLock:TPasMPSlimReaderWriterLock;
       fResourceFileNameMap:TResourceStringMap;
       fMemoryBudget:TpvSizeInt;
       fMemoryUsage:TpvSizeInt;
      public
       constructor Create(const aResourceManager:TpvResourceManager;const aResourceClass:TpvResourceClass); reintroduce;
       destructor Destroy; override;
       procedure Shutdown;
      published
       property MemoryBudget:TpvSizeInt read fMemoryBudget write fMemoryBudget;
       property MemoryUsage:TpvSizeInt read fMemoryUsage;
     end;

     { TpvResourceManager }

     TpvResourceManager=class
      private
       type TResourceClassTypeList=class(TpvObjectGenericList<TpvResourceClassType>);
            TResourceClassTypeMap=class(TpvHashMap<TpvResourceClass,TpvResourceClassType>);
            TResourceList=class(TpvObjectGenericList<TpvResource>);
            TResourceHandleManager=class(TpvGenericIDManager<TpvResourceHandle>);
            TResourceHandleMap=array of TpvResource;
            TMetaResourceList=class(TpvObjectGenericList<TpvMetaResource>);
            TMetaResourceUUIDMap=class(TpvHashMap<TpvUUID,TpvMetaResource>);
            TMetaResourceFileNameMap=class(TpvStringHashMap<TpvMetaResource>);
            TMetaResourceAssetNameMap=class(TpvStringHashMap<TpvMetaResource>);
       function AllocateHandle(const aResource:TpvResource):TpvResourceHandle;
       procedure FreeHandle(const aHandle:TpvResourceHandle);
       function GetResourceByHandle(const aHandle:TpvResourceHandle):IpvResource;
       procedure SortDelayedToFreeResourcesByCreationIndices(const aLock:Boolean);
      private
       fLock:TPasMPMultipleReaderSingleWriterSpinLock;
       fCreationIndexCounterLock:TPasMPSlimReaderWriterLock;
       fLocked:TPasMPBool32;
       fActive:TPasMPBool32;
       fLoadLock:TPasMPCriticalSection;
       fCreationIndexCounter:TpvUInt64;
       fResourceClassTypeList:TResourceClassTypeList;
       fResourceClassTypeListLock:TPasMPMultipleReaderSingleWriterSpinLock;
       fResourceClassTypeMap:TResourceClassTypeMap;
       fResourceHandleLock:TPasMPMultipleReaderSingleWriterSpinLock;
       fResourceHandleManager:TResourceHandleManager;
       fResourceHandleMap:TResourceHandleMap;
       fMetaResourceLock:TPasMPMultipleReaderSingleWriterSpinLock;
       fMetaResourceList:TMetaResourceList;
       fMetaResourceUUIDMap:TMetaResourceUUIDMap;
       fMetaResourceFileNameMap:TMetaResourceFileNameMap;
       fMetaResourceAssetNameMap:TMetaResourceAssetNameMap;
       fDelayedToFreeResourcesLock:TPasMPCriticalSection;
       fDelayedToFreeResources:TResourceList;
       fBackgroundLoader:TpvResourceBackgroundLoader;
       fBaseDataPath:TpvUTF8String;
       function GetMetaResourceByUUID(const pUUID:TpvUUID):TpvMetaResource;
       function GetMetaResourceByFileName(const pFileName:TpvUTF8String):TpvMetaResource;
       function GetMetaResourceByAssetName(const pAssetName:TpvUTF8String):TpvMetaResource;
      public
       constructor Create;
       destructor Destroy; override;
       procedure Shutdown;
       procedure Process;
       class function SanitizeFileName(aFileName:TpvUTF8String):TpvUTF8String; static;
       procedure DestroyDelayedFreeingObjectsWithParent(const aObject:TObject);
       function GetResourceClassType(const aResourceClass:TpvResourceClass):TpvResourceClassType;
       function FindResource(const aResourceClass:TpvResourceClass;const aFileName:TpvUTF8String):TpvResource;
       function LoadResource(const aResourceClass:TpvResourceClass;const aFileName:TpvUTF8String;const aOnFinish:TpvResourceOnFinish=nil;const aLoadInBackground:boolean=false;const aParent:TpvResource=nil;const aParallelLoadable:TpvResource.TParallelLoadable=TpvResource.TParallelLoadable.None):TpvResource;
       function GetResource(const aResourceClass:TpvResourceClass;const aFileName:TpvUTF8String;const aOnFinish:TpvResourceOnFinish=nil):TpvResource;
       function BackgroundLoadResource(const aResourceClass:TpvResourceClass;const aFileName:TpvUTF8String;const aOnFinish:TpvResourceOnFinish=nil;const aParent:TpvResource=nil;const aParallelLoadable:TpvResource.TParallelLoadable=TpvResource.TParallelLoadable.None):TpvResource;
       procedure FreeDelayedToFreeResources;
       function TryAcquireSynchronizationLock:Boolean;
       procedure AcquireSynchronizationLock;
       procedure ReleaseSynchronizationLock;
       function SynchronizationPoint:Boolean;
       function FinishResources(const aTimeout:TpvInt64=1):boolean;
       function WaitForResources(const aTimeout:TpvInt64=-1):boolean;
       function GetNewUUID:TpvUUID;
       property ResourceClassTypes[const aResourceClass:TpvResourceClass]:TpvResourceClassType read GetResourceClassType;
       property Resources[const aResourceClass:TpvResourceClass;const aFileName:TpvUTF8String]:TpvResource read FindResource;
       property ResourceByHandle[const aHandle:TpvResourceHandle]:IpvResource read GetResourceByHandle; default;
       property BaseDataPath:TpvUTF8String read fBaseDataPath write fBaseDataPath;
       property MetaResourceByUUID[const pUUID:TpvUUID]:TpvMetaResource read GetMetaResourceByUUID;
       property MetaResourceByFileName[const pFileName:TpvUTF8String]:TpvMetaResource read GetMetaResourceByFileName;
       property MetaResourceByAssetName[const pAssetName:TpvUTF8String]:TpvMetaResource read GetMetaResourceByAssetName;
     end;

var AllowExternalResources:boolean=false;

procedure DeferredFreeAndNil(var aObject);

implementation

uses PasVulkan.PasMP,PasVulkan.Application,PasVulkan.Utils;

{ TpvMetaResource }

constructor TpvMetaResource.Create;
begin

 inherited Create;

 fUUID:=TpvUUID.Null;

 fResource:=nil;

 fResourceLock:=TPasMPSlimReaderWriterLock.Create;

 fFileName:='';

 fName:='';

 fTemporary:=false;

 pvApplication.ResourceManager.fMetaResourceLock.AcquireWrite;
 try
  pvApplication.ResourceManager.fMetaResourceList.Add(self);
 finally
  pvApplication.ResourceManager.fMetaResourceLock.ReleaseWrite;
 end;

end;

constructor TpvMetaResource.CreateTemporary;
begin
 Create;
 fTemporary:=true;
 SetUUID(pvApplication.ResourceManager.GetNewUUID);
end;

constructor TpvMetaResource.CreateNew(const pFileName:TpvUTF8String);
begin
 Create;
 SetUUID(pvApplication.ResourceManager.GetNewUUID);
 SetFileName(pFileName);
end;

destructor TpvMetaResource.Destroy;
begin

 FreeAndNil(fResource);

 pvApplication.ResourceManager.fMetaResourceLock.AcquireWrite;
 try
  if length(fFileName)>0 then begin
   pvApplication.ResourceManager.fMetaResourceFileNameMap.Delete(LowerCase(fFileName));
   fFileName:='';
  end;
  if length(fAssetName)>0 then begin
   pvApplication.ResourceManager.fMetaResourceAssetNameMap.Delete(LowerCase(fAssetName));
   fAssetName:='';
  end;
  if fUUID<>TpvUUID.Null then begin
   pvApplication.ResourceManager.fMetaResourceUUIDMap.Delete(fUUID);
   fUUID:=TpvUUID.Null;
  end;
  pvApplication.ResourceManager.fMetaResourceList.Remove(self);
 finally
  pvApplication.ResourceManager.fMetaResourceLock.ReleaseWrite;
 end;

 FreeAndNil(fResourceLock);

 inherited Destroy;
end;

procedure TpvMetaResource.SetUUID(const pUUID:TpvUUID);
begin
 if fUUID<>TpvUUID.Null then begin
  pvApplication.ResourceManager.fMetaResourceLock.AcquireWrite;
  try
   if fUUID<>TpvUUID.Null then begin
    pvApplication.ResourceManager.fMetaResourceUUIDMap.Delete(fUUID);
   end;
   if pUUID<>TpvUUID.Null then begin
    fUUID:=pUUID;
    pvApplication.ResourceManager.fMetaResourceUUIDMap.Add(pUUID,self);
   end;
  finally
   pvApplication.ResourceManager.fMetaResourceLock.ReleaseWrite;
  end;
 end;
end;

procedure TpvMetaResource.SetFileName(const pFileName:TpvUTF8String);
begin
 if fFileName<>pFileName then begin
  pvApplication.ResourceManager.fMetaResourceLock.AcquireWrite;
  try
   if length(fFileName)>0 then begin
    pvApplication.ResourceManager.fMetaResourceFileNameMap.Delete(LowerCase(fFileName));
   end;
   if length(pFileName)>0 then begin
    fFileName:=pFileName;
    pvApplication.ResourceManager.fMetaResourceFileNameMap.Add(LowerCase(pFileName),self);
   end;
  finally
   pvApplication.ResourceManager.fMetaResourceLock.ReleaseWrite;
  end;
 end;
 if length(pFileName)>0 then begin
  if copy(LowerCase(pFileName),1,length(pvApplication.Assets.BasePath))=LowerCase(pvApplication.Assets.BasePath) then begin
   SetAssetName(StringReplace(copy(pFileName,length(pvApplication.Assets.BasePath)+1,(length(pFileName)-length(pvApplication.Assets.BasePath))+1),'\','/',[rfReplaceAll]));
  end;
 end;
end;

procedure TpvMetaResource.SetAssetName(const pAssetName:TpvUTF8String);
begin
 if fAssetName<>pAssetName then begin
  pvApplication.ResourceManager.fMetaResourceLock.AcquireWrite;
  try
   if length(fAssetName)>0 then begin
    pvApplication.ResourceManager.fMetaResourceAssetNameMap.Delete(LowerCase(fAssetName));
   end;
   if length(pAssetName)>0 then begin
    fAssetName:=pAssetName;
    pvApplication.ResourceManager.fMetaResourceAssetNameMap.Add(LowerCase(pAssetName),self);
   end;
  finally
   pvApplication.ResourceManager.fMetaResourceLock.ReleaseWrite;
  end;
 end;
end;

function TpvMetaResource.GetResource:IpvResource;
begin
 fResourceLock.Acquire;
 try
  result:=fResource;
 finally
  fResourceLock.Release;
 end;
end;

function TpvMetaResource.HasResourceInstance:boolean;
begin
 result:=assigned(fResource);
end;

procedure TpvMetaResource.LoadFromStream(const pStream:TStream);
begin
end;

procedure TpvMetaResource.LoadFromFile(const pFileName:TpvUTF8String);
var FileStream:TFileStream;
begin
 FileStream:=TFileStream.Create(pFileName,fmOpenRead or fmShareDenyWrite);
 try
  LoadFromStream(FileStream);
  SetFileName(pFileName);
 finally
  FileStream.Free;
 end;
end;

function TpvMetaResource.Clone(const pFileName:TpvUTF8String):TpvMetaResource;
var MetaResourceClass:TpvMetaResourceClass;
begin
 MetaResourceClass:=TpvMetaResourceClass(ClassType);
 result:=MetaResourceClass.Create;
 result.SetUUID(pvApplication.ResourceManager.GetNewUUID);
 result.SetFileName(pFileName);
end;

procedure TpvMetaResource.Rename(const pFileName:TpvUTF8String);
begin
 if length(fFileName)>0 then begin
  RenameFile(fFileName,pFileName);
  SetFileName(pFileName);
 end;
end;

procedure TpvMetaResource.Delete;
begin
 if length(fFileName)>0 then begin
  DeleteFile(fFileName);
 end;
 Free;
end;

{ TpvResource }

constructor TpvResource.Create(const aResourceManager:TpvResourceManager;const aParent:TpvResource;const aMetaResource:TpvMetaResource;const aParallelLoadable:TpvResource.TParallelLoadable);
var OldReferenceCounter:TpvInt32;
    CountParents:TpvSizeInt;
    Current:TpvResource;
begin
 inherited Create;

 fResourceManager:=aResourceManager;

 fParent:=aParent;

 fParallelLoadable:=aParallelLoadable;

 CountParents:=0;
 Current:=fParent;
 while assigned(Current) do begin
  inc(CountParents);
  Current:=Current.fParent;
 end;

 fParents:=nil;
 if CountParents>0 then begin
  SetLength(fParents,CountParents);
  CountParents:=0;
  Current:=fParent;
  while assigned(Current) do begin
   fParents[CountParents]:=Current;
   inc(CountParents);
   Current:=Current.fParent;
  end;
 end;

 fHandle:=fResourceManager.AllocateHandle(self);

 fFileName:='';

 fAsyncLoadState:=TAsyncLoadState.None;

 fLoaded:=false;

 fIsOnDelayedToFreeResourcesList:=false;

 fMemoryUsage:=0;

 fMetaData:=nil;

 fOnFinish:=nil;

 fReleaseFrameDelay:=0;

 fMetaResource:=aMetaResource;
 if not assigned(fMetaResource) then begin
  fMetaResource:=GetMetaResourceClass.CreateTemporary;
 end;
 if assigned(fMetaResource) then begin
  TPasMPInterlocked.Write(TObject(fMetaResource.fResource),TObject(self));
 end;

 OldReferenceCounter:=fReferenceCounter;
 try
  fInstanceInterface:=self;
 finally
  fReferenceCounter:=OldReferenceCounter;
 end;

 fResourceClassType:=fResourceManager.GetResourceClassType(TpvResourceClass(ClassType));

 if assigned(fResourceManager) then begin
  fResourceManager.fCreationIndexCounterLock.Acquire;
  try
   fCreationIndex:=fResourceManager.fCreationIndexCounter;
   inc(fResourceManager.fCreationIndexCounter);
  finally
   fResourceManager.fCreationIndexCounterLock.Release;
  end;
 end;

 if assigned(fResourceManager) and assigned(fResourceClassType) then begin
  fResourceClassType.fResourceListLock.Acquire;
  try
   fResourceClassType.fResourceList.Add(self);
  finally
   fResourceClassType.fResourceListLock.Release;
  end;
 end;

 fIsAsset:=false;

 fAssetBasePath:='';

end;

destructor TpvResource.Destroy;
var Index:TpvSizeInt;
begin

 if assigned(fResourceManager) and
    (assigned(fResourceClassType) or
     (fIsOnDelayedToFreeResourcesList and assigned(fResourceManager.fDelayedToFreeResources))) then begin

  fResourceManager.fLock.AcquireWrite;
  try

   if assigned(fResourceClassType) then begin
    fResourceClassType.fResourceListLock.Acquire;
    try
     fResourceClassType.fResourceList.Remove(self);
    finally
     fResourceClassType.fResourceListLock.Release;
    end;
   end;

   if fIsOnDelayedToFreeResourcesList and assigned(fResourceManager.fDelayedToFreeResources) then begin
    try
     fResourceManager.fDelayedToFreeResourcesLock.Acquire;
     try
      Index:=fResourceManager.fDelayedToFreeResources.IndexOf(self);
      if Index>=0 then begin
       fResourceManager.fDelayedToFreeResources.Extract(Index);
      end;
     finally
      fResourceManager.fDelayedToFreeResourcesLock.Release;
     end;
    finally
     fIsOnDelayedToFreeResourcesList:=false;
    end;
   end;

  finally
   fResourceManager.fLock.ReleaseWrite;
  end;

 end;

 SetFileName('');

 FreeAndNil(fMetaData);

 if assigned(fMetaResource) then begin
  TPasMPInterlocked.Write(TObject(fMetaResource.fResource),nil);
 end;

 if assigned(fResourceManager) then begin
  fResourceManager.FreeHandle(fHandle);
 end;

 fHandle:=0;

 if assigned(fMetaResource) and fMetaResource.fTemporary then begin
  FreeAndNil(fMetaResource);
 end;

 fParents:=nil;

 FillChar(fInstanceInterface,SizeOf(IpvResource),0);

 inherited Destroy;

end;

procedure TpvResource.PrepareDeferredFree;
begin
end;

procedure TpvResource.DeferredFree;
begin
 if assigned(self) then begin
  if (fReleaseFrameDelay>0) and
     assigned(fResourceManager) and
     fResourceManager.fActive and
     assigned(fResourceManager.fDelayedToFreeResources) and not fIsOnDelayedToFreeResourcesList then begin
   try
    PrepareDeferredFree;
   finally
    try
     fResourceManager.fDelayedToFreeResourcesLock.Acquire;
     try
      fResourceManager.fDelayedToFreeResources.Add(self);
     finally
      fResourceManager.fDelayedToFreeResourcesLock.Release;
     end;
    finally
     fIsOnDelayedToFreeResourcesList:=true;
    end;
   end;
  end else begin
   Destroy;
  end;
 end;
end;

procedure TpvResource.SetFileName(const aFileName:TpvUTF8String);
var NewFileName:TpvUTF8String;
    OldReferenceCounter:TpvInt32;
begin
 NewFileName:=TpvResourceManager.SanitizeFileName(aFileName);
 if fFileName<>NewFileName then begin
  if assigned(fResourceClassType) then begin
   fResourceClassType.fResourceFileNameMapLock.Acquire;
  end;
  try
   OldReferenceCounter:=fReferenceCounter;
   try
    inc(fReferenceCounter,2); // For to avoid false-positive frees in this situation
    if assigned(fResourceClassType) and (length(fFileName)>0) then begin
     fResourceClassType.fResourceFileNameMap.Delete(TpvUTF8String(LowerCase(String(fFileName))));
    end;
    fFileName:=NewFileName;
    if assigned(fResourceClassType) and (length(fFileName)>0) then begin
     fResourceClassType.fResourceFileNameMap.Add(TpvUTF8String(LowerCase(String(fFileName))),self);
    end;
   finally
    fReferenceCounter:=OldReferenceCounter;
   end;
  finally
   if assigned(fResourceClassType) then begin
    fResourceClassType.fResourceFileNameMapLock.Release;
   end;
  end;
 end;
end;

procedure TpvResource.AfterConstruction;
begin
 inherited AfterConstruction;
end;

procedure TpvResource.BeforeDestruction;
begin
 inherited BeforeDestruction;
end;

class function TpvResource.GetMetaResourceClass:TpvMetaResourceClass;
begin
 result:=TpvMetaResource;
end;

function TpvResource._AddRef:TpvInt32;
begin
 result:=inherited _AddRef;
end;

function TpvResource._Release:TpvInt32;
begin
 if (fReleaseFrameDelay>0) and assigned(fResourceManager) and fResourceManager.fActive and assigned(fResourceManager.fDelayedToFreeResources) and not fIsOnDelayedToFreeResourcesList then begin
  result:=TPasMPInterlocked.Decrement(fReferenceCounter);
  if result=0 then begin
   if assigned(fMetaResource) then begin
    fMetaResource.fResourceLock.Acquire;
   end;
   try
    try
     PrepareDeferredFree;
    finally
     try
      fResourceManager.fDelayedToFreeResourcesLock.Acquire;
      try
       fResourceManager.fDelayedToFreeResources.Add(self);
      finally
       fResourceManager.fDelayedToFreeResourcesLock.Release;
      end;
     finally
      fIsOnDelayedToFreeResourcesList:=true;
     end;
    end;
   finally
    if assigned(fMetaResource) and assigned(fMetaResource.fResourceLock) then begin
     fMetaResource.fResourceLock.Release;
    end;
   end;
  end;
 end else begin
  result:=inherited _Release;
 end;
end;

function TpvResource.GetResource:TpvResource;
begin
 result:=self;
end;

function TpvResource.GetResourceClass:TpvResourceClass;
begin
 result:=TpvResourceClass(ClassType);
end;

function TpvResource.WaitFor(const aWaitForMode:TpvResourceWaitForMode=TpvResourceWaitForMode.Auto):boolean;
begin
 result:=fLoaded;
 if (not result) and
    assigned(fResourceManager) and
    assigned(fResourceManager.fBackgroundLoader) then begin
  fResourceManager.fBackgroundLoader.WaitForResource(self,aWaitForMode);
  result:=fLoaded;
 end;
end;

function TpvResource.CreateNewFileStreamFromFileName(const aFileName:TpvUTF8String):TStream;
begin
 result:=TFileStream.Create(IncludeTrailingPathDelimiter(String(fResourceManager.fBaseDataPath))+String(TpvResourceManager.SanitizeFileName(aFileName)),fmCreate);
 fIsAsset:=false;
end;

function TpvResource.GetStreamFromFileName(const aFileName:TpvUTF8String):TStream;
var SanitizedFileName:TpvUTF8String;
begin
 SanitizedFileName:=TpvResourceManager.SanitizeFileName(aFileName);
 if pvApplication.Assets.ExistAsset(String(SanitizedFileName)) then begin
  result:=pvApplication.Assets.GetAssetStream(String(SanitizedFileName));
  fIsAsset:=true;
  fAssetBasePath:=PasVulkan.Utils.ExtractFilePath(SanitizedFileName);
 end else begin
  if FileExists(String(SanitizedFileName)) then begin
   result:=TFileStream.Create(String(SanitizedFileName),fmOpenRead or fmShareDenyNone);
   fIsAsset:=false;
  end else begin
   result:=nil;
  end;
 end;
end;

function TpvResource.LoadMetaData(const aStream:TStream):boolean;
begin
 FreeAndNil(fMetaData);
 if assigned(aStream) and (aStream.Size>0) then begin
  fMetaData:=TPasJSON.Parse(aStream);
  result:=assigned(fMetaData);
 end else begin
  result:=false;
 end;
end;

function TpvResource.SaveMetaData(const aStream:TStream):boolean;
var Data:TpvRawByteString;
begin
 if assigned(aStream) and assigned(fMetaData) then begin
  Data:=TPasJSON.Stringify(fMetaData);
  if length(Data)>0 then begin
   aStream.WriteBuffer(Data[1],length(Data));
   result:=true;
  end else begin
   result:=false;
  end;
 end else begin
  result:=false;
 end;
end;

function TpvResource.LoadMetaData:boolean;
var MetaFileName:TpvUTF8String;
    Stream:TStream;
begin
 MetaFileName:=TpvResourceManager.SanitizeFileName(TpvUTF8String(ChangeFileExt(String(fFileName),'.meta')));
 Stream:=GetStreamFromFileName(MetaFileName);
 if assigned(Stream) then begin
  try
   result:=LoadMetaData(Stream);
  finally
   FreeAndNil(Stream);
  end;
 end else begin
  result:=false;
 end;
end;

function TpvResource.SaveMetaData:boolean;
var MetaFileName:TpvUTF8String;
    Stream:TStream;
begin
 MetaFileName:=TpvResourceManager.SanitizeFileName(TpvUTF8String(ChangeFileExt(String(fFileName),'.meta')));
 if assigned(fMetaData) then begin
  Stream:=CreateNewFileStreamFromFileName(MetaFileName);
  try
   result:=SaveMetaData(Stream);
  finally
   FreeAndNil(Stream);
  end;
 end else begin
  result:=false;
 end;
end;

function TpvResource.BeginLoad(const aStream:TStream):boolean;
begin
 result:=false;
end;

function TpvResource.EndLoad:boolean;
begin
 result:=true;
end;

function TpvResource.Load(const aStream:TStream):boolean;
var ThreadID:TThreadID;
begin
 result:=fLoaded;
 if not result then begin
  ThreadID:=GetCurrentThreadID;
  if (ThreadID=MainThreadID) or
     (assigned(fResourceManager.fBackgroundLoader) and
      assigned(fResourceManager.fBackgroundLoader.fBackgroundLoaderThread) and
      (ThreadID=fResourceManager.fBackgroundLoader.fBackgroundLoaderThread.ThreadID)) then begin
   fAsyncLoadState:=TAsyncLoadState.Done;
  end else begin
   fAsyncLoadState:=TAsyncLoadState.Loading;
  end;
  LoadMetaData;
  fResourceManager.fLoadLock.Acquire;
  try
   result:=BeginLoad(aStream);
   if result then begin
    result:=EndLoad;
    fAsyncLoadState:=TAsyncLoadState.Done;
    if result then begin
     fLoaded:=true;
    end;
   end;
  finally
   fResourceManager.fLoadLock.Release;
  end;
 end;
end;

function TpvResource.Save:boolean;
begin
 result:=false;
end;

procedure TpvResource.MarkAsLoaded;
begin
 fLoaded:=true;
 fAsyncLoadState:=TAsyncLoadState.Done;
end;

function TpvResource.LoadFromFileName(const aFileName:TpvUTF8String):boolean;
var SanitizedFileName:TpvUTF8String;
    Stream:TStream;
begin
 SanitizedFileName:=TpvResourceManager.SanitizeFileName(aFileName);
 Stream:=GetStreamFromFileName(SanitizedFileName);
 if assigned(Stream) then begin
  try
   result:=Load(Stream);
   if result then begin
    SetFileName(SanitizedFileName);
   end;
  finally
   FreeAndNil(Stream);
  end;
 end else begin
  result:=false;
 end;
end;

function TpvResource.SaveToFileName(const aFileName:TpvUTF8String):boolean;
begin
 SetFileName(TpvResourceManager.SanitizeFileName(aFileName));
 result:=Save;
end;

{ TpvResourceDependencyNode }

constructor TpvResourceDependencyNode.Create(const aResource:TpvResource);
begin
 inherited Create;
 fResource:=aResource;
 fRemainingDependencyCount:=0;
 fDependentNodes.Initialize;
end;

destructor TpvResourceDependencyNode.Destroy;
begin
 fDependentNodes.Finalize;
 inherited Destroy;
end;

function TpvResourceDependencyNode.DecrementDependencyCount:TpvInt32;
begin
 result:=TPasMPInterlocked.Decrement(fRemainingDependencyCount);
end;

procedure TpvResourceDependencyNode.AddDependent(const aDependentNode:TpvResourceDependencyNode);
begin
 fDependentNodes.Add(aDependentNode);
end;

{ TpvResourceDependencyDirectedAcyclicGraph }

constructor TpvResourceDependencyDirectedAcyclicGraph.Create;
begin
 inherited Create;
 fNodesByResource:=TNodesByResourceMap.Create(nil);
 fNodesByResourceCount:=0;
 fReadyToLoadNodes:=TpvResourceDependencyNodes.Create;
 fGraphLock:=TPasMPMultipleReaderSingleWriterLock.Create;
 fReadyNodesLock:=TPasMPMultipleReaderSingleWriterLock.Create;
end;

destructor TpvResourceDependencyDirectedAcyclicGraph.Destroy;
var CurrentNode:TpvResourceDependencyNode;
begin

 for CurrentNode in fNodesByResource.Values do begin
  CurrentNode.Free;
 end;

 FreeAndNil(fNodesByResource);
 FreeAndNil(fReadyToLoadNodes);
 FreeAndNil(fReadyNodesLock);
 FreeAndNil(fGraphLock);

 inherited Destroy;

end;

function TpvResourceDependencyDirectedAcyclicGraph.AddNode(const aResource:TpvResource;const aParentResource:TpvResource):TpvResourceDependencyNode;
var ParentNode,NewNode:TpvResourceDependencyNode;
    EnqueueReadyNode:boolean;
begin

 EnqueueReadyNode:=false;

 fGraphLock.AcquireWrite;
 try

  // Get or create the child node
  if not fNodesByResource.TryGet(aResource,NewNode) then begin
   NewNode:=TpvResourceDependencyNode.Create(aResource);
   fNodesByResource.Add(aResource,NewNode);
   TPasMPInterlocked.Increment(fNodesByResourceCount);
  end;

  if assigned(aParentResource) then begin
   // Check if parent is already loaded - if so, no need to wait
   if aParentResource.fLoaded then begin
    // Parent already loaded, child can start immediately
    EnqueueReadyNode:=true;
   end else begin
    // Only create dependency if parent already exists in graph
    if fNodesByResource.TryGet(aParentResource,ParentNode) then begin
     // Parent exists - link child to parent
     TPasMPInterlocked.Increment(NewNode.fRemainingDependencyCount);
     ParentNode.AddDependent(NewNode);
    end else begin
     // Parent not in graph - no dependency, child can load immediately
     // This is expected when application queues resources in wrong order
     pvApplication.Log(LOG_DEBUG,'TpvResourceDependencyDirectedAcyclicGraph.AddNode','Parent resource not in graph - child will load without waiting for parent');
     EnqueueReadyNode:=true;
    end;
   end;
  end else begin
   // No parent = ready to load immediately
   EnqueueReadyNode:=true;
  end;

 finally
  fGraphLock.ReleaseWrite;
 end;

 if EnqueueReadyNode then begin
  fReadyNodesLock.AcquireWrite;
  try
   fReadyToLoadNodes.Add(NewNode);
  finally
   fReadyNodesLock.ReleaseWrite;
  end;
 end;

 result:=NewNode;

end;

procedure TpvResourceDependencyDirectedAcyclicGraph.MarkNodeComplete(const aNode:TpvResourceDependencyNode);
var DependentIndex:TpvSizeInt;
    DependentNode:TpvResourceDependencyNode;
    NewDependencyCount:TpvInt32;
begin

 for DependentIndex:=0 to aNode.fDependentNodes.Count-1 do begin
  DependentNode:=aNode.fDependentNodes.Items[DependentIndex];
  NewDependencyCount:=DependentNode.DecrementDependencyCount;
  if NewDependencyCount=0 then begin
   fReadyNodesLock.AcquireWrite;
   try
    fReadyToLoadNodes.Add(DependentNode);
   finally
    fReadyNodesLock.ReleaseWrite;
   end;
  end;
 end;

 fGraphLock.AcquireWrite;
 try
  fNodesByResource.Delete(aNode.fResource);
  TPasMPInterlocked.Decrement(fNodesByResourceCount);
 finally
  fGraphLock.ReleaseWrite;
 end;

 aNode.Free;

end;

function TpvResourceDependencyDirectedAcyclicGraph.TakeReadyNodes(const aReadyNodes:TpvResourceDependencyNodes):boolean;
var Index:TpvSizeInt;
    Node:TpvResourceDependencyNode;
    FirstResource,CurrentResource:TpvResource;
    CanAddToBatch:Boolean;    
begin

 result:=false;

 fReadyNodesLock.AcquireWrite;
 try
 
  // Get first resource in the aReadyNodes list, if any from previous calls, otherwise nil 
  if aReadyNodes.Count>0 then begin
   FirstResource:=aReadyNodes.Items[0].fResource;
  end else begin
   FirstResource:=nil;  
  end;
  
  // Iterate backwards through ready to load nodes
  for Index:=fReadyToLoadNodes.Count-1 downto 0 do begin

   // Get the node
   Node:=fReadyToLoadNodes.Items[Index];

   // Only remove if actually ready
   if TPasMPInterlocked.Read(Node.fRemainingDependencyCount)=0 then begin

    // Get the current resource of the node
    CurrentResource:=Node.fResource;

    // Check if there is a first resource in the batch 
    if assigned(FirstResource) then begin
     
     // Check if compatible with first resource in batch
     case FirstResource.fParallelLoadable of

      // No parallel loading
      TpvResource.TParallelLoadable.None:begin
       CanAddToBatch:=false;
      end;

      // Always parallel loadable, when other is also always parallel loadable
      TpvResource.TParallelLoadable.Always:begin
       CanAddToBatch:=CurrentResource.fParallelLoadable=TpvResource.TParallelLoadable.Always;
      end;

      // Same type parallel loadable, when other is also same type parallel loadable and of same class type
      TpvResource.TParallelLoadable.SameType:begin
       CanAddToBatch:=(CurrentResource.fParallelLoadable=TpvResource.TParallelLoadable.SameType) and
                      (CurrentResource.ClassType=FirstResource.ClassType);
      end;    

      // Default case - should not happen, it should just suppress a possible compiler warning            
      else begin
       pvApplication.Log(LOG_DEBUG,'TakeReadyNodes','Unexpected ParallelLoadable value: '+IntToStr(Ord(FirstResource.fParallelLoadable)));
       CanAddToBatch:=false;
      end;

     end;

    end else begin

     // Set the first resource in the batch, for further compatibility checks, when it is not yet set
     FirstResource:=CurrentResource;

     // No first resource yet, so this one can be added
     CanAddToBatch:=true;

    end;

    // If it can be added, then add it to aReadyNodes
    if CanAddToBatch then begin

     // Ready - remove from the list by swapping with last and deleting last
     if (Index+1)<fReadyToLoadNodes.Count then begin
      fReadyToLoadNodes.Exchange(Index,fReadyToLoadNodes.Count-1);
      fReadyToLoadNodes.Delete(fReadyToLoadNodes.Count-1);
     end else begin
      fReadyToLoadNodes.Delete(Index);
     end;
     
     // Add to the output list
     aReadyNodes.Add(Node);
     
     // Indicate that at least one node was taken
     result:=true;

    end else begin
     
     // Otherwise check if it is non-parallel loadable, then stop processing further nodes, as they will 
     // also be incompatible

     if assigned(FirstResource) and (FirstResource.fParallelLoadable=TpvResource.TParallelLoadable.None) then begin
      // First resource is non-parallel, stop taking more
      break;
     end;     

    end;     

   end else begin

    // Not ready yet - leave it in the list
    // This should never happen if graph logic is correct
    pvApplication.Log(LOG_DEBUG,'TpvResourceDependencyDirectedAcyclicGraph.TakeReadyNodes','Node $'+IntToHex(TpvPtrUInt(Node))+' in ready queue still has pending dependencies (count='+IntToStr(Node.fRemainingDependencyCount)+')');

   end;

  end;

 finally
  fReadyNodesLock.ReleaseWrite;
 end;

end;

function TpvResourceDependencyDirectedAcyclicGraph.HasPendingNodes:Boolean;
begin
 result:=TPasMPInterlocked.Read(fNodesByResourceCount)>0;
 if not result then begin
  fReadyNodesLock.AcquireRead;
  try
   result:=fReadyToLoadNodes.Count>0;
  finally
   fReadyNodesLock.ReleaseRead;
  end;
 end;
end;

{ TpvResourceBackgroundLoader.TQueueItem }

constructor TpvResourceBackgroundLoader.TQueueItem.Create(const aResourceBackgroundLoader:TpvResourceBackgroundLoader;const aResource:TpvResource);
begin
 inherited Create;
 fResourceBackgroundLoader:=aResourceBackgroundLoader;
 fResource:=aResource;
 fStream:=nil;
 fAutoFinalizeAfterLoad:=true;
 fResourceBackgroundLoader.fQueueItemLock.Acquire;
 try
  fResourceBackgroundLoader.fQueueItems.Add(self);
 finally
  fResourceBackgroundLoader.fQueueItemLock.Release;
 end;
 if assigned(fResourceBackgroundLoader) and assigned(fResource) then begin
  fResourceBackgroundLoader.fQueueItemResourceMapLock.Acquire;
  try
   fResourceBackgroundLoader.fQueueItemResourceMap.Add(fResource.GetResource,self);
  finally
   fResourceBackgroundLoader.fQueueItemResourceMapLock.Release;
  end;
 end;
 TPasMPInterlocked.Increment(fResourceBackgroundLoader.fCountQueueItems);
end;

destructor TpvResourceBackgroundLoader.TQueueItem.Destroy;
var Index:TpvSizeInt;
begin
 TPasMPInterlocked.Decrement(fResourceBackgroundLoader.fCountQueueItems);
 if assigned(fResourceBackgroundLoader) then begin
  try
   if assigned(fResource) then begin
    fResourceBackgroundLoader.fQueueItemResourceMapLock.Acquire;
    try
     fResourceBackgroundLoader.fQueueItemResourceMap.Delete(fResource.GetResource);
    finally
     fResourceBackgroundLoader.fQueueItemResourceMapLock.Release;
    end;
   end;
  finally
   fResourceBackgroundLoader.fQueueItemLock.Acquire;
   try
    for Index:=0 to fResourceBackgroundLoader.fQueueItems.Count-1 do begin
     if fResourceBackgroundLoader.fQueueItems.Items[Index]=self then begin
      fResourceBackgroundLoader.fQueueItems.Delete(Index);
      break;
     end;
    end;
   finally
    fResourceBackgroundLoader.fQueueItemLock.Release;
   end;
  end;
 end;
 FreeAndNil(fStream);
 fResource:=nil;
 inherited Destroy;
end;

{ TpvResourceBackgroundLoaderThread }

constructor TpvResourceBackgroundLoaderThread.Create(const aBackgroundLoader:TpvResourceBackgroundLoader);
begin
 fBackgroundLoader:=aBackgroundLoader;
 fResourceManager:=fBackgroundLoader.fResourceManager;
 fEvent:=TPasMPEvent.Create(nil,false,false,'');
 fState:=StateIdle;
 fLastWasWorking:=false;
 inherited Create(false);
end;

destructor TpvResourceBackgroundLoaderThread.Destroy;
begin
 Shutdown;
 FreeAndNil(fEvent);
 inherited Destroy;
end;

procedure TpvResourceBackgroundLoaderThread.Shutdown;
begin
 if not Finished then begin
  Terminate;
  while fState<>StateIdle do begin
   Sleep(1);
  end;
  fEvent.SetEvent;
  WaitFor;
 end;
end;

procedure TpvResourceBackgroundLoaderThread.Execute;
begin
{$if declared(NameThreadForDebugging)}
 NameThreadForDebugging('TpvResourceBackgroundLoaderThread');
{$ifend}
 while not Terminated do begin
  if fEvent.WaitFor(1000)=TWaitResult.wrSignaled then begin
   if Terminated then begin
    TPasMPInterlocked.Write(fState,StateIdle);
    break;
   end else begin
    if TPasMPInterlocked.CompareExchange(fState,StateProcessing,StateReady)=StateReady then begin
     try
      fBackgroundLoader.Process(pvApplication.BackgroundResourceLoaderFrameTimeout);
     finally
      TPasMPInterlocked.Write(fState,StateIdle);
     end;
    end;
   end;
  end;
 end;
end;

function TpvResourceBackgroundLoaderThread.SynchronizationPoint:Boolean;
begin

 // Check if it is still processing from previous spawn
 case TPasMPInterlocked.Read(fState) of

  StateReady,StateProcessing:begin
  
   // Still working and indicate that to the caller
   result:=true;

  end;

  StateLocked:begin

   // Locked by the main thread
   result:=false;

  end;

  else begin

   fResourceManager.Process;

   fResourceManager.FreeDelayedToFreeResources;

   // Not working, check if there are resources to finish
   if (not (Terminated or fLastWasWorking)) and fBackgroundLoader.HasResourcesToFinish then begin

    // When there are resources to finish, then try to wake up the thread, and if successful, indicate that it is now working, so that
    // the actual game or application logic can wait for it to finish in this execution frame by skipping its own processing for this
    // execution frame. This ensures that GPU resources are not used from multiple threads simultaneously at uploading the resources
    // to the GPU, but while the message event loop is still running in the main thread, so that the application does not hang for
    // the duration of the resource loading from the prespective of the operating system. Not optimal but better than nothing.

    result:=TPasMPInterlocked.CompareExchange(fState,StateReady,StateIdle)=StateIdle;
    if result then begin
     
     // Wake up the background loader thread to finish resources
     fEvent.SetEvent;

     // Indicate that it was working in this execution frame so that next execution frame it can continue normal processing 
     // for one execution frame, so that the application does not hang from the perspective of the user visually.
     fLastWasWorking:=true; 

    end;

   end else begin

    // Otherwise not working and no resources to finish, then the actual game or application logic can continue in this execution frame

    // Indicate that it was not working in this execution frame, so that next execution frame it can try to wake up the background
    // loader thread again to finish resources. Just ping-ponging where both the application and the background loader thread get
    // some time to run.
    fLastWasWorking:=false;

    result:=false;

   end;

  end;

 end;

end;

{ TpvResourceBackgroundLoader }

constructor TpvResourceBackgroundLoader.Create(const aResourceManager:TpvResourceManager);
var Index:TpvSizeInt;
    AvailableCPUCores:TPasMPAvailableCPUCores;
begin

 fResourceManager:=aResourceManager;

 fPasMPInstance:=TPasMP.Create(1,-1,-1,0,false,true,true,false,TThreadPriority.tpNormal,0,0);

 fBackgroundLoaderThread:=TpvResourceBackgroundLoaderThread.Create(self);

 fEvent:=TPasMPEvent.Create(nil,false,false,'');

 fLock:=TPasMPSpinLock.Create;

 fCountQueueItems:=0;

 fQueueItems.Initialize;

 fQueueItemLock:=TPasMPSpinLock.Create;

 fQueueItemResourceMap:=TQueueItemResourceMap.Create(nil);

 fQueueItemResourceMapLock:=TPasMPSpinLock.Create;

 fToProcessQueueItems.Initialize;

 fDependencyGraph:=TpvResourceDependencyDirectedAcyclicGraph.Create;

 fRootJob:=nil;

 inherited Create;

end;

destructor TpvResourceBackgroundLoader.Destroy;
begin

 if assigned(fRootJob) then begin
  try
   pvApplication.PasMPInstance.WaitRelease(fRootJob);
  finally
   fRootJob:=nil;
  end;
 end;

 fBackgroundLoaderThread.Shutdown;
 FreeAndNil(fBackgroundLoaderThread); 

 fToProcessQueueItems.Finalize;

 while fQueueItems.Count>0 do begin
  fQueueItems.Items[0].Free;
 end;
 fQueueItems.Finalize;

 fCountQueueItems:=0;

 FreeAndNil(fQueueItemLock);

 FreeAndNil(fQueueItemResourceMap);

 FreeAndNil(fQueueItemResourceMapLock);

 FreeAndNil(fDependencyGraph);

 FreeAndNil(fEvent);

 FreeAndNil(fLock);

 FreeAndNil(fPasMPInstance);

 inherited Destroy;

end;

procedure TpvResourceBackgroundLoader.Shutdown;
begin
 if assigned(fRootJob) then begin
  try
   fPasMPInstance.WaitRelease(fRootJob);
  finally
   fRootJob:=nil;
  end;
 end;
end;

procedure TpvResourceBackgroundLoader.HandleLoadDependencyBatchMethod(const aJob:PPasMPJob;const aThreadIndex:TPasMPInt32;const aData:pointer;const aFromIndex,aToIndex:TPasMPNativeInt);
var Index:TPasMPNativeInt;
    Node:TpvResourceDependencyNode;
    Resource:TpvResource;
    Stream:TStream;
    Success:Boolean;
    Batch:TpvResourceDependencyNodes;
/// QueueItem:TQueueItem;
begin
 Batch:=TpvResourceDependencyNodes(aData);

 for Index:=aFromIndex to aToIndex do begin

  Node:=Batch.Items[Index];

  Resource:=Node.Resource;
  Resource.fAsyncLoadState:=TpvResource.TAsyncLoadState.Loading;

  Stream:=Resource.GetStreamFromFileName(Resource.fFileName);
  try
   if assigned(Stream) then begin
    Resource.LoadMetaData;
    Success:=Resource.BeginLoad(Stream);
    if Success then begin
     Resource.fAsyncLoadState:=TpvResource.TAsyncLoadState.Success;
    end else begin
     Resource.fAsyncLoadState:=TpvResource.TAsyncLoadState.Fail;
    end;
   end else begin
    Resource.fAsyncLoadState:=TpvResource.TAsyncLoadState.Fail;
   end;
  finally
   FreeAndNil(Stream);
  end;

  // Not safe here, must be done in the main thread, because finalization may involve GPU operations
{ fQueueItemResourceMapLock.Acquire;
  try
   QueueItem:=fQueueItemResourceMap.Values[Resource];
  finally
   fQueueItemResourceMapLock.Release;
  end;

  if assigned(QueueItem) and TPasMPInterlocked.CompareExchange(QueueItem.fAutoFinalizeAfterLoad,false,true) then begin
   FinalizeQueueItem(QueueItem);
   QueueItem.Free;
  end;}

 end;

end;

procedure TpvResourceBackgroundLoader.ProcessLoadingWithDirectedAcyclicGraphJobMethod(const aJob:PPasMPJob;const aThreadIndex:TPasMPInt32);
begin
 ProcessLoadingWithDirectedAcyclicGraph;
end;

procedure TpvResourceBackgroundLoader.ProcessLoadingWithDirectedAcyclicGraph;
var Node:TpvResourceDependencyNode;
    Batch:TpvResourceDependencyNodes;
    Index:TpvSizeInt;
begin

 Batch:=TpvResourceDependencyNodes.Create;
 try

  // Accumulate all currently ready nodes in one batch
  while fDependencyGraph.TakeReadyNodes(Batch) do begin
  end;

  // Process the batch if any nodes were collected
  if Batch.Count>0 then begin

   // Load all resources in parallel
   fPasMPInstance.Invoke(fPasMPInstance.ParallelFor(Batch,
                                                    0,
                                                    Batch.Count-1,
                                                    HandleLoadDependencyBatchMethod,
                                                    1,
                                                    PasMPDefaultDepth,
                                                    nil,
                                                    0,
                                                    PasMPAreaMaskBackgroundLoading,
                                                    PasMPAreaMaskUpdate or PasMPAreaMaskRender,
                                                    true,
                                                    PasMPAffinityMaskBackgroundLoadingAllowMask,
                                                    PasMPAffinityMaskBackgroundLoadingAvoidMask));

   // Mark all nodes as complete, which may make their dependents ready
   for Index:=0 to Batch.Count-1 do begin
    fDependencyGraph.MarkNodeComplete(Batch.Items[Index]);
   end;

  end; 

 finally
  FreeAndNil(Batch);
 end;

end;

procedure TpvResourceBackgroundLoader.PasMPProcess;
begin

 if assigned(fRootJob) then begin

  if fPasMPInstance.IsJobValid(fRootJob) then begin
   exit;
  end;

  try
   fPasMPInstance.WaitRelease(fRootJob);
  finally
   fRootJob:=nil;
  end;

 end;

 if fDependencyGraph.HasPendingNodes or (TPasMPInterlocked.Read(fCountQueueItems)>0) then begin

  fRootJob:=fPasMPInstance.Acquire(ProcessLoadingWithDirectedAcyclicGraphJobMethod,nil,nil,0,PasMPAreaMaskBackgroundLoading,PasMPAreaMaskUpdate or PasMPAreaMaskRender,PasMPAffinityMaskBackgroundLoadingAllowMask,PasMPAffinityMaskBackgroundLoadingAvoidMask);
  fPasMPInstance.Run(fRootJob,true);

 end;

end;

function TpvResourceBackgroundLoader.QueueResource(const aResource:TpvResource;const aParent:TpvResource):boolean;
var Index:TpvSizeInt;
    QueueItem,
    TemporaryQueueItem:TQueueItem;
    Resource:TpvResource;
    Found:boolean;
begin

 result:=false;

{if assigned(aParent) then begin
  pvApplication.Log(LOG_DEBUG,'QueueResource','Queueing child='+aResource.fFileName+' parent='+aParent.fFileName);
 end else begin
  pvApplication.Log(LOG_DEBUG,'QueueResource','Queueing root='+aResource.fFileName);
 end;}

 fLock.Acquire;
 try

  Resource:=aResource.GetResource;

  fQueueItemResourceMapLock.Acquire;
  try
   QueueItem:=fQueueItemResourceMap.Values[Resource];
  finally
   fQueueItemResourceMapLock.Release;
  end;

  if not assigned(QueueItem) then begin

   Resource.fAsyncLoadState:=TpvResource.TAsyncLoadState.Queued;

   QueueItem:=TQueueItem.Create(self,aResource);

   if assigned(aParent) then begin
    fDependencyGraph.AddNode(aResource.GetResource,aParent.GetResource);
   end else begin
    fDependencyGraph.AddNode(aResource.GetResource,nil);
   end;

   result:=true;

  end;

 finally
  fLock.Release;
 end;

 if result then begin
  fEvent.SetEvent;
 end;

end;

procedure TpvResourceBackgroundLoader.FinalizeQueueItem(const aQueueItem:TQueueItem);
var Resource:TpvResource;
    Success:boolean;
begin

 fLock.Acquire;
 try

  Resource:=aQueueItem.fResource;

  Success:=Resource.fAsyncLoadState=TpvResource.TAsyncLoadState.Success;

  if Success then begin
   fLock.Release;
   try
    fResourceManager.fLoadLock.Acquire;
    try
     Success:=Resource.EndLoad;
    finally
     fResourceManager.fLoadLock.Release;
    end;
   finally
    fLock.Acquire;
   end;
  end;

  Resource.fAsyncLoadState:=TpvResource.TAsyncLoadState.Done;

  if Success then begin
   Resource.fLoaded:=true;
  end;

 finally
  fLock.Release;
 end;

 if assigned(Resource.fOnFinish) then begin
  Resource.fOnFinish(Resource,Success);
 end;

end;

procedure TpvResourceBackgroundLoader.WaitForResource(const aResource:TpvResource;const aWaitForMode:TpvResourceWaitForMode);
var QueueItem:TQueueItem;
    NeedManualFinalize:boolean;
    ThreadID:TThreadID;
begin

 fQueueItemResourceMapLock.Acquire;
 try
  QueueItem:=fQueueItemResourceMap.Values[aResource];
 finally
  fQueueItemResourceMapLock.Release;
 end;
 
 if assigned(QueueItem) then begin
 
  ThreadID:=GetCurrentThreadID;

  NeedManualFinalize:=(aWaitForMode=TpvResourceWaitForMode.Process) or
                      ((aWaitForMode=TpvResourceWaitForMode.Auto) and ((ThreadID=MainThreadID) or (assigned(fBackgroundLoaderThread) and (ThreadID=fBackgroundLoaderThread.ThreadID))));
                      
  if NeedManualFinalize then begin
   // Try to claim finalization responsibility atomically
   if not TPasMPInterlocked.CompareExchange(QueueItem.fAutoFinalizeAfterLoad,false,true) then begin
    // Someone else already claimed it or it was already finalized
    NeedManualFinalize:=false;
   end;
  end;
  
  // Wait for resource to finish loading
  // Note: StealAndExecuteJob helps other resources load while waiting,
  // improving overall parallelism instead of blocking the thread
  while not (aResource.fAsyncLoadState in [TpvResource.TAsyncLoadState.Success,
                                           TpvResource.TAsyncLoadState.Fail,
                                           TpvResource.TAsyncLoadState.Done]) do begin
   if not fPasMPInstance.StealAndExecuteJob then begin
    TPasMP.Yield;
    Sleep(1);
   end;
  end;
  
  if NeedManualFinalize then begin
   FinalizeQueueItem(QueueItem);
   FreeAndNil(QueueItem);
  end else begin
   while not (aResource.fAsyncLoadState in [TpvResource.TAsyncLoadState.Fail,
                                            TpvResource.TAsyncLoadState.Done]) do begin
    if not fPasMPInstance.StealAndExecuteJob then begin
     TPasMP.Yield;
     Sleep(1);
    end;
   end;
  end;
  
 end;

end;

function TpvResourceBackgroundLoader.ProcessIteration(const aStartTime:TpvHighResolutionTime;const aTimeout:TpvInt64):boolean;
var Index:TpvSizeInt;
    QueueItem:TQueueItem;
    Resource:TpvResource;
    OK:Boolean;
begin

 result:=true;

 Index:=0;
 while true do begin

  fQueueItemLock.Acquire;
  try
   if Index<fQueueItems.Count then begin
    QueueItem:=fQueueItems.Items[Index];
   end else begin
    QueueItem:=nil;
   end;
  finally
   fQueueItemLock.Release;
  end;

  if not assigned(QueueItem) then begin
   break;
  end;

  Resource:=QueueItem.fResource;
  try

   if (Resource.fAsyncLoadState in [TpvResource.TAsyncLoadState.Queued,
                                    TpvResource.TAsyncLoadState.Loading]) then begin

    inc(Index);

   end else begin

    OK:=false;

    // Try to claim finalization responsibility atomically 
    if TPasMPInterlocked.CompareExchange(QueueItem.fAutoFinalizeAfterLoad,false,true) then begin

     fLock.Release;
     try
      if fResourceManager.fLoadLock.TryEnter then begin
       pvApplication.Log(LOG_DEBUG,'TpvResourceBackgroundLoader.ProcessIteration','Processing "'+Resource.fFileName+'" ...');
       try
        FinalizeQueueItem(QueueItem);
        OK:=true;
       finally
        fResourceManager.fLoadLock.Leave;
       end;
       pvApplication.Log(LOG_DEBUG,'TpvResourceBackgroundLoader.ProcessIteration','Processed "'+Resource.fFileName+'" ...');
      end;
     finally
      fLock.Acquire;
     end;

    end; 

    if OK then begin
     FreeAndNil(QueueItem);
    end else begin
     inc(Index);
    end;

   end;

  finally
  end;

  if (aTimeout>=0) and
     (pvApplication.HighResolutionTimer.ToMilliseconds(pvApplication.HighResolutionTimer.GetTime-aStartTime)>=aTimeout) then begin
   result:=false;
   break;
  end;

 end;

end;

function TpvResourceBackgroundLoader.HasResourcesToFinish:boolean;
var Index:TpvSizeInt;
    QueueItem:TQueueItem;
    Resource:TpvResource;
begin
 result:=false;
 fQueueItemLock.Acquire;
 try
  if fQueueItems.Count>0 then begin
   for Index:=0 to fQueueItems.Count-1 do begin
    QueueItem:=fQueueItems.Items[Index];
    if assigned(QueueItem) then begin
     Resource:=QueueItem.fResource;
     if not (Resource.fAsyncLoadState in [TpvResource.TAsyncLoadState.Queued,
                                          TpvResource.TAsyncLoadState.Loading]) then begin
      result:=true;
      break;
     end;
    end;
   end;
  end;
 finally
  fQueueItemLock.Release;
 end;
end;

function TpvResourceBackgroundLoader.Process(const aTimeout:TpvInt64=5):boolean;
begin
 fLock.Acquire;
 try
  ProcessIteration(pvApplication.HighResolutionTimer.GetTime,aTimeOut);
  fQueueItemLock.Acquire;
  try
   result:=fQueueItems.Count=0;
  finally
   fQueueItemLock.Release;
  end;
 finally
  fLock.Release;
 end;
end;

function TpvResourceBackgroundLoader.WaitForResources(const aTimeout:TpvInt64=-1):boolean;
var Start:TpvHighResolutionTime;
    OK:boolean;
begin
 Start:=pvApplication.HighResolutionTimer.GetTime;
 fLock.Acquire;
 try
  repeat
   fQueueItemLock.Acquire;
   try
    OK:=fQueueItems.Count>0;
   finally
    fQueueItemLock.Release;
   end;
   if OK and ProcessIteration(Start,aTimeout) then begin
    if not fPasMPInstance.StealAndExecuteJob then begin
     TPasMP.Relax;
    end;
   end else begin
    break;
   end;
  until false;
  fQueueItemLock.Acquire;
  try
   result:=fQueueItems.Count=0;
  finally
   fQueueItemLock.Release;
  end;
 finally
  fLock.Release;
 end;
end;

function TpvResourceBackgroundLoader.GetCountOfQueuedResources:TpvSizeInt;
begin
 fLock.Acquire;
 try
  fQueueItemLock.Acquire;
  try
   result:=fQueueItems.Count;
  finally
   fQueueItemLock.Release;
  end;
 finally
  fLock.Release;
 end;
end;

{ TpvResourceClassType }

constructor TpvResourceClassType.Create(const aResourceManager:TpvResourceManager;const aResourceClass:TpvResourceClass);
begin

 inherited Create;

 fResourceManager:=aResourceManager;

 fResourceClass:=aResourceClass;

 fResourceListLock:=TPasMPSlimReaderWriterLock.Create;

 fResourceList:=TResourceList.Create;
 fResourceList.OwnsObjects:=false;

 fResourceFileNameMapLock:=TPasMPSlimReaderWriterLock.Create;

 fResourceFileNameMap:=TResourceStringMap.Create(nil);

 fMemoryBudget:=0;

 fMemoryUsage:=0;

end;

destructor TpvResourceClassType.Destroy;
begin

 Shutdown;

 FreeAndNil(fResourceList);

 FreeAndNil(fResourceListLock);

 FreeAndNil(fResourceFileNameMap);

 FreeAndNil(fResourceFileNameMapLock);

 inherited Destroy;
end;

procedure TpvResourceClassType.Shutdown;
var Resource:TpvResource;
begin
 while fResourceList.Count>0 do begin
  Resource:=fResourceList.Items[fResourceList.Count-1];
  fResourceList.Items[fResourceList.Count-1]:=nil;
  fResourceList.Delete(fResourceList.Count-1);
  Resource.Free;
 end;
end;

{ TpvResourceManager }

constructor TpvResourceManager.Create;
begin
 inherited Create;

 fLock:=TPasMPMultipleReaderSingleWriterSpinLock.Create;

 fLocked:=false;

 fCreationIndexCounterLock:=TPasMPSlimReaderWriterLock.Create;

 fLoadLock:=TPasMPCriticalSection.Create;

 fCreationIndexCounter:=0;

 fResourceClassTypeList:=TResourceClassTypeList.Create;
 fResourceClassTypeList.OwnsObjects:=true;

 fResourceClassTypeListLock:=TPasMPMultipleReaderSingleWriterSpinLock.Create;

 fResourceClassTypeMap:=TResourceClassTypeMap.Create(nil);

 fResourceHandleLock:=TPasMPMultipleReaderSingleWriterSpinLock.Create;

 fResourceHandleManager:=TResourceHandleManager.Create;

 fResourceHandleMap:=nil;

 if assigned(pvApplication) then begin
  fBaseDataPath:=TpvUTF8String(pvApplication.Assets.BasePath);
 end;

 fDelayedToFreeResourcesLock:=TPasMPCriticalSection.Create;

 fDelayedToFreeResources:=TResourceList.Create;
 fDelayedToFreeResources.OwnsObjects:=true;

 fMetaResourceLock:=TPasMPMultipleReaderSingleWriterSpinLock.Create;
 fMetaResourceList:=TMetaResourceList.Create;
 fMetaResourceList.OwnsObjects:=false;
 fMetaResourceUUIDMap:=TMetaResourceUUIDMap.Create(nil);
 fMetaResourceFileNameMap:=TMetaResourceFileNameMap.Create(nil);
 fMetaResourceAssetNameMap:=TMetaResourceAssetNameMap.Create(nil);

 fBackgroundLoader:=TpvResourceBackgroundLoader.Create(self);

 fActive:=true;

end;

destructor TpvResourceManager.Destroy;
begin

 Shutdown;

 FreeAndNil(fBackgroundLoader);

 FreeAndNil(fDelayedToFreeResources);

 FreeAndNil(fDelayedToFreeResourcesLock);

 FreeAndNil(fResourceHandleManager);

 fResourceHandleMap:=nil;

 FreeAndNil(fResourceHandleLock);

 FreeAndNil(fResourceClassTypeList);

 FreeAndNil(fResourceClassTypeListLock);

 FreeAndNil(fResourceClassTypeMap);

 while fMetaResourceList.Count>0 do begin
  fMetaResourceList.Items[fMetaResourceList.Count-1].Free;
 end;
 FreeAndNil(fMetaResourceList);

 FreeAndNil(fMetaResourceUUIDMap);

 FreeAndNil(fMetaResourceFileNameMap);

 FreeAndNil(fMetaResourceAssetNameMap);

 FreeAndNil(fMetaResourceLock);

 FreeAndNil(fLoadLock);

 FreeAndNil(fCreationIndexCounterLock);

 FreeAndNil(fLock);

 inherited Destroy;

end;

function TpvResourceManager.GetMetaResourceByUUID(const pUUID:TpvUUID):TpvMetaResource;
begin
 fMetaResourceLock.AcquireRead;
 try
  result:=fMetaResourceUUIDMap.Values[pUUID];
 finally
  fMetaResourceLock.ReleaseRead;
 end;
end;

function TpvResourceManager.GetMetaResourceByFileName(const pFileName:TpvUTF8String):TpvMetaResource;
begin
 fMetaResourceLock.AcquireRead;
 try
  result:=fMetaResourceFileNameMap.Values[LowerCase(pFileName)];
 finally
  fMetaResourceLock.ReleaseRead;
 end;
end;

function TpvResourceManager.GetMetaResourceByAssetName(const pAssetName:TpvUTF8String):TpvMetaResource;
begin
 fMetaResourceLock.AcquireRead;
 try
  result:=fMetaResourceAssetNameMap.Values[LowerCase(pAssetName)];
 finally
  fMetaResourceLock.ReleaseRead;
 end;
end;

function TpvResourceManager.AllocateHandle(const aResource:TpvResource):TpvResourceHandle;
var OldCount:TpvInt32;
begin
 result:=fResourceHandleManager.AllocateID;
 fResourceHandleLock.AcquireWrite;
 try
  OldCount:=length(fResourceHandleMap);
  if OldCount<=result then begin
   SetLength(fResourceHandleMap,(result+1)+((result+2) shr 1));
   FillChar(fResourceHandleMap[OldCount],(length(fResourceHandleMap)-OldCount)*SizeOf(TpvResource),#0);
  end;
  fResourceHandleMap[result]:=aResource;
 finally
  fResourceHandleLock.ReleaseWrite;
 end;
end;

procedure TpvResourceManager.FreeHandle(const aHandle:TpvResourceHandle);
begin
 fResourceHandleLock.AcquireWrite;
 try
  fResourceHandleMap[aHandle]:=nil;
 finally
  fResourceHandleLock.ReleaseWrite;
 end;
 fResourceHandleManager.FreeID(aHandle);
end;

function TpvResourceManager.GetResourceByHandle(const aHandle:TpvResourceHandle):IpvResource;
begin
 if aHandle>=0 then begin
  fResourceHandleLock.AcquireRead;
  try
   if aHandle<length(fResourceHandleMap) then begin
    result:=fResourceHandleMap[aHandle];
   end else begin
    result:=nil;
   end;
  finally
   fResourceHandleLock.ReleaseRead;
  end;
 end else begin
  result:=nil;
 end;
end;

procedure TpvResourceManager.Shutdown;
var Index:TpvSizeInt;
    ResourceClassType:TpvResourceClassType;
begin

 if fActive then begin

  fActive:=false;

  fBackgroundLoader.Shutdown;

  fDelayedToFreeResourcesLock.Acquire;
  try
   SortDelayedToFreeResourcesByCreationIndices(false);
   while fDelayedToFreeResources.Count>0 do begin
    fDelayedToFreeResources.Delete(fDelayedToFreeResources.Count-1);
   end;
  finally
   fDelayedToFreeResourcesLock.Release;
  end;
  FreeAndNil(fDelayedToFreeResources);

  Index:=0;
  while Index<fResourceClassTypeList.Count do begin
   ResourceClassType:=fResourceClassTypeList[Index];
   ResourceClassType.Shutdown;
   inc(Index);
  end;

  fResourceClassTypeList.Clear;

  fResourceClassTypeMap.Clear;

 end;

end;

procedure TpvResourceManager.Process;
begin
 fBackgroundLoader.PasMPProcess;
end;

class function TpvResourceManager.SanitizeFileName(aFileName:TpvUTF8String):TpvUTF8String;
var Index,LastDirectoryNameBeginIndex,Len:TpvSizeInt;
    Temporary:TpvUTF8String;
begin

 result:=aFileName;

 if AllowExternalResources then begin
  if FileExists(result) then begin
   result:=ExpandFileName(result);
   exit;
  end else begin
   for Index:=1 to length(result) do begin
    if result[Index] in ['\','/'] then begin
     Temporary:=ExpandFileName(result);
     if FileExists(Temporary) then begin
      result:=Temporary;
      exit;
     end;
    end;
   end;
  end;
 end;

 Index:=1;
 LastDirectoryNameBeginIndex:=1;
 Len:=length(result);
 while Index<=Len do begin
  case result[Index] of
   'A'..'Z':begin
    inc(result[Index],Ord('a')-Ord('A'));
    inc(Index);
   end;
   '\','/':begin
    if (LastDirectoryNameBeginIndex<Index) and
       ((result[LastDirectoryNameBeginIndex]='.') and
        (((Index-LastDirectoryNameBeginIndex)=1) or
         (((Index-LastDirectoryNameBeginIndex)=2) and
          (result[LastDirectoryNameBeginIndex+1]='.')))) then begin
     // Remove "./" and "../" from string
     Delete(result,LastDirectoryNameBeginIndex,(Index-LastDirectoryNameBeginIndex)+1);
     dec(Len,(Index-LastDirectoryNameBeginIndex)+1);
    end else if Index=1 then begin
     // Remove beginning "/" from string
     Delete(result,1,1);
     dec(Len);
    end else begin
     if result[Index]='\' then begin
      result[Index]:='/';
     end;
     inc(Index);
     LastDirectoryNameBeginIndex:=Index;
    end;
   end;
   else begin
    inc(Index);
   end;
  end;
 end;

end;

function TpvResourceManagerSortDelayedToFreeResourcesByCreationIndicesCompare(const a,b:Pointer):TpvInt32;
begin
 if TpvResource(a).fCreationIndex<TpvResource(b).fCreationIndex then begin
  result:=-1;
 end else if TpvResource(a).fCreationIndex>TpvResource(b).fCreationIndex then begin
  result:=1;
 end else begin
  result:=0;
 end;
end;

procedure TpvResourceManager.SortDelayedToFreeResourcesByCreationIndices(const aLock:Boolean);
begin
 if aLock then begin
  fDelayedToFreeResourcesLock.Acquire;
 end;
 try
  if fDelayedToFreeResources.Count>1 then begin
   IndirectIntroSort(@fDelayedToFreeResources.RawItems[0],0,fDelayedToFreeResources.Count-1,TpvResourceManagerSortDelayedToFreeResourcesByCreationIndicesCompare);
  end;
 finally
  if aLock then begin
   fDelayedToFreeResourcesLock.Release;
  end;
 end;
end;

procedure TpvResourceManager.DestroyDelayedFreeingObjectsWithParent(const aObject:TObject);
var Index,OtherIndex:TpvSizeInt;
    Resource,Current:TpvResource;
    OK:boolean;
begin

 fDelayedToFreeResourcesLock.Acquire;
 try

  SortDelayedToFreeResourcesByCreationIndices(false);

  for Index:=fDelayedToFreeResources.Count-1 downto 0 do begin
   OK:=false;
   Resource:=fDelayedToFreeResources[Index];
   if assigned(Resource) then begin
    if Resource.fParent=aObject then begin
     OK:=true;
    end else begin
     for OtherIndex:=0 to length(Resource.fParents)-1 do begin
      Current:=Resource.fParents[OtherIndex];
      if Current=aObject then begin
       OK:=true;
       break;
      end;
     end;
    end;
   end;
   if OK then begin
    Resource:=fDelayedToFreeResources.Extract(Index);
    if assigned(Resource) then begin
     Resource.fIsOnDelayedToFreeResourcesList:=false;
     FreeAndNil(Resource);
    end;
   end;
  end;

 finally
  fDelayedToFreeResourcesLock.Release;
 end;

end;

function TpvResourceManager.GetResourceClassType(const aResourceClass:TpvResourceClass):TpvResourceClassType;
begin
 if not assigned(aResourceClass) then begin
  raise EpvResourceClassNull.Create('Resource class is null');
 end;
 fResourceClassTypeListLock.AcquireRead;
 try
  result:=fResourceClassTypeMap[aResourceClass];
  if not assigned(result) then begin
   fResourceClassTypeListLock.ReadToWrite;
   try
    result:=TpvResourceClassType.Create(self,aResourceClass);
    try
     fResourceClassTypeMap[aResourceClass]:=result;
    finally
     fResourceClassTypeList.Add(result);
    end;
   finally
    fResourceClassTypeListLock.WriteToRead;
   end;
  end;
 finally
  fResourceClassTypeListLock.ReleaseRead;
 end;
end;

function TpvResourceManager.FindResource(const aResourceClass:TpvResourceClass;const aFileName:TpvUTF8String):TpvResource;
var ResourceClassType:TpvResourceClassType;
begin
 ResourceClassType:=GetResourceClassType(aResourceClass);
 ResourceClassType.fResourceFileNameMapLock.Acquire;
 try
  result:=ResourceClassType.fResourceFileNameMap[SanitizeFileName(aFileName)];
 finally
  ResourceClassType.fResourceFileNameMapLock.Release;
 end;
end;

function TpvResourceManager.LoadResource(const aResourceClass:TpvResourceClass;const aFileName:TpvUTF8String;const aOnFinish:TpvResourceOnFinish;const aLoadInBackground:boolean;const aParent:TpvResource;const aParallelLoadable:TpvResource.TParallelLoadable):TpvResource;
var ResourceClassType:TpvResourceClassType;
    Resource:TpvResource;
    FileName:TpvUTF8String;
begin
 FileName:=SanitizeFileName(aFileName);
 ResourceClassType:=GetResourceClassType(aResourceClass);
 fLock.AcquireRead;
 try
  ResourceClassType.fResourceFileNameMapLock.Acquire;
  try
   result:=ResourceClassType.fResourceFileNameMap[FileName];
  finally
   ResourceClassType.fResourceFileNameMapLock.Release;
  end;
  if assigned(result) then begin
   Resource:=result.GetResource;
   if not (Resource is aResourceClass) then begin
    raise EpvResourceClassMismatch.Create('Resource class mismatch');
   end;
   if aLoadInBackground then begin
    if not Resource.fLoaded then begin
     fLock.ReadToWrite;
     try
      fBackgroundLoader.QueueResource(result,aParent);
     finally
      fLock.WriteToRead;
     end;
    end;
   end else begin
    fLock.ReleaseRead;
    try
     fBackgroundLoader.WaitForResource(Resource,TpvResourceWaitForMode.Auto);
    finally
     fLock.AcquireRead;
    end;
   end;
  end else begin
   fLock.ReadToWrite;
   try
    fLocked:=true;
    try
     Resource:=aResourceClass.Create(self,aParent,nil,aParallelLoadable);
     Resource.SetFileName(FileName);
     Resource.fOnFinish:=aOnFinish;
    finally
     fLocked:=false;
    end;
    if aLoadInBackground then begin
     result:=Resource;
     fBackgroundLoader.QueueResource(result,aParent);
    end;
   finally
    fLock.WriteToRead;
   end;
   if not aLoadInBackground then begin
    fLock.ReleaseRead;
    try
     if Resource.LoadFromFileName(FileName) then begin
      result:=Resource;
     end else begin
      FreeAndNil(Resource);
     end;
    finally
     fLock.AcquireRead;
    end;
   end;
  end;
 finally
  fLock.ReleaseRead;
 end;
end;

function TpvResourceManager.GetResource(const aResourceClass:TpvResourceClass;const aFileName:TpvUTF8String;const aOnFinish:TpvResourceOnFinish):TpvResource;
begin
 result:=LoadResource(aResourceClass,aFileName,aOnFinish,false,nil);
end;

function TpvResourceManager.BackgroundLoadResource(const aResourceClass:TpvResourceClass;const aFileName:TpvUTF8String;const aOnFinish:TpvResourceOnFinish;const aParent:TpvResource;const aParallelLoadable:TpvResource.TParallelLoadable):TpvResource;
begin
 result:=LoadResource(aResourceClass,aFileName,aOnFinish,true,aParent,aParallelLoadable);
end;

procedure TpvResourceManager.FreeDelayedToFreeResources;
var Index:TpvSizeInt;
begin
 if fDelayedToFreeResources.Count>0 then begin
  fDelayedToFreeResourcesLock.Acquire;
  try
   SortDelayedToFreeResourcesByCreationIndices(false);
   for Index:=fDelayedToFreeResources.Count-1 downto 0 do begin
    if TPasMPInterlocked.Decrement(fDelayedToFreeResources[Index].fReleaseFrameDelay)=0 then begin
     fDelayedToFreeResources.Delete(Index);
    end;
   end;
  finally
   fDelayedToFreeResourcesLock.Release;
  end;
 end;
end;

function TpvResourceManager.TryAcquireSynchronizationLock:Boolean;
begin
 result:=assigned(fBackgroundLoader) and
         assigned(fBackgroundLoader.fBackgroundLoaderThread) and
         (TPasMPInterlocked.CompareExchange(fBackgroundLoader.fBackgroundLoaderThread.fState,TpvResourceBackgroundLoaderThread.StateLocked,TpvResourceBackgroundLoaderThread.StateIdle)=TpvResourceBackgroundLoaderThread.StateIdle);
end;

procedure TpvResourceManager.AcquireSynchronizationLock;
begin
 if assigned(fBackgroundLoader) and assigned(fBackgroundLoader.fBackgroundLoaderThread) then begin
  while TPasMPInterlocked.CompareExchange(fBackgroundLoader.fBackgroundLoaderThread.fState,TpvResourceBackgroundLoaderThread.StateLocked,TpvResourceBackgroundLoaderThread.StateIdle)<>TpvResourceBackgroundLoaderThread.StateIdle do begin
   Sleep(1);
  end;
 end;
end;

procedure TpvResourceManager.ReleaseSynchronizationLock;
begin
 if assigned(fBackgroundLoader) and assigned(fBackgroundLoader.fBackgroundLoaderThread) then begin
  TPasMPInterlocked.CompareExchange(fBackgroundLoader.fBackgroundLoaderThread.fState,TpvResourceBackgroundLoaderThread.StateIdle,TpvResourceBackgroundLoaderThread.StateLocked);
 end;
end;

function TpvResourceManager.SynchronizationPoint:Boolean;
begin
 if assigned(fBackgroundLoader) and assigned(fBackgroundLoader.fBackgroundLoaderThread) then begin
  result:=fBackgroundLoader.fBackgroundLoaderThread.SynchronizationPoint;
 end else begin
  result:=false;
 end; 
end;

function TpvResourceManager.FinishResources(const aTimeout:TpvInt64=1):boolean;
begin
 result:=fBackgroundLoader.Process(aTimeout);
end;

function TpvResourceManager.WaitForResources(const aTimeout:TpvInt64=-1):boolean;
begin
 result:=fBackgroundLoader.WaitForResources(aTimeout);
end;

function TpvResourceManager.GetNewUUID:TpvUUID;
begin
 repeat
  result:=TpvUUID.Create;
 until not assigned(GetMetaResourceByUUID(result));
end;

procedure DeferredFreeAndNil(var aObject);
begin
 if assigned(pointer(aObject)) then begin
  try
   if TObject(aObject) is TpvResource then begin
    TpvResource(AObject).DeferredFree;
   end else begin
    TObject(AObject).Free;
   end;
  finally
   TObject(aObject):=nil;
  end;
 end;
end;

initialization
end.

