## MODIFIED Requirements

### Requirement: Floating Action Dock Rendering and Positioning
The system SHALL display a floating action pill dock anchored at the bottom-right corner of the main content area, rendered with 100% transparent corners outside the pill shape, exact semicircular pill curvature without hard black drop shadows or dark corner cutouts, seamless container background blending matching the active interface theme, an integrated solid blue primary Finish action section occupying the right side of the dock, and state-aware custom-rendered secondary action buttons with illuminated hover and pressed styling.

#### Scenario: Displaying floating action dock
- **WHEN** GOverlay main window is displayed
- **THEN** the floating action dock SHALL be anchored at the bottom-right above tab content, rendering completely clean semicircular rounded ends without black drop shadow artifacts, dark bounding boxes, or chamfered corners.

#### Scenario: Hovering over Finish action button
- **WHEN** user hovers the mouse over the primary Finish action button
- **THEN** the button SHALL illuminate with a brighter, more vibrant blue/cyan fill while preserving white text contrast.

#### Scenario: Pressing Finish action button
- **WHEN** user presses the primary Finish action button
- **THEN** the button SHALL render an active deeper pressed state for immediate tactile feedback.

#### Scenario: Hovering over secondary action buttons
- **WHEN** user hovers the mouse over any secondary button (Menu, Preview, Add)
- **THEN** the button SHALL render a distinct elevated slate chip background with crisp white text.
