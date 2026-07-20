## 1. Add loading flag and silent save support

- [x] 1.1 Declare `FOsDriverLoading: Boolean;` private field in `Tgoverlayform` (overlayunit.pas)
- [x] 1.2 Wrap GPU driver startup load block in `FormCreate` (overlayunit.pas) with `FOsDriverLoading := True` / `False`
- [x] 1.3 Update `SaveOptiScalerConfig` definition and implementation to support `ASilent: Boolean = False` parameter (overlayunit.pas, optiscaler_tab.pas)
- [x] 1.4 Bypass notifications and command panel updates in `SaveOptiScalerConfig` helper if `ASilent` is True (optiscaler_tab.pas)

## 2. Implement silent saves on driver toggle

- [x] 2.1 Wrap `SaveOptiScalerConfig` call in `mesaRadioButtonChange` (overlayunit.pas) with `if not FOsDriverLoading then SaveOptiScalerConfig(True);`
- [x] 2.2 Wrap `SaveOptiScalerConfig` call in `nvidiaRadioButtonChange` (overlayunit.pas) with `if not FOsDriverLoading then SaveOptiScalerConfig(True);`

## 3. Verification

- [x] 3.1 Verify compile builds clean with `make`
