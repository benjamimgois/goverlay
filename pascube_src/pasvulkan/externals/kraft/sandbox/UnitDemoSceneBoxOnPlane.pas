unit UnitDemoSceneBoxOnPlane;

{$MODE Delphi}

interface

uses Kraft,UnitDemoScene;

type TDemoSceneBoxOnPlane=class(TDemoScene)
      public
       RigidBodyFloor:TKraftRigidBody;
       ShapeFloorPlane:TKraftShapePlane;
       RigidBodyBox:TKraftRigidBody;
       ShapeBox:TKraftShapeBox;
       constructor Create(const AKraftPhysics:TKraft); override;
       destructor Destroy; override;
       procedure Step(const DeltaTime:double); override;
     end;

implementation

uses UnitFormMain;

constructor TDemoSceneBoxOnPlane.Create(const AKraftPhysics:TKraft); 
begin
 inherited Create(AKraftPhysics);

 RigidBodyFloor:=TKraftRigidBody.Create(KraftPhysics);
 RigidBodyFloor.SetRigidBodyType(krbtSTATIC);
 ShapeFloorPlane:=TKraftShapePlane.Create(KraftPhysics,RigidBodyFloor,Plane(Vector3Norm(Vector3(0.0,1.0,0.0)),0.0));
 ShapeFloorPlane.Restitution:=0.3;
 RigidBodyFloor.Finish;
 RigidBodyFloor.SetWorldTransformation(Matrix4x4Translate(0.0,0.0,0.0));
 RigidBodyFloor.CollisionGroups:=[0];

 RigidBodyBox:=TKraftRigidBody.Create(KraftPhysics);
 RigidBodyBox.SetRigidBodyType(krbtDYNAMIC);
 ShapeBox:=TKraftShapeBox.Create(KraftPhysics,RigidBodyBox,Vector3(1.0,1.0,1.0));
 ShapeBox.Restitution:=0.3;
 ShapeBox.Density:=100.0;
 RigidBodyBox.Finish;
 RigidBodyBox.SetWorldTransformation(Matrix4x4Translate(0.0,8.0,0.0));
 RigidBodyBox.CollisionGroups:=[0];

end;

destructor TDemoSceneBoxOnPlane.Destroy;
begin
 inherited Destroy;
end;

procedure TDemoSceneBoxOnPlane.Step(const DeltaTime:double);
begin
end;

initialization
 RegisterDemoScene('Box on plane',TDemoSceneBoxOnPlane);
end.
