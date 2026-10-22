## 1. Subprocess Supervision and Pipe Isolation in bgmod

- [x] 1.1 Implement signal handling (`SIGTERM`, `SIGINT`) in `bgmod.lpr` to store child PIDs and forward termination signals to active child processes (`GamePid` and `LoggerPid`).
- [x] 1.2 Refactor the launch block in `bgmod.lpr` to fork `GamePid` for the game command instead of unconditionally replacing the supervisor process via `execvpe`.
- [x] 1.3 In the supervisor parent process of `bgmod.lpr`, immediately restore original `stderr` descriptor, close the pipe write descriptor, wait for `GamePid` using `fpWaitPid`, cleanly terminate and reap `LoggerPid`, and exit with the game's exit code.

## 2. Verification and Testing

- [x] 2.1 Add automated test cases covering `bgmod` supervisor process lifecycle, pipe EOF closure, and clean child reaping.
- [x] 2.2 Rebuild `bgmod` and run the full test suite (`./build_tests.sh` and logic tests) to verify all tests pass without regression.
