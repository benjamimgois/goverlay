## 1. CPU Name Detection Fallback

- [x] 1.1 Update TPasCubeScreen.GetCPUName in UnitPasCubeScreen.pas to include fallbacks for "processor" in cpuinfo and "model name" in lscpu.

## 2. Mali Bifrost v7 Driver Loading Override

- [x] 2.1 Set PAN_I_WANT_A_BROKEN_VULKAN_DRIVER=1 at startup in pascube.lpr.

## 3. Verification

- [x] 3.1 Verify that both GOverlay and PasCube compile successfully.
