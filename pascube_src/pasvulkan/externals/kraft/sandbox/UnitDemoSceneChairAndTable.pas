unit UnitDemoSceneChairAndTable;

{$MODE Delphi}

interface

uses Kraft,UnitDemoScene;

type TDemoSceneChairAndTable=class(TDemoScene)
      public
       RigidBodyFloor:TKraftRigidBody;
       ShapeFloorPlane:TKraftShapePlane;
       constructor Create(const AKraftPhysics:TKraft); override;
       destructor Destroy; override;
       procedure Step(const DeltaTime:double); override;
     end;

implementation

uses UnitFormMain;

constructor TDemoSceneChairAndTable.Create(const AKraftPhysics:TKraft);
var RigidBody:TKraftRigidBody;
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

 begin
  RigidBody:=TKraftRigidBody.Create(KraftPhysics);
  RigidBody.SetRigidBodyType(krbtDYNAMIC);

  Shape:=TKraftShapeBox.Create(KraftPhysics,RigidBody,Vector3(0.25,1.0,0.25));
  Shape.Restitution:=0.3;
  Shape.Density:=1.0;
  Shape.LocalTransform:=Matrix4x4Translate(-0.75,0.0,0.75);

  Shape:=TKraftShapeBox.Create(KraftPhysics,RigidBody,Vector3(0.25,1.0,0.25));
  Shape.Restitution:=0.3;
  Shape.Density:=1.0;
  Shape.LocalTransform:=Matrix4x4Translate(0.75,0.0,0.75);

  Shape:=TKraftShapeBox.Create(KraftPhysics,RigidBody,Vector3(0.25,1.0,0.25));
  Shape.Restitution:=0.3;
  Shape.Density:=1.0;
  Shape.LocalTransform:=Matrix4x4Translate(-0.75,0.0,-0.75);

  Shape:=TKraftShapeBox.Create(KraftPhysics,RigidBody,Vector3(0.25,1.0,0.25));
  Shape.Restitution:=0.3;
  Shape.Density:=1.0;
  Shape.LocalTransform:=Matrix4x4Translate(0.75,0.0,-0.75);

  Shape:=TKraftShapeBox.Create(KraftPhysics,RigidBody,Vector3(1.0,0.25,1.0));
  Shape.Restitution:=0.3;
  Shape.Density:=1.0;
  Shape.LocalTransform:=Matrix4x4Translate(0.0,1.25,0.0);

  Shape:=TKraftShapeBox.Create(KraftPhysics,RigidBody,Vector3(0.25,1.0,0.25));
  Shape.Restitution:=0.3;
  Shape.Density:=1.0;
  Shape.LocalTransform:=Matrix4x4Translate(-0.75,2.5,-0.75);

  Shape:=TKraftShapeBox.Create(KraftPhysics,RigidBody,Vector3(0.25,1.0,0.25));
  Shape.Restitution:=0.3;
  Shape.Density:=1.0;
  Shape.LocalTransform:=Matrix4x4Translate(0.75,2.5,-0.75);

  Shape:=TKraftShapeBox.Create(KraftPhysics,RigidBody,Vector3(0.25,1.0,0.25));
  Shape.Restitution:=0.3;
  Shape.Density:=1.0;
  Shape.LocalTransform:=Matrix4x4Translate(0.0,2.5,-0.75);

  Shape:=TKraftShapeBox.Create(KraftPhysics,RigidBody,Vector3(1.0,0.25,0.25));
  Shape.Restitution:=0.3;
  Shape.Density:=1.0;
  Shape.LocalTransform:=Matrix4x4Translate(0.0,3.75,-0.75);

  RigidBody.ForcedMass:=10.0;

  RigidBody.Finish;
  RigidBody.SetWorldTransformation(Matrix4x4Translate(0.0,1.0,-2.0));
  RigidBody.CollisionGroups:=[0];

 end;

 begin
  RigidBody:=TKraftRigidBody.Create(KraftPhysics);
  RigidBody.SetRigidBodyType(krbtDYNAMIC);

  Shape:=TKraftShapeBox.Create(KraftPhysics,RigidBody,Vector3(0.25,1.625,0.25));
  Shape.Restitution:=0.3;
  Shape.Density:=1.0;
  Shape.LocalTransform:=Matrix4x4Translate(-2.75,0.0,1.75);

  Shape:=TKraftShapeBox.Create(KraftPhysics,RigidBody,Vector3(0.25,1.625,0.25));
  Shape.Restitution:=0.3;
  Shape.Density:=1.0;
  Shape.LocalTransform:=Matrix4x4Translate(2.75,0.0,1.75);

  Shape:=TKraftShapeBox.Create(KraftPhysics,RigidBody,Vector3(0.25,1.625,0.25));
  Shape.Restitution:=0.3;
  Shape.Density:=1.0;
  Shape.LocalTransform:=Matrix4x4Translate(-2.75,0.0,-1.75);

  Shape:=TKraftShapeBox.Create(KraftPhysics,RigidBody,Vector3(0.25,1.625,0.25));
  Shape.Restitution:=0.3;
  Shape.Density:=1.0;
  Shape.LocalTransform:=Matrix4x4Translate(2.75,0.0,-1.75);

  Shape:=TKraftShapeBox.Create(KraftPhysics,RigidBody,Vector3(3.0,0.25,2.0));
  Shape.Restitution:=0.3;
  Shape.Density:=1.0;
  Shape.LocalTransform:=Matrix4x4Translate(0.0,1.875,0.0);

  RigidBody.Finish;
  RigidBody.SetWorldTransformation(Matrix4x4Translate(0.0,1.625,0.0));
  RigidBody.CollisionGroups:=[0];

 end;

end;

destructor TDemoSceneChairAndTable.Destroy;
begin
 inherited Destroy;
end;

procedure TDemoSceneChairAndTable.Step(const DeltaTime:double);
begin
end;

initialization
 RegisterDemoScene('Chair and table',TDemoSceneChairAndTable);
end.
