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
unit PasVulkan.Scene;
{$i PasVulkan.inc}
{$ifndef fpc}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=24.0}
   {$legacyifend on}
  {$ifend}
 {$endif}
{$endif}

interface

uses Classes,
     SysUtils,
     PasMP,
     PasVulkan.Types,
     PasVulkan.Math,
     PasVulkan.Math.Double,
     PasVulkan.Collections,
     PasVulkan.HighResolutionTimer,
     PasVulkan.PasMP,
     PasVulkan.Scene3D,
     PasVulkan.Utils;

{

A scene node can be an entity or even a component for an entity node as well, here is no distinction for simplicity, for the contrast to 
the entity-component-system pattern, which is also implemented in the PasVulkan framework, see the PasVulkan.EntityComponentSystem.pas unit.
So it's your choice, if you want to use the entity-component-system pattern or the scene graph pattern or both.

The scene graph pattern is a tree structure, where each node can have zero or more child nodes, but only one parent node. The root node
has no parent node. Each node can have zero or more data objects, which can be used for any purpose, even as components for an entity
node. The scene graph pattern is very useful for rendering, physics, audio, AI, etc. and is very flexible and easy to use. 

GetNodeListOf returns a list of all child nodes of the specified node class.

GetNodeOf returns the child node of the specified node class at the specified index, which is zero by default, and nil if there is out of bounds.

GetNodeCountOf returns the count of child nodes of the specified node class.

StartLoad, BackgroundLoad and FinishLoad are used for loading of data, which can be done in parallel, like loading of textures, meshes, etc. 
Or to be more precise, StartLoad is called before the background loading of the scene graph, BackgroundLoad is called in a background thread
and should be used for loading of data, which can be done in parallel and FinishLoad is called after the background loading of the scene graph. 

StartLoad is called before the background loading of the scene graph. It's called in the main thread.

BackgroundLoad is called in a background thread and should be used for loading of data, which can be done in parallel.

FinishLoad is called after the background loading of the scene graph. It's called in the main thread.

LoadSynchronizationPoint should be called every frame outside of Update and Render functions to have a synchronization point for the loading
mechanism of the scene graph.

WaitForLoaded waits until the scene graph or node is loaded, and should be only used with awareness, because it can block the main thread.

IsLoaded returns true, if the scene graph or node is loaded.

Check is called for checking outside and before the Update and Render functions in parallel lock-step, for doing stuff which needs to be 
done sequentially in serial order, like creating or destroying of objects, or checking stuff, etc.

Store and Interpolate are used for interpolation of the scene graph for the "Fix your timestep" pattern, which means, that the scene graph
is updated with a fixed timestep, but rendered with a variable timestep, which is interpolated between the last and the current scene graph
state for smooth rendering. Where Store is called for storing the scene graph state, Interpolate is called for interpolating the scene graph
with a fixed timestep with aDeltaTime as parameter, Interpolate is called for interpolating the scene graph with a variable timestep with 
aAlpha as parameter. And FrameUpdate is called after Interpolate for updating some stuff just frame-wise, like audio, etc. and is called
in the main thread.

Render is called for rendering the scene graph and can be called in the main "or" in a render thread, depending on the settings of the
PasVulkan main loop, so be careful with thread-safety.

UpdateAudio is called for updating audio and is called in the audio thread, so be careful with thread-safety. So use it in combination with
FrameUpdate, which is called in the main thread, with a thread safe data ring buffer oder queue for audio data, which is filled in FrameUpdate
and read in UpdateAudio. You can use the constructs from PasMP for that, see the PasMP.pas unit.

Serialize and Deserialize are used for serialization and deserialization of the scene graph and can be used for saving and loading of the
scene graph, for example for saving and loading of a game level, etc.

And very important, avoid acyclic and circular dependencies as much as possible, because it can lead to deadlocks, etc. and can be very
difficult to debug. If you have to use them, use them with awareness and be careful with them.

Directed Acyclic Graph (DAG) for scene node dependency management:

The scene graph includes a powerful DAG system for managing node dependencies and enabling efficient parallel execution. When enabled via
UseDirectedAcyclicGraph, the scene automatically builds a dependency graph that respects both explicit dependencies and the parent-child
hierarchy.

Key features:
- Nodes can declare explicit dependencies via AddDependency/RemoveDependency (a node will execute after its dependencies)
- Parent-child relationships are implicit dependencies (parents execute before their children)
- Nodes can declare conflicts via AddConflictingNode (conflicting nodes never execute in parallel)
- Per-node ParallelExecution flag controls whether a node can run in parallel with others
- Automatic cycle detection during graph construction
- Topological sorting ensures correct execution order
- Execution levels group nodes that can safely run in parallel

The DAG system organizes nodes into execution levels where:
- All nodes in a level can execute in parallel (if ParallelExecution=true and no conflicts exist)
- Each level completes before the next level starts
- Dependencies are always satisfied before a node executes
- Conflicts are resolved by placing nodes in different levels

This enables efficient parallel processing of Check, Store, Update, Render, and other scene operations while maintaining correctness.

Per-stage parallel execution control:

The ParallelStages property (TStageSet) provides fine-grained control over which scene stages use parallel execution within the DAG.
Each stage (Check, Store, BeginUpdate, Update, EndUpdate, Interpolate, FrameUpdate, Render, UpdateAudio) can be individually enabled
or disabled for parallel execution. This allows you to:
- Enable parallelism only for performance-critical stages
- Disable parallelism for stages with thread-safety concerns
- Profile and tune parallel execution on a per-stage basis
- Mix sequential and parallel execution as needed

When a stage is not in ParallelStages, it executes sequentially even when UseDirectedAcyclicGraph is enabled. When a stage is in
ParallelStages, the DAG execution levels are used to run nodes in parallel where dependencies and conflicts allow.

NOTE: Scene methods are assumed to be called from a single thread in a frame-ordered fashion.
      fDeltaTime and fAlpha are only written by that thread and read by worker threads.

}

type TpvScene=class;

     TpvSceneNode=class;

     TpvSceneNodeClass=class of TpvSceneNode;

     TpvSceneNodes=TpvObjectGenericList<TpvSceneNode>;

     TpvSceneNodesList=TpvObjectGenericList<TpvSceneNodes>;

     TpvSceneNodeStack=TpvDynamicFastStack<TpvSceneNode>;

     TpvSceneNodeHashMap=TpvHashMap<TpvSceneNodeClass,TpvSceneNodes>;

     TpvSceneNodeState=TPasMPInt32;
     PpvSceneNodeState=^TpvSceneNodeState;

     TpvSceneNodeStateHelper=record helper for TpvSceneNodeState
      public
       const Unused=TpvSceneNodeState(0);
             Unloaded=TpvSceneNodeState(1);
             StartLoading=TpvSceneNodeState(2);
             StartLoaded=TpvSceneNodeState(3);
             BackgroundLoading=TpvSceneNodeState(4);
             BackgroundLoaded=TpvSceneNodeState(5);
             Loading=TpvSceneNodeState(6);
             Loaded=TpvSceneNodeState(7);
             Failed=TpvSceneNodeState(8);
             Unloading=TpvSceneNodeState(9);
             ManualLoad=TpvSceneNodeState(10);
             ManualLoading=TpvSceneNodeState(11);
     end;

     TpvSceneNodeVisitedState=
      (
       Unvisited=0,
       Visiting=1,
       Visited=2
      );

     { TpvSceneDirectedAcyclicGraph }
     // Directed Acyclic Graph (DAG) for scene node dependency management.
     // Performs cycle detection and topological sorting during graph construction.
     TpvSceneDirectedAcyclicGraph=class
      private
       fScene:TpvScene;
       fLeafNodes:TpvSceneNodes;
       fTopologicallySortedNodes:TpvSceneNodes;
       fExecutionLevels:TpvSceneNodesList;
       fGeneration:TPasMPUInt32;
       fLastGeneration:TPasMPUInt32;
       fValid:boolean;
       fParallelExecutionDefault:boolean;
       fLock:TPasMPSlimReaderWriterLock;
       procedure SetParallelExecutionDefault(const aParallelExecutionDefault:boolean);
       procedure BuildExecutionLevels;
      public
       constructor Create(const aScene:TpvScene); reintroduce;
       destructor Destroy; override;
       procedure Invalidate; inline;
       procedure Rebuild;
      public
       property LeafNodes:TpvSceneNodes read fLeafNodes;
       property TopologicallySortedNodes:TpvSceneNodes read fTopologicallySortedNodes;
       property ExecutionLevels:TpvSceneNodesList read fExecutionLevels;
       property Valid:boolean read fValid;
       property ParallelExecutionDefault:boolean read fParallelExecutionDefault write SetParallelExecutionDefault;
       property Generation:TPasMPUInt32 read fGeneration;
     end;

     { TpvSceneNode }
     TpvSceneNode=class      
      public
      private
       fScene:TpvScene;
       fParent:TpvSceneNode;
       fData:TObject;
       fIndex:TpvSizeInt;
       fChildren:TpvSceneNodes;
       fConflictingNodes:TpvSceneNodes;
       fIncomingNodeDependencies:TpvSceneNodes;
       fOutgoingNodeDependencies:TpvSceneNodes;
       fDirectedAcyclicGraphInputDependencies:TpvSceneNodes;
       fDirectedAcyclicGraphOutputDependencies:TpvSceneNodes;
       fNodeHashMap:TpvSceneNodeHashMap;
       fLock:TpvInt32;
       fState:TpvSceneNodeState;
       fDestroying:boolean;
       fIsCountToStartLoadNodes:boolean;
       fIsCountToBackgroundLoadNodes:boolean;
       fIsCountToFinishLoadNodes:boolean;
       fParallelExecution:boolean;
       fManualLoad:boolean;
       fVisitedState:TpvSceneNodeVisitedState; // For DAG traversal
       fBeginTime:TpvHighResolutionTime;
       fEndTime:TpvHighResolutionTime;
       fTimeDuration:TpvHighResolutionTime;
       procedure InvalidateDirectedAcyclicGraph; inline;
       procedure SetParallelExecution(const aParallelExecution:boolean);
      public
       fStartLoadVisitGeneration:TpvUInt32;
       fBackgroundLoadVisitGeneration:TpvUInt32;
       fFinishLoadVisitGeneration:TpvUInt32;
      public
       
       constructor Create(const aParent:TpvSceneNode;const aData:TObject=nil); reintroduce; virtual;
       destructor Destroy; override;
       
       procedure AfterConstruction; override;
       procedure BeforeDestruction; override;

       procedure AddConflictingNode(const aNode:TpvSceneNode);
       procedure RemoveConflictingNode(const aNode:TpvSceneNode);
       
       procedure AddDependency(const aNode:TpvSceneNode);
       procedure RemoveDependency(const aNode:TpvSceneNode);
       
       procedure Add(const aNode:TpvSceneNode);
       procedure Remove(const aNode:TpvSceneNode);
       
       function GetNodeListOf(const aNodeClass:TpvSceneNodeClass):TpvSceneNodes;
       function GetNodeOf(const aNodeClass:TpvSceneNodeClass;const aIndex:TpvSizeInt=0):TpvSceneNode;
       function GetNodeCountOf(const aNodeClass:TpvSceneNodeClass):TpvSizeInt;
       
       procedure BeforeStartLoad; virtual;
       procedure StartLoad; virtual;
       procedure AfterStartLoad; virtual;
       
       procedure BeforeBackgroundLoad; virtual;
       procedure BackgroundLoad; virtual;
       procedure AfterBackgroundLoad; virtual;
       
       procedure BeforeFinishLoad; virtual;
       procedure FinishLoad; virtual;
       procedure AfterFinishLoad; virtual;
       
       procedure WaitForLoaded; virtual;
       
       procedure Load; virtual;

       function IsLoaded:boolean; virtual;

       procedure ResetTimeDuration; inline; 
       procedure TimeBlockBegin; virtual;
       procedure TimeBlockEnd; virtual;
              
       procedure Check; virtual;

       procedure Store; virtual;

       procedure BeginUpdate(const aDeltaTime:TpvDouble); virtual;
       procedure Update(const aDeltaTime:TpvDouble); virtual;
       procedure EndUpdate(const aDeltaTime:TpvDouble); virtual;
       
       procedure Interpolate(const aAlpha:TpvDouble); virtual;
       
       procedure FrameUpdate; virtual;
       
       procedure Render; virtual;
       
       procedure UpdateAudio; virtual;

       procedure DumpTimes; virtual;

       function Serialize:TObject; virtual;       
       procedure Deserialize(const aData:TObject); virtual;

      public
       property State:TpvSceneNodeState read fState;
       property ParallelExecution:boolean read fParallelExecution write SetParallelExecution;
       property ManualLoad:boolean read fManualLoad write fManualLoad;
      published
       property Scene:TpvScene read fScene;
       property Parent:TpvSceneNode read fParent;
       property Data:TObject read fData;
       property Children:TpvSceneNodes read fChildren;
     end;

     { TpvScene }
     TpvScene=class
      public
       type TStage=
             (
              Check,
              Store,  
              BeginUpdate,
              Update,
              EndUpdate,
              Interpolate,
              FrameUpdate,
              Render,
              UpdateAudio
             );
             PStage=^TStage;
             TStageSet=set of TStage;
             PStageSet=^TStageSet;
      private
       fRootNode:TpvSceneNode;
       fAllNodesLock:TPasMPSlimReaderWriterLock;
       fAllNodes:TpvSceneNodes;
       fCountToStartLoadNodes:TPasMPInt32;
       fCountToBackgroundLoadNodes:TPasMPInt32;
       fCountToFinishLoadNodes:TPasMPInt32;
       fData:TObject;
       fDirectedAcyclicGraph:TpvSceneDirectedAcyclicGraph;
       fUseDirectedAcyclicGraph:TPasMPBool32;
       fPasMPInstance:TPasMP;
       fDeltaTime:TpvDouble;
       fAlpha:TpvDouble;
       fParallelStages:TStageSet;
       fFirstTimeUpdateInStep:TPasMPBool32;
       procedure InvalidateDirectedAcyclicGraph; inline;
       procedure RebuildDirectedAcyclicGraph; inline;
       procedure CheckParallelForJob(const aJob:PPasMPJob;const ThreadIndex:TPasMPInt32;const aData:pointer;const aFromIndex,aToIndex:TPasMPNativeInt);
       procedure StoreParallelForJob(const aJob:PPasMPJob;const ThreadIndex:TPasMPInt32;const aData:pointer;const aFromIndex,aToIndex:TPasMPNativeInt);
       procedure BeginUpdateParallelForJob(const aJob:PPasMPJob;const ThreadIndex:TPasMPInt32;const aData:pointer;const aFromIndex,aToIndex:TPasMPNativeInt);
       procedure UpdateParallelForJob(const aJob:PPasMPJob;const ThreadIndex:TPasMPInt32;const aData:pointer;const aFromIndex,aToIndex:TPasMPNativeInt);
       procedure EndUpdateParallelForJob(const aJob:PPasMPJob;const ThreadIndex:TPasMPInt32;const aData:pointer;const aFromIndex,aToIndex:TPasMPNativeInt);
       procedure InterpolateParallelForJob(const aJob:PPasMPJob;const ThreadIndex:TPasMPInt32;const aData:pointer;const aFromIndex,aToIndex:TPasMPNativeInt);
       procedure FrameUpdateParallelForJob(const aJob:PPasMPJob;const ThreadIndex:TPasMPInt32;const aData:pointer;const aFromIndex,aToIndex:TPasMPNativeInt);
       procedure RenderParallelForJob(const aJob:PPasMPJob;const ThreadIndex:TPasMPInt32;const aData:pointer;const aFromIndex,aToIndex:TPasMPNativeInt);
       procedure UpdateAudioParallelForJob(const aJob:PPasMPJob;const ThreadIndex:TPasMPInt32;const aData:pointer;const aFromIndex,aToIndex:TPasMPNativeInt);
      public
       fStartLoadVisitGeneration:TpvUInt32;
       fBackgroundLoadVisitGeneration:TpvUInt32;
       fFinishLoadVisitGeneration:TpvUInt32;
      private
       fBackgroundLoadJob:PPasMPJob;
       procedure BackgroundLoadJobMethod(const aJob:PPasMPJob;const aThreadIndex:TPasMPInt32);
      public
       constructor Create(const aData:TObject=nil); reintroduce; virtual;
       destructor Destroy; override;
       procedure Shutdown; virtual;
       procedure StartLoad; virtual;
       procedure BackgroundLoad; virtual;
       procedure FinishLoad; virtual;
       procedure WaitForLoaded; virtual;
       function IsLoaded:boolean; virtual;
       procedure LoadSynchronizationPoint; virtual;
       procedure Check; virtual;
       procedure Store; virtual;
       procedure BeginUpdate(const aDeltaTime:TpvDouble); virtual;
       procedure Update(const aDeltaTime:TpvDouble); virtual;
       procedure EndUpdate(const aDeltaTime:TpvDouble); virtual;
       procedure Interpolate(const aAlpha:TpvDouble); virtual;
       procedure FrameUpdate; virtual;
       procedure Render; virtual;
       procedure UpdateAudio; virtual;
       procedure DumpTimes; virtual;
       function Serialize:TObject; virtual;
       procedure Deserialize(const aData:TObject); virtual;
      published
       property RootNode:TpvSceneNode read fRootNode;
       property Data:TObject read fData;
       property DirectedAcyclicGraph:TpvSceneDirectedAcyclicGraph read fDirectedAcyclicGraph;
       property UseDirectedAcyclicGraph:TPasMPBool32 read fUseDirectedAcyclicGraph write fUseDirectedAcyclicGraph;
       property ParallelStages:TStageSet read fParallelStages write fParallelStages;
       property FirstTimeUpdateInStep:TPasMPBool32 read fFirstTimeUpdateInStep write fFirstTimeUpdateInStep;
     end;

     { TpvSceneNode3D }
     TpvSceneNode3D=class(TpvSceneNode)
      private
       fLastNode3DParent:TpvSceneNode3D;
       fTransform:TpvMatrix4x4D;
       fCachedWorldTransform:TpvMatrix4x4D;
       fLastCachedWorldTransform:TpvMatrix4x4D;
       fInterpolatedCachedWorldTransform:TpvMatrix4x4D;
       fBounds:TpvAABB;
      protected
       procedure UpdateCachedWorldTransform; virtual;
       procedure RecursiveUpdateCachedWorldTransform; virtual;
       procedure SetTransform(const aValue:TpvMatrix4x4D); virtual;
       function GetWorldTransform:TpvMatrix4x4D; virtual;
       procedure SetWorldTransform(const aWorldTransform:TpvMatrix4x4D); virtual;
       procedure UpdateBounds; virtual;
      public
       constructor Create(const aParent:TpvSceneNode;const aData:TObject=nil); override;
       destructor Destroy; override;
       procedure Store; override;
       procedure BeginUpdate(const aDeltaTime:TpvDouble); override;
       procedure Update(const aDeltaTime:TpvDouble); override;
       procedure EndUpdate(const aDeltaTime:TpvDouble); override;
       procedure Interpolate(const aAlpha:TpvDouble); override;
      public
       property Transform:TpvMatrix4x4D read fTransform write SetTransform;
       property WorldTransform:TpvMatrix4x4D read GetWorldTransform write SetWorldTransform;
       property CachedWorldTransform:TpvMatrix4x4D read fCachedWorldTransform;
       property LastCachedWorldTransform:TpvMatrix4x4D read fLastCachedWorldTransform;
       property InterpolatedCachedWorldTransform:TpvMatrix4x4D read fInterpolatedCachedWorldTransform;
       property Bounds:TpvAABB read fBounds write fBounds;
     end;

implementation

uses PasVulkan.Application;

{ TpvSceneNode }

constructor TpvSceneNode.Create(const aParent:TpvSceneNode;const aData:TObject);
begin
 inherited Create;

 fLock:=0;

 fParent:=aParent;

 if assigned(fParent) then begin
  fScene:=fParent.fScene;
 end else begin
  fScene:=nil;
 end;

 fData:=aData;

 fIndex:=-1;

 fIsCountToStartLoadNodes:=false;
 fIsCountToBackgroundLoadNodes:=false;
 fIsCountToFinishLoadNodes:=false;

 fChildren:=TpvSceneNodes.Create;
 fChildren.OwnsObjects:=true;

 fConflictingNodes:=TpvSceneNodes.Create;
 fConflictingNodes.OwnsObjects:=false;

 fIncomingNodeDependencies:=TpvSceneNodes.Create;
 fIncomingNodeDependencies.OwnsObjects:=false;

 fOutgoingNodeDependencies:=TpvSceneNodes.Create;
 fOutgoingNodeDependencies.OwnsObjects:=false;

 fDirectedAcyclicGraphInputDependencies:=TpvSceneNodes.Create;
 fDirectedAcyclicGraphInputDependencies.OwnsObjects:=false;

 fDirectedAcyclicGraphOutputDependencies:=TpvSceneNodes.Create;
 fDirectedAcyclicGraphOutputDependencies.OwnsObjects:=false;

 fDestroying:=false;

 if assigned(fScene) and assigned(fScene.fDirectedAcyclicGraph) then begin
  fParallelExecution:=fScene.fDirectedAcyclicGraph.fParallelExecutionDefault;
 end else begin
  fParallelExecution:=false;
 end;

 fManualLoad:=false;

 fVisitedState:=TpvSceneNodeVisitedState.Unvisited;

 fStartLoadVisitGeneration:=0;
 fBackgroundLoadVisitGeneration:=0;
 fFinishLoadVisitGeneration:=0;

 fTimeDuration:=0;
 fBeginTime:=0;
 fEndTime:=0;

 TPasMPInterlocked.Write(fState,TpvSceneNodeState.Unloaded);

 fNodeHashMap:=TpvSceneNodeHashMap.Create(nil);

 if assigned(fParent) then begin
  fParent.Add(self);
 end;

end;

destructor TpvSceneNode.Destroy;
var ChildNodeIndex:TpvSizeInt;
    ChildNode,ParentNode:TpvSceneNode;
    NodeClass:TpvSceneNodeClass;
    Nodes:TpvSceneNodes;
begin
 if assigned(fParent) and not fDestroying then begin
  ParentNode:=fParent;
  TPasMPMultipleReaderSingleWriterSpinLock.AcquireWrite(ParentNode.fLock);
  try
   fParent:=nil;
   ChildNodeIndex:=ParentNode.fChildren.IndexOf(self);
   if ChildNodeIndex>=0 then begin
    NodeClass:=TpvSceneNodeClass(ClassType);
    Nodes:=ParentNode.fNodeHashMap[NodeClass];
    if assigned(Nodes) then begin
     Nodes.Remove(self);
    end;
    ParentNode.fChildren.Extract(ChildNodeIndex);
   end;
  finally
   TPasMPMultipleReaderSingleWriterSpinLock.ReleaseWrite(ParentNode.fLock);
  end;
 end;

 FreeAndNil(fDirectedAcyclicGraphInputDependencies);
 
 FreeAndNil(fDirectedAcyclicGraphOutputDependencies);

 FreeAndNil(fOutgoingNodeDependencies);

 FreeAndNil(fIncomingNodeDependencies);

 FreeAndNil(fConflictingNodes);

 for ChildNodeIndex:=0 to fChildren.Count-1 do begin
  ChildNode:=fChildren[ChildNodeIndex];
  ChildNode.fDestroying:=true;
 end;
 FreeAndNil(fChildren);

 for Nodes in fNodeHashMap.Values do begin
  Nodes.Free;
 end;
 FreeAndNil(fNodeHashMap);

 inherited Destroy;
end;

procedure TpvSceneNode.AfterConstruction;
begin
 inherited AfterConstruction;
 if assigned(fScene) then begin
  fScene.fAllNodesLock.Acquire;
  try
   fIndex:=fScene.fAllNodes.Add(self);
  finally
   fScene.fAllNodesLock.Release;
  end;
  if ManualLoad then begin
   TPasMPInterlocked.Write(fState,TpvSceneNodeState.ManualLoad);
  end else begin
   if not fIsCountToStartLoadNodes then begin
    TPasMPInterlocked.Increment(fScene.fCountToStartLoadNodes);
    fIsCountToStartLoadNodes:=true;
   end;
  end;
  InvalidateDirectedAcyclicGraph;
 end;
end;

procedure TpvSceneNode.BeforeDestruction;
var Index:TpvSizeInt;
begin
 if assigned(fScene) then begin
  if fIndex>=0 then begin
   try
    fScene.fAllNodesLock.Acquire;
    try
     Index:=fIndex;
     if Index=(fScene.fAllNodes.Count-1) then begin
      fScene.fAllNodes.Delete(Index);
     end else begin
      fScene.fAllNodes.Exchange(Index,fScene.fAllNodes.Count-1);
      fScene.fAllNodes.Delete(fScene.fAllNodes.Count-1);
      fScene.fAllNodes[Index].fIndex:=Index;
     end;
    finally
     fScene.fAllNodesLock.Release;
    end;
   finally
    fIndex:=-1;
   end; 
  end;
 end;
 if fOutgoingNodeDependencies.Count>0 then begin
  for Index:=fOutgoingNodeDependencies.Count-1 downto 0 do begin
   fOutgoingNodeDependencies[Index].RemoveDependency(self);
  end;
 end;
 if fIncomingNodeDependencies.Count>0 then begin
  for Index:=fIncomingNodeDependencies.Count-1 downto 0 do begin
   RemoveDependency(fIncomingNodeDependencies[Index]);
  end;
 end;
 InvalidateDirectedAcyclicGraph;
 inherited BeforeDestruction;
end;

procedure TpvSceneNode.InvalidateDirectedAcyclicGraph;
begin
 if assigned(fScene) and assigned(fScene.fDirectedAcyclicGraph) then begin
  fScene.fDirectedAcyclicGraph.Invalidate;
 end;
end;

procedure TpvSceneNode.SetParallelExecution(const aParallelExecution:boolean);
begin
 if fParallelExecution<>aParallelExecution then begin
  fParallelExecution:=aParallelExecution;
  InvalidateDirectedAcyclicGraph;
 end;
end;

procedure TpvSceneNode.AddConflictingNode(const aNode:TpvSceneNode);
begin

 if assigned(aNode) and (aNode<>self) then begin

  TPasMPMultipleReaderSingleWriterSpinLock.AcquireWrite(fLock);
  try
   if assigned(fConflictingNodes) and not fConflictingNodes.Contains(aNode) then begin
    fConflictingNodes.Add(aNode);
    InvalidateDirectedAcyclicGraph;
   end;
  finally
   TPasMPMultipleReaderSingleWriterSpinLock.ReleaseWrite(fLock);
  end;

 end;

end;

procedure TpvSceneNode.RemoveConflictingNode(const aNode:TpvSceneNode);
var Index:TpvSizeInt;
begin

 if assigned(aNode) and (aNode<>self) then begin

  if assigned(fConflictingNodes) then begin
   TPasMPMultipleReaderSingleWriterSpinLock.AcquireWrite(fLock);
   try
    Index:=fConflictingNodes.IndexOf(aNode);
    if Index>=0 then begin
     fConflictingNodes.Delete(Index);
     InvalidateDirectedAcyclicGraph;
    end;
   finally
    TPasMPMultipleReaderSingleWriterSpinLock.ReleaseWrite(fLock);
   end;
  end;

 end;

end;

procedure TpvSceneNode.AddDependency(const aNode:TpvSceneNode);
var ToInvalidate:Boolean;
begin

 if assigned(aNode) and (aNode<>self) then begin

  ToInvalidate:=false;

  if TpvPtrUInt(self)<TpvPtrUInt(aNode) then begin
   TPasMPMultipleReaderSingleWriterSpinLock.AcquireWrite(fLock);
   TPasMPMultipleReaderSingleWriterSpinLock.AcquireWrite(aNode.fLock);
  end else begin
   TPasMPMultipleReaderSingleWriterSpinLock.AcquireWrite(aNode.fLock);
   TPasMPMultipleReaderSingleWriterSpinLock.AcquireWrite(fLock);
  end;
  try
   if assigned(fIncomingNodeDependencies) and not fIncomingNodeDependencies.Contains(aNode) then begin
    fIncomingNodeDependencies.Add(aNode);
    ToInvalidate:=true;
   end;
   if assigned(aNode.fOutgoingNodeDependencies) and not aNode.fOutgoingNodeDependencies.Contains(self) then begin
    aNode.fOutgoingNodeDependencies.Add(self);
    ToInvalidate:=true;
   end;
  finally
   if TpvPtrUInt(self)<TpvPtrUInt(aNode) then begin
    TPasMPMultipleReaderSingleWriterSpinLock.ReleaseWrite(aNode.fLock);
    TPasMPMultipleReaderSingleWriterSpinLock.ReleaseWrite(fLock);
   end else begin
    TPasMPMultipleReaderSingleWriterSpinLock.ReleaseWrite(fLock);
    TPasMPMultipleReaderSingleWriterSpinLock.ReleaseWrite(aNode.fLock);
   end;
  end;

  if ToInvalidate then begin
   InvalidateDirectedAcyclicGraph;
  end;

 end;

end;

procedure TpvSceneNode.RemoveDependency(const aNode:TpvSceneNode);
var Index:TpvSizeInt;
    ToInvalidate:Boolean;
begin

 if assigned(aNode) and (aNode<>self) then begin

  ToInvalidate:=false;

  if TpvPtrUInt(self)<TpvPtrUInt(aNode) then begin
   TPasMPMultipleReaderSingleWriterSpinLock.AcquireWrite(fLock);
   TPasMPMultipleReaderSingleWriterSpinLock.AcquireWrite(aNode.fLock);
  end else begin
   TPasMPMultipleReaderSingleWriterSpinLock.AcquireWrite(aNode.fLock);
   TPasMPMultipleReaderSingleWriterSpinLock.AcquireWrite(fLock);
  end;
  try
   if assigned(fIncomingNodeDependencies) then begin
    Index:=fIncomingNodeDependencies.IndexOf(aNode);
    if Index>=0 then begin
     fIncomingNodeDependencies.Delete(Index);
     ToInvalidate:=true;
    end;
   end;
   if assigned(aNode.fOutgoingNodeDependencies) then begin
    Index:=aNode.fOutgoingNodeDependencies.IndexOf(self);
    if Index>=0 then begin
     aNode.fOutgoingNodeDependencies.Delete(Index);
     ToInvalidate:=true;
    end;
   end;
  finally
   if TpvPtrUInt(self)<TpvPtrUInt(aNode) then begin
    TPasMPMultipleReaderSingleWriterSpinLock.ReleaseWrite(aNode.fLock);
    TPasMPMultipleReaderSingleWriterSpinLock.ReleaseWrite(fLock);
   end else begin
    TPasMPMultipleReaderSingleWriterSpinLock.ReleaseWrite(fLock);
    TPasMPMultipleReaderSingleWriterSpinLock.ReleaseWrite(aNode.fLock);
   end;
  end;

  if ToInvalidate then begin
   InvalidateDirectedAcyclicGraph;
  end;

 end;

end;

procedure TpvSceneNode.Add(const aNode:TpvSceneNode);
var NodeClass:TpvSceneNodeClass;
    Nodes:TpvSceneNodes;
begin

 if assigned(aNode) and (aNode<>self) then begin

  TPasMPMultipleReaderSingleWriterSpinLock.AcquireWrite(fLock);
  try

   NodeClass:=TpvSceneNodeClass(aNode.ClassType);

   Nodes:=fNodeHashMap[NodeClass];
   if not assigned(Nodes) then begin
    Nodes:=TpvSceneNodes.Create;
    Nodes.OwnsObjects:=false;
    fNodeHashMap[NodeClass]:=Nodes;
   end;
   Nodes.Add(aNode);

   fChildren.Add(aNode);

   aNode.fParent:=self;

   InvalidateDirectedAcyclicGraph;

  finally
   TPasMPMultipleReaderSingleWriterSpinLock.ReleaseWrite(fLock);
  end;

 end;

end;

procedure TpvSceneNode.Remove(const aNode:TpvSceneNode);
var Index:TpvSizeInt;
    NodeClass:TpvSceneNodeClass;
    Nodes:TpvSceneNodes;
begin

 if assigned(aNode) and (aNode<>self) and (aNode.fParent=self) and not aNode.fDestroying then begin

  TPasMPMultipleReaderSingleWriterSpinLock.AcquireWrite(fLock);
  try

   Index:=fChildren.IndexOf(aNode);
   if Index>=0 then begin

    aNode.fDestroying:=true;

    NodeClass:=TpvSceneNodeClass(aNode.ClassType);

    Nodes:=fNodeHashMap[NodeClass];
    if assigned(Nodes) then begin
     Nodes.Remove(aNode);
    end;

    fChildren.Extract(Index);

    aNode.Free;

    InvalidateDirectedAcyclicGraph;

   end;

  finally
   TPasMPMultipleReaderSingleWriterSpinLock.ReleaseWrite(fLock);
  end;

 end;

end;

function TpvSceneNode.GetNodeListOf(const aNodeClass:TpvSceneNodeClass):TpvSceneNodes;
begin
 result:=fNodeHashMap[aNodeClass];
end;

function TpvSceneNode.GetNodeOf(const aNodeClass:TpvSceneNodeClass;const aIndex:TpvSizeInt=0):TpvSceneNode;
var Nodes:TpvSceneNodes;
begin
 Nodes:=fNodeHashMap[aNodeClass];
 if assigned(Nodes) and (aIndex>=0) and (aIndex<Nodes.Count) then begin
  result:=Nodes[aIndex];
 end else begin
  result:=nil;
 end;
end;

function TpvSceneNode.GetNodeCountOf(const aNodeClass:TpvSceneNodeClass):TpvSizeInt;
var Nodes:TpvSceneNodes;
begin
 Nodes:=fNodeHashMap[aNodeClass];
 if assigned(Nodes) then begin
  result:=Nodes.Count;
 end else begin
  result:=0;
 end;
end;

procedure TpvSceneNode.BeforeStartLoad;
begin
end;

procedure TpvSceneNode.StartLoad;
begin
end;

procedure TpvSceneNode.AfterStartLoad;
var OldState:TpvSceneNodeState;
begin
 OldState:=TPasMPInterlocked.Read(fState);
 if (OldState=TpvSceneNodeState.Unloaded) or (OldState=TpvSceneNodeState.StartLoading) then begin
  TPasMPInterlocked.CompareExchange(fState,TpvSceneNodeState.StartLoaded,OldState);
  if fIsCountToStartLoadNodes then begin
   fIsCountToStartLoadNodes:=false;
   TPasMPInterlocked.Decrement(fScene.fCountToStartLoadNodes);
  end;
  if not fIsCountToBackgroundLoadNodes then begin
   TPasMPInterlocked.Increment(fScene.fCountToBackgroundLoadNodes);
   fIsCountToBackgroundLoadNodes:=true;
  end;
 end;
end;

procedure TpvSceneNode.BeforeBackgroundLoad;
begin  
end;

procedure TpvSceneNode.BackgroundLoad;
begin
end;

procedure TpvSceneNode.AfterBackgroundLoad;
var OldState:TpvSceneNodeState;
begin
 OldState:=TPasMPInterlocked.Read(fState);
 if (OldState=TpvSceneNodeState.StartLoaded) or (OldState=TpvSceneNodeState.BackgroundLoading) then begin
  TPasMPInterlocked.CompareExchange(fState,TpvSceneNodeState.BackgroundLoaded,OldState);
  if fIsCountToBackgroundLoadNodes then begin
   fIsCountToBackgroundLoadNodes:=false;
   TPasMPInterlocked.Decrement(fScene.fCountToBackgroundLoadNodes);
  end;
  if not fIsCountToFinishLoadNodes then begin
   TPasMPInterlocked.Increment(fScene.fCountToFinishLoadNodes);
   fIsCountToFinishLoadNodes:=true;
  end;
 end;
end;

procedure TpvSceneNode.BeforeFinishLoad;
begin
end;

procedure TpvSceneNode.FinishLoad;
begin
end;

procedure TpvSceneNode.AfterFinishLoad;
var OldState:TpvSceneNodeState;
begin
 OldState:=TPasMPInterlocked.Read(fState);
 if ((OldState=TpvSceneNodeState.BackgroundLoaded) or (OldState=TpvSceneNodeState.Loading)) and
    (TPasMPInterlocked.CompareExchange(fState,TpvSceneNodeState.Loaded,OldState)=OldState) then begin
  if assigned(fScene) then begin
   if fIsCountToFinishLoadNodes then begin
    fIsCountToFinishLoadNodes:=false;
    TPasMPInterlocked.Decrement(fScene.fCountToFinishLoadNodes);
    InvalidateDirectedAcyclicGraph;
   end;
  end;
 end;
end;

procedure TpvSceneNode.WaitForLoaded;
var ChildNodeIndex:TpvSizeInt;
    ChildNode:TpvSceneNode;
begin
 pvApplication.Log(LOG_DEBUG,ClassName+'.WaitForLoaded','Entering...');
 try
  for ChildNodeIndex:=0 to fChildren.Count-1 do begin
   ChildNode:=fChildren[ChildNodeIndex];
   ChildNode.WaitForLoaded;
  end;
  while TPasMPInterlocked.Read(fState)<TpvSceneNodeState.Loaded do begin
   if not pvApplication.PasMPInstance.StealAndExecuteJob then begin
    Sleep(1);
   end;
  end;
 finally
  pvApplication.Log(LOG_DEBUG,ClassName+'.WaitForLoaded','Leaving...');
 end;
end;

procedure TpvSceneNode.Load;
begin
 if TPasMPInterlocked.CompareExchange(fState,TpvSceneNodeState.ManualLoading,TpvSceneNodeState.ManualLoad)=TpvSceneNodeState.ManualLoad then begin
  try
   StartLoad;
   BackgroundLoad;
   FinishLoad;
   TPasMPInterlocked.Write(fState,TpvSceneNodeState.Loaded);
   InvalidateDirectedAcyclicGraph;
  except
   TPasMPInterlocked.Write(fState,TpvSceneNodeState.Failed);
  end;
 end;
end;

function TpvSceneNode.IsLoaded:boolean;
var ChildNodeIndex:TpvSizeInt;
    ChildNode:TpvSceneNode;
begin
 for ChildNodeIndex:=0 to fChildren.Count-1 do begin
  ChildNode:=fChildren[ChildNodeIndex];
  result:=ChildNode.IsLoaded;
  if not result then begin
   exit;
  end;
 end;
 result:=TPasMPInterlocked.Read(fState)>=TpvSceneNodeState.Loaded;
end;

procedure TpvSceneNode.ResetTimeDuration;
begin
 if fScene.fFirstTimeUpdateInStep then begin
  fTimeDuration:=0;
 end;
end;

procedure TpvSceneNode.TimeBlockBegin;
begin
 fBeginTime:=pvApplication.HighResolutionTimer.GetTime;
end;

procedure TpvSceneNode.TimeBlockEnd;
begin
 fEndTime:=pvApplication.HighResolutionTimer.GetTime;
 inc(fTimeDuration,fEndTime-fBeginTime);
end;

procedure TpvSceneNode.Check;
var ChildNodeIndex:TpvSizeInt;
    ChildNode:TpvSceneNode;
begin
 if (fState=TpvSceneNodeState.Loaded) and not fScene.fUseDirectedAcyclicGraph then begin
  for ChildNodeIndex:=0 to fChildren.Count-1 do begin
   ChildNode:=fChildren[ChildNodeIndex];
   if assigned(ChildNode) and (ChildNode.fState=TpvSceneNodeState.Loaded) then begin
    ChildNode.Check;
   end;
  end;
 end;
end;

procedure TpvSceneNode.Store;
var ChildNodeIndex:TpvSizeInt;
    ChildNode:TpvSceneNode;
begin
 if (fState=TpvSceneNodeState.Loaded) and not fScene.fUseDirectedAcyclicGraph then begin
  for ChildNodeIndex:=0 to fChildren.Count-1 do begin
   ChildNode:=fChildren[ChildNodeIndex];
   if assigned(ChildNode) and (ChildNode.fState=TpvSceneNodeState.Loaded) then begin
    ChildNode.Store;
   end;
  end;
 end;
end;

procedure TpvSceneNode.BeginUpdate(const aDeltaTime:TpvDouble);
var ChildNodeIndex:TpvSizeInt;
    ChildNode:TpvSceneNode;
begin
 if (fState=TpvSceneNodeState.Loaded) and not fScene.fUseDirectedAcyclicGraph then begin
  for ChildNodeIndex:=0 to fChildren.Count-1 do begin
   ChildNode:=fChildren[ChildNodeIndex];
   if assigned(ChildNode) and (ChildNode.fState=TpvSceneNodeState.Loaded) then begin
    ChildNode.BeginUpdate(aDeltaTime);
   end;
  end;
 end;
end;

procedure TpvSceneNode.Update(const aDeltaTime:TpvDouble);
var ChildNodeIndex:TpvSizeInt;
    ChildNode:TpvSceneNode;
begin
 if (fState=TpvSceneNodeState.Loaded) and not fScene.fUseDirectedAcyclicGraph then begin
  for ChildNodeIndex:=0 to fChildren.Count-1 do begin
   ChildNode:=fChildren[ChildNodeIndex];
   if assigned(ChildNode) and (ChildNode.fState=TpvSceneNodeState.Loaded) then begin
    ChildNode.Update(aDeltaTime);
   end;
  end;
 end;
end;

procedure TpvSceneNode.EndUpdate(const aDeltaTime:TpvDouble);
var ChildNodeIndex:TpvSizeInt;
    ChildNode:TpvSceneNode;
begin
 if (fState=TpvSceneNodeState.Loaded) and not fScene.fUseDirectedAcyclicGraph then begin
  for ChildNodeIndex:=0 to fChildren.Count-1 do begin
   ChildNode:=fChildren[ChildNodeIndex];
   if assigned(ChildNode) and (ChildNode.fState=TpvSceneNodeState.Loaded) then begin
    ChildNode.EndUpdate(aDeltaTime);
   end;
  end;
 end;
end;

procedure TpvSceneNode.Interpolate(const aAlpha:TpvDouble);
var ChildNodeIndex:TpvSizeInt;
    ChildNode:TpvSceneNode;
begin
 if (fState=TpvSceneNodeState.Loaded) and not fScene.fUseDirectedAcyclicGraph then begin
  for ChildNodeIndex:=0 to fChildren.Count-1 do begin
   ChildNode:=fChildren[ChildNodeIndex];
   if assigned(ChildNode) and (ChildNode.fState=TpvSceneNodeState.Loaded) then begin
    ChildNode.Interpolate(aAlpha);
   end;
  end;
 end;
end;

procedure TpvSceneNode.FrameUpdate;
var ChildNodeIndex:TpvSizeInt;
    ChildNode:TpvSceneNode;
begin
 if (fState=TpvSceneNodeState.Loaded) and not fScene.fUseDirectedAcyclicGraph then begin
  for ChildNodeIndex:=0 to fChildren.Count-1 do begin
   ChildNode:=fChildren[ChildNodeIndex];
   if assigned(ChildNode) and (ChildNode.fState=TpvSceneNodeState.Loaded) then begin
    ChildNode.FrameUpdate;
   end;
  end;
 end;
end;

procedure TpvSceneNode.Render;
var ChildNodeIndex:TpvSizeInt;
    ChildNode:TpvSceneNode;
begin
 if (fState=TpvSceneNodeState.Loaded) and not fScene.fUseDirectedAcyclicGraph then begin
  for ChildNodeIndex:=0 to fChildren.Count-1 do begin
   ChildNode:=fChildren[ChildNodeIndex];
   if assigned(ChildNode) and (ChildNode.fState=TpvSceneNodeState.Loaded) then begin
    ChildNode.Render;
   end;
  end;
 end;
end;

procedure TpvSceneNode.UpdateAudio;
var ChildNodeIndex:TpvSizeInt;
    ChildNode:TpvSceneNode;
begin
 if (fState=TpvSceneNodeState.Loaded) and not fScene.fUseDirectedAcyclicGraph then begin
  for ChildNodeIndex:=0 to fChildren.Count-1 do begin
   ChildNode:=fChildren[ChildNodeIndex];
   if assigned(ChildNode) and (ChildNode.fState=TpvSceneNodeState.Loaded) then begin
    ChildNode.UpdateAudio;
   end;
  end;
 end;
end;

procedure TpvSceneNode.DumpTimes;
var ChildNodeIndex:TpvSizeInt;
    ChildNode:TpvSceneNode;
begin
 if (fState=TpvSceneNodeState.Loaded) then begin
  WriteLn('  ',ClassName,': ',pvApplication.HighResolutionTimer.ToFloatSeconds(fTimeDuration)*1000.0:7:5,' ms');
  if not fScene.fUseDirectedAcyclicGraph then begin
   for ChildNodeIndex:=0 to fChildren.Count-1 do begin
    ChildNode:=fChildren[ChildNodeIndex];
    if assigned(ChildNode) and (ChildNode.fState=TpvSceneNodeState.Loaded) then begin
     ChildNode.DumpTimes;
    end;
   end;
  end;
 end;
end;

function TpvSceneNode.Serialize:TObject;
begin
 result:=nil;
end;

procedure TpvSceneNode.Deserialize(const aData:TObject);
begin
end;

{ TpvSceneDirectedAcyclicGraph }

constructor TpvSceneDirectedAcyclicGraph.Create(const aScene:TpvScene);
begin

 inherited Create;

 fScene:=aScene;

 fLeafNodes:=TpvSceneNodes.Create;
 fLeafNodes.OwnsObjects:=false;

 fTopologicallySortedNodes:=TpvSceneNodes.Create;
 fTopologicallySortedNodes.OwnsObjects:=false;

 fExecutionLevels:=TpvSceneNodesList.Create;
 fExecutionLevels.OwnsObjects:=true;

 fGeneration:=0;
 fLastGeneration:=0;

 fValid:=false;

 ParallelExecutionDefault:=false;

 fLock:=TPasMPSlimReaderWriterLock.Create;

end;

destructor TpvSceneDirectedAcyclicGraph.Destroy;
begin
 FreeAndNil(fLock);
 FreeAndNil(fExecutionLevels);
 FreeAndNil(fTopologicallySortedNodes);
 FreeAndNil(fLeafNodes);
 inherited Destroy;
end;

procedure TpvSceneDirectedAcyclicGraph.Invalidate;
begin
 TPasMPInterlocked.Increment(fGeneration);
end;

procedure TpvSceneDirectedAcyclicGraph.SetParallelExecutionDefault(const aParallelExecutionDefault:boolean);
begin
 if fParallelExecutionDefault<>aParallelExecutionDefault then begin
  fParallelExecutionDefault:=aParallelExecutionDefault;
  Invalidate;
 end;
end;

procedure TpvSceneDirectedAcyclicGraph.BuildExecutionLevels;
var NodeIndex,LevelIndex,DependencyIndex,ConflictIndex:TpvSizeInt;
    Node,DependencyNode,ConflictNode:TpvSceneNode;
    CurrentLevelCandidates,NextLevelCandidates,CurrentLevel,TemporaryLevelCandidates:TpvSceneNodes;
    ProcessedNodes:TpvSceneNodes;
    RemainingDependencies:TpvSizeIntDynamicArray;
    CanAddToLevel:boolean;
begin

 // Clear existing execution levels
 fExecutionLevels.Clear;

 if not fValid then begin
  // DAG is not valid (has cycles), cannot build execution levels
  exit;
 end;

 ProcessedNodes:=TpvSceneNodes.Create;
 ProcessedNodes.OwnsObjects:=false;
 try

  CurrentLevelCandidates:=TpvSceneNodes.Create;
  CurrentLevelCandidates.OwnsObjects:=false;
  try

   NextLevelCandidates:=TpvSceneNodes.Create;
   NextLevelCandidates.OwnsObjects:=false;
   try

    // Initialize remaining dependencies count for each node
    fScene.fAllNodesLock.Acquire;
    try
     SetLength(RemainingDependencies,fScene.fAllNodes.Count);
     for NodeIndex:=0 to fScene.fAllNodes.Count-1 do begin
      Node:=fScene.fAllNodes[NodeIndex];
      if assigned(Node) then begin
       RemainingDependencies[NodeIndex]:=Node.fDirectedAcyclicGraphInputDependencies.Count;
       // Add nodes with no dependencies to first level candidates
       if RemainingDependencies[NodeIndex]=0 then begin
        CurrentLevelCandidates.Add(Node);
       end;
      end;
     end;
    finally
     fScene.fAllNodesLock.Release;
    end;

    // Build levels
    while CurrentLevelCandidates.Count>0 do begin

     // Process current level candidates, splitting by conflicts and ParallelExecution
     while CurrentLevelCandidates.Count>0 do begin

      CurrentLevel:=TpvSceneNodes.Create;
      CurrentLevel.OwnsObjects:=false;

      // Try to add as many non-conflicting nodes as possible to this level
      NodeIndex:=0;
      while NodeIndex<CurrentLevelCandidates.Count do begin
       Node:=CurrentLevelCandidates[NodeIndex];
       CanAddToLevel:=true;

       // Check if node can be added to current level
       if CurrentLevel.Count>0 then begin

        // If any node in current level has ParallelExecution=false, can't add more
        for LevelIndex:=0 to CurrentLevel.Count-1 do begin
         if not CurrentLevel[LevelIndex].fParallelExecution then begin
          CanAddToLevel:=false;
          break;
         end;
        end;

        // If this node has ParallelExecution=false, can't add to non-empty level
        if CanAddToLevel and (not Node.fParallelExecution) then begin
         CanAddToLevel:=false;
        end;

        // Check for conflicts with nodes already in this level
        if CanAddToLevel then begin
         for LevelIndex:=0 to CurrentLevel.Count-1 do begin
          // Check if Node conflicts with any node in CurrentLevel
          if Node.fConflictingNodes.Contains(CurrentLevel[LevelIndex]) then begin
           CanAddToLevel:=false;
           break;
          end;
          // Also check reverse - if any node in CurrentLevel conflicts with Node
          if CurrentLevel[LevelIndex].fConflictingNodes.Contains(Node) then begin
           CanAddToLevel:=false;
           break;
          end;
         end;
        end;

       end;

       if CanAddToLevel then begin
        // Add node to current level
        CurrentLevel.Add(Node);
        ProcessedNodes.Add(Node);
        CurrentLevelCandidates.Delete(NodeIndex);

        // Update dependencies for dependent nodes
        for DependencyIndex:=0 to Node.fDirectedAcyclicGraphOutputDependencies.Count-1 do begin
         DependencyNode:=Node.fDirectedAcyclicGraphOutputDependencies[DependencyIndex];
         if assigned(DependencyNode) and (DependencyNode.fIndex>=0) and (DependencyNode.fIndex<Length(RemainingDependencies)) then begin
          Dec(RemainingDependencies[DependencyNode.fIndex]);
          if RemainingDependencies[DependencyNode.fIndex]=0 then begin
           // All dependencies satisfied, add to next level candidates
           if not NextLevelCandidates.Contains(DependencyNode) then begin
            NextLevelCandidates.Add(DependencyNode);
           end;
          end;
         end;
        end;

        // If node has ParallelExecution=false, finish this level immediately
        if not Node.fParallelExecution then begin
         break;
        end;

       end else begin
        // Can't add this node to current level, try next node
        inc(NodeIndex);
       end;

      end;

      // Add the completed level to execution levels
      if CurrentLevel.Count>0 then begin
       fExecutionLevels.Add(CurrentLevel);
      end else begin
       FreeAndNil(CurrentLevel);
      end;

     end;

     // Move to next level
     TemporaryLevelCandidates:=NextLevelCandidates;
     NextLevelCandidates:=CurrentLevelCandidates;
     CurrentLevelCandidates:=TemporaryLevelCandidates;
     NextLevelCandidates.Clear;

    end;

   finally
    FreeAndNil(NextLevelCandidates);
   end;

  finally
   FreeAndNil(CurrentLevelCandidates);
  end;

 finally
  FreeAndNil(ProcessedNodes);
 end;
  
end;

procedure TpvSceneDirectedAcyclicGraph.Rebuild;
type TSceneNodeStack=TpvDynamicFastStack<TpvSceneNode>;
var NodeIndex,DependencyIndex:TpvSizeInt;
    Node,DependencyNode:TpvSceneNode;
    NodeStack:TSceneNodeStack;
    CycleDetected:boolean;
begin

 if TPasMPInterlocked.CompareExchange(fLastGeneration,fGeneration,fLastGeneration)<>fGeneration then begin

  fLock.Acquire;
  try
 
   NodeStack.Initialize;
   try
   
    fLeafNodes.ClearNoFree;
    fTopologicallySortedNodes.ClearNoFree;
    
    // Reset visited states and clear per-node DAG dependencies
    fScene.fAllNodesLock.Acquire;
    try
     for NodeIndex:=0 to fScene.fAllNodes.Count-1 do begin
      Node:=fScene.fAllNodes[NodeIndex];
      if assigned(Node) then begin
       Node.fDirectedAcyclicGraphInputDependencies.ClearNoFree;
       Node.fDirectedAcyclicGraphOutputDependencies.ClearNoFree;
       Node.fVisitedState:=TpvSceneNodeVisitedState.Unvisited;
      end;
     end;
    finally
     fScene.fAllNodesLock.Release;
    end;
    
    CycleDetected:=false;
    
    // Build DAG using DFS with cycle detection and topological sorting
    fScene.fAllNodesLock.Acquire;
    try
     for NodeIndex:=0 to fScene.fAllNodes.Count-1 do begin
      Node:=fScene.fAllNodes[NodeIndex];
      
      if assigned(Node) and (Node.fVisitedState=TpvSceneNodeVisitedState.Unvisited) then begin
      
       // Check if this node has any dependencies, dependents, or children
       if (Node.fIncomingNodeDependencies.Count>0) or 
          (Node.fOutgoingNodeDependencies.Count>0) or
          (Node.fChildren.Count>0) or
          assigned(Node.fParent) then begin
          
        NodeStack.Push(Node);
        
        while NodeStack.Pop(Node) do begin
        
         case Node.fVisitedState of
         
          TpvSceneNodeVisitedState.Unvisited:begin
           // Mark as visiting
           Node.fVisitedState:=TpvSceneNodeVisitedState.Visiting;
           
           // Build DirectedAcyclicGraph dependencies from IncomingNodeDependencies
           for DependencyIndex:=0 to Node.fIncomingNodeDependencies.Count-1 do begin
            DependencyNode:=Node.fIncomingNodeDependencies[DependencyIndex];
            if assigned(DependencyNode) and not Node.fDirectedAcyclicGraphInputDependencies.Contains(DependencyNode) then begin
             Node.fDirectedAcyclicGraphInputDependencies.Add(DependencyNode);
             if not DependencyNode.fDirectedAcyclicGraphOutputDependencies.Contains(Node) then begin
              DependencyNode.fDirectedAcyclicGraphOutputDependencies.Add(Node);
             end;
            end;
           end;
           
           // Add implicit parent dependency (parent must execute before child)
           if assigned(Node.fParent) and not Node.fDirectedAcyclicGraphInputDependencies.Contains(Node.fParent) then begin
            Node.fDirectedAcyclicGraphInputDependencies.Add(Node.fParent);
            if not Node.fParent.fDirectedAcyclicGraphOutputDependencies.Contains(Node) then begin
             Node.fParent.fDirectedAcyclicGraphOutputDependencies.Add(Node);
            end;
           end;
           
           // Process incoming dependencies for DFS traversal
           if (Node.fIncomingNodeDependencies.Count>0) or assigned(Node.fParent) then begin
           
            // Push this node again to mark as visited after dependencies
            NodeStack.Push(Node);
            
            // Push all dependencies
            for DependencyIndex:=0 to Node.fIncomingNodeDependencies.Count-1 do begin
             DependencyNode:=Node.fIncomingNodeDependencies[DependencyIndex];
             if assigned(DependencyNode) then begin
              if DependencyNode.fVisitedState=TpvSceneNodeVisitedState.Visiting then begin
               // Cycle detected!
               CycleDetected:=true;
               pvApplication.Log(LOG_ERROR,'TpvSceneDirectedAcyclicGraph.Rebuild','Cycle detected: Node depends on node which is in its dependency chain');
              end else if DependencyNode.fVisitedState=TpvSceneNodeVisitedState.Unvisited then begin
               NodeStack.Push(DependencyNode);
              end;
             end;
            end;
            
            // Also push parent as dependency
            if assigned(Node.fParent) then begin
             if Node.fParent.fVisitedState=TpvSceneNodeVisitedState.Visiting then begin
              // Cycle detected (parent depends on child, should not happen in tree!)
              CycleDetected:=true;
              pvApplication.Log(LOG_ERROR,'TpvSceneDirectedAcyclicGraph.Rebuild','Cycle detected: Parent depends on child in tree structure');
             end else if Node.fParent.fVisitedState=TpvSceneNodeVisitedState.Unvisited then begin
              NodeStack.Push(Node.fParent);
             end;
            end;
            
           end else begin
            // No dependencies, mark as visited and add to sorted lists
            Node.fVisitedState:=TpvSceneNodeVisitedState.Visited;
            fTopologicallySortedNodes.Add(Node);
            
            // Check if this is a leaf node (no output dependencies)
            if Node.fOutgoingNodeDependencies.Count=0 then begin
             fLeafNodes.Add(Node);
            end;
           end;
           
          end;
          
          TpvSceneNodeVisitedState.Visiting:begin
           // Coming back after processing dependencies
           Node.fVisitedState:=TpvSceneNodeVisitedState.Visited;
           fTopologicallySortedNodes.Add(Node);
           
           // Check if this is a leaf node
           if Node.fOutgoingNodeDependencies.Count=0 then begin
            fLeafNodes.Add(Node);
           end;
          end;
          
         end;
         
        end;
        
       end else begin
        // Node with no dependencies or dependents
        Node.fVisitedState:=TpvSceneNodeVisitedState.Visited;
        fLeafNodes.Add(Node);
        fTopologicallySortedNodes.Add(Node);
       end;
       
      end;
      
     end;
    finally
     fScene.fAllNodesLock.Release;
    end;
    
    if CycleDetected then begin
     pvApplication.Log(LOG_ERROR,'TpvSceneDirectedAcyclicGraph.Rebuild','Dependency cycles detected. Some nodes may not process in the correct order.');
    end;
    
    fValid:=not CycleDetected;
    
   finally
    NodeStack.Finalize;
   end;
   
   // Build execution levels after DAG is constructed
   BuildExecutionLevels;
   
  finally
   fLock.Release;
  end;

 end;

end;

{ TpvScene }

constructor TpvScene.Create(const aData:TObject=nil);
begin

 inherited Create;

 fPasMPInstance:=pvApplication.PasMPInstance;

 fAllNodesLock:=TPasMPSlimReaderWriterLock.Create;

 fAllNodes:=TpvSceneNodes.Create(false);

 fRootNode:=TpvSceneNode.Create(nil);
 fRootNode.fScene:=self;

 fCountToStartLoadNodes:=0;
 fCountToBackgroundLoadNodes:=0;
 fCountToFinishLoadNodes:=0;

 fData:=aData;

 fStartLoadVisitGeneration:=1;
 fBackgroundLoadVisitGeneration:=1;
 fFinishLoadVisitGeneration:=1;

 fBackgroundLoadJob:=nil;

 fDirectedAcyclicGraph:=TpvSceneDirectedAcyclicGraph.Create(self);

 fUseDirectedAcyclicGraph:=false;

 fFirstTimeUpdateInStep:=true;

 fParallelStages:=[];

end;

destructor TpvScene.Destroy;
begin

 Shutdown;

 FreeAndNil(fDirectedAcyclicGraph);

 FreeAndNil(fRootNode);

 FreeAndNil(fAllNodes);

 FreeAndNil(fAllNodesLock);

 inherited Destroy;

end;

procedure TpvScene.Shutdown;
begin
 if assigned(fBackgroundLoadJob) then begin
  try
   pvApplication.PasMPInstance.WaitRelease(fBackgroundLoadJob);
  finally
   fBackgroundLoadJob:=nil;
  end;
 end;
end; 

procedure TpvScene.InvalidateDirectedAcyclicGraph;
begin
 if assigned(fDirectedAcyclicGraph) then begin
  fDirectedAcyclicGraph.Invalidate;
 end;
end;

procedure TpvScene.RebuildDirectedAcyclicGraph;
begin
 if assigned(fDirectedAcyclicGraph) then begin
  fDirectedAcyclicGraph.Rebuild;
 end;
end;

procedure TpvScene.BackgroundLoadJobMethod(const aJob:PPasMPJob;const aThreadIndex:TPasMPInt32);
begin
//if pvApplication.PasMPInstance.JobWorkerThreads[aThreadIndex].Depth<=1 then begin
 BackgroundLoad;
{end else begin
  TPasMPInterlocked.BitwiseOr(aJob^.InternalData,PasMPJobFlagRequeue);
 end;}
end;

procedure TpvScene.StartLoad;
type TStackItem=record
      Node:TpvSceneNode;
      Pass:TpvSizeInt;
     end;
     PStackItem=^TStackItem;
     TStack=TpvDynamicFastStack<TStackItem>;
var Index,Pass:TpvSizeInt;
    Stack:TStack;
    NewStackItem:PStackItem;
    CurrentStackItem:TStackItem;
    Node:TpvSceneNode;
begin
 Stack.Initialize;
 try
  NewStackItem:=Pointer(Stack.PushIndirect);
  NewStackItem^.Node:=fRootNode;
  NewStackItem^.Pass:=0;
  while Stack.Pop(CurrentStackItem) do begin
   Node:=CurrentStackItem.Node;
   Pass:=CurrentStackItem.Pass;
   repeat
    case Pass of
     0:begin
      if Node.fStartLoadVisitGeneration<>fStartLoadVisitGeneration then begin
       Node.fStartLoadVisitGeneration:=fStartLoadVisitGeneration;
       if Node.fIncomingNodeDependencies.Count>0 then begin
        NewStackItem:=Pointer(Stack.PushIndirect);
        NewStackItem^.Node:=Node;
        NewStackItem^.Pass:=1;
        for Index:=Node.fIncomingNodeDependencies.Count-1 downto 0 do begin
         NewStackItem:=Pointer(Stack.PushIndirect);
         NewStackItem^.Node:=Node.fIncomingNodeDependencies[Index];
         NewStackItem^.Pass:=0;
        end;       
       end else begin
        Pass:=1;
        continue;
       end;
      end; 
     end;
     1:begin     
      if TPasMPInterlocked.Read(Node.fState)=TpvSceneNodeState.Unloaded then begin
       NewStackItem:=Pointer(Stack.PushIndirect);
       NewStackItem^.Node:=Node;
       NewStackItem^.Pass:=2;
       try
        Node.BeforeStartLoad;
       except
        on e:Exception do begin
         pvApplication.Log(LOG_ERROR,ClassName+'.StartLoad',DumpExceptionCallStack(e));
         if TPasMPInterlocked.CompareExchange(Node.fState,TpvSceneNodeState.Failed,TpvSceneNodeState.Unloaded)=TpvSceneNodeState.Unloaded then begin
          if Node.fIsCountToStartLoadNodes then begin
           Node.fIsCountToStartLoadNodes:=false;
           TPasMPInterlocked.Decrement(fCountToStartLoadNodes);
          end;
         end;
        end;
       end;
      end;
      if Node.Children.Count>0 then begin
       for Index:=Node.Children.Count-1 downto 0 do begin
        NewStackItem:=Pointer(Stack.PushIndirect);
        NewStackItem^.Node:=Node.Children[Index];
        NewStackItem^.Pass:=0;
       end;
      end;
     end;
     2:begin
      if TPasMPInterlocked.CompareExchange(Node.fState,TpvSceneNodeState.StartLoading,TpvSceneNodeState.Unloaded)=TpvSceneNodeState.Unloaded then begin
       try
        Node.StartLoad;
        Node.AfterStartLoad;
       except
        on e:Exception do begin
         pvApplication.Log(LOG_ERROR,ClassName+'.StartLoad',DumpExceptionCallStack(e));
         if TPasMPInterlocked.CompareExchange(Node.fState,TpvSceneNodeState.Failed,TpvSceneNodeState.StartLoading)=TpvSceneNodeState.StartLoading then begin
          if Node.fIsCountToStartLoadNodes then begin
           Node.fIsCountToStartLoadNodes:=false;
           TPasMPInterlocked.Decrement(fCountToStartLoadNodes);
          end;
         end;
        end;
       end;
      end;
     end;    
    end;
    break;
   until false;
  end;
 finally
  Stack.Finalize;
 end;
 inc(fStartLoadVisitGeneration);
end;

procedure TpvScene.BackgroundLoad;
type TStackItem=record
      Node:TpvSceneNode;
      Pass:TpvSizeInt;
     end;
     PStackItem=^TStackItem;
     TStack=TpvDynamicFastStack<TStackItem>;
var Index,Pass:TpvSizeInt;
    Stack:TStack;
    NewStackItem:PStackItem;
    CurrentStackItem:TStackItem;
    Node:TpvSceneNode;
begin
 Stack.Initialize;
 try
  NewStackItem:=Pointer(Stack.PushIndirect);
  NewStackItem^.Node:=fRootNode;
  NewStackItem^.Pass:=0;
  while Stack.Pop(CurrentStackItem) do begin
   Node:=CurrentStackItem.Node;
   Pass:=CurrentStackItem.Pass;
   repeat
    case Pass of
     0:begin
      if Node.fBackgroundLoadVisitGeneration<>fBackgroundLoadVisitGeneration then begin
       Node.fBackgroundLoadVisitGeneration:=fBackgroundLoadVisitGeneration;
       if Node.fIncomingNodeDependencies.Count>0 then begin
        NewStackItem:=Pointer(Stack.PushIndirect);
        NewStackItem^.Node:=Node;
        NewStackItem^.Pass:=1;
        for Index:=Node.fIncomingNodeDependencies.Count-1 downto 0 do begin
         NewStackItem:=Pointer(Stack.PushIndirect);
         NewStackItem^.Node:=Node.fIncomingNodeDependencies[Index];
         NewStackItem^.Pass:=0;
        end;       
       end else begin
        Pass:=1;
        continue;
       end;
      end; 
     end;
     1:begin     
      if TPasMPInterlocked.Read(Node.fState)=TpvSceneNodeState.StartLoaded then begin
       NewStackItem:=Pointer(Stack.PushIndirect);
       NewStackItem^.Node:=Node;
       NewStackItem^.Pass:=2;
       try
        Node.BeforeBackgroundLoad;
       except
        on e:Exception do begin
         pvApplication.Log(LOG_ERROR,ClassName+'.BackgroundLoad',DumpExceptionCallStack(e));
         if TPasMPInterlocked.CompareExchange(Node.fState,TpvSceneNodeState.Failed,TpvSceneNodeState.StartLoaded)=TpvSceneNodeState.StartLoaded then begin
          if Node.fIsCountToBackgroundLoadNodes then begin
           Node.fIsCountToBackgroundLoadNodes:=false;
           TPasMPInterlocked.Decrement(fCountToBackgroundLoadNodes);
          end;
         end;
        end;
       end;
      end;
      if Node.Children.Count>0 then begin
       for Index:=Node.Children.Count-1 downto 0 do begin
        NewStackItem:=Pointer(Stack.PushIndirect);
        NewStackItem^.Node:=Node.Children[Index];
        NewStackItem^.Pass:=0;
       end;
      end;
     end;
     2:begin
      if TPasMPInterlocked.CompareExchange(Node.fState,TpvSceneNodeState.BackgroundLoading,TpvSceneNodeState.StartLoaded)=TpvSceneNodeState.StartLoaded then begin
       try
        Node.BackgroundLoad;
        Node.AfterBackgroundLoad;
       except
        on e:Exception do begin
         pvApplication.Log(LOG_ERROR,ClassName+'.BackgroundLoad',DumpExceptionCallStack(e));
         if TPasMPInterlocked.CompareExchange(Node.fState,TpvSceneNodeState.Failed,TpvSceneNodeState.BackgroundLoading)=TpvSceneNodeState.BackgroundLoading then begin
          if Node.fIsCountToBackgroundLoadNodes then begin
           Node.fIsCountToBackgroundLoadNodes:=false;
           TPasMPInterlocked.Decrement(fCountToBackgroundLoadNodes);
          end;
         end;
        end;
       end;
      end;
     end;
    end;
    break;
   until false;
  end;
 finally
  Stack.Finalize;
 end;
 inc(fBackgroundLoadVisitGeneration);
end;

procedure TpvScene.FinishLoad;
type TStackItem=record
      Node:TpvSceneNode;
      Pass:TpvSizeInt;
     end;
     PStackItem=^TStackItem;
     TStack=TpvDynamicFastStack<TStackItem>;
var Index,Pass:TpvSizeInt;
    Stack:TStack;
    NewStackItem:PStackItem;
    CurrentStackItem:TStackItem;
    Node:TpvSceneNode;
begin
 Stack.Initialize;
 try
  NewStackItem:=Pointer(Stack.PushIndirect);
  NewStackItem^.Node:=fRootNode;
  NewStackItem^.Pass:=0;
  while Stack.Pop(CurrentStackItem) do begin
   Node:=CurrentStackItem.Node;
   Pass:=CurrentStackItem.Pass;
   repeat
    case Pass of
     0:begin
      if Node.fFinishLoadVisitGeneration<>fFinishLoadVisitGeneration then begin
       Node.fFinishLoadVisitGeneration:=fFinishLoadVisitGeneration;
       if Node.fIncomingNodeDependencies.Count>0 then begin
        NewStackItem:=Pointer(Stack.PushIndirect);
        NewStackItem^.Node:=Node;
        NewStackItem^.Pass:=1;
        for Index:=Node.fIncomingNodeDependencies.Count-1 downto 0 do begin
         NewStackItem:=Pointer(Stack.PushIndirect);
         NewStackItem^.Node:=Node.fIncomingNodeDependencies[Index];
         NewStackItem^.Pass:=0;
        end;       
       end else begin
        Pass:=1;
        continue;
       end;
      end;
     end;
     1:begin     
      if TPasMPInterlocked.Read(Node.fState)=TpvSceneNodeState.BackgroundLoaded then begin
       NewStackItem:=Pointer(Stack.PushIndirect);
       NewStackItem^.Node:=Node;
       NewStackItem^.Pass:=2;
       try
        Node.BeforeFinishLoad;
       except
        on e:Exception do begin
         pvApplication.Log(LOG_ERROR,ClassName+'.FinishLoad',DumpExceptionCallStack(e));
         if TPasMPInterlocked.CompareExchange(Node.fState,TpvSceneNodeState.Failed,TpvSceneNodeState.BackgroundLoaded)=TpvSceneNodeState.BackgroundLoaded then begin
          if Node.fIsCountToFinishLoadNodes then begin
           Node.fIsCountToFinishLoadNodes:=false;
           TPasMPInterlocked.Decrement(fCountToFinishLoadNodes);
          end;
         end;
        end;
       end;
      end;
      if Node.Children.Count>0 then begin
       for Index:=Node.Children.Count-1 downto 0 do begin
        NewStackItem:=Pointer(Stack.PushIndirect);
        NewStackItem^.Node:=Node.Children[Index];
        NewStackItem^.Pass:=0;
       end;
      end;
     end;
     2:begin
      if TPasMPInterlocked.CompareExchange(Node.fState,TpvSceneNodeState.Loading,TpvSceneNodeState.BackgroundLoaded)=TpvSceneNodeState.BackgroundLoaded then begin
       try
        Node.FinishLoad;
        Node.AfterFinishLoad;
        InvalidateDirectedAcyclicGraph;
       except
        on e:Exception do begin
         pvApplication.Log(LOG_ERROR,ClassName+'.FinishLoad',DumpExceptionCallStack(e));
         if TPasMPInterlocked.CompareExchange(Node.fState,TpvSceneNodeState.Failed,TpvSceneNodeState.Loading)=TpvSceneNodeState.Loading then begin
          if Node.fIsCountToFinishLoadNodes then begin
           Node.fIsCountToFinishLoadNodes:=false;
           TPasMPInterlocked.Decrement(fCountToFinishLoadNodes);
          end;
         end;
        end;
       end;
      end;
     end;
    end;
    break;
   until false;
  end;
 finally
  Stack.Finalize;
 end;
 inc(fFinishLoadVisitGeneration);
end;

procedure TpvScene.WaitForLoaded;
begin
 fRootNode.WaitForLoaded;
end;

function TpvScene.IsLoaded:boolean;
begin
 result:=fRootNode.IsLoaded;
end;

procedure TpvScene.LoadSynchronizationPoint;
begin
 
 if TPasMPInterlocked.Read(fCountToStartLoadNodes)>0 then begin
  StartLoad;
 end;
 
 repeat

  if assigned(fBackgroundLoadJob) then begin

   if pvApplication.PasMPInstance.IsJobValid(fBackgroundLoadJob) then begin
    break;
   end;

   try
    pvApplication.PasMPInstance.WaitRelease(fBackgroundLoadJob);
   finally
    fBackgroundLoadJob:=nil;
   end;

  end;

  if TPasMPInterlocked.Read(fCountToBackgroundLoadNodes)>0 then begin
   fBackgroundLoadJob:=pvApplication.PasMPInstance.Acquire(BackgroundLoadJobMethod,nil,nil,0,0);
   pvApplication.PasMPInstance.Run(fBackgroundLoadJob,true);
  end;

  break;

 until false;

 if TPasMPInterlocked.Read(fCountToFinishLoadNodes)>0 then begin
  FinishLoad;
 end;

end;

procedure TpvScene.CheckParallelForJob(const aJob:PPasMPJob;const ThreadIndex:TPasMPInt32;const aData:pointer;const aFromIndex,aToIndex:TPasMPNativeInt);
var ExecutionLevelNodeIndex:TpvSizeInt;
    ExecutionLevelNodes:TpvSceneNodes;
begin
 ExecutionLevelNodes:=aData;
 for ExecutionLevelNodeIndex:=aFromIndex to aToIndex do begin
  ExecutionLevelNodes.RawItems[ExecutionLevelNodeIndex].Check;
 end;
end;

procedure TpvScene.Check;
var ExecutionLevelIndex,ExecutionLevelNodeIndex:TpvSizeInt;
    ExecutionLevelNodes:TpvSceneNodes;
begin
 if fUseDirectedAcyclicGraph then begin
  RebuildDirectedAcyclicGraph;
  for ExecutionLevelIndex:=0 to fDirectedAcyclicGraph.fExecutionLevels.Count-1 do begin
   ExecutionLevelNodes:=fDirectedAcyclicGraph.fExecutionLevels.RawItems[ExecutionLevelIndex];
   if ExecutionLevelNodes.Count>0 then begin
    if ExecutionLevelNodes.Count>1 then begin
     if assigned(fPasMPInstance) and (TpvScene.TStage.Check in fParallelStages) then begin
      fPasMPInstance.Invoke(
       fPasMPInstance.ParallelFor(
        ExecutionLevelNodes,
        0,
        ExecutionLevelNodes.Count-1,
        CheckParallelForJob,
        -4,
        PasMPDefaultDepth,
        nil,
        0,
        PasMPAreaMaskUpdate,
        PasMPAreaMaskRender or PasMPAreaMaskBackgroundLoading,        
        false,
        PasMPAffinityMaskUpdateAllowMask,
        PasMPAffinityMaskUpdateAvoidMask
       )
      );
     end else begin
      for ExecutionLevelNodeIndex:=0 to ExecutionLevelNodes.Count-1 do begin
       ExecutionLevelNodes.RawItems[ExecutionLevelNodeIndex].Check;
      end;
     end;
    end else begin
     ExecutionLevelNodes[0].Check;
    end;
   end;
  end;
 end else begin
  fRootNode.Check;
 end;
end;

procedure TpvScene.StoreParallelForJob(const aJob:PPasMPJob;const ThreadIndex:TPasMPInt32;const aData:pointer;const aFromIndex,aToIndex:TPasMPNativeInt);
var ExecutionLevelNodeIndex:TpvSizeInt;
    ExecutionLevelNodes:TpvSceneNodes;
begin
 ExecutionLevelNodes:=aData;
 for ExecutionLevelNodeIndex:=aFromIndex to aToIndex do begin
  ExecutionLevelNodes.RawItems[ExecutionLevelNodeIndex].Store;
 end;
end;

procedure TpvScene.Store;
var ExecutionLevelIndex,ExecutionLevelNodeIndex:TpvSizeInt;
    ExecutionLevelNodes:TpvSceneNodes;
begin
 if fUseDirectedAcyclicGraph then begin
  RebuildDirectedAcyclicGraph;
  for ExecutionLevelIndex:=0 to fDirectedAcyclicGraph.fExecutionLevels.Count-1 do begin
   ExecutionLevelNodes:=fDirectedAcyclicGraph.fExecutionLevels.RawItems[ExecutionLevelIndex];
   if ExecutionLevelNodes.Count>0 then begin
    if ExecutionLevelNodes.Count>1 then begin
     if assigned(fPasMPInstance) and (TpvScene.TStage.Store in fParallelStages) then begin
      fPasMPInstance.Invoke(
       fPasMPInstance.ParallelFor(
        ExecutionLevelNodes,
        0,
        ExecutionLevelNodes.Count-1,
        StoreParallelForJob,
        -4,
        PasMPDefaultDepth,
        nil,
        0,
        PasMPAreaMaskUpdate,
        PasMPAreaMaskRender or PasMPAreaMaskBackgroundLoading,        
        false,
        PasMPAffinityMaskUpdateAllowMask,
        PasMPAffinityMaskUpdateAvoidMask
       )
      );
     end else begin
      for ExecutionLevelNodeIndex:=0 to ExecutionLevelNodes.Count-1 do begin
       ExecutionLevelNodes.RawItems[ExecutionLevelNodeIndex].Store;
      end;
     end;
    end else begin
     ExecutionLevelNodes[0].Store;
    end;
   end;
  end;
 end else begin
  fRootNode.Store;
 end;
end;

procedure TpvScene.BeginUpdateParallelForJob(const aJob:PPasMPJob;const ThreadIndex:TPasMPInt32;const aData:pointer;const aFromIndex,aToIndex:TPasMPNativeInt);
var ExecutionLevelNodeIndex:TpvSizeInt;
    ExecutionLevelNodes:TpvSceneNodes;
begin
 ExecutionLevelNodes:=aData;
 for ExecutionLevelNodeIndex:=aFromIndex to aToIndex do begin
  ExecutionLevelNodes.RawItems[ExecutionLevelNodeIndex].BeginUpdate(fDeltaTime);
 end;
end;

procedure TpvScene.BeginUpdate(const aDeltaTime:TpvDouble);
var ExecutionLevelIndex,ExecutionLevelNodeIndex:TpvSizeInt;
    ExecutionLevelNodes:TpvSceneNodes;
begin
 if fUseDirectedAcyclicGraph then begin
  RebuildDirectedAcyclicGraph;
  fDeltaTime:=aDeltaTime;
  for ExecutionLevelIndex:=0 to fDirectedAcyclicGraph.fExecutionLevels.Count-1 do begin
   ExecutionLevelNodes:=fDirectedAcyclicGraph.fExecutionLevels.RawItems[ExecutionLevelIndex];
   if ExecutionLevelNodes.Count>0 then begin
    if ExecutionLevelNodes.Count>1 then begin
     if assigned(fPasMPInstance) and (TpvScene.TStage.BeginUpdate in fParallelStages) then begin
      fPasMPInstance.Invoke(
       fPasMPInstance.ParallelFor(
        ExecutionLevelNodes,
        0,
        ExecutionLevelNodes.Count-1,
        BeginUpdateParallelForJob,
        -4,
        PasMPDefaultDepth,
        nil,
        0,
        PasMPAreaMaskUpdate,
        PasMPAreaMaskRender or PasMPAreaMaskBackgroundLoading,        
        false,
        PasMPAffinityMaskUpdateAllowMask,
        PasMPAffinityMaskUpdateAvoidMask
       )
      );
     end else begin
      for ExecutionLevelNodeIndex:=0 to ExecutionLevelNodes.Count-1 do begin
       ExecutionLevelNodes.RawItems[ExecutionLevelNodeIndex].BeginUpdate(aDeltaTime);
      end;
     end;
    end else begin
     ExecutionLevelNodes[0].BeginUpdate(aDeltaTime);
    end;
   end;
  end;
 end else begin
  fRootNode.BeginUpdate(aDeltaTime);
 end;
end;

procedure TpvScene.UpdateParallelForJob(const aJob:PPasMPJob;const ThreadIndex:TPasMPInt32;const aData:pointer;const aFromIndex,aToIndex:TPasMPNativeInt);
var ExecutionLevelNodeIndex:TpvSizeInt;
    ExecutionLevelNodes:TpvSceneNodes;
begin
 ExecutionLevelNodes:=aData;
 for ExecutionLevelNodeIndex:=aFromIndex to aToIndex do begin
  ExecutionLevelNodes.RawItems[ExecutionLevelNodeIndex].Update(fDeltaTime);
 end;
end;

procedure TpvScene.Update(const aDeltaTime:TpvDouble);
var ExecutionLevelIndex,ExecutionLevelNodeIndex:TpvSizeInt;
    ExecutionLevelNodes:TpvSceneNodes;
begin
 if fUseDirectedAcyclicGraph then begin
  RebuildDirectedAcyclicGraph;
  fDeltaTime:=aDeltaTime;
  for ExecutionLevelIndex:=0 to fDirectedAcyclicGraph.fExecutionLevels.Count-1 do begin
   ExecutionLevelNodes:=fDirectedAcyclicGraph.fExecutionLevels.RawItems[ExecutionLevelIndex];
   if ExecutionLevelNodes.Count>0 then begin
    if ExecutionLevelNodes.Count>1 then begin
     if assigned(fPasMPInstance) and (TpvScene.TStage.Update in fParallelStages) then begin
      fPasMPInstance.Invoke(
       fPasMPInstance.ParallelFor(
        ExecutionLevelNodes,
        0,
        ExecutionLevelNodes.Count-1,
        UpdateParallelForJob,
        -4,
        PasMPDefaultDepth,
        nil,
        0,
        PasMPAreaMaskUpdate,
        PasMPAreaMaskRender or PasMPAreaMaskBackgroundLoading,        
        false,
        PasMPAffinityMaskUpdateAllowMask,
        PasMPAffinityMaskUpdateAvoidMask
       )
      );
     end else begin
      for ExecutionLevelNodeIndex:=0 to ExecutionLevelNodes.Count-1 do begin
       ExecutionLevelNodes.RawItems[ExecutionLevelNodeIndex].Update(aDeltaTime);
      end;
     end;
    end else begin
     ExecutionLevelNodes[0].Update(aDeltaTime);
    end;
   end;
  end;
 end else begin
  fRootNode.Update(aDeltaTime);
 end;
end;

procedure TpvScene.EndUpdateParallelForJob(const aJob:PPasMPJob;const ThreadIndex:TPasMPInt32;const aData:pointer;const aFromIndex,aToIndex:TPasMPNativeInt);
var ExecutionLevelNodeIndex:TpvSizeInt;
    ExecutionLevelNodes:TpvSceneNodes;
begin
 ExecutionLevelNodes:=aData;
 for ExecutionLevelNodeIndex:=aFromIndex to aToIndex do begin
  ExecutionLevelNodes.RawItems[ExecutionLevelNodeIndex].EndUpdate(fDeltaTime);
 end;
end;

procedure TpvScene.EndUpdate(const aDeltaTime:TpvDouble);
var ExecutionLevelIndex,ExecutionLevelNodeIndex:TpvSizeInt;
    ExecutionLevelNodes:TpvSceneNodes;
begin
 if fUseDirectedAcyclicGraph then begin
  RebuildDirectedAcyclicGraph;
  fDeltaTime:=aDeltaTime;
  for ExecutionLevelIndex:=0 to fDirectedAcyclicGraph.fExecutionLevels.Count-1 do begin
   ExecutionLevelNodes:=fDirectedAcyclicGraph.fExecutionLevels.RawItems[ExecutionLevelIndex];
   if ExecutionLevelNodes.Count>0 then begin
    if ExecutionLevelNodes.Count>1 then begin
     if assigned(fPasMPInstance) and (TpvScene.TStage.EndUpdate in fParallelStages) then begin
      fPasMPInstance.Invoke(
       fPasMPInstance.ParallelFor(
        ExecutionLevelNodes,
        0,
        ExecutionLevelNodes.Count-1,
        EndUpdateParallelForJob,
        -4,
        PasMPDefaultDepth,
        nil,
        0,
        PasMPAreaMaskUpdate,
        PasMPAreaMaskRender or PasMPAreaMaskBackgroundLoading,        
        false,
        PasMPAffinityMaskUpdateAllowMask,
        PasMPAffinityMaskUpdateAvoidMask
       )
      );
     end else begin
      for ExecutionLevelNodeIndex:=0 to ExecutionLevelNodes.Count-1 do begin
       ExecutionLevelNodes.RawItems[ExecutionLevelNodeIndex].EndUpdate(aDeltaTime);
      end;
     end;
    end else begin
     ExecutionLevelNodes[0].EndUpdate(aDeltaTime);
    end;
   end;
  end;
 end else begin
  fRootNode.EndUpdate(aDeltaTime);
 end;
end;

procedure TpvScene.InterpolateParallelForJob(const aJob:PPasMPJob;const ThreadIndex:TPasMPInt32;const aData:pointer;const aFromIndex,aToIndex:TPasMPNativeInt);
var ExecutionLevelNodeIndex:TpvSizeInt;
    ExecutionLevelNodes:TpvSceneNodes;
begin
 ExecutionLevelNodes:=aData;
 for ExecutionLevelNodeIndex:=aFromIndex to aToIndex do begin
  ExecutionLevelNodes.RawItems[ExecutionLevelNodeIndex].Interpolate(fAlpha);
 end;
end;

procedure TpvScene.Interpolate(const aAlpha:TpvDouble);
var ExecutionLevelIndex,ExecutionLevelNodeIndex:TpvSizeInt;
    ExecutionLevelNodes:TpvSceneNodes;
begin
 if fUseDirectedAcyclicGraph then begin
  RebuildDirectedAcyclicGraph;
  fAlpha:=aAlpha;
  for ExecutionLevelIndex:=0 to fDirectedAcyclicGraph.fExecutionLevels.Count-1 do begin
   ExecutionLevelNodes:=fDirectedAcyclicGraph.fExecutionLevels.RawItems[ExecutionLevelIndex];
   if ExecutionLevelNodes.Count>0 then begin
    if ExecutionLevelNodes.Count>1 then begin
     if assigned(fPasMPInstance) and (TpvScene.TStage.Interpolate in fParallelStages) then begin
      fPasMPInstance.Invoke(
       fPasMPInstance.ParallelFor(
        ExecutionLevelNodes,
        0,
        ExecutionLevelNodes.Count-1,
        InterpolateParallelForJob,
        -4,
        PasMPDefaultDepth,
        nil,
        0,
        PasMPAreaMaskUpdate,
        PasMPAreaMaskRender or PasMPAreaMaskBackgroundLoading,
        false,
        PasMPAffinityMaskUpdateAllowMask,
        PasMPAffinityMaskUpdateAvoidMask
       )
      );
     end else begin
      for ExecutionLevelNodeIndex:=0 to ExecutionLevelNodes.Count-1 do begin
       ExecutionLevelNodes.RawItems[ExecutionLevelNodeIndex].Interpolate(aAlpha);
      end;
     end;
    end else begin
     ExecutionLevelNodes[0].Interpolate(aAlpha);
    end;
   end;
  end;
 end else begin
  fRootNode.Interpolate(aAlpha);
 end;
end;

procedure TpvScene.FrameUpdateParallelForJob(const aJob:PPasMPJob;const ThreadIndex:TPasMPInt32;const aData:pointer;const aFromIndex,aToIndex:TPasMPNativeInt);
var ExecutionLevelNodeIndex:TpvSizeInt;
    ExecutionLevelNodes:TpvSceneNodes;
begin
 ExecutionLevelNodes:=aData;
 for ExecutionLevelNodeIndex:=aFromIndex to aToIndex do begin
  ExecutionLevelNodes.RawItems[ExecutionLevelNodeIndex].FrameUpdate;
 end;
end;

procedure TpvScene.FrameUpdate;
var ExecutionLevelIndex,ExecutionLevelNodeIndex:TpvSizeInt;
    ExecutionLevelNodes:TpvSceneNodes;
begin
 if fUseDirectedAcyclicGraph then begin
  RebuildDirectedAcyclicGraph;
  for ExecutionLevelIndex:=0 to fDirectedAcyclicGraph.fExecutionLevels.Count-1 do begin
   ExecutionLevelNodes:=fDirectedAcyclicGraph.fExecutionLevels.RawItems[ExecutionLevelIndex];
   if ExecutionLevelNodes.Count>0 then begin
    if ExecutionLevelNodes.Count>1 then begin
     if assigned(fPasMPInstance) and (TpvScene.TStage.FrameUpdate in fParallelStages) then begin
      fPasMPInstance.Invoke(
       fPasMPInstance.ParallelFor(
        ExecutionLevelNodes,
        0,
        ExecutionLevelNodes.Count-1,
        FrameUpdateParallelForJob,
        -4,
        PasMPDefaultDepth,
        nil,
        0,
        PasMPAreaMaskUpdate,
        PasMPAreaMaskRender or PasMPAreaMaskBackgroundLoading,        
        false,
        PasMPAffinityMaskUpdateAllowMask,
        PasMPAffinityMaskUpdateAvoidMask
       )
      );
     end else begin
      for ExecutionLevelNodeIndex:=0 to ExecutionLevelNodes.Count-1 do begin
       ExecutionLevelNodes.RawItems[ExecutionLevelNodeIndex].FrameUpdate;
      end;
     end;
    end else begin
     ExecutionLevelNodes[0].FrameUpdate;
    end;
   end;
  end;
 end else begin
  fRootNode.FrameUpdate;
 end;
end;

procedure TpvScene.RenderParallelForJob(const aJob:PPasMPJob;const ThreadIndex:TPasMPInt32;const aData:pointer;const aFromIndex,aToIndex:TPasMPNativeInt);
var ExecutionLevelNodeIndex:TpvSizeInt;
    ExecutionLevelNodes:TpvSceneNodes;
begin
 ExecutionLevelNodes:=aData;
 for ExecutionLevelNodeIndex:=aFromIndex to aToIndex do begin
  ExecutionLevelNodes.RawItems[ExecutionLevelNodeIndex].Render;
 end;
end;

procedure TpvScene.Render;
var ExecutionLevelIndex,ExecutionLevelNodeIndex:TpvSizeInt;
    ExecutionLevelNodes:TpvSceneNodes;
begin
 if fUseDirectedAcyclicGraph then begin
  RebuildDirectedAcyclicGraph;
  for ExecutionLevelIndex:=0 to fDirectedAcyclicGraph.fExecutionLevels.Count-1 do begin
   ExecutionLevelNodes:=fDirectedAcyclicGraph.fExecutionLevels.RawItems[ExecutionLevelIndex];
   if ExecutionLevelNodes.Count>0 then begin
    if ExecutionLevelNodes.Count>1 then begin
     if assigned(fPasMPInstance) and (TpvScene.TStage.Render in fParallelStages) then begin
      fPasMPInstance.Invoke(
       fPasMPInstance.ParallelFor(
        ExecutionLevelNodes,
        0,
        ExecutionLevelNodes.Count-1,
        RenderParallelForJob,
        -4,
        PasMPDefaultDepth,
        nil,
        0,
        PasMPAreaMaskUpdate,
        PasMPAreaMaskRender or PasMPAreaMaskBackgroundLoading,
        false,
        PasMPAffinityMaskUpdateAllowMask,
        PasMPAffinityMaskUpdateAvoidMask
       )
      );
     end else begin
      for ExecutionLevelNodeIndex:=0 to ExecutionLevelNodes.Count-1 do begin
       ExecutionLevelNodes.RawItems[ExecutionLevelNodeIndex].Render;
      end;
     end;
    end else begin
     ExecutionLevelNodes[0].Render;
    end;
   end;
  end;
 end else begin
  fRootNode.Render;
 end;
end;

procedure TpvScene.UpdateAudioParallelForJob(const aJob:PPasMPJob;const ThreadIndex:TPasMPInt32;const aData:pointer;const aFromIndex,aToIndex:TPasMPNativeInt);
var ExecutionLevelNodeIndex:TpvSizeInt;
    ExecutionLevelNodes:TpvSceneNodes;
begin
 ExecutionLevelNodes:=aData;
 for ExecutionLevelNodeIndex:=aFromIndex to aToIndex do begin
  ExecutionLevelNodes.RawItems[ExecutionLevelNodeIndex].UpdateAudio;
 end;
end;

procedure TpvScene.UpdateAudio;
var ExecutionLevelIndex,ExecutionLevelNodeIndex:TpvSizeInt;
    ExecutionLevelNodes:TpvSceneNodes;
begin
 if fUseDirectedAcyclicGraph then begin
  RebuildDirectedAcyclicGraph;
  for ExecutionLevelIndex:=0 to fDirectedAcyclicGraph.fExecutionLevels.Count-1 do begin
   ExecutionLevelNodes:=fDirectedAcyclicGraph.fExecutionLevels.RawItems[ExecutionLevelIndex];
   if ExecutionLevelNodes.Count>0 then begin
    if ExecutionLevelNodes.Count>1 then begin
     if assigned(fPasMPInstance) and (TpvScene.TStage.UpdateAudio in fParallelStages) then begin
      fPasMPInstance.Invoke(
       fPasMPInstance.ParallelFor(
        ExecutionLevelNodes,
        0,
        ExecutionLevelNodes.Count-1,
        UpdateAudioParallelForJob,
        -4,
        PasMPDefaultDepth,
        nil,
        0,
        PasMPAreaMaskUpdate,
        PasMPAreaMaskRender or PasMPAreaMaskBackgroundLoading,        
        false,
        PasMPAffinityMaskUpdateAllowMask,
        PasMPAffinityMaskUpdateAvoidMask
       )
      );
     end else begin
      for ExecutionLevelNodeIndex:=0 to ExecutionLevelNodes.Count-1 do begin
       ExecutionLevelNodes.RawItems[ExecutionLevelNodeIndex].UpdateAudio;
      end;
     end;
    end else begin
     ExecutionLevelNodes[0].UpdateAudio;
    end;
   end;
  end;
 end else begin
  fRootNode.UpdateAudio;
 end;
end;

procedure TpvScene.DumpTimes;
var ExecutionLevelIndex,ExecutionLevelNodeIndex:TpvSizeInt;
    ExecutionLevelNodes:TpvSceneNodes;
begin
 WriteLn('Scene Node Times Dump:');
 if fUseDirectedAcyclicGraph then begin
  RebuildDirectedAcyclicGraph;
  for ExecutionLevelIndex:=0 to fDirectedAcyclicGraph.fExecutionLevels.Count-1 do begin
   ExecutionLevelNodes:=fDirectedAcyclicGraph.fExecutionLevels.RawItems[ExecutionLevelIndex];
   for ExecutionLevelNodeIndex:=0 to ExecutionLevelNodes.Count-1 do begin
    ExecutionLevelNodes.RawItems[ExecutionLevelNodeIndex].DumpTimes;
   end;
  end;
 end else begin
  fRootNode.DumpTimes;
 end;
 WriteLn;
end;

function TpvScene.Serialize:TObject;
begin
 result:=nil;
end;

procedure TpvScene.Deserialize(const aData:TObject);
begin
end;

{ TpvSceneNode3D }

constructor TpvSceneNode3D.Create(const aParent:TpvSceneNode;const aData:TObject=nil);
var LastNode3D:TpvSceneNode; 
begin

 inherited Create(aParent,aData);

 LastNode3D:=fParent;
 while assigned(LastNode3D) and not (LastNode3D is TpvSceneNode3D) do begin
  LastNode3D:=LastNode3D.fParent;
 end;
 if not (assigned(LastNode3D) and (LastNode3D is TpvSceneNode3D)) then begin
  LastNode3D:=nil; // No parent TpvSceneNode3D found
 end;

 fLastNode3DParent:=TpvSceneNode3D(LastNode3D);

 fTransform:=TpvMatrix4x4.Identity;

 fCachedWorldTransform:=TpvMatrix4x4.Identity;

end;

destructor TpvSceneNode3D.Destroy;
begin
 inherited Destroy;
end;

procedure TpvSceneNode3D.UpdateCachedWorldTransform;
begin
 if assigned(fLastNode3DParent) then begin
  fCachedWorldTransform:=fLastNode3DParent.fCachedWorldTransform*fTransform;
 end else begin
  fCachedWorldTransform:=fTransform;
 end;
end;

procedure TpvSceneNode3D.RecursiveUpdateCachedWorldTransform;
var Index:TpvSizeInt;
    Node:TpvSceneNode;
begin
 UpdateCachedWorldTransform;
 for Index:=0 to fChildren.Count-1 do begin
  Node:=fChildren[Index];
  if Node is TpvSceneNode3D then begin
   TpvSceneNode3D(Node).RecursiveUpdateCachedWorldTransform;
  end;
 end;
end;

procedure TpvSceneNode3D.SetTransform(const aValue:TpvMatrix4x4D);
begin
 fTransform:=aValue;
 RecursiveUpdateCachedWorldTransform;
end;

function TpvSceneNode3D.GetWorldTransform:TpvMatrix4x4D;
begin
 if assigned(fLastNode3DParent) then begin
  result:=fLastNode3DParent.GetWorldTransform*fTransform;
 end else begin
  result:=fTransform;
 end;
end;

procedure TpvSceneNode3D.SetWorldTransform(const aWorldTransform:TpvMatrix4x4D);
begin
 if assigned(fLastNode3DParent) then begin
  fTransform:=fLastNode3DParent.GetWorldTransform.Inverse*aWorldTransform;
 end else begin
  fTransform:=aWorldTransform;
 end;
 RecursiveUpdateCachedWorldTransform;
end;

procedure TpvSceneNode3D.UpdateBounds;
begin
end;

procedure TpvSceneNode3D.Store;
begin
 inherited Store;
 fLastCachedWorldTransform:=fCachedWorldTransform;
end;

procedure TpvSceneNode3D.BeginUpdate(const aDeltaTime:TpvDouble);
begin
 inherited BeginUpdate(aDeltaTime);
end;

procedure TpvSceneNode3D.Update(const aDeltaTime:TpvDouble);
begin
 inherited Update(aDeltaTime);
end;

procedure TpvSceneNode3D.EndUpdate(const aDeltaTime:TpvDouble);
begin
 inherited EndUpdate(aDeltaTime);
end;

procedure TpvSceneNode3D.Interpolate(const aAlpha:TpvDouble);
begin
 fInterpolatedCachedWorldTransform:=fLastCachedWorldTransform.Slerp(fCachedWorldTransform,aAlpha);
 inherited Interpolate(aAlpha);
end;

end.
