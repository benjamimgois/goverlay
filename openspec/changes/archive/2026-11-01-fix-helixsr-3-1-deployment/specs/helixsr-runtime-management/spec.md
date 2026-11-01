# Spec Delta

## MODIFIED Requirements

### Requirement: HelixSR Game Profile Synchronization and Deployment
The system SHALL synchronize HelixSR runtime files into active game profiles according to the selected mode. In standard mode, the system SHALL deploy the specialized HelixSR Scaler OptiScaler build (`helixsr-scaler/OptiScaler.dll`) along with its companion `OptiScaler/` directory, proxy DLL, and `HelixSR/` containing `helixsr.dll` and `helixsr_upscaler.dll` into the game directory. In experimental Native DLSS mode, the system SHALL deploy the DLSS loader, `nvngx.dll`, and `helixsr-fg` directly without OptiScaler while displaying a single-player safety notice.

#### Scenario: Standard HelixSR deployment
- **WHEN** the game profile has HelixSR active with Native DLSS disabled
- **THEN** the system SHALL write `UPSCALER_TYPE=3` to `bgmod.conf`
- **AND** deploy `helixsr-scaler/OptiScaler.dll` as the proxy DLL and `OptiScaler.dll`, copy `helixsr-scaler/OptiScaler/` directory into the game's `OptiScaler/` directory, and deploy `HelixSR/` containing `helixsr.dll`, `helixsr_upscaler.dll`, and `helixsr.ini` into the game directory.

#### Scenario: Experimental Native DLSS deployment
- **WHEN** the game profile has HelixSR active with Native DLSS enabled
- **THEN** the system SHALL write `UPSCALER_TYPE=3` and `HELIXSR_NATIVE_DLSS=1` to `bgmod.conf`
- **AND** deploy `dlss-loader/dxgi.dll`, `nvngx.dll` (from `HelixSR/helixsr.dll` or `HelixSR-fsrfg/amd_fidelityfx_dx12.dll`), and `helixsr-fg/` into the game directory
- **AND** display an advisory notice warning against online multiplayer use with anti-cheat.
