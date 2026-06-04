program kraftsandbox;

{$MODE Delphi}

uses
{$ifdef unix}
  cthreads,
{$endif}
{$ifdef Windows}
  Windows,
  MMSystem,
{$endif}
  SysUtils,
  Forms, Interfaces,
  UnitFormMain in 'UnitFormMain.pas' {FormMain},
{$ifdef KraftPasMP}
  PasMP in '..\..\pasmp\src\PasMP.pas',
{$endif}
{$ifdef KraftPasJSON}
  PUCU in '..\..\pucu\src\PUCU.pas',
  PasDblStrUtils in '..\..\pasdblstrutils\src\PasDblStrUtils.pas',
  PasJSON in '..\..\pasjson\src\PasJSON.pas',
{$endif}
  kraft in '..\src\kraft.pas',
  KraftArcadeCarPhysics in '..\src\KraftArcadeCarPhysics.pas',
  KraftRayCastVehicle,
  UnitDemoScene in 'UnitDemoScene.pas',
  UnitDemoSceneCatapult in 'UnitDemoSceneCatapult.pas',
  UnitDemoSceneRoundabout in 'UnitDemoSceneRoundabout.pas',
  UnitDemoSceneCarousel in 'UnitDemoSceneCarousel.pas',
  UnitDemoSceneBoxOnPlane in 'UnitDemoSceneBoxOnPlane.pas',
  UnitDemoSceneSandBox in 'UnitDemoSceneSandBox.pas',
  UnitDemoSceneSphereOnSDFTerrain in 'UnitDemoSceneSphereOnSDFTerrain.pas',
  UnitDemoSceneBoxStacking in 'UnitDemoSceneBoxStacking.pas',
  UnitDemoSceneBoxPyramidStacking in 'UnitDemoSceneBoxPyramidStacking.pas',
  UnitDemoSceneBridge in 'UnitDemoSceneBridge.pas',
  UnitDemoSceneCombinedShapes in 'UnitDemoSceneCombinedShapes.pas',
  UnitDemoSceneChain in 'UnitDemoSceneChain.pas',
  UnitDemoSceneStrainedChain in 'UnitDemoSceneStrainedChain.pas',
  UnitDemoSceneBrickWall in 'UnitDemoSceneBrickWall.pas',
  UnitDemoSceneDomino in 'UnitDemoSceneDomino.pas',
  UnitDemoSceneChairAndTable in 'UnitDemoSceneChairAndTable.pas',
  UnitDemoSceneConvexHull in 'UnitDemoSceneConvexHull.pas',
  UnitDemoSceneSignedDistanceField in 'UnitDemoSceneSignedDistanceField.pas',
  UnitDemoSceneConstraintVehicle in 'UnitDemoSceneConstraintVehicle.pas',
  UnitDemoSceneRaycastArcadeVehicle in 'UnitDemoSceneRaycastArcadeVehicle.pas',
  UnitDemoSceneRaycastVehicle;

{$R *.res}

begin
{$ifdef Windows}
  timeBeginPeriod(1);
{$endif}
  FormatSettings.DecimalSeparator:='.';
  FormatSettings.ThousandSeparator:=',';
  //Application.UpdateFormatSettings:=false;
  Application.Initialize;
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
{$ifdef Windows}
  timeEndPeriod(1);
{$endif}
end.
