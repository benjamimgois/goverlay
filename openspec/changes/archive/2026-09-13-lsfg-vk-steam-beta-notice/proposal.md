## Why

Multiple users report difficulties using `lsfg-vk 2.0` because their Steam Lossless Scaling installation remains on the default public version rather than the required `lsfg-vk` beta branch. In `lsfg-vk 2.0`, the runtime relies on native Vulkan bindless shaders provided exclusively by `lsfg-vk.dll` (downloaded through the Steam beta branch). When users select `lsfg-vk` in GOverlay without switching branches in Steam, frame generation fails silently or produces errors.

While an inline alert banner and migration assistant exist, many users do not notice the banner before testing games. Showing a visual, informative dialog immediately upon selecting `lsfg-vk`—specifically when `lsfg-vk.dll` is missing—featuring an authentic Steam settings screenshot and clear instructions will proactively resolve user confusion.

## What Changes

- Add a proactive Steam Beta Branch guidance modal popup (`TLSFGVkSteamBetaNoticeDialog`) that triggers automatically when the user selects `lsfg-vk` in the Lossless Scaling tab and `lsfg-vk.dll` is not detected in their Steam installation.
- Provide an option ("Do not show this notice again") persisted in GOverlay settings so users are not repeatedly prompted once informed.
- Include a high-contrast visual screenshot of the Steam Properties -> Betas screen (`assets/images/steam_lsfg_beta.png`) highlighting the `lsfg-vk` branch option.
- Provide direct action buttons in the popup: "Open Steam Folder" (opens Steam's Lossless Scaling directory) and "Open Migration Assistant" (for full system diagnostic).
- Enhance Step 1 of `lsfg_migration_dialog.pas` to also display this visual screenshot or preview, unifying the visual guidance across GOverlay.

## Capabilities

### Modified Capabilities
- `lsfg-vk-migration-assistant`: Add requirements for proactive Steam beta branch modal notice upon selecting `lsfg-vk` when `lsfg-vk.dll` is missing, user dismissal preference persistence, and visual screenshot guidance in the assistant dialog.

## Impact

- `lossless_scaling_tab.pas`: Hook `MethodLsfgClick` to check `CheckSteamBetaDllHealth` and show `TLSFGVkSteamBetaNoticeDialog` if `lsfg-vk.dll` is missing and user has not muted the notice.
- `lsfg_steam_beta_dialog.pas` (new unit) or within `lsfg_migration_dialog.pas`: Dedicated or shared dialog form with the visual guide image, instructions, action buttons, and "do not show again" checkbox.
- `assets/images/steam_lsfg_beta.png` (new asset): Visual screenshot of Steam Betas tab showing the `lsfg-vk` version.
- `goverlay.ini` / config: Setting `lsfg_hide_steam_beta_notice` (or similar) to persist dismissal.
- Build system: Asset installation in `Makefile` and AppImage packaging.
