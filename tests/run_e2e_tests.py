#!/usr/bin/env python3
import os
import sys
import time
import shutil
import argparse
import subprocess
import tempfile
import configparser

parser = argparse.ArgumentParser(description="Run E2E GUI integration tests for GOverlay.")
parser.add_argument("--no-virtual", action="store_true", help="Run directly on the host display instead of Xvfb.")
args = parser.parse_args()

# Setup mock home directory to avoid polluting user config
TEMP_DIR = tempfile.mkdtemp(prefix="goverlay_test_")
MOCK_HOME = os.path.join(TEMP_DIR, "mock_home")
os.makedirs(MOCK_HOME, exist_ok=True)
os.environ["HOME"] = MOCK_HOME

# Paths to verify
MOCK_CONFIG_DIR = os.path.join(MOCK_HOME, ".config", "goverlay")
os.makedirs(MOCK_CONFIG_DIR, exist_ok=True)

# Build binaries path
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
GOBERLAY_BIN = os.path.abspath(os.path.join(SCRIPT_DIR, "..", "goverlay"))

print(f"[*] Isolated test environment created at: {TEMP_DIR}")
print(f"[*] Target GOverlay binary: {GOBERLAY_BIN}")

if not os.path.exists(GOBERLAY_BIN):
    print("[-] Error: GOverlay binary not found. Please compile with 'make' first.")
    sys.exit(1)

# Helper to run shell commands
def run_cmd(cmd):
    return subprocess.run(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)

def get_window_scale(window_id):
    res = run_cmd(f"xdotool getwindowgeometry {window_id}")
    for line in res.stdout.split("\n"):
        if "Geometry:" in line:
            try:
                parts = line.split("Geometry:")[1].strip().split("x")
                w = int(parts[0])
                h = int(parts[1])
                print(f"[+] Detected window physical size: {w}x{h}")
                return w / 1045.0, h / 683.0
            except Exception as e:
                print(f"[-] Warning: Failed to parse window geometry ({e}). Defaulting to 1.0 scale.")
    return 1.0, 1.0

def click_relative(window_id, rx, ry, scale_w, scale_h):
    tx = int(rx * scale_w)
    ty = int(ry * scale_h)
    run_cmd(f"xdotool mousemove --window {window_id} {tx} {ty} click 1")

# Check for required tools
has_xdotool = shutil.which("xdotool") is not None
if not has_xdotool:
    print("[-] Error: 'xdotool' is required to run these tests. Please install it first.")
    sys.exit(1)

has_xvfb = shutil.which("Xvfb") is not None
use_xvfb = has_xvfb and not args.no_virtual

xvfb_proc = None

if use_xvfb:
    print("[*] Starting Xvfb virtual framebuffer...")
    xvfb_proc = subprocess.Popen("Xvfb :99 -screen 0 1024x768x24", shell=True)
    os.environ["DISPLAY"] = ":99"
    time.sleep(2) # Wait for Xvfb to initialize
    if xvfb_proc.poll() is not None:
        print("[-] Error: Failed to start Xvfb. Falling back to host display...")
        use_xvfb = False

if not use_xvfb:
    print("[*] Running directly on host display...")
    if "DISPLAY" not in os.environ:
        print("[-] Error: No DISPLAY environment variable set. Cannot run GUI tests.")
        sys.exit(1)

goverlay_proc = None

try:
    # 2. Launch GOverlay forcing X11 backend (important for Wayland sessions)
    print("[*] Launching GOverlay...")
    env = os.environ.copy()
    env["QT_QPA_PLATFORM"] = "xcb"
    env["GDK_BACKEND"] = "x11"
    
    goverlay_proc = subprocess.Popen([GOBERLAY_BIN], env=env, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    
    # Wait loop for window to appear
    print("[*] Waiting for GOverlay window to spawn...")
    window_id = None
    for attempt in range(40):  # Try for 20 seconds
        time.sleep(0.5)
        # Search by class first (usually 'goverlay'), then title name case-insensitively
        res = run_cmd("xdotool search --class goverlay")
        window_ids = res.stdout.strip().split()
        if not window_ids:
            res = run_cmd("xdotool search --name '[Gg]overlay'")
            window_ids = res.stdout.strip().split()
        
        if window_ids:
            window_id = window_ids[0]
            break
            
    if not window_id:
        print("[-] Error: GOverlay window not found after 15 seconds.")
        if goverlay_proc.poll() is not None:
            stdout, stderr = goverlay_proc.communicate()
            print(f"GOverlay exited early. Stderr:\n{stderr}")
        sys.exit(1)
    
    print(f"[+] Found GOverlay window ID: {window_id}")
    
    # Get window DPI scale factors
    scale_w, scale_h = get_window_scale(window_id)
    print(f"[*] Calculated scaling factors: Width={scale_w:.2f}, Height={scale_h:.2f}")

    # Activate and raise window
    run_cmd(f"xdotool windowactivate {window_id}")
    time.sleep(1)

    # Capture screenshot for debugging if import (ImageMagick) is available
    SCREENSHOTS_DIR = os.path.join(SCRIPT_DIR, "screenshots")
    if shutil.which("import") is not None:
        os.makedirs(SCREENSHOTS_DIR, exist_ok=True)
        run_cmd(f"import -window root {os.path.join(SCREENSHOTS_DIR, 'initial_state.png')}")
        print(f"[*] Initial state screenshot saved to {os.path.join(SCREENSHOTS_DIR, 'initial_state.png')}")

    # 3. Simulate E2E Interactions
    
    # Click OptiScaler Tab (X=142, Y=345 relative to window)
    print("[*] Clicking OptiScaler tab...")
    click_relative(window_id, 142, 345, scale_w, scale_h)
    time.sleep(2.5)
    if shutil.which("import") is not None:
        run_cmd(f"import -window root {os.path.join(SCREENSHOTS_DIR, 'optiscaler_tab_active.png')}")

    # Verify OptiScaler configuration was loaded
    opti_ini_path = os.path.join(MOCK_CONFIG_DIR, "OptiScaler.ini")
    print(f"[*] Checking OptiScaler INI path: {opti_ini_path}")

    # Click MESA GPU Driver radio button
    # Since window manager borders/decorations might offset Y, we try a vertical click sweep
    # (X=723 relative to window, Y sweeps from 52, 92, 122, 142)
    print("[*] Toggling MESA GPU Driver option (performing click sweep)...")
    clicked_mesa = False
    opti_y_offset = 92 # default fallback
    for y_offset in [52, 92, 122, 142]:
        print(f"[*] Trying to click MESA option at Y-offset: {y_offset}...")
        click_relative(window_id, 723, y_offset, scale_w, scale_h)
        time.sleep(2)
        
        # Verify if changing driver saved the configuration silently
        if os.path.exists(opti_ini_path):
            config = configparser.ConfigParser()
            config.read(opti_ini_path)
            if "Upscale" in config and config.getboolean("Upscale", "ForceReflex", fallback=False):
                print(f"[+] Success: MESA clicked successfully at Y-offset {y_offset}!")
                opti_y_offset = y_offset
                clicked_mesa = True
                if shutil.which("import") is not None:
                    run_cmd(f"import -window root {os.path.join(SCREENSHOTS_DIR, 'optiscaler_mesa_clicked.png')}")
                break

    if not clicked_mesa:
        print("[-] Assertion Fail: OptiScaler.ini was not generated after driver toggle sweeps.")
        sys.exit(1)

    # Click NVIDIA GPU Driver option to restore/verify toggle (X=293, using working Y-offset)
    print(f"[*] Toggling NVIDIA GPU Driver option at Y-offset {opti_y_offset}...")
    click_relative(window_id, 293, opti_y_offset, scale_w, scale_h)
    time.sleep(2)
    if shutil.which("import") is not None:
        run_cmd(f"import -window root {os.path.join(SCREENSHOTS_DIR, 'optiscaler_nvidia_clicked.png')}")

    # Re-verify configuration file changes
    config.read(opti_ini_path)
    if "Upscale" in config and not config.getboolean("Upscale", "ForceReflex", fallback=True):
         print("[+] Assertion Pass: ForceReflex successfully reset to False under [Upscale] for NVIDIA.")
    else:
         print("[-] Assertion Fail: ForceReflex did not reset to False in OptiScaler.ini.")
         sys.exit(1)

    # 4. Navigate back to MangoHud (X=142, Y=165)
    print("[*] Navigating to MangoHud tab...")
    click_relative(window_id, 142, 165, scale_w, scale_h)
    time.sleep(2)
    
    # Close GOverlay gracefully
    print("[*] Closing GOverlay...")
    run_cmd(f"xdotool windowkill {window_id}")
    time.sleep(1)

    print("[+] All integration tests passed successfully!")

finally:
    # Cleanup processes
    print("[*] Cleaning up processes...")
    if goverlay_proc and goverlay_proc.poll() is None:
        goverlay_proc.terminate()
        goverlay_proc.wait()
    
    if xvfb_proc:
        xvfb_proc.terminate()
        xvfb_proc.wait()
    
    # Cleanup temp directory
    shutil.rmtree(TEMP_DIR)
