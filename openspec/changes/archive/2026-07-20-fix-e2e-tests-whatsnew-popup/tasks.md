## 1. Avoid changelog popup on startup

- [x] 1.1 Add logic to seed `config.ini` with `ChangelogSeenVersion=1.8.9` under general section (tests/run_e2e_tests.py)

## 2. Refactor click coordinate scaling logic

- [x] 2.1 Update `click_relative` helper to accept layout alignment flags (fixed/left/right-anchored) and calculate target coordinates (tests/run_e2e_tests.py)
- [x] 2.2 Update tab navigation clicks to use fixed absolute coordinates (tests/run_e2e_tests.py)
- [x] 2.3 Update Mesa driver selection click to use right-anchored proportional coordinates (tests/run_e2e_tests.py)
- [x] 2.4 Update Nvidia driver selection click to use left-anchored coordinates (tests/run_e2e_tests.py)

## 3. Verification

- [x] 3.1 Verify tests execute and pass successfully on the host display (tests/run_e2e_tests.py)
