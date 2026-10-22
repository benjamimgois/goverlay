# Tasks

## 1. Modelo de dados — TMangoHudSettings e TMangoHudUiHelper

- [x] 1.1 Adicionar campo `FpsOnly: Boolean` ao record `TMangoHudSettings` em
  `overlay_config.pas` logo após o campo `AutoUpload`. Verificar: o projeto
  compila sem erros (`lazbuild goverlay.lpi`).

- [x] 1.2 Adicionar campo privado `FFpsOnly: Boolean` à classe
  `TMangoHudUiHelper` em `mangohud_ui.pas` (seção `private`). Verificar:
  compila sem erros.

## 2. Ciclo de Load — reconhecer fps_only

- [x] 2.1 Em `ResetMangoHudControls` (`mangohud_ui.pas`), adicionar
  `FFpsOnly := False;` no início do bloco `try` (antes de resetar os
  checkboxes). Verificar: ao carregar qualquer config que não contenha
  `fps_only`, `FFpsOnly` permanece `False` após o load.

- [x] 2.2 Em `LoadMangoHudBoolFlag` (`mangohud_ui.pas`), adicionar handler para
  o token `fps_only`:
  ```pascal
  else if SameText(ATrimmedLine, 'fps_only') then
    FFpsOnly := True
  ```
  Verificar: ao carregar um arquivo contendo apenas `fps_only`, `FFpsOnly` é
  `True` após `LoadMangoHudConfig`.

## 3. Ciclo de Save — propagar e usar o flag

- [x] 3.1 Em `SaveMangoHudConfig` (`mangohud_ui.pas`), antes da chamada a
  `SaveMangoHudConfigCore`, adicionar `Settings.FpsOnly := FFpsOnly;`. Verificar:
  ao inspecionar em debug, `Settings.FpsOnly` reflete o valor correto de
  `FFpsOnly`.

- [x] 3.2 Em `SaveMangoHudConfigCore` (`overlay_config.pas`), adicionar branch
  no início da função (após declarar variáveis locais):
  ```pascal
  if Settings.FpsOnly then
  begin
    ConfigLines := TStringList.Create;
    try
      ConfigLines.Add('fps_only');
      ConfigLines.SaveToFile(Settings.MangoHudCfgFile);
      // mirror para ~/.config/MangoHud/MangoHud.conf (igual ao código existente)
      // mirror para Steam Flatpak (igual ao código existente)
    finally
      ConfigLines.Free;
    end;
    WriteLn('[DEBUG] SaveMangoHudConfigCore: fps_only preset written to ', Settings.MangoHudCfgFile);
    Result := True;
    Exit;
  end;
  ```
  Verificar: ao chamar `SaveMangoHudConfig` com `FFpsOnly=True`, o arquivo
  resultante contém apenas `fps_only` (verificar com `cat` no terminal).

## 4. Cancelamento — qualquer controle cancela fps_only

- [x] 4.1 Em `GenericControlChange` (`overlayunit.pas`), adicionar
  `TMangoHudUiHelper(FMangoHelper).SetFpsOnly(False);` antes da chamada a
  `StartAutoSaveTimer`. Criar método público `procedure SetFpsOnly(AValue: Boolean)`
  em `TMangoHudUiHelper` que simplesmente faz `FFpsOnly := AValue`. Verificar:
  ao ativar qualquer checkbox na aba MangoHud após selecionar fps_only, o
  próximo save gera config completa (verificar com `cat` no arquivo).

- [x] 4.2 Fazer o mesmo em `GenericControlClick` (`overlayunit.pas`) para
  radiobuttons e outros controles wired via OnClick. Verificar: mudar posição
  do HUD ou qualquer radiobutton também cancela fps_only.

## 5. Refatorar fpsonlyBitBtnClick

- [x] 5.1 Substituir o write direto em `fpsonlyBitBtnClick` (`overlayunit.pas`)
  pelo novo fluxo:
  ```pascal
  FLoadingConfig := True;
  try
    SetAllCheckBoxesToFalse;
    TMangoHudUiHelper(FMangoHelper).SetFpsOnly(True);
  finally
    FLoadingConfig := False;
  end;
  SaveMangoHudConfig;
  ShowSavedStatus;
  ```
  Verificar: ao clicar no preset "FPS Only", o arquivo
  `~/.local/share/goverlay/gameconfig/global/MangoHud.conf` contém apenas
  `fps_only` e o mesmo vale para `~/.config/MangoHud/MangoHud.conf`.

## 6. Verificação de integração — round-trip completo

- [x] 6.1 Teste manual do ciclo completo:
  1. Abrir GOverlay → aba MangoHud → clicar "FPS Only" → fechar GOverlay.
  2. `cat ~/.local/share/goverlay/gameconfig/global/MangoHud.conf` → deve
     conter apenas `fps_only`.
  3. Reabrir GOverlay → aguardar inicialização completa → fechar sem interagir.
  4. `cat ~/.local/share/goverlay/gameconfig/global/MangoHud.conf` → deve
     ainda conter apenas `fps_only`.
  Verificar: o arquivo persiste corretamente entre as sessões.

- [x] 6.2 Compilar com `lazbuild goverlay.lpi` e confirmar zero erros e zero
  warnings novos relacionados ao código alterado.
