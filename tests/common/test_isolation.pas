unit test_isolation;

{$mode objfpc}{$H+}

interface

procedure EnsureIsolatedEnvironment(const ASeedDriver: string);
function IsolatedHome: string;
function IsSafeSandboxDir(const ADir: string): Boolean;
procedure CleanupIsolatedEnvironment(ASuccess: Boolean);

implementation

uses
  SysUtils, FileUtil, BaseUnix, apputils;

{$IFDEF UNIX}
// FPC 3.2 RTL ships no setenv wrapper; bind libc directly (test programs
// already link libc). libc execv is used for the same reason: FPC's fpExecV
// passes the RTL's startup envp snapshot, ignoring setenv.
function setenv(const name, value: PChar; overwrite: cint): cint; cdecl; external 'c' name 'setenv';
function execv(path: PChar; argv: PPChar): cint; cdecl; external 'c' name 'execv';
{$ENDIF}

var
  FHome: string = '';

function IsSafeSandboxDir(const ADir: string): Boolean;
var
  TempPrefix, Resolved: string;
begin
  if ADir = '' then Exit(False);

  // Compare resolved paths, never the raw string. A path such as
  // '<tmp>/goverlay_test_x/../../home/user' passes any prefix test while the
  // kernel resolves it to '/home/user' - and DeleteDirectory follows the
  // resolved path, not the string that was checked. Refuse traversal outright
  // and then measure what the path actually points at.
  if Pos(PathDelim + '..' + PathDelim,
         PathDelim + ADir + PathDelim) > 0 then Exit(False);

  Resolved := ExcludeTrailingPathDelimiter(ExpandFileName(ADir));
  TempPrefix := IncludeTrailingPathDelimiter(GetTempDir(False)) + 'goverlay_test_';
  Result := (Pos(TempPrefix, Resolved) = 1) and (Length(Resolved) > Length(TempPrefix));
end;

function IsolatedHome: string;
begin
  Result := FHome;
end;

procedure EnsureIsolatedEnvironment(const ASeedDriver: string);
var
  ConfDir, SandboxDir, CurHome: string;
  Conf: TextFile;
  Args: array of PChar;
  i: Integer;
begin
  SandboxDir := GetEnvironmentVariable('GOVERLAY_TEST_SANDBOX_DIR');
  CurHome := GetEnvironmentVariable('HOME');

  // Phase B: already re-executed with the isolated HOME in place.
  if SandboxDir <> '' then
  begin
    if (CurHome <> SandboxDir) or not IsSafeSandboxDir(CurHome) then
    begin
      WriteLn(StdErr, '[test] FATAL: Invalid or unsafe isolated HOME detected: ', CurHome);
      Halt(2);
    end;
    FHome := CurHome;
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
  setenv(PChar('GOVERLAY_TEST_SANDBOX_DIR'), PChar(FHome), 1);

  Args := nil;
  SetLength(Args, ParamCount + 2);
  for i := 0 to ParamCount do
    Args[i] := PChar(ParamStr(i));
  Args[ParamCount + 1] := nil;

  // fpDup2 clears FD_CLOEXEC on the descriptor it writes to, so fds 1 and 2
  // survive execv while the pipe's read end (CLOEXEC) and its reader thread do
  // not. The child would then inherit a pipe nobody reads and die of SIGPIPE on
  // its first WriteLn. Put the real stdout/stderr back before handing over.
  RestoreStdoutHook;
  execv(PChar('/proc/self/exe'), PPChar(@Args[0]));

  // Only reached if exec fails
  WriteLn(StdErr, '[test] FATAL: re-exec failed');
  Halt(2);
end;

procedure CleanupIsolatedEnvironment(ASuccess: Boolean);
begin
  if ASuccess then
  begin
    if IsSafeSandboxDir(FHome) then
    begin
      if DirectoryExists(FHome) then
        DeleteDirectory(FHome, False);
      WriteLn('[test] Isolated HOME cleaned up.');
    end
    else
      WriteLn(StdErr, '[test] WARNING: Refusing to clean up non-sandbox directory: ', FHome);
  end
  else
    WriteLn('[test] FAILURES detected - preserved isolated HOME at: ', FHome);
end;

end.
