# Tasks

## 1. Test Suite Compatibility for Non-FHS & Isolated Environments

- [x] 1.1 Update `tests/logic/logic_test_cases.pas` to dynamically resolve shell interpreters (`FindTestHelperExecutable('sh')`) and external utilities (`FindTestHelperExecutable('cp')`) across all mock scripts and test process invocations, and verify `make test-logic` compiles and passes.
- [x] 1.2 Update `tests/gui/gui_test_cases.pas` to ensure any remaining hardcoded `/bin/sh` or system binaries use `FindTestHelperExecutable`, and verify `make test-gui` compiles and passes.
- [x] 1.3 Ensure `bgmod.lpr` runtime environment initialization retains `PATH` from `envp` during detached splash and supervisor child launches, and verify tests pass cleanly with `make test`.

## Workflow follow-up

- Archive the change after implementation and validation.
