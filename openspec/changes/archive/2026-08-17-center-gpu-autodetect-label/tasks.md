# Tasks: Center GPU Driver Auto Detect Label and Slightly Reduce Font Size

## 1. UI Layout & Typography Implementation

- [x] 1.1 In `optiscaler_tab.pas` `InitOptiScalerTab`, set `autodetectmesaLabel.Font.Size := 8` and `autodetectnvLabel.Font.Size := 8`
- [x] 1.2 In `optiscaler_tab.pas` `ReflowOptiScalerTabNew`, calculate horizontal centering of `autodetectmesaLabel` relative to `mesaImage` and `autodetectnvLabel` relative to `nvidiaImage`

## 2. Testing and Validation

- [x] 2.1 Run unit and GUI tests (`make test` and `make test-logic`) and verify clean release build
