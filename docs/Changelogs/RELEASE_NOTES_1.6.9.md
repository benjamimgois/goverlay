# Release Notes 1.6.9

## New Features
- **GPU Selection**: Added "Use both GPUs" option in configuration, allowing simpler selection for multi-GPU setups.
- **Testing Tools**: Prioritized `pascube` over `vkcube` for testing MangoHud/VkBasalt effects. if `pascube` is available, it will be used automatically; otherwise, the system falls back to `vkcube` with a notification.

## Fixes & Improvements
- **Flatpak Support**: Fixed OptiScaler `fgmod` installation path to correctly use the real user home directory (`/home/$USER/fgmod`) instead of the sandbox container path.
- **System Detection**: Optimized system detection routines.
