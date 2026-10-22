# Tasks

## 1. Dialog Structure & Layout

- [x] 1.1 Update `TChangelogForm` dimensions to fixed 680x520 and adjust header panel bounds in `changelogunit.pas`. Verify dialog initializes to 680x520 without layout clipping.
- [x] 1.2 Replace `TMemo` with a styled `TScrollBox` configured with auto-scroll and Goverlay modern scrollbar styling in `changelogunit.pas`. Verify scrolling container initializes cleanly.

## 2. Block Parser & Text Formatting

- [x] 2.1 Implement changelog text parsing to recognize headers (`###`, `##`), list items (`- `, `* `), image tags (`<img ... src="..." />`, `![...](...)`), and regular paragraphs.
- [x] 2.2 Implement dynamic creation of formatted `TLabel` elements for headers (accent/bold typography) and bullet list items (bullet dot `•` with automatic word wrapping). Verify text sections render with proper hierarchy and margins.

## 3. Asynchronous Image Loader & Caching

- [x] 3.1 Implement local disk cache directory (`~/.cache/goverlay/changelog/`) and asynchronous download thread using `curl`. Verify images are stored with hashed/sanitized filenames.
- [x] 3.2 Implement image container with placeholder, loading the cached/downloaded image into a `TImage` scaled proportionally to fit the viewport width, and updating vertical scrollbox layout. Verify remote images render properly without blocking the main UI thread.

## 4. Verification & Polish

- [x] 4.1 Compile the project with `lazbuild goverlay.lpi` and verify there are no compilation errors or warnings.
- [x] 4.2 Test the changelog dialog with sample release notes containing headers, bullet points, and images to verify visual appeal and responsiveness.
