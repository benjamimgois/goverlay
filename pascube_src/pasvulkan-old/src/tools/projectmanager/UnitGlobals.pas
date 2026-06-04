unit UnitGlobals;
{$i ..\..\PasVulkan.inc}
{$ifndef fpc}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=24.0}
   {$legacyifend on}
  {$ifend}
 {$endif}
{$endif}

interface

uses SysUtils,Classes,UnitVersion;

type TBuildMode=(Debug,Release);

var OwnExecutableFileName:UnicodeString='';
    PasVulkanRootPath:UnicodeString='';
    PasVulkanProjectsPath:UnicodeString='';
    PasVulkanProjectTemplatePath:UnicodeString='';

    FPCBinaryPath:UnicodeString='';

    DoShowUsage:boolean=true;
    DoShowHelp:boolean=false;
    DoShowInfos:boolean=false;

    CurrentCommand:UnicodeString='';
    CurrentProjectName:UnicodeString='';
    CurrentTarget:UnicodeString='';

    BuildMode:TBuildMode=TBuildMode.Release;

    FPCOptimizationLevel:Int32=1;

    SDL2StaticLinking:boolean=false;

implementation

procedure InitializeGlobals;
begin
 OwnExecutableFileName:=UnicodeString(UTF8String(ParamStr(0)));
 PasVulkanRootPath:=IncludeTrailingPathDelimiter(ExtractFilePath(OwnExecutableFileName));
 PasVulkanProjectsPath:=IncludeTrailingPathDelimiter(PasVulkanRootPath+'projects');
 PasVulkanProjectTemplatePath:=IncludeTrailingPathDelimiter(PasVulkanProjectsPath+'template');

{$if defined(fpc)}
{$if (defined(Win32) or defined(Win64) or defined(Windows)) and defined(cpu386)}
 CurrentTarget:='fpc-x86_32-windows';
{$elseif (defined(Win32) or defined(Win64) or defined(Windows)) and (defined(cpuamd64) or defined(cpux64))}
 CurrentTarget:='fpc-x86_64-windows';
{$elseif defined(Linux) and defined(cpu386)}
 CurrentTarget:='fpc-x86_32-linux';
{$elseif defined(Linux) and (defined(cpuamd64) or defined(cpux64))}
 CurrentTarget:='fpc-x86_64-linux';
{$elseif defined(Android)}
 CurrentTarget:='fpc-allcpu-android';
{$else}
 CurrentTarget:='';
{$ifend}
{$else}
{$if (defined(Win32) or defined(Win64) or defined(Windows)) and defined(cpu386)}
 CurrentTarget:='delphi-x86_32-windows';
{$elseif (defined(Win32) or defined(Win64) or defined(Windows)) and (defined(cpuamd64) or defined(cpux64))}
 CurrentTarget:='delphi-x86_64-windows';
{$else}
 CurrentTarget:='';
{$ifend}
{$ifend}

end;

procedure FinalizeGlobals;
begin
end;

initialization
 InitializeGlobals;
finalization
 FinalizeGlobals;
end.

