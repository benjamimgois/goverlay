program projectmanager;
{$i ..\..\PasVulkan.inc}
{$ifndef fpc}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=24.0}
   {$legacyifend on}
  {$ifend}
 {$endif}
{$endif}
{$if defined(Win32) or defined(Win64) or defined(Windows)}
 {$define Windows}
 {$apptype console}
{$ifend}

// {$if defined(fpc) and defined(Unix)}cthreads,{$ifend}

uses {$if defined(fpc) and defined(Unix)}cthreads,{$ifend}
     SysUtils,
     Classes,
     UnitVersion,
     UnitGlobals,
     UnitParameters,
     UnitExternalProcess,
     UnitProject;

{$if defined(fpc) and defined(Windows)}
function IsDebuggerPresent:longbool; stdcall; external 'kernel32.dll' name 'IsDebuggerPresent';
{$ifend}

procedure ShowTitle;
begin
 WriteLn('PasVulkan project manager version ',ProjectManagerVersion);
 WriteLn(ProjectManagerCopyright);
end;

procedure ShowUsage;
begin
 WriteLn('Usage: ',ExtractFileName(OwnExecutableFileName),' ([options] ...) [command] ([command parameters])');
end;

procedure ShowInfos;
begin
 WriteLn('Built with ',{$if defined(fpc)}
          'FreePascal compiler ',{$i %FPCVERSION%},' for ',{$i %FPCTARGETCPU%},' on ',{$i %FPCTARGETOS%},' at ',{$i %DATE%}
         {$else}
          'Delphi compiler'
         {$ifend});
 WriteLn('PasVulkan root path: ',PasVulkanRootPath);
end;

procedure ShowHelp;
begin
 WriteLn;
 ShowUsage;
 WriteLn;
 WriteLn('Options: -h / --help / -?                      Show this help');
 WriteLn('         -i / --info                           Show informations');
 WriteLn('         -O1                                   FPC compiler optimization level 1 (default)');
 WriteLn('         -O2                                   FPC compiler optimization level 2');
 WriteLn('         -O3                                   FPC compiler optimization level 3');
 WriteLn('         -O4                                   FPC compiler optimization level 4');
 WriteLn('         --debug                               Compile as debug build');
 WriteLn('         --release                             Compile as release build (default)');
 WriteLn('         --sdl2-static-link                    Static linking of SDL2 (Windows-only)');
 WriteLn('         --fpc-binary-path [path]              Path to the SVN trunk version of the FreePascal Compiler');
 WriteLn;
 WriteLn('Commands: compileassets [projectname]          Compile assets');
 WriteLn('          create [projectname]                 Create a new project (project name must be a valid lowercase pascal and java identifier)');
 WriteLn('          build [projectname] ([target(s)])    Build an existent project');
 WriteLn('          help                                 Show this help');
 WriteLn('          run [projectname]                    Run an existent project');
 WriteLn('          update [projectname]                 Update the project base files of an existent project');
 WriteLn;
 WriteLn('Supported targets: fpc-allcpu-android');
 WriteLn('                   fpc-arm32-android');
 WriteLn('                   fpc-aarch64-android');
 WriteLn('                   fpc-x86_32-android');
 WriteLn('                   fpc-x86_64-android');
 WriteLn('                   fpc-x86_32-linux');
 WriteLn('                   fpc-arm32-linux');
 WriteLn('                   fpc-aarch64-linux');
 WriteLn('                   fpc-x86_64-linux');
 WriteLn('                   fpc-x86_32-windows');
 WriteLn('                   fpc-x86_64-windows');
 WriteLn('                   delphi-x86_32-windows');
 WriteLn('                   delphi-x86_64-windows');
 WriteLn;
end;

var ExitCode:Int32;
begin

 ExitCode:=0;

 ParseCommandLine;

 ShowTitle;

 if DoShowInfos then begin
  ShowInfos;
 end;

 if DoShowHelp then begin
  ShowHelp;
 end else if DoShowUsage and (length(CurrentCommand)=0) then begin
  ShowUsage;
 end;

 if length(CurrentCommand)>0 then begin
  if CurrentCommand='create' then begin
   if not CreateProject then begin
    ExitCode:=1;
   end;
  end else if CurrentCommand='update' then begin
   if not UpdateProject then begin
    ExitCode:=1;
   end;
  end else if CurrentCommand='compileassets' then begin
   if not CompileAssets then begin
    ExitCode:=1;
   end;
  end else if CurrentCommand='build' then begin
   if not BuildProject then begin
    ExitCode:=1;
   end;
  end else if CurrentCommand='help' then begin
   ShowHelp;
  end else if CurrentCommand='run' then begin
   if not RunProject then begin
    ExitCode:=1;
   end;
  end else begin
   WriteLn('Unknown command: ',CurrentCommand);
  end;
 end;

{$ifdef Windows}
 if {$ifdef fpc}IsDebuggerPresent{$else}DebugHook<>0{$endif} then begin
  WriteLn('Press return to exit . . . ');
  ReadLn;
 end;
{$endif}
 Halt(ExitCode);
end.



