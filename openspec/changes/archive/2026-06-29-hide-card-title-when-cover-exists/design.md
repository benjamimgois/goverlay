## Context

In `games_tab.pas`, non-Steam games found in user-added folders are rendered as card panels (`CardPanel`). Each card consists of a `CardImage` (background/cover art), optional badge icons/labels for tools like MangoHud/vkBasalt, and a `TLabel` (`BdgLbl`) displaying `GameName` at the bottom of the card panel.

When cover artwork is missing, `TNonSteamCoverThread` asynchronously attempts to fetch artwork from Steam Store API or Web search. If all remote sources fail, `GenerateFallbackCover` produces a synthetic fallback cover featuring the GOverlay application icon on a dark background.

Currently, `BdgLbl` is unconditionally visible on all non-Steam game cards.

## Goals / Non-Goals

**Goals:**
- Hide the `BdgLbl` text title on non-Steam cards whenever a valid, real game cover image is present.
- Ensure `BdgLbl` remains visible when a game card falls back to the generic GOverlay icon cover.
- Smoothly update title label visibility when async cover download threads finish loading real covers or fallback images.

**Non-Goals:**
- Modifying Steam library game card rendering logic.
- Changing how fallback cover images are generated or cached.

## Decisions

### 1. Tagging and Locating the Card Title Label
- **Choice**: Assign a specific marker tag (e.g. `Tag := 9991` or identificatory properties) to the bottom `BdgLbl` when creating the non-Steam card panel in `games_tab.pas`.
- **Rationale**: Searching controls by tag or type allows clean, safe lookup during UI updates without altering the child component array structure or adding complex reference tracking arrays.

### 2. Initial Visibility State based on Cache Status
- **Choice**: During initial card construction in `games_tab.pas`, set `BdgLbl.Visible := not HasCover`.
- **Rationale**: If a valid cached cover already exists on disk, the title text is hidden immediately on app launch, avoiding visual pop-in/flicker. If no cache exists yet, title text remains visible over the placeholder background.

### 3. Asynchronous Visibility Updates in `TNonSteamCoverThread`
- **Choice**: Extend the thread item structure (`FItems[i]`) or update routine (`DoUpdateImage`) to track whether the resolved cover is a fallback image (`IsFallback: Boolean`).
- **Rationale**: When `DoUpdateImage` runs on the main thread via `Synchronize`, it can update both `CardImage` and set `BdgLbl.Visible := IsFallback`. If a web/Steam cover was successfully downloaded, `IsFallback` is `False` and `BdgLbl` becomes hidden. If `GenerateFallbackCover` was used, `IsFallback` is `True` and `BdgLbl` remains visible.

## Risks / Trade-offs

- **[Risk]** Asynchronous UI thread synchronization mismatch if card panels are recreated during folder rescan.
  - **Mitigation**: Existing bounds and control checks in `DoUpdateImage` validate `FForm.FCardPanels` indices before applying updates.
