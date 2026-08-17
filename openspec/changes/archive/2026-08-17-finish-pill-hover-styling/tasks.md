# Tasks: Finish Pill Highlight Hover Styling

## 1. Finish Pill Custom State-Aware Painting

- [x] 1.1 Update `TFloatingActionDock` in `floating_dock.pas` to replace `FFinishBtn` with custom state-aware painting and event handlers (`MouseEnter`, `MouseLeave`, `MouseDown`, `MouseUp`, `Click`)
- [x] 1.2 Implement normal (`#2078B4`), vibrant hover (`#2B94DC`), and pressed (`#185F9B`) states in `PillPaint` and `FinishPaint`, keeping white text and smooth pill curvature
- [x] 1.3 Verify solo Finish pill mode and multi-button dock mode render seamlessly across all hover states

## 2. Testing and Validation

- [x] 2.1 Add automated GUI test case in `tests/gui/gui_test_cases.pas` verifying Finish button hover and press state transitions and click propagation
- [x] 2.2 Run full test suite (`make test` and `make test-logic`) and verify clean release build
