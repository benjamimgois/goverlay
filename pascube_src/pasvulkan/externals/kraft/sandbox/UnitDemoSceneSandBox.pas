unit UnitDemoSceneSandBox;

{$MODE Delphi}

{$j+}

interface

uses Kraft,UnitDemoScene;

type TDemoSceneSandBox=class(TDemoScene)
      public
       RigidBody:TKraftRigidBody;

       RagdollOffset:TKraftMatrix4x4;

       RigidBodyFloor:TKraftRigidBody;
   //  ShapeFloorBoxes:array[0..5] of TKraftShapeBox;
       ShapeFloorPlane:TKraftShapePlane;

       RigidBodyMesh:TKraftRigidBody;
       Mesh:TKraftMesh;
       ShapeMesh:TKraftShapeMesh;

       ConvexHull:TKraftConvexHull;

       ObjectRigidBody:array[0..18] of TKraftRigidBody;
       ObjectShape:array[0..19] of TKraftShape;

       pp:array[0..4,0..1] of TKraftVector3;
   //  WorldPlaneDistanceConstraints:array[0..4] of TKraftConstraintJointWorldPlaneDistance;
    
       RopeConstraints:array[0..3] of TKraftConstraint;

       HingeConstraints:array[0..3] of TKraftConstraint;

       SliderConstraints:array[0..3] of TKraftConstraint;

       RagdollRigidBody:array[0..1+2+2+5] of TKraftRigidBody;
       RagdollShape:array[0..1+2+2+5] of TKraftShape;
       RagdollConstraints:array[0..9] of TKraftConstraint;

       constructor Create(const AKraftPhysics:TKraft); override;
       destructor Destroy; override;
       procedure Step(const DeltaTime:double); override;
     end;

implementation

uses UnitFormMain,sandboxfile;

const ConvexHullPoints:array[0..5] of TKraftVector3=((x:-2.0;y:1.0;z:1.0{$if KraftSIMD};w:0.0{$ifend}),
                                                     (x:2.0;y:0.0;z:0.0{$if KraftSIMD};w:0.0{$ifend}),
                                                     (x:1.0;y:-2.0;z:1.0{$if KraftSIMD};w:0.0{$ifend}),
                                                     (x:0.0;y:2.0;z:0.0{$if KraftSIMD};w:0.0{$ifend}),
                                                     (x:1.0;y:1.0;z:-2.0{$if KraftSIMD};w:0.0{$ifend}),
                                                     (x:0.0;y:0.0;z:2.0{$if KraftSIMD};w:0.0{$ifend}));{}

constructor TDemoSceneSandBox.Create(const AKraftPhysics:TKraft);
const ScaleRagDoll=4.0;
      BODYPART_PELVIS=0;
      BODYPART_SPINE=1;
      BODYPART_HEAD=2;
      BODYPART_LEFT_UPPER_LEG=3;
      BODYPART_LEFT_LOWER_LEG=4;
      BODYPART_RIGHT_UPPER_LEG=5;
      BODYPART_RIGHT_LOWER_LEG=6;
      BODYPART_LEFT_UPPER_ARM=7;
      BODYPART_LEFT_LOWER_ARM=8;
      BODYPART_RIGHT_UPPER_ARM=9;
      BODYPART_RIGHT_LOWER_ARM=10;
      BODY_BASE_X=-16.0;
      BODY_BASE_Y=6.0;
      BODY_BASE_Z=2.0;
begin
 inherited Create(AKraftPhysics);

 RigidBodyFloor:=TKraftRigidBody.Create(KraftPhysics);
 RigidBodyFloor.SetRigidBodyType(krbtSTATIC);
 ShapeFloorPlane:=TKraftShapePlane.Create(KraftPhysics,RigidBodyFloor,Plane(Vector3Norm(Vector3(0.0,1.0,0.0)),0.0));
{ShapeFloorBoxes[0]:=TKraftShapeBox.Create(KraftPhysics,RigidBodyFloor,Vector3(50.0,25.0,50.0));
 ShapeFloorBoxes[0].LocalTransform:=Matrix4x4Translate(0.0,-25.0,0.0);
 ShapeFloorBoxes[0].Friction:=0.4;
 ShapeFloorBoxes[0].Restitution:=0.2;
 ShapeFloorBoxes[1]:=TKraftShapeBox.Create(KraftPhysics,RigidBodyFloor,Vector3(50.0,25.0,50.0));
 ShapeFloorBoxes[1].LocalTransform:=Matrix4x4Translate(0.0,50.0,0.0);
 ShapeFloorBoxes[2]:=TKraftShapeBox.Create(KraftPhysics,RigidBodyFloor,Vector3(50.0,50.0,25.0));
 ShapeFloorBoxes[2].LocalTransform:=Matrix4x4Translate(0.0,25.0,50.0);
 ShapeFloorBoxes[3]:=TKraftShapeBox.Create(KraftPhysics,RigidBodyFloor,Vector3(50.0,50.0,25.0));
 ShapeFloorBoxes[3].LocalTransform:=Matrix4x4Translate(0.0,25.0,-50.0);
 ShapeFloorBoxes[4]:=TKraftShapeBox.Create(KraftPhysics,RigidBodyFloor,Vector3(25.0,50.0,50.0));
 ShapeFloorBoxes[4].LocalTransform:=Matrix4x4Translate(50.0,25.0,0);
 ShapeFloorBoxes[5]:=TKraftShapeBox.Create(KraftPhysics,RigidBodyFloor,Vector3(25.0,50.0,50.0));
 ShapeFloorBoxes[5].LocalTransform:=Matrix4x4Translate(-50.0,25.0,0);}
 RigidBodyFloor.Finish;
 RigidBodyFloor.SetWorldTransformation(Matrix4x4Translate(0.0,-8.0,0.0));
 RigidBodyFloor.CollisionGroups:=[0];

 RigidBodyMesh:=TKraftRigidBody.Create(KraftPhysics);
 RigidBodyMesh.SetRigidBodyType(krbtSTATIC);
 Mesh:=TKraftMesh.Create(KraftPhysics);
 MeshGarbageCollector.Add(Mesh);
 Mesh.Load(@sandboxData,sandboxSize);
 Mesh.Scale(0.1);
 Mesh.Finish;
 ShapeMesh:=TKraftShapeMesh.Create(KraftPhysics,RigidBodyMesh,Mesh);
 ShapeMesh.Friction:=0.5;
 ShapeMesh.Restitution:=0.0;
 ShapeMesh.Density:=1.0;
 ShapeMesh.Finish;
 RigidBodyMesh.Finish;
 RigidBodyMesh.SetWorldTransformation(Matrix4x4Translate(0.0,-4.0,0.0));
 RigidBodyMesh.CollisionGroups:=[0];{}

{ObjectRigidBody[5]:=TKraftRigidBody.Create(KraftPhysics);
 ObjectRigidBody[5].SetRigidBodyType(krbtDYNAMIC);
 ObjectShape[5]:=TKraftShapeSphere.Create(KraftPhysics,ObjectRigidBody[5],1.0);
//ObjectShape[5]:=TKraftShapeTriangle.Create(KraftPhysics,ObjectRigidBody[5],Vector3(15.0,0.0,-8.0),Vector3(-15.0,0.0,-8.0),Vector3(-15.0,15.0,-8.0));
 ObjectShape[5].Friction:=0.4;
 ObjectShape[5].Restitution:=0.2;
 ObjectShape[5].Density:=1.0;
/// ObjectRigidBody[5].ForcedMass:=1.0;
 ObjectRigidBody[5].Finish;
// ObjectRigidBody[5].SetWorldTransformation(Matrix4x4Translate(-37.3,24.0,-36.0));
// ObjectRigidBody[5].SetWorldTransformation(Matrix4x4Translate(-35.0,30.0,-26.0));
 ObjectRigidBody[5].SetWorldTransformation(Matrix4x4Translate(-35.0,30.0,-25.0));
 ObjectRigidBody[5].SetToAwake;{}

(**)
 ObjectRigidBody[0]:=TKraftRigidBody.Create(KraftPhysics);
 ObjectRigidBody[0].SetRigidBodyType(krbtDYNAMIC);
 ObjectShape[0]:=TKraftShapeSphere.Create(KraftPhysics,ObjectRigidBody[0],3.0);
//ObjectShape[0]:=TKraftShapeSphere.Create(KraftPhysics,ObjectRigidBody[0],5.0);
 //ObjectShape:=TKraftShapeBox.Create(KraftPhysics,ObjectRigidBody,Vector3(5.0,5.0,5.0));
 ObjectShape[0].Friction:=0.4;
 ObjectShape[0].Restitution:=0.2;
 ObjectShape[0].Density:=1.0;
 //ObjectRigidBody.ForcedMass:=1.0;
 ObjectRigidBody[0].Finish;
 ObjectRigidBody[0].SetWorldTransformation(Matrix4x4Translate(10.0,5.0,5.0));
 ObjectRigidBody[0].AngularVelocity:=Vector3Origin;
 ObjectRigidBody[0].SetToAwake;

 ObjectRigidBody[1]:=TKraftRigidBody.Create(KraftPhysics);
 ObjectRigidBody[1].SetRigidBodyType(krbtDYNAMIC);
// ObjectShape[2]:=TKraftShapeSphere.Create(KraftPhysics,ObjectRigidBody[1],1.0);
 ObjectShape[1]:=TKraftShapeBox.Create(KraftPhysics,ObjectRigidBody[1],Vector3(1.0,1.0,1.0));
 ObjectShape[1].Friction:=0.4;
 ObjectShape[1].Restitution:=0.5;
 ObjectShape[1].Density:=1.0;
 //ObjectRigidBody[1].ForcedMass:=1;
 ObjectRigidBody[1].Finish;
 ObjectRigidBody[1].SetWorldTransformation(Matrix4x4Translate(4.0,4.0,-1.0));
// ObjectRigidBody[1].SetWorldTransformation(Matrix4x4Translate(2.0,2.0,-12.0));
 ObjectRigidBody[1].SetToAwake;
 ObjectRigidBody[1].CollisionGroups:=[2];

 ObjectRigidBody[18]:=TKraftRigidBody.Create(KraftPhysics);
 ObjectRigidBody[18].SetRigidBodyType(krbtDYNAMIC);
// ObjectShape[2]:=TKraftShapeSphere.Create(KraftPhysics,ObjectRigidBody[18],1.0);
 ObjectShape[18]:=TKraftShapeBox.Create(KraftPhysics,ObjectRigidBody[18],Vector3(1.0,1.0,1.0));
 ObjectShape[18].Friction:=0.4;
 ObjectShape[18].Restitution:=0.5;
 ObjectShape[18].Density:=1.0;
 ObjectShape[19]:=TKraftShapeSphere.Create(KraftPhysics,ObjectRigidBody[18],1.0);
 ObjectShape[19].LocalTransform:=Matrix4x4Translate(0.0,1.0,0.0);
 ObjectShape[19].Friction:=0.4;
 ObjectShape[19].Restitution:=0.5;
 ObjectShape[19].Density:=1.0;
 //ObjectRigidBody[18].ForcedMass:=1;
 ObjectRigidBody[18].Finish;
 ObjectRigidBody[18].SetWorldTransformation(Matrix4x4Translate(4.0,4.0,1.5));
// ObjectRigidBody[18].SetWorldTransformation(Matrix4x4Translate(2.0,2.0,-12.0));
 ObjectRigidBody[18].SetToAwake;
 ObjectRigidBody[18].CollisionGroups:=[2];

{}ObjectRigidBody[2]:=TKraftRigidBody.Create(KraftPhysics);
 ObjectRigidBody[2].SetRigidBodyType(krbtDYNAMIC);
 ObjectShape[2]:=TKraftShapeSphere.Create(KraftPhysics,ObjectRigidBody[2],1.0);
//ObjectShape[2]:=TKraftShapeBox.Create(KraftPhysics,ObjectRigidBody[2],Vector3(1.0,1.0,1.0));
 ObjectShape[2].Friction:=0.4;
 ObjectShape[2].Restitution:=0.2;
 ObjectShape[2].Density:=1.0;
 //ObjectRigidBody[1].ForcedMass:=1;
 ObjectRigidBody[2].Finish;
 ObjectRigidBody[2].SetWorldTransformation(Matrix4x4Translate(-2.0,2.0,-12.0));
// ObjectRigidBody[2].SetWorldTransformation(Matrix4x4Translate(-2.0,16.0,0.0));
 ObjectRigidBody[2].SetToAwake;{}

{}ObjectRigidBody[3]:=TKraftRigidBody.Create(KraftPhysics);
 ObjectRigidBody[3].SetRigidBodyType(krbtDYNAMIC);
 ObjectShape[3]:=TKraftShapeCapsule.Create(KraftPhysics,ObjectRigidBody[3],1.0,4.0); // Cylinder
 ObjectShape[3].Friction:=0.4;
 ObjectShape[3].Restitution:=0.2;
 ObjectShape[3].Density:=1.0;
 //ObjectRigidBody[1].ForcedMass:=1;
 ObjectRigidBody[3].Finish;
 ObjectRigidBody[3].SetWorldTransformation(Matrix4x4TermMul(Matrix4x4RotateX(pi*0.0),Matrix4x4Translate(-2.0,11.0,-20.0)));
//ObjectRigidBody[3].SetWorldTransformation(Matrix4x4TermMul(Matrix4x4RotateX(pi*0.0),Matrix4x4Translate(-5.0,4.0,5.0)));
 ObjectRigidBody[3].SetToAwake;{}

{}ObjectRigidBody[4]:=TKraftRigidBody.Create(KraftPhysics);
 ObjectRigidBody[4].SetRigidBodyType(krbtDYNAMIC);
 ObjectShape[4]:=TKraftShapeCapsule.Create(KraftPhysics,ObjectRigidBody[4],1.0,4.0);
 ObjectShape[4].Friction:=0.4;
 ObjectShape[4].Restitution:=0.2;
 ObjectShape[4].Density:=1.0;
 //ObjectRigidBody[1].ForcedMass:=1;
 ObjectRigidBody[4].Finish;
 ObjectRigidBody[4].SetWorldTransformation(Matrix4x4TermMul(Matrix4x4RotateX(pi*0.5),Matrix4x4Translate(-3.0,1.0,5.0)));
 ObjectRigidBody[4].SetToAwake;{}

{}ObjectRigidBody[5]:=TKraftRigidBody.Create(KraftPhysics);
 ObjectRigidBody[5].SetRigidBodyType(krbtDYNAMIC);
 ObjectShape[5]:=TKraftShapeSphere.Create(KraftPhysics,ObjectRigidBody[5],1.0);
//ObjectShape[5]:=TKraftShapeTriangle.Create(KraftPhysics,ObjectRigidBody[5],Vector3(15.0,0.0,-8.0),Vector3(-15.0,0.0,-8.0),Vector3(-15.0,15.0,-8.0));
 ObjectShape[5].Friction:=0.4;
 ObjectShape[5].Restitution:=0.7;
 ObjectShape[5].Density:=1.0;
 //ObjectRigidBody[1].ForcedMass:=1;
 ObjectRigidBody[5].Finish;
// ObjectRigidBody[5].SetWorldTransformation(Matrix4x4Translate(-37.3,24.0,-36.0));
// ObjectRigidBody[5].SetWorldTransformation(Matrix4x4Translate(-35.0,30.0,-26.0));
 ObjectRigidBody[5].SetWorldTransformation(Matrix4x4Translate(-35.0,30.0,-25.0));
 ObjectRigidBody[5].SetToAwake;{}

{}ObjectRigidBody[6]:=TKraftRigidBody.Create(KraftPhysics);
 ObjectRigidBody[6].SetRigidBodyType(krbtDYNAMIC);
 ObjectShape[6]:=TKraftShapeCapsule.Create(KraftPhysics,ObjectRigidBody[6],1.0,4.0);
 ObjectShape[6].Friction:=0.4;
 ObjectShape[6].Restitution:=0.2;
 ObjectShape[6].Density:=1.0;
 //ObjectRigidBody[1].ForcedMass:=1;
 ObjectRigidBody[6].Finish;
 ObjectRigidBody[6].SetWorldTransformation(Matrix4x4TermMul(Matrix4x4TermMul(Matrix4x4RotateX(pi*0.5),Matrix4x4RotateY(pi*0.5)),Matrix4x4Translate(-10.0,1.0,-4.5)));
 ObjectRigidBody[6].SetToAwake;{}

{}ObjectRigidBody[7]:=TKraftRigidBody.Create(KraftPhysics);
 ObjectRigidBody[7].SetRigidBodyType(krbtDYNAMIC);
 ObjectShape[7]:=TKraftShapeCapsule.Create(KraftPhysics,ObjectRigidBody[7],1.0,4.0);
//ObjectShape[7]:=TKraftShapeCone.Create(KraftPhysics,ObjectRigidBody[7],1.0,4.0);
 ObjectShape[7].Friction:=0.4;
 ObjectShape[7].Restitution:=0.2;
 ObjectShape[7].Density:=1.0;
 //ObjectRigidBody[1].ForcedMass:=1;
 ObjectRigidBody[7].Finish;
 ObjectRigidBody[7].SetWorldTransformation(Matrix4x4TermMul(Matrix4x4RotateX(pi*0.0),Matrix4x4Translate(-8.0,1.0,5.0)));
// ObjectRigidBody[7].SetWorldTransformation(Matrix4x4TermMul(Matrix4x4RotateX(pi*0.5),Matrix4x4Translate(-8.0,1.0,5.0)));
 ObjectRigidBody[7].SetToAwake;{}

{}ObjectRigidBody[8]:=TKraftRigidBody.Create(KraftPhysics);
 ObjectRigidBody[8].SetRigidBodyType(krbtDYNAMIC);
// ObjectShape[8]:=TKraftShapeSphere.Create(KraftPhysics,ObjectRigidBody[8],1.0);
 ConvexHull:=TKraftConvexHull.Create(KraftPhysics);
 ConvexHullGarbageCollector.Add(ConvexHull);
 ConvexHull.Load(pointer(@ConvexHullPoints),length(ConvexHullPoints));
 ConvexHull.Build;
 ConvexHull.Finish;
// Dump1(ConvexHull);
{DumpFile(@ConvexHull.Vertices[0],length(ConvexHull.Vertices)*sizeof(ConvexHull.Vertices[0]),'hbv');
 DumpFaces(ConvexHull.Faces,'hbf');
 DumpFile(@ConvexHull.Edges[0],length(ConvexHull.Edges)*sizeof(ConvexHull.Edges[0]),'hbe');
 DumpFile(@ConvexHull.AABB,sizeof(ConvexHull.AABB),'hb_aabb');
 DumpFile(@ConvexHull.MassData,sizeof(ConvexHull.MassData),'hb_massdata');  {}
//
//
 ObjectShape[8]:=TKraftShapeConvexHull.Create(KraftPhysics,ObjectRigidBody[8],ConvexHull);{
 ObjectShape[8]:=TKraftShapeConvexHull.Create(KraftPhysics,ObjectRigidBody[8],pointer(@ConvexHullPoints),length(ConvexHullPoints));{}
 ObjectShape[8].Friction:=0.4;
 ObjectShape[8].Restitution:=0.2;
 ObjectShape[8].Density:=1.0;
 //ObjectRigidBody[1].ForcedMass:=1;
 ObjectRigidBody[8].Finish;
{DumpFile(@ObjectShape[8].Vertices[0],length(ObjectShape[8].Vertices)*sizeof(ObjectShape[8].Vertices[0]),'hav');
 DumpFaces(ObjectShape[8].Faces,'haf');
 DumpFile(@ObjectShape[8].Edges[0],length(ObjectShape[8].Edges)*sizeof(ObjectShape[8].Edges[0]),'hae');{}
//Dump2(ObjectShape[8]);
// ObjectRigidBody[8].SetWorldTransformation(Matrix4x4TermMul(Matrix4x4RotateX(pi*0.125),Matrix4x4Translate(0.0,3.0,0.0)));
 ObjectRigidBody[8].SetWorldTransformation(Matrix4x4TermMul(Matrix4x4RotateX(pi*0.125),Matrix4x4Translate(5.0,-1.5,5.0)));
//ObjectRigidBody[8].SetWorldTransformation(Matrix4x4TermMul(Matrix4x4RotateX(pi*0.125),Matrix4x4Translate(0.0,1.0,8.0)));
 ObjectRigidBody[8].SetToAwake;{}

 ObjectRigidBody[9]:=TKraftRigidBody.Create(KraftPhysics);
 ObjectRigidBody[9].SetRigidBodyType(krbtSTATIC);
 ObjectShape[9]:=TKraftShapeSphere.Create(KraftPhysics,ObjectRigidBody[9],0.1);
 ObjectRigidBody[9].Finish;
 ObjectRigidBody[9].SetWorldTransformation(Matrix4x4TermMul(Matrix4x4RotateX(pi*0.0),Matrix4x4Translate(-8.0,8.0,15.0)));
 ObjectRigidBody[9].SetToAwake;

 ObjectRigidBody[10]:=TKraftRigidBody.Create(KraftPhysics);
 ObjectRigidBody[10].SetRigidBodyType(krbtDYNAMIC);
 ObjectShape[10]:=TKraftShapeSphere.Create(KraftPhysics,ObjectRigidBody[10],1.0);
 ObjectRigidBody[10].Finish;
 ObjectRigidBody[10].SetWorldTransformation(Matrix4x4TermMul(Matrix4x4RotateX(pi*0.0),Matrix4x4Translate(-8.0,6.5,15.0)));
 ObjectRigidBody[10].SetToAwake;

 ObjectRigidBody[11]:=TKraftRigidBody.Create(KraftPhysics);
 ObjectRigidBody[11].SetRigidBodyType(krbtDYNAMIC);
 ObjectShape[11]:=TKraftShapeSphere.Create(KraftPhysics,ObjectRigidBody[11],1.0);
 ObjectRigidBody[11].Finish;
 ObjectRigidBody[11].SetWorldTransformation(Matrix4x4TermMul(Matrix4x4RotateX(pi*0.0),Matrix4x4Translate(-8.0,5.0,15.0)));
 ObjectRigidBody[11].SetToAwake;

 ObjectRigidBody[12]:=TKraftRigidBody.Create(KraftPhysics);
 ObjectRigidBody[12].SetRigidBodyType(krbtDYNAMIC);
 ObjectShape[12]:=TKraftShapeSphere.Create(KraftPhysics,ObjectRigidBody[12],1.0);
 ObjectRigidBody[12].Finish;
 ObjectRigidBody[12].SetWorldTransformation(Matrix4x4TermMul(Matrix4x4RotateX(pi*0.0),Matrix4x4Translate(-8.0,3.5,15.0)));
 ObjectRigidBody[12].SetToAwake;

 ObjectRigidBody[13]:=TKraftRigidBody.Create(KraftPhysics);
 ObjectRigidBody[13].SetRigidBodyType(krbtDYNAMIC);
 ObjectShape[13]:=TKraftShapeSphere.Create(KraftPhysics,ObjectRigidBody[13],1.0);
 ObjectRigidBody[13].Finish;
 ObjectRigidBody[13].SetWorldTransformation(Matrix4x4TermMul(Matrix4x4RotateX(pi*0.0),Matrix4x4Translate(-8.0,1.0,15.0)));
 ObjectRigidBody[13].SetToAwake;

 ObjectRigidBody[14]:=TKraftRigidBody.Create(KraftPhysics);
 ObjectRigidBody[14].SetRigidBodyType(krbtSTATIC);
 ObjectShape[14]:=TKraftShapeSphere.Create(KraftPhysics,ObjectRigidBody[14],1.0);
 ObjectRigidBody[14].Finish;
 ObjectRigidBody[14].SetWorldTransformation(Matrix4x4TermMul(Matrix4x4RotateX(pi*0.0),Matrix4x4Translate(-12.0,6.0,15.0)));
 ObjectRigidBody[14].SetToAwake;

 ObjectRigidBody[15]:=TKraftRigidBody.Create(KraftPhysics);
 ObjectRigidBody[15].SetRigidBodyType(krbtDYNAMIC);
 ObjectShape[15]:=TKraftShapeSphere.Create(KraftPhysics,ObjectRigidBody[15],1.0);
 ObjectRigidBody[15].Finish;
 ObjectRigidBody[15].SetWorldTransformation(Matrix4x4TermMul(Matrix4x4RotateX(pi*0.0),Matrix4x4Translate(-12.0,3.0,15.0)));
 ObjectRigidBody[15].SetToAwake;

 ObjectRigidBody[16]:=TKraftRigidBody.Create(KraftPhysics);
 ObjectRigidBody[16].SetRigidBodyType(krbtSTATIC);
 ObjectShape[16]:=TKraftShapeSphere.Create(KraftPhysics,ObjectRigidBody[16],1.0);
 ObjectRigidBody[16].Finish;
 ObjectRigidBody[16].SetWorldTransformation(Matrix4x4TermMul(Matrix4x4RotateX(pi*0.0),Matrix4x4Translate(-16.0,6.0,15.0)));
 ObjectRigidBody[16].SetToAwake;

 ObjectRigidBody[17]:=TKraftRigidBody.Create(KraftPhysics);
 ObjectRigidBody[17].SetRigidBodyType(krbtDYNAMIC);
 ObjectShape[17]:=TKraftShapeSphere.Create(KraftPhysics,ObjectRigidBody[17],1.0);
 ObjectRigidBody[17].Finish;
 ObjectRigidBody[17].SetWorldTransformation(Matrix4x4TermMul(Matrix4x4RotateX(pi*0.0),Matrix4x4Translate(-16.0,6.0,12.0)));
 ObjectRigidBody[17].SetToAwake;

{Constraints[0]:=TKraftConstraintJointDistance.Create(KraftPhysics,ObjectRigidBody[9],ObjectRigidBody[10],Vector3(-8.0,7.0,15.0),Vector3(-8.0,7.0,15.0),4.0,0.5);
 Constraints[1]:=TKraftConstraintJointDistance.Create(KraftPhysics,ObjectRigidBody[10],ObjectRigidBody[11],Vector3(-8.0,5.0,15.0),Vector3(-8.0,5.0,15.0),4.0,0.5);
{}

{Constraints[0]:=TKraftConstraintJointDistance.Create(KraftPhysics,ObjectRigidBody[9],ObjectRigidBody[10],Vector3(0.0,0.01,0),Vector3(0.0,-0.01,0.0),4.0,0.5);
 Constraints[1]:=TKraftConstraintJointDistance.Create(KraftPhysics,ObjectRigidBody[10],ObjectRigidBody[11],Vector3(0.0,0.01,0),Vector3(0.0,-0.01,0.0),4.0,0.5);
{}

{WorldPlaneDistanceConstraints[0]:=TKraftConstraintJointWorldPlaneDistance.Create(KraftPhysics,ObjectRigidBody[1],Vector3(0.0,-1.0,0.0),Plane(Vector3(0.0,1.0,0.0),-1.0),false,4.0,kclbLimitMinimumDistance,1.0,0.5);
 WorldPlaneDistanceConstraints[1]:=TKraftConstraintJointWorldPlaneDistance.Create(KraftPhysics,ObjectRigidBody[1],Vector3(-0.65,-1.0,-0.65),Plane(Vector3(0.0,1.0,0.0),-1.0),false,4.0,kclbLimitMinimumDistance,1.0,0.5);
 WorldPlaneDistanceConstraints[2]:=TKraftConstraintJointWorldPlaneDistance.Create(KraftPhysics,ObjectRigidBody[1],Vector3(0.65,-1.0,-0.65),Plane(Vector3(0.0,1.0,0.0),-1.0),false,4.0,kclbLimitMinimumDistance,1.0,0.5);
 WorldPlaneDistanceConstraints[3]:=TKraftConstraintJointWorldPlaneDistance.Create(KraftPhysics,ObjectRigidBody[1],Vector3(-0.65,-1.0,0.65),Plane(Vector3(0.0,1.0,0.0),-1.0),false,4.0,kclbLimitMinimumDistance,1.0,0.5);
 WorldPlaneDistanceConstraints[4]:=TKraftConstraintJointWorldPlaneDistance.Create(KraftPhysics,ObjectRigidBody[1],Vector3(0.65,-1.0,0.65),Plane(Vector3(0.0,1.0,0.0),-1.0),false,4.0,kclbLimitMinimumDistance,1.0,0.5);{}
//Exclude(ObjectRigidBody[1].Flags,krbfAllowSleep);

{}
 RopeConstraints[0]:=TKraftConstraintJointRope.Create(KraftPhysics,ObjectRigidBody[9],ObjectRigidBody[10],Vector3(0.0,-0.55,0),Vector3(0.0,0.55,0.0),1.0,true);
 RopeConstraints[1]:=TKraftConstraintJointRope.Create(KraftPhysics,ObjectRigidBody[10],ObjectRigidBody[11],Vector3(0.0,-0.55,0),Vector3(0.0,0.55,0.0),1.0,true);
 RopeConstraints[2]:=TKraftConstraintJointRope.Create(KraftPhysics,ObjectRigidBody[11],ObjectRigidBody[12],Vector3(0.0,-0.55,0),Vector3(0.0,0.55,0.0),1.0,true);
 RopeConstraints[3]:=TKraftConstraintJointRope.Create(KraftPhysics,ObjectRigidBody[12],ObjectRigidBody[13],Vector3(0.0,-0.55,0),Vector3(0.0,0.55,0.0),1.0,true);
//Constraints[3]:=TKraftConstraintJointFixed.Create(KraftPhysics,ObjectRigidBody[12],ObjectRigidBody[13],Vector3(-8.0,3.0,15.0));
 {}

//HingeConstraints[0]:=TKraftConstraintJointBallSocket.Create(KraftPhysics,ObjectRigidBody[14],ObjectRigidBody[15],Vector3(-12.0,4.5,18.0));
//HingeConstraints[0]:=TKraftConstraintJointFixed.Create(KraftPhysics,ObjectRigidBody[14],ObjectRigidBody[15],Vector3(-12.0,4.5,18.0));
 HingeConstraints[0]:=TKraftConstraintJointHinge.Create(KraftPhysics,ObjectRigidBody[14],ObjectRigidBody[15],Vector3(-12.0,4.5,15.0),Vector3Norm(Vector3(1.0,0.0,0.0)),false,false,-1.0,1.0,0.0,0.0,true);

 SliderConstraints[0]:=TKraftConstraintJointSlider.Create(KraftPhysics,ObjectRigidBody[16],ObjectRigidBody[17],Vector3(-16.0,6.0,13.5),Vector3Norm(Vector3(0.0,0.0,1.0)),true,false,-0.5,0.5,0.0,0.0,true);

{
 Constraints[0]:=TKraftConstraintJointVelocityBasedDistance.Create(KraftPhysics,ObjectRigidBody[9],ObjectRigidBody[10],2.0);
 Constraints[1]:=TKraftConstraintJointVelocityBasedDistance.Create(KraftPhysics,ObjectRigidBody[10],ObjectRigidBody[11],2.0);
{}

{
 Constraints[0]:=TKraftConstraintJointVelocityBasedBall.Create(KraftPhysics,ObjectRigidBody[9],ObjectRigidBody[10],Vector3(0.0,-1.01,0.0),Vector3(0.0,1.01,0.0));
 Constraints[1]:=TKraftConstraintJointVelocityBasedBall.Create(KraftPhysics,ObjectRigidBody[10],ObjectRigidBody[11],Vector3(0.0,-1.01,0.0),Vector3(0.0,1.01,0.0));

//Constraints[0]:=TKraftConstraintJointVelocityBasedDistance.Create(KraftPhysics,ObjectRigidBody[9],ObjectRigidBody[10],4.0);
//Constraints[1]:=TKraftConstraintJointVelocityBasedDistance.Create(KraftPhysics,ObjectRigidBody[10],ObjectRigidBody[11],4.0);

 begin
 end;

(**)

{ObjectRigidBody[0]:=TKraftRigidBody.Create(KraftPhysics);
 ObjectRigidBody[0].SetRigidBodyType(krbtDYNAMIC);
 ObjectShape[0]:=TKraftShapeSphere.Create(KraftPhysics,ObjectRigidBody[0],1.0);
//ObjectShape[0]:=TKraftShapeTriangle.Create(KraftPhysics,ObjectRigidBody[5],Vector3(15.0,0.0,-8.0),Vector3(-15.0,0.0,-8.0),Vector3(-15.0,15.0,-8.0));
 ObjectShape[0].Friction:=0.4;
 ObjectShape[0].Restitution:=0.2;
 ObjectShape[0].Density:=1.0;
 //ObjectRigidBody[0].ForcedMass:=1;
 ObjectRigidBody[0].Finish;
// ObjectRigidBody[0].SetWorldTransformation(Matrix4x4Translate(-37.3,24.0,-36.0));
 ObjectRigidBody[0].SetWorldTransformation(Matrix4x4Translate(-35.0,30.0,-25.0));
 ObjectRigidBody[0].SetToAwake;{}

{ObjectRigidBody[0]:=TKraftRigidBody.Create(KraftPhysics);
 ObjectRigidBody[0].SetRigidBodyType(krbtDYNAMIC);
 ObjectShape[0]:=TKraftShapeSphere.Create(KraftPhysics,ObjectRigidBody[0],1.0);
//ObjectShape[0]:=TKraftShapeTriangle.Create(KraftPhysics,ObjectRigidBody[0],Vector3(15.0,0.0,-8.0),Vector3(-15.0,0.0,-8.0),Vector3(-15.0,15.0,-8.0));
 ObjectShape[0].Friction:=0.4;
 ObjectShape[0].Restitution:=0.2;
 ObjectShape[0].Density:=1.0;
 //ObjectRigidBody[1].ForcedMass:=1;
 ObjectRigidBody[0].Finish;
// ObjectRigidBody[0].SetWorldTransformation(Matrix4x4Translate(-37.3,24.0,-36.0));
// ObjectRigidBody[0].SetWorldTransformation(Matrix4x4Translate(-35.0,30.0,-26.0));
 ObjectRigidBody[0].SetWorldTransformation(Matrix4x4Translate(-35.0,30.0,-25.0));
 ObjectRigidBody[0].SetToAwake;{}



{ObjectRigidBody[0]:=TKraftRigidBody.Create(KraftPhysics);
 ObjectRigidBody[0].SetRigidBodyType(krbtDYNAMIC);
// ObjectShape[8]:=TKraftShapeSphere.Create(KraftPhysics,ObjectRigidBody[8],1.0);
 ConvexHull:=TKraftConvexHull.Create(KraftPhysics);
 ConvexHull.Load(pointer(@ConvexHullPoints),length(ConvexHullPoints));
 ConvexHull.Build;
 ConvexHull.Finish;
 ObjectShape[0]:=TKraftShapeConvexHull.Create(KraftPhysics,ObjectRigidBody[0],ConvexHull);
 ObjectShape[0].Friction:=0.4;
 ObjectShape[0].Restitution:=0.2;
 ObjectShape[0].Density:=1.0;
 ObjectRigidBody[0].Finish;
 ObjectRigidBody[0].SetWorldTransformation(Matrix4x4TermMul(Matrix4x4RotateX(pi*0.125),Matrix4x4Translate(5.0,-1.5,5.0)));
 ObjectRigidBody[0].SetToAwake;{}

(**)
 begin

  RagdollOffset:=Matrix4x4Translate(BODY_BASE_X,BODY_BASE_Y,BODY_BASE_Z);

  RagdollRigidBody[BODYPART_PELVIS]:=TKraftRigidBody.Create(KraftPhysics);
  RagdollRigidBody[BODYPART_PELVIS].SetRigidBodyType(krbtDYNAMIC);
  RagdollShape[BODYPART_PELVIS]:=TKraftShapeCapsule.Create(KraftPhysics,RagdollRigidBody[BODYPART_PELVIS],ScaleRagDoll*0.15,ScaleRagDoll*0.20);
  RagdollRigidBody[BODYPART_PELVIS].Finish;
  RagdollRigidBody[BODYPART_PELVIS].SetWorldTransformation(Matrix4x4TermMul(Matrix4x4TermMul(Matrix4x4RotateX(pi*0.0),Matrix4x4Translate(0.0,ScaleRagDoll*1.0,0.0)),RagdollOffset));
  RagdollRigidBody[BODYPART_PELVIS].SetToAwake;
  RagdollRigidBody[BODYPART_PELVIS].Flags:=RagdollRigidBody[BODYPART_PELVIS].Flags-[krbfContinuous];

  RagdollRigidBody[BODYPART_SPINE]:=TKraftRigidBody.Create(KraftPhysics);
  RagdollRigidBody[BODYPART_SPINE].SetRigidBodyType(krbtDYNAMIC);
  RagdollShape[BODYPART_SPINE]:=TKraftShapeCapsule.Create(KraftPhysics,RagdollRigidBody[BODYPART_SPINE],ScaleRagDoll*0.15,ScaleRagDoll*0.28);
  RagdollRigidBody[BODYPART_SPINE].Finish;
  RagdollRigidBody[BODYPART_SPINE].SetWorldTransformation(Matrix4x4TermMul(Matrix4x4TermMul(Matrix4x4RotateX(pi*0.0),Matrix4x4Translate(0.0,ScaleRagDoll*1.2,0.0)),RagdollOffset));
  RagdollRigidBody[BODYPART_SPINE].SetToAwake;
  RagdollRigidBody[BODYPART_SPINE].Flags:=RagdollRigidBody[BODYPART_SPINE].Flags-[krbfContinuous];

  RagdollRigidBody[BODYPART_HEAD]:=TKraftRigidBody.Create(KraftPhysics);
  RagdollRigidBody[BODYPART_HEAD].SetRigidBodyType(krbtDYNAMIC);
  RagdollShape[BODYPART_HEAD]:=TKraftShapeCapsule.Create(KraftPhysics,RagdollRigidBody[BODYPART_HEAD],ScaleRagDoll*0.10,ScaleRagDoll*0.05);
  RagdollRigidBody[BODYPART_HEAD].Finish;
  RagdollRigidBody[BODYPART_HEAD].SetWorldTransformation(Matrix4x4TermMul(Matrix4x4TermMul(Matrix4x4RotateX(pi*0.0),Matrix4x4Translate(0.0,ScaleRagDoll*1.6,0.0)),RagdollOffset));
  RagdollRigidBody[BODYPART_HEAD].SetToAwake;
  RagdollRigidBody[BODYPART_HEAD].Flags:=RagdollRigidBody[BODYPART_HEAD].Flags-[krbfContinuous];

  RagdollRigidBody[BODYPART_LEFT_UPPER_LEG]:=TKraftRigidBody.Create(KraftPhysics);
  RagdollRigidBody[BODYPART_LEFT_UPPER_LEG].SetRigidBodyType(krbtDYNAMIC);
  RagdollShape[BODYPART_LEFT_UPPER_LEG]:=TKraftShapeCapsule.Create(KraftPhysics,RagdollRigidBody[BODYPART_LEFT_UPPER_LEG],ScaleRagDoll*0.07,ScaleRagDoll*0.45);
  RagdollRigidBody[BODYPART_LEFT_UPPER_LEG].Finish;
  RagdollRigidBody[BODYPART_LEFT_UPPER_LEG].SetWorldTransformation(Matrix4x4TermMul(Matrix4x4TermMul(Matrix4x4RotateX(pi*0.0),Matrix4x4Translate(ScaleRagDoll*(-0.18),ScaleRagDoll*0.65,0.0)),RagdollOffset));
  RagdollRigidBody[BODYPART_LEFT_UPPER_LEG].SetToAwake;
  RagdollRigidBody[BODYPART_LEFT_UPPER_LEG].Flags:=RagdollRigidBody[BODYPART_LEFT_UPPER_LEG].Flags-[krbfContinuous];

  RagdollRigidBody[BODYPART_LEFT_LOWER_LEG]:=TKraftRigidBody.Create(KraftPhysics);
  RagdollRigidBody[BODYPART_LEFT_LOWER_LEG].SetRigidBodyType(krbtDYNAMIC);
  RagdollShape[BODYPART_LEFT_LOWER_LEG]:=TKraftShapeCapsule.Create(KraftPhysics,RagdollRigidBody[BODYPART_LEFT_LOWER_LEG],ScaleRagDoll*0.05,ScaleRagDoll*0.37);
  RagdollRigidBody[BODYPART_LEFT_LOWER_LEG].Finish;
  RagdollRigidBody[BODYPART_LEFT_LOWER_LEG].SetWorldTransformation(Matrix4x4TermMul(Matrix4x4TermMul(Matrix4x4RotateX(pi*0.0),Matrix4x4Translate(ScaleRagDoll*(-0.18),ScaleRagDoll*(-0.2),0.0)),RagdollOffset));
  RagdollRigidBody[BODYPART_LEFT_LOWER_LEG].SetToAwake;
  RagdollRigidBody[BODYPART_LEFT_LOWER_LEG].Flags:=RagdollRigidBody[BODYPART_LEFT_LOWER_LEG].Flags-[krbfContinuous];

  RagdollRigidBody[BODYPART_RIGHT_UPPER_LEG]:=TKraftRigidBody.Create(KraftPhysics);
  RagdollRigidBody[BODYPART_RIGHT_UPPER_LEG].SetRigidBodyType(krbtDYNAMIC);
  RagdollShape[BODYPART_RIGHT_UPPER_LEG]:=TKraftShapeCapsule.Create(KraftPhysics,RagdollRigidBody[BODYPART_RIGHT_UPPER_LEG],ScaleRagDoll*0.07,ScaleRagDoll*0.45);
  RagdollRigidBody[BODYPART_RIGHT_UPPER_LEG].Finish;
  RagdollRigidBody[BODYPART_RIGHT_UPPER_LEG].SetWorldTransformation(Matrix4x4TermMul(Matrix4x4TermMul(Matrix4x4RotateX(pi*0.0),Matrix4x4Translate(ScaleRagDoll*(0.18),ScaleRagDoll*0.65,0.0)),RagdollOffset));
  RagdollRigidBody[BODYPART_RIGHT_UPPER_LEG].SetToAwake;
  RagdollRigidBody[BODYPART_RIGHT_UPPER_LEG].Flags:=RagdollRigidBody[BODYPART_RIGHT_UPPER_LEG].Flags-[krbfContinuous];

  RagdollRigidBody[BODYPART_RIGHT_LOWER_LEG]:=TKraftRigidBody.Create(KraftPhysics);
  RagdollRigidBody[BODYPART_RIGHT_LOWER_LEG].SetRigidBodyType(krbtDYNAMIC);
  RagdollShape[BODYPART_RIGHT_LOWER_LEG]:=TKraftShapeCapsule.Create(KraftPhysics,RagdollRigidBody[BODYPART_RIGHT_LOWER_LEG],ScaleRagDoll*0.05,ScaleRagDoll*0.37);
  RagdollRigidBody[BODYPART_RIGHT_LOWER_LEG].Finish;
  RagdollRigidBody[BODYPART_RIGHT_LOWER_LEG].SetWorldTransformation(Matrix4x4TermMul(Matrix4x4TermMul(Matrix4x4RotateX(pi*0.0),Matrix4x4Translate(ScaleRagDoll*(0.18),ScaleRagDoll*(-0.2),0.0)),RagdollOffset));
  RagdollRigidBody[BODYPART_RIGHT_LOWER_LEG].SetToAwake;
  RagdollRigidBody[BODYPART_RIGHT_LOWER_LEG].Flags:=RagdollRigidBody[BODYPART_RIGHT_LOWER_LEG].Flags-[krbfContinuous];

  RagdollRigidBody[BODYPART_LEFT_UPPER_ARM]:=TKraftRigidBody.Create(KraftPhysics);
  RagdollRigidBody[BODYPART_LEFT_UPPER_ARM].SetRigidBodyType(krbtDYNAMIC);
  RagdollShape[BODYPART_LEFT_UPPER_ARM]:=TKraftShapeCapsule.Create(KraftPhysics,RagdollRigidBody[BODYPART_LEFT_UPPER_ARM],ScaleRagDoll*0.05,ScaleRagDoll*0.33);
  RagdollRigidBody[BODYPART_LEFT_UPPER_ARM].Finish;
  RagdollRigidBody[BODYPART_LEFT_UPPER_ARM].SetWorldTransformation(Matrix4x4TermMul(Matrix4x4TermMul(Matrix4x4RotateZ(pi*0.5),Matrix4x4Translate(ScaleRagDoll*(-0.35),ScaleRagDoll*1.45,0.0)),RagdollOffset));
  RagdollRigidBody[BODYPART_LEFT_UPPER_ARM].SetToAwake;
  RagdollRigidBody[BODYPART_LEFT_UPPER_ARM].Flags:=RagdollRigidBody[BODYPART_LEFT_UPPER_ARM].Flags-[krbfContinuous];

  RagdollRigidBody[BODYPART_LEFT_LOWER_ARM]:=TKraftRigidBody.Create(KraftPhysics);
  RagdollRigidBody[BODYPART_LEFT_LOWER_ARM].SetRigidBodyType(krbtDYNAMIC);
  RagdollShape[BODYPART_LEFT_LOWER_ARM]:=TKraftShapeCapsule.Create(KraftPhysics,RagdollRigidBody[BODYPART_LEFT_LOWER_ARM],ScaleRagDoll*0.04,ScaleRagDoll*0.25);
  RagdollRigidBody[BODYPART_LEFT_LOWER_ARM].Finish;
  RagdollRigidBody[BODYPART_LEFT_LOWER_ARM].SetWorldTransformation(Matrix4x4TermMul(Matrix4x4TermMul(Matrix4x4RotateZ(pi*0.5),Matrix4x4Translate(ScaleRagDoll*(-0.7),ScaleRagDoll*1.45,0.0)),RagdollOffset));
  RagdollRigidBody[BODYPART_LEFT_LOWER_ARM].SetToAwake;
  RagdollRigidBody[BODYPART_LEFT_LOWER_ARM].Flags:=RagdollRigidBody[BODYPART_LEFT_LOWER_ARM].Flags-[krbfContinuous];

  RagdollRigidBody[BODYPART_RIGHT_UPPER_ARM]:=TKraftRigidBody.Create(KraftPhysics);
  RagdollRigidBody[BODYPART_RIGHT_UPPER_ARM].SetRigidBodyType(krbtDYNAMIC);
  RagdollShape[BODYPART_RIGHT_UPPER_ARM]:=TKraftShapeCapsule.Create(KraftPhysics,RagdollRigidBody[BODYPART_RIGHT_UPPER_ARM],ScaleRagDoll*0.05,ScaleRagDoll*0.33);
  RagdollRigidBody[BODYPART_RIGHT_UPPER_ARM].Finish;
  RagdollRigidBody[BODYPART_RIGHT_UPPER_ARM].SetWorldTransformation(Matrix4x4TermMul(Matrix4x4TermMul(Matrix4x4RotateZ(-(pi*0.5)),Matrix4x4Translate(ScaleRagDoll*(0.35),ScaleRagDoll*1.45,0.0)),RagdollOffset));
  RagdollRigidBody[BODYPART_RIGHT_UPPER_ARM].SetToAwake;
  RagdollRigidBody[BODYPART_RIGHT_UPPER_ARM].Flags:=RagdollRigidBody[BODYPART_RIGHT_UPPER_ARM].Flags-[krbfContinuous];

  RagdollRigidBody[BODYPART_RIGHT_LOWER_ARM]:=TKraftRigidBody.Create(KraftPhysics);
  RagdollRigidBody[BODYPART_RIGHT_LOWER_ARM].SetRigidBodyType(krbtDYNAMIC);
  RagdollShape[BODYPART_RIGHT_LOWER_ARM]:=TKraftShapeCapsule.Create(KraftPhysics,RagdollRigidBody[BODYPART_RIGHT_LOWER_ARM],ScaleRagDoll*0.04,ScaleRagDoll*0.25);
  RagdollRigidBody[BODYPART_RIGHT_LOWER_ARM].Finish;
  RagdollRigidBody[BODYPART_RIGHT_LOWER_ARM].SetWorldTransformation(Matrix4x4TermMul(Matrix4x4TermMul(Matrix4x4RotateZ(-(pi*0.5)),Matrix4x4Translate(ScaleRagDoll*(0.7),ScaleRagDoll*1.45,0.0)),RagdollOffset));
  RagdollRigidBody[BODYPART_RIGHT_LOWER_ARM].SetToAwake;
  RagdollRigidBody[BODYPART_RIGHT_LOWER_ARM].Flags:=RagdollRigidBody[BODYPART_RIGHT_LOWER_ARM].Flags-[krbfContinuous];

  /// ******* PELVIS ******** ///
  RagdollConstraints[0]:=TKraftConstraintJointBallSocket.Create(KraftPhysics,
                                                                RagdollRigidBody[BODYPART_PELVIS],
                                                                RagdollRigidBody[BODYPART_SPINE],
                                                                Vector3(0.0,0.15*ScaleRagdoll,0.0),
                                                                Vector3(0.0,-(0.15*ScaleRagdoll),0.0));

  /// ******* SPINE HEAD ******** ///
  RagdollConstraints[1]:=TKraftConstraintJointBallSocket.Create(KraftPhysics,
                                                                RagdollRigidBody[BODYPART_SPINE],
                                                                RagdollRigidBody[BODYPART_HEAD],
                                                                Vector3(0.0,0.25*ScaleRagdoll,0.0),
                                                                Vector3(0.0,-(0.15*ScaleRagdoll),0.0),
                                                                true);

  /// ******* LEFT HIP ******** ///
  RagdollConstraints[2]:=TKraftConstraintJointBallSocket.Create(KraftPhysics,
                                                                        RagdollRigidBody[BODYPART_PELVIS],
                                                                        RagdollRigidBody[BODYPART_LEFT_UPPER_LEG],
                                                                        Vector3(-(0.18*ScaleRagdoll),-(0.10*ScaleRagdoll),0.0),
                                                                        Vector3(0.0*ScaleRagdoll,0.225*ScaleRagdoll,0.0));

  /// ******* LEFT KNEE ******** ///
  RagdollConstraints[3]:=TKraftConstraintJointBallSocket.Create(KraftPhysics,
                                                                        RagdollRigidBody[BODYPART_LEFT_UPPER_LEG],
                                                                        RagdollRigidBody[BODYPART_LEFT_LOWER_LEG],
                                                                        Vector3(0.0,-(0.225*ScaleRagdoll),0.0),
                                                                        Vector3(0.0*ScaleRagdoll,0.185*ScaleRagdoll,0.0));

  /// ******* RIGHT HIP ******** ///
  RagdollConstraints[4]:=TKraftConstraintJointBallSocket.Create(KraftPhysics,
                                                                        RagdollRigidBody[BODYPART_PELVIS],
                                                                        RagdollRigidBody[BODYPART_RIGHT_UPPER_LEG],
                                                                        Vector3(0.18*ScaleRagdoll,-(0.10*ScaleRagdoll),0.0),
                                                                        Vector3(0.0*ScaleRagdoll,0.225*ScaleRagdoll,0.0));

  /// ******* RIGHT KNEE ******** ///
  RagdollConstraints[5]:=TKraftConstraintJointBallSocket.Create(KraftPhysics,
                                                                        RagdollRigidBody[BODYPART_RIGHT_UPPER_LEG],
                                                                        RagdollRigidBody[BODYPART_RIGHT_LOWER_LEG],
                                                                        Vector3(0.0,-(0.225*ScaleRagdoll),0.0),
                                                                        Vector3(0.0*ScaleRagdoll,0.185*ScaleRagdoll,0.0));
  /// ******* LEFT SHOULDER ******** ///
  RagdollConstraints[6]:=TKraftConstraintJointBallSocket.Create(KraftPhysics,
                                                                        RagdollRigidBody[BODYPART_SPINE],
                                                                        RagdollRigidBody[BODYPART_LEFT_UPPER_ARM],
                                                                        Vector3(-(0.2*ScaleRagdoll),0.15*ScaleRagdoll,0.0),
                                                                        Vector3(0.0*ScaleRagdoll,-(0.18*ScaleRagdoll),0.0));

  /// ******* LEFT ELBOW ******** ///
  RagdollConstraints[7]:=TKraftConstraintJointBallSocket.Create(KraftPhysics,
                                                                        RagdollRigidBody[BODYPART_LEFT_UPPER_ARM],
                                                                        RagdollRigidBody[BODYPART_LEFT_LOWER_ARM],
                                                                        Vector3(0.0,0.18*ScaleRagdoll,0.0),
                                                                        Vector3(0.0,-(0.14*ScaleRagdoll),0.0));

  /// ******* RIGHT SHOULDER ******** ///
  RagdollConstraints[8]:=TKraftConstraintJointBallSocket.Create(KraftPhysics,
                                                                        RagdollRigidBody[BODYPART_SPINE],
                                                                        RagdollRigidBody[BODYPART_RIGHT_UPPER_ARM],
                                                                        Vector3(0.2*ScaleRagdoll,0.15*ScaleRagdoll,0.0),
                                                                        Vector3(0.0*ScaleRagdoll,-(0.18*ScaleRagdoll),0.0));

  /// ******* RIGHT ELBOW ******** ///
  RagdollConstraints[9]:=TKraftConstraintJointBallSocket.Create(KraftPhysics,
                                                                        RagdollRigidBody[BODYPART_RIGHT_UPPER_ARM],
                                                                        RagdollRigidBody[BODYPART_RIGHT_LOWER_ARM],
                                                                        Vector3(0.0,0.18*ScaleRagdoll,0.0),
                                                                        Vector3(0.0,-(0.14*ScaleRagdoll),0.0));

{
  /// ******* RIGHT SHOULDER ******** ///
  RagdollConstraints[8]:=TKraftConstraintJointBallSocket.Create(KraftPhysics,RagdollRigidBody[BODYPART_SPINE],RagdollRigidBody[BODYPART_RIGHT_UPPER_ARM],Vector3(0.25*ScaleRagdoll,0.15*ScaleRagdoll,0.0),Vector3(0.0,-(0.18*ScaleRagdoll),0.0));

  /// ******* RIGHT ELBOW ******** ///
  RagdollConstraints[9]:=TKraftConstraintJointBallSocket.Create(KraftPhysics,RagdollRigidBody[BODYPART_RIGHT_UPPER_ARM],RagdollRigidBody[BODYPART_RIGHT_LOWER_ARM],Vector3(0.0,0.18*ScaleRagdoll,0.0),Vector3(0.0,-(0.25*ScaleRagdoll),0.0));

}
 end;
end;

destructor TDemoSceneSandBox.Destroy;
begin
 inherited Destroy;
end;

procedure TDemoSceneSandBox.Step(const DeltaTime:double);
begin
end;

initialization
 RegisterDemoScene('Sand box',TDemoSceneSandBox);
end.


