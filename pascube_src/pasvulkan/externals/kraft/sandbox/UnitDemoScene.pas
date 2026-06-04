unit UnitDemoScene;

{$MODE Delphi}

{$j+}

interface

uses SysUtils,Classes,LCLIntf, LCLType, LMessages, kraft;

type TDemoScene=class;

     TDemoSceneClass=class of TDemoScene;

     { TDemoScene }

     TDemoScene=class
      public
       fKraftPhysics:TKraft;
       GarbageCollector:TList;
       MeshGarbageCollector:TList;
       ConvexHullGarbageCollector:TList;
       SignedDistanceFieldGarbageCollector:TList;
       constructor Create(const AKraftPhysics:TKraft); virtual;
       destructor Destroy; override;
       procedure Step(const DeltaTime:double); virtual;
       procedure DebugDraw; virtual;
       function HasOwnKeyboardControls:boolean; virtual;
       procedure KeyDown(const aKey:Int32); virtual;
       procedure KeyUp(const aKey:Int32); virtual;
       function UpdateCamera(var aCameraPosition:TKraftVector3;var aCameraOrientation:TKraftQuaternion):boolean; virtual;
       procedure StoreWorldTransforms; virtual;
       procedure InterpolateWorldTransforms(const aAlpha:TKraftScalar); virtual;
       property KraftPhysics:TKraft read fKraftPhysics;
     end;

var DemoScenes:TStringList;

procedure RegisterDemoScene(const Name:string;const DemoSceneClass:TDemoSceneClass);

implementation

uses UnitFormMain;

constructor TDemoScene.Create(const AKraftPhysics:TKraft);
begin
 inherited Create;
 fKraftPhysics:=AKraftPhysics;
 GarbageCollector:=TList.Create;
 MeshGarbageCollector:=TList.Create;
 ConvexHullGarbageCollector:=TList.Create;
 SignedDistanceFieldGarbageCollector:=TList.Create;
end;

destructor TDemoScene.Destroy;
var Index:longint;
begin
 //wglMakeCurrent(FormGL.hDCGL,FormGL.hGL);

 for Index:=0 to GarbageCollector.Count-1 do begin
  TObject(GarbageCollector[Index]).Free;
 end;
 GarbageCollector.Free;

 while assigned(fKraftPhysics.RigidBodyFirst) do begin
  fKraftPhysics.RigidBodyFirst.Free;
 end;

 while assigned(fKraftPhysics.ConstraintFirst) do begin
  fKraftPhysics.ConstraintFirst.Free;
 end;

 for Index:=0 to MeshGarbageCollector.Count-1 do begin
  TObject(MeshGarbageCollector[Index]).Free;
 end;
 MeshGarbageCollector.Free;

 for Index:=0 to ConvexHullGarbageCollector.Count-1 do begin
  TObject(ConvexHullGarbageCollector[Index]).Free;
 end;
 ConvexHullGarbageCollector.Free;

 for Index:=0 to SignedDistanceFieldGarbageCollector.Count-1 do begin
  TObject(SignedDistanceFieldGarbageCollector[Index]).Free;
 end;
 SignedDistanceFieldGarbageCollector.Free;

 //wglMakeCurrent(0,0);

 inherited Destroy;
end;

procedure TDemoScene.Step(const DeltaTime:double);
begin
end;

procedure TDemoScene.DebugDraw;
begin

end;

function TDemoScene.HasOwnKeyboardControls:boolean;
begin
 result:=false;
end;

procedure TDemoScene.KeyDown(const aKey:Int32);
begin

end;

procedure TDemoScene.KeyUp(const aKey:Int32);
begin

end;

function TDemoScene.UpdateCamera(var aCameraPosition:TKraftVector3;var aCameraOrientation:TKraftQuaternion):boolean;
begin
 result:=false;
end;

procedure TDemoScene.StoreWorldTransforms;
begin
end;

procedure TDemoScene.InterpolateWorldTransforms(const aAlpha:TKraftScalar);
begin
end;

procedure RegisterDemoScene(const Name:string;const DemoSceneClass:TDemoSceneClass);
begin
 DemoScenes.AddObject(Name,pointer(DemoSceneClass));
end;

initialization
 DemoScenes:=TStringList.Create;
finalization
 DemoScenes.Free;
end.
