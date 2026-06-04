# PasTerm Terminal Emulator

PasTerm is a comprehensive terminal emulator class designed for both **Delphi** and **FreePascal** environments. It handles various terminal functionalities, including input encoding, cursor management, scrolling, and more. This readme provides guidance for new users on integrating and utilizing PasTerm within their applications.

This guide contains examples for Delphi VCL and Lazarus LCL. However, it is also possible to use SDL, OpenGL, Vulkan, Metal, and similar graphics APIs where framebuffer textures can be utilized. This flexibility allows PasTerm to integrate seamlessly with various drawing backends, as it does not include its own drawing functions but relies on user-defined drawing backends.

But take note, PasTerm handles only the terminal output, not the input.  At the end in this document, an example template for input handling is provided, which users must adjust to fit their specific application needs.

## Table of Contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
  - [Setting Up the User Interface](#setting-up-the-user-interface)
  - [Implementing Event Handlers](#implementing-event-handlers)
  - [Example Implementation](#example-implementation)
    - [Delphi VCL Example](#delphi-vcl-example)
    - [FreePascal + Lazarus LCL Example](#freepascal--lazarus-lcl-example)
  - [Additional Considerations](#additional-considerations)
- [Additional Features](#additional-features)
- [License](#license)
- [Input Handling Example](#input-handling-example)

## Requirements

- **Delphi Users:**
  - **Delphi IDE**: Ensure the latest stable version of Delphi is installed.
  
- **FreePascal + Lazarus Users:**
  - **FreePascal Compiler**: Ensure the latest stable version of FreePascal is installed.
  - **Lazarus IDE**: The Lazarus Integrated Development Environment is required for GUI development.

- **PasTerm Unit**: Include the `PasTerm` unit in the project. Ensure the unit name matches the location where PasTerm is defined.

## Installation

1. **Download PasTerm**: Obtain the `PasTerm` unit source file and place it within the project's directory or a designated library path.

2. **Add to Project**:
   - **Delphi**: Include the `PasTerm` unit in the project's `uses` clause.
   - **FreePascal + Lazarus**: Include the `PasTerm` unit in the project's `uses` clause.

## Usage

### Setting Up the User Interface

1. **Create a New Project**:
   - **Delphi**: Create a new VCL Forms Application.
   - **FreePascal + Lazarus**: Create a new Lazarus GUI application.

2. **Add a `TImage` Component**:
   - Place a `TImage` component onto the main form. This component serves as the drawing surface for the terminal emulator.
   - Set the `Align` property of the `TImage` to `alClient` (Delphi) or `alClient` (Lazarus) to make it occupy the entire form area.

### Implementing Event Handlers

TPasTerm relies on specific event handlers to render the terminal's framebuffer. These handlers should be implemented to draw the terminal's content onto the `TImage` component using a `TCanvas`. The essential event handlers include:

- `OnDrawBackground`
- `OnDrawCodePoint`
- `OnDrawCursor`

> **Note:** `OnDrawCodePointMasked` is optional and can be set to `nil` if not needed. It is primarily used for performance optimization by handling partial updates to the framebuffer.

### Example Implementation

Below is an example of integrating PasTerm within both Delphi VCL and FreePascal + Lazarus LCL applications using the `TImage` component for rendering.

#### Delphi VCL Example

```delphi
unit TerminalForm;

interface

uses
  System.Classes, Vcl.Controls, Vcl.Forms, Vcl.ExtCtrls, System.Types,
  PasTerm;

type
  TForm1 = class(TForm)
    Image1: TImage;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    Term: TPasTerm;
    CellWidth: Integer;
    CellHeight: Integer;
    FontName: string;
    procedure DrawBackground(Sender: TPasTerm);
    procedure DrawCodePoint(Sender: TPasTerm; const aCodePoint: TPasTerm.TFrameBufferCodePoint; const aColumn, aRow: Integer);
    procedure DrawCursor(Sender: TPasTerm; const aColumn, aRow: Integer);
    procedure UpdateImage;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses
  Vcl.Graphics, Vcl.Dialogs, System.SysUtils;

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
  // Initialize cell dimensions and font
  CellWidth := 8;  // Adjust based on desired character width
  CellHeight := 16; // Adjust based on desired character height
  FontName := 'Consolas'; // Use a monospaced font

  // Initialize the terminal emulator
  Term := TPasTerm.Create(80, 25); // 80 columns x 25 rows
  Term.OnDrawBackground := DrawBackground;
  Term.OnDrawCodePoint := DrawCodePoint;
  Term.OnDrawCursor := DrawCursor;
  // OnDrawCodePointMasked is optional and left unassigned for simplicity

  // Initialize the image bitmap
  Image1.Picture.Bitmap.PixelFormat := pf32bit;
  Image1.Picture.Bitmap.SetSize(Term.Columns * CellWidth, Term.Rows * CellHeight);

  // Example: Write some text to the terminal
  Term.Write('Hello, TPasTerm Terminal Emulator!'#13#10);
  Term.Write('This is a sample text.');
  Term.Flush;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  Term.Free;
end;

// Event handler to draw the background
procedure TForm1.DrawBackground(Sender: TPasTerm);
begin
  with Image1.Picture.Bitmap.Canvas do
  begin
    Brush.Color := clBlack;
    FillRect(Rect(0, 0, Image1.Picture.Bitmap.Width, Image1.Picture.Bitmap.Height));
  end;
end;

// Event handler to draw a code point (character)
procedure TForm1.DrawCodePoint(Sender: TPasTerm; const aCodePoint: TPasTerm.TFrameBufferCodePoint; const aColumn, aRow: Integer);
var
  Rect: TRect;
  CharStr: string;
  Color: TColor;
begin
  // Define the rectangle area for the character
  Rect := Rect(aColumn * CellWidth, aRow * CellHeight, (aColumn + 1) * CellWidth, (aRow + 1) * CellHeight);

  // Convert Unicode code point to string
  CharStr := Char(aCodePoint.CodePoint);

  // Set text color
  Color := aCodePoint.ForegroundColor;
  Image1.Picture.Bitmap.Canvas.Font.Color := Color;

  // Set font
  Image1.Picture.Bitmap.Canvas.Font.Name := FontName;
  Image1.Picture.Bitmap.Canvas.Font.Size := 10; // Adjust based on CellHeight

  // Draw the character
  Image1.Picture.Bitmap.Canvas.TextOut(Rect.Left, Rect.Top, CharStr);
end;

// Event handler to draw the cursor
procedure TForm1.DrawCursor(Sender: TPasTerm; const aColumn, aRow: Integer);
var
  Rect: TRect;
begin
  // Define the rectangle area for the cursor
  Rect := Rect(aColumn * CellWidth, aRow * CellHeight, (aColumn + 1) * CellWidth, (aRow + 1) * CellHeight);

  with Image1.Picture.Bitmap.Canvas do
  begin
    Brush.Color := clWhite;
    FillRect(Rect);
  end;
end;

// Optional: Update the entire image (e.g., on resize)
procedure TForm1.UpdateImage;
begin
  Image1.Picture.Bitmap.SetSize(Term.Columns * CellWidth, Term.Rows * CellHeight);
  Term.Clear(true);
  Term.Flush;
end;

end.
```

#### FreePascal + Lazarus LCL Example

```pascal
unit TerminalForm;

interface

uses
  Classes, Controls, Forms, ExtCtrls, Graphics, SysUtils, PasTerm;

type
  TForm1 = class(TForm)
    Image1: TImage;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    Term: TPasTerm;
    CellWidth: Integer;
    CellHeight: Integer;
    FontName: string;
    procedure DrawBackground(Sender: TPasTerm);
    procedure DrawCodePoint(Sender: TPasTerm; const aCodePoint: TPasTerm.TFrameBufferCodePoint; const aColumn, aRow: Integer);
    procedure DrawCursor(Sender: TPasTerm; const aColumn, aRow: Integer);
    procedure UpdateImage;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
  // Initialize cell dimensions and font
  CellWidth := 8;   // Adjust based on desired character width
  CellHeight := 16; // Adjust based on desired character height
  FontName := 'Consolas'; // Use a monospaced font

  // Initialize the terminal emulator
  Term := TPasTerm.Create(80, 25); // 80 columns x 25 rows
  Term.OnDrawBackground := @DrawBackground;
  Term.OnDrawCodePoint := @DrawCodePoint;
  Term.OnDrawCursor := @DrawCursor;
  // OnDrawCodePointMasked is optional and left unassigned for simplicity

  // Initialize the image bitmap
  Image1.Picture.Bitmap.PixelFormat := pf32bit;
  Image1.Picture.Bitmap.SetSize(Term.Columns * CellWidth, Term.Rows * CellHeight);

  // Example: Write some text to the terminal
  Term.Write('Hello, TPasTerm Terminal Emulator!'#13#10);
  Term.Write('This is a sample text.');
  Term.Flush;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  Term.Free;
end;

// Event handler to draw the background
procedure TForm1.DrawBackground(Sender: TPasTerm);
begin
  with Image1.Picture.Bitmap.Canvas do
  begin
    Brush.Color := clBlack;
    FillRect(Rect(0, 0, Image1.Picture.Bitmap.Width, Image1.Picture.Bitmap.Height));
  end;
end;

// Event handler to draw a code point (character)
procedure TForm1.DrawCodePoint(Sender: TPasTerm; const aCodePoint: TPasTerm.TFrameBufferCodePoint; const aColumn, aRow: Integer);
var
  RectArea: TRect;
  CharStr: string;
  Color: TColor;
begin
  // Define the rectangle area for the character
  RectArea := Rect(aColumn * CellWidth, aRow * CellHeight, (aColumn + 1) * CellWidth, (aRow + 1) * CellHeight);

  // Convert Unicode code point to string
  CharStr := Char(aCodePoint.CodePoint);

  // Set text color
  Color := aCodePoint.ForegroundColor;
  Image1.Picture.Bitmap.Canvas.Font.Color := Color;

  // Set font
  Image1.Picture.Bitmap.Canvas.Font.Name := FontName;
  Image1.Picture.Bitmap.Canvas.Font.Size := 10; // Adjust based on CellHeight

  // Draw the character
  Image1.Picture.Bitmap.Canvas.TextOut(RectArea.Left, RectArea.Top, CharStr);
end;

// Event handler to draw the cursor
procedure TForm1.DrawCursor(Sender: TPasTerm; const aColumn, aRow: Integer);
var
  RectArea: TRect;
begin
  // Define the rectangle area for the cursor
  RectArea := Rect(aColumn * CellWidth, aRow * CellHeight, (aColumn + 1) * CellWidth, (aRow + 1) * CellHeight);

  with Image1.Picture.Bitmap.Canvas do
  begin
    Brush.Color := clWhite;
    FillRect(RectArea);
  end;
end;

// Optional: Update the entire image (e.g., on resize)
procedure TForm1.UpdateImage;
begin
  Image1.Picture.Bitmap.SetSize(Term.Columns * CellWidth, Term.Rows * CellHeight);
  Term.Clear(true);
  Term.Flush;
end;

end.
```

### Additional Considerations

- **Font Metrics**: Ensure that `CellWidth` and `CellHeight` correspond to the actual size of the characters rendered by the chosen font. Adjust `Font.Size` and the cell dimensions as necessary to achieve the desired appearance.

- **Performance**: For large terminals or frequent updates, optimize the drawing routines. For example, redraw only the cells that have changed instead of the entire terminal to improve performance.

- **Unicode Support**: The `DrawCodePoint` handler assumes that the code points correspond to valid Unicode characters. Ensure proper handling of multi-byte characters if necessary to support a wide range of symbols and languages.

- **Event Synchronization**: If the application handles terminal input/output in separate threads, ensure that access to the `TImage` component is thread-safe. Utilize synchronization mechanisms such as `TThread.Synchronize` or `TThread.Queue` to manage concurrent access and prevent race conditions.

- **Cursor Visibility**: Implement cursor blinking by toggling its visibility at regular intervals using a `TTimer`. This enhances the user experience by providing a visual indication of the current cursor position.

## Additional Features

PasTerm offers various terminal functionalities that can be leveraged based on project requirements:

- **Input Handling**: Capture user inputs (keyboard events) and send them to the terminal emulator to allow interactive terminal sessions.

- **Scrollback Buffer**: Implement a scrollback buffer to enable users to view previous terminal outputs, enhancing the usability for logging and reviewing past commands or outputs.

- **Window Resizing**: Handle form or image resizing by adjusting the terminal's rows and columns accordingly. This ensures that the terminal adapts gracefully to different window sizes and resolutions.

- **Color Support**: Expand color handling to support 256 colors or true color as needed. This allows for more vibrant and detailed terminal displays, accommodating a wider range of applications and user preferences.

- **Cursor Blinking**: Implement cursor blinking by toggling its visibility at regular intervals using a timer. This provides a dynamic and intuitive indication of the cursor's position within the terminal.

## License

PasTerm is released under the zlib License.

## Input Handling Example

PasTerm handles only the terminal output. Below is an example template for input handling, which users must adjust to fit their specific application needs:

```pascal
function TScreenEmulator.KeyEvent(const aKeyEvent: TpvApplicationInputKeyEvent): boolean;
  procedure Send(const u: TpvRawByteString);
  var
    c: AnsiChar;
  begin
    if Length(u) > 0 then
    begin
      for c in u do
      begin
        fMachineInstance.fMachine.UARTDevice.InputQueue.Enqueue(c);
        fMachineInstance.fMachine.UARTDevice.Notify;
      end;
      fMachineInstance.fMachine.WakeUp;
    end;
  end;
var
  c: AnsiChar;
  u, m: TpvRawByteString;
  v: TPasTermUInt8;
begin
  Result := false;
  case aKeyEvent.KeyEventType of
    TpvApplicationInputKeyEventType.Typed:
    begin
      v := 0;
      if TpvApplicationInputKeyModifier.SHIFT in aKeyEvent.KeyModifiers then
        v := v or 1;
      if TpvApplicationInputKeyModifier.ALT in aKeyEvent.KeyModifiers then
        v := v or 2;
      if TpvApplicationInputKeyModifier.CTRL in aKeyEvent.KeyModifiers then
        v := v or 4;
      if TpvApplicationInputKeyModifier.META in aKeyEvent.KeyModifiers then
        v := v or 8;
      if v <> 0 then
        m := IntToStr(v + 1)
      else
        m := '';
      case aKeyEvent.KeyCode of
        KEYCODE_UP:
        begin
          if Length(m) > 0 then
          begin
            if m = '3' then
              m := '5';
            Send(#$1b'[1;' + m + 'A');
          end
          else if TpvApplicationInputKeyModifier.SHIFT in aKeyEvent.KeyModifiers then
            Send(#$1b'OA')
          else if TpvApplicationInputKeyModifier.CTRL in aKeyEvent.KeyModifiers then
            Send(#$1b'OA')
          else
            Send(#$1b'[A');
        end;
        KEYCODE_DOWN:
        begin
          if Length(m) > 0 then
          begin
            if m = '3' then
              m := '5';
            Send(#$1b'[1;' + m + 'B');
          end
          else if TpvApplicationInputKeyModifier.SHIFT in aKeyEvent.KeyModifiers then
            Send(#$1b'OB')
          else if TpvApplicationInputKeyModifier.CTRL in aKeyEvent.KeyModifiers then
            Send(#$1b'OB')
          else
            Send(#$1b'[B');
        end;
        KEYCODE_RIGHT:
        begin
          if Length(m) > 0 then
          begin
            if m = '3' then
              m := '5';
            Send(#$1b'[1;' + m + 'C');
          end
          else if TpvApplicationInputKeyModifier.SHIFT in aKeyEvent.KeyModifiers then
            Send(#$1b'OC')
          else if TpvApplicationInputKeyModifier.CTRL in aKeyEvent.KeyModifiers then
            Send(#$1b'OC')
          else
            Send(#$1b'[C');
        end;
        KEYCODE_LEFT:
        begin
          if Length(m) > 0 then
          begin
            if m = '3' then
              m := '5';
            Send(#$1b'[1;' + m + 'D');
          end
          else if TpvApplicationInputKeyModifier.SHIFT in aKeyEvent.KeyModifiers then
            Send(#$1b'OD')
          else if TpvApplicationInputKeyModifier.CTRL in aKeyEvent.KeyModifiers then
            Send(#$1b'OD')
          else
            Send(#$1b'[D');
        end;
        KEYCODE_HOME:
        begin
          if Length(m) > 0 then
            Send(#$1b'[1;' + m + '~')
          else
            Send(#$1b'[1~');
        end;
        KEYCODE_END:
        begin
          if Length(m) > 0 then
            Send(#$1b'[4;' + m + '~')
          else
            Send(#$1b'[4~');
        end;
        KEYCODE_PAGEDOWN:
        begin
          if Length(m) > 0 then
            Send(#$1b'[6;' + m + '~')
          else
            Send(#$1b'[6~');
        end;
        KEYCODE_PAGEUP:
        begin
          if Length(m) > 0 then
            Send(#$1b'[5;' + m + '~')
          else
            Send(#$1b'[5~');
        end;
        KEYCODE_F1:
        begin
          if Length(m) > 0 then
            Send(#$1b'[1;' + m + 'P')
          else
            Send(#$1b'[[A');
        end;
        KEYCODE_F2:
        begin
          if Length(m) > 0 then
            Send(#$1b'[1;' + m + 'Q')
          else
            Send(#$1b'[[B');
        end;
        KEYCODE_F3:
        begin
          if Length(m) > 0 then
            Send(#$1b'[1;' + m + 'R')
          else
            Send(#$1b'[[C');
        end;
        KEYCODE_F4:
        begin
          if Length(m) > 0 then
            Send(#$1b'[1;' + m + 'S')
          else
            Send(#$1b'[[D');
        end;
        KEYCODE_F5:
        begin
          if Length(m) > 0 then
            Send(#$1b'[15;' + m + '~')
          else
            Send(#$1b'[[E');
        end;
        KEYCODE_F6:
        begin
          if Length(m) > 0 then
            Send(#$1b'[17;' + m + '~')
          else
            Send(#$1b'[17~');
        end;
        KEYCODE_F7:
        begin
          if Length(m) > 0 then
            Send(#$1b'[18;' + m + '~')
          else
            Send(#$1b'[18~');
        end;
        KEYCODE_F8:
        begin
          if Length(m) > 0 then
            Send(#$1b'[19;' + m + '~')
          else
            Send(#$1b'[19~');
        end;
        KEYCODE_F9:
        begin
          if Length(m) > 0 then
            Send(#$1b'[20;' + m + '~')
          else
            Send(#$1b'[20~');
        end;
        KEYCODE_F10:
        begin
          if Length(m) > 0 then
            Send(#$1b'[21;' + m + '~')
          else
            Send(#$1b'[21~');
        end;
        KEYCODE_F11:
        begin
          if Length(m) > 0 then
            Send(#$1b'[23;' + m + '~')
          else
            Send(#$1b'[23~');
        end;
        KEYCODE_F12:
        begin
          if Length(m) > 0 then
            Send(#$1b'[24;' + m + '~')
          else
            Send(#$1b'[24~');
        end;
        KEYCODE_TAB:
        begin
          if TpvApplicationInputKeyModifier.SHIFT in aKeyEvent.KeyModifiers then
            Send(#$1b'[Z')
          else
            Send(#9);
        end;
        KEYCODE_BACKSPACE:
        begin
          if TpvApplicationInputKeyModifier.SHIFT in aKeyEvent.KeyModifiers then
            Send(#$7F)
          else if TpvApplicationInputKeyModifier.CTRL in aKeyEvent.KeyModifiers then
            Send(#$08)
          else
            Send(#$7F);
        end;
        KEYCODE_KP_ENTER,
        KEYCODE_RETURN:
        begin
          if TpvApplicationInputKeyModifier.ALT in aKeyEvent.KeyModifiers then
            Send(#$1B#10)
          else
            Send(#10);
        end;
        KEYCODE_ESCAPE:
        begin
          if TpvApplicationInputKeyModifier.ALT in aKeyEvent.KeyModifiers then
            Send(#$1B)
          else
            Send(#$1B#$1B);
        end;
        KEYCODE_DELETE:
        begin
          if Length(m) > 0 then
            Send(#$1B'[3;' + m + '~')
          else
            Send(#$1B'[3~');
        end;
        KEYCODE_INSERT:
        begin
          if Length(m) > 0 then
            Send(#$1B'[2;' + m + '~')
          else
            Send(#$1B'[2~');
        end;
        KEYCODE_A..KEYCODE_Z:
        begin
          if TpvApplicationInputKeyModifier.CTRL in aKeyEvent.KeyModifiers then
            Send(Chr((aKeyEvent.KeyCode - KEYCODE_A) + 1));
        end;
      end;
    end;
    TpvApplicationInputKeyEventType.Unicode:
    begin
      if (TpvApplicationInputKeyModifier.CTRL in aKeyEvent.KeyModifiers) and
         (((aKeyEvent.KeyCode >= Ord('a')) and (aKeyEvent.KeyCode <= Ord('z'))) or
          ((aKeyEvent.KeyCode >= Ord('A')) and (aKeyEvent.KeyCode <= Ord('Z'))) or
          (aKeyEvent.KeyCode = Ord('@'))) then
      begin
        // Example: Handle CTRL + Key combinations if needed
      end
      else
      begin
        Send(PUCUUTF32CharToUTF8(aKeyEvent.KeyCode));
      end;
    end;
  end;
  Result := true;
end;
```

**Explanation:**

- **Function `Send`**: This procedure takes a `TpvRawByteString` and enqueues each character into the terminal's input queue. It then notifies the UART device and wakes up the machine instance to process the input.

- **Handling Key Events**: The `KeyEvent` function processes different types of key events (`Typed`, `Unicode`, `Down`, `Up`) and sends appropriate escape sequences or characters to the terminal emulator based on the key pressed and any modifiers (Shift, Alt, Ctrl, Meta).

- **Adjusting the Template**: Users should modify this template to fit the specific needs of their application, ensuring that key mappings and escape sequences align with the desired terminal behavior.

> **Note:** This is a basic template and may require adjustments to handle all possible key events and combinations effectively within your application.
