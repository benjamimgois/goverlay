# Capability Spec: OptiScaler Tab Software Status UI

## Specification

### Software Status Card Display for DLSS Enabler
- WHEN DLSS Enabler is active on the Stable channel:
  - The Software Status card SHALL display the OptiScaler stable version (`0.9.4`) on the OptiScaler version row.
  - The Software Status card SHALL display the installed Streamline SDK version (e.g. `2.12.0`) with an active green status indicator.
  - The Software Status card SHALL position version labels dynamically relative to component name labels to prevent text overlapping.
