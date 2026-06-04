program entitycomponentsystem;
{$ifdef fpc}
 {$mode delphi}
{$else}
 {$legacyifend on}
{$endif}
{$if defined(Win32) or defined(Win64) or defined(Windows)}
 {$apptype console}
{$ifend}

uses
  SysUtils,
  PasVulkan.Types in '..\..\PasVulkan.Types.pas',
  PasVulkan.Framework in '..\..\PasVulkan.Framework.pas',
  PasVulkan.EntityComponentSystem in '..\..\PasVulkan.EntityComponentSystem.pas',
  PasVulkan.Components.Name in '..\..\PasVulkan.Components.Name.pas',
  PasVulkan.Components.Parent in '..\..\PasVulkan.Components.Parent.pas',
  PasVulkan.Components.Renderer in '..\..\PasVulkan.Components.Renderer.pas',
  PasVulkan.Components.SortKey in '..\..\PasVulkan.Components.SortKey.pas',
  PasVulkan.Components.Transform in '..\..\PasVulkan.Components.Transform.pas';

var World:TpvEntityComponentSystem.TWorld;
begin
 try
  World:=TpvEntityComponentSystem.TWorld.Create;
  try

  finally
   FreeAndNil(World);
  end;
  readln;
 except
  on E:Exception do begin
   Writeln(E.ClassName, ': ', E.Message);
  end;
 end;
end.
