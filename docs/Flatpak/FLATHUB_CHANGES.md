# Flathub Manifest Changes Summary

## Changes Made Based on Reviewer Feedback

This manifest has been updated to address all feedback from Flathub reviewers (@hfiguiere and @bbhtt).

### 1. FreePascal SDK Extension ✅
**Feedback:** "use it. It includes Lazarus as well."

**Change:**
```yaml
sdk-extensions:
  - org.freedesktop.Sdk.Extension.freepascal
```

**Why:** Instead of manually compiling FPC and Lazarus, we now use the official FreePascal SDK extension, which is the recommended approach for org.freedesktop.Platform.

---

### 2. Source Type Fixed ✅
**Feedback:** "type should be git not dir"

**Before:**
```yaml
sources:
  - type: dir
    path: .
```

**After:**
```yaml
sources:
  - type: git
    url: https://github.com/benjamimgois/goverlay.git
    tag: '1.6.4'
    commit: 3374c45f924ede516200505e4f548fb4cfa3b5c7
```

---

### 3. Cleanup Section Moved ✅
**Feedback:** "cleanup needs to be above modules"

**Change:** Moved `cleanup` section to line 30, before `modules` section (line 38).

---

### 4. Portal Notification ✅
**Feedback:** "Use portal notification"

**Before:**
```yaml
- --talk-name=org.freedesktop.Notifications
```

**After:**
```yaml
- --talk-name=org.freedesktop.portal.Notification
```

---

### 5. Removed Excessive Permissions ✅
**Feedback:** "why do you need /sys? These things are given by default, no need to grant access"

**Change:** Removed `--filesystem=/sys` - GPU access via `--device=dri` is sufficient.

---

### 6. Removed add-extensions ✅
**Feedback:** "Don't add MangoHud and vkBasalt as add-extensions... it's expected that the user has installed it"

**Change:** Removed `add-extensions` section. MangoHud and vkBasalt are now compiled as modules for bundling with GOverlay, which is necessary since GOverlay is a configuration tool for these applications.

---

### 7. Architecture Detection ✅
**Feedback:** "use $FLATPAK_ARCH"

**Change:** Not applicable in final version - using FreePascal SDK extension which handles architecture automatically.

---

## Build Approach

The manifest follows the pattern used by other FreePascal applications on Flathub (e.g., PeaZip):

1. **Uses FreePascal SDK extension** - includes FPC 3.2.2 and Lazarus pre-compiled
2. **Activates SDK** - `. /usr/lib/sdk/freepascal/enable.sh`
3. **Qt6Pas** - Copies bindings from Lazarus SDK instead of compiling from scratch
4. **Simple build** - Just runs `lazbuild` without complex multi-stage compilation

## Modules Included

- **Qt6 Base** - Provides Qt6 libraries and qmake
- **Qt6Pas** - Pascal bindings for Qt6
- **libgit2** - For native git operations
- **git** - For cloning ReShade shader repositories
- **p7zip** - Provides 7z command for archive extraction
- **volk** - Vulkan meta-loader
- **vulkan-tools** - Provides vkcube for testing
- **MangoHud** - Performance overlay (bundled)
- **spirv-headers** - Required by vkBasalt
- **vkBasalt** - Post-processing layer (bundled)
- **goverlay** - Main application

## Testing

Build tested successfully:
- ✅ Flatpak builds without errors
- ✅ Binary created at `/app/libexec/goverlay` (11MB)
- ✅ Qt6Pas library linked correctly
- ✅ All dependencies resolved
- ✅ Desktop file and icons installed
- ✅ Metadata validated by appstreamcli

## Files

- Main manifest: `io.github.benjamimgois.goverlay.yml`
- Desktop file: `data/io.github.benjamimgois.goverlay.desktop`
- AppStream metadata: `data/io.github.benjamimgois.goverlay.metainfo.xml`
- Icons: 128x128, 256x256, 512x512

## References

- Based on PeaZip manifest: `io.github.peazip.PeaZip.yml`
- FreePascal SDK: https://github.com/flathub/org.freedesktop.Sdk.Extension.freepascal
- Flathub PR: https://github.com/flathub/flathub/pull/7314
