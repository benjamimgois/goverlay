unit UnitDemoSceneConstraintVehicle;

{$MODE Delphi}

interface

uses LCLIntf,LCLType,LMessages,Math,Kraft,UnitDemoScene;

type TDemoSceneConstraintVehicle=class(TDemoScene)
      public
       RigidBodyFloor:TKraftRigidBody;
       ShapeFloorPlane:TKraftShapePlane;
       ChassisRigidBody:TKraftRigidBody;
       WheelRigidBodies:array[0..1,0..1] of TKraftRigidBody;
       WheelHingeJointConstraints:array[0..1,0..1] of TKraftConstraintJointHinge;
       CarSteering:double;
       CarSpeed:double;
       Time:double;
       InputKeyLeft,InputKeyRight,InputKeyUp,InputKeyDown,InputKeyBrake,InputKeyHandBrake:boolean;
       constructor Create(const AKraftPhysics:TKraft); override;
       destructor Destroy; override;
       procedure Step(const DeltaTime:double); override;
       procedure DebugDraw; override;
       function HasOwnKeyboardControls:boolean; override;
       procedure KeyDown(const aKey:Int32); override;
       procedure KeyUp(const aKey:Int32); override;
       function UpdateCamera(var aCameraPosition:TKraftVector3;var aCameraOrientation:TKraftQuaternion):boolean; override;
       procedure StoreWorldTransforms; override;
       procedure InterpolateWorldTransforms(const aAlpha:TKraftScalar); override;
     end;

implementation

uses UnitFormMain;

const CarWidth=2.0;
      CarLength=4.0;

      CarHalfWidth=CarWidth*0.5;

      CountDominos=64;

      CountStreetElevations=64;

      CountWheelVertices=128;

      JumpingRampWidth=16.0;
      JumpingRampHeight=16.0;
      JumpingRampLength=64.0;

      JumpingRampHalfWidth=JumpingRampWidth*0.5;
      JumpingRampHalfHeight=JumpingRampHeight*0.5;
      JumpingRampHalfLength=JumpingRampLength*0.5;

      JumpingRampConvexHullPoints:array[0..5] of TKraftVector3=((x:-JumpingRampHalfWidth;y:0.0;z:0{$if KraftSIMD};w:0.0{$ifend}),
                                                                (x:JumpingRampHalfWidth;y:0.0;z:0{$if KraftSIMD};w:0.0{$ifend}),
                                                                (x:-JumpingRampHalfWidth;y:JumpingRampHeight;z:0.0{$if KraftSIMD};w:0.0{$ifend}),
                                                                (x:JumpingRampHalfWidth;y:JumpingRampHeight;z:0.0{$if KraftSIMD};w:0.0{$ifend}),
                                                                (x:-JumpingRampHalfWidth;y:0.0;z:JumpingRampLength{$if KraftSIMD};w:0.0{$ifend}),
                                                                (x:JumpingRampHalfWidth;y:0.0;z:JumpingRampLength{$if KraftSIMD};w:0.0{$ifend}));{}

constructor TDemoSceneConstraintVehicle.Create(const AKraftPhysics:TKraft);
const WheelPositions:array[0..1,0..1] of TKraftVector3=(((x:CarHalfWidth;y:1.25;z:-CarLength{$if KraftSIMD};w:0.0{$ifend}),
                                                         (x:-CarHalfWidth;y:1.25;z:-CarLength{$if KraftSIMD};w:0.0{$ifend})),
                                                        ((x:CarHalfWidth;y:1.25;z:0.0{$if KraftSIMD};w:0.0{$ifend}),
                                                         (x:-CarHalfWidth;y:1.25;z:0.0{$if KraftSIMD};w:0.0{$ifend})));
var Index,x,y:longint;
    Shape:TKraftShape;
    ConvexHull, onvexHull:TKraftConvexHull;
    RigidBody:TKraftRigidBody;
    t,s,c:TKraftScalar;
begin
 inherited Create(AKraftPhysics);

 CarSteering:=0.0;
 Time:=0.0;

 RigidBodyFloor:=TKraftRigidBody.Create(KraftPhysics);
 RigidBodyFloor.SetRigidBodyType(krbtSTATIC);
 ShapeFloorPlane:=TKraftShapePlane.Create(KraftPhysics,RigidBodyFloor,Plane(Vector3Norm(Vector3(0.0,1.0,0.0)),0.0));
 ShapeFloorPlane.Restitution:=0.3;
 RigidBodyFloor.Finish;
 RigidBodyFloor.SetWorldTransformation(Matrix4x4Translate(0.0,0.0,0.0));
 RigidBodyFloor.CollisionGroups:=[0];

 begin
  ConvexHull:=TKraftConvexHull.Create(KraftPhysics);
  ConvexHullGarbageCollector.Add(ConvexHull);
  ConvexHull.Load(pointer(@JumpingRampConvexHullPoints),length(JumpingRampConvexHullPoints));
  ConvexHull.Build;
  ConvexHull.Finish;
  for Index:=1 to 4 do begin
   RigidBody:=TKraftRigidBody.Create(KraftPhysics);
   RigidBody.SetRigidBodyType(krbtSTATIC);
   Shape:=TKraftShapeConvexHull.Create(KraftPhysics,RigidBody,ConvexHull);
   Shape.Restitution:=0.3;
   Shape.Density:=1.0;
   Shape.Friction:=1.0;
   RigidBody.Finish;
   RigidBody.SetWorldTransformation(Matrix4x4Translate(0.0,0.0,-((JumpingRampLength+(CarLength*2.0)))*Index));
   RigidBody.CollisionGroups:=[0];
  end;
  for Index:=1 to 4 do begin
   RigidBody:=TKraftRigidBody.Create(KraftPhysics);
   RigidBody.SetRigidBodyType(krbtSTATIC);
   Shape:=TKraftShapeConvexHull.Create(KraftPhysics,RigidBody,ConvexHull);
   Shape.Restitution:=0.3;
   Shape.Density:=1.0;
   Shape.Friction:=1.0;
   RigidBody.Finish;
   RigidBody.SetWorldTransformation(Matrix4x4TermMul(Matrix4x4RotateY(PI),Matrix4x4Translate(-(JumpingRampWidth+(CarWidth*2.0)),0.0,-((JumpingRampLength+(CarLength*2.0)))*Index)));
   RigidBody.CollisionGroups:=[0];
  end;
 end;

 begin
  // Dominos
  for Index:=0 to CountDominos-1 do begin
   RigidBody:=TKraftRigidBody.Create(KraftPhysics);
   RigidBody.SetRigidBodyType(krbtDYNAMIC);
   Shape:=TKraftShapeBox.Create(KraftPhysics,RigidBody,Vector3(0.125,1.0,0.5));
   Shape.Restitution:=0.4;
   Shape.Density:=1.0;
   RigidBody.ForcedMass:=1.0;
   RigidBody.Finish;
   RigidBody.SetWorldTransformation(Matrix4x4TermMul(Matrix4x4TermMul(Matrix4x4Translate(0.0,TKraftShapeBox(Shape).Extents.y,-8.0-((Index/CountDominos)*4.0)),Matrix4x4RotateY((Index-((CountDominos-1)*0.5))*(pi/CountDominos)*2.0)),Matrix4x4Translate(JumpingRampWidth+(CarWidth*4),0.0,-12.0)));
   RigidBody.CollisionGroups:=[0,1];
// RigidBody.Gravity.Vector:=Vector3(0.0,-9.81*4.0,0.0);
// RigidBody.Flags:=RigidBody.Flags+[krbfHasOwnGravity];
  end;
 end;//}

{}begin
  // Street elevations
  for Index:=0 to CountStreetElevations-1 do begin
   RigidBody:=TKraftRigidBody.Create(KraftPhysics);
   RigidBody.SetRigidBodyType(krbtSTATIC);
   Shape:=TKraftShapeCapsule.Create(KraftPhysics,RigidBody,0.25,16);
   Shape.Restitution:=0.4;
   Shape.Density:=1.0;
   RigidBody.ForcedMass:=1.0;
   RigidBody.Finish;
   RigidBody.SetWorldTransformation(Matrix4x4TermMul(
                                     Matrix4x4RotateZ(PI*0.5),
                                     Matrix4x4Translate(-(JumpingRampWidth+(CarWidth*4)),0.0,-(12.0+(Index*0.75)))
                                    )
                                   );
   RigidBody.CollisionGroups:=[0];
  end;
 end;//}

 begin
  ChassisRigidBody:=TKraftRigidBody.Create(KraftPhysics);
  ChassisRigidBody.SetRigidBodyType(krbtDYNAMIC);
  Shape:=TKraftShapeBox.Create(KraftPhysics,ChassisRigidBody,Vector3(1.0,0.0625,3.0));
  Shape.Restitution:=0.3;
  Shape.Density:=10.0;
  Shape.LocalTransform:=Matrix4x4Translate(0.0,0.0,0.0);
  ChassisRigidBody.Finish;
  ChassisRigidBody.SetWorldTransformation(Matrix4x4Translate(0.0,1.5,-2.0));
  ChassisRigidBody.CollisionGroups:=[1];
  ChassisRigidBody.AngularVelocityDamp:=10.0;
  ChassisRigidBody.LinearVelocityDamp:=0.05;
 end;

{ConvexHull:=TKraftConvexHull.Create(KraftPhysics);
 ConvexHullGarbageCollector.Add(ConvexHull);
 for y:=0 to CountWheelVertices-1 do begin
  t:=(y/(CountWheelVertices-1))*PI*2.0;
  SinCos(t,s,c);
  s:=s*0.75;
  c:=c*0.75;
  ConvexHull.AddVertex(Vector3(-0.5,s,c));
  ConvexHull.AddVertex(Vector3(0.5,s,c));
 end;
 ConvexHull.Build;
 ConvexHull.Finish;}

 for y:=0 to 1 do begin

  for x:=0 to 1 do begin

   WheelRigidBodies[y,x]:=TKraftRigidBody.Create(KraftPhysics);
   WheelRigidBodies[y,x].SetRigidBodyType(krbtDYNAMIC);
// Shape:=TKraftShapeConvexHull.Create(KraftPhysics,WheelRigidBodies[y,x],ConvexHull);
   Shape:=TKraftShapeSphere.Create(KraftPhysics,WheelRigidBodies[y,x],0.5);
   Shape.Restitution:=0.3;
   Shape.Density:=1.0;
   Shape.Friction:=10.0;
   WheelRigidBodies[y,x].Finish;
   WheelRigidBodies[y,x].SetWorldTransformation(Matrix4x4Translate(WheelPositions[y,x]));
   WheelRigidBodies[y,x].CollisionGroups:=[1];
   WheelRigidBodies[y,x].AngularVelocityDamp:=1.0;
   WheelRigidBodies[y,x].LinearVelocityDamp:=0.05;
   WheelRigidBodies[y,x].MaximalAngularVelocity:=0.25;

   WheelHingeJointConstraints[y,x]:=TKraftConstraintJointHinge.Create(KraftPhysics,
                                                                      ChassisRigidBody,
                                                                      WheelRigidBodies[y,x],
                                                                      WheelPositions[y,x],
                                                                      Vector3Norm(Vector3(1.0,0.0,0.0)),
                                                                      false,
                                                                      false,
                                                                      -1.0,
                                                                      1.0,
                                                                      1.0,
                                                                      0.0,
                                                                      false);

  end;
 end;

 InputKeyLeft:=false;
 InputKeyRight:=false;
 InputKeyUp:=false;
 InputKeyDown:=false;
 InputKeyBrake:=false;
 InputKeyHandBrake:=false;

end;

destructor TDemoSceneConstraintVehicle.Destroy;
begin
 inherited Destroy;
end;

procedure TDemoSceneConstraintVehicle.Step(const DeltaTime:double);
const Signs:array[0..1] of longint=(1,-1);
      MaxAngle=32.0*DEG2RAD;
var x,y:longint;
    CarAngle,Radius:double;
    SideRadius:array[0..1] of single;
    AxisVectors:array[0..1,0..1] of TKraftVector3;
    NeedBeAwake:boolean;
    WorldTransform:TKraftMatrix4x4;
    WorldLeft,WorldRight,WorldUp,WorldDown,WorldForward,WorldBackward,WorldPosition,
    HitPoint,HitNormal,KeepUpNormal,Axis,NewUp,Delta,Force:TKraftVector3;
    HitTime,Angle:TKraftScalar;
    HitShape:TKraftShape;
    SourceQuaternion,TargetQuaternion,DifferenceQuaternion:TKraftQuaternion;
begin

 Time:=Time+DeltaTime;

 WorldTransform:=ChassisRigidBody.WorldTransform;
 WorldRight:=PKraftVector3(pointer(@WorldTransform[0,0]))^;
 WorldLeft:=Vector3Neg(WorldRight);
 WorldUp:=PKraftVector3(pointer(@WorldTransform[1,0]))^;
 WorldDown:=Vector3Neg(WorldUp);
 WorldForward:=PKraftVector3(pointer(@WorldTransform[2,0]))^;
 WorldBackward:=Vector3Neg(WorldForward);
 WorldPosition:=PKraftVector3(pointer(@WorldTransform[3,0]))^;

 CarSteering:=Min(Max((CarSteering*0.99)+(((ord(InputKeyRight) and 1)*0.01)-((ord(InputKeyLeft) and 1)*0.01)),-1.0),1.0);
 CarSpeed:=Min(Max((CarSpeed*0.99)+(((ord(InputKeyUp) and 1)*0.01)-((ord(InputKeyDown) and 1)*0.01)),-1.0),1.0);
 CarAngle:=Min(Max(CarSteering,-1.0),1.0)*10.0;

 NeedBeAwake:=(abs(CarSpeed)>1e-5) or (abs(CarAngle)>1e-5);

 begin
  // Keep up
{ if fKraftPhysics.SphereCast(WorldPosition,1.0,WorldDown,2.0,HitShape,HitTime,HitPoint,HitNormal,[0]) then begin
   KeepUpNormal:=HitNormal;
  end else}begin
   KeepUpNormal:=Vector3Neg(fKraftPhysics.Gravity.Vector);
  end;

  // Calculate the new target up-vector
  NewUp:=Vector3Norm(KeepUpNormal);

{ // Get difference quaternion between current orientation to target keep-up-right-forward orientation
  SourceQuaternion:=ChassisRigidBody.Sweep.q;
  TargetQuaternion:=QuaternionMul(QuaternionFromToRotation(WorldUp,NewUp),ChassisRigidBody.Sweep.q);
  DifferenceQuaternion:=QuaternionTermNormalize(QuaternionMul(TargetQuaternion,QuaternionInverse(SourceQuaternion)));

  // Convert difference quaternion to axis angles
  QuaternionToAxisAngle(DifferenceQuaternion,Axis,Angle);

  // Transform axis into local space
  Axis:=Vector3TermMatrixMulTransposedBasis(Axis,ChassisRigidBody.WorldTransform);

  // Get difference velocity
  Delta:=Vector3ScalarMul(Axis,Min(Max(Angle,-MaxAngle),MaxAngle)*32.0);
  Delta.Yaw:=0.0; // Clear yaw

  ChassisRigidBody.AddWorldTorque(Vector3ScalarMul(Delta,100.0),kfmForce); }
// ChassisRigidBody.AddWorldTorque(Vector3ScalarMul(Delta,fKraftPhysics.WorldDeltaTime),kfmVelocity);
//  AngularVelocity,Vector3ScalarMul(Delta,TimeStep.DeltaTime));


{  // Apply difference velocity directly to angular velocity
   Vector3DirectAdd(LocalAngularVelocity,Vector3ScalarMul(Delta,TimeStep.DeltaTime)); }

  if Vector3Dot(WorldUp,NewUp)<0.9 then begin

   Axis:=Vector3Norm(Vector3Cross(WorldUp,NewUp));

   // To avoid the vehicle going backwards/forwards (or rolling sideways),
   // set the pitch/roll to 0 before applying the 'straightening' impulse.
 //ChassisRigidBody.AngularVelocity:=Vector3(0.0,ChassisRigidBody.AngularVelocity.y,0.0);

   Force:=Vector3ScalarMul(Axis,ChassisRigidBody.Mass*100.0);
   if Vector3Length(Force)>1e-6 then begin
    ChassisRigidBody.AddWorldTorque(Force,kfmForce);
    NeedBeAwake:=true;
   end;

  end;

 end;

 begin
  // All-wheel steering and driving
  if abs(CarAngle)>EPSILON then begin
   Radius:=tan(CarAngle*DEG2RAD);
  end else begin
   Radius:=tan(EPSILON*DEG2RAD);
  end;
  Radius:=CarLength/Radius;
  SideRadius[0]:=arctan(CarLength/(Radius-CarHalfWidth));
  SideRadius[1]:=arctan(CarLength/(Radius+CarHalfWidth));
  for y:=0 to 1 do begin
   for x:=0 to 1 do begin
    AxisVectors[y,x]:=Vector3TermMatrixMulBasis(Vector3Norm(Vector3(cos(SideRadius[x]),0.0,sin(SideRadius[x])*Signs[y])),ChassisRigidBody.WorldTransform);
    WheelHingeJointConstraints[y,x].SetWorldRotationAxis(AxisVectors[y,x]);
    WheelRigidBodies[y,x].AddWorldAngularVelocity(Vector3TermMatrixMul(Vector3ScalarMul(AxisVectors[y,x],-(CarSpeed*0.5)),WheelRigidBodies[y,x].WorldInverseInertiaTensor),kfmVelocity);
   end;
  end;
 end;

 if NeedBeAwake then begin
  for y:=0 to 1 do begin
   for x:=0 to 1 do begin
    WheelRigidBodies[y,x].SetToAwake;
   end;
  end;
  ChassisRigidBody.SetToAwake;
 end;

end;

procedure TDemoSceneConstraintVehicle.DebugDraw;
begin
 inherited DebugDraw;
{glDisable(GL_LIGHTING);
 glEnable(GL_POLYGON_OFFSET_LINE);
 glEnable(GL_POLYGON_OFFSET_POINT);
 glPolygonOffset(-8,8);
 glPointSize(8);
 glLineWidth(4);
 glColor4f(1,1,1,1);
 Vehicle.DebugDraw;
 glDisable(GL_DEPTH_TEST);
 glDisable(GL_POLYGON_OFFSET_LINE);
 glDisable(GL_POLYGON_OFFSET_POINT);}
end;

function TDemoSceneConstraintVehicle.HasOwnKeyboardControls:boolean;
begin
 result:=true;
end;

procedure TDemoSceneConstraintVehicle.KeyDown(const aKey:Int32);
begin
 case aKey of
  VK_LEFT:begin
   InputKeyLeft:=true;
  end;
  VK_RIGHT:begin
   InputKeyRight:=true;
  end;
  VK_UP:begin
   InputKeyUp:=true;
  end;
  VK_DOWN:begin
   InputKeyDown:=true;
  end;
  VK_SPACE:begin
   InputKeyBrake:=true;
  end;
  VK_RETURN:begin
   InputKeyHandBrake:=true;
  end;
 end;
end;

procedure TDemoSceneConstraintVehicle.KeyUp(const aKey:Int32);
begin
 case aKey of
  VK_LEFT:begin
   InputKeyLeft:=false;
  end;
  VK_RIGHT:begin
   InputKeyRight:=false;
  end;
  VK_UP:begin
   InputKeyUp:=false;
  end;
  VK_DOWN:begin
   InputKeyDown:=false;
  end;
  VK_SPACE:begin
   InputKeyBrake:=false;
  end;
  VK_RETURN:begin
   InputKeyHandBrake:=false;
  end;
 end;
end;

function TDemoSceneConstraintVehicle.UpdateCamera(var aCameraPosition:TKraftVector3;var aCameraOrientation:TKraftQuaternion):boolean;
var Position,WorldLeft,WorldRight,WorldUp,WorldDown,WorldForward,WorldBackward,WorldPosition:TKraftVector3;
    TargetMatrix:TKraftMatrix3x3;
    LerpFactor:TKraftScalar;
    WorldTransform:TKraftMatrix4x4;
begin
 WorldTransform:=ChassisRigidBody.WorldTransform;
 WorldRight:=PKraftVector3(pointer(@WorldTransform[0,0]))^;
 WorldLeft:=Vector3Neg(WorldRight);
 WorldUp:=PKraftVector3(pointer(@WorldTransform[1,0]))^;
 WorldDown:=Vector3Neg(WorldUp);
 WorldForward:=PKraftVector3(pointer(@WorldTransform[2,0]))^;
 WorldBackward:=Vector3Neg(WorldForward);
 WorldPosition:=PKraftVector3(pointer(@WorldTransform[3,0]))^;
 LerpFactor:=1.0-exp(-(1.0/20.0));
 Position:=Vector3Add(Vector3Add(WorldPosition,Vector3ScalarMul(WorldForward,10.0)),Vector3ScalarMul(WorldUp,5.0));
 PKraftVector3(@TargetMatrix[2,0])^:=Vector3Norm(Vector3Sub(WorldPosition,Position));
 PKraftVector3(@TargetMatrix[1,0])^:=WorldUp;
 PKraftVector3(@TargetMatrix[0,0])^:=Vector3Cross(PKraftVector3(@TargetMatrix[1,0])^,PKraftVector3(@TargetMatrix[2,0])^);
 PKraftVector3(@TargetMatrix[1,0])^:=Vector3Cross(PKraftVector3(@TargetMatrix[2,0])^,PKraftVector3(@TargetMatrix[0,0])^);
 aCameraPosition:=Vector3Lerp(aCameraPosition,Position,LerpFactor);
 aCameraOrientation:=QuaternionSlerp(aCameraOrientation,QuaternionFromMatrix3x3(TargetMatrix),LerpFactor);  {}
 result:=true;
end;

procedure TDemoSceneConstraintVehicle.StoreWorldTransforms;
begin
 inherited StoreWorldTransforms;
 //Vehicle.StoreWorldTransforms;
end;

procedure TDemoSceneConstraintVehicle.InterpolateWorldTransforms(const aAlpha:TKraftScalar);
begin
 inherited InterpolateWorldTransforms(aAlpha);
 //Vehicle.InterpolateWorldTransforms(aAlpha);
end;

initialization
 RegisterDemoScene('Constraint vehicle',TDemoSceneConstraintVehicle);
end.
