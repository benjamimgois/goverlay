## 1. Setup test framework structure

- [x] 1.1 Create `tests/` directory
- [x] 1.2 Write `requirements.txt` with python packages (`pytest`, `pyvirtualdisplay`, `pyautogui`, `pillow`, `opencv-python`)

## 2. Implement E2E test runner

- [x] 2.1 Write `tests/run_e2e_tests.py` that handles Xvfb startup and mocks the `$HOME` config folder
- [x] 2.2 Implement GOverlay startup check and template matching helper functions
- [x] 2.3 Write template capture utility to easily grab PNG images of buttons/tabs for matches

## 3. Implement target test scenarios

- [x] 3.1 Write test case for OptiScaler GPU driver selection (MESA/NVIDIA) and assert silent ini updates
- [x] 3.2 Write test case for Tab navigation and Save button states in global mode

## 4. Verification

- [x] 4.1 Run the test runner locally in Xvfb and verify all tests pass successfully
- [x] 4.2 Document how to execute the test suite in `README.md` or a new test guide
