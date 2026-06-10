unit UnitBenchmarkPhysics;
{$ifdef fpc}
 {$mode delphi}
{$endif}

interface

uses SysUtils,
     Classes,
     Math,
     PasVulkan.Types,
     PasVulkan.Math;

const
  MAX_BODIES = 512;
  GRAVITY = -9.8;
  GROUND_Y = -3.0;
  RESTITUTION = 0.6;
  FRICTION = 0.3;
  DAMPING = 0.995;

type
  PCubeBody = ^TCubeBody;
  TCubeBody = record
   Position: TpvVector3;
   Velocity: TpvVector3;
   Scale: TpvFloat;
   Color: TpvVector3;
   Active: Boolean;
   Rotation: TpvVector3; // euler angles
   RotVelocity: TpvVector3;
  end;

  TAABB = record
   MinCoords: TpvVector3;
   MaxCoords: TpvVector3;
  end;

  TPhysicsWorld = class
   private
    fBodies: array[0..MAX_BODIES-1] of TCubeBody;
    fBodyCount: Integer;
    fCollisionChecks: Int64;
    fContactSolves: Int64;
   public
    constructor Create;
    procedure Clear;
    function SpawnBody(const aPos: TpvVector3; const aScale: TpvFloat; const aColor: TpvVector3): Integer;
    procedure RemoveBody(const aIndex: Integer);
    procedure Step(const aDeltaTime: TpvFloat);
    function GetBody(const aIndex: Integer): PCubeBody;
    property BodyCount: Integer read fBodyCount;
    property CollisionChecks: Int64 read fCollisionChecks;
    property ContactSolves: Int64 read fContactSolves;
    procedure ResetCounters;
  end;

implementation

constructor TPhysicsWorld.Create;
begin
 inherited Create;
 fBodyCount := 0;
 fCollisionChecks := 0;
 fContactSolves := 0;
end;

procedure TPhysicsWorld.Clear;
begin
 fBodyCount := 0;
 fCollisionChecks := 0;
 fContactSolves := 0;
end;

function TPhysicsWorld.SpawnBody(const aPos: TpvVector3; const aScale: TpvFloat; const aColor: TpvVector3): Integer;
var i: Integer;
begin
 Result := -1;
 // Try to reuse inactive slot
 for i := 0 to fBodyCount - 1 do begin
  if not fBodies[i].Active then begin
   fBodies[i].Position := aPos;
   fBodies[i].Velocity := TpvVector3.Create(0,0,0);
   fBodies[i].Scale := aScale;
   fBodies[i].Color := aColor;
   fBodies[i].Active := true;
   fBodies[i].Rotation := TpvVector3.Create(0,0,0);
   fBodies[i].RotVelocity := TpvVector3.Create(0,0,0);
   Result := i;
   Exit;
  end;
 end;
 // Add new
 if fBodyCount < MAX_BODIES then begin
  fBodies[fBodyCount].Position := aPos;
  fBodies[fBodyCount].Velocity := TpvVector3.Create(0,0,0);
  fBodies[fBodyCount].Scale := aScale;
  fBodies[fBodyCount].Color := aColor;
  fBodies[fBodyCount].Active := true;
  fBodies[fBodyCount].Rotation := TpvVector3.Create(0,0,0);
  fBodies[fBodyCount].RotVelocity := TpvVector3.Create(0,0,0);
  Result := fBodyCount;
  Inc(fBodyCount);
 end;
end;

procedure TPhysicsWorld.RemoveBody(const aIndex: Integer);
begin
 if (aIndex >= 0) and (aIndex < fBodyCount) then begin
  fBodies[aIndex].Active := false;
 end;
end;

procedure TPhysicsWorld.Step(const aDeltaTime: TpvFloat);
var i, j: Integer;
    bodyA, bodyB: PCubeBody;
    overlapX, overlapY, overlapZ, minOverlap: TpvFloat;
    normal: TpvVector3;
    relVel: TpvFloat;
    impulse: TpvFloat;
    dt: TpvFloat;
    AABBs: array[0..MAX_BODIES-1] of TAABB;
    SortedIndices: array[0..MAX_BODIES-1] of Integer;
    ActiveCount, h, tmpIdx, idxA, idxB: Integer;
begin
 dt := Min(aDeltaTime, 0.05); // clamp dt to avoid explosion

 // Integrate
 for i := 0 to fBodyCount - 1 do begin
  bodyA := @fBodies[i];
  if not bodyA^.Active then Continue;

  // Gravity
  bodyA^.Velocity.y := bodyA^.Velocity.y + GRAVITY * dt;

  // Damping
  bodyA^.Velocity := bodyA^.Velocity * DAMPING;
  bodyA^.RotVelocity := bodyA^.RotVelocity * DAMPING;

  // Integrate position
  bodyA^.Position := bodyA^.Position + bodyA^.Velocity * dt;
  bodyA^.Rotation := bodyA^.Rotation + bodyA^.RotVelocity * dt;

  // Ground collision
  if bodyA^.Position.y - bodyA^.Scale < GROUND_Y then begin
   bodyA^.Position.y := GROUND_Y + bodyA^.Scale;
   bodyA^.Velocity.y := -bodyA^.Velocity.y * RESTITUTION;
   bodyA^.Velocity.x := bodyA^.Velocity.x * (1.0 - FRICTION * dt);
   bodyA^.Velocity.z := bodyA^.Velocity.z * (1.0 - FRICTION * dt);
  end;

  // Respawn if fell too far
  if bodyA^.Position.y < -8.0 then begin
   bodyA^.Position.y := 5.0 + Random * 3.0;
   bodyA^.Position.x := (Random - 0.5) * 6.0;
   bodyA^.Position.z := (Random - 0.5) * 6.0;
   bodyA^.Velocity := TpvVector3.Create(0,0,0);
  end;
 end;

 // Precompute AABBs to avoid allocations
 ActiveCount := 0;
 for i := 0 to fBodyCount - 1 do begin
  if fBodies[i].Active then begin
   AABBs[i].MinCoords := TpvVector3.Create(
    fBodies[i].Position.x - fBodies[i].Scale,
    fBodies[i].Position.y - fBodies[i].Scale,
    fBodies[i].Position.z - fBodies[i].Scale
   );
   AABBs[i].MaxCoords := TpvVector3.Create(
    fBodies[i].Position.x + fBodies[i].Scale,
    fBodies[i].Position.y + fBodies[i].Scale,
    fBodies[i].Position.z + fBodies[i].Scale
   );
   SortedIndices[ActiveCount] := i;
   Inc(ActiveCount);
  end;
 end;

 // Shellsort to sort SortedIndices by AABBs[index].MinCoords.x (ascending)
 h := 1;
 while h < ActiveCount div 3 do
  h := 3 * h + 1;
 while h >= 1 do begin
  for i := h to ActiveCount - 1 do begin
   j := i;
   tmpIdx := SortedIndices[j];
   while (j >= h) and (AABBs[SortedIndices[j - h]].MinCoords.x > AABBs[tmpIdx].MinCoords.x) do begin
    SortedIndices[j] := SortedIndices[j - h];
    j := j - h;
   end;
   SortedIndices[j] := tmpIdx;
  end;
  h := h div 3;
 end;

 // Sweep and Prune
 for i := 0 to ActiveCount - 1 do begin
  idxA := SortedIndices[i];
  bodyA := @fBodies[idxA];
  for j := i + 1 to ActiveCount - 1 do begin
   idxB := SortedIndices[j];

   // Since SortedIndices is sorted by MinCoords.x, if MinCoords.x of B > MaxCoords.x of A,
   // then no subsequent body can possibly overlap with body A on X-axis.
   if AABBs[idxB].MinCoords.x > AABBs[idxA].MaxCoords.x then
    Break;

   bodyB := @fBodies[idxB];

   Inc(fCollisionChecks);

   // Check overlap on Y and Z, and also full overlap check on X
   if (AABBs[idxA].MaxCoords.y > AABBs[idxB].MinCoords.y) and (AABBs[idxA].MinCoords.y < AABBs[idxB].MaxCoords.y) and
      (AABBs[idxA].MaxCoords.z > AABBs[idxB].MinCoords.z) and (AABBs[idxA].MinCoords.z < AABBs[idxB].MaxCoords.z) and
      (AABBs[idxA].MaxCoords.x > AABBs[idxB].MinCoords.x) then begin

    Inc(fContactSolves);

    // Find minimum overlap axis
    overlapX := Min(AABBs[idxA].MaxCoords.x - AABBs[idxB].MinCoords.x, AABBs[idxB].MaxCoords.x - AABBs[idxA].MinCoords.x);
    overlapY := Min(AABBs[idxA].MaxCoords.y - AABBs[idxB].MinCoords.y, AABBs[idxB].MaxCoords.y - AABBs[idxA].MinCoords.y);
    overlapZ := Min(AABBs[idxA].MaxCoords.z - AABBs[idxB].MinCoords.z, AABBs[idxB].MaxCoords.z - AABBs[idxA].MinCoords.z);

    minOverlap := overlapX;
    normal := TpvVector3.Create(1,0,0);
    if overlapY < minOverlap then begin
     minOverlap := overlapY;
     normal := TpvVector3.Create(0,1,0);
    end;
    if overlapZ < minOverlap then begin
     minOverlap := overlapZ;
     normal := TpvVector3.Create(0,0,1);
    end;

    // Separate bodies
    bodyA^.Position := bodyA^.Position - normal * (minOverlap * 0.5);
    bodyB^.Position := bodyB^.Position + normal * (minOverlap * 0.5);

    // Update cached AABBs for the separated bodies
    AABBs[idxA].MinCoords := TpvVector3.Create(bodyA^.Position.x - bodyA^.Scale, bodyA^.Position.y - bodyA^.Scale, bodyA^.Position.z - bodyA^.Scale);
    AABBs[idxA].MaxCoords := TpvVector3.Create(bodyA^.Position.x + bodyA^.Scale, bodyA^.Position.y + bodyA^.Scale, bodyA^.Position.z + bodyA^.Scale);
    AABBs[idxB].MinCoords := TpvVector3.Create(bodyB^.Position.x - bodyB^.Scale, bodyB^.Position.y - bodyB^.Scale, bodyB^.Position.z - bodyB^.Scale);
    AABBs[idxB].MaxCoords := TpvVector3.Create(bodyB^.Position.x + bodyB^.Scale, bodyB^.Position.y + bodyB^.Scale, bodyB^.Position.z + bodyB^.Scale);

    // Simple impulse response
    relVel := (bodyB^.Velocity - bodyA^.Velocity).Dot(normal);
    if relVel < 0 then begin
     impulse := -(1.0 + RESTITUTION) * relVel * 0.5;
     bodyA^.Velocity := bodyA^.Velocity - normal * impulse;
     bodyB^.Velocity := bodyB^.Velocity + normal * impulse;
    end;

    // Add slight rotation on collision
    bodyA^.RotVelocity := bodyA^.RotVelocity + TpvVector3.Create(
     (Random-0.5)*2.0,
     (Random-0.5)*2.0,
     (Random-0.5)*2.0
    );
    bodyB^.RotVelocity := bodyB^.RotVelocity + TpvVector3.Create(
     (Random-0.5)*2.0,
     (Random-0.5)*2.0,
     (Random-0.5)*2.0
    );
   end;
  end;
 end;
end;

function TPhysicsWorld.GetBody(const aIndex: Integer): PCubeBody;
begin
 if (aIndex >= 0) and (aIndex < fBodyCount) then begin
  Result := @fBodies[aIndex];
 end else begin
  Result := nil;
 end;
end;

procedure TPhysicsWorld.ResetCounters;
begin
 fCollisionChecks := 0;
 fContactSolves := 0;
end;

end.
