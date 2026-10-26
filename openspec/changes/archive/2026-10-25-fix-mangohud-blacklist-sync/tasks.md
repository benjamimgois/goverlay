# Tasks

## 1. Centralized Blacklist Synchronization Helper

- [x] 1.1 Implement `SyncBlacklistToMangoHud` in `overlay_config.pas` to serialize process names to `blacklist=` in global host, global gameconfig profile (`gameconfig/global/MangoHud.conf`), and Flatpak `MangoHud.conf` files.
- [x] 1.2 Refactor `SaveMangoHudConfigCore` in `overlay_config.pas` to use `TConfigManager.GetBlacklistFile` and the centralized serialization helper.

## 2. Real-Time Modal Synchronization & Modern UI

- [x] 2.1 Update `blacklistunit.pas` to resolve the blacklist configuration file via `TConfigManager.GetBlacklistFile`.
- [x] 2.2 Wire `insertblacklistBitBtnClick` and `removeblacklistBitBtnClick` in `blacklistunit.pas` to call `SyncBlacklistToMangoHud` immediately after updating the list.
- [x] 2.3 Refactor `saveBitbtnClick` in `overlayunit.pas` to reuse `SyncBlacklistToMangoHud`.
- [x] 2.4 Modernize `TblacklistForm` UI layout: expand dimensions, add header typography, owner-draw list rows with status bullets and padding, add item counter label, and wire keyboard shortcuts (Enter to add, Delete to remove, Escape to close).

## 3. Verification & Testing

- [x] 3.1 Add automated test cases in `tests/logic/logic_test_cases.pas` verifying that `SyncBlacklistToMangoHud` updates host `MangoHud.conf` and `gameconfig/global/MangoHud.conf` accurately with added/removed entries and default stock entries when missing.
- [x] 3.2 Run the full logic test suite (`./tests/logic/logic_tests`) and verify all tests pass.
