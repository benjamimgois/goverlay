## 1. MangoHud Alpha Default Value

- [x] 1.1 Update `ResetMangoHudControls` in `mangohud_ui.pas` to set `transpTrackBar.Position := 6` and `alphavalueLabel.Caption := '0.6'`.

## 2. Verification & Testing

- [x] 2.1 Verify compilation with `lazbuild goverlay.lpi --bm=Release`.
- [x] 2.2 Run unit tests with `make test-logic`.
- [x] 2.3 Run full GUI test suite with `make test-gui`.
