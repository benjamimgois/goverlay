unit UnitDemoSceneBoxStacking;

{$MODE Delphi}

interface

uses Kraft,UnitDemoScene;

type TDemoSceneBoxStacking=class(TDemoScene)
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

constructor TDemoSceneBoxStacking.Create(const AKraftPhysics:TKraft);
var i:longint;
begin
 inherited Create(AKraftPhysics);

 RigidBodyFloor:=TKraftRigidBody.Create(KraftPhysics);
 RigidBodyFloor.SetRigidBodyType(krbtSTATIC);
 ShapeFloorPlane:=TKraftShapePlane.Create(KraftPhysics,RigidBodyFloor,Plane(Vector3Norm(Vector3(0.0,1.0,0.0)),0.0));
 ShapeFloorPlane.Restitution:=0.4;
 RigidBodyFloor.Finish;
 RigidBodyFloor.SetWorldTransformation(Matrix4x4Translate(0.0,0.0,0.0));
 RigidBodyFloor.CollisionGroups:=[0];

 for i:=0 to 9 do begin
  RigidBodyBox:=TKraftRigidBody.Create(KraftPhysics);
  RigidBodyBox.SetRigidBodyType(krbtDYNAMIC);
  ShapeBox:=TKraftShapeBox.Create(KraftPhysics,RigidBodyBox,Vector3(0.25,0.25,0.25));
  ShapeBox.Restitution:=0.4;
  ShapeBox.Density:=100.0;
  RigidBodyBox.Finish;
  RigidBodyBox.SetWorldTransformation(Matrix4x4Translate(0.0,ShapeBox.Extents.y+(i*(ShapeBox.Extents.y*2.0)),0.0));
  RigidBodyBox.CollisionGroups:=[0];
 end;

end;

destructor TDemoSceneBoxStacking.Destroy;
begin
 inherited Destroy;
end;

procedure TDemoSceneBoxStacking.Step(const DeltaTime:double);
begin
end;

initialization
 RegisterDemoScene('Box stacking',TDemoSceneBoxStacking);
end.
