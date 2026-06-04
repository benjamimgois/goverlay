unit UnitDemoSceneRaycastArcadeVehicle;

{$MODE Delphi}

interface

uses LCLIntf,LCLType,LMessages,SysUtils,Classes,Math,Kraft,KraftArcadeCarPhysics,UnitDemoScene,gl,glext;

type { TDemoSceneRaycastArcadeVehicle }

     TDemoSceneRaycastArcadeVehicle=class(TDemoScene)
      public
       RigidBodyFloor:TKraftRigidBody;
       ShapeFloorPlane:TKraftShapePlane;
       Vehicle:TVehicle;
       CarSteering:double;
       CarSpeed:double;
       Time:double;
       InputKeyLeft,InputKeyRight,InputKeyUp,InputKeyDown,InputKeyBrake,InputKeyHandBrake:boolean;
       constructor Create(const aKraftPhysics:TKraft); override;
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

const CarWidth=1.8;
      CarLength=4.40;
      CarHeight=1.55;

      CarHalfWidth=CarWidth*0.5;

      WheelRadius=0.75;

      WheelY=-WheelRadius;

      ProtectionHeightOffset=4;

      CountDominos=64;

      CountStreetElevations=64;

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

{ TDemoSceneRaycastArcadeVehicle }

constructor TDemoSceneRaycastArcadeVehicle.Create(const aKraftPhysics: TKraft);
const Height=10;
var Index,i,j:Int32;
    RigidBody:TKraftRigidBody;
    Shape:TKraftShape;
    ConvexHull:TKraftConvexHull;
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

 begin
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
  // Brick wall
  for i:=0 to Height-1 do begin
   for j:=0 to Height-1 do begin
    if (i+j)>0 then begin
     RigidBody:=TKraftRigidBody.Create(KraftPhysics);
     RigidBody.SetRigidBodyType(krbtDYNAMIC);
     Shape:=TKraftShapeBox.Create(KraftPhysics,RigidBody,Vector3(1.0,0.5,0.25));
     Shape.Restitution:=0.4;
     Shape.Density:=10.0;
  // RigidBody.ForcedMass:=1.0;
     RigidBody.Finish;
     RigidBody.SetWorldTransformation(Matrix4x4Translate((((j+((i and 1)*0.5))-(Height*0.5))*(TKraftShapeBox(Shape).Extents.x*2.0))-((JumpingRampWidth+(CarWidth*4))*2),TKraftShapeBox(Shape).Extents.y+((Height-(i+1))*(TKraftShapeBox(Shape).Extents.y*2.0)),-8.0));
     RigidBody.CollisionGroups:=[0];
     RigidBody.SetToSleep;
    end;
   end;
  end;
 end;    //}

 Vehicle:=TVehicle.Create(KraftPhysics);

 Vehicle.DownForce:=10.0;

 Vehicle.AccelerationCurveEnvelope:=TVehicle.TEnvelope.CreateLinear(0.0,0.0,5.0,200.0);
 Vehicle.ReverseAccelerationCurveEnvelope:=TVehicle.TEnvelope.CreateLinear(0.0,0.0,5.0,50.0);

 Vehicle.FlightStabilizationForce:=6.0;
 Vehicle.FlightStabilizationDamping:=0.7;

 Vehicle.AxleFront.Width:=1.55;
 Vehicle.AxleFront.Offset:=Vector2(1.51,-0.5);
 Vehicle.AxleFront.Radius:=0.3;
 Vehicle.AxleFront.WheelVisualScale:=1.0;//2.9;
 Vehicle.AxleFront.StabilizerBarAntiRollForce:=15000.0;
 Vehicle.AxleFront.RelaxedSuspensionLength:=0.6;
{Vehicle.AxleFront.SuspensionStiffness:=15000.0;
 Vehicle.AxleFront.SuspensionDamping:=3000.0;
 Vehicle.AxleFront.SuspensionRestitution:=1.0;}
{Vehicle.AxleFront.LaterialFriction:=0.6;
 Vehicle.AxleFront.RollingFriction:=0.03;
 Vehicle.AxleFront.RelaxedSuspensionLength:=0.45;
 Vehicle.AxleFront.StabilizerBarAntiRollForce:=10000.0;
 Vehicle.AxleFront.WheelVisualScale:=1.0;//2.9;
 Vehicle.AxleFront.AfterFlightSlipperyK:=0.02;
 Vehicle.AxleFront.BrakeSlipperyK:=0.5;
 Vehicle.AxleFront.HandBrakeSlipperyK:=0.3;}
 Vehicle.AxleFront.IsPowered:=false;

 Vehicle.AxleRear.Width:=1.55;
 Vehicle.AxleRear.Offset:=Vector2(-1.29,-0.5);
 Vehicle.AxleRear.Radius:=0.3;
 Vehicle.AxleRear.WheelVisualScale:=1.0;//2.9;
 Vehicle.AxleRear.StabilizerBarAntiRollForce:=15000.0;
 Vehicle.AxleRear.RelaxedSuspensionLength:=0.6;
{Vehicle.AxleRear.SuspensionStiffness:=9500.0;
 Vehicle.AxleRear.SuspensionDamping:=3000.0;
 Vehicle.AxleRear.SuspensionRestitution:=1.0;}
{Vehicle.AxleRear.LaterialFriction:=0.6;
 Vehicle.AxleRear.RollingFriction:=0.03;
 Vehicle.AxleRear.RelaxedSuspensionLength:=0.45;
 Vehicle.AxleRear.StabilizerBarAntiRollForce:=10000.0;
 Vehicle.AxleRear.WheelVisualScale:=1.0;//2.9;
 Vehicle.AxleRear.AfterFlightSlipperyK:=0.02;
 Vehicle.AxleRear.BrakeSlipperyK:=0.5;
 Vehicle.AxleRear.HandBrakeSlipperyK:=0.2; }
 Vehicle.AxleRear.IsPowered:=true;

 Vehicle.RigidBody:=TKraftRigidBody.Create(aKraftPhysics);
 Vehicle.RigidBody.SetRigidBodyType(krbtDYNAMIC);
{Vehicle.RigidBody.Flags:=Vehicle.RigidBody.Flags+[krbfHasForcedCenterOfMass];
 Vehicle.RigidBody.ForcedCenterOfMass.x:=0;
 Vehicle.RigidBody.ForcedCenterOfMass.y:=-0.3;
 Vehicle.RigidBody.ForcedCenterOfMass.z:=0.0;
 Vehicle.RigidBody.ForcedMass:=1500.0;}
 Shape:=TKraftShapeBox.Create(aKraftPhysics,Vehicle.RigidBody,Vector3(CarHalfWidth,CarHeight*0.5,CarLength*0.5));
 Shape.Restitution:=0.3;
 Shape.Density:=200.0;
 Shape.LocalTransform:=Matrix4x4Translate(0.0,0.0,0.0);
 Shape.Flags:=Shape.Flags+[ksfHasForcedCenterOfMass];
 Shape.ForcedCenterOfMass.x:=0;
 Shape.ForcedCenterOfMass.y:=-0.6;
 Shape.ForcedCenterOfMass.z:=0.0;
 Shape.ForcedMass:=1500.0;
{Shape:=TKraftShapeBox.Create(aKraftPhysics,Vehicle.RigidBody,Vector3(1.0,1.0,2.0));
 Shape.Restitution:=0.3;
 Shape.Density:=10.0;
 Shape.LocalTransform:=Matrix4x4Translate(0.0,1.75,1.0);}
 Vehicle.RigidBody.Finish;
 Vehicle.RigidBody.SetWorldTransformation(Matrix4x4TermMul(Matrix4x4RotateY(PI),Matrix4x4Translate(0.0,CarHeight+Vehicle.AxleFront.Radius,0.0)));
 Vehicle.RigidBody.CollisionGroups:=[1];
 Vehicle.RigidBody.CollideWithCollisionGroups:=[0,1];
 Vehicle.RigidBody.AngularVelocityDamp:=10.0;//10.0;
 Vehicle.RigidBody.LinearVelocityDamp:=0.3275;
{Vehicle.RigidBody.Flags:=Vehicle.RigidBody.Flags+[TKraftRigidBodyFlag.krbfHasOwnGravity];
 Vehicle.RigidBody.Gravity.x:=0.0;
 Vehicle.RigidBody.Gravity.y:=0.0;
 Vehicle.RigidBody.Gravity.z:=0.0;}

 Vehicle.Reset;

 InputKeyLeft:=false;
 InputKeyRight:=false;
 InputKeyUp:=false;
 InputKeyDown:=false;
 InputKeyBrake:=false;
 InputKeyHandBrake:=false;

{begin
  DummyRigidBody:=TKraftRigidBody.Create(KraftPhysics);
  DummyRigidBody.SetRigidBodyType(krbtSTATIC);
  Shape:=TKraftShapeBox.Create(KraftPhysics,DummyRigidBody,Vector3(4.0,25.0,2.0));
  Shape.Restitution:=0.3;
  DummyRigidBody.Finish;
  DummyRigidBody.CollisionGroups:=[0];
  DummyRigidBody.SetWorldTransformation(Matrix4x4TermMul(Matrix4x4RotateX(-0.35*pi),Matrix4x4Translate(0.0,0.0,-10.0)));
 end;}

end;

destructor TDemoSceneRaycastArcadeVehicle.Destroy;
begin
 FreeAndNil(Vehicle);
 inherited Destroy;
end;

procedure TDemoSceneRaycastArcadeVehicle.Step(const DeltaTime:double);
begin
 Time:=Time+DeltaTime;
 Vehicle.InputVertical:=(ord(InputKeyUp) and 1)-(ord(InputKeyDown) and 1);
 Vehicle.InputHorizontal:=(ord(InputKeyLeft) and 1)-(ord(InputKeyRight) and 1);
 Vehicle.InputBrake:=InputKeyBrake;
 Vehicle.InputHandBrake:=InputKeyHandBrake;
 Vehicle.Update;
end;

procedure TDemoSceneRaycastArcadeVehicle.DebugDraw;
begin
 inherited DebugDraw;
 glDisable(GL_LIGHTING);
 glEnable(GL_POLYGON_OFFSET_LINE);
 glEnable(GL_POLYGON_OFFSET_POINT);
 glPolygonOffset(-8,8);
 glPointSize(8);
 glLineWidth(4);
 glColor4f(1,1,1,1);
 Vehicle.DebugDraw;
 glDisable(GL_DEPTH_TEST);
 glDisable(GL_POLYGON_OFFSET_LINE);
 glDisable(GL_POLYGON_OFFSET_POINT);
end;

function TDemoSceneRaycastArcadeVehicle.HasOwnKeyboardControls:boolean;
begin
 result:=true;
end;

procedure TDemoSceneRaycastArcadeVehicle.KeyDown(const aKey:Int32);
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

procedure TDemoSceneRaycastArcadeVehicle.KeyUp(const aKey:Int32);
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

function TDemoSceneRaycastArcadeVehicle.UpdateCamera(var aCameraPosition:TKraftVector3;var aCameraOrientation:TKraftQuaternion):boolean;
var Position:TKraftVector3;
    TargetMatrix:TKraftMatrix3x3;
    LerpFactor:TKraftScalar;
begin
 LerpFactor:=1.0-exp(-(1.0/20.0));
 Position:=Vector3Add(Vector3Add(Vehicle.WorldPosition,Vector3ScalarMul(Vehicle.WorldForward,-5.0)),Vector3ScalarMul(Vehicle.WorldUp,0.0));
 PKraftVector3(@TargetMatrix[2,0])^.xyz:=Vector3Norm(Vector3Sub(Vehicle.WorldPosition,Position)).xyz;
 PKraftVector3(@TargetMatrix[1,0])^.xyz:=Vehicle.WorldUp.xyz;
 PKraftVector3(@TargetMatrix[0,0])^.xyz:=Vector3Cross(PKraftVector3(@TargetMatrix[1,0])^,PKraftVector3(@TargetMatrix[2,0])^).xyz;
 PKraftVector3(@TargetMatrix[1,0])^.xyz:=Vector3Cross(PKraftVector3(@TargetMatrix[2,0])^,PKraftVector3(@TargetMatrix[0,0])^).xyz;
 aCameraPosition:=Vector3Lerp(aCameraPosition,Position,LerpFactor);
 aCameraOrientation:=QuaternionSlerp(aCameraOrientation,QuaternionFromMatrix3x3(TargetMatrix),LerpFactor);
 result:=true;
end;

procedure TDemoSceneRaycastArcadeVehicle.StoreWorldTransforms;
begin
 inherited StoreWorldTransforms;
 Vehicle.StoreWorldTransforms;
end;

procedure TDemoSceneRaycastArcadeVehicle.InterpolateWorldTransforms(const aAlpha:TKraftScalar);
begin
 inherited InterpolateWorldTransforms(aAlpha);
 Vehicle.InterpolateWorldTransforms(aAlpha);
end;

initialization
 RegisterDemoScene('Raycast arcade vehicle',TDemoSceneRaycastArcadeVehicle);
end.
