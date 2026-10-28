# Design: Remove Legacy Hardware Icons from Metrics Card Headers

## Details
1. `gpuImage.Visible := False;` and `cpuImage.Visible := False;` in `InitMetricsTab` and `ReflowMetricsTab`.
2. Omit positioning of `gpuImage` and `cpuImage` in `ReflowMetricsTab`.
3. Add `FStorageLabel.ShowAccelChar := False;` in `InitMetricsTab`.
