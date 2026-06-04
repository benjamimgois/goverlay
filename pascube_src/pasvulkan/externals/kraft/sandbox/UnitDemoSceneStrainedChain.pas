unit UnitDemoSceneStrainedChain;

{$MODE Delphi}

interface

uses Kraft,UnitDemoScene;

type TDemoSceneStrainedChain=class(TDemoScene)
      public
       RigidBodyFloor:TKraftRigidBody;
       ShapeFloorPlane:TKraftShapePlane;
       constructor Create(const AKraftPhysics:TKraft); override;
       destructor Destroy; override;
       procedure Step(const DeltaTime:double); override;
     end;

implementation

uses UnitFormMain;

constructor TDemoSceneStrainedChain.Create(const AKraftPhysics:TKraft);
const Count=11;
      Spacing=0.125;
var Index:longint;
    RigidBody:array[0..Count-1] of TKraftRigidBody;
    Shape:TKraftShape;
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
  RigidBody[Index]:=TKraftRigidBody.Create(KraftPhysics);
  if (Index=0) or (Index=(Count-1)) then begin
   RigidBody[Index].SetRigidBodyType(krbtSTATIC);
  end else begin
   RigidBody[Index].SetRigidBodyType(krbtDYNAMIC);
  end;
  Shape:=TKraftShapeSphere.Create(KraftPhysics,RigidBody[Index],1.0);
  Shape.Restitution:=0.3;
  Shape.Density:=1.0;
  RigidBody[Index].Finish;
  RigidBody[Index].SetWorldTransformation(Matrix4x4Translate((Index-((Count-1)*0.5))*2.5,4.0,-4.0));
  RigidBody[Index].CollisionGroups:=[0];
 end;

 for Index:=1 to Count-1 do begin
  TKraftConstraintJointBallSocket.Create(KraftPhysics,RigidBody[Index-1],RigidBody[Index],Vector3(1.125,0.0,0.0),Vector3(-1.125,0.0,0.0),true);
 end;

end;

destructor TDemoSceneStrainedChain.Destroy;
begin
 inherited Destroy;
end;

procedure TDemoSceneStrainedChain.Step(const DeltaTime:double);
begin
end;

initialization
 RegisterDemoScene('Strained chain',TDemoSceneStrainedChain);
end.
