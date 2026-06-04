unit UnitFormMain;

{$MODE Delphi}

{$j+}

interface

uses
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Math, Menus, TypInfo, kraft, ExtCtrls, StdCtrls, ComCtrls, OpenGLContext, gl, glext,
  UnitDemoScene, {$ifdef KraftPasMP}PasMP,{$endif} Types, ObjectInspector, PropEdits, PropEditUtils, GraphPropEdits;

type TCamera=object
      public
       LeftRight:TKraftScalar;
       UpDown:TKraftScalar;
       Position:TKraftVector3;
       Orientation:TKraftQuaternion;
       Matrix:TKraftMatrix4x4;
       FOV:TKraftScalar;
       procedure Reset;
       procedure MoveForwards(Speed:TKraftScalar);
       procedure MoveSidewards(Speed:TKraftScalar);
       procedure MoveUpwards(Speed:TKraftScalar);
       procedure RotateCamera(const x,y:TKraftScalar);
       procedure TestCamera;
       procedure Interpolate(const a,b:TCamera;const t:TKraftScalar);
     end;

     TThreadTimer=class(TThread)
      private
       procedure Draw;
      protected
       procedure Execute; override;
      public
       constructor Create;
       destructor Destroy; override;
     end;

  { TFormMain }

  TFormMain = class(TForm)
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    OpenGLControlWorld: TOpenGLControl;
    PopupMenu1: TPopupMenu;
    sPanelLeft: TPanel;
    sSplitter1: TSplitter;
    sPanelLeftTop: TPanel;
    sSplitter2: TSplitter;
    sPanelLeftBottom: TPanel;
    sGroupBoxTree: TGroupBox;
    sGroupBoxPropertyEditor: TGroupBox;
    sPanelRight: TPanel;
    sSplitter3: TSplitter;
    sPanelMiddle: TPanel;
    sPanelMiddleBottom: TPanel;
    sSplitter4: TSplitter;
    sPageControl1: TPageControl;
    sTabSheetInfo: TTabSheet;
    sPageControl2: TPageControl;
    sTabSheetWorld: TTabSheet;
    sTreeViewMain: TTreeView;
    sGroupBoxDemos: TGroupBox;
    sMemoInfo: TMemo;
    N3: TMenuItem;
    Skinned1: TMenuItem;
    sTreeViewDemos: TTreeView;
    sTabSheetPerformance: TTabSheet;
    sLabelBroadPhaseTime: TLabel;
    TimerDraw: TTimer;
    TimerFPS: TTimer;
    TimerPerformance: TTimer;
    sLabelMidPhaseTime: TLabel;
    sLabelNarrowPhaseTime: TLabel;
    sLabelSolverTime: TLabel;
    sLabelContinuousTime: TLabel;
    sLabelTotalTime: TLabel;
    sTabSheetSettings: TTabSheet;
    sCheckBoxDrawDynamicAABBTree: TCheckBox;
    sCheckBoxDrawContacts: TCheckBox;
    sCheckBoxDrawWireFrame: TCheckBox;
    sCheckBoxDrawSolid: TCheckBox;
    sCheckBoxDrawConstraints: TCheckBox;
    procedure CheckBoxSingleThreadedChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure OpenGLControlWorldClick(Sender: TObject);
    procedure OpenGLControlWorldEnter(Sender: TObject);
    procedure OpenGLControlWorldExit(Sender: TObject);
    procedure OpenGLControlWorldKeyDown(Sender: TObject; var Key: Word;
     Shift: TShiftState);
    procedure OpenGLControlWorldKeyUp(Sender: TObject; var Key: Word;
     Shift: TShiftState);
    procedure OpenGLControlWorldMouseDown(Sender: TObject;
     Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure OpenGLControlWorldMouseMove(Sender: TObject; Shift: TShiftState;
     X, Y: Integer);
    procedure OpenGLControlWorldMouseUp(Sender: TObject; Button: TMouseButton;
     Shift: TShiftState; X, Y: Integer);
    procedure OpenGLControlWorldMouseWheel(Sender: TObject; Shift: TShiftState;
     WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure OpenGLControlWorldPaint(Sender: TObject);
    procedure sTreeViewMainChange(Sender: TObject; Node: TTreeNode);
    procedure JvInspectorMainItemDoubleClicked(Sender: TObject;
      Item: TObject);
    procedure JvInspectorMainAfterItemCreate(Sender: TObject;
      Item: TObject);
    procedure Skinned1Click(Sender: TObject);
    procedure sListBoxDemosClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure sTreeViewDemosDblClick(Sender: TObject);
    procedure JvSimScope1Update(Sender: TObject);
    procedure TimerDrawTimer(Sender: TObject);
    procedure TimerFPSTimer(Sender: TObject);
    procedure TimerPerformanceTimer(Sender: TObject);
    procedure sTreeViewDemosKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
    {$ifdef KraftPasMP}PasMPInstance:TPasMP;{$endif}
    KraftPhysics:TKraft;
    TreeNodeKraftPhysics:TTreeNode;
    TreeNodeDemos:TTreeNode;
    TreeNodeDemoDefault:TTreeNode;
    DemoScene:TDemoScene;
    OpenGLInitialized:boolean;
    CurrentCamera,LastCamera,InterpolatedCamera:TCamera;
    LastTime,NowTime,DeltaTime,FST2,FET2,Frames:int64;
    FPS:double;
    FloatDeltaTime:double;
    TimeAccumulator:double;
    LastMouseX,LastMouseY:longint;
    Grabbing,Rotating:boolean;
    KeyLeft,KeyRight,KeyBackwards,KeyForwards,KeyUp,KeyDown:boolean;
    HighResolutionTimer:TKraftHighResolutionTimer;
    ThreadTimer:TThreadTimer;
    PropertyGrid: TOIPropertyGrid;
//    TheObjectInspector: TObjectInspectorDlg;
    ThePropertyEditorHook: TPropertyEditorHook;
    procedure AddRigidBody(RigidBody:TKraftRigidBody);
    procedure AddConstraint(Constraint:TKraftConstraint);
    procedure LoadScene(DemoSceneClass:TDemoSceneClass);
    procedure SetObjectInspectorRoot(AObject: TPersistent);
  end;

var
  FormMain: TFormMain;

implementation

{$R *.lfm}

//uses UnitFormGL;

constructor TThreadTimer.Create;
begin
 FreeOnTerminate:=false;
 inherited Create(true);
end;

destructor TThreadTimer.Destroy;
begin
 inherited Destroy;
end;

procedure TThreadTimer.Draw;
begin
 if assigned(FormMain.KraftPhysics) then begin
  FormMain.OpenGLControlWorld.Paint;
  Application.ProcessMessages;
 end;
end;

procedure TThreadTimer.Execute;
begin
 while not Terminated do begin
  Synchronize(Draw);
  //Sleep(0);
 end;
end;

var GrabRigidBody:TKraftRigidBody;
    GrabShape:TKraftShape;
    GrabDelta:TKraftVector3;
    GrabDistance:single;
//  GrabRigidBodyTransform:TKraftMatrix4x4;
//  GrabCameraTransform:TKraftMatrix4x4;
    GrabConstraint:TKraftConstraintJointGrab;

procedure StartGrab;
var Point,Normal:TKraftVector3;
    s:TKraftShape;
    t:single;
begin
 GrabRigidBody:=nil;
 GrabShape:=nil;
 if assigned(FormMain.KraftPhysics) then begin
  if FormMain.KraftPhysics.RayCast(FormMain.CurrentCamera.Position,PKraftVector3(pointer(@FormMain.CurrentCamera.Matrix[2,0]))^,1024.0,s,t,Point,Normal) then begin
   if assigned(s) and assigned(s.RigidBody) and (s.RigidBody.RigidBodyType=krbtDYNAMIC) then begin
    GrabRigidBody:=s.RigidBody;
    GrabShape:=s;
    GrabDelta:=Vector3Sub(s.RigidBody.Sweep.c,FormMain.CurrentCamera.Position);
    GrabDistance:=Vector3Dist(s.RigidBody.Sweep.c,FormMain.CurrentCamera.Position);
    GrabConstraint:=TKraftConstraintJointGrab.Create(FormMain.KraftPhysics,GrabRigidBody,Point,5.0,0.7,GrabRigidBody.Mass*1000.0);
    GrabRigidBody.SetToAwake;
   end;
  end;
 end;
end;

procedure StopGrab;
begin
 if assigned(GrabRigidBody) then begin
  GrabRigidBody.SetToAwake;
  FreeAndNil(GrabConstraint);
 end;
 GrabRigidBody:=nil;
 GrabShape:=nil;
 GrabConstraint:=nil;
end;

procedure ProcessGrab;
begin
 if assigned(GrabRigidBody) and assigned(GrabConstraint) then begin
  GrabConstraint.SetWorldPoint(Vector3Add(FormMain.CurrentCamera.Position,Vector3ScalarMul(PKraftVector3(pointer(@FormMain.CurrentCamera.Matrix[2,0]))^,GrabDistance)));
  GrabRigidBody.SetToAwake;
 end;
end;

procedure FireSphere;
var RigidBody:TKraftRigidBody;
    Shape:TKraftShape;
begin
 RigidBody:=TKraftRigidBody.Create(FormMain.KraftPhysics);
 RigidBody.SetRigidBodyType(krbtDYNAMIC);
 Shape:=TKraftShapeSphere.Create(FormMain.KraftPhysics,RigidBody,0.5);
 Shape.Friction:=0.4;
 Shape.Restitution:=0.2;
 Shape.Density:=20.0;
 RigidBody.Finish;
 RigidBody.SetWorldTransformation(Matrix4x4Translate(Vector3Add(FormMain.CurrentCamera.Position,Vector3ScalarMul(PKraftVector3(pointer(@FormMain.CurrentCamera.Matrix[2,0]))^,1.0))));
 RigidBody.AngularVelocity:=Vector3Origin;
 RigidBody.LinearVelocity:=Vector3ScalarMul(PKraftVector3(pointer(@FormMain.CurrentCamera.Matrix[2,0]))^,3.0*RigidBody.Mass);
 RigidBody.SetToAwake;
end;

procedure TCamera.Reset;
begin
 LeftRight:=1.0;
 UpDown:=0.0;
 Position:=Vector3(0.0,2.0,4.0);
 Orientation:=QuaternionFromAngles(LeftRight*pi,0.0,UpDown*pi);
 Matrix:=QuaternionToMatrix4x4(Orientation);
 FOV:=90.0;
end;

procedure TCamera.MoveForwards(Speed:TKraftScalar);
begin
 Position:=Vector3Add(Position,Vector3ScalarMul(PKraftVector3(pointer(@Matrix[2,0]))^,Speed));
end;

procedure TCamera.MoveSidewards(Speed:TKraftScalar);
begin
 Position:=Vector3Add(Position,Vector3ScalarMul(PKraftVector3(pointer(@Matrix[0,0]))^,Speed));
end;

procedure TCamera.MoveUpwards(Speed:TKraftScalar);
begin
 Position:=Vector3Add(Position,Vector3ScalarMul(PKraftVector3(pointer(@Matrix[1,0]))^,Speed));
end;

procedure TCamera.RotateCamera(const x,y:TKraftScalar);
begin
 LeftRight:=LeftRight+x;
 UpDown:=Min(Max(UpDown-y,-0.5),0.5);
 Orientation:=QuaternionFromAngles(LeftRight*pi,0.0,UpDown*pi);
{Orientation:=QuaternionTermNormalize(QuaternionMul(QuaternionMul(QuaternionFromAxisAngle(Vector3XAxis,y),
                                                                  Orientation),
                                                    QuaternionFromAxisAngle(Vector3YAxis,x)));{}
 Matrix:=QuaternionToMatrix4x4(Orientation);
end;

procedure TCamera.Interpolate(const a,b:TCamera;const t:TKraftScalar);
begin
 Position:=Vector3Lerp(a.Position,b.Position,t);
 Orientation:=QuaternionSlerp(a.Orientation,b.Orientation,t);
 Matrix:=QuaternionToMatrix4x4(Orientation);
 FOV:=(a.FOV*(1.0-t))+(b.FOV*t);
end;

procedure TCamera.TestCamera;
begin
 if assigned(FormMain.KraftPhysics) then begin
  FormMain.KraftPhysics.PushSphere(Position,0.5);
 end;
end;

procedure DrawObjectTreeNode(Tree:TKraftDynamicAABBTree;Node:PKraftDynamicAABBTreeNode);
var
 I: integer;
begin
//glPolygonMode(GL_FRONT_AND_BACK,GL_LINE);
 glBegin(GL_LINE_STRIP);
 glVertex3f(Node^.AABB.Min.X,Node^.AABB.Min.Y,Node^.AABB.Min.Z);
 glVertex3f(Node^.AABB.Max.X,Node^.AABB.Min.Y,Node^.AABB.Min.Z);
 glVertex3f(Node^.AABB.Max.X,Node^.AABB.Max.Y,Node^.AABB.Min.Z);
 glVertex3f(Node^.AABB.Min.X,Node^.AABB.Max.Y,Node^.AABB.Min.Z);
 glVertex3f(Node^.AABB.Min.X,Node^.AABB.Min.Y,Node^.AABB.Min.Z);
 glEnd;
 glBegin(GL_LINE_STRIP);
 glVertex3f(Node^.AABB.Min.X,Node^.AABB.Min.Y,Node^.AABB.Max.Z);
 glVertex3f(Node^.AABB.Max.X,Node^.AABB.Min.Y,Node^.AABB.Max.Z);
 glVertex3f(Node^.AABB.Max.X,Node^.AABB.Max.Y,Node^.AABB.Max.Z);
 glVertex3f(Node^.AABB.Min.X,Node^.AABB.Max.Y,Node^.AABB.Max.Z);
 glVertex3f(Node^.AABB.Min.X,Node^.AABB.Min.Y,Node^.AABB.Max.Z);
 glEnd;
 glBegin(GL_LINE_STRIP);
 glVertex3f(Node^.AABB.Min.X,Node^.AABB.Min.Y,Node^.AABB.Min.Z);
 glVertex3f(Node^.AABB.Min.X,Node^.AABB.Min.Y,Node^.AABB.Max.Z);
 glEnd;
 glBegin(GL_LINE_STRIP);
 glVertex3f(Node^.AABB.Min.X,Node^.AABB.Max.Y,Node^.AABB.Min.Z);
 glVertex3f(Node^.AABB.Min.X,Node^.AABB.Max.Y,Node^.AABB.Max.Z);
 glEnd;
 glBegin(GL_LINE_STRIP);
 glVertex3f(Node^.AABB.Max.X,Node^.AABB.Max.Y,Node^.AABB.Min.Z);
 glVertex3f(Node^.AABB.Max.X,Node^.AABB.Max.Y,Node^.AABB.Max.Z);
 glEnd;
 glBegin(GL_LINE_STRIP);
 glVertex3f(Node^.AABB.Max.X,Node^.AABB.Min.Y,Node^.AABB.Min.Z);
 glVertex3f(Node^.AABB.Max.X,Node^.AABB.Min.Y,Node^.AABB.Max.Z);
 glEnd;
//glPolygonMode(GL_FRONT_AND_BACK,GL_FILL);
 for I:=0 to 1 do begin
  if Node^.Children[I]>=0 then begin
   DrawObjectTreeNode(Tree,@Tree.Nodes[Node^.Children[I]]);
  end;
 end;
end;

{procedure DrawMeshTree(Shape:TKraftShapeMesh;const CameraMatrix:TKraftMatrix4x4);
var i:integer;
    Node:PKraftMeshSkipListNode;
    ModelViewMatrix:TKraftMatrix4x4;
begin
 glMatrixMode(GL_MODELVIEW);
 ModelViewMatrix:=Matrix4x4TermMul(Shape.WorldTransform,CameraMatrix);
 glLoadMatrixf(pointer(@ModelViewMatrix));
 if DrawMeshTreeDisplayList=0 then begin
  DrawMeshTreeDisplayList:=glGenLists(1);
  glNewList(DrawMeshTreeDisplayList,GL_COMPILE);

  for i:=0 to Shape.Mesh.CountSkipListNodes-1 do begin
   Node:=@Shape.Mesh.SkipListNodes[i];
   glBegin(GL_LINE_STRIP);
   glVertex3f(Node^.AABB.Min.X,Node^.AABB.Min.Y,Node^.AABB.Min.Z);
   glVertex3f(Node^.AABB.Max.X,Node^.AABB.Min.Y,Node^.AABB.Min.Z);
   glVertex3f(Node^.AABB.Max.X,Node^.AABB.Max.Y,Node^.AABB.Min.Z);
   glVertex3f(Node^.AABB.Min.X,Node^.AABB.Max.Y,Node^.AABB.Min.Z);
   glVertex3f(Node^.AABB.Min.X,Node^.AABB.Min.Y,Node^.AABB.Min.Z);
   glEnd;
   glBegin(GL_LINE_STRIP);
   glVertex3f(Node^.AABB.Min.X,Node^.AABB.Min.Y,Node^.AABB.Max.Z);
   glVertex3f(Node^.AABB.Max.X,Node^.AABB.Min.Y,Node^.AABB.Max.Z);
   glVertex3f(Node^.AABB.Max.X,Node^.AABB.Max.Y,Node^.AABB.Max.Z);
   glVertex3f(Node^.AABB.Min.X,Node^.AABB.Max.Y,Node^.AABB.Max.Z);
   glVertex3f(Node^.AABB.Min.X,Node^.AABB.Min.Y,Node^.AABB.Max.Z);
   glEnd;
   glBegin(GL_LINE_STRIP);
   glVertex3f(Node^.AABB.Min.X,Node^.AABB.Min.Y,Node^.AABB.Min.Z);
   glVertex3f(Node^.AABB.Min.X,Node^.AABB.Min.Y,Node^.AABB.Max.Z);
   glEnd;
   glBegin(GL_LINE_STRIP);
   glVertex3f(Node^.AABB.Min.X,Node^.AABB.Max.Y,Node^.AABB.Min.Z);
   glVertex3f(Node^.AABB.Min.X,Node^.AABB.Max.Y,Node^.AABB.Max.Z);
   glEnd;
   glBegin(GL_LINE_STRIP);
   glVertex3f(Node^.AABB.Max.X,Node^.AABB.Max.Y,Node^.AABB.Min.Z);
   glVertex3f(Node^.AABB.Max.X,Node^.AABB.Max.Y,Node^.AABB.Max.Z);
   glEnd;
   glBegin(GL_LINE_STRIP);
   glVertex3f(Node^.AABB.Max.X,Node^.AABB.Min.Y,Node^.AABB.Min.Z);
   glVertex3f(Node^.AABB.Max.X,Node^.AABB.Min.Y,Node^.AABB.Max.Z);
   glEnd;
  end;

  glEndList;
 end;

 if DrawMeshTreeDisplayList<>0 then begin
  glCallList(DrawMeshTreeDisplayList);
 end;
end;}

procedure DrawObjectAABB(const AABB:TKraftAABB);
begin
//glPolygonMode(GL_FRONT_AND_BACK,GL_LINE);
 glBegin(GL_LINE_STRIP);
 glVertex3f(AABB.Min.X,AABB.Min.Y,AABB.Min.Z);
 glVertex3f(AABB.Max.X,AABB.Min.Y,AABB.Min.Z);
 glVertex3f(AABB.Max.X,AABB.Max.Y,AABB.Min.Z);
 glVertex3f(AABB.Min.X,AABB.Max.Y,AABB.Min.Z);
 glVertex3f(AABB.Min.X,AABB.Min.Y,AABB.Min.Z);
 glEnd;
 glBegin(GL_LINE_STRIP);
 glVertex3f(AABB.Min.X,AABB.Min.Y,AABB.Max.Z);
 glVertex3f(AABB.Max.X,AABB.Min.Y,AABB.Max.Z);
 glVertex3f(AABB.Max.X,AABB.Max.Y,AABB.Max.Z);
 glVertex3f(AABB.Min.X,AABB.Max.Y,AABB.Max.Z);
 glVertex3f(AABB.Min.X,AABB.Min.Y,AABB.Max.Z);
 glEnd;
 glBegin(GL_LINE_STRIP);
 glVertex3f(AABB.Min.X,AABB.Min.Y,AABB.Min.Z);
 glVertex3f(AABB.Min.X,AABB.Min.Y,AABB.Max.Z);
 glEnd;
 glBegin(GL_LINE_STRIP);
 glVertex3f(AABB.Min.X,AABB.Max.Y,AABB.Min.Z);
 glVertex3f(AABB.Min.X,AABB.Max.Y,AABB.Max.Z);
 glEnd;
 glBegin(GL_LINE_STRIP);
 glVertex3f(AABB.Max.X,AABB.Max.Y,AABB.Min.Z);
 glVertex3f(AABB.Max.X,AABB.Max.Y,AABB.Max.Z);
 glEnd;
 glBegin(GL_LINE_STRIP);
 glVertex3f(AABB.Max.X,AABB.Min.Y,AABB.Min.Z);
 glVertex3f(AABB.Max.X,AABB.Min.Y,AABB.Max.Z);
 glEnd;
end;

procedure TFormMain.AddRigidBody(RigidBody:TKraftRigidBody);
var TreeNodeRigidBody,TreeNodeRigidBodyShape:TTreeNode;
    Shape:TKraftShape;
begin
 TreeNodeRigidBody:=sTreeViewMain.Items.AddChildObject(TreeNodeKraftPhysics,RigidBody.ClassName,RigidBody);
 Shape:=RigidBody.ShapeFirst;
 while assigned(Shape) do begin
  TreeNodeRigidBodyShape:=sTreeViewMain.Items.AddChildObject(TreeNodeRigidBody,Shape.ClassName,Shape);
  if assigned(TreeNodeRigidBodyShape) then begin
  end;
  Shape:=Shape.ShapeNext;
 end;
end;

procedure TFormMain.AddConstraint(Constraint:TKraftConstraint);
var Index:longint;
    TreeNodeConstraint,TreeNodeRigidBody,TreeNodeRigidBodyShape:TTreeNode;
    RigidBody:TKraftRigidBody;
    Shape:TKraftShape;
begin
 TreeNodeConstraint:=sTreeViewMain.Items.AddChildObject(TreeNodeKraftPhysics,Constraint.ClassName,Constraint);
 for Index:=0 to length(Constraint.RigidBodies)-1 do begin
  RigidBody:=Constraint.RigidBodies[Index];
  if assigned(RigidBody) then begin
   TreeNodeRigidBody:=sTreeViewMain.Items.AddChildObject(TreeNodeConstraint,RigidBody.ClassName,RigidBody);
   Shape:=RigidBody.ShapeFirst;
   while assigned(Shape) do begin
    TreeNodeRigidBodyShape:=sTreeViewMain.Items.AddChildObject(TreeNodeRigidBody,Shape.ClassName,Shape);
    if assigned(TreeNodeRigidBodyShape) then begin
    end;
    Shape:=Shape.ShapeNext;
   end;
  end;
 end;
end;

procedure TFormMain.LoadScene(DemoSceneClass:TDemoSceneClass);
var RigidBody:TKraftRigidBody;
    Constraint:TKraftConstraint;
begin

 sTreeViewMain.Items.BeginUpdate;
 try

  TreeNodeKraftPhysics:=nil;

  SetObjectInspectorRoot(nil);
  sTreeViewMain.Items.Clear;

  FreeAndNil(DemoScene);

  DemoScene:=DemoSceneClass.Create(KraftPhysics);

  TreeNodeKraftPhysics:=sTreeViewMain.Items.AddObjectFirst(nil,'TKraft',KraftPhysics);

  RigidBody:=KraftPhysics.RigidBodyFirst;
  while assigned(RigidBody) do begin
   AddRigidBody(RigidBody);
   RigidBody:=RigidBody.RigidBodyNext;
  end;

  Constraint:=KraftPhysics.ConstraintFirst;
  while assigned(Constraint) do begin
   AddConstraint(Constraint);
   Constraint:=Constraint.Next;
  end;

  sTreeViewMain.Selected:=TreeNodeKraftPhysics;
  TreeNodeKraftPhysics.Expand(true);
  SetObjectInspectorRoot(KraftPhysics);

  CurrentCamera.Reset;
  LastCamera:=CurrentCamera;

 finally
  sTreeViewMain.Items.EndUpdate;
 end;

 if assigned(DemoScene) then begin
  DemoScene.StoreWorldTransforms;
  DemoScene.InterpolateWorldTransforms(0.0);
 end;

 KraftPhysics.StoreWorldTransforms;
 KraftPhysics.InterpolateWorldTransforms(0.0);

 LastTime:=HighResolutionTimer.GetTime;

 OpenGLControlWorld.SetFocus;

end;

procedure TFormMain.FormCreate(Sender: TObject);
var Index:longint;
begin

 ThePropertyEditorHook:=TPropertyEditorHook.Create(nil);

{TheObjectInspector:=TObjectInspectorDlg.Create(Application);
 TheObjectInspector.PropertyEditorHook:=ThePropertyEditorHook;
 TheObjectInspector.SetBounds(10,10,240,500);{}

 PropertyGrid:=TOIPropertyGrid.CreateWithParams(Self,ThePropertyEditorHook
      ,[tkUnknown, tkInteger, tkChar, tkEnumeration, tkFloat, tkSet{, tkMethod}
      , tkSString, tkLString, tkAString, tkWString, tkVariant
      , tkArray, tkRecord, tkInterface, tkClass, tkObject, tkWChar, tkBool
      , tkInt64, tkQWord],
      25);
 PropertyGrid.Name:='PropertyGrid';
 PropertyGrid.Parent:=sGroupBoxPropertyEditor;
 PropertyGrid.Align:=alClient;
 SetObjectInspectorRoot(nil);
 //TheObjectInspector.Show;

 DemoScene:=nil;

 OpenGLInitialized:=false;

{$ifdef KraftPasMP}
 PasMPInstance:=TPasMP.Create(-1,-1,-1,0,false);

 KraftPhysics:=TKraft.Create(PasMPInstance);
{$else}
 KraftPhysics:=TKraft.Create(-1);
{$endif}

 KraftPhysics.SetFrequency(120.0);

 KraftPhysics.VelocityIterations:=8;

 KraftPhysics.PositionIterations:=3;

 KraftPhysics.SpeculativeIterations:=8;

 KraftPhysics.TimeOfImpactIterations:=20;

 KraftPhysics.Gravity.y:=-9.81;
 
 ThreadTimer:=TThreadTimer.Create;

 KeyLeft:=false;
 KeyRight:=false;
 KeyBackwards:=false;
 KeyForwards:=false;
 KeyUp:=false;
 KeyDown:=false;

 //ReadyGL:=false;

 Grabbing:=false;

 Rotating:=false;

 CurrentCamera.Reset;
 LastCamera:=CurrentCamera;

 HighResolutionTimer:=TKraftHighResolutionTimer.Create(60);

 LastTime:=HighResolutionTimer.GetTime;

 FPS:=0.0;

 FST2:=LastTime;
 FET2:=LastTime;
 Frames:=0;

 TimeAccumulator:=0.0;

 sTreeViewDemos.Items.BeginUpdate;
 try
  DemoScenes.Sort;
  TreeNodeDemos:=sTreeViewDemos.Items.AddChildFirst(nil,'Demos');
  for Index:=0 to DemoScenes.Count-1 do begin
   sTreeViewDemos.Items.AddChildObject(TreeNodeDemos,DemoScenes.Strings[Index],DemoScenes.Objects[Index]);
  end;
//TreeNodeDemoDefault:=TreeNodeDemos.FindNode('Sphere on SDF terrain');
  TreeNodeDemoDefault:=TreeNodeDemos.FindNode('Raycast vehicle');
  if not assigned(TreeNodeDemoDefault) then begin
   TreeNodeDemoDefault:=TreeNodeDemos.GetFirstChild;
  end;
 finally
  sTreeViewDemos.Items.EndUpdate;
 end;
 TreeNodeDemos.Expand(true);

// LoadScene(TDemoSceneBoxOnPlane);

end;

procedure TFormMain.CheckBoxSingleThreadedChange(Sender: TObject);
begin
end;

procedure TFormMain.FormDestroy(Sender: TObject);
begin
 FreeAndNil(DemoScene);
 FreeAndNil(KraftPhysics);
{$ifdef KraftPasMP}
 FreeAndNil(PasMPInstance);
{$endif}
 ThreadTimer.Terminate;
 if ThreadTimer.Suspended then begin
  ThreadTimer.Resume;
 end;
 ThreadTimer.WaitFor;
 ThreadTimer.Free;
 HighResolutionTimer.Free;
 ThePropertyEditorHook.Free;
end;

procedure TFormMain.SetObjectInspectorRoot(AObject: TPersistent);
var Selection: TPersistentSelectionList;
begin
 if assigned(AObject) then begin
  ThePropertyEditorHook.LookupRoot:=AObject;
  Selection:=TPersistentSelectionList.Create;
  try
   Selection.Add(AObject);
   //TheObjectInspector.Selection:=Selection;
   PropertyGrid.Selection:=Selection;
  finally
   Selection.Free;
  end;
 end else begin
  ThePropertyEditorHook.LookupRoot:=nil;
  Selection:=TPersistentSelectionList.Create;
  try
   //TheObjectInspector.Selection:=Selection;
   PropertyGrid.Selection:=Selection;
  finally
   Selection.Free;
  end;
 end;
end;

procedure TFormMain.N2Click(Sender: TObject);
begin
 close;
end;

procedure TFormMain.OpenGLControlWorldClick(Sender: TObject);
begin
 OpenGLControlWorld.SetFocus;
end;

procedure TFormMain.OpenGLControlWorldEnter(Sender: TObject);
begin
end;

procedure TFormMain.OpenGLControlWorldExit(Sender: TObject);
begin
 Grabbing:=false;
 Rotating:=false;
 KeyLeft:=false;
 KeyRight:=false;
 KeyBackwards:=false;
 KeyForwards:=false;
 KeyUp:=false;
 KeyDown:=false;
 StopGrab;
end;

procedure TFormMain.OpenGLControlWorldKeyDown(Sender: TObject; var Key: Word;
 Shift: TShiftState);
begin
{if Rotating then}begin
  case Key of
   VK_SPACE:begin
    if (assigned(FormMain.DemoScene) and FormMain.DemoScene.HasOwnKeyboardControls) then begin
     FormMain.DemoScene.KeyDown(VK_SPACE);
    end else begin
     FireSphere;
    end;
   end;
   VK_LEFT,ord('A'):begin
    if (assigned(FormMain.DemoScene) and FormMain.DemoScene.HasOwnKeyboardControls) then begin
     FormMain.DemoScene.KeyDown(VK_LEFT);
    end else begin
     KeyLeft:=true;
    end;
   end;
   VK_RIGHT,ord('D'):begin
    if (assigned(FormMain.DemoScene) and FormMain.DemoScene.HasOwnKeyboardControls) then begin
     FormMain.DemoScene.KeyDown(VK_RIGHT);
    end else begin
     KeyRight:=true;
    end;
   end;
   VK_UP,ord('W'):begin
    if (assigned(FormMain.DemoScene) and FormMain.DemoScene.HasOwnKeyboardControls) then begin
     FormMain.DemoScene.KeyDown(VK_UP);
    end else begin
     KeyForwards:=true;
    end;
   end;
   VK_DOWN,ord('S'):begin
    if (assigned(FormMain.DemoScene) and FormMain.DemoScene.HasOwnKeyboardControls) then begin
     FormMain.DemoScene.KeyDown(VK_DOWN);
    end else begin
     KeyBackwards:=true;
    end;
   end;
   VK_PRIOR,ord('R'):begin
    if (assigned(FormMain.DemoScene) and FormMain.DemoScene.HasOwnKeyboardControls) then begin
     FormMain.DemoScene.KeyDown(VK_PRIOR);
    end else begin
     KeyUp:=true;
    end;
   end;
   VK_NEXT,ord('F'):begin
    if (assigned(FormMain.DemoScene) and FormMain.DemoScene.HasOwnKeyboardControls) then begin
     FormMain.DemoScene.KeyDown(VK_NEXT);
    end else begin
     KeyDown:=true;
    end;
   end;
   else begin
    if (assigned(FormMain.DemoScene) and FormMain.DemoScene.HasOwnKeyboardControls) then begin
     FormMain.DemoScene.KeyDown(Key);
    end;
   end;
  end;
 end;
end;

procedure TFormMain.OpenGLControlWorldKeyUp(Sender: TObject; var Key: Word;
 Shift: TShiftState);
begin
{if Rotating then{}begin
  case Key of
   VK_SPACE:begin
    if (assigned(FormMain.DemoScene) and FormMain.DemoScene.HasOwnKeyboardControls) then begin
     FormMain.DemoScene.KeyUp(VK_SPACE);
    end else begin
    end;
{   FormMain.sTreeViewMain.Items.BeginUpdate;
    try
     FormMain.AddRigidBody(RigidBody);
    finally
     FormMain.sTreeViewMain.Items.EndUpdate;
    end;{}
   end;
   VK_LEFT,ord('A'):begin
    if (assigned(FormMain.DemoScene) and FormMain.DemoScene.HasOwnKeyboardControls) then begin
     FormMain.DemoScene.KeyUp(VK_LEFT);
    end else begin
     KeyLeft:=false;
    end;
   end;
   VK_RIGHT,ord('D'):begin
    if (assigned(FormMain.DemoScene) and FormMain.DemoScene.HasOwnKeyboardControls) then begin
     FormMain.DemoScene.KeyUp(VK_RIGHT);
    end else begin
     KeyRight:=false;
    end;
   end;
   VK_UP,ord('W'):begin
    if (assigned(FormMain.DemoScene) and FormMain.DemoScene.HasOwnKeyboardControls) then begin
     FormMain.DemoScene.KeyUp(VK_UP);
    end else begin
     KeyForwards:=false;
    end;
   end;
   VK_DOWN,ord('S'):begin
    if (assigned(FormMain.DemoScene) and FormMain.DemoScene.HasOwnKeyboardControls) then begin
     FormMain.DemoScene.KeyUp(VK_DOWN);
    end else begin
     KeyBackwards:=false;
    end;
   end;
   VK_PRIOR,ord('R'):begin
    if (assigned(FormMain.DemoScene) and FormMain.DemoScene.HasOwnKeyboardControls) then begin
     FormMain.DemoScene.KeyUp(VK_PRIOR);
    end else begin
     KeyUp:=false;
    end;
   end;
   VK_NEXT,ord('F'):begin
    if (assigned(FormMain.DemoScene) and FormMain.DemoScene.HasOwnKeyboardControls) then begin
     FormMain.DemoScene.KeyUp(VK_NEXT);
    end else begin
     KeyDown:=false;
    end;
   end;
   else begin
    if (assigned(FormMain.DemoScene) and FormMain.DemoScene.HasOwnKeyboardControls) then begin
     FormMain.DemoScene.KeyUp(Key);
    end;
   end;
  end;
 end;
end;

procedure TFormMain.OpenGLControlWorldMouseDown(Sender: TObject;
 Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 LastMouseX:=x;
 LastMouseY:=y;
 Rotating:=false;
 case Button of
  mbLeft:begin
   if not (assigned(FormMain.DemoScene) and FormMain.DemoScene.HasOwnKeyboardControls) then begin
    Rotating:=true;
   end;
// Cursor:=crNone;
   OpenGLControlWorld.SetFocus;
  end;
  mbRight:begin
   if not (assigned(FormMain.DemoScene) and FormMain.DemoScene.HasOwnKeyboardControls) then begin
    Grabbing:=true;
    Rotating:=true;
   end;
// Cursor:=crNone;
   OpenGLControlWorld.SetFocus;
   if not (assigned(FormMain.DemoScene) and FormMain.DemoScene.HasOwnKeyboardControls) then begin
    StartGrab;
   end;
  end;
 end;
end;

procedure TFormMain.OpenGLControlWorldMouseMove(Sender: TObject;
 Shift: TShiftState; X, Y: Integer);
var xrel,yrel:longint;
begin
 if not (assigned(FormMain.DemoScene) and FormMain.DemoScene.HasOwnKeyboardControls) then begin
  if Rotating then begin
   xrel:=LastMouseX-x;
   yrel:=LastMouseY-y;
   if (xrel<>0) or (yrel<>0) then begin
    CurrentCamera.RotateCamera(xrel*0.002,yrel*0.002);
   end;
   if (x<100) or (y<100) or (x>=(OpenGLControlWorld.ClientWidth-100)) or (y>=(OpenGLControlWorld.ClientHeight-100)) then begin
    LastMouseX:=OpenGLControlWorld.ClientWidth div 2;
    LastMouseY:=OpenGLControlWorld.ClientHeight div 2;
    Mouse.CursorPos:=OpenGLControlWorld.ClientToScreen(Point(OpenGLControlWorld.ClientWidth div 2,OpenGLControlWorld.ClientHeight div 2));
   end else begin
    LastMouseX:=x;
    LastMouseY:=y;
   end;
  end;
 end;
end;

procedure TFormMain.OpenGLControlWorldMouseUp(Sender: TObject;
 Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 if not (assigned(FormMain.DemoScene) and FormMain.DemoScene.HasOwnKeyboardControls) then begin
  if Grabbing then begin
   Grabbing:=false;
   StopGrab;
  end;
  if Rotating then begin
  //Cursor:=crDefault;
   Rotating:=false;
   KeyLeft:=false;
   KeyRight:=false;
   KeyBackwards:=false;
   KeyForwards:=false;
   KeyUp:=false;
   KeyDown:=false;
  end;
 end;
end;

procedure TFormMain.OpenGLControlWorldMouseWheel(Sender: TObject;
 Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean
 );
begin
 CurrentCamera.FOV:=Min(Max(CurrentCamera.FOV+(WheelDelta*0.01),15.0),160.0);
 Handled:=true;
end;

procedure TFormMain.OpenGLControlWorldPaint(Sender: TObject);
const
 GlobalAmbient: array[0..3] of GLFLOAT = (0.025,0.025,0.025,1);
 Licht0Ambient: array[0..3] of GLFLOAT = (0.2,0.2,0.2,1);
 Licht0Diffuse: array[0..3] of GLFLOAT = (0.8,0.8,0.8,1);
 Licht0Specular: array[0..3] of GLFLOAT = (0.025,0.025,0.025,1);
 LModellAmbient: array[0..3] of GLFLOAT = (0.025,0.025,0.025,1);
 Licht0Pos: array[0..3] of GLFLOAT = (0.0,160.0,160.0,1.0);
 MaterialDiffuse: array[0..3] of GLFLOAT = (0.8,0.8,0.8,1);
 MaterialSpecular: array[0..3] of GLFLOAT = (0.1,0.1,0.1,1);
 MaterialAmbient: array[0..3] of GLFLOAT = (0.2,0.2,0.2,1);
 MaterialShininess: array[0..3] of GLFLOAT = (0.1,0.1,0.1,1);
var i:longint;
    m:TKraftMatrix4x4;
    v:TKraftVector4;
    vv:TKraftVector3;
    RigidBody:TKraftRigidBody;
    Shape:TKraftShape;
    PhysicsTimeStep:double;
    Constraint:TKraftConstraint;
    UpdateCameraDone:boolean;
begin
 if not OpenGLInitialized then begin
  if glext.Load_GL_version_1_2 and
     glext.Load_GL_version_1_3 and
     glext.Load_GL_version_1_4 and
     glext.Load_GL_version_1_5 and
     glext.Load_GL_version_2_0 then begin
   OpenGLInitialized:=true;
{$ifdef Windows}
   if Load_WGL_EXT_swap_control then begin
    wglSwapIntervalEXT(0);
   end;
{$endif}
  end;
 end;
 if OpenGLInitialized then begin
  if assigned(FormMain.KraftPhysics) then begin

   NowTime:=HighResolutionTimer.GetTime;
   DeltaTime:=NowTime-LastTime;

 { if DeltaTime>=HighResolutionTimer.FrameInterval then}begin

    LastTime:=NowTime;

    FloatDeltaTime:=Min(Max(HighResolutionTimer.ToFloatSeconds(DeltaTime),0.0),1.0);

    PhysicsTimeStep:=1.0/FormMain.KraftPhysics.WorldFrequency;

    TimeAccumulator:=TimeAccumulator+FloatDeltaTime;
    while TimeAccumulator>=PhysicsTimeStep do begin
     TimeAccumulator:=TimeAccumulator-PhysicsTimeStep;
     LastCamera:=CurrentCamera;
     if Grabbing then begin
      ProcessGrab;
     end;
     FormMain.KraftPhysics.StoreWorldTransforms;
     if assigned(FormMain.DemoScene) then begin
      FormMain.DemoScene.StoreWorldTransforms;
      UpdateCameraDone:=FormMain.DemoScene.UpdateCamera(CurrentCamera.Position,CurrentCamera.Orientation);
      FormMain.DemoScene.Step(PhysicsTimeStep);
     end else begin
      UpdateCameraDone:=false;
     end;
     FormMain.KraftPhysics.Step(PhysicsTimeStep);
     CurrentCamera.TestCamera;
     if not UpdateCameraDone then begin
      if KeyLeft then begin
       CurrentCamera.MoveSidewards(PhysicsTimeStep*10.0);
      end;
      if KeyRight then begin
       CurrentCamera.MoveSidewards(-(PhysicsTimeStep*10.0));
      end;
      if KeyForwards then begin
       CurrentCamera.MoveForwards(PhysicsTimeStep*10.0);
      end;
      if KeyBackwards then begin
       CurrentCamera.MoveForwards(-(PhysicsTimeStep*10.0));
      end;
      if KeyUp then begin
       CurrentCamera.MoveUpwards(PhysicsTimeStep*10.0);
      end;
      if KeyDown then begin
       CurrentCamera.MoveUpwards(-(PhysicsTimeStep*10.0));
      end;
     end;
     CurrentCamera.TestCamera;
    end;
    if assigned(FormMain.DemoScene) then begin
     FormMain.DemoScene.InterpolateWorldTransforms(TimeAccumulator/PhysicsTimeStep);
    end;
    FormMain.KraftPhysics.InterpolateWorldTransforms(TimeAccumulator/PhysicsTimeStep);
    InterpolatedCamera.Interpolate(LastCamera,CurrentCamera,TimeAccumulator/PhysicsTimeStep);

    inc(Frames);
    if abs(FST2-NowTime)>=HighResolutionTimer.Frequency then begin
     FET2:=FST2;
     FST2:=NowTime;
     if (FST2-FET2)<>0 then begin
      FPS:=(Frames*HighResolutionTimer.Frequency)/(FST2-FET2);
     end;
     Frames:=0;
    end;

 //   wglMakeCurrent(hDCGL,hGL);
    glViewPort(0,0,OpenGLControlWorld.ClientWidth,OpenGLControlWorld.ClientHeight);
    glClearDepth(1.0);
    glClearColor(0.0,0.0,0.0,0.0);
    glClear(GL_COLOR_BUFFER_BIT or GL_STENCIL_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();

   (**)
    glColor4f(0.0,0.0,0.0,0.0);//0.1725,0.3275,0.6275,1.0);
    glDisable(GL_DEPTH_TEST);
    glDisable(GL_LIGHTING);
    glDisable(GL_CULL_FACE);
    glDepthMask(GL_FALSE);
    glPolygonMode(GL_FRONT_AND_BACK,GL_FILL);
   {}glBegin(GL_QUADS);
    glVertex3f(1.0,-1.0,0.0);
    glVertex3f(1.0,1.0,0.0);
    glVertex3f(-1.0,1.0,0.0);
    glVertex3f(-1.0,-1.0,0.0);
    glEnd;{}
    glDepthMask(GL_TRUE);
    glMatrixMode(GL_PROJECTION);
    m:=Matrix4x4Perspective(InterpolatedCamera.FOV,ClientWidth/ClientHeight,0.1,1024.0);
    glLoadMatrixf(pointer(@m));
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LEQUAL);
    glCullFace(GL_BACK);
    glDisable(GL_BLEND);
    glEnable(GL_COLOR_MATERIAL);
    glEnable(GL_LIGHTING);
    glEnable(GL_LIGHT0);
    glLightModelfv(GL_LIGHT_MODEL_AMBIENT,@LModellAmbient);
    glLightModelfv(GL_LIGHT_MODEL_AMBIENT,@GlobalAmbient);
    m:=Matrix4x4LookAt(InterpolatedCamera.Position,Vector3Add(InterpolatedCamera.Position,PKraftVector3(pointer(@InterpolatedCamera.Matrix[2,0]))^),PKraftVector3(pointer(@InterpolatedCamera.Matrix[1,0]))^);
    v:=PKraftVector4(pointer(@Licht0Pos))^;
    Vector4MatrixMul(v,m);
    glLightfv(GL_LIGHT0,GL_POSITION,@v);
    glLightfv(GL_LIGHT0,GL_AMBIENT,@Licht0Ambient);
    glLightfv(GL_LIGHT0,GL_DIFFUSE,@Licht0Diffuse);
    glLightfv(GL_LIGHT0,GL_SPECULAR,@Licht0Specular);

    glMaterialfv(GL_FRONT_AND_BACK,GL_DIFFUSE,@MaterialDiffuse);
    glMaterialfv(GL_FRONT_AND_BACK,GL_SPECULAR,@MaterialSpecular);
    glMaterialfv(GL_FRONT_AND_BACK,GL_AMBIENT,@MaterialAmbient);
    glMaterialfv(GL_FRONT_AND_BACK,GL_SHININESS,@MaterialShininess);

    glShadeModel(GL_SMOOTH);

    glDepthFunc(GL_LESS);
    glCullFace(GL_BACK);

    glEnable(GL_LIGHTING);

    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    glLoadMatrixf(@m);

 ///   i:=0;
    glEnable(GL_CULL_FACE);
    glPolygonMode(GL_FRONT_AND_BACK,GL_FILL);
    if FormMain.sCheckBoxDrawSolid.Checked then begin
     RigidBody:=FormMain.KraftPhysics.RigidBodyFirst;
     while assigned(RigidBody) do begin
      if RigidBody.IsStatic then begin
       glColor4f(0.75,0.5,0.125,1);
      end else if krbfAwake in RigidBody.Flags then begin
       glColor4f(1.0,0.0,1.0,1.0);
      end else begin
       glColor4f(1.0,0.0,0.0,1.0);
      end;
      Shape:=RigidBody.ShapeFirst;
      while assigned(Shape) do begin
       Shape.Draw(m);
       Shape:=Shape.ShapeNext;
      end;
      RigidBody:=RigidBody.RigidBodyNext;
     end;
    end;

    glDepthFunc(GL_LEQUAL);

    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
    glDisable(GL_LIGHTING);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    glLoadMatrixf(@m);
    glLineWidth(2);
    glPolygonOffset(-1,1);
    if FormMain.sCheckBoxDrawDynamicAABBTree.Checked then begin
     if FormMain.KraftPhysics.StaticAABBTree.Root>=0 then begin
      glColor4f(0.5,0.5,1.0,0.75);
      DrawObjectTreeNode(FormMain.KraftPhysics.StaticAABBTree,@FormMain.KraftPhysics.StaticAABBTree.Nodes[FormMain.KraftPhysics.StaticAABBTree.Root]);
     end;
     glPolygonOffset(-2,2);
     if FormMain.KraftPhysics.SleepingAABBTree.Root>=0 then begin
      glColor4f(1.0,0.5,0.5,0.75);
      DrawObjectTreeNode(FormMain.KraftPhysics.SleepingAABBTree,@FormMain.KraftPhysics.SleepingAABBTree.Nodes[FormMain.KraftPhysics.SleepingAABBTree.Root]);
     end;
     glPolygonOffset(-3,3);
     if FormMain.KraftPhysics.DynamicAABBTree.Root>=0 then begin
      glColor4f(0.5,1.0,0.5,0.75);
      DrawObjectTreeNode(FormMain.KraftPhysics.DynamicAABBTree,@FormMain.KraftPhysics.DynamicAABBTree.Nodes[FormMain.KraftPhysics.DynamicAABBTree.Root]);
     end;
     glPolygonOffset(-4,4);
     if FormMain.KraftPhysics.KinematicAABBTree.Root>=0 then begin
      glColor4f(1.0,0.5,1.0,0.75);
      DrawObjectTreeNode(FormMain.KraftPhysics.KinematicAABBTree,@FormMain.KraftPhysics.KinematicAABBTree.Nodes[FormMain.KraftPhysics.KinematicAABBTree.Root]);
     end;
     glPolygonOffset(-5,5);
   //  DrawObjectAABB(ShapeMesh.WorldAABB);
     glLineWidth(1);
     RigidBody:=FormMain.KraftPhysics.RigidBodyFirst;
     while assigned(RigidBody) do begin
      Shape:=RigidBody.ShapeFirst;
      while assigned(Shape) do begin
       if krbfAwake in Shape.RigidBody.Flags then begin
        glColor4f(1.0,1.0,1.0,0.75);
        DrawObjectAABB(Shape.WorldAABB);
       end else begin
        glColor4f(1.0,0.5,0.5,0.75);
        DrawObjectAABB(Shape.WorldAABB);
       end;
       Shape:=Shape.ShapeNext;
      end;
      RigidBody:=RigidBody.RigidBodyNext;
     end;
    end;
    glPolygonOffset(-1,1);
    glLineWidth(1);

    glEnable(GL_CULL_FACE);
    glDisable(GL_LIGHTING);
    glPolygonMode(GL_FRONT_AND_BACK,GL_LINE);
    glEnable(GL_POLYGON_OFFSET_LINE);
    glEnable(GL_POLYGON_OFFSET_POINT);
    glPolygonOffset(-8,8);
    glPointSize(1);
    glLineWidth(1);
    if FormMain.sCheckBoxDrawWireFrame.Checked then begin
     RigidBody:=FormMain.KraftPhysics.RigidBodyFirst;
     while assigned(RigidBody) do begin
      Shape:=RigidBody.ShapeFirst;
      while assigned(Shape) do begin
       glColor4f(1.0,1.0,1.0,1.0);
       Shape.Draw(m);
       Shape:=Shape.ShapeNext;
      end;
      RigidBody:=RigidBody.RigidBodyNext;
     end;
    end;
    glDisable(GL_POLYGON_OFFSET_LINE);
    glDisable(GL_POLYGON_OFFSET_POINT);

    if assigned(FormMain.DemoScene) then begin
     FormMain.DemoScene.DebugDraw;
    end;

    glDisable(GL_LIGHTING);
    glEnable(GL_POLYGON_OFFSET_LINE);
    glEnable(GL_POLYGON_OFFSET_POINT);
    glPolygonOffset(-8,8);
    glPointSize(8);
    glLineWidth(4);
    glDisable(GL_DEPTH_TEST);
    if FormMain.sCheckBoxDrawContacts.Checked then begin
     FormMain.KraftPhysics.ContactManager.DebugDraw(m);
    end;
    glDisable(GL_POLYGON_OFFSET_LINE);
    glDisable(GL_POLYGON_OFFSET_POINT);

    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();

    glEnable(GL_DEPTH_TEST);
    if FormMain.sCheckBoxDrawConstraints.Checked then begin
     Constraint:=FormMain.KraftPhysics.ConstraintFirst;
     while assigned(Constraint) do begin
{     if assigned(Constraint.RigidBodies[0]) and
         assigned(Constraint.RigidBodies[1]) then begin
       glLineWidth(5);
       glColor4f(1.0,1.0,0.125,1.0);
       glBegin(GL_LINE_STRIP);
       vv:=Vector3TermMatrixMul(PKraftVector3(pointer(@Constraint.RigidBodies[0].ShapeFirst.InterpolatedWorldTransform[3,0]))^,m);
       glVertex3fv(@vv);
       vv:=Vector3TermMatrixMul(PKraftVector3(pointer(@Constraint.RigidBodies[1].ShapeFirst.InterpolatedWorldTransform[3,0]))^,m);
       glVertex3fv(@vv);
       glEnd;
      end;{}
      if Constraint is TKraftConstraintJointRope then begin
       glLineWidth(5);
       glColor4f(0.125,1.0,1.0,1.0);
       glBegin(GL_LINE_STRIP);
       vv:=Vector3TermMatrixMul(TKraftConstraintJointRope(Constraint).GetAnchorA,m);
       glVertex3fv(@vv);
       vv:=Vector3TermMatrixMul(TKraftConstraintJointRope(Constraint).GetAnchorB,m);
       glVertex3fv(@vv);
       glEnd;
      end;
      if Constraint is TKraftConstraintJointBallSocket then begin
       glLineWidth(5);
       glColor4f(0.125,1.0,1.0,1.0);
       glBegin(GL_LINE_STRIP);
       vv:=Vector3TermMatrixMul(TKraftConstraintJointBallSocket(Constraint).GetAnchorA,m);
       glVertex3fv(@vv);
       vv:=Vector3TermMatrixMul(TKraftConstraintJointBallSocket(Constraint).GetAnchorB,m);
       glVertex3fv(@vv);
       glEnd;
      end;
      if Constraint is TKraftConstraintJointDistance then begin
       glLineWidth(5);
       glColor4f(0.125,1.0,1.0,1.0);
       glBegin(GL_LINE_STRIP);
       vv:=Vector3TermMatrixMul(TKraftConstraintJointDistance(Constraint).GetAnchorA,m);
       glVertex3fv(@vv);
       vv:=Vector3TermMatrixMul(TKraftConstraintJointDistance(Constraint).GetAnchorB,m);
       glVertex3fv(@vv);
       glEnd;
      end;
      if Constraint is TKraftConstraintJointHinge then begin
       glLineWidth(5);
       glColor4f(0.125,1.0,1.0,1.0);
       glBegin(GL_LINE_STRIP);
       vv:=Vector3TermMatrixMul(TKraftConstraintJointHinge(Constraint).GetAnchorA,m);
       glVertex3fv(@vv);
       vv:=Vector3TermMatrixMul(TKraftConstraintJointHinge(Constraint).GetAnchorB,m);
       glVertex3fv(@vv);
       glEnd;
      end;
      Constraint:=Constraint.Next;
     end;
    end;
    glDisable(GL_DEPTH_TEST);

    if FormMain.sCheckBoxDrawConstraints.Checked then begin
     if assigned(GrabRigidBody) then begin
      glLineWidth(10);
      glColor4f(1.0,1.0,0.125,1.0);
      glBegin(GL_LINE_STRIP);
      vv:=Vector3TermMatrixMul(GrabConstraint.GetWorldPoint,m);
      glVertex3fv(@vv);
      vv:=Vector3TermMatrixMul(GrabConstraint.GetAnchor,m);
      glVertex3fv(@vv);
      glEnd;
     end;
    end;

    glMatrixMode(GL_PROJECTION);
    glClear(GL_STENCIL_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
    glLoadIdentity();
    glFrustum(-0.01,0.01,-0.0075,0.0075,0.01,1000.0);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    glDisable(GL_DEPTH_TEST);
    glDisable(GL_LIGHTING);
    glColor4f(1,1,1,1);
    if not (assigned(FormMain.DemoScene) and FormMain.DemoScene.HasOwnKeyboardControls) then begin
     glPointSize(2);
     glLineWidth(2);
     glTranslatef(0,0,-4);
     glBegin(GL_LINES);
     glVertex3f(-0.25,0,0);
     glVertex3f(0.25,0,0);
     glVertex3f(0,-0.25,0);
     glVertex3f(0,0.25,0);
     glEnd;
     glBegin(GL_LINE_STRIP);
     for i:=0 to 16 do begin
      glVertex3f(cos(i*pi/8)*0.125,sin(i*pi/8)*0.125,0);
     end;
     glEnd;
     glBegin(GL_LINE_STRIP);
     for i:=0 to 16 do begin
      glVertex3f(cos(i*pi/8)*0.06125*0.5,sin(i*pi/8)*0.06125*0.5,0);
     end;
     glEnd;
     glPointSize(1);
     glLineWidth(1);

     if Focused then begin
      glClear(GL_DEPTH_BUFFER_BIT);
      glMatrixMode(GL_PROJECTION);
      glLoadIdentity();
      glMatrixMode(GL_MODELVIEW);
      glLoadIdentity();
      glDisable(GL_BLEND);
      glColor4f(0.5,0.5,1.0,1.0);
      glLineWidth(3);
      glDisable(GL_DEPTH_TEST);
      glDisable(GL_LIGHTING);
      glDisable(GL_CULL_FACE);
      glDepthMask(GL_FALSE);
      glPolygonMode(GL_FRONT_AND_BACK,GL_LINE);
      glBegin(GL_QUADS);
      glVertex3f(1.0,-1.0,0.0);
      glVertex3f(1.0,1.0,0.0);
      glVertex3f(-1.0,1.0,0.0);
      glVertex3f(-1.0,-1.0,0.0);
      glEnd;
      glDisable(GL_BLEND);
     end else begin
   {  glClear(GL_DEPTH_BUFFER_BIT);
      glMatrixMode(GL_PROJECTION);
      glLoadIdentity();
      glMatrixMode(GL_MODELVIEW);
      glLoadIdentity();
      glEnable(GL_BLEND);
      glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
      glColor4f(0.0,0.0,0.0,0.25);
      glDisable(GL_DEPTH_TEST);
      glDisable(GL_LIGHTING);
      glDisable(GL_CULL_FACE);
      glDepthMask(GL_FALSE);
      glPolygonMode(GL_FRONT_AND_BACK,GL_FILL);
      glBegin(GL_QUADS);
      glVertex3f(1.0,-1.0,0.0);
      glVertex3f(1.0,1.0,0.0);
      glVertex3f(-1.0,1.0,0.0);
      glVertex3f(-1.0,-1.0,0.0);
      glEnd;
      glDisable(GL_BLEND);{}
     end;
    end;

    glDisable(GL_POLYGON_OFFSET_LINE);
    glDisable(GL_POLYGON_OFFSET_POINT);

    OpenGLControlWorld.SwapBuffers;

 { end else begin

    Sleep(0);{}

   end;

  end else begin

 //  wglMakeCurrent(hDCGL,hGL);
   glViewPort(0,0,OpenGLControlWorld.ClientWidth,OpenGLControlWorld.ClientHeight);
   glClearDepth(1.0);
   glClearColor(0.0,0.0,0.0,0.0);
   glClear(GL_COLOR_BUFFER_BIT or GL_STENCIL_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
   glMatrixMode(GL_PROJECTION);
   glLoadIdentity();
   glMatrixMode(GL_MODELVIEW);
   glLoadIdentity();
   OpenGLControlWorld.SwapBuffers;

  end;

 end;
end;

procedure TFormMain.sTreeViewMainChange(Sender: TObject; Node: TTreeNode);
var TreeNode:TTreeNode;
begin
 TreeNode:=sTreeViewMain.Selected;
 if assigned(TreeNode) then begin
  SetObjectInspectorRoot(pointer(TreeNode.Data));
 end else begin
  SetObjectInspectorRoot(nil);
 end;
end;

procedure TFormMain.JvInspectorMainItemDoubleClicked(Sender: TObject;
  Item: TObject);
begin
{if assigned(Item) and assigned(Item.Data) then begin
  if Item.Data.TypeInfo=TypeInfo(TKraftVector3Property) then begin
  TJvInspectorClassItem(Item).
   JvInspectorMain.InspectObject:=TJvInspectorClassItem(Item).;
  end;
 end;}
end;

procedure TFormMain.JvInspectorMainAfterItemCreate(Sender: TObject;
  Item: TObject);
begin
{if assigned(Item) and (Item is TJvInspectorClassItem) and assigned(Item.Data) then begin
  if Item.Data.TypeInfo=TypeInfo(TKraftVector3Property) then begin
   TJvInspectorClassItem(Item).RenderAsCategory:=true;
   TJvInspectorClassItem(Item).Expanded:=true;
  end;
 end;{}
end;

procedure TFormMain.Skinned1Click(Sender: TObject);
begin
// Skinned1.Checked:=not Skinned1.Checked;
// sSkinManager1.Active:=Skinned1.Checked;
end;

procedure TFormMain.sListBoxDemosClick(Sender: TObject);
begin
//LoadScene(TDemoSceneClass(sListBoxDemos.Items.Objects[sListBoxDemos.ItemIndex]));
end;

procedure TFormMain.FormShow(Sender: TObject);
begin
 LastTime:=HighResolutionTimer.GetTime;
 FST2:=LastTime;
 FET2:=LastTime;
 Frames:=0;
 if ThreadTimer.Suspended then begin
  ThreadTimer.Resume;
 end;
 sTreeViewDemos.Selected:=TreeNodeDemoDefault;
 sTreeViewDemosDblClick(nil);
end;

procedure TFormMain.sTreeViewDemosDblClick(Sender: TObject);
var TreeNode:TTreeNode;
begin
 TreeNode:=sTreeViewDemos.Selected;
 if assigned(TreeNode) and assigned(TreeNode.Data) then begin
  LoadScene(TDemoSceneClass(TreeNode.Data));
 end;
end;

procedure TFormMain.JvSimScope1Update(Sender: TObject);
begin
 if assigned(KraftPhysics) then begin
 end;
end;

procedure TFormMain.TimerDrawTimer(Sender: TObject);
begin
 if assigned(KraftPhysics) then begin
  //OpenGLControlWorld.Paint;
 end;
end;

procedure TFormMain.TimerFPSTimer(Sender: TObject);
begin
 sTabSheetWorld.Caption:='World ('+IntToStr(round(FPS))+' FPS)';
end;

procedure TFormMain.TimerPerformanceTimer(Sender: TObject);
var s:string;
begin
 if assigned(KraftPhysics) then begin

  Str(KraftPhysics.HighResolutionTimer.ToNanoseconds(KraftPhysics.BroadPhaseTime)/1000000.0:1:5,s);
  sLabelBroadPhaseTime.Caption:='Broad phase: '+s+' ms';

  Str(KraftPhysics.HighResolutionTimer.ToNanoseconds(KraftPhysics.MidPhaseTime)/1000000.0:1:5,s);
  sLabelMidPhaseTime.Caption:='Mid phase: '+s+' ms';

  Str(KraftPhysics.HighResolutionTimer.ToNanoseconds(KraftPhysics.NarrowPhaseTime)/1000000.0:1:5,s);
  sLabelNarrowPhaseTime.Caption:='Narrow phase: '+s+' ms';

  Str(KraftPhysics.HighResolutionTimer.ToNanoseconds(KraftPhysics.SolverTime)/1000000.0:1:5,s);
  sLabelSolverTime.Caption:='Discrete solver: '+s+' ms';

  Str(KraftPhysics.HighResolutionTimer.ToNanoseconds(KraftPhysics.ContinuousTime)/1000000.0:1:5,s);
  sLabelContinuousTime.Caption:='Continuous collision detection and response: '+s+' ms';

  Str(KraftPhysics.HighResolutionTimer.ToNanoseconds(KraftPhysics.TotalTime)/1000000.0:1:5,s);
  sLabelTotalTime.Caption:='Total: '+s+' ms';

 end;

end;

procedure TFormMain.sTreeViewDemosKeyPress(Sender: TObject; var Key: Char);
begin
 if Key=#13 then begin
  sTreeViewDemosDblClick(Sender);
 end;
end;

end.
