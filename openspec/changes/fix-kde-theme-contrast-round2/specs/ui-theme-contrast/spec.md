## ADDED Requirements

### Requirement: Icon buttons keep legible text after runtime caption or icon changes
The system SHALL keep the label of every button that displays an icon (such as "Frames / Joule", "Joules / Frame", "Percent", "Graph") legible against its background in the active GOverlay theme, at first display and after the user toggles the button or a configuration is loaded, regardless of the desktop palette.

#### Scenario: Metrics efficiency button on Kubuntu theme
- **WHEN** the user opens the Metrics tab on the official Kubuntu (Breeze) theme
- **THEN** the "Frames / Joule" buttons and the "Percent" button show clearly readable text with high contrast against the card

#### Scenario: Button toggled by the user
- **WHEN** the user clicks the efficiency or core-load-type button so its caption and icon change
- **THEN** the new label remains equally legible

### Requirement: Lossless Scaling status buttons contrast
The system SHALL render the action buttons of the Frame Interpolation "Software Status" card (browse, check updates, install MAKO / install update, lsfg-vk Assistant, lsfg-vk install, AFMF install) with legible text in both enabled and disabled states, and enabled buttons SHALL NOT look disabled.

#### Scenario: Status card on Kubuntu theme
- **WHEN** the user views the Upscalers → Frame Interpolation tab on the official Kubuntu theme
- **THEN** "Install MAKO" / "Install update" and "lsfg-vk Assistant" display readable text with the same prominence as other enabled buttons

#### Scenario: Theme switch
- **WHEN** the user switches between dark and light GOverlay themes
- **THEN** these buttons update their text and background colors consistently

### Requirement: About dialog tab bar contrast
The system SHALL style the tab bar of the About dialog so tab captions are readable in both selected and unselected states under the active GOverlay theme, independent of the desktop palette.

#### Scenario: About dialog on Kubuntu theme
- **WHEN** the user opens the About dialog on the official Kubuntu theme
- **THEN** both the "About" and "License" tabs show readable captions, and the selected tab is visually distinguishable from the other

#### Scenario: About dialog in light GOverlay theme
- **WHEN** the user opens the About dialog with the light GOverlay theme
- **THEN** the tab captions and tab backgrounds have sufficient contrast
