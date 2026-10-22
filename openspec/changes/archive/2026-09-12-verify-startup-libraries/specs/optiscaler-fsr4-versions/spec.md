## MODIFIED Requirements

### Requirement: Centralized FSR4 Directory and Download of Alternative Builds
The system SHALL maintain a centralized `FSR4/` directory under GOverlay's data directory containing subdirectories for `Latest`, `4.1.1b`, and `4.0.2c`, downloading alternative INT8 versions during OptiScaler download, update, or startup integrity self-healing.

#### Scenario: Alternative builds downloaded during setup
- **WHEN** OptiScaler is downloaded, installed, or updated
- **THEN** the system ensures `~/.local/share/goverlay/FSR4/` exists and downloads the 4.1.1b and 4.0.2c DLLs into their respective subfolders if not already cached.

#### Scenario: Alternative builds verified and restored at startup
- **WHEN** GOverlay starts up and any FSR4 subfolder (`Latest`, `4.1.1b`, `4.0.2c`) is missing its required `amd_fidelityfx_upscaler_dx12.dll`
- **THEN** the system automatically triggers a targeted download or copy into the respective subfolder.
