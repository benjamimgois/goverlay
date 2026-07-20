# GOverlay E2E GUI Integration Tests

This directory contains automated end-to-end integration tests for GOverlay. The test runner launches GOverlay, simulates user navigation/interaction via `xdotool` inside a virtual framebuffer (`Xvfb`), and asserts that correct configuration files are written.

## Prerequisites

Before running the tests, make sure you have the required system packages installed.

### Install System Dependencies

* **Arch Linux / Manjaro:**
  ```bash
  sudo pacman -S xorg-server-xvfb xdotool imagemagick
  ```

* **Ubuntu / Debian / Linux Mint:**
  ```bash
  sudo apt install xvfb xdotool imagemagick
  ```

* **Fedora / RHEL:**
  ```bash
  sudo dnf install xorg-x11-server-Xvfb xdotool imagemagick
  ```

## Running the Tests

### 1. Compile GOverlay
Make sure you build the latest version of GOverlay before running the tests:
```bash
make
```

### 2. Run the test suite
Run the test runner script:
```bash
python3 tests/run_e2e_tests.py
```

The script will:
* Spin up a virtual display `Xvfb` (Display `:99`).
* Launch GOverlay inside the virtual framebuffer using a clean mock `$HOME` directory.
* Click on the **OptiScaler** tab.
* Toggle the **MESA** GPU Driver option and assert that `OptiScaler.ini` gets saved silently on disk.
* Toggle the **NVIDIA** GPU Driver option and assert the update is reverted silently.
* Capture screenshots of key UI interactions inside `tests/screenshots/` for debugging.
* Gracefully kill the application and clean up.

### Running on Host Display (Visible Mode)
If you want to run the tests directly on your desktop (so you can watch the mouse clicks and window open/close in real-time), run:
```bash
python3 tests/run_e2e_tests.py --no-virtual
```
*Note: Your mouse cursor will be briefly hijacked during the test to simulate clicks.*
