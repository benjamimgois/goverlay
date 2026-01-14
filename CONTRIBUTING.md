# Contributing to GOverlay

Thank you for your interest in contributing to **GOverlay**! 🎉

This document provides guidelines for contributing to the project. Following these guidelines helps maintain code quality and makes the review process smoother for everyone.

---

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Setting Up Development Environment](#setting-up-development-environment)
- [How to Contribute](#how-to-contribute)
  - [Reporting Bugs](#reporting-bugs)
  - [Suggesting Features](#suggesting-features)
  - [Submitting Pull Requests](#submitting-pull-requests)
- [Development Guidelines](#development-guidelines)
  - [Code Style](#code-style)
  - [Commit Messages](#commit-messages)
  - [Testing](#testing)
- [Project Structure](#project-structure)
- [Building and Running](#building-and-running)
- [License](#license)

---

## Code of Conduct

Be respectful and considerate of others. This is a community project, and we value contributions from everyone. Harassment, discrimination, or any form of abusive behavior will not be tolerated.

---

## Getting Started

### Prerequisites

Before you start contributing, ensure you have the following tools installed:

#### Required Tools

- **[Lazarus IDE](https://www.lazarus-ide.org/)** - Free Pascal IDE
- **[Free Pascal Compiler (FPC)](https://www.freepascal.org/)** - Pascal compiler
- **[Git](https://git-scm.com/)** - Version control
- **[qt6pas](https://gitlab.com/freepascal.org/lazarus/lazarus/-/tree/main/lcl/interfaces/qt6/cbindings)** - Qt6 bindings for Lazarus

#### Runtime Dependencies

- **[MangoHud](https://github.com/flightlessmango/MangoHud)** - Performance overlay
- **[vkBasalt](https://github.com/DadSchoorse/vkBasalt)** - Post-processing effects
- **[mesa-demos](https://gitlab.freedesktop.org/mesa/demos)** - OpenGL demo tools
- **[vulkan-tools](https://github.com/LunarG/VulkanTools)** - Vulkan utilities

### Setting Up Development Environment

1. **Fork and clone the repository:**
   ```bash
   git clone https://github.com/YOUR_USERNAME/goverlay.git
   cd goverlay
   ```

2. **Open the project in Lazarus IDE:**
   ```bash
   lazarus-ide goverlay.lpi
   ```
   
   Or simply open `goverlay.lpi` from the IDE.

3. **Build the project:**
   ```bash
   make
   ```

4. **Run the application:**
   ```bash
   ./start_goverlay.sh
   ```

---

## How to Contribute

### Reporting Bugs

If you find a bug, please create an issue on [GitHub Issues](https://github.com/benjamimgois/goverlay/issues) with the following information:

- **Clear title** describing the issue
- **Description** of what happened vs. what you expected
- **Steps to reproduce** the bug
- **Environment details:**
  - GOverlay version
  - Distribution and version
  - Installation method (Flatpak, native, AppImage, etc.)
  - MangoHud/vkBasalt/OptiScaler versions
- **Logs or screenshots** if applicable

**Example:**
```markdown
### Bug: vkBasalt toggle key not saving

**Expected:** Selected toggle key should be saved to config
**Actual:** Always saves "Home" regardless of selection

**Steps to Reproduce:**
1. Open GOverlay
2. Go to vkBasalt tab
3. Select "F1" from toggle key dropdown
4. Click Save
5. Check vkBasalt config - shows "Home"

**Environment:**
- GOverlay 1.7.0 (Flatpak)
- Arch Linux
- vkBasalt 0.3.2
```

### Suggesting Features

Feature requests are welcome! Please create an issue with:

- **Clear description** of the feature
- **Use case** - why is this useful?
- **Proposed implementation** (optional)
- **Mockups or examples** (if applicable)

### Submitting Pull Requests

1. **Create a new branch** for your changes:
   ```bash
   git checkout -b feature/your-feature-name
   ```
   or
   ```bash
   git checkout -b fix/bug-description
   ```

2. **Make your changes** following the [Development Guidelines](#development-guidelines)

3. **Test your changes** thoroughly:
   - Build and run the application
   - Test affected functionality
   - Run validation tests: `make tests`

4. **Commit your changes** with clear, descriptive messages

5. **Push to your fork:**
   ```bash
   git push origin feature/your-feature-name
   ```

6. **Open a Pull Request** on GitHub with:
   - Clear title describing the change
   - Description of what was changed and why
   - Reference to related issues (e.g., "Fixes #123")
   - Screenshots/recordings for UI changes
   - Testing performed

---

## Development Guidelines

### Code Style

GOverlay is written in **Object Pascal** using the **Lazarus IDE**. Follow these guidelines:

#### General Rules

- Use **meaningful variable and function names**
- Keep functions focused and concise (single responsibility)
- Add **comments** for complex logic
- Use **consistent indentation** (2 spaces recommended)
- Place opening braces on the same line (K&R style)

#### Naming Conventions

- **Units/Files:** `lowercase` or `descriptivename.pas`
- **Classes:** `TPascalCase` (e.g., `TThemeManager`)
- **Functions/Procedures:** `PascalCase` (e.g., `SaveConfiguration`)
- **Variables:** `camelCase` (e.g., `configPath`, `isEnabled`)
- **Constants:** `UPPER_CASE` or `PascalCase` (e.g., `MAX_SIZE`, `DefaultPath`)
- **UI Components:** descriptive names with type suffix (e.g., `saveButton`, `configEdit`, `mangoCheckbox`)

#### Example Code

```pascal
procedure TSomeUnit.LoadConfiguration;
var
  configFile: TStringList;
  configPath: string;
  i: Integer;
begin
  configPath := GetConfigPath;
  
  if not FileExists(configPath) then
  begin
    ShowMessage('Configuration file not found');
    Exit;
  end;

  configFile := TStringList.Create;
  try
    configFile.LoadFromFile(configPath);
    
    for i := 0 to configFile.Count - 1 do
    begin
      // Process configuration lines
      ProcessConfigLine(configFile[i]);
    end;
  finally
    configFile.Free;
  end;
end;
```

### Commit Messages

Write clear, descriptive commit messages following this format:

```
<type>: <short description>

<optional longer description>

<optional footer with issue references>
```

#### Types:
- `feat:` - New feature
- `fix:` - Bug fix
- `refactor:` - Code refactoring (no functional change)
- `docs:` - Documentation changes
- `style:` - Code style/formatting changes
- `test:` - Adding or updating tests
- `chore:` - Build process, dependencies, etc.

#### Examples:

```bash
feat: add display_server option to MangoHud config

Added checkbox to enable/disable display_server in MangoHud configuration.
This allows users to show the current display server in the overlay.

Fixes #245
```

```bash
fix: vkBasalt toggle key always saving as Home

Fixed bug where selected toggle key from dropdown was not being saved.
Now correctly writes the selected key (F1-F4, Home) to vkBasalt config.

Fixes #312
```

### Testing

Before submitting a PR, ensure:

1. **The project compiles without errors:**
   ```bash
   make clean
   make
   ```

2. **Run validation tests:**
   ```bash
   make tests
   ```
   This validates the `.desktop` and `.metainfo.xml` files.

3. **Manual testing:**
   - Test the specific feature/fix you implemented
   - Test on both native and Flatpak environments (if applicable)
   - Verify UI changes work correctly with both light and dark themes
   - Check that configuration files are saved and loaded correctly

4. **Test different scenarios:**
   - Fresh install (no existing config)
   - Existing config (ensure backwards compatibility)
   - Edge cases (empty values, invalid inputs, etc.)

---

## Project Structure

```
goverlay/
├── data/                     # Application data files
│   ├── icons/               # Application icons
│   ├── fgmod/               # FGMOD scripts and resources
│   ├── *.desktop            # Desktop entry file
│   └── *.metainfo.xml       # AppStream metadata
├── *.pas                    # Pascal source files
│   ├── overlayunit.pas      # Main MangoHud/vkBasalt/OptiScaler UI
│   ├── themeunit.pas        # Theme management
│   ├── optiscaler_update.pas # OptiScaler update logic
│   ├── configmanager.pas    # Configuration handling
│   ├── systemdetector.pas   # System detection utilities
│   └── ...                  # Other units
├── *.lfm                    # Lazarus form files (UI layouts)
├── goverlay.lpi             # Lazarus project file
├── goverlay.lpr             # Main program file
├── Makefile                 # Build configuration
├── README.md                # Project documentation
├── LICENSE                  # GPL-3.0 license
└── CONTRIBUTING.md          # This file
```

### Key Files

- **`overlayunit.pas`** - Main application logic and UI
- **`themeunit.pas`** - Dark/light theme management
- **`configmanager.pas`** - Configuration file handling
- **`optiscaler_update.pas`** - OptiScaler download and update logic
- **`fgmod_resources.pas`** - Embedded FGMOD scripts
- **`Makefile`** - Build automation

---

## Building and Running

### Standard Build

```bash
# Build the project
make

# Run locally
./start_goverlay.sh

# Install system-wide
sudo make install

# Uninstall
sudo make uninstall
```

### Flatpak Build

```bash
# Build Flatpak locally
./build-flatpak.sh

# Install the local build
flatpak install --user flatpak-repo io.github.benjamimgois.goverlay
```

### Clean Build

```bash
# Clean build artifacts
make clean
```

---

## Additional Resources

- **MangoHud Documentation:** https://github.com/flightlessmango/MangoHud
- **vkBasalt Documentation:** https://github.com/DadSchoorse/vkBasalt
- **OptiScaler Documentation:** https://github.com/optiscaler/OptiScaler
- **Lazarus Documentation:** https://wiki.freepascal.org/Lazarus_Documentation
- **Free Pascal Documentation:** https://www.freepascal.org/docs.html

---

## License

By contributing to GOverlay, you agree that your contributions will be licensed under the **GNU General Public License v3.0**.

See [LICENSE](LICENSE) for the full license text.

---

## Questions?

If you have questions about contributing, feel free to:

- Open a [Discussion](https://github.com/benjamimgois/goverlay/discussions)
- Ask in an [Issue](https://github.com/benjamimgois/goverlay/issues)
- Reach out to the maintainer: [@benjamimgois](https://github.com/benjamimgois)

---

**Thank you for contributing to GOverlay!** Your efforts help make Linux gaming better for everyone. 🚀
