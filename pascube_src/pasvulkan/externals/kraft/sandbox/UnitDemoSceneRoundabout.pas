unit UnitDemoSceneRoundabout;

{$MODE Delphi}

interface

uses Kraft,UnitDemoScene;

type TDemoSceneRoundabout=class(TDemoScene)
      public
       RigidBodyFloor:TKraftRigidBody;
       ShapeFloorPlane:TKraftShapePlane;
       constructor Create(const AKraftPhysics:TKraft); override;
       destructor Destroy; override;
       procedure Step(const DeltaTime:double); override;
     end;

implementation

uses UnitFormMain;

constructor TDemoSceneRoundabout.Create(const AKraftPhysics:TKraft);
const Count=4;
      Spacing=0.125;
      RoundaboutDownBasisPointsPerCircle=16;
      RoundaboutDownBasisCircleRadius=1.0;
      RoundaboutDownBasisHeight=0.5;
      RoundaboutTopBasisPointsPerCircle=16;
      RoundaboutTopBasisCircleRadius=2.0;
      RoundaboutTopBasisHeight=0.25;
var Index:longint;
    RigidBodySphere:TKraftRigidBody;
    ShapeSphere:TKraftShapeSphere;
    ShapeBox:TKraftShapeBox;
    ShapeRoundaboutDownBasis,ShapeRoundaboutTopBasis:TKraftShapeConvexHull;
    RigidBodyRoundaboutDownBasis,RigidBodyRoundaboutTopBasis:TKraftRigidBody;
    ConvexHullRoundaboutDownBasis,ConvexHullRoundaboutTopBasis:TKraftConvexHull;
    v:TKraftScalar;
begin
 inherited Create(AKraftPhysics);

 RigidBodyFloor:=TKraftRigidBody.Create(KraftPhysics);
 RigidBodyFloor.SetRigidBodyType(krbtSTATIC);
 ShapeFloorPlane:=TKraftShapePlane.Create(KraftPhysics,RigidBodyFloor,Plane(Vector3Norm(Vector3(0.0,1.0,0.0)),0.0));
 ShapeFloorPlane.Restitution:=0.3;
 RigidBodyFloor.Finish;
 RigidBodyFloor.SetWorldTransformation(Matrix4x4Translate(0.0,0.0,0.0));
 RigidBodyFloor.CollisionGroups:=[0];

 RigidBodyRoundaboutDownBasis:=TKraftRigidBody.Create(KraftPhysics);
 RigidBodyRoundaboutDownBasis.SetRigidBodyType(krbtSTATIC);
 ConvexHullRoundaboutDownBasis:=TKraftConvexHull.Create(KraftPhysics);
 ConvexHullGarbageCollector.Add(ConvexHullRoundaboutDownBasis);
 for Index:=0 to RoundaboutDownBasisPointsPerCircle-1 do begin
  v:=(Index/RoundaboutDownBasisPointsPerCircle)*(pi*2.0);
  ConvexHullRoundaboutDownBasis.AddVertex(Vector3(sin(v)*RoundaboutDownBasisCircleRadius,-(RoundaboutDownBasisHeight*0.5),cos(v)*RoundaboutDownBasisCircleRadius));
  ConvexHullRoundaboutDownBasis.AddVertex(Vector3(sin(v)*RoundaboutDownBasisCircleRadius,RoundaboutDownBasisHeight*0.5,cos(v)*RoundaboutDownBasisCircleRadius));
 end;
 ConvexHullRoundaboutDownBasis.Build;
 ConvexHullRoundaboutDownBasis.Finish;
 ShapeRoundaboutDownBasis:=TKraftShapeConvexHull.Create(KraftPhysics,RigidBodyRoundaboutDownBasis,ConvexHullRoundaboutDownBasis);
 ShapeRoundaboutDownBasis.Restitution:=0.3;
 ShapeRoundaboutDownBasis.Density:=1.0;
 RigidBodyRoundaboutDownBasis.Finish;
 RigidBodyRoundaboutDownBasis.SetWorldTransformation(Matrix4x4Translate(0.0,RoundaboutDownBasisHeight*0.5,0.0));
 RigidBodyRoundaboutDownBasis.CollisionGroups:=[0];

 RigidBodyRoundaboutTopBasis:=TKraftRigidBody.Create(KraftPhysics);
 RigidBodyRoundaboutTopBasis.SetRigidBodyType(krbtDYNAMIC);
 ConvexHullRoundaboutTopBasis:=TKraftConvexHull.Create(KraftPhysics);
 ConvexHullGarbageCollector.Add(ConvexHullRoundaboutTopBasis);
 for Index:=0 to RoundaboutTopBasisPointsPerCircle-1 do begin
  v:=(Index/RoundaboutTopBasisPointsPerCircle)*(pi*2.0);
  ConvexHullRoundaboutTopBasis.AddVertex(Vector3(sin(v)*RoundaboutTopBasisCircleRadius,-(RoundaboutTopBasisHeight*0.5),cos(v)*RoundaboutTopBasisCircleRadius));
  ConvexHullRoundaboutTopBasis.AddVertex(Vector3(sin(v)*RoundaboutTopBasisCircleRadius,RoundaboutTopBasisHeight*0.5,cos(v)*RoundaboutTopBasisCircleRadius));
 end;
 ConvexHullRoundaboutTopBasis.Build;
 ConvexHullRoundaboutTopBasis.Finish;
 ShapeRoundaboutTopBasis:=TKraftShapeConvexHull.Create(KraftPhysics,RigidBodyRoundaboutTopBasis,ConvexHullRoundaboutTopBasis);
 ShapeRoundaboutTopBasis.Restitution:=0.3;
 ShapeRoundaboutTopBasis.Density:=1.0;
 begin
  ShapeBox:=TKraftShapeBox.Create(KraftPhysics,RigidBodyRoundaboutTopBasis,Vector3(0.125,0.5,0.125));
  ShapeBox.LocalTransform:=Matrix4x4Translate(0.0,0.5,0.0);
  ShapeBox.Finish;
 end;
 for Index:=0 to 7 do begin
  v:=(Index/8)*(pi*2.0);
  ShapeBox:=TKraftShapeBox.Create(KraftPhysics,RigidBodyRoundaboutTopBasis,Vector3(0.125,0.5,0.5));
  ShapeBox.LocalTransform:=Matrix4x4TermMul(Matrix4x4Translate(RoundaboutTopBasisCircleRadius-0.25,0.5,0.0),Matrix4x4RotateY(v));
  ShapeBox.Finish;
 end;
 RigidBodyRoundaboutTopBasis.Finish;
 RigidBodyRoundaboutTopBasis.SetWorldTransformation(Matrix4x4Translate(0.0,RoundaboutDownBasisHeight+(RoundaboutTopBasisHeight*0.5),0.0));
 RigidBodyRoundaboutTopBasis.CollisionGroups:=[0];

 TKraftConstraintJointHinge.Create(KraftPhysics,RigidBodyRoundaboutDownBasis,RigidBodyRoundaboutTopBasis,Vector3(0.0,RoundaboutDownBasisHeight,0.0),Vector3(0.0,1.0,0.0));

 RigidBodySphere:=TKraftRigidBody.Create(KraftPhysics);
 RigidBodySphere.SetRigidBodyType(krbtDYNAMIC);
 ShapeSphere:=TKraftShapeSphere.Create(KraftPhysics,RigidBodySphere,0.5);
 ShapeSphere.Finish;
 RigidBodySphere.Finish;
 RigidBodySphere.SetWorldTransformation(Matrix4x4Translate(0.0,RoundaboutDownBasisHeight+RoundaboutTopBasisHeight+0.5,RoundaboutTopBasisCircleRadius-0.5));
 RigidBodySphere.CollisionGroups:=[0];

 RigidBodyRoundaboutTopBasis.AddBodyTorque(Vector3(0.0,3000.0,0.0));

end;

destructor TDemoSceneRoundabout.Destroy;
begin
 inherited Destroy;
end;

procedure TDemoSceneRoundabout.Step(const DeltaTime:double);
begin
end;

initialization
 RegisterDemoScene('Roundabout',TDemoSceneRoundabout);
end.

