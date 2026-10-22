# Tasks

## 1. Remove GameDir logging from bgmod

- [x] 1.1 Remove GameDir write block from `Log()` procedure in `bgmod.lpr` and verify `bgmod` logs exclusively to `/tmp/bgmod.log` and `CentralLogDir`
- [x] 1.2 Remove `*GameLogFile` variables (`MangoGameLogFile`, `MakoGameLogFile`, `LsfgGameLogFile`, `OptiGameLogFile`, `DlssGameLogFile`, `SumiGameLogFile`, `BasaltGameLogFile`, `ReShadeGameLogFile`) and their corresponding `InitToolLogFile` invocations in `bgmod.lpr`
- [x] 1.3 Refactor `RunSubprocessLogger` signature and stderr filter loop in `bgmod.lpr` to eliminate `*GameFd` handles and write tool diagnostics exclusively to `*CentFd`
- [x] 1.4 Update OptiScaler logging in `bgmod.lpr` (`EnsureOptiScalerLogging`) to avoid forcing `LogToFile=true` into the game directory, keeping console/stderr logging active for central capture

## 2. Remove GameDir logging from bgmod-uninstaller

- [x] 2.1 Remove GameDir write block from `Log()` procedure in `bgmod-uninstaller.lpr` and verify logs are directed only to `/tmp/` and `CentralLogDir`

## 3. Documentation and Verification

- [x] 3.1 Update `README.md` to reflect that `bgmod` logs to `/tmp/bgmod.log` and `~/.local/share/goverlay/logs/[Game Name]/`, eliminating game directory logging
- [x] 3.2 Compile `bgmod` and `bgmod-uninstaller` using `make` and run the test suite (`./tests/logic/logic_tests` and `./tests/gui/gui_tests`) to verify successful compilation and no regressions
