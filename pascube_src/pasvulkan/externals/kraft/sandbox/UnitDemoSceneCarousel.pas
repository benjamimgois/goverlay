unit UnitDemoSceneCarousel;

{$MODE Delphi}

interface

uses Kraft,UnitDemoScene;

type TDemoSceneCarousel=class(TDemoScene)
      public
       RigidBodyFloor:TKraftRigidBody;
       ShapeFloorPlane:TKraftShapePlane;
       RigidBodyCarouselTopBasis:TKraftRigidBody;
       constructor Create(const AKraftPhysics:TKraft); override;
       destructor Destroy; override;
       procedure Step(const DeltaTime:double); override;
     end;

implementation

uses UnitFormMain;

constructor TDemoSceneCarousel.Create(const AKraftPhysics:TKraft);
const Count=4;
      Spacing=0.125;
      CarouselDownBasisPointsPerCircle=16;
      CarouselDownBasisCircleRadius=1.5;
      CarouselDownBasisHeight=0.5;
      CarouselTopBasisPointsPerCircle=16;
      CarouselTopBasisCircleRadius=3.0;
      CarouselTopBasisHeight=0.25;
      CountChainSpheres=4;
var Index,EdgeIndex,SubIndex:longint;
    RigidBody:array[0..CountChainSpheres-1] of TKraftRigidBody;
    RigidBodySphere:TKraftRigidBody;
    RigidBodySeat:TKraftRigidBody;
    ShapeSphere:TKraftShapeSphere;
    ShapeBox:TKraftShapeBox;
    ShapeCapsule:TKraftShapeCapsule;
    ShapeCarouselDownBasis,ShapeCarouselTopBasis:TKraftShapeConvexHull;
    RigidBodyCarouselDownBasis:TKraftRigidBody;
    ConvexHullCarouselDownBasis,ConvexHullCarouselTopBasis:TKraftConvexHull;
    v:TKraftScalar;
    m:TKraftMatrix4x4;
    vFrom,vTo:TKraftVector3;
begin
 inherited Create(AKraftPhysics);

 RigidBodyFloor:=TKraftRigidBody.Create(KraftPhysics);
 RigidBodyFloor.SetRigidBodyType(krbtSTATIC);
 ShapeFloorPlane:=TKraftShapePlane.Create(KraftPhysics,RigidBodyFloor,Plane(Vector3Norm(Vector3(0.0,1.0,0.0)),0.0));
 ShapeFloorPlane.Restitution:=0.3;
 RigidBodyFloor.Finish;
 RigidBodyFloor.SetWorldTransformation(Matrix4x4Translate(0.0,0.0,0.0));
 RigidBodyFloor.CollisionGroups:=[0];

 RigidBodyCarouselDownBasis:=TKraftRigidBody.Create(KraftPhysics);
 RigidBodyCarouselDownBasis.SetRigidBodyType(krbtSTATIC);
 ConvexHullCarouselDownBasis:=TKraftConvexHull.Create(KraftPhysics);
 ConvexHullGarbageCollector.Add(ConvexHullCarouselDownBasis);
 for Index:=0 to CarouselDownBasisPointsPerCircle-1 do begin
  v:=(Index/CarouselDownBasisPointsPerCircle)*(pi*2.0);
  ConvexHullCarouselDownBasis.AddVertex(Vector3(sin(v)*CarouselDownBasisCircleRadius,-(CarouselDownBasisHeight*0.5),cos(v)*CarouselDownBasisCircleRadius));
  ConvexHullCarouselDownBasis.AddVertex(Vector3(sin(v)*CarouselDownBasisCircleRadius,CarouselDownBasisHeight*0.5,cos(v)*CarouselDownBasisCircleRadius));
 end;
 ConvexHullCarouselDownBasis.Build;
 ConvexHullCarouselDownBasis.Finish;
 ShapeCarouselDownBasis:=TKraftShapeConvexHull.Create(KraftPhysics,RigidBodyCarouselDownBasis,ConvexHullCarouselDownBasis);
 ShapeCarouselDownBasis.Restitution:=0.3;
 ShapeCarouselDownBasis.Density:=1.0;
 ShapeCarouselDownBasis.Finish;
 RigidBodyCarouselDownBasis.Finish;
 RigidBodyCarouselDownBasis.SetWorldTransformation(Matrix4x4Translate(0.0,CarouselDownBasisHeight*0.5,0.0));
 RigidBodyCarouselDownBasis.CollisionGroups:=[0];

 RigidBodyCarouselTopBasis:=TKraftRigidBody.Create(KraftPhysics);
 RigidBodyCarouselTopBasis.SetRigidBodyType(krbtDYNAMIC);
 ConvexHullCarouselTopBasis:=TKraftConvexHull.Create(KraftPhysics);
 ConvexHullGarbageCollector.Add(ConvexHullCarouselTopBasis);
 for Index:=0 to CarouselTopBasisPointsPerCircle-1 do begin
  v:=(Index/CarouselTopBasisPointsPerCircle)*(pi*2.0);
  ConvexHullCarouselTopBasis.AddVertex(Vector3(sin(v)*CarouselTopBasisCircleRadius,-(CarouselTopBasisHeight*0.5),cos(v)*CarouselTopBasisCircleRadius));
  ConvexHullCarouselTopBasis.AddVertex(Vector3(sin(v)*CarouselTopBasisCircleRadius,CarouselTopBasisHeight*0.5,cos(v)*CarouselTopBasisCircleRadius));
 end;
 ConvexHullCarouselTopBasis.Build;
 ConvexHullCarouselTopBasis.Finish;
 ShapeCarouselTopBasis:=TKraftShapeConvexHull.Create(KraftPhysics,RigidBodyCarouselTopBasis,ConvexHullCarouselTopBasis);
 ShapeCarouselTopBasis.Restitution:=0.3;
 ShapeCarouselTopBasis.Density:=1.0;
 ShapeCarouselTopBasis.Friction:=1.0;
 ShapeCarouselTopBasis.Finish;
 ShapeCarouselTopBasis:=TKraftShapeConvexHull.Create(KraftPhysics,RigidBodyCarouselTopBasis,ConvexHullCarouselTopBasis);
 ShapeCarouselTopBasis.Restitution:=0.3;
 ShapeCarouselTopBasis.Density:=1.0;
 ShapeCarouselTopBasis.LocalTransform:=Matrix4x4Translate(0.0,2.75,0.0);
 ShapeCarouselTopBasis.Finish;
 begin
  ShapeCapsule:=TKraftShapeCapsule.Create(KraftPhysics,RigidBodyCarouselTopBasis,0.75,3.0);
  ShapeCapsule.LocalTransform:=Matrix4x4Translate(0.0,1.5,0.0);
  ShapeCapsule.Finish;
 end;
{for Index:=0 to 7 do begin
  v:=(Index/8)*(pi*2.0);
  ShapeBox:=TKraftShapeBox.Create(KraftPhysics,RigidBodyCarouselTopBasis,Vector3(0.015625,1.5,0.125));
  ShapeBox.LocalTransform:=Matrix4x4TermMul(Matrix4x4Translate(CarouselTopBasisCircleRadius-0.25,1.5,0.0),Matrix4x4RotateY(v));
  ShapeBox.Finish;
 end;{}
 RigidBodyCarouselTopBasis.ForcedMass:=100.0;
 RigidBodyCarouselTopBasis.Finish;
 RigidBodyCarouselTopBasis.SetWorldTransformation(Matrix4x4Translate(0.0,CarouselDownBasisHeight+(CarouselTopBasisHeight*0.5),0.0));
 RigidBodyCarouselTopBasis.CollisionGroups:=[0];

 TKraftConstraintJointHinge.Create(KraftPhysics,RigidBodyCarouselDownBasis,RigidBodyCarouselTopBasis,Vector3(0.0,CarouselDownBasisHeight,0.0),Vector3(0.0,1.0,0.0));

 for Index:=0 to 7 do begin
  v:=(Index/8)*(pi*2.0);
  RigidBodySeat:=TKraftRigidBody.Create(KraftPhysics);
  RigidBodySeat.SetRigidBodyType(krbtDYNAMIC);
  ShapeBox:=TKraftShapeBox.Create(KraftPhysics,RigidBodySeat,Vector3(0.25,0.0625,0.25));
  ShapeBox.Finish;
  ShapeBox:=TKraftShapeBox.Create(KraftPhysics,RigidBodySeat,Vector3(0.0625,0.25,0.25));
  ShapeBox.LocalTransform:=Matrix4x4Translate(0.0625-0.25,0.0625+0.25,0.0);
  ShapeBox.Finish;
  ShapeBox:=TKraftShapeBox.Create(KraftPhysics,RigidBodySeat,Vector3(0.25,0.0625,0.03125));
  ShapeBox.LocalTransform:=Matrix4x4Translate(0.0,0.0625+0.0625,0.03125-0.25);
  ShapeBox.Finish;
  ShapeBox:=TKraftShapeBox.Create(KraftPhysics,RigidBodySeat,Vector3(0.25,0.0625,0.03125));
  ShapeBox.LocalTransform:=Matrix4x4Translate(0.0,0.0625+0.0625,-(0.03125-0.25));
  ShapeBox.Finish;
  RigidBodySeat.ForcedMass:=5.0;
  RigidBodySeat.Finish;
  m:=Matrix4x4TermMul(Matrix4x4Translate(0.0,CarouselDownBasisHeight+CarouselTopBasisHeight+0.5,CarouselTopBasisCircleRadius-1.0),Matrix4x4RotateY(v));
  RigidBodySeat.SetWorldTransformation(m);
  for EdgeIndex:=0 to 3 do begin
   case EdgeIndex of
    0:begin
     vFrom:=Vector3TermMatrixMul(Vector3(0.25,2.0,0.25),m);
     vTo:=Vector3TermMatrixMul(Vector3(0.25,0.5,0.25),m);
    end;
    1:begin
     vFrom:=Vector3TermMatrixMul(Vector3(-0.25,2.0,0.25),m);
     vTo:=Vector3TermMatrixMul(Vector3(-0.25,0.5,0.25),m);
    end;
    2:begin
     vFrom:=Vector3TermMatrixMul(Vector3(-0.25,2.0,-0.25),m);
     vTo:=Vector3TermMatrixMul(Vector3(-0.25,0.5,-0.25),m);
    end;
    else begin
     vFrom:=Vector3TermMatrixMul(Vector3(0.25,2.0,-0.25),m);
     vTo:=Vector3TermMatrixMul(Vector3(0.25,0.5,-0.25),m);
    end;
   end;
   for SubIndex:=0 to CountChainSpheres-1 do begin
    RigidBody[SubIndex]:=TKraftRigidBody.Create(KraftPhysics);
    RigidBody[SubIndex].SetRigidBodyType(krbtDYNAMIC);
    ShapeSphere:=TKraftShapeSphere.Create(KraftPhysics,RigidBody[SubIndex],0.1);
    ShapeSphere.Restitution:=0.3;
    ShapeSphere.Density:=1.0;
    RigidBody[SubIndex].Finish;
    RigidBody[SubIndex].SetWorldTransformation(Matrix4x4Translate(Vector3Lerp(vTo,vFrom,SubIndex/CountChainSpheres)));
    RigidBody[SubIndex].CollisionGroups:=[0];
   end;
   for SubIndex:=1 to CountChainSpheres-1 do begin
    TKraftConstraintJointBallSocket.Create(KraftPhysics,RigidBody[SubIndex-1],RigidBody[SubIndex],Vector3Lerp(PKraftVector3(pointer(@RigidBody[SubIndex].WorldTransform[3,0]))^,PKraftVector3(pointer(@RigidBody[SubIndex-1].WorldTransform[3,0]))^,0.5),true);
   end;
   TKraftConstraintJointBallSocket.Create(KraftPhysics,RigidBodyCarouselTopBasis,RigidBody[CountChainSpheres-1],vFrom,true);
   TKraftConstraintJointBallSocket.Create(KraftPhysics,RigidBodySeat,RigidBody[0],vTo,false);
  end;
  RigidBodySeat.CollisionGroups:=[0];
 end;

end;

destructor TDemoSceneCarousel.Destroy;
begin
 inherited Destroy;
end;

procedure TDemoSceneCarousel.Step(const DeltaTime:double);
begin
 RigidBodyCarouselTopBasis.SetBodyTorque(Vector3(0.0,1.25,0.0),kfmAcceleration);
end;

initialization
 RegisterDemoScene('Carousel',TDemoSceneCarousel);
end.

