unit UnitDemoSceneSphereOnSDFTerrain;

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

type { TKraftShapeSignedDistanceFieldTerrain }
     TKraftShapeSignedDistanceFieldTerrain=class(TKraftShapeSignedDistanceField)
      private
       fSize:TKraftScalar;
       fHeight:TKraftScalar;
       fResolution:Int32;
       fHalfSize:Double;
       fScale:Double;
       fInverseScale:Double;
       fData:TKraftScalarArray;
       fGradientData:TKraftScalarArray;
      public
       constructor Create(const APhysics:TKraft;const ARigidBody:TKraftRigidBody;const aSize,aHeight:TKraftScalar;const aResolution:Int32); reintroduce;
       destructor Destroy; override;
       function GetLocalSignedDistance(const Position:TKraftVector3):TKraftScalar; override;
//     function GetLocalSignedDistanceGradient(const Position:TKraftVector3):TKraftVector3; override;
       function GetLocalClosestPointTo(const Position:TKraftVector3):TKraftVector3; override;
{$ifdef DebugDraw}
       procedure Draw(const CameraMatrix:TKraftMatrix4x4); override;
{$endif}
     end;

     TDemoSceneSphereOnSDFTerrain=class(TDemoScene)
      public
       RigidBodyFloor:TKraftRigidBody;
       ShapeSignedDistanceFieldTerrain:TKraftShapeSignedDistanceFieldTerrain;
       RigidBodySphere:TKraftRigidBody;
       ShapeSphere:TKraftShapeSphere;
       constructor Create(const AKraftPhysics:TKraft); override;
       destructor Destroy; override;
       procedure Step(const DeltaTime:double); override;
     end;

implementation

uses UnitFormMain;

{ TKraftShapeSignedDistanceFieldTerrain }

constructor TKraftShapeSignedDistanceFieldTerrain.Create(const APhysics:TKraft;const ARigidBody:TKraftRigidBody;const aSize,aHeight:TKraftScalar;const aResolution:Int32);
var AABB:TKraftAABB;
    x,y:Int32;
    k1,k2:TKraftScalar;
begin

 fSize:=aSize;
 fHeight:=aHeight;
 fResolution:=aResolution;

 fHalfSize:=fSize*0.5;

 fScale:=fResolution/fSize;
 fInverseScale:=fSize/fResolution;

 fData:=nil;
 SetLength(fData,fResolution*fResolution);

 fGradientData:=nil;
 SetLength(fGradientData,fResolution*fResolution);

 for y:=0 to fResolution-1 do begin
  for x:=0 to fResolution-1 do begin
   k1:=sin(x*pi*4/fResolution)*2;
   k2:=cos(y*pi*4/fResolution)*2;
   fData[(y*fResolution)+x]:=-10.0;//(Min(Max(((((cos(x*pi*k1/fResolution)*sin(y*pi*k2/fResolution)))+(k1*0.5)-(k2*0.5)))*64,-64),32)/64.0)*fHeight;
  end;
 end;

 AABB.Min:=Vector3(-fSize,-fHeight,-fSize);
 AABB.Max:=Vector3(fSize,fHeight,fSize);
 inherited Create(APhysics,ARigidBody,@AABB);

end;

destructor TKraftShapeSignedDistanceFieldTerrain.Destroy;
begin
 fData:=nil;
 fGradientData:=nil;
 inherited Destroy;
end;

function TKraftShapeSignedDistanceFieldTerrain.GetLocalSignedDistance(const Position:TKraftVector3):TKraftScalar;
var dx,dy:Double;
    ix,iy,nx,ny:Int32;
    fx,fy:Single;
begin
 dx:=(Position.x+fHalfSize)*fScale;
 dy:=(Position.z+fHalfSize)*fScale;
 if dx<=0.0 then begin
  dx:=0.0;
 end else if dx>=fResolution then begin
  dx:=fResolution;
 end;
 if dy<=0.0 then begin
  dy:=0.0;
 end else if dy>=fResolution then begin
  dy:=fResolution;
 end;
 ix:=trunc(dx);
 iy:=trunc(dy);
 if ix>=(fResolution-1) then begin
  ix:=fResolution-2;
 end;
 if iy>=(fResolution-1) then begin
  iy:=fResolution-2;
 end;
 fx:=dx-ix;
 fy:=dy-iy;
 nx:=ix+1;
 ny:=iy+1;
 if nx>=fResolution then begin
  nx:=fResolution-1;
 end;
 if ny>=fResolution then begin
  ny:=fResolution-1;
 end;
 result:=Position.y-((((fData[(iy*fResolution)+ix]*(1.0-fx))+(fData[(iy*fResolution)+nx]*fx))*(1.0-fy))+
                     (((fData[(ny*fResolution)+ix]*(1.0-fx))+(fData[(ny*fResolution)+nx]*fx))*fy));
end;

(*function TKraftShapeSignedDistanceFieldTerrain.GetLocalSignedDistanceGradient(const Position:TKraftVector3):TKraftVector3;
var dx,dy:Double;
    ix,iy,nx,ny:Int32;
    fx,fy:Single;
begin
 dx:=(Position.x+fHalfSize)*fScale;
 dy:=(Position.z+fHalfSize)*fScale;
 if dx<=0.0 then begin
  dx:=0.0;
 end else if dx>=fResolution then begin
  dx:=fResolution;
 end;
 if dy<=0.0 then begin
  dy:=0.0;
 end else if dy>=fResolution then begin
  dy:=fResolution;
 end;
 ix:=trunc(dx);
 iy:=trunc(dy);
 if ix>=(fResolution-1) then begin
  ix:=fResolution-2;
 end;
 if iy>=(fResolution-1) then begin
  iy:=fResolution-2;
 end;
 fx:=dx-ix;
 fy:=dy-iy;
 nx:=ix+1;
 ny:=iy+1;
 if nx>=fResolution then begin
  nx:=fResolution-1;
 end;
 if ny>=fResolution then begin
  ny:=fResolution-1;
 end;
 result:=Vector3Norm(Vector3(1.0,
                             (fData[(iy*fResolution)+ix]*Data[(iy*fResolution)+nx]*fx))*(1.0-fy))+
                                         (((fData[(ny*fResolution)+ix]*(1.0-fx))+(fData[(ny*fResolution)+nx]*fx))*fy)),
                             1.0)));
{result:=Vector3Norm(Vector3(Position.X-((dx*fInverseScale)-fHalfSize),
                             Position.Y-((((fData[(iy*fResolution)+ix]*(1.0-fx))+(fData[(iy*fResolution)+nx]*fx))*(1.0-fy))+
                                         (((fData[(ny*fResolution)+ix]*(1.0-fx))+(fData[(ny*fResolution)+nx]*fx))*fy)),
                             Position.Z-((dy*fInverseScale)-fHalfSize)));}
end;         *)

function TKraftShapeSignedDistanceFieldTerrain.GetLocalClosestPointTo(const Position:TKraftVector3):TKraftVector3;
var dx,dy:Double;
    ix,iy,nx,ny:Int32;
    fx,fy:Single;
begin
 dx:=(Position.x+fHalfSize)*fScale;
 dy:=(Position.z+fHalfSize)*fScale;
 if dx<=0.0 then begin
  dx:=0.0;
 end else if dx>=fResolution then begin
  dx:=fResolution;
 end;
 if dy<=0.0 then begin
  dy:=0.0;
 end else if dy>=fResolution then begin
  dy:=fResolution;
 end;
 ix:=trunc(dx);
 iy:=trunc(dy);
 if ix>=(fResolution-1) then begin
  ix:=fResolution-2;
 end;
 if iy>=(fResolution-1) then begin
  iy:=fResolution-2;
 end;
 fx:=dx-ix;
 fy:=dy-iy;
 nx:=ix+1;
 ny:=iy+1;
 if nx>=fResolution then begin
  nx:=fResolution-1;
 end;
 if ny>=fResolution then begin
  ny:=fResolution-1;
 end;
 result:=Vector3((dx*fInverseScale)-fHalfSize,
                 ((((fData[(iy*fResolution)+ix]*(1.0-fx))+(fData[(iy*fResolution)+nx]*fx))*(1.0-fy))+
                  (((fData[(ny*fResolution)+ix]*(1.0-fx))+(fData[(ny*fResolution)+nx]*fx))*fy)),
                 (dy*fInverseScale)-fHalfSize);
end;

{$ifdef DebugDraw}
procedure TKraftShapeSignedDistanceFieldTerrain.Draw(const CameraMatrix:TKraftMatrix4x4);
var ix,iy,nx,ny:Int32;
    v0,v1,v2,v3,n:TKraftVector3;
    ModelViewMatrix:TKraftMatrix4x4;
begin
 glPushMatrix;
 glMatrixMode(GL_MODELVIEW);
 ModelViewMatrix:=Matrix4x4TermMul(InterpolatedWorldTransform,CameraMatrix);
{$ifdef UseDouble}
 glLoadMatrixd(pointer(@ModelViewMatrix));
{$else}
 glLoadMatrixf(pointer(@ModelViewMatrix));
{$endif}

 if DrawDisplayList=0 then begin
  DrawDisplayList:=glGenLists(1);
  glNewList(DrawDisplayList,GL_COMPILE);
  glBegin(GL_TRIANGLES);
  for iy:=0 to fResolution-2 do begin
   ny:=iy+1;
   if ny>=fResolution then begin
    ny:=fResolution-1;
   end;
   for ix:=0 to fResolution-2 do begin
    nx:=ix+1;
    if nx>=fResolution then begin
     nx:=fResolution-1;
    end;
    v0.x:=(ix*fInverseScale)-fHalfSize;
    v0.y:=fData[(iy*fResolution)+ix];
    v0.z:=(iy*fInverseScale)-fHalfSize;
    v1.x:=(nx*fInverseScale)-fHalfSize;
    v1.y:=fData[(iy*fResolution)+nx];
    v1.z:=(iy*fInverseScale)-fHalfSize;
    v2.x:=(nx*fInverseScale)-fHalfSize;
    v2.y:=fData[(ny*fResolution)+nx];
    v2.z:=(ny*fInverseScale)-fHalfSize;
    v3.x:=(ix*fInverseScale)-fHalfSize;
    v3.y:=fData[(ny*fResolution)+ix];
    v3.z:=(ny*fInverseScale)-fHalfSize;
    n:=Vector3Norm(Vector3Cross(Vector3Sub(v2,v0),Vector3Sub(v1,v0)));
    glNormal3f(n.x,n.y,n.z);
    glVertex3f(v0.x,v0.y,v0.z);
    glVertex3f(v2.x,v2.y,v2.z);
    glVertex3f(v1.x,v1.y,v1.z);
    n:=Vector3Norm(Vector3Cross(Vector3Sub(v3,v0),Vector3Sub(v2,v0)));
    glNormal3f(n.x,n.y,n.z);
    glVertex3f(v0.x,v0.y,v0.z);
    glVertex3f(v3.x,v3.y,v3.z);
    glVertex3f(v2.x,v2.y,v2.z);
   end;
  end;
  glEnd;

  glEndList;
 end;

 if DrawDisplayList<>0 then begin
  glCallList(DrawDisplayList);
 end;

 glPopMatrix;
end;
{$endif}

constructor TDemoSceneSphereOnSDFTerrain.Create(const AKraftPhysics:TKraft); 
begin
 inherited Create(AKraftPhysics);

 RigidBodyFloor:=TKraftRigidBody.Create(KraftPhysics);
 RigidBodyFloor.SetRigidBodyType(krbtSTATIC);
 ShapeSignedDistanceFieldTerrain:=TKraftShapeSignedDistanceFieldTerrain.Create(KraftPhysics,RigidBodyFloor,512,16,128);
 ShapeSignedDistanceFieldTerrain.Restitution:=0.3;
 ShapeSignedDistanceFieldTerrain.Density:=100.0;
 RigidBodyFloor.Finish;
 RigidBodyFloor.SetWorldTransformation(Matrix4x4Translate(64.0,14.0,0.0));
 RigidBodyFloor.CollisionGroups:=[0];

 RigidBodySphere:=TKraftRigidBody.Create(KraftPhysics);
 RigidBodySphere.SetRigidBodyType(krbtDYNAMIC);
 ShapeSphere:=TKraftShapeSphere.Create(KraftPhysics,RigidBodySphere,1.0);
 ShapeSphere.Restitution:=0.3;
 ShapeSphere.Density:=1.0;
 RigidBodySphere.Finish;
 RigidBodySphere.SetWorldTransformation(Matrix4x4Translate(0.0,8.0,0.0));
 RigidBodySphere.CollisionGroups:=[0];

end;

destructor TDemoSceneSphereOnSDFTerrain.Destroy;
begin
 inherited Destroy;
end;

procedure TDemoSceneSphereOnSDFTerrain.Step(const DeltaTime:double);
begin
end;

initialization
//RegisterDemoScene('Sphere on SDF terrain',TDemoSceneSphereOnSDFTerrain);
end.
