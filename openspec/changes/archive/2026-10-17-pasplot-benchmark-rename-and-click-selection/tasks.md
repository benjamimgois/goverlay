# Tasks: PasPlot Benchmark Renaming and Full-Card Click Selection

## 1. Metadata Persistence & Data Model

- [x] 1.1 Add `IniFiles` and `Menus` to the `uses` clause in `pasplot_form.pas` and implement `GetBenchmarkCustomName` and `SetBenchmarkCustomName` helpers accessing `~/.config/goverlay/logs/<GameName>/benchmarks.ini`. Verify that reading and writing INI keys works with valid and empty values.
- [x] 1.2 Update `LoadRunsForSelectedGame` to load custom names from `benchmarks.ini` into `FDiscoveredRuns[I].DisplayName`, falling back to `FormatRunTimestampFromFileName`. Verify by loading a sample game log directory with and without `benchmarks.ini`.
- [x] 1.3 Update `DeleteRunClick` to clean up the corresponding key from `benchmarks.ini` whenever a benchmark run is deleted. Verify that deleted runs no longer have leftover keys in `benchmarks.ini`.

## 2. Full-Card Click Selection & Cursor

- [x] 2.1 Set `FRunCheckListBox.Cursor := crHandPoint` and implement `RunCheckListMouseDown` to toggle `Checked[Idx]` on left mouse clicks when `X >= 20` (outside native checkbox area), calling `ReloadCheckedRunsData`. Verify that clicking the dot, text, or card background toggles selection.
- [x] 2.2 Handle right mouse clicks in `RunCheckListMouseDown` to set `FRunCheckListBox.ItemIndex := Idx` so context menu actions accurately target the clicked item. Verify that right clicking an unselected item selects it.

## 3. Renaming Triggers & Interaction

- [x] 3.1 Implement `PromptRenameBenchmark(AIndex: Integer)` displaying an `InputQuery` modal with the current name pre-filled, updating `benchmarks.ini` and refreshing `FLoadedRuns`, `FStatsGrid`, and chart titles upon confirmation. Verify that entering a new string updates `DisplayName`, while clearing the text restores the timestamp.
- [x] 3.2 Add `FRenameRunBtn: TBitBtn` on `FTopPanel` positioned between `FOpenFolderBtn` and `FDeleteRunBtn`, wired to rename the selected item. Verify that clicking `[Rename Run]` opens the rename dialog.
- [x] 3.3 Add `FRunPopupMenu: TPopupMenu` with `"Rename Benchmark... (F2)"` and `"Delete Benchmark"` attached to `FRunCheckListBox`, and wire the `F2` key in `FRunCheckListBox.OnKeyDown`. Verify both right-click menu and pressing `F2` trigger renaming.
- [x] 3.4 Wire `FRunCheckListBox.OnDblClick` to trigger `PromptRenameBenchmark`, ensuring `MouseDown` double-click detection (`ssDouble in Shift`) avoids double-toggling the checkbox. Verify double-clicking opens rename without changing check status.

## 4. Card Layout & Verification

- [x] 4.1 Update `RunCheckListDrawItem` to render the custom name as the card title, and display the original timestamp in the footer line alongside duration, FPS, and power metrics (`YYYY-MM-DD HH:MM • Xs • Y FPS • ZW`) when renamed. Verify visual layout in both Light and Dark themes.
- [x] 4.2 Compile GOverlay with `make` (or `lazbuild`) and execute logic and GUI test suites to ensure zero compilation regressions and verify all views reflect custom benchmark names.

## Workflow follow-up

- Archive the change after implementation and user acceptance testing are complete.
