# CachyOS/Arch Linux Build Issue - FPC Thread Creation Bug

## Problem Summary

The Free Pascal Compiler (FPC 3.2.2) package in CachyOS/Arch Linux has a **critical bug** that prevents **ANY** Pascal program from creating threads, including `lazbuild`. This affects both Lazarus 4.4-1.1 and any Pascal application using the `cthreads` unit.

### Error Message
```
[FORMS.PP] ExceptionOccurred
  Sender=EThread
  Exception=Failed to create new thread
  Stack trace:
  $0000000000445F86
  ...
Exception at 0000000000445F86: EThread:
Failed to create new thread.
```

## Root Cause - UPDATED 2025-12-03

**CONFIRMED**: The issue is with the **FPC 3.2.2-11.1** package from cachyos-extra-znver4 repository, NOT just lazbuild.

### Diagnostic Results

1. ✅ **C/pthread works**: Native C programs using `pthread_create()` work perfectly
2. ✅ **System limits OK**: ulimit and systemd TasksMax are properly configured
3. ✅ **pthread library present**: `/usr/lib/libpthread.so.0` exists and is functional
4. ❌ **FPC binaries broken**: Binaries compiled by FPC are NOT linked with libpthread
5. ❌ **All Pascal threads fail**: Even simple Pascal programs with `cthreads` unit fail
6. ⚠️  **Works as root**: Same binaries work when executed as root (suggests capability/security issue)

### Technical Details

```bash
# Test results:
$ ldd /tmp/test_thread
    linux-vdso.so.1 => ...
    libc.so.6 => /usr/lib/libc.so.6
    # ❌ NO libpthread.so.0 linked!

$ ./test_thread  # As user
FAILED: EThread: Failed to create new thread

$ sudo ./test_thread  # As root
SUCCESS: Thread created!
```

The FPC compiler is not properly linking pthread, even when:
- `{$linklib pthread}` directive is used
- `cthreads` unit is included
- `-k-lpthread` flag is passed

### Why It Works as Root

The fact that the same binary works as root suggests one of:
1. **Capability issue**: Root has CAP_SYS_RESOURCE or similar capabilities
2. **RLIMIT bypass**: Root bypasses certain resource limits
3. **Security policy**: AppArmor/SELinux blocking thread creation for users
4. **glibc stub pthread**: Modern glibc has stub pthread in libc.so.6, but user context may block it

## Solutions

### ✅ Solution 1: Flatpak Build (RECOMMENDED - WORKS)

### Setup (One-time)
```bash
# Add Flathub repository
flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Install KDE Platform runtime
flatpak install --user flathub org.kde.Platform/x86_64/6.7
```

### Building and Installing
```bash
# Build Flatpak (uses flatpak-builder which has working lazbuild)
./build-flatpak.sh

# Install locally
flatpak install --user ./goverlay.flatpak

# Run
flatpak run io.github.benjamimgois.goverlay
```

### Advantages
- ✅ Builds successfully without lazbuild issues
- ✅ Self-contained runtime dependencies
- ✅ Easy distribution
- ✅ Sandboxed execution with proper permissions

### ⚠️ Solution 2: Switch to Arch Linux Standard Repos

CachyOS uses optimized packages (znver4) that may have compilation issues. Try using standard Arch packages:

```bash
# Check current repository
pacman -Si fpc | grep Repository

# If showing cachyos-*, switch to standard arch repos
# Edit /etc/pacman.conf and move [core] [extra] above [cachyos-*] repos

# Reinstall FPC and Lazarus from standard Arch
sudo pacman -S --asdeps fpc
sudo pacman -S lazarus

# Test if thread creation works
fpc /tmp/test_thread.pas && /tmp/test_thread
```

### ⚠️ Solution 3: Downgrade FPC Package

Try an older FPC version from cache:

```bash
# Check cache for older versions
ls -lh /var/cache/pacman/pkg/fpc-*.pkg.tar.zst

# Downgrade to older version (if available)
sudo pacman -U /var/cache/pacman/pkg/fpc-<older-version>.pkg.tar.zst

# Prevent upgrade
sudo pacman -Dd fpc lazarus  # Add to IgnorePkg in /etc/pacman.conf
```

### ❌ Solution 4: Build FPC from Source (Complex)

Building FPC requires an existing FPC (bootstrap problem):

```bash
# This is complex and may not work due to circular dependency
# Only attempt if you have another working FPC installation

git clone https://gitlab.com/freepascal.org/fpc/source.git
cd source
git checkout release_3_2_2

# Bootstrap with existing FPC (if it works)
make clean
make all FPC=/usr/lib/fpc/3.2.2/ppcx64
```

## Alternative Solutions (Less Reliable)

### 1. Run as Root (NOT RECOMMENDED FOR SECURITY)

Since the binary works as root, you could theoretically:

```bash
# ⚠️ SECURITY RISK - Do not use for production
sudo lazbuild -B goverlay.lpi --bm=Release
sudo chown $USER:$USER goverlay
./goverlay
```

**Why this is bad:**
- Security risk running compiler as root
- Binary may have incorrect ownership/permissions
- Not a real fix, just a workaround

### 2. Use Capability Workaround (EXPERIMENTAL)

Try giving the binary specific capabilities:

```bash
# Compile first (will fail at runtime)
lazbuild -B goverlay.lpi --bm=Release || true

# Add capabilities to allow thread creation
sudo setcap cap_sys_resource+ep ./goverlay

# Test
./goverlay
```

This is unlikely to work but worth trying.

## Reporting the Bug

This bug should be reported to **CachyOS** (since the affected package is from cachyos-extra-znver4) and **Arch Linux**:

### Bug Report Template for CachyOS

```
Package: fpc 3.2.2-11.1 (cachyos-extra-znver4)
Affects: lazarus 4.4-1.1, all Pascal programs using threads
Severity: Critical - prevents any Pascal threading functionality

Summary: FPC binaries fail to create threads for non-root users

Description:
The Free Pascal Compiler (FPC) 3.2.2-11.1 from cachyos-extra-znver4 produces binaries that
cannot create threads when run as regular users. The same binaries work correctly when run as root.

Root Cause:
FPC-compiled binaries are not properly linked with libpthread, even when using the cthreads unit.

Steps to Reproduce:
1. Install fpc package (3.2.2-11.1) from cachyos-extra-znver4
2. Create simple Pascal program with cthreads unit:

   program Test;
   {$mode objfpc}{$H+}
   uses {$IFDEF UNIX}cthreads,{$ENDIF} Classes;
   var T: TThread;
   begin
     T := TThread.Create(False);
     T.WaitFor;
   end.

3. Compile: fpc test.pas
4. Check linking: ldd test  # Shows NO libpthread.so.0!
5. Run as user: ./test  # Fails with "EThread: Failed to create new thread"
6. Run as root: sudo ./test  # Works!

Expected Behavior:
- FPC should link pthread library correctly
- Compiled binaries should create threads as regular user

Actual Behavior:
- FPC binaries lack libpthread linkage
- Thread creation fails for non-root users
- lazbuild, Lazarus IDE, and all Pascal threading apps are broken

System Information:
- FPC: 3.2.2-11.1 (cachyos-extra-znver4)
- Lazarus: 4.4-1.1
- Architecture: x86_64_v4
- Kernel: 6.12.59-2-cachyos-lts
- Distro: CachyOS Linux
- Build date: Sat Jun 8 2024

Diagnostic Evidence:
- C programs with pthread work perfectly
- ulimit -u shows 126259 (sufficient)
- systemd TasksMax=infinity
- /usr/lib/libpthread.so.0 exists and works
- FPC /usr/lib/fpc/3.2.2/ppcx64 compiled Jun 8 2024

Possible Causes:
1. FPC package built with incorrect optimization flags (znver4-specific)
2. Missing -lpthread in FPC build configuration
3. Issue with PIE/PIC flags in znver4 toolchain
4. cthreads.o unit not properly linking pthread

Impact:
- **ALL Lazarus development blocked**
- Cannot build any Free Pascal applications using threads
- Affects: Goverlay, LazPaint, Double Commander, and other Lazarus apps

Workaround:
Use Flatpak build environment with working FPC, or switch to standard Arch repos.

Related:
- Standard Arch Linux fpc package may not have this issue
- Only affects cachyos-extra-znver4 optimized build
```

**Where to Report:**
1. **CachyOS GitHub**: https://github.com/CachyOS/CachyOS-PKGBUILDs/issues
2. **CachyOS Discord**: https://discord.gg/cachyos
3. **Arch Linux Bug Tracker**: https://bugs.archlinux.org/ (if standard Arch has the same issue)
4. **FPC Bug Tracker**: https://gitlab.com/freepascal.org/fpc/source/-/issues (as reference)

## References

- [FreePascal EThread Issue #10815](https://gitlab.com/freepascal.org/fpc/source/-/issues/10815)
- [Lazarus lazbuild crash #36318](https://gitlab.com/freepascal.org/lazarus/lazarus/-/issues/36318)
- [Arch Linux Lazarus rebuild thread](https://bbs.archlinux.org/viewtopic.php?id=285365)

## Related Files

- `build-workaround.sh` - Interactive script with build options
- `build-flatpak.sh` - Flatpak build script (working solution)
- `io.github.benjamimgois.goverlay.yml` - Flatpak manifest

## Status

- **Current Status**: ✅ **RESOLVED** - Use standard Arch repos instead of CachyOS znver4
- **Working Solution**: Install `extra/fpc` and `extra/lazarus-qt6` from standard Arch repositories
- **Root Cause**: CachyOS znver4-optimized FPC 3.2.2-11.1 has broken pthread linking
- **Fix Script**: Run `./fix-fpc-arch.sh` to switch to working packages

## Quick Fix (WORKS!)

```bash
# Run the automated fix script
./fix-fpc-arch.sh

# Or manually:
sudo pacman -S extra/fpc extra/lazarus-qt6 --needed
make clean
make
```

This installs FPC 3.2.2-11 (without .1 suffix) from standard Arch which has proper pthread support.
