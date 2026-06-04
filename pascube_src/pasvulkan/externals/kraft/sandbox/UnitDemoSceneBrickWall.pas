unit UnitDemoSceneBrickWall;

{$MODE Delphi}

interface

uses Kraft,UnitDemoScene;

type TDemoSceneBrickWall=class(TDemoScene)
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

constructor TDemoSceneBrickWall.Create(const AKraftPhysics:TKraft);
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
  for j:=0 to Height-1 do begin
   if (i+j)>0 then begin
    RigidBodyBox:=TKraftRigidBody.Create(KraftPhysics);
    RigidBodyBox.SetRigidBodyType(krbtDYNAMIC);
    ShapeBox:=TKraftShapeBox.Create(KraftPhysics,RigidBodyBox,Vector3(1.0,0.5,0.25));
    ShapeBox.Restitution:=0.4;
    ShapeBox.Density:=10.0;
 // RigidBodyBox.ForcedMass:=1.0;
    RigidBodyBox.Finish;
    RigidBodyBox.SetWorldTransformation(Matrix4x4Translate(((j+((i and 1)*0.5))-(Height*0.5))*(ShapeBox.Extents.x*2.0),ShapeBox.Extents.y+((Height-(i+1))*(ShapeBox.Extents.y*2.0)),-8.0));
    RigidBodyBox.CollisionGroups:=[0];
    RigidBodyBox.SetToSleep;
   end;
  end;
 end;

end;

destructor TDemoSceneBrickWall.Destroy;
begin
 inherited Destroy;
end;

procedure TDemoSceneBrickWall.Step(const DeltaTime:double);
begin
end;

initialization
 RegisterDemoScene('Brick wall',TDemoSceneBrickWall);
end.
