unit UnitDemoSceneCombinedShapes;

{$MODE Delphi}

interface

uses Kraft,UnitDemoScene;

type TDemoSceneCombinedShapes=class(TDemoScene)
      public
       RigidBodyFloor:TKraftRigidBody;
       ShapeFloorPlane:TKraftShapePlane;
       constructor Create(const AKraftPhysics:TKraft); override;
       destructor Destroy; override;
       procedure Step(const DeltaTime:double); override;
     end;

implementation

uses UnitFormMain;

constructor TDemoSceneCombinedShapes.Create(const AKraftPhysics:TKraft);
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

  Shape:=TKraftShapeBox.Create(KraftPhysics,RigidBody,Vector3(1.0,1.0,1.0));
  Shape.Restitution:=0.3;
  Shape.Density:=1.0;
  Shape.LocalTransform:=Matrix4x4Translate(0.0,0.0,0.0);

  Shape:=TKraftShapeBox.Create(KraftPhysics,RigidBody,Vector3(0.5,0.5,0.5));
  Shape.Restitution:=0.3;
  Shape.Density:=1.0;
  Shape.LocalTransform:=Matrix4x4Translate(0.0,1.0,0.0);

  Shape:=TKraftShapeBox.Create(KraftPhysics,RigidBody,Vector3(0.5,0.5,0.5));
  Shape.Restitution:=0.3;
  Shape.Density:=1.0;
  Shape.LocalTransform:=Matrix4x4Translate(0.0,-1.0,0.0);

  Shape:=TKraftShapeBox.Create(KraftPhysics,RigidBody,Vector3(0.5,0.5,0.5));
  Shape.Restitution:=0.3;
  Shape.Density:=1.0;
  Shape.LocalTransform:=Matrix4x4Translate(1.0,0.0,0.0);

  Shape:=TKraftShapeBox.Create(KraftPhysics,RigidBody,Vector3(0.5,0.5,0.5));
  Shape.Restitution:=0.3;
  Shape.Density:=1.0;
  Shape.LocalTransform:=Matrix4x4Translate(-1.0,0.0,0.0);

  Shape:=TKraftShapeBox.Create(KraftPhysics,RigidBody,Vector3(0.5,0.5,0.5));
  Shape.Restitution:=0.3;
  Shape.Density:=1.0;
  Shape.LocalTransform:=Matrix4x4Translate(0.0,0.0,1.0);

  Shape:=TKraftShapeBox.Create(KraftPhysics,RigidBody,Vector3(0.5,0.5,0.5));
  Shape.Restitution:=0.3;
  Shape.Density:=1.0;
  Shape.LocalTransform:=Matrix4x4Translate(0.0,0.0,-1.0);

  Shape:=TKraftShapeSphere.Create(KraftPhysics,RigidBody,0.5);
  Shape.Restitution:=0.3;
  Shape.Density:=1.0;
  Shape.LocalTransform:=Matrix4x4Translate(0.0,1.5,0.0);

  Shape:=TKraftShapeSphere.Create(KraftPhysics,RigidBody,0.5);
  Shape.Restitution:=0.3;
  Shape.Density:=1.0;
  Shape.LocalTransform:=Matrix4x4Translate(0.0,-1.5,0.0);

  Shape:=TKraftShapeSphere.Create(KraftPhysics,RigidBody,0.5);
  Shape.Restitution:=0.3;
  Shape.Density:=1.0;
  Shape.LocalTransform:=Matrix4x4Translate(1.5,0.0,0.0);

  Shape:=TKraftShapeSphere.Create(KraftPhysics,RigidBody,0.5);
  Shape.Restitution:=0.3;
  Shape.Density:=1.0;
  Shape.LocalTransform:=Matrix4x4Translate(-1.5,0.0,0.0);

  Shape:=TKraftShapeSphere.Create(KraftPhysics,RigidBody,0.5);
  Shape.Restitution:=0.3;
  Shape.Density:=1.0;
  Shape.LocalTransform:=Matrix4x4Translate(0.0,0.0,1.5);

  Shape:=TKraftShapeSphere.Create(KraftPhysics,RigidBody,0.5);
  Shape.Restitution:=0.3;
  Shape.Density:=1.0;
  Shape.LocalTransform:=Matrix4x4Translate(0.0,0.0,-1.5);

  RigidBody.Finish;
  RigidBody.SetWorldTransformation(Matrix4x4Translate(-3.0,2.5,0.0));
  RigidBody.CollisionGroups:=[0];

 end;

 begin
  RigidBody:=TKraftRigidBody.Create(KraftPhysics);
  RigidBody.SetRigidBodyType(krbtDYNAMIC);

  Shape:=TKraftShapeSphere.Create(KraftPhysics,RigidBody,1.0);
  Shape.Restitution:=0.3;
  Shape.Density:=1.0;
  Shape.LocalTransform:=Matrix4x4Translate(0.0,0.0,0.0);

  Shape:=TKraftShapeCapsule.Create(KraftPhysics,RigidBody,0.5,3.0);
  Shape.Restitution:=0.3;
  Shape.Density:=1.0;
  Shape.LocalTransform:=Matrix4x4Translate(0.0,0.0,0.0);

  Shape:=TKraftShapeCapsule.Create(KraftPhysics,RigidBody,0.5,3.0);
  Shape.Restitution:=0.3;
  Shape.Density:=1.0;
  Shape.LocalTransform:=Matrix4x4RotateX(0.5*pi);

  Shape:=TKraftShapeCapsule.Create(KraftPhysics,RigidBody,0.5,3.0);
  Shape.Restitution:=0.3;
  Shape.Density:=1.0;
  Shape.LocalTransform:=Matrix4x4RotateZ(0.5*pi);

  Shape:=TKraftShapeCapsule.Create(KraftPhysics,RigidBody,0.25,3.0);
  Shape.Restitution:=0.3;
  Shape.Density:=1.0;
  Shape.LocalTransform:=Matrix4x4RotateX(0.25*pi);

  Shape:=TKraftShapeCapsule.Create(KraftPhysics,RigidBody,0.25,3.0);
  Shape.Restitution:=0.3;
  Shape.Density:=1.0;
  Shape.LocalTransform:=Matrix4x4RotateX(0.75*pi);

  Shape:=TKraftShapeCapsule.Create(KraftPhysics,RigidBody,0.25,3.0);
  Shape.Restitution:=0.3;
  Shape.Density:=1.0;
  Shape.LocalTransform:=Matrix4x4RotateZ(0.25*pi);

  Shape:=TKraftShapeCapsule.Create(KraftPhysics,RigidBody,0.25,3.0);
  Shape.Restitution:=0.3;
  Shape.Density:=1.0;
  Shape.LocalTransform:=Matrix4x4RotateZ(0.75*pi);

  RigidBody.Finish;
  RigidBody.SetWorldTransformation(Matrix4x4Translate(3.0,2.5,0.0));
  RigidBody.CollisionGroups:=[0];

 end;

 begin
  RigidBody:=TKraftRigidBody.Create(KraftPhysics);
  RigidBody.SetRigidBodyType(krbtDYNAMIC);

  Shape:=TKraftShapeCapsule.Create(KraftPhysics,RigidBody,0.25,1.0);
  Shape.Restitution:=0.3;
  Shape.Density:=1.0;
  Shape.LocalTransform:=Matrix4x4TermMul(Matrix4x4RotateZ(0.5*pi),Matrix4x4Translate(0.0,0.0,0.5));

  Shape:=TKraftShapeCapsule.Create(KraftPhysics,RigidBody,0.25,1.0);
  Shape.Restitution:=0.3;
  Shape.Density:=1.0;
  Shape.LocalTransform:=Matrix4x4TermMul(Matrix4x4RotateZ(0.5*pi),Matrix4x4Translate(0.0,0.0,-0.5));

  Shape:=TKraftShapeCapsule.Create(KraftPhysics,RigidBody,0.25,1.0);
  Shape.Restitution:=0.3;
  Shape.Density:=1.0;
  Shape.LocalTransform:=Matrix4x4TermMul(Matrix4x4TermMul(Matrix4x4RotateZ(0.5*pi),Matrix4x4Translate(0.0,0.0,0.5)),Matrix4x4RotateY(0.5*pi));

  Shape:=TKraftShapeCapsule.Create(KraftPhysics,RigidBody,0.25,1.0);
  Shape.Restitution:=0.3;
  Shape.Density:=1.0;
  Shape.LocalTransform:=Matrix4x4TermMul(Matrix4x4TermMul(Matrix4x4RotateZ(0.5*pi),Matrix4x4Translate(0.0,0.0,-0.5)),Matrix4x4RotateY(0.5*pi));

  RigidBody.Finish;
  RigidBody.SetWorldTransformation(Matrix4x4Translate(0.0,1.0,-3.0));
  RigidBody.CollisionGroups:=[0];

 end;

 begin
  RigidBody:=TKraftRigidBody.Create(KraftPhysics);
  RigidBody.SetRigidBodyType(krbtDYNAMIC);

  Shape:=TKraftShapeCapsule.Create(KraftPhysics,RigidBody,0.25,1.5);
  Shape.Restitution:=0.3;
  Shape.Density:=1.0;
  Shape.LocalTransform:=Matrix4x4RotateZ(0.5*pi);

  Shape:=TKraftShapeSphere.Create(KraftPhysics,RigidBody,0.5);
  Shape.Restitution:=0.3;
  Shape.Density:=1.0;
  Shape.LocalTransform:=Matrix4x4Translate(-1.0,0.0,0.0);

  Shape:=TKraftShapeSphere.Create(KraftPhysics,RigidBody,0.5);
  Shape.Restitution:=0.3;
  Shape.Density:=1.0;
  Shape.LocalTransform:=Matrix4x4Translate(1.0,0.0,0.0);

  RigidBody.Finish;
  RigidBody.SetWorldTransformation(Matrix4x4Translate(0.0,1.0,0.0));
  RigidBody.CollisionGroups:=[0];

 end;

 begin
  RigidBody:=TKraftRigidBody.Create(KraftPhysics);
  RigidBody.SetRigidBodyType(krbtDYNAMIC);

  Shape:=TKraftShapeCapsule.Create(KraftPhysics,RigidBody,0.25,3.0);
  Shape.Restitution:=0.3;
  Shape.Density:=0.5;
  Shape.LocalTransform:=Matrix4x4RotateZ(0.5*pi);

  Shape:=TKraftShapeSphere.Create(KraftPhysics,RigidBody,2.0);
  Shape.Restitution:=0.3;
  Shape.Density:=0.5;
  Shape.LocalTransform:=Matrix4x4Translate(-3.0,0.0,0.0);

  Shape:=TKraftShapeSphere.Create(KraftPhysics,RigidBody,2.0);
  Shape.Restitution:=0.3;
  Shape.Density:=1.0;
  Shape.LocalTransform:=Matrix4x4Translate(3.0,0.0,0.0);

  RigidBody.Finish;
  RigidBody.SetWorldTransformation(Matrix4x4Translate(0.0,2.5,-8.0));
  RigidBody.CollisionGroups:=[0];

 end;

 begin
  RigidBody:=TKraftRigidBody.Create(KraftPhysics);
  RigidBody.SetRigidBodyType(krbtDYNAMIC);

  Shape:=TKraftShapeCapsule.Create(KraftPhysics,RigidBody,0.25,3.0);
  Shape.Restitution:=0.3;
  Shape.Density:=0.5;
  Shape.LocalTransform:=Matrix4x4RotateZ(0.5*pi);

  Shape:=TKraftShapeSphere.Create(KraftPhysics,RigidBody,2.0);
  Shape.Restitution:=0.3;
  Shape.Density:=0.5;
  Shape.LocalTransform:=Matrix4x4Translate(-3.0,0.0,0.0);

  Shape:=TKraftShapeSphere.Create(KraftPhysics,RigidBody,2.0);
  Shape.Restitution:=0.3;
  Shape.Density:=1.0;
  Shape.LocalTransform:=Matrix4x4Translate(3.0,0.0,0.0);

  RigidBody.Finish;
  RigidBody.SetWorldTransformation(Matrix4x4Translate(0.0,2.5,-12.0));
  RigidBody.CollisionGroups:=[0];

 end;

 begin
  RigidBody:=TKraftRigidBody.Create(KraftPhysics);
  RigidBody.SetRigidBodyType(krbtDYNAMIC);

  Shape:=TKraftShapeBox.Create(KraftPhysics,RigidBody,Vector3(0.9,0.5,2.75));
  Shape.Friction:=0.8;
  Shape.Restitution:=0.3;
  Shape.Density:=1.0;
  Shape.LocalTransform:=Matrix4x4Translate(0.0,0.75,0.0);

  Shape:=TKraftShapeBox.Create(KraftPhysics,RigidBody,Vector3(0.9,0.5,2.75));
  Shape.Friction:=0.8;
  Shape.Restitution:=0.3;
  Shape.Density:=1.0;
  Shape.LocalTransform:=Matrix4x4Translate(0.0,-0.75,0.0);

  Shape:=TKraftShapeBox.Create(KraftPhysics,RigidBody,Vector3(0.9,1.25,1.75));
  Shape.Friction:=0.8;
  Shape.Restitution:=0.3;
  Shape.Density:=1.0;
  Shape.LocalTransform:=Matrix4x4Translate(0.0,0.0,0.0);

  Shape:=TKraftShapeBox.Create(KraftPhysics,RigidBody,Vector3(0.9,1.25,0.5));
  Shape.Friction:=0.8;
  Shape.Restitution:=0.3;
  Shape.Density:=1.0;
  Shape.LocalTransform:=Matrix4x4Translate(0.0,0.0,2.75);

  Shape:=TKraftShapeBox.Create(KraftPhysics,RigidBody,Vector3(0.9,1.25,0.5));
  Shape.Friction:=0.8;
  Shape.Restitution:=0.3;
  Shape.Density:=1.0;
  Shape.LocalTransform:=Matrix4x4Translate(0.0,0.0,-2.75);

  RigidBody.Finish;
  RigidBody.SetWorldTransformation(Matrix4x4Translate(0.0,2.5,-10.0));
  RigidBody.CollisionGroups:=[0];

 end;

end;

destructor TDemoSceneCombinedShapes.Destroy;
begin
 inherited Destroy;
end;

procedure TDemoSceneCombinedShapes.Step(const DeltaTime:double);
begin
end;

initialization
 RegisterDemoScene('Combined shapes',TDemoSceneCombinedShapes);
end.
