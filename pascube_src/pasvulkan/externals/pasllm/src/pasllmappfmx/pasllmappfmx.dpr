program pasllmappfmx;
{$legacyifend on}

uses
  System.StartUpCopy,
  FMX.Types,
  {$ifdef mswindows}
  Windows,
  {$endif }
  FMX.Forms,
  FMX.Skia,
  PasLLMApp.FormMain in 'PasLLMApp.FormMain.pas' {FormMain},
  PasLLM in '..\PasLLM.pas';

{$R *.res}

{$ifdef mswindows}
function IsWine: Boolean;
type
  TWineGetVersion = function: PAnsiChar; cdecl;
var
  hNTDLL: HMODULE;
  WineGetVersion: TWineGetVersion;
begin
  Result := False;
  hNTDLL := GetModuleHandle('ntdll.dll');
  if hNTDLL <> 0 then
  begin
    WineGetVersion := GetProcAddress(hNTDLL, 'wine_get_version');
    Result := Assigned(WineGetVersion);
  end;
end;
{$endif}

begin
{$ifdef mswindows}

 if IsWine then begin

  // 1) Make sure Skia is OFF on Windows
{$if declared(GlobalUseSkia)}
  GlobalUseSkia := false;
{$ifend}

  // 2) Avoid GPU canvas (DX) and Direct2D   force GDI+ software canvas
  GlobalUseGPUCanvas := False;     // don't use TCanvasGpu
  GlobalUseDirect2D  := False;     // turn off D2D; FMX will use GDI+ for 2D

 end else begin

  FMX.Skia.GlobalUseSkia:=true;

 end;

 // Optional: if present in your Delphi version
 // GlobalUseDX := False;          // replaces deprecated GlobalUseDX10
 // GlobalUseDX10Software := True; // force D2D WARP (software rasterizer)

{$endif}
  Application.Initialize;
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
