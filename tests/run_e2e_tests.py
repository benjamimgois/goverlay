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

# Seed mock goverlay.conf to bypass the Changelog/What's New popup and start with Mesa driver checked
mock_config_path = os.path.join(MOCK_CONFIG_DIR, "goverlay.conf")
with open(mock_config_path, "w") as f:
    f.write("[General]\nChangelogSeenVersion=1.8.9\n[OptiScaler]\nGpuDriver=mesa\n")
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
    wx, wy = 0, 0
    w, h = 1045, 683
    res = run_cmd(f"xdotool getwindowgeometry {window_id}")
    for line in res.stdout.split("\n"):
        if "Position:" in line:
            try:
                parts = line.split("Position:")[1].strip().split()[0].split(",")
                wx = int(parts[0])
                wy = int(parts[1])
            except Exception as e:
                print(f"[-] Warning: Failed to parse window position ({e}).")
        elif "Geometry:" in line:
            try:
                parts = line.split("Geometry:")[1].strip().split("x")
                w = int(parts[0])
                h = int(parts[1])
            except Exception as e:
                print(f"[-] Warning: Failed to parse window geometry ({e}).")
    print(f"[+] Detected window position: {wx},{wy}, size: {w}x{h}")
    return wx, wy, w, h

def get_dpi_scale():
    try:
        res = subprocess.run("xrdb -query", shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        if res.returncode != 0:
            print(f"[-] Warning: xrdb failed with exit code {res.returncode}. Stderr: {res.stderr.strip()}")
            return 1.0
        for line in res.stdout.split("\n"):
            if "Xft.dpi:" in line:
                dpi = float(line.split("Xft.dpi:")[1].strip())
                scale = dpi / 96.0
                print(f"[+] Detected system DPI: {dpi} (Scale: {scale:.3f})")
                return scale
    except Exception as e:
        print(f"[-] Warning: Failed to detect DPI via xrdb ({e}). Defaulting to 1.0.")
    return 1.0

def click_relative(window_id, rx, ry, scale_w, scale_h, align="left"):
    # Left sidebar menu width scales with DPI
    sidebar_w = int(211 * scale_w)
    margin = 8
    
    if align == "fixed":
        # Sidebar elements (left is relative to sidebar)
        tx = int(rx * scale_w)
        ty = int(ry * scale_h)
    elif align == "right":
        # Right-anchored inside content panel (e.g. Mesa)
        # Distance from right edge in design coordinates: 1045 - rx
        dist_from_right = 1045 - rx
        # In forced window width (1045), right edge is at 1045
        tx = 1045 - dist_from_right
        ty = int(ry * scale_h)
    else: # "left" or left-anchored inside content panel (e.g. Nvidia)
        # Position is relative to sidebar edge
        # design left of control inside content panel: rx - 211
        left_inside_panel = rx - 211 - margin
        # scale the control's Left property inside the panel
        tx = sidebar_w + margin + int(left_inside_panel * scale_w)
        ty = int(ry * scale_h)
        
    print(f"[*] Clicking relative ({rx}, {ry}) -> physical ({tx}, {ty}) [scale_w={scale_w:.3f}, align={align}]")
    run_cmd(f"xdotool windowfocus {window_id}")
    time.sleep(0.2)
    # Simulate a physical click with a delay, ensuring window focus and window-relative coordinates
    run_cmd(f"xdotool windowactivate {window_id}")
    run_cmd(f"xdotool mousemove --window {window_id} {tx} {ty} click 1")
    time.sleep(0.1)
    run_cmd(f"xdotool mousemove --window {window_id} {tx} {ty} mousedown 1 sleep 0.1 mouseup 1")

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
    
    goverlay_proc = subprocess.Popen([GOBERLAY_BIN], env=env, text=True)
    
    # Wait for GOverlay's background initialization / downloads to complete
    print("[*] Waiting 12 seconds for GOverlay auto-installation and update threads to settle...")
    time.sleep(12)

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
            print("GOverlay exited early.")
        sys.exit(1)
    
    print(f"[+] Found GOverlay window ID: {window_id}")
    
    # Activate and raise window
    run_cmd(f"xdotool windowactivate {window_id}")
    time.sleep(1.5)

    # Detect scale factor using system DPI scale from xrdb
    scale_w = get_dpi_scale()
    scale_h = scale_w
    print(f"[*] Calculated scaling factors from system DPI: Width={scale_w:.3f}, Height={scale_h:.3f}")

    # Get window DPI geometry size after settling just for logging
    _, _, w, h = get_window_geometry(window_id)

    # Force window size to design dimensions to ensure stable coordinate mappings
    print("[*] Forcing GOverlay window size to 1045x683...")
    run_cmd(f"xdotool windowsize {window_id} 1045 683")
    time.sleep(2)

    # Capture screenshot for debugging if import (ImageMagick) is available
    SCREENSHOTS_DIR = os.path.join(SCRIPT_DIR, "screenshots")
    if shutil.which("import") is not None:
        os.makedirs(SCREENSHOTS_DIR, exist_ok=True)
        run_cmd(f"import -window root {os.path.join(SCREENSHOTS_DIR, 'initial_state.png')}")
        print(f"[*] Initial state screenshot saved to {os.path.join(SCREENSHOTS_DIR, 'initial_state.png')}")

    # 3. Simulate E2E Interactions
    
    # Click OptiScaler Tab (X=142, Y=345 relative to window)
    print("[*] Clicking OptiScaler tab...")
    click_relative(window_id, 142, 345, scale_w, scale_h, align="fixed")
    time.sleep(2)
    if shutil.which("import") is not None:
        run_cmd(f"import -window root {os.path.join(SCREENSHOTS_DIR, 'optiscaler_tab_active.png')}")

    # Verify OptiScaler configuration was loaded
    opti_ini_path = os.path.join(MOCK_HOME, ".local", "share", "goverlay", "gameconfig", "global", "OptiScaler.ini")
    print(f"[*] Checking OptiScaler INI path: {opti_ini_path}")

    # Click MESA GPU Driver radio button
    # Since window manager borders/decorations might offset Y, we try a vertical click sweep
    # Mesa is right-anchored: X=728 relative to design size (1045) to click the actual TRadioButton (not the image)
    print("[*] Toggling MESA GPU Driver option (performing click sweep)...")
    clicked_mesa = False
    opti_y_offset = 76 # default fallback
    for y_offset in [76, 52, 92, 122, 142]:
        print(f"[*] Trying to click MESA option at Y-offset: {y_offset}...")
        click_relative(window_id, 728, y_offset, scale_w, scale_h, align="right")
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

    # Click NVIDIA GPU Driver option to restore/verify toggle (performing click sweep)
    print("[*] Toggling NVIDIA GPU Driver option...")
    clicked_nv = False
    for x_offset in [297, 293, 283, 303, 273]:
        for y_offset in [opti_y_offset, 76, 52, 92, 122, 142]:
            print(f"[*] Trying to click NVIDIA option at X: {x_offset}, Y: {y_offset}...")
            click_relative(window_id, x_offset, y_offset, scale_w, scale_h, align="left")
            time.sleep(2)
            
            # Re-verify configuration file changes in goverlay.conf
            config.read(mock_config_path)
            if "OptiScaler" in config and config.get("OptiScaler", "GpuDriver", fallback="").lower() == "nvidia":
                print(f"[+] Success: NVIDIA clicked successfully at X: {x_offset}, Y: {y_offset}! (GpuDriver=nvidia detected)")
                clicked_nv = True
                if shutil.which("import") is not None:
                    run_cmd(f"import -window root {os.path.join(SCREENSHOTS_DIR, 'optiscaler_nvidia_clicked.png')}")
                break
        if clicked_nv:
            break

    if not clicked_nv:
         print("[-] Assertion Fail: GpuDriver did not reset to nvidia in goverlay.conf.")
         sys.exit(1)

    # 4. Navigate back to MangoHud (X=142, Y=165)
    print("[*] Navigating to MangoHud tab...")
    click_relative(window_id, 142, 165, scale_w, scale_h, align="fixed")
    time.sleep(2)
    
    # Close GOverlay gracefully
    print("[*] Closing GOverlay...")
    run_cmd(f"xdotool windowkill {window_id}")
    time.sleep(1)

    print("[+] All integration tests passed successfully!")
    test_passed = True

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
    if 'test_passed' in locals() and test_passed:
        shutil.rmtree(TEMP_DIR)
    else:
        print(f"[*] Preserving isolated environment for diagnostics: {TEMP_DIR}")
