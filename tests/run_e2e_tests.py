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

# Seed mock goverlay.conf to bypass the Changelog/What's New popup
mock_config_path = os.path.join(MOCK_CONFIG_DIR, "goverlay.conf")
with open(mock_config_path, "w") as f:
    f.write("[General]\nChangelogSeenVersion=1.8.9\n")
print(f"[*] Seeded mock goverlay.conf at: {mock_config_path}")

# Seed mock OptiScaler.ini template in optiscaler-stable cache and global gameconfig dir
STABLE_CACHE_DIR = os.path.join(MOCK_HOME, ".local", "share", "goverlay", "optiscaler-stable")
GLOBAL_CFG_DIR = os.path.join(MOCK_HOME, ".local", "share", "goverlay", "gameconfig", "global")
os.makedirs(STABLE_CACHE_DIR, exist_ok=True)
os.makedirs(GLOBAL_CFG_DIR, exist_ok=True)

opti_template = "[Menu]\nShortcutKey=auto\nScale=1.0\n[Upscale]\nForceReflex=false\n"
with open(os.path.join(STABLE_CACHE_DIR, "OptiScaler.ini"), "w") as f:
    f.write(opti_template)
with open(os.path.join(GLOBAL_CFG_DIR, "OptiScaler.ini"), "w") as f:
    f.write(opti_template)
print(f"[*] Seeded mock OptiScaler.ini template at: {STABLE_CACHE_DIR} and {GLOBAL_CFG_DIR}")

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

def get_window_geometry(window_id):
    res = run_cmd(f"xdotool getwindowgeometry {window_id}")
    for line in res.stdout.split("\n"):
        if "Geometry:" in line:
            try:
                parts = line.split("Geometry:")[1].strip().split("x")
                w = int(parts[0])
                h = int(parts[1])
                print(f"[+] Detected window physical size: {w}x{h}")
                return w, h
            except Exception as e:
                print(f"[-] Warning: Failed to parse window geometry ({e}). Defaulting to 1045x683.")
    return 1045, 683

def click_relative(window_id, rx, ry, scale_w, scale_h):
    tx = int(rx * scale_w)
    ty = int(ry * scale_h)
    print(f"[*] Clicking relative ({rx}, {ry}) -> physical ({tx}, {ty}) [scale_w={scale_w:.3f}, scale_h={scale_h:.3f}]")
    run_cmd(f"xdotool windowfocus {window_id}")
    time.sleep(0.2)
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
    
    # Force window size to design dimensions to ensure stable coordinate mappings
    print("[*] Forcing GOverlay window size to 1045x683...")
    run_cmd(f"xdotool windowsize {window_id} 1045 683")
    time.sleep(1.5)

    # Get window DPI geometry size
    w, h = get_window_geometry(window_id)
    scale_w = w / 1045.0
    scale_h = h / 683.0
    print(f"[*] Calculated scaling factors: Width={scale_w:.3f}, Height={scale_h:.3f}")

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
    # We click in two vertical locations to handle title bar decoration offsets of up to 40px
    print("[*] Clicking OptiScaler tab (dual-click vertical sweep)...")
    click_relative(window_id, 142, 345, scale_w, scale_h)
    time.sleep(1.5)
    click_relative(window_id, 142, 385, scale_w, scale_h)
    time.sleep(2)
    if shutil.which("import") is not None:
        run_cmd(f"import -window root {os.path.join(SCREENSHOTS_DIR, 'optiscaler_tab_active.png')}")

    # Verify OptiScaler configuration was loaded
    opti_ini_path = os.path.join(MOCK_HOME, ".local", "share", "goverlay", "gameconfig", "global", "OptiScaler.ini")
    print(f"[*] Checking OptiScaler INI path: {opti_ini_path}")

    # Click MESA GPU Driver radio button
    # Since window manager borders/decorations might offset Y, we try a vertical click sweep
    # Mesa is right-anchored: X=715 relative to design size (1045) to click the actual TRadioButton (not the image)
    print("[*] Toggling MESA GPU Driver option (performing click sweep)...")
    clicked_mesa = False
    opti_y_offset = 92 # default fallback
    for y_offset in [52, 92, 122, 142]:
        print(f"[*] Trying to click MESA option at Y-offset: {y_offset}...")
        click_relative(window_id, 715, y_offset, scale_w, scale_h)
        time.sleep(2)
        
        # Verify if changing driver saved the configuration in goverlay.conf
        if os.path.exists(mock_config_path):
            config = configparser.ConfigParser()
            config.read(mock_config_path)
            if "OptiScaler" in config and config.get("OptiScaler", "GpuDriver", fallback="").lower() == "mesa":
                print(f"[+] Success: MESA clicked successfully at Y-offset {y_offset}! (GpuDriver=mesa detected in goverlay.conf)")
                opti_y_offset = y_offset
                clicked_mesa = True
                if shutil.which("import") is not None:
                    run_cmd(f"import -window root {os.path.join(SCREENSHOTS_DIR, 'optiscaler_mesa_clicked.png')}")
                break

    if not clicked_mesa:
        print("[-] Assertion Fail: MESA driver preference was not saved after click sweeps.")
        sys.exit(1)

    # Click NVIDIA GPU Driver option to restore/verify toggle (X=285, TRadioButton, using working Y-offset)
    print(f"[*] Toggling NVIDIA GPU Driver option at Y-offset {opti_y_offset}...")
    click_relative(window_id, 285, opti_y_offset, scale_w, scale_h)
    time.sleep(2)
    if shutil.which("import") is not None:
        run_cmd(f"import -window root {os.path.join(SCREENSHOTS_DIR, 'optiscaler_nvidia_clicked.png')}")

    # Re-verify configuration file changes in goverlay.conf
    config.read(mock_config_path)
    if "OptiScaler" in config and config.get("OptiScaler", "GpuDriver", fallback="").lower() == "nvidia":
         print("[+] Assertion Pass: GpuDriver successfully reset to nvidia in goverlay.conf.")
    else:
         print("[-] Assertion Fail: GpuDriver did not reset to nvidia in goverlay.conf.")
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
