#!/usr/bin/env python3
import os
import sys
import struct
import binascii
import subprocess
import shutil

def parse_vdf_bytes(data, offset=0):
    res = {}
    while offset < len(data):
        type_byte = data[offset]
        if type_byte == 8:
            return res, offset + 1
        
        offset += 1
        key_end = data.find(b'\x00', offset)
        if key_end == -1:
            raise ValueError("Corrupt VDF: key not null-terminated")
        key = data[offset:key_end].decode('utf-8', errors='ignore')
        offset = key_end + 1
        
        if type_byte == 0:
            val, offset = parse_vdf_bytes(data, offset)
            res[key] = val
        elif type_byte == 1:
            val_end = data.find(b'\x00', offset)
            if val_end == -1:
                raise ValueError("Corrupt VDF: string value not null-terminated")
            val = data[offset:val_end].decode('utf-8', errors='ignore')
            res[key] = val
            offset = val_end + 1
        elif type_byte == 2:
            if offset + 4 > len(data):
                raise ValueError("Corrupt VDF: not enough bytes for integer")
            val = struct.unpack('<I', data[offset:offset+4])[0]
            res[key] = val
            offset += 4
        else:
            raise ValueError(f"Corrupt VDF: unknown type byte {type_byte}")
    return res, offset

def serialize_vdf(dict_data):
    res = bytearray()
    for key, val in dict_data.items():
        key_bytes = key.encode('utf-8') + b'\x00'
        if isinstance(val, dict):
            res.append(0)
            res.extend(key_bytes)
            res.extend(serialize_vdf(val))
        elif isinstance(val, str):
            res.append(1)
            res.extend(key_bytes)
            res.extend(val.encode('utf-8') + b'\x00')
        elif isinstance(val, int):
            res.append(2)
            res.extend(key_bytes)
            res.extend(struct.pack('<I', val))
    res.append(8)
    return bytes(res)

def parse_shortcuts(filepath):
    if not os.path.exists(filepath) or os.path.getsize(filepath) == 0:
        return {}
    with open(filepath, 'rb') as f:
        data = f.read()
    if data[0] != 0:
        raise ValueError("File doesn't start with root map type 0")
    key_end = data.find(b'\x00', 1)
    root_key = data[1:key_end].decode('utf-8')
    if root_key != 'shortcuts':
        raise ValueError("Root key is not 'shortcuts'")
    shortcuts_dict, _ = parse_vdf_bytes(data, key_end + 1)
    return shortcuts_dict

def save_shortcuts(filepath, shortcuts_dict):
    root = {"shortcuts": shortcuts_dict}
    content = serialize_vdf(root)
    with open(filepath, 'wb') as f:
        f.write(content)

def is_steam_running():
    try:
        res = subprocess.run(['pgrep', '-x', 'steam'], capture_output=True)
        return res.returncode == 0
    except Exception:
        return False

def find_grid_assets_dir(custom_path, exe_path):
    if custom_path and os.path.isdir(custom_path):
        return os.path.realpath(custom_path)
    
    script_dir = os.path.dirname(os.path.realpath(__file__))
    parent_dir = os.path.dirname(script_dir)
    exe_dir = os.path.dirname(exe_path) if exe_path else ""
    
    candidates = [
        os.path.join(parent_dir, "data", "steam_grid"),
        os.path.join(parent_dir, "steam_grid"),
        os.path.join(script_dir, "steam_grid"),
        os.path.join(exe_dir, "data", "steam_grid"),
        os.path.join(exe_dir, "steam_grid"),
        "/usr/share/goverlay/data/steam_grid",
        "/usr/local/share/goverlay/data/steam_grid",
        "/app/share/goverlay/data/steam_grid",
    ]
    for c in candidates:
        if os.path.isdir(c):
            return os.path.realpath(c)
    return ""

def install_grid_artwork(grid_dir, short_appid, long_grid_id, grid_assets_dir, icon_path):
    if not os.path.isdir(grid_dir):
        os.makedirs(grid_dir, exist_ok=True)
    
    asset_mappings = {
        'cover.png': ['p.png'],
        'banner.png': ['.png'],
        'hero.png': ['_hero.png'],
        'logo.png': ['_logo.png'],
        'icon.png': ['_icon.png']
    }
    
    if grid_assets_dir and os.path.isdir(grid_assets_dir):
        for src_name, suffixes in asset_mappings.items():
            src_file = os.path.join(grid_assets_dir, src_name)
            if os.path.exists(src_file):
                for suf in suffixes:
                    for target_id in [str(long_grid_id), str(short_appid)]:
                        dst_file = os.path.join(grid_dir, f"{target_id}{suf}")
                        try:
                            shutil.copyfile(src_file, dst_file)
                        except Exception as e:
                            sys.stderr.write(f"Warning: Failed to copy {src_name} to {dst_file}: {e}\n")
    elif icon_path and os.path.exists(icon_path):
        # Fallback: copy icon as _icon.png
        for target_id in [str(long_grid_id), str(short_appid)]:
            dst_file = os.path.join(grid_dir, f"{target_id}_icon.png")
            try:
                shutil.copyfile(icon_path, dst_file)
            except Exception:
                pass

def remove_grid_artwork(grid_dir, ids):
    if not os.path.isdir(grid_dir):
        return
    suffixes = [
        'p.png', 'p.jpg',
        '.png', '.jpg',
        '_hero.png', '_hero.jpg',
        '_logo.png', '_logo.jpg',
        '_icon.png', '_icon.jpg'
    ]
    for id_val in ids:
        for suf in suffixes:
            fpath = os.path.join(grid_dir, f"{id_val}{suf}")
            if os.path.exists(fpath):
                try:
                    os.remove(fpath)
                except Exception as e:
                    sys.stderr.write(f"Warning: Failed to remove {fpath}: {e}\n")

def main():
    if len(sys.argv) < 3:
        print("Usage: goverlay-steam-shortcut.py <action: add|remove> <exe_path> [icon_path] [grid_assets_dir]")
        sys.exit(1)
        
    action = sys.argv[1]
    exe_path = sys.argv[2]
    icon_path = ""
    custom_grid_dir = ""
    
    if len(sys.argv) > 4:
        icon_path = sys.argv[3]
        custom_grid_dir = sys.argv[4]
    elif len(sys.argv) == 4:
        arg3 = sys.argv[3]
        if os.path.isdir(arg3):
            custom_grid_dir = arg3
        else:
            icon_path = arg3
            
    grid_assets_dir = find_grid_assets_dir(custom_grid_dir, exe_path)
    if not icon_path and grid_assets_dir:
        icon_cand = os.path.join(grid_assets_dir, "icon.png")
        if os.path.exists(icon_cand):
            icon_path = icon_cand
    
    # 1. Find all possible userdata userdata/*/config/shortcuts.vdf paths
    home = os.path.expanduser("~")
    base_dirs = [
        os.path.join(home, ".local/share/Steam/userdata"),
        os.path.join(home, ".steam/steam/userdata"),
        os.path.join(home, ".steam/root/userdata"),
        os.path.join(home, ".var/app/com.valvesoftware.Steam/.local/share/Steam/userdata")
    ]
    
    shortcut_files = []
    for base in base_dirs:
        if os.path.isdir(base):
            for user_dir in os.listdir(base):
                config_dir = os.path.join(base, user_dir, "config")
                if os.path.isdir(config_dir):
                    vdf_path = os.path.realpath(os.path.join(config_dir, "shortcuts.vdf"))
                    if vdf_path not in shortcut_files:
                        shortcut_files.append(vdf_path)
                        
    if not shortcut_files:
        print("Error: No Steam userdata folders found.")
        sys.exit(1)

    success_count = 0
    fail_count = 0
    
    # AppID generation (matching Steam behavior)
    # Concatenate Exe + AppName
    s = (exe_path + "GOverlay").encode('utf-8')
    crc = binascii.crc32(s) & 0xffffffff
    appid = crc | 0x80000000
    long_grid_id = (appid << 32) | 0x02000000
    
    for vdf_path in shortcut_files:
        try:
            config_parent = os.path.dirname(vdf_path)
            grid_dir = os.path.join(config_parent, "grid")
            
            # Check if writeable/readable
            if os.path.exists(vdf_path):
                if not os.access(vdf_path, os.W_OK):
                    print(f"Skipping (no write permission): {vdf_path}")
                    fail_count += 1
                    continue
            else:
                if not os.access(config_parent, os.W_OK):
                    print(f"Skipping (no write permission): {vdf_path}")
                    fail_count += 1
                    continue
                
            shortcuts = parse_shortcuts(vdf_path)
            
            # Find and remove any existing GOverlay shortcuts & collect IDs for artwork cleanup
            goverlay_keys = []
            goverlay_ids = {str(appid), str(long_grid_id)}
            for k, v in shortcuts.items():
                if v.get('AppName') == 'GOverlay':
                    goverlay_keys.append(k)
                    old_id = v.get('appid')
                    if old_id:
                        goverlay_ids.add(str(old_id))
                        goverlay_ids.add(str((old_id << 32) | 0x02000000))
            
            for k in goverlay_keys:
                del shortcuts[k]
                
            # Clean up old artwork
            remove_grid_artwork(grid_dir, goverlay_ids)
                
            if action == 'add':
                # Exe dir
                start_dir = os.path.dirname(exe_path)
                
                # Check for flatpak execution context
                is_flatpak = os.path.exists('/.flatpak-info') or 'FLATPAK_ID' in os.environ
                if is_flatpak:
                    # In Flatpak context, we launch goverlay using flatpak command
                    exe_val = '"flatpak"'
                    start_val = '""'
                    launch_opts = 'run io.github.benjamimgois.goverlay'
                else:
                    # Use wrapper script as the executable so it runs at OS level before
                    # Steam can inject its runtime libraries. The wrapper clears LD_LIBRARY_PATH
                    # and LD_PRELOAD via 'exec env -u', then passes all args to the real exe.
                    exe_dir = os.path.dirname(exe_path)
                    wrapper = os.path.join(exe_dir, 'assets', 'goverlay-steam-launch.sh')
                    if not os.path.exists(wrapper):
                        # Fallback: look in the same directory as the exe
                        wrapper = os.path.join(exe_dir, 'goverlay-steam-launch.sh')
                    if os.path.exists(wrapper):
                        exe_val = f'"{wrapper}"'
                        start_val = f'"{exe_dir}"'
                        launch_opts = exe_path
                    else:
                        exe_val = f'"{exe_path}"'
                        start_val = f'"{exe_dir}"'
                        launch_opts = ''
                
                new_idx = 0
                while str(new_idx) in shortcuts:
                    new_idx += 1
                    
                shortcuts[str(new_idx)] = {
                    'appid': appid,
                    'AppName': 'GOverlay',
                    'Exe': exe_val,
                    'StartDir': start_val,
                    'icon': icon_path,
                    'ShortcutPath': '',
                    'LaunchOptions': launch_opts,
                    'IsHidden': 0,
                    'AllowDesktopConfig': 1,
                    'AllowOverlay': 0,
                    'OpenVR': 0,
                    'Devkit': 0,
                    'DevkitGameID': '',
                    'last_play_time': 0,
                    'tags': {}
                }
                
                # Install Steam Grid artwork files into config/grid/
                install_grid_artwork(grid_dir, appid, long_grid_id, grid_assets_dir, icon_path)
                
            elif action == 'remove':
                pass
                
            save_shortcuts(vdf_path, shortcuts)
            success_count += 1
            
        except Exception as e:
            sys.stderr.write(f"Error processing {vdf_path}: {e}\n")
            fail_count += 1
            
    if success_count > 0:
        if action == 'add':
            print("Steam shortcut created successfully.")
        else:
            print("Steam shortcut removed successfully.")
    else:
        print("Failed to update any shortcuts.")

if __name__ == '__main__':
    main()
