# Spec Delta

## Purpose

Provides an intuitive, interactive visual flow diagram representing the real-time state transitions of the vkNemu Idle Limiter on the Goverlay Performance tab.

## ADDED Requirements

### Requirement: Interactive Idle Limiter State Transition Diagram
The system SHALL display an interactive visual flow diagram representing the state progression of the Idle Limiter across active gameplay, idle standby, and game resumption.

#### Scenario: Displaying state progression diagram
- **WHEN** the user inspects the Idle Limiter (vkNemu) section on the Performance tab
- **THEN** the system SHALL render a behavior flow card showing the active game state, idle timeout transition, standby state, wake input condition, and resume delay

### Requirement: Real-Time Flow Parameter Reflection
The system SHALL update the displayed values within the state transition diagram in real time whenever the user modifies any Idle Limiter parameter.

#### Scenario: User adjusts idle timeout or target FPS
- **WHEN** the user changes the Idle FPS spin edit or Inactivity Timeout spin edit
- **THEN** the transition diagram SHALL immediately update its standby FPS and idle duration indicators to reflect the new values without requiring saving or reloading
