## Purpose

Ensures that Flatpak build workflows in CI and local helper scripts install and use the KDE 6.11 runtime and SDK matching the project manifest requirements.

## ADDED Requirements

### Requirement: CI Workflow Flatpak Runtime Version
The GitHub Actions workflow files (`appimage.yml`, `release.yml`, and `flatpak-release.yml`) SHALL install version `6.11` of `org.kde.Platform`, `org.kde.Sdk`, and `io.qt.qtwebengine.BaseApp` prior to executing `flatpak-builder`.

#### Scenario: Installing Flatpak runtimes in CI
- **WHEN** the Flatpak build job runs in GitHub Actions
- **THEN** `sudo flatpak install -y flathub org.kde.Platform//6.11 org.kde.Sdk//6.11` and `sudo flatpak install -y flathub io.qt.qtwebengine.BaseApp//6.11` are executed without error.

### Requirement: Local Build Script Runtime Version
The local Flatpak build helper script (`flatpak/build-flatpak.sh`) SHALL check and install version `6.11` of `org.kde.Platform`, `org.kde.Sdk`, and `io.qt.qtwebengine.BaseApp`.

#### Scenario: Running local flatpak build script
- **WHEN** a developer executes `flatpak/build-flatpak.sh`
- **THEN** the script verifies and provisions the `6.11` SDK and runtime dependencies.
