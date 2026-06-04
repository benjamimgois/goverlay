unit UnitDemoSceneConvexHull;

{$MODE Delphi}

interface

uses Kraft,UnitDemoScene;

type TDemoSceneConvexHull=class(TDemoScene)
      public
       RigidBodyFloor:TKraftRigidBody;
       ShapeFloorPlane:TKraftShapePlane;
       constructor Create(const AKraftPhysics:TKraft); override;
       destructor Destroy; override;
       procedure Step(const DeltaTime:double); override;
     end;

implementation

uses UnitFormMain;

const ConvexHullPoints:array[0..5] of TKraftVector3=((x:-2.0;y:1.0;z:1.0{$if KraftSIMD};w:0.0{$ifend}),
                                                     (x:2.0;y:0.0;z:0.0{$if KraftSIMD};w:0.0{$ifend}),
                                                     (x:1.0;y:-2.0;z:1.0{$if KraftSIMD};w:0.0{$ifend}),
                                                     (x:0.0;y:2.0;z:0.0{$if KraftSIMD};w:0.0{$ifend}),
                                                     (x:1.0;y:1.0;z:-2.0{$if KraftSIMD};w:0.0{$ifend}),
                                                     (x:0.0;y:0.0;z:2.0{$if KraftSIMD};w:0.0{$ifend}));{}

constructor TDemoSceneConvexHull.Create(const AKraftPhysics:TKraft);
var RigidBody:TKraftRigidBody;
    Shape:TKraftShape;
    ConvexHull:TKraftConvexHull;
begin
 inherited Create(AKraftPhysics);

 RigidBodyFloor:=TKraftRigidBody.Create(KraftPhysics);
 RigidBodyFloor.SetRigidBodyType(krbtSTATIC);
 ShapeFloorPlane:=TKraftShapePlane.Create(KraftPhysics,RigidBodyFloor,Plane(Vector3Norm(Vector3(0.0,1.0,0.0)),0.0));
 ShapeFloorPlane.Restitution:=0.3;
 RigidBodyFloor.Finish;
 RigidBodyFloor.SetWorldTransformation(Matrix4x4Translate(0.0,0.0,0.0));
 RigidBodyFloor.CollisionGroups:=[0];

 RigidBody:=TKraftRigidBody.Create(KraftPhysics);
 RigidBody.SetRigidBodyType(krbtDYNAMIC);
 ConvexHull:=TKraftConvexHull.Create(KraftPhysics);
 ConvexHullGarbageCollector.Add(ConvexHull);
 ConvexHull.Load(pointer(@ConvexHullPoints),length(ConvexHullPoints));
 ConvexHull.Build;
 ConvexHull.Finish;
 Shape:=TKraftShapeConvexHull.Create(KraftPhysics,RigidBody,ConvexHull);
 Shape.Restitution:=0.3;
 Shape.Density:=1.0;
 RigidBody.Finish;
 RigidBody.SetWorldTransformation(Matrix4x4TermMul(Matrix4x4RotateZ(pi*0.25),Matrix4x4Translate(0.0,4.0,0.0)));
 RigidBody.CollisionGroups:=[0];

end;

destructor TDemoSceneConvexHull.Destroy;
begin
 inherited Destroy;
end;

procedure TDemoSceneConvexHull.Step(const DeltaTime:double);
begin
end;

initialization
 RegisterDemoScene('Convex hull',TDemoSceneConvexHull);
end.
