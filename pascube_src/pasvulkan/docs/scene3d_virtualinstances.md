# PasVulkan Scene3D Virtual Instance System

## Overview

The Virtual Instance System provides automatic, intelligent management of Scene3D rendering resources through a sophisticated assignment algorithm. It eliminates manual resource management by automatically sharing GPU resources across similar instances while maintaining high rendering performance.

### Key Features

- **Automatic Resource Sharing**: Virtual instances automatically assigned to non-virtual instances based on similarity
- **GPU Instancing**: Multiple similar virtual instances share GPU resources via hardware instancing
- **Temporal Coherence**: Frame-to-frame stability prevents flickering/popping
- **Frustum Culling Integration**: Only visible instances participate in assignment
- **Zero Configuration**: Works out-of-the-box with sensible defaults
- **Thread-Safe**: All operations protected by locks

## Architecture

### Three-Tier Instance Hierarchy

```
TGroup (Model Definition)
  └─ TVirtualInstanceManager (Assignment Engine)
       ├─ Non-Virtual Instances (GPU Resource Pool)
       │    ├─ Non-Virtual Instance #1 [Active/Inactive]
       │    │    └─ Preallocated Render Instances (Hardware Instancing Pool)
       │    │         ├─ Render Instance #1 [Active/Inactive]
       │    │         ├─ Render Instance #2 [Active/Inactive]
       │    │         └─ Render Instance #N [Active/Inactive]
       │    ├─ Non-Virtual Instance #2
       │    └─ Non-Virtual Instance #N
       └─ Virtual Instances (Lightweight User Objects)
            ├─ Virtual Instance #1 → Assigned to Non-Virtual #1
            ├─ Virtual Instance #2 → Assigned to Non-Virtual #1 (via render instance)
            └─ Virtual Instance #N → Unassigned (culled or no capacity)
```

### Instance Types

#### 1. Virtual Instances (User Creates)
- **Lightweight** (~few hundred bytes)
- Created by application: `Group.CreateInstance(Virtual:=true)`
- Contains: Transform, animation state, scene index
- **Automatically registered** with manager on creation
- **Automatically unregistered** on destruction

#### 2. Non-Virtual Instances (Manager Owns)
- **Heavy GPU resources** (vertex buffers, joint matrices, etc.)
- Created by manager in fixed pool
- Never freed during gameplay, only recycled
- Can be activated/deactivated as needed
- Each can optionally have a render instance pool

#### 3. Render Instances (Hardware Instancing)
- Used when multiple similar instances share one non-virtual
- Preallocated per non-virtual instance
- Contains: Per-instance matrix, bounds
- Enables GPU hardware instancing

## Assignment Algorithm

### Two-Step Greedy Assignment

The manager runs a sophisticated assignment algorithm each frame via `UpdateAssignments()`:

#### Step 1: Primary Assignment (Dissimilar Preference)
```pascal
for each Non-Virtual Instance do
  Find best DISSIMILAR virtual instance
  Assign virtual → non-virtual
  Copy state (matrix, animation, etc.)
  Activate non-virtual instance
end
```

**Goal**: Maximize diversity - each non-virtual gets a different animation state

#### Step 2: Instancing Assignment (Similar Preference)  
```pascal
for each remaining Virtual Instance do
  Find best SIMILAR non-virtual instance (already active)
  Assign virtual → non-virtual's render instance pool
  Share GPU resources via hardware instancing
end
```

**Goal**: Pack similar instances together for efficient instancing

### Similarity Scoring

The default heuristic (`DefaultAssignmentHeuristic`) computes a score based on:

1. **Animation State Similarity** (±10.0)
   - Compares animation times, blend factors
   - Higher score = more similar states

2. **Distance to Camera** (-0.001 per unit)
   - Closer objects get slightly higher priority
   - Minimal impact on final score

3. **Temporal Coherence Bonus** (+5.0)
   - If assigned to same non-virtual as last frame
   - Prevents flickering

4. **Switching Penalty** (-1.0)
   - If previously assigned to different non-virtual
   - Encourages stability

**Score Formula (Step 1 - Dissimilar):**
```pascal
Score = (-Similarity × 10.0) - (Distance × 0.001) + Temporal Bonus/Penalty
```

**Score Formula (Step 2 - Similar):**
```pascal
Score = (Similarity × 10.0) - (Distance × 0.001) + Temporal Bonus/Penalty
```

### State Similarity Computation

```pascal
function ComputeStateSimilarity(const aInstanceA,aInstanceB:TInstance):TpvDouble;
var Index:TpvSizeInt;
    Similarity,TimeDifference:TpvDouble;
begin
 result:=0.0;
 
 // Scene must match
 if aInstanceA.Scene<>aInstanceB.Scene then begin
  exit;
 end;
 
 Similarity:=1.0;
 
 // Animation state comparison
 if aInstanceA.UseAnimationStates and aInstanceB.UseAnimationStates and
    (length(aInstanceA.AnimationStates)=length(aInstanceB.AnimationStates)) then begin
  for Index:=0 to length(aInstanceA.AnimationStates)-1 do begin
   // Time similarity (within 1 second = similar)
   TimeDifference:=abs(aInstanceA.AnimationStates[Index].Time-aInstanceB.AnimationStates[Index].Time);
   Similarity:=Similarity*(1.0/(1.0+TimeDifference));
   
   // Blend factor similarity
   Similarity:=Similarity*(1.0-abs(aInstanceA.AnimationStates[Index].Factor-aInstanceB.AnimationStates[Index].Factor));
  end;
 end;
 
 // Per-animation similarity
 if (length(aInstanceA.Animations)>0) and (length(aInstanceA.Animations)=length(aInstanceB.Animations)) then begin
  for Index:=0 to length(aInstanceA.Animations)-1 do begin
   Similarity:=Similarity*aInstanceA.Animations[Index].GetSimilarityTo(aInstanceB.Animations[Index]);
  end;
 end;
 
 result:=Similarity; // 0.0 (dissimilar) to 1.0 (identical)
end;
```

## Basic Usage

### 1. Initialize Manager (One-Time Setup)

```pascal
var Group:TpvScene3D.TGroup;
    Manager:TpvScene3D.TGroup.TVirtualInstanceManager;
begin
 // Load model
 Group:=LoadModelFromGLTF('models/character.gltf');
 
 // Create manager with capacity
 Manager:=Group.GetOrCreateVirtualInstanceManager(50,100);
 // Parameters: MaxNonVirtualInstances=50, MaxRenderInstancesPerNonVirtual=100
end;
```

**Parameters:**
- `MaximumNonVirtualInstances`: How many different animation states you expect simultaneously
- `MaximumRenderInstancesPerNonVirtualInstance`: How many similar objects can share GPU resources

**Rule of Thumb:**
- Non-virtuals ≈ unique animations visible at once (e.g., 20-100)
- Render instances ≈ max crowd density (e.g., 50-200)

### 2. Create Virtual Instances

```pascal
var Character:TGameCharacter;
    VirtualInstance:TpvScene3D.TGroup.TInstance;
begin
 // Create virtual instance
 VirtualInstance:=Group.CreateInstance(false,true); // Headless=false, Virtual=true
 
 // Set properties
 VirtualInstance.ModelMatrix:=CharacterTransform;
 VirtualInstance.Scene:=0;  // Scene index
 VirtualInstance.Active:=true;  // Participate in culling/assignment
 
 // Setup animations
 VirtualInstance.Animations[0].Time:=1.5;
 VirtualInstance.Animations[0].Factor:=1.0;
 
 Character.VirtualInstance:=VirtualInstance;
end;
```

**Automatic Registration**: Virtual instances automatically register with the manager in `AfterConstruction`.

### 3. Update Loop

```pascal
procedure TGame.Update(const aDeltaTime:TpvDouble);
var Character:TGameCharacter;
begin
 // Update all virtual instances (transforms, animations)
 for Character in fCharacters do begin
  Character.Update(aDeltaTime);
  Character.VirtualInstance.ModelMatrix:=Character.Transform;
 end;
 
 // Manager automatically handles assignment during rendering
 // No manual intervention needed!
end;
```

### 4. Trigger Assignment (Automatic)

Assignment happens automatically during rendering:

```pascal
// In Scene3D.Prepare or similar rendering code
Manager.UpdateAssignments(InFlightFrameIndex);
```

You don't need to call this manually - the engine handles it!

### 5. Cleanup (Automatic)

```pascal
// When character is destroyed:
VirtualInstance.Free;  // Automatically unregisters from manager
```

## Advanced Features

### Custom Assignment Heuristic

Override the default assignment logic:

```pascal
function TMyGame.CustomAssignmentHeuristic(const aInstance:TInstance;
                                           const aTargetInstance:TInstance;
                                           const aCandidates:TInstances;
                                           const aInFlightFrameIndex:TpvSizeInt;
                                           const aCameraPosition:PpvVector3D;
                                           const aPreferDissimilar:Boolean;
                                           out aInstanceIndex:TpvSizeInt):TInstance;
begin
 // Your custom logic here
 // Must return best candidate from aCandidates
 result:=nil;
end;

// Set custom callback
Manager.CustomAssignmentCallback:=CustomAssignmentHeuristic;
```

### Debug Visualization

Enable debug mode to track assignments:

```pascal
var DebugInfoIndex:TpvSizeInt;
    DebugInfo:TpvScene3D.TGroup.TVirtualInstanceManager.TAssignmentDebugInfo;
begin
 Manager.DebugEnabled:=true;

 // After UpdateAssignments:
 for DebugInfoIndex:=0 to Manager.CountDebugInfos-1 do begin
  DebugInfo:=Manager.DebugInfos[DebugInfoIndex];
  
  writeln('Virtual: ',TpvPtrUInt(DebugInfo.VirtualInstance));
  writeln('→ NonVirtual: ',TpvPtrUInt(DebugInfo.AssignedNonVirtualInstance));
  writeln('Distance: ',DebugInfo.Distance:0:2);
  writeln('Priority: ',DebugInfo.Priority:0:2);
  writeln('StateHash: ',DebugInfo.StateHash);
 end;
end;
```

### Animation State Structure

Virtual instances track animation state automatically:

```pascal
// Animation state per virtual instance
VirtualInstance.Animations[0].Time:=AnimTime;
VirtualInstance.Animations[0].Factor:=BlendWeight;
VirtualInstance.Animations[0].Additive:=false;
VirtualInstance.Animations[0].Complete:=true;

// Manager compares these for similarity scoring
```

## Game Integration Example

### Character Class

```pascal
type TGameCharacter=class
      private
       fGroup:TpvScene3D.TGroup;
       fVirtualInstance:TpvScene3D.TGroup.TInstance;
       fAnimationTime:TpvDouble;
       fAnimationState:TAnimationState;
      public
       constructor Create(const aGroup:TpvScene3D.TGroup);
       destructor Destroy; override;
       procedure Update(const aDeltaTime:TpvDouble);
     end;

constructor TGameCharacter.Create(const aGroup:TpvScene3D.TGroup);
begin
 inherited Create;
 fGroup:=aGroup;
 
 // Create virtual instance
 fVirtualInstance:=fGroup.CreateInstance(false,true); // Headless=false, Virtual=true
 
 fVirtualInstance.Active:=true;
 fVirtualInstance.Scene:=0;
 fAnimationTime:=0.0;
end;

destructor TGameCharacter.Destroy;
begin
 // Automatically unregisters from manager
 fVirtualInstance.Free;
 inherited Destroy;
end;

procedure TGameCharacter.Update(const aDeltaTime:TpvDouble);
begin
 // Update animation
 fAnimationTime:=fAnimationTime+aDeltaTime;
 
 // Update virtual instance
 fVirtualInstance.Animations[0].Time:=fAnimationTime;
 fVirtualInstance.Animations[0].Factor:=fAnimationState.BlendWeight;
 fVirtualInstance.ModelMatrix:=GetWorldTransform;
 
 // Manager automatically handles rest!
end;
```

### Game Loop

```pascal
procedure TGame.Initialize;
var CharacterIndex:TpvSizeInt;
begin
 // Load character model
 fCharacterGroup:=Scene3D.LoadGroup('character.gltf');
 
 // Initialize manager
 fCharacterGroup.GetOrCreateVirtualInstanceManager(50,100);
 
 // Spawn characters
 for CharacterIndex:=0 to 99 do begin
  fCharacters.Add(TGameCharacter.Create(fCharacterGroup));
 end;
end;

procedure TGame.Update;
var Character:TGameCharacter;
begin
 for Character in fCharacters do begin
  Character.Update(DeltaTime);
 end;
 
 // Assignment happens automatically during rendering
end;
```

## Performance Characteristics

### Memory Usage

**Per Virtual Instance**: ~200-500 bytes
- Transform matrix (64 bytes)
- Animation state (~100 bytes)
- Bookkeeping (~100 bytes)

**Per Non-Virtual Instance**: ~5-50 MB (model dependent)
- Animated vertex buffer
- Joint matrices
- Render instance pool

**Total Example** (100 characters, 10 unique animations):
- 100 virtual instances: ~50 KB
- 10 non-virtual instances: ~50-500 MB
- Render instances: ~10-50 KB

### CPU Performance

**UpdateAssignments Complexity**:
- O(N × M) where N = non-virtuals, M = virtual instances
- Typical: O(50 × 100) = 5,000 comparisons
- With optimizations: <1ms on modern CPUs

**Per-Frame Cost**:
- Frustum culling: ~0.1ms (100 instances)
- Assignment: ~0.5ms (100 virtuals, 50 non-virtuals)
- State update: ~0.2ms
- **Total**: <1ms

### GPU Performance

**Instancing Benefits**:
- Draw calls: N (non-virtuals) instead of M (total objects)
- Example: 100 characters → 10 draw calls (10x reduction)
- Batch size: Up to 100 instances per draw call

**Memory Transfers**:
- Only active non-virtual GPU buffers uploaded
- Render instance matrices uploaded per-frame (~1KB each)

## Migration Guide

### From Manual Management

**Before:**
```pascal
// Manual creation
Instance1:=Group.CreateInstance(false,false); // Virtual=false
Instance1.Animations[0].Time:=1.0;

Instance2:=Group.CreateInstance(false,false); // Virtual=false
Instance2.Animations[0].Time:=1.0;  // Duplicate GPU resources!
```

**After:**
```pascal
// Initialize manager once
Group.GetOrCreateVirtualInstanceManager(50,100);

// Create virtual instances
Virtual1:=Group.CreateInstance(false,true); // Virtual=true
Virtual1.Animations[0].Time:=1.0;

Virtual2:=Group.CreateInstance(false,true); // Virtual=true
Virtual2.Animations[0].Time:=1.0;  // Shares GPU resources automatically!
```

### From Old DynamicGroupManager

The old system required manual `AcquireInstance` / `ReleaseInstance` calls and explicit state keys. The new system:

- ✅ No manual acquire/release
- ✅ No state key management
- ✅ Automatic registration on creation
- ✅ Automatic unregistration on destruction
- ✅ Animation state extracted automatically
- ✅ Temporal coherence built-in

## Implementation Details

### Automatic Registration

Virtual instances register automatically in `TInstance.AfterConstruction`:

```pascal
procedure TInstance.AfterConstruction;
begin
 if fVirtual and assigned(fGroup.fVirtualInstanceManager) then begin
  fGroup.fVirtualInstanceManager.fVirtualInstances.Add(self);
 end;
end;
```

### Automatic Unregistration

Virtual instances unregister in `TInstance.Remove`:

```pascal
procedure TInstance.Remove;
begin
 if fVirtual and assigned(fVirtualInstanceManager) then begin
  fVirtualInstanceManager.fVirtualInstances.Remove(self);
 end;
end;
```

### Assignment State Tracking

Each virtual instance tracks its assignment:

```pascal
type TInstance=class
      fAssignedNonVirtualInstance:TInstance;  // Current assignment
      fPreviousAssignedNonVirtualInstance:TInstance;  // Last frame (for temporal coherence)
     end;
```

### Thread Safety

All public methods protected by `TPasMPSpinLock`:

```pascal
procedure UpdateAssignments(const aInFlightFrameIndex:TpvSizeInt);
begin
 fLock.Acquire;
 try
  // Assignment logic
 finally
  fLock.Release;
 end;
end;
```

## Best Practices

### 1. ⚠️ CRITICAL: Dependencies and Update Order Safety

**Problem: Virtual Instance Properties Not in DAG Dependency Tracking**

The `TInstance.Update` DAG system handles dependency ordering for regular instances (parent updates before child). Virtual instances **are part of the DAG**, but they're treated like non-virtual instances - the DAG system doesn't know about the **virtual-to-non-virtual assignment relationship**.

**The Issue:**
- Non-virtual instance A gets updated by DAG
- Non-virtual instance A has virtual instances B and C assigned to it
- Virtual instances B and C will update **later** in unpredictable order
- If B or C have dependencies on each other, ordering is wrong!

**When MaxRenderInstanceCount = 0 (Direct Assignment):**
```
❌ UNSAFE for virtual instances with dependencies/appendages!

Non-Virtual Instance X (updates first - via DAG)
├─ Virtual Instance A assigned → updates X.ModelMatrix (happens later, unpredictable order)
└─ Virtual Instance B assigned → updates X.ModelMatrix (happens later, unpredictable order)

Problem: If Virtual B depends on Virtual A (parent-child), but B updates before A:
- B reads stale/incorrect transform from A
- B writes incorrect ModelMatrix to Non-Virtual X
- Result: Incorrect positioning, visual glitches, race conditions
```

**When MaxRenderInstanceCount > 0 (Render Instance Assignment):**
```
✅ SAFE for virtual instances with dependencies/appendages!

Non-Virtual Instance X (updates first - via DAG)
├─ Virtual Instance A → Render Instance X[0] (writes own slot)
└─ Virtual Instance B → Render Instance X[1] (writes own slot)

Each virtual gets independent render instance slot
No race condition - separate memory locations
Virtual A updates Render Instance X[0].ModelMatrix
Virtual B updates Render Instance X[1].ModelMatrix
Parent-child computation happens in each virtual's own Update (before writing)
Unpredictable update order doesn't matter - isolated writes
```

**Best Practice:**
- **Simple standalone objects** (trees, rocks, NPCs without attachments): `MaxRenderInstanceCount = 0` OK
- **Objects with dependencies/appendages** (characters with weapons, vehicles with parts): `MaxRenderInstanceCount > 0` REQUIRED
- **Default recommendation**: Always use `MaxRenderInstanceCount > 0` unless you're certain instances are independent

**Why Render Instances Are Safe:**
1. Each virtual instance writes to its own render instance slot
2. No shared ModelMatrix between dependent virtuals
3. Transform hierarchy resolved during virtual's Update (before writing to render instance)
4. Unpredictable update order doesn't matter - isolated writes

**Example:**
```pascal
// Character with attached weapon (dependency)
CharacterGroup.GetOrCreateVirtualInstanceManager(
 50,   // Non-virtual instances
 100   // ✅ Render instances > 0 for safety!
);

// Simple trees (no dependencies)
TreeGroup.GetOrCreateVirtualInstanceManager(
 20,   // Non-virtual instances  
 0     // ✅ Can use 0 - trees are independent
);
```

### 2. Right-Size Your Pools

```pascal
var Manager:TpvScene3D.TGroup.TVirtualInstanceManager;
begin
 // Too small: Will run out of capacity
 Manager:=Group.GetOrCreateVirtualInstanceManager(5,10);  // ❌ Only 5 animations

 // Too large: Wastes GPU memory  
 Manager:=Group.GetOrCreateVirtualInstanceManager(1000,1000);  // ❌ Huge waste

 // Just right: Covers peak usage with headroom
 Manager:=Group.GetOrCreateVirtualInstanceManager(50,100);  // ✅ Perfect
end;
```

### 3. Keep Virtual Instances Active

```pascal
// Only set Active=true for instances that should render
VirtualInstance.Active:=IsInWorld and IsVisible;

// Inactive instances don't participate in assignment
// (Saves CPU in UpdateAssignments)
```

### 4. Minimize State Changes

```pascal
// Good: Smooth animation
Animations[0].Time:=Animations[0].Time+DeltaTime;  // ✅ Continuous, stays similar

// Bad: Random jumps
Animations[0].Time:=Random*10.0;  // ❌ Breaks similarity, causes reassignment
```

### 5. Use Scene Indices

```pascal
// Separate by scene/level
VirtualInstance.Scene:=CurrentLevelIndex;

// Manager only matches instances with same scene
```

### 6. Profile Your Assignment Cost

```pascal
var StartTime,AssignmentTime:TpvDouble;
begin
 StartTime:=GetTickCount;
 Manager.UpdateAssignments(FrameIndex);
 AssignmentTime:=GetTickCount-StartTime;

 if AssignmentTime>2.0 then begin
  writeln('WARNING: Assignment taking too long!');
 end;
end;
```

## Troubleshooting

### Problem: Objects Not Rendering

**Cause**: Virtual instance not assigned

**Check**:
```pascal
begin
 if not Manager.IsVirtualInstanceAssigned(VirtualInstance) then begin
  writeln('Not assigned! Check pool capacity');
 end;
end;
```

**Solution**: Increase `MaximumNonVirtualInstances`

### Problem: Flickering Between Frames

**Cause**: Poor temporal coherence (too much reassignment)

**Check**: Enable debug mode, watch `Priority` values

**Solution**: 
- Increase temporal bonus in custom heuristic
- Reduce animation state granularity
- Check for state "thrashing"

### Problem: Low FPS Despite Instancing

**Cause**: Too many unique animation states (defeats instancing)

**Check**: Count active non-virtual instances

**Solution**:
- Quantize animation times (round to 0.1s)
- Reduce animation blend precision
- Use fewer unique animations

### Problem: Memory Usage Too High

**Cause**: Too many non-virtual instances allocated

**Check**: `MaximumNonVirtualInstances` parameter

**Solution**: Reduce pool size to what's actually needed

## Technical Notes

### Why Virtual Instances?

Traditional approach: Each game object owns a heavy `TInstance`
- 100 objects = 100 × 50MB = 5 GB GPU memory
- Each with duplicate GPU buffers
- No sharing possible

Virtual instance approach: Game objects own lightweight virtual instances
- 100 virtual instances = 100 × 500 bytes = 50 KB
- Manager shares 10 non-virtual instances = 10 × 50MB = 500 MB
- **10x memory reduction!**

### GPU Instancing Details

When multiple virtual instances share a non-virtual:

1. Non-virtual uploads animated vertices once
2. Each virtual's render instance uploads just a matrix (~64 bytes)
3. GPU hardware instancing duplicates geometry
4. One draw call renders all similar instances

This is why render instance pool size matters - it's the max batch size for instancing.

### State Similarity Philosophy

The system treats animation as **continuous state space**:
- Similar times → similar poses → can share GPU vertex buffer
- Dissimilar times → different poses → need separate buffers

This is why smooth animations work best - neighboring frames share resources naturally.

## Summary

The Virtual Instance System provides:

✅ **Automatic** resource management - no manual acquire/release  
✅ **Efficient** GPU memory usage - sharing via similarity  
✅ **Scalable** to hundreds of instances - O(N×M) assignment  
✅ **Stable** frame-to-frame - temporal coherence built-in  
✅ **Flexible** - custom heuristics for special cases  
✅ **Thread-safe** - concurrent updates supported  

Perfect for games with many animated characters/objects like crowd simulations, RTS units, or MMO players!
