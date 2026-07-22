unit test_isolation;

{$mode objfpc}{$H+}

interface

procedure EnsureIsolatedEnvironment(const ASeedDriver: string);
function IsolatedHome: string;
procedure CleanupIsolatedEnvironment(ASuccess: Boolean);

implementation

uses
  SysUtils, FileUtil, BaseUnix;

{$IFDEF UNIX}
// FPC 3.2 RTL ships no setenv wrapper; bind libc directly (test programs
// already link libc). libc execv is used for the same reason: FPC's fpExecV
// passes the RTL's startup envp snapshot, ignoring setenv.
function setenv(const name, value: PChar; overwrite: cint): cint; cdecl; external 'c' name 'setenv';
function execv(path: PChar; argv: PPChar): cint; cdecl; external 'c' name 'execv';
{$ENDIF}

var
  FHome: string = '';

function IsolatedHome: string;
begin
  Result := FHome;
end;

procedure EnsureIsolatedEnvironment(const ASeedDriver: string);
var
  ConfDir: string;
  Conf: TextFile;
  Args: array of PChar;
  i: Integer;
begin
  // Phase B: already re-executed with the isolated HOME in place.
  if GetEnvironmentVariable('GOVERLAY_TEST_ISOLATED') = '1' then
  begin
    FHome := GetEnvironmentVariable('HOME');
    WriteLn('[test] Isolated HOME: ', FHome);
    Exit;
  end;

  // Phase A: the FPC runtime snapshots the environment at process start, so
  // the mock HOME cannot be applied in-process. Build the sandbox, then
  // re-exec self so the child sees it from birth (libc setenv values are
  // inherited across execv).
  if GetEnvironmentVariable('QT_QPA_PLATFORM') = '' then
    setenv(PChar('QT_QPA_PLATFORM'), PChar('offscreen'), 1);
  setenv(PChar('GOVERLAY_TEST'), PChar('1'), 1);

  FHome := IncludeTrailingPathDelimiter(GetTempDir(False)) +
    'goverlay_test_' + IntToStr(Trunc(Now * 86400000));
  ConfDir := FHome + '/.config/goverlay';
  ForceDirectories(ConfDir);

  // Seed: changelog suppressed; driver optionally pre-set for toggle tests.
  AssignFile(Conf, ConfDir + '/goverlay.conf');
  Rewrite(Conf);
  WriteLn(Conf, '[General]');
  WriteLn(Conf, 'ChangelogSeenVersion=1.8.9');
  WriteLn(Conf, '[OptiScaler]');
  if ASeedDriver <> '' then
    WriteLn(Conf, 'GpuDriver=', ASeedDriver);
  CloseFile(Conf);

  setenv(PChar('HOME'), PChar(FHome), 1);
  setenv(PChar('GOVERLAY_TEST_ISOLATED'), PChar('1'), 1);

  SetLength(Args, ParamCount + 2);
  for i := 0 to ParamCount do
    Args[i] := PChar(ParamStr(i));
  Args[ParamCount + 1] := nil;
  execv(PChar('/proc/self/exe'), PPChar(@Args[0]));

  // Only reached if exec fails
  WriteLn(StdErr, '[test] FATAL: re-exec failed');
  Halt(2);
end;

procedure CleanupIsolatedEnvironment(ASuccess: Boolean);
begin
  if ASuccess then
  begin
    if (FHome <> '') and DirectoryExists(FHome) then
      DeleteDirectory(FHome, False);
    WriteLn('[test] Isolated HOME cleaned up.');
  end
  else
    WriteLn('[test] FAILURES detected - preserved isolated HOME at: ', FHome);
end;

end.
