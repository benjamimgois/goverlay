unit gfxlaunch;

{$mode objfpc}{$H+}

interface

procedure RunPasCube;

implementation

uses
  Classes, SysUtils, Process;

var
  NvidiaDriver: Boolean = False;

function IsNvidiaLoaded: Boolean;
var
  S: string;
begin
  Result := RunCommand('lsmod', [], S, [poUsePipes, poWaitOnExit]) and
            (Pos('nvidia', S) > 0);
end;

procedure RunDetached(const Cmd: string);
var
  P: TProcess;
begin
  P := TProcess.Create(nil);
  try
    P.Executable := '/bin/sh';
    P.Parameters.Add('-c');
    P.Parameters.Add(Cmd);
    P.Options := [poNoConsole, poDetached];
    P.Execute;
  finally
    P.Free;
  end;
end;

procedure RunPasCube;
var
  Cmd: string;
begin
  NvidiaDriver := IsNvidiaLoaded;

  if NvidiaDriver then
  begin
    // Método para driver NVIDIA proprietário
    Cmd := '__GLX_VENDOR_LIBRARY_NAME=mesa MESA_LOADER_DRIVER_OVERRIDE=zink ' +
           'QT_QPA_PLATFORM=xcb mangohud pascube &';
  end
  else
  begin
    // Método para driver Mesa
    Cmd := 'LIBGL_KOPPER_DRI2=1 MESA_LOADER_DRIVER_OVERRIDE=zink mangohud ' +
           'QT_QPA_PLATFORM=xcb pascube &';
  end;

  RunDetached(Cmd);
end;

end.

