unit UnitDemoSceneDomino;

{$MODE Delphi}

interface

uses Kraft,UnitDemoScene;

type TDemoSceneDomino=class(TDemoScene)
      public
       RigidBodyFloor:TKraftRigidBody;
       ShapeFloorPlane:TKraftShapePlane;
       constructor Create(const AKraftPhysics:TKraft); override;
       destructor Destroy; override;
       procedure Step(const DeltaTime:double); override;
     end;

implementation

uses UnitFormMain;

constructor TDemoSceneDomino.Create(const AKraftPhysics:TKraft);
const Count=64;
var i:longint;
    RigidBody:TKraftRigidBody;
    Shape:TKraftShape;
begin
 inherited Create(AKraftPhysics);

 RigidBodyFloor:=TKraftRigidBody.Create(KraftPhysics);
 RigidBodyFloor.SetRigidBodyType(krbtSTATIC);
 ShapeFloorPlane:=TKraftShapePlane.Create(KraftPhysics,RigidBodyFloor,Plane(Vector3Norm(Vector3(0.0,1.0,0.0)),0.0));
 ShapeFloorPlane.Restitution:=0.4;
 RigidBodyFloor.Finish;
 RigidBodyFloor.SetWorldTransformation(Matrix4x4Translate(0.0,0.0,0.0));
 RigidBodyFloor.CollisionGroups:=[0];

 for i:=0 to Count-1 do begin
  RigidBody:=TKraftRigidBody.Create(KraftPhysics);
  RigidBody.SetRigidBodyType(krbtDYNAMIC);
  Shape:=TKraftShapeBox.Create(KraftPhysics,RigidBody,Vector3(0.125,1.0,0.5));
  Shape.Restitution:=0.4;
  Shape.Density:=1.0;
  RigidBody.ForcedMass:=1.0;
  RigidBody.Finish;
  RigidBody.SetWorldTransformation(Matrix4x4TermMul(Matrix4x4TermMul(Matrix4x4Translate(0.0,TKraftShapeBox(Shape).Extents.y,-8.0-((i/Count)*4.0)),Matrix4x4RotateY((i-((Count-1)*0.5))*(pi/Count)*2.0)),Matrix4x4Translate(0.0,0.0,-12.0)));
  RigidBody.CollisionGroups:=[0];
  RigidBody.Gravity.Vector:=Vector3(0.0,-9.81*4.0,0.0);
  RigidBody.Flags:=RigidBody.Flags+[krbfHasOwnGravity];
 end;

 RigidBody:=TKraftRigidBody.Create(KraftPhysics);
 RigidBody.SetRigidBodyType(krbtDYNAMIC);
 Shape:=TKraftShapeSphere.Create(KraftPhysics,RigidBody,0.5);
 Shape.Restitution:=0.4;
 Shape.Density:=1.0;
 RigidBody.ForcedMass:=1.0;
 RigidBody.Finish;
 i:=Count;
 RigidBody.SetWorldTransformation(Matrix4x4TermMul(Matrix4x4TermMul(Matrix4x4Translate(0.0,TKraftShapeSphere(Shape).Radius,-12.0),Matrix4x4RotateY((i-((Count-1)*0.5))*(pi/Count)*2.0)),Matrix4x4Translate(4.0,0.0,-12.0)));
 RigidBody.CollisionGroups:=[0];
 RigidBody.Gravity.Vector:=Vector3(0.0,-9.81*4.0,0.0);
 RigidBody.Flags:=RigidBody.Flags+[krbfHasOwnGravity];
 RigidBody.SetWorldForce(Vector3(-8.0,0.0,0.0),kfmVelocity);

end;

destructor TDemoSceneDomino.Destroy;
begin
 inherited Destroy;
end;

procedure TDemoSceneDomino.Step(const DeltaTime:double);
begin
end;

initialization
 RegisterDemoScene('Domino',TDemoSceneDomino);
end.
