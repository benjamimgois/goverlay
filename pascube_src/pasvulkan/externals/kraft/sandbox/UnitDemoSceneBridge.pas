unit UnitDemoSceneBridge;

{$MODE Delphi}

interface

uses Kraft,UnitDemoScene;

type TDemoSceneBridge=class(TDemoScene)
      public
       RigidBodyFloor:TKraftRigidBody;
       ShapeFloorPlane:TKraftShapePlane;
       constructor Create(const AKraftPhysics:TKraft); override;
       destructor Destroy; override;
       procedure Step(const DeltaTime:double); override;
     end;

implementation

uses UnitFormMain;

constructor TDemoSceneBridge.Create(const AKraftPhysics:TKraft);
const Count=11;
      Spacing=0.125;
var Index:longint;
    RigidBodyBox:array[0..Count-1] of TKraftRigidBody;
    ShapeBox:TKraftShapeBox;
begin
 inherited Create(AKraftPhysics);

 RigidBodyFloor:=TKraftRigidBody.Create(KraftPhysics);
 RigidBodyFloor.SetRigidBodyType(krbtSTATIC);
 ShapeFloorPlane:=TKraftShapePlane.Create(KraftPhysics,RigidBodyFloor,Plane(Vector3Norm(Vector3(0.0,1.0,0.0)),0.0));
 ShapeFloorPlane.Restitution:=0.3;
 RigidBodyFloor.Finish;
 RigidBodyFloor.SetWorldTransformation(Matrix4x4Translate(0.0,0.0,0.0));
 RigidBodyFloor.CollisionGroups:=[0];

 for Index:=0 to Count-1 do begin
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
 end;

 for Index:=1 to Count-1 do begin
  TKraftConstraintJointBallSocket.Create(KraftPhysics,RigidBodyBox[Index-1],RigidBodyBox[Index],Vector3(ShapeBox.Extents.x+(Spacing*0.5),0.0,-ShapeBox.Extents.z),Vector3(-(ShapeBox.Extents.x+(Spacing*0.5)),0.0,-ShapeBox.Extents.z));
  TKraftConstraintJointBallSocket.Create(KraftPhysics,RigidBodyBox[Index-1],RigidBodyBox[Index],Vector3(ShapeBox.Extents.x+(Spacing*0.5),0.0,ShapeBox.Extents.z),Vector3(-(ShapeBox.Extents.x+(Spacing*0.5)),0.0,ShapeBox.Extents.z));
 end;

end;

destructor TDemoSceneBridge.Destroy;
begin
 inherited Destroy;
end;

procedure TDemoSceneBridge.Step(const DeltaTime:double);
begin
end;

initialization
 RegisterDemoScene('Bridge',TDemoSceneBridge);
end.
