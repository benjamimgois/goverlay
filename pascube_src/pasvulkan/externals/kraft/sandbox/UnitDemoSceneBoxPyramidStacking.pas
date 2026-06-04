unit UnitDemoSceneBoxPyramidStacking;

{$MODE Delphi}

interface

uses Kraft,UnitDemoScene;

type TDemoSceneBoxPyramidStacking=class(TDemoScene)
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

constructor TDemoSceneBoxPyramidStacking.Create(const AKraftPhysics:TKraft);
const Height=10;
var i,j:longint;
begin
 inherited Create(AKraftPhysics);

 RigidBodyFloor:=TKraftRigidBody.Create(KraftPhysics);
 RigidBodyFloor.SetRigidBodyType(krbtSTATIC);
 ShapeFloorPlane:=TKraftShapePlane.Create(KraftPhysics,RigidBodyFloor,Plane(Vector3Norm(Vector3(0.0,1.0,0.0)),0.0));
 ShapeFloorPlane.Restitution:=0.4;
 RigidBodyFloor.Finish;
 RigidBodyFloor.SetWorldTransformation(Matrix4x4Translate(0.0,0.0,0.0));
 RigidBodyFloor.CollisionGroups:=[0];

 for i:=0 to Height-1 do begin
  for j:=0 to i do begin
   RigidBodyBox:=TKraftRigidBody.Create(KraftPhysics);
   RigidBodyBox.SetRigidBodyType(krbtDYNAMIC);
   ShapeBox:=TKraftShapeBox.Create(KraftPhysics,RigidBodyBox,Vector3(0.25,0.25,0.25));
   ShapeBox.Restitution:=0.4;
   ShapeBox.Density:=100.0;
// RigidBodyBox.ForcedMass:=1.0;
   RigidBodyBox.Finish;
   RigidBodyBox.SetWorldTransformation(Matrix4x4Translate((j-(i*0.5))*(ShapeBox.Extents.x*2.05),ShapeBox.Extents.y+((Height-(i+1))*(ShapeBox.Extents.y*2.0)),0.0));
   RigidBodyBox.CollisionGroups:=[0];
  end;
 end;

end;

destructor TDemoSceneBoxPyramidStacking.Destroy;
begin
 inherited Destroy;
end;

procedure TDemoSceneBoxPyramidStacking.Step(const DeltaTime:double);
begin
end;

initialization
 RegisterDemoScene('Box pyramid stacking',TDemoSceneBoxPyramidStacking);
end.
