unit UnitDemoSceneSignedDistanceField;

{$MODE Delphi}

interface

uses {$ifdef DebugDraw}
      {$ifdef fpc}
       GL,
       GLext,
      {$else}
       OpenGL,
      {$endif}
     {$endif}
     Math,
     Kraft,
     UnitDemoScene;

type TDemoSceneSignedDistanceField=class(TDemoScene)
      public
       RigidBodyFloor:TKraftRigidBody;
       ShapeFloorPlane:TKraftShapePlane;
       constructor Create(const AKraftPhysics:TKraft); override;
       destructor Destroy; override;
       procedure Step(const DeltaTime:double); override;
     end;

implementation

uses UnitFormMain;

type { TSignedDistanceField }
     TSignedDistanceField=class(TKraftSignedDistanceField)
      private
      public
       function GetLocalSignedDistance(const Position:TKraftVector3):TKraftScalar; override;
{$ifdef DebugDrawNo}
       procedure Draw(const WorldTransform,CameraMatrix:TKraftMatrix4x4); override;
{$endif}
     end;

function TSignedDistanceField.GetLocalSignedDistance(const Position:TKraftVector3):TKraftScalar;
var b,q:TKraftVector3;
    r:TKraftScalar;
begin
 b:=Vector3(0.5,0.5,0.5);
 r:=0.25;
 q:=Vector3Add(Vector3Sub(Vector3Abs(Position),b),Vector3(r,r,r));
 result:=(Vector3Length(Vector3(Max(0.0,q.x),Max(0.0,q.y),Max(0.0,q.z)))+Min(Max(q.x,Max(q.y,q.z)),0.0))-r;
end;

{$ifdef DebugDrawNo}
procedure TSignedDistanceField.Draw(const WorldTransform,CameraMatrix:TKraftMatrix4x4);
{$ifdef NoOpenGL}
begin
end;
{$else}
const lats=16;
      longs=16;
      pi2=pi*2.0;
      fRadius=1.0;
var i,j:TKraftInt32;
    lat0,z0,zr0,lat1,z1,zr1,lng,x,y:TKraftScalar;
    ModelViewMatrix:TKraftMatrix4x4;
begin
 glPushMatrix;
 glMatrixMode(GL_MODELVIEW);
 ModelViewMatrix:=Matrix4x4TermMul(WorldTransform,CameraMatrix);
{$ifdef KraftUseDouble}
 glLoadMatrixd(pointer(@ModelViewMatrix));
{$else}
 glLoadMatrixf(pointer(@ModelViewMatrix));
{$endif}

 if DrawDisplayList=0 then begin
  DrawDisplayList:=glGenLists(1);
  glNewList(DrawDisplayList,GL_COMPILE);

  for i:=0 to lats do begin
   lat0:=pi*(((i-1)/lats)-0.5);
   z0:=sin(lat0)*fRadius;
   zr0:=cos(lat0)*fRadius;
   lat1:=pi*((i/lats)-0.5);
   z1:=sin(lat1)*fRadius;
   zr1:=cos(lat1)*fRadius;
   glBegin(GL_QUAD_STRIP);
   for j:=0 to longs do begin
    lng:=pi2*((j-1)/longs);
    x:=cos(lng);
    y:=sin(lng);
    glNormal3f(x*zr1,y*zr1,z1);
    glVertex3f(x*zr1,y*zr1,z1);
    glNormal3f(x*zr0,y*zr0,z0);
    glVertex3f(x*zr0,y*zr0,z0);
   end;
   glEnd;
  end;

  glEndList;
 end;

 if DrawDisplayList<>0 then begin
  glCallList(DrawDisplayList);
 end;

 glPopMatrix;
end;
{$endif}
{$endif}

constructor TDemoSceneSignedDistanceField.Create(const AKraftPhysics:TKraft);
var RigidBody:TKraftRigidBody;
    Shape:TKraftShape;
    SignedDistanceField:TSignedDistanceField;
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
 SignedDistanceField:=TSignedDistanceField.Create(KraftPhysics);
 SignedDistanceFieldGarbageCollector.Add(SignedDistanceField);
 SignedDistanceField.Finish;
 Shape:=TKraftShapeSignedDistanceField.Create(KraftPhysics,RigidBody,SignedDistanceField);
 Shape.Restitution:=0.3;
 Shape.Density:=1.0;
 RigidBody.Finish;
 RigidBody.SetWorldTransformation(Matrix4x4TermMul(Matrix4x4RotateZ(pi*0.0),Matrix4x4Translate(0.0,4.0,0.0)));
 RigidBody.CollisionGroups:=[0];

end;

destructor TDemoSceneSignedDistanceField.Destroy;
begin
 inherited Destroy;
end;

procedure TDemoSceneSignedDistanceField.Step(const DeltaTime:double);
begin
end;

initialization
// RegisterDemoScene('Signed distance field',TDemoSceneSignedDistanceField);
end.
