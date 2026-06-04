program spirvreflection;
{$ifdef fpc}
 {$mode delphi}
{$else}
 {$legacyifend on}
{$endif}
{$if defined(Win32) or defined(Win64) or defined(Windows)}
 {$apptype console}
{$ifend}

uses
  System.SysUtils,
  PasVulkan.Framework in '..\..\PasVulkan.Framework.pas';

var ShaderModule:TpvVulkanShaderModule;
    ReflectionData:TpvVulkanShaderModuleReflectionData;
begin
 try
  ShaderModule:=TpvVulkanShaderModule.Create(nil,'test.spv');
  try
   ReflectionData:=ShaderModule.GetReflectionData;
   try

   finally
    Finalize(ReflectionData);
   end;
  finally
   FreeAndNil(ShaderModule);
  end;
  readln;
 except
  on E:Exception do begin
   Writeln(E.ClassName, ': ', E.Message);
  end;
 end;
end.
