unit logic_test_cases;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testregistry;

type
  TDriverPreferenceTests = class(TTestCase)
  published
    procedure TestRoundTrip;
    procedure TestLowercasesValue;
  end;

  TOptiScalerIniTests = class(TTestCase)
  published
    procedure TestIniRoundTrip;
    procedure TestSectionBracketFlexibility;
  end;

  TSandboxIsolationTests = class(TTestCase)
  published
    procedure TestIsSafeSandboxDirValid;
    procedure TestIsSafeSandboxDirRejectsUnsafePaths;
    procedure TestIsSafeSandboxDirRejectsTraversal;
    procedure TestIsSafeSandboxDirAcceptsDottedNames;
  end;

implementation

uses
  themeunit, configfile, test_isolation;

procedure TDriverPreferenceTests.TestRoundTrip;
begin
  SaveOptiScalerDriverPreference('mesa');
  AssertEquals('mesa round-trip', 'mesa', LoadOptiScalerDriverPreference);
  SaveOptiScalerDriverPreference('nvidia');
  AssertEquals('nvidia round-trip', 'nvidia', LoadOptiScalerDriverPreference);
end;

procedure TDriverPreferenceTests.TestLowercasesValue;
begin
  SaveOptiScalerDriverPreference('MESA');
  AssertEquals('stored value is lowercased', 'mesa', LoadOptiScalerDriverPreference);
end;

procedure TOptiScalerIniTests.TestIniRoundTrip;
var
  IniPath: string;
  Cfg: TConfigFile;
  F: TextFile;
begin
  // Seed an OptiScaler.ini-style file inside the isolated HOME
  IniPath := IsolatedHome + '/OptiScaler.ini';
  AssignFile(F, IniPath);
  Rewrite(F);
  WriteLn(F, '[Upscale]');
  WriteLn(F, 'ForceReflex=false');
  WriteLn(F, 'SpoofDLSS=false');
  CloseFile(F);

  Cfg := TConfigFile.Create;
  try
    AssertTrue('ini loads', Cfg.Load(IniPath));
    AssertFalse('ForceReflex reads false', Cfg.GetBool('ForceReflex=', True));

    // TConfigFile contract (see configkeys.pas): key prefixes include '=',
    // section names include brackets.
    Cfg.SetBool('ForceReflex=', True, '[Upscale]');
    AssertTrue('ini saves', Cfg.Save);
  finally
    Cfg.Free;
  end;

  // Reload from disk and assert persistence
  Cfg := TConfigFile.Create;
  try
    AssertTrue('ini reloads', Cfg.Load(IniPath));
    AssertTrue('ForceReflex persisted true', Cfg.GetBool('ForceReflex=', False));
    AssertFalse('SpoofDLSS untouched', Cfg.GetBool('SpoofDLSS=', True));
  finally
    Cfg.Free;
  end;
end;

procedure TOptiScalerIniTests.TestSectionBracketFlexibility;
var
  IniPath, TextContent: string;
  Cfg: TConfigFile;
  F: TextFile;
begin
  IniPath := IsolatedHome + '/OptiScaler_SectionTest.ini';
  AssignFile(F, IniPath);
  Rewrite(F);
  WriteLn(F, '[FrameGen]');
  WriteLn(F, 'Enabled=auto');
  CloseFile(F);

  Cfg := TConfigFile.Create;
  try
    AssertTrue('ini loads', Cfg.Load(IniPath));
    // Test section matching without brackets
    Cfg.SetValue('FGInput=', 'fsrfg', 'FrameGen');
    // Test section matching with brackets
    Cfg.SetValue('FGOutput=', 'xefg', '[FrameGen]');
    // Test creating missing section without brackets
    Cfg.SetValue('NewKey=', 'val', 'NewSec');
    AssertTrue('ini saves', Cfg.Save);
  finally
    Cfg.Free;
  end;

  // Verify file content structure
  AssignFile(F, IniPath);
  Reset(F);
  TextContent := '';
  while not EOF(F) do
  begin
    ReadLn(F, IniPath); // reuse string var for line reading
    TextContent := TextContent + IniPath + #10;
  end;
  CloseFile(F);

  AssertTrue('FGInput in FrameGen', Pos('FGInput=fsrfg', TextContent) > 0);
  AssertTrue('FGOutput in FrameGen', Pos('FGOutput=xefg', TextContent) > 0);
  AssertTrue('NewSec section created with brackets', Pos('[newsec]', TextContent) > 0);
  AssertFalse('Unbracketed FrameGen section not created', Pos(#10'FrameGen'#10, TextContent) > 0);
end;

procedure TSandboxIsolationTests.TestIsSafeSandboxDirValid;
var
  ValidSandbox: string;
begin
  ValidSandbox := IncludeTrailingPathDelimiter(GetTempDir(False)) + 'goverlay_test_12345678';
  AssertTrue('Valid sandbox path accepted', IsSafeSandboxDir(ValidSandbox));
end;

procedure TSandboxIsolationTests.TestIsSafeSandboxDirRejectsUnsafePaths;
begin
  AssertFalse('Empty path rejected', IsSafeSandboxDir(''));
  AssertFalse('Root path rejected', IsSafeSandboxDir('/'));
  AssertFalse('Home path rejected', IsSafeSandboxDir('/home/testuser'));
  AssertFalse('Root home rejected', IsSafeSandboxDir('/root'));
  AssertFalse('Base temp directory rejected', IsSafeSandboxDir(GetTempDir(False)));
  AssertFalse('Temp prefix alone rejected', IsSafeSandboxDir(IncludeTrailingPathDelimiter(GetTempDir(False)) + 'goverlay_test_'));
  AssertFalse('Arbitrary temp folder rejected', IsSafeSandboxDir(IncludeTrailingPathDelimiter(GetTempDir(False)) + 'other_folder'));
end;

// The paths below all start with the sandbox prefix, so a string comparison
// accepts every one of them - while the kernel resolves them outside the
// sandbox, which is where DeleteDirectory would then do its work.
procedure TSandboxIsolationTests.TestIsSafeSandboxDirRejectsTraversal;
var
  Prefix: string;
begin
  Prefix := IncludeTrailingPathDelimiter(GetTempDir(False)) + 'goverlay_test_x';

  AssertFalse('Escape to a home directory rejected',
    IsSafeSandboxDir(Prefix + '/../../home/testuser'));
  AssertFalse('Escape to filesystem root rejected',
    IsSafeSandboxDir(Prefix + '/../..'));
  AssertFalse('Escape to the temp root rejected',
    IsSafeSandboxDir(Prefix + '/..'));
  AssertFalse('Trailing traversal rejected',
    IsSafeSandboxDir(Prefix + '/subdir/../../'));
  AssertFalse('Traversal in the middle of a longer path rejected',
    IsSafeSandboxDir(Prefix + '/a/../../../etc/skel'));
  AssertFalse('Traversal that also leaves the temp root rejected',
    IsSafeSandboxDir(Prefix + '/../../../root'));

  // Landing back inside the sandbox is still refused: a directory about to be
  // deleted recursively is not the place to trust a path that needs resolving.
  AssertFalse('Traversal that resolves back inside is still rejected',
    IsSafeSandboxDir(Prefix + '/subdir/..'));
end;

procedure TSandboxIsolationTests.TestIsSafeSandboxDirAcceptsDottedNames;
var
  Prefix: string;
begin
  // Dots are only dangerous as a whole path component; they are legal in names.
  Prefix := IncludeTrailingPathDelimiter(GetTempDir(False)) + 'goverlay_test_';
  AssertTrue('Name containing dots accepted', IsSafeSandboxDir(Prefix + '12345..678'));
  AssertTrue('Name ending in dots accepted', IsSafeSandboxDir(Prefix + '12345678..'));
  AssertTrue('Trailing slash accepted', IsSafeSandboxDir(Prefix + '12345678/'));
end;

initialization
  RegisterTest(TDriverPreferenceTests);
  RegisterTest(TOptiScalerIniTests);
  RegisterTest(TSandboxIsolationTests);

end.
