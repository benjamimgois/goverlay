# Design

## Context

Ver `proposal.md → Why` para a motivação. Em resumo: `fps_only` é um token
especial do MangoHud que não tem representação nos controles da UI do GOverlay.
O parser atual (`LoadMangoHudBoolFlag`) não possui handler para esse token, então
ao carregar um arquivo `fps_only`, todos os controles ficam no estado padrão
(off). O próximo save substitui `fps_only` por uma config completa vazia.

**Fluxo atual (quebrado):**
```
fpsonlyBitBtnClick → escreve fps_only diretamente no arquivo (bypass de SaveMangoHudConfigCore)
↓
LoadMangoHudConfig: fps_only lido → sem handler → controles off
↓
Save automático → SaveMangoHudConfigCore → config completa vazia → fps_only PERDIDO
```

**Fluxo desejado:**
```
fpsonlyBitBtnClick → FFpsOnly=True → SaveMangoHudConfig
                                         ↓
                               Settings.FpsOnly=True
                                         ↓
                               SaveMangoHudConfigCore → escreve apenas fps_only
↓
LoadMangoHudConfig: fps_only lido → FFpsOnly=True
↓
Save automático → Settings.FpsOnly=True → escreve apenas fps_only ← PRESERVADO
```

## Goals / Non-Goals

**Goals:**
- `fps_only` sobrevive ao ciclo load→save completo.
- Qualquer toque do usuário em controles MangoHud cancela o modo fps_only.
- `fpsonlyBitBtnClick` reutiliza `SaveMangoHudConfigCore` (sem write direto).

**Non-Goals:**
- Não representa `fps_only` visualmente como checkbox na UI.
- Não implementa outros tokens especiais do MangoHud (e.g., `full`).
- Não corrige o save espúrio no startup (porém neutraliza seu efeito).

## Decisions

### D1: Estado como flag interno `FFpsOnly` em `TMangoHudUiHelper`

**Escolhido:** Campo `FFpsOnly: Boolean` privado em `TMangoHudUiHelper`.

**Por que não em `TMangoHudSettings`:** `TMangoHudSettings` é um record de
transferência (in/out de `SaveMangoHudConfigCore`). O estado `FFpsOnly` pertence
à UI. O campo `FpsOnly` é adicionado ao record apenas para comunicar o estado
de UI para o core de save — não como fonte de verdade.

**Alternativa descartada:** Detectar `fps_only` na hora do save verificando se
todos os checkboxes estão off. Frágil — um usuário pode querer salvar uma
config sem nenhuma métrica ativa sem estar em fps_only mode.

### D2: Cancelamento em `GenericControlChange`

**Escolhido:** `GenericControlChange` seta `FFpsOnly := False` antes de
chamar `StartAutoSaveTimer`.

**Por que Opção A (qualquer toque cancela):** É o comportamento mais intuitivo.
Se o usuário mudou qualquer controle, ele não está mais em "fps_only mode". A
ação `fpsonlyBitBtnClick` é sempre explícita.

**Alternativa descartada:** Opção B (apenas ao clicar em outro preset). Requer
instrução adicional ao usuário e pode deixar estado inconsistente se o usuário
fechar a UI sem clicar em outro preset.

### D3: `SaveMangoHudConfigCore` como ponto de branch

**Escolhido:** Branch no início de `SaveMangoHudConfigCore`:
```pascal
if Settings.FpsOnly then begin
  // escreve apenas fps_only + mirrors
  Result := True;
  Exit;
end;
```

**Por que não em `SaveMangoHudConfig` (UI helper):** `SaveMangoHudConfigCore`
já centraliza todos os mirrors (global + Flatpak). Duplicar essa lógica seria
propenso a drift. O branch garante que qualquer caminho que chame o core
(incluindo `fpsonlyBitBtnClick` refatorado) obtenha o comportamento correto.

### D4: `fpsonlyBitBtnClick` simplificado

**Escolhido:** Remover o write direto de `fpsonlyBitBtnClick`. O botão apenas
seta `FFpsOnly := True` e chama `SaveMangoHudConfig` normal.

**Impacto:** Elimina o bypass que causava dessincronização entre
`gameconfig/global/MangoHud.conf` e `~/.config/MangoHud/MangoHud.conf` (fix
anterior ao bug #405, agora substituído por essa abordagem mais limpa).

## Risks / Trade-offs

- **[Risco] `FFpsOnly` não é persistido além do arquivo:** Se algo além do
  GOverlay modificar o `MangoHud.conf` removendo `fps_only`, o estado será
  recalibrado no próximo load. → Mitigação: load sempre re-deriva `FFpsOnly`
  do arquivo, então é auto-corretivo.

- **[Trade-off] Save espúrio no startup ainda ocorre:** O save único disparado
  durante `FormShow → mangohudLabelClick(nil)` continua acontecendo, mas agora
  escreve `fps_only` corretamente (neutralizado). Corrigir o save espúrio em
  si requereria setar `FLoadingConfig = True` durante todo o `mangohudLabelClick`
  — deixado para uma mudança separada se necessário.

## Open Questions

_(Nenhuma.)_
