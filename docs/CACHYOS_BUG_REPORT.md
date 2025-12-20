# Bug Report: FPC 3.2.2-11.1 Thread Creation Failure on CachyOS

**Repository Issue Link:** https://github.com/CachyOS/CachyOS-PKGBUILDs/issues

---

## Summary

The Free Pascal Compiler (FPC) package version **3.2.2-11.1** from the **cachyos-extra-znver4** repository produces binaries that **cannot create threads** when executed by non-root users. This completely breaks all Lazarus development and any Free Pascal application using threading.

---

## Package Information

- **Package Name:** `fpc`
- **Affected Version:** `3.2.2-11.1`
- **Repository:** `cachyos-extra-znver4`
- **Architecture:** `x86_64_v4`
- **Build Date:** Sat Jun 8 2024
- **Also Affects:** `lazarus 4.4-1.1`, all Pascal programs using `cthreads` unit

---

## Severity

**CRITICAL** - Completely prevents:
- All Lazarus IDE development
- Building any Free Pascal applications with threading
- Running existing Pascal applications that use threads
- Affects multiple applications: Goverlay, LazPaint, Double Commander, etc.

---

## Problem Description

### What Happens

When compiling Pascal programs with the `cthreads` unit using FPC 3.2.2-11.1 from cachyos-extra-znver4:

1. Compilation succeeds without errors (except harmless crtbeginS.o warnings)
2. The resulting binary is **NOT linked with libpthread**
3. When run as a regular user, thread creation fails with: `EThread: Failed to create new thread`
4. **The same binary works perfectly when run as root**

### Root Cause

FPC-compiled binaries are missing `libpthread` linkage, even when:
- Using `{$IFDEF UNIX}cthreads{$ENDIF}` in the source
- Adding `{$linklib pthread}` directive
- Passing `-k-lpthread` compiler flag

This suggests the FPC package was built with incorrect flags or missing pthread support in the znver4 optimization.

---

## Steps to Reproduce

### 1. Create Test Program

```bash
cat > /tmp/test_thread.pas <<'EOF'
program TestThread;
{$mode objfpc}{$H+}
uses
  {$IFDEF UNIX}cthreads,{$ENDIF}
  Classes, SysUtils;

type
  TTestThread = class(TThread)
  protected
    procedure Execute; override;
  end;

procedure TTestThread.Execute;
begin
  WriteLn('Thread created successfully!');
end;

var
  Thread: TTestThread;
begin
  try
    WriteLn('Attempting to create thread...');
    Thread := TTestThread.Create(False);
    Thread.WaitFor;
    Thread.Free;
    WriteLn('SUCCESS: Thread creation works!');
  except
    on E: Exception do
    begin
      WriteLn('FAILED: ', E.ClassName, ': ', E.Message);
      Halt(1);
    end;
  end;
end.
EOF
```

### 2. Compile with CachyOS FPC

```bash
fpc /tmp/test_thread.pas -o/tmp/test_thread
```

### 3. Check Library Linkage

```bash
ldd /tmp/test_thread
```

**Expected:** Should show `libpthread.so.0`
**Actual:** Only shows `libc.so.6` - **NO libpthread!**

### 4. Run as User

```bash
./test_thread
```

**Result:**
```
Attempting to create thread...
FAILED: EThread: Failed to create new thread
```

### 5. Run as Root

```bash
sudo ./test_thread
```

**Result:**
```
Attempting to create thread...
Thread created successfully!
SUCCESS: Thread creation works!
```

---

## Diagnostic Evidence

### System Information

```bash
$ pacman -Q fpc
fpc 3.2.2-11.1

$ pacman -Qi fpc | grep -E "^(Repository|Build Date)"
Repository       : cachyos-extra-znver4
Build Date       : Sat Jun 8 2024

$ uname -r
6.12.59-2-cachyos-lts

$ cat /etc/os-release | grep NAME
NAME="CachyOS Linux"
```

### Thread Creation Tests

#### ✅ C Program with pthread (WORKS)

```bash
$ cat > /tmp/test.c <<'EOF'
#include <pthread.h>
#include <stdio.h>
void* func(void* arg) { printf("Thread OK\n"); return NULL; }
int main() { pthread_t t; pthread_create(&t, NULL, func, NULL); pthread_join(t, NULL); return 0; }
EOF

$ gcc -pthread /tmp/test.c -o/tmp/test_c && /tmp/test_c
Thread OK
# ✅ WORKS PERFECTLY
```

#### ❌ Pascal Program with cthreads (FAILS)

```bash
$ fpc /tmp/test_thread.pas && /tmp/test_thread
FAILED: EThread: Failed to create new thread
# ❌ FAILS AS USER

$ sudo /tmp/test_thread
SUCCESS: Thread creation works!
# ✅ WORKS AS ROOT (why?)
```

### System Limits (All OK)

```bash
$ ulimit -u
126259  # More than enough

$ systemctl show user@$(id -u).service | grep TasksMax
TasksMax=infinity
EffectiveTasksMax=83330  # Still plenty

$ cat /proc/sys/kernel/threads-max
252518  # System allows many threads
```

### Library Analysis

```bash
$ ldd /tmp/test_thread
    linux-vdso.so.1 (0x00007ffc8b3f8000)
    libc.so.6 => /usr/lib/libc.so.6 (0x00007f8c9a800000)
    /lib64/ld-linux-x86-64.so.2 => /usr/lib64/ld-linux-x86-64.so.2 (0x00007f8c9aa5a000)
# ❌ NO libpthread.so.0 !!!

$ ls -l /usr/lib/libpthread.so.0
-rwxr-xr-x 1 root root 14360 Nov 14 05:21 /usr/lib/libpthread.so.0
# ✅ Library exists and is functional
```

---

## Why It Works as Root

The fact that the **exact same binary** works as root suggests:

1. **RLIMIT bypass:** Root can exceed certain resource limits
2. **Capability issue:** Root has `CAP_SYS_RESOURCE` or similar
3. **glibc stub pthread:** Modern glibc includes pthread stubs in `libc.so.6`, but user context may restrict access
4. **Security policy:** Some kernel security feature blocking non-root thread creation

This indicates the binary is *technically* trying to create threads via glibc stubs, but something in the user context prevents it.

---

## Comparison: CachyOS vs Standard Arch

### CachyOS znver4 (BROKEN)

```bash
$ pacman -Si fpc | grep Repository
Repository      : cachyos-extra-znver4

$ pacman -Q fpc
fpc 3.2.2-11.1  # Note the .1 suffix

$ fpc test.pas && ./test
FAILED: EThread: Failed to create new thread  # ❌
```

### Standard Arch (WORKS)

```bash
$ sudo pacman -S extra/fpc extra/lazarus-qt6

$ pacman -Q fpc
fpc 3.2.2-11  # No .1 suffix

$ fpc test.pas && ./test
SUCCESS: Thread creation works!  # ✅
```

---

## Impact

### Broken Applications

All Free Pascal/Lazarus applications using threads are **completely non-functional**:

- **Goverlay** - GPU overlay configurator (cannot build)
- **LazPaint** - Image editor (if using threaded operations)
- **Double Commander** - File manager (may use threads)
- **Any custom Lazarus projects** developed on CachyOS

### Developer Impact

- **Lazarus IDE development completely blocked** on CachyOS
- Developers must either:
  - Switch to Flatpak (slower, more complex)
  - Use standard Arch repos (lose znver4 optimizations)
  - Cannot use CachyOS for Pascal development

---

## Workaround

### Temporary Solution

Switch to standard Arch Linux repositories:

```bash
# Install from extra (standard Arch)
sudo pacman -S extra/fpc extra/lazarus-qt6 --needed

# Verify it works
fpc /tmp/test_thread.pas && /tmp/test_thread
# Should show: SUCCESS: Thread creation works!
```

### Prevent Upgrade Back to Broken Package

Add to `/etc/pacman.conf`:

```ini
[options]
IgnorePkg = fpc lazarus lazarus-qt6
```

Or edit repo priorities in `/etc/pacman.conf` to prioritize `[extra]` over `[cachyos-extra-znver4]` for these packages.

---

## Possible Causes

### 1. znver4 Optimization Flags

The znver4-specific optimization flags may be incompatible with FPC's thread library linking:

- LTO (Link Time Optimization) breaking pthread symbols
- PIC/PIE flags interfering with cthreads.o
- Aggressive optimization removing "unused" pthread references

### 2. Missing Build Dependencies

FPC build may be missing:

- Explicit `-lpthread` in LDFLAGS
- Proper pthread-related compiler directives
- Thread library paths during compilation

### 3. cthreads Unit Compilation Issue

The `cthreads.ppu` unit may have been compiled incorrectly for znver4:

```bash
$ ls -l /usr/lib/fpc/3.2.2/units/x86_64-linux/rtl/cthreads.*
-rw-r--r-- 1 root root 48760 Jun  8  2024 cthreads.o
-rw-r--r-- 1 root root 27538 Jun  8  2024 cthreads.ppu
```

These may not actually link pthread despite appearing present.

---

## Suggested Fix

### For CachyOS Maintainers

1. **Review PKGBUILD for fpc in cachyos-extra-znver4**
   - Compare with standard Arch `extra/fpc` PKGBUILD
   - Check for differences in CFLAGS, LDFLAGS, or build options

2. **Ensure pthread linking in FPC builds**
   - Add explicit `-lpthread` to linker flags
   - Verify `cthreads.o` unit properly links pthread

3. **Test before release**
   - Run simple thread creation test as non-root user
   - Verify `ldd` shows `libpthread.so.0` in compiled binaries

4. **Consider if znver4 optimization is worth it for FPC**
   - If optimization breaks core functionality, better to use standard build
   - Or document that FPC should be installed from `extra` repo

---

## Additional Testing

I'm available to test any fixed packages and provide detailed feedback.

### Test Environment

- **CPU:** AMD Ryzen (znver4 architecture)
- **Kernel:** 6.12.59-2-cachyos-lts
- **Use Case:** Building Goverlay (MangoHud/vkBasalt GUI)

---

## References

- [FreePascal EThread Issue #10815](https://gitlab.com/freepascal.org/fpc/source/-/issues/10815)
- [Lazarus lazbuild crash #36318](https://gitlab.com/freepascal.org/lazarus/lazarus/-/issues/36318)
- [Arch Linux FPC Package](https://archlinux.org/packages/extra/x86_64/fpc/)
- [Detailed diagnostics in project](ARCH_LINUX_BUILD_ISSUE.md)

---

## Summary for Quick Reference

| Aspect | CachyOS znver4 | Standard Arch |
|--------|----------------|---------------|
| Package | fpc 3.2.2-11.**1** | fpc 3.2.2-11 |
| Repository | cachyos-extra-znver4 | extra |
| pthread linked? | ❌ NO | ✅ YES |
| Threads work? | ❌ NO (as user) | ✅ YES |
| Root workaround? | ✅ YES | N/A |
| Lazarus builds? | ❌ NO | ✅ YES |

**Recommendation:** Rebuild `fpc 3.2.2-11.1` in cachyos-extra-znver4 with proper pthread support, or advise users to use `extra/fpc` instead.

---

**Reporter:** Benjamim (Goverlay developer)
**Date:** 2025-12-03
**Contact:** [Your GitHub/Discord if you want to add]
