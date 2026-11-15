# Tasks

## 1. Fix `bgmod` Self-Update `execv` Argument Lifetime

- [x] 1.1 In `bgmod.lpr` (runtime wrapper self-update block around lines 3197–3203), declare `ReExecStrs: array of string`, copy `ParamStr(0..ParamCount)` into `ReExecStrs`, and populate `ReExecArgs[k] := PChar(ReExecStrs[k])` and `execv(PChar(ReExecStrs[0]), @ReExecArgs[0])`; verify `bgmod` compiles cleanly with `lazbuild`.

## 2. Regression Test & Verification

- [x] 2.1 Add an automated test in `tests/logic/logic_test_cases.pas` (or `tests/gui/gui_test_cases.pas`) that stages a `bgmod` binary and a differing/newer master `bgmod` in a temporary directory, invokes `bgmod` with multiple arguments (e.g. `echo wrapper works`), and asserts the re-executed output/log preserves all arguments in order; run `make test` and confirm all tests pass.
