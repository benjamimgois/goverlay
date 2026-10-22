# Spec

## Purpose

Garante que o preset "FPS Only" do MangoHud sobreviva ao ciclo completo de save → load → save sem ser substituído por uma configuração padrão completa. Qualquer modificação posterior pelo usuário cancela o modo FPS Only e restaura o comportamento de save normal.

## ADDED Requirements

### Requirement: fps-only-token-load

Ao carregar um arquivo `MangoHud.conf` que contenha o token `fps_only`, o sistema SHALL reconhecer e preservar esse estado internamente, sem descartá-lo ou convertê-lo para o estado vazio equivalente à configuração padrão.

#### Scenario: arquivo contendo apenas fps_only é carregado

- **WHEN** o GOverlay carrega um `MangoHud.conf` cujo único token de configuração é `fps_only`
- **THEN** o estado interno `FFpsOnly` é verdadeiro e nenhum checkbox da aba MangoHud é marcado como ativo

### Requirement: fps-only-token-save

Quando o estado interno `FFpsOnly` é verdadeiro, o sistema SHALL escrever apenas o token `fps_only` nos arquivos de configuração do MangoHud — incluindo `gameconfig/global/MangoHud.conf`, `~/.config/MangoHud/MangoHud.conf` e o local Steam Flatpak — em vez de gerar a configuração completa a partir do estado da UI.

#### Scenario: save automático com estado fps_only ativo

- **WHEN** um save (manual ou automático) ocorre enquanto `FFpsOnly` é verdadeiro
- **THEN** todos os arquivos de configuração do MangoHud contêm apenas o token `fps_only`

### Requirement: fps-only-cancellation

Qualquer alteração intencional de um controle da UI do MangoHud (checkbox, toggle, trackbar, combobox ou radiobutton) SHALL cancelar o estado `FFpsOnly`, fazendo com que o próximo save gere a configuração completa a partir do estado atual da UI.

#### Scenario: usuário ativa uma métrica após fps_only

- **WHEN** `FFpsOnly` é verdadeiro E o usuário ativa qualquer controle da aba MangoHud
- **THEN** `FFpsOnly` é imediatamente definido como falso
- **AND** o próximo save gera a configuração completa normalmente
