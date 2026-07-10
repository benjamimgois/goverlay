## 1. Dependency Check Implementation

- [x] 1.1 Update `CheckDependencies` in `goverlay_system.pas` to check for the implicit layer configuration JSON files and fallback shared library.
- [x] 1.2 Update `CheckDependencies` in `apputils.pas` to check for the implicit layer configuration JSON files and fallback shared library.

## 2. UI Integration on Home Tab

- [x] 2.1 Update `DEP_NAMES` array size declaration and values in `home_tab.pas` to include the `'Low Latency'` dependency name.
- [x] 2.2 Increase the `Dependencies` card height to fit the new row and update the dependency rendering loop to iterate up to index 6 in `home_tab.pas`.
- [x] 2.3 Update constants `DEP_KEYS`, `DEP_DISPLAY`, and `DEP_HINTS` in `THomeTabHelper.RefreshHomeDeps` to declare `array[0..6]` and add `'vulkan-low-latency-layer'`.
