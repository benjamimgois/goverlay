unit UnitDemoSceneChain;

{$MODE Delphi}

interface

uses Kraft,UnitDemoScene;

type TDemoSceneChain=class(TDemoScene)
      public
       RigidBodyFloor:TKraftRigidBody;
       ShapeFloorPlane:TKraftShapePlane;
       constructor Create(const AKraftPhysics:TKraft); override;
       destructor Destroy; override;
       procedure Step(const DeltaTime:double); override;
     end;

implementation

uses UnitFormMain;

constructor TDemoSceneChain.Create(const AKraftPhysics:TKraft);
const Count=11;
      Spacing=0.125;
var Index:longint;
    RigidBody:array[0..Count-1] of TKraftRigidBody;
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

 for Index:=0 to Count-1 do begin
  RigidBody[Index]:=TKraftRigidBody.Create(KraftPhysics);
  if (Index=0) or (Index=(Count-1)) then begin
   RigidBody[Index].SetRigidBodyType(krbtSTATIC);
  end else begin
   RigidBody[Index].SetRigidBodyType(krbtDYNAMIC);
  end;
  Shape:=TKraftShapeSphere.Create(KraftPhysics,RigidBody[Index],1.0);
  Shape.Restitution:=0.3;
  Shape.Density:=1.0;
  RigidBody[Index].Finish;
  RigidBody[Index].SetWorldTransformation(Matrix4x4Translate((Index-((Count-1)*0.5))*2.25,7.0,-4.0));
  RigidBody[Index].CollisionGroups:=[0];
 end;

 for Index:=1 to Count-1 do begin

  // This is the most cheap way to construct a chain
  TKraftConstraintJointBallSocket.Create(KraftPhysics,RigidBody[Index-1],RigidBody[Index],Vector3(1.25,0.0,0.0),Vector3(-1.25,0.0,0.0),true);

{ // This is a better way to construct a chain, but attention:
  // TKraftConstraintJointDistance needs soft constraint damping and frequency constants fine tuning and a comparably high world update frequency,
  // but the soft constraint frequency must be smaller than the half of the world update frequency, because of the Nyquist theorem.
  TKraftConstraintJointDistance.Create(KraftPhysics,RigidBody[Index-1],RigidBody[Index],Vector3(1.0,0.0,0.0),Vector3(-1.0,0.0,0.0),10.0,1.0,true);
{}

{ // This is also a better way to construct a chain, but attention:
  // TKraftConstraintJointRope needs high counts of velocity and position iterations at a so such long chain, for to being stable!
  TKraftConstraintJointRope.Create(KraftPhysics,RigidBody[Index-1],RigidBody[Index],Vector3(1.0,0.0,0.0),Vector3(-1.0,0.0,0.0),0.5,true);
{}

 end;

end;

destructor TDemoSceneChain.Destroy;
begin
 inherited Destroy;
end;

procedure TDemoSceneChain.Step(const DeltaTime:double);
begin
end;

initialization
 RegisterDemoScene('Chain',TDemoSceneChain);
end.
