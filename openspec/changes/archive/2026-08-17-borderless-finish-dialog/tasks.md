## 1. Window Frame & Navigation Chrome

- [x] 1.1 Update `TFinishDialogForm` in `finish_dialog.pas` to use `BorderStyle := bsNone`, custom `OnPaint` border rendering, and a draggable header bar.
- [x] 1.2 Add top-right `✕` close button with hover feedback, and wire `Escape` key (`VK_ESCAPE`) handler to dismiss the dialog.
- [x] 1.3 Remove the redundant bottom "Done" button (`FCloseBtn`) and streamline dialog layout and dimensions.

## 2. High-Contrast Command Card & Styling

- [x] 2.1 Refactor `FCmdPanel` into a prominent terminal/code-styled card with a distinct dark background, accent border, and terminal prompt indicator (`❯_`).
- [x] 2.2 Modernize `FCopyBtn` with a prominent action button appearance and copy feedback (`Copied!`).
- [x] 2.3 Ensure dynamic accent colors and command text correctly adapt when switching between Steam and Heroic tabs.

## 3. Verification & Testing

- [x] 3.1 Build the application using `lazbuild` to verify clean compilation.
- [x] 3.2 Run the automated GUI and logic test suite to ensure all tests pass.
