# Proposal

## Why

O preset "FPS Only" do MangoHud é salvo como o token especial `fps_only` no
arquivo de configuração, mas ao recarregar o GOverlay esse token não é
reconhecido pelo parser da UI — resultando em um estado vazio que, ao ser
salvo, sobrescreve o `fps_only` com uma config completa padrão. Isso faz com
que a preferência do usuário seja silenciosamente descartada a cada
reinicialização do GOverlay (bug reportado em #405).

## What Changes

- Adicionar campo `FpsOnly: Boolean` em `TMangoHudSettings` para comunicar o
  estado ao `SaveMangoHudConfigCore`.
- Adicionar campo `FFpsOnly: Boolean` em `TMangoHudUiHelper` como estado
  interno da UI.
- Adicionar handler para o token `fps_only` em `LoadMangoHudBoolFlag`: ao
  carregar um arquivo que contém apenas `fps_only`, setar `FFpsOnly := True`.
- Resetar `FFpsOnly := False` em `ResetMangoHudControls` (início de cada load).
- Em `SaveMangoHudConfig`, propagar `FFpsOnly` para `Settings.FpsOnly`.
- Em `SaveMangoHudConfigCore`, quando `Settings.FpsOnly = True`, escrever
  apenas `fps_only` no lugar da config completa — incluindo mirror para
  `~/.config/MangoHud/MangoHud.conf` e Steam Flatpak (comportamento idêntico
  ao save normal).
- Em `GenericControlChange` (handler de auto-save), setar `FFpsOnly := False`
  quando qualquer controle da UI for modificado pelo usuário — cancelando o
  modo fps_only ao primeiro toque intencional.
- Simplificar `fpsonlyBitBtnClick`: em vez de escrever diretamente no arquivo,
  setar `FFpsOnly := True` e chamar `SaveMangoHudConfig` normalmente.

## Capabilities

### New Capabilities

- `mangohud-fps-only-round-trip`: O preset "FPS Only" do MangoHud sobrevive ao
  ciclo completo de save → load → save sem ser convertido para config completa.
  Qualquer modificação pelo usuário após selecionar FPS Only cancela o modo e
  restaura o comportamento de save normal.

### Modified Capabilities

_(Nenhuma capability existente tem requisitos alterados — a persistência de
tools em `config-persistence-and-tool-toggling` não cobre o ciclo interno do
arquivo MangoHud.conf.)_

## Impact

- **`overlay_config.pas`**: `TMangoHudSettings` (novo campo `FpsOnly`),
  `SaveMangoHudConfigCore` (branch para fps_only).
- **`mangohud_ui.pas`**: `TMangoHudUiHelper` (novo campo `FFpsOnly`),
  `ResetMangoHudControls`, `LoadMangoHudBoolFlag`, `SaveMangoHudConfig`.
- **`overlayunit.pas`**: `fpsonlyBitBtnClick` (simplificado),
  `GenericControlChange` (reset de `FFpsOnly`).
- Sem mudança em APIs públicas, arquivos de configuração externos ou
  dependências.
