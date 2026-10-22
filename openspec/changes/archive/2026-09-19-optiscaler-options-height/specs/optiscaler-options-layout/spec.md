# Spec Delta: optiscaler-options-layout

## ADDED Requirements

### Requirement: OptiScaler Options Card Height Without Vertical Scrolling
The OptiScaler tab options card SHALL fit within standard application window dimensions without causing vertical scrolling on the tab scrollbox.

#### Scenario: Standard Window Height Layout
- **GIVEN** GOverlay is opened at its default window dimensions (client height ~648px)
- **WHEN** the user navigates to the OptiScaler tab
- **THEN** `FOsOptionsCard` height SHALL be less than 410px and at least 290px
- **AND** `FOsBgPanel` height SHALL NOT exceed `FOsScrollBox.ClientHeight`
- **AND** `FOsStatusCard` bottom SHALL fit completely within `FOsScrollBox.ClientHeight` without vertical scrollbar activation
