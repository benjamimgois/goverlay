unit UnitDemoSceneCatapult;

{$MODE Delphi}

interface

uses Kraft,UnitDemoScene;

type TDemoSceneCatapult=class(TDemoScene)
      public
       RigidBodyFloor:TKraftRigidBody;
       ShapeFloorPlane:TKraftShapePlane;
       constructor Create(const AKraftPhysics:TKraft); override;
       destructor Destroy; override;
       procedure Step(const DeltaTime:double); override;
     end;

implementation

uses UnitFormMain;

constructor TDemoSceneCatapult.Create(const AKraftPhysics:TKraft);
const Count=4;
      Spacing=0.125;
var Index:longint;
    RigidBodyBox:array[0..Count-1] of TKraftRigidBody;
    ShapeBox:TKraftShapeBox;
    RigidBodyCapsule:TKraftRigidBody;
    ShapeCapsule:TKraftShapeCapsule;

begin
 inherited Create(AKraftPhysics);

 RigidBodyFloor:=TKraftRigidBody.Create(KraftPhysics);
 RigidBodyFloor.SetRigidBodyType(krbtSTATIC);
 ShapeFloorPlane:=TKraftShapePlane.Create(KraftPhysics,RigidBodyFloor,Plane(Vector3Norm(Vector3(0.0,1.0,0.0)),0.0));
 ShapeFloorPlane.Restitution:=0.3;
 RigidBodyFloor.Finish;
 RigidBodyFloor.SetWorldTransformation(Matrix4x4Translate(0.0,0.0,0.0));
 RigidBodyFloor.CollisionGroups:=[0];

 RigidBodyCapsule:=TKraftRigidBody.Create(KraftPhysics);
 RigidBodyCapsule.SetRigidBodyType(krbtSTATIC);
 ShapeCapsule:=TKraftShapeCapsule.Create(KraftPhysics,RigidBodyCapsule,0.25,2.0);
 ShapeCapsule.Restitution:=0.3;
 RigidBodyCapsule.Finish;
 RigidBodyCapsule.CollisionGroups:=[0];
 RigidBodyCapsule.SetWorldTransformation(Matrix4x4TermMul(Matrix4x4RotateX(0.5*pi),Matrix4x4Translate(0.0,0.5,0.0)));

 RigidBodyBox[0]:=TKraftRigidBody.Create(KraftPhysics);
 RigidBodyBox[0].SetRigidBodyType(krbtDYNAMIC);
 ShapeBox:=TKraftShapeBox.Create(KraftPhysics,RigidBodyBox[0],Vector3(2.0,0.1,1.0));
 ShapeBox.Restitution:=0.3;
//ShapeBox.Density:=100.0;
 RigidBodyBox[0].Finish;
 RigidBodyBox[0].SetWorldTransformation(Matrix4x4Translate(0.0,1.0,0.0));
 RigidBodyBox[0].CollisionGroups:=[0];

 RigidBodyBox[1]:=TKraftRigidBody.Create(KraftPhysics);
 RigidBodyBox[1].SetRigidBodyType(krbtDYNAMIC);
 ShapeBox:=TKraftShapeBox.Create(KraftPhysics,RigidBodyBox[1],Vector3(0.5,0.5,0.5));
 ShapeBox.Restitution:=0.3;
 ShapeBox.Density:=50.0;
 RigidBodyBox[1].Finish;
 RigidBodyBox[1].SetWorldTransformation(Matrix4x4Translate(1.5,8.0,0.0));
 RigidBodyBox[1].CollisionGroups:=[0];

 RigidBodyBox[2]:=TKraftRigidBody.Create(KraftPhysics);
 RigidBodyBox[2].SetRigidBodyType(krbtDYNAMIC);
 ShapeBox:=TKraftShapeBox.Create(KraftPhysics,RigidBodyBox[2],Vector3(0.25,0.25,0.25));
 ShapeBox.Restitution:=0.3;
 ShapeBox.Density:=50.0;
 RigidBodyBox[2].Finish;
 RigidBodyBox[2].SetWorldTransformation(Matrix4x4Translate(-1.5,1.25,0.0));
 RigidBodyBox[2].CollisionGroups:=[0];

 TKraftConstraintJointHinge.Create(KraftPhysics,RigidBodyCapsule,RigidBodyBox[0],Vector3(0.0,0.5,0.0),Vector3(0.0,0.0,1.0));

{for Index:=0 to Count-1 do begin
  RigidBodyBox[Index]:=TKraftRigidBody.Create(KraftPhysics);
  if (Index=0) or (Index=(Count-1)) then begin
   RigidBodyBox[Index].SetRigidBodyType(krbtSTATIC);
  end else begin
   RigidBodyBox[Index].SetRigidBodyType(krbtDYNAMIC);
  end;
  ShapeBox:=TKraftShapeBox.Create(KraftPhysics,RigidBodyBox[Index],Vector3(0.5,0.1,1.0));
  ShapeBox.Restitution:=0.3;
  ShapeBox.Density:=100.0;
  RigidBodyBox[Index].Finish;
  RigidBodyBox[Index].SetWorldTransformation(Matrix4x4Translate(((ShapeBox.Extents.x*2.0)+Spacing)*(Index-((Count-1)*0.5)),5.0,-4.0));
  RigidBodyBox[Index].CollisionGroups:=[0];
 end;}

{
 for Index:=1 to Count-1 do begin
  TKraftConstraintJointBallSocket.Create(KraftPhysics,RigidBodyBox[Index-1],RigidBodyBox[Index],Vector3(ShapeBox.Extents.x+(Spacing*0.5),0.0,-ShapeBox.Extents.z),Vector3(-(ShapeBox.Extents.x+(Spacing*0.5)),0.0,-ShapeBox.Extents.z));
  TKraftConstraintJointBallSocket.Create(KraftPhysics,RigidBodyBox[Index-1],RigidBodyBox[Index],Vector3(ShapeBox.Extents.x+(Spacing*0.5),0.0,ShapeBox.Extents.z),Vector3(-(ShapeBox.Extents.x+(Spacing*0.5)),0.0,ShapeBox.Extents.z));
 end;
 {}

end;

destructor TDemoSceneCatapult.Destroy;
begin
 inherited Destroy;
end;

procedure TDemoSceneCatapult.Step(const DeltaTime:double);
begin
end;

initialization
 RegisterDemoScene('Catapult',TDemoSceneCatapult);
end.
