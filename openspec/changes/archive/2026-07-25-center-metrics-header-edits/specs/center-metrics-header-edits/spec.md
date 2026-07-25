## ADDED Requirements

### Requirement: Metrics Tab Header Edits Centering
The MangoHud UI helper SHALL dynamically calculate and center the horizontal positions (`Left`) of `gpunameEdit`, `gpuColorButton`, `cpunameEdit`, and `cpuColorButton` within their respective cards (`FMtGpuCard`, `FMtCpuCard`) during `ReflowMetricsTab`.

#### Scenario: Window reflow centers header edits
- **WHEN** `ReflowMetricsTab` is executed during window resize or reflow
- **THEN** `gpunameEdit.Left` and `cpunameEdit.Left` are set to `(CW - Edit.Width) div 2`
- **THEN** `gpuColorButton.Left` and `cpuColorButton.Left` are set to `(CW - ColorButton.Width) div 2`
