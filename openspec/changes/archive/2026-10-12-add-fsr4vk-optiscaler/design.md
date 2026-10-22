# Design

## Context

Atualmente o GOverlay possui três canais para OptiScaler controlados por `optversionComboBox`:
- `0`: Stable Channel (`~/.local/share/goverlay/optiscaler/`)
- `1`: Bleeding-edge (`~/.local/share/goverlay/optiscaler-edge/`)
- `2`: Custom Build (`~/.local/share/goverlay/optiscaler-custom/`)

O repositório `dvj5411/fsr4vk` fornece um pacote com:
- `OptiScaler/amd_fidelityfx_upscaler_vk.dll` (FFX Vulkan provider com modelos INT8)
- `OptiScaler.dll` (fork customizado do OptiScaler que expõe e suporta esse provedor)

Para permitir que usuários comuns ativem o recurso com um simples clique sem perder o canal anterior, implementamos um canal dedicado `FSR4VK` e um toggle de conveniência no card de Upscaler.

## Goals / Non-Goals

**Goals:**
- Criar o canal de software `FSR4VK` (índice 2) e reposicionar `Custom Build` para o índice 3.
- Isolar os arquivos do fork em `~/.local/share/goverlay/optiscaler-fsr4vk/`.
- Oferecer um toggle `FSR4 Vulkan` na seção "Spatial Upscaler" do OptiScaler que comuta o canal de forma bidirecional.
- Garantir verificação e download automatizado do release `dvj5411/fsr4vk` na splash screen e suporte a updates via botão "Check for updates".
- Fazer deploy dos arquivos corretos para os perfis de jogos que usarem `FSR4VK` (`OPT_CHANNEL=2`).

**Non-Goals:**
- Não compilar o `fsr4vk` a partir do código fonte; o GOverlay consome os releases pré-compilados do GitHub.
- Não alterar a funcionalidade do FSR 4 DX12 já existente (`FSR4/Latest`, `FSR4/4.1.1b`, etc.).

## Decisions

### 1. Reordenação dos Canais no ComboBox
- **Decisão:** Inserir `FSR4VK` no índice 2 e mover `Custom Build` para o índice 3.
- **Alternativa considerada:** Colocar `FSR4VK` no final (índice 3). Foi descartada porque o `Custom Build` conceitualmente deve ser a última opção (opção manual/avançada do usuário).
- **Tratamento de migração:** Atualizar checagens de código onde `ItemIndex = 2` representava Custom Build para `ItemIndex = 3`. No salvamento de `bgmod.conf`, `OPT_CHANNEL=2` passa a representar `FSR4VK` e `OPT_CHANNEL=3` representa Custom Build.

### 2. Cache e Sincronização de Bibliotecas de Apoio
- **Decisão:** Criar a pasta `~/.local/share/goverlay/optiscaler-fsr4vk/`. Como o ZIP do release do `fsr4vk` contém apenas `OptiScaler.dll` e `OptiScaler/amd_fidelityfx_upscaler_vk.dll`, após extrair o ZIP o GOverlay copia as bibliotecas complementares da instalação estável (ex: `fakenvapi.dll`, `fakenvapi.ini`, `nvngx_dlss*.dll`, `libxess*.dll`, scripts de setup e template de `OptiScaler.ini`).
- **Benefício:** O jogo recebe uma instalação completa e funcional do OptiScaler, com o binário e provider Vulkan do `fsr4vk`.

### 3. Toggle de Atalho ("FSR4 Vulkan")
- **Decisão:** O toggle armazena em uma variável interna (`FPreviousOptChannel`) o canal que estava ativo antes de ligar o toggle.
  - Ao ligar: se canal != `FSR4VK`, guarda o canal atual e muda para `FSR4VK`.
  - Ao desligar: volta para `FPreviousOptChannel` (se válido) ou `Stable Channel`.
  - Mudanças manuais em `optversionComboBox`: se o usuário selecionar `FSR4VK`, o toggle liga. Se selecionar outro canal, o toggle desliga e atualiza `FPreviousOptChannel`.

### 4. Ciclo de Atualização e Splash
- **Decisão:**
  - Em `CheckAndInstallOptiScaler` / `TStartupDownloadThread`: adicionar checagem para `optiscaler-fsr4vk`. Se faltar `OptiScaler.dll` ou `OptiScaler/amd_fidelityfx_upscaler_vk.dll`, aciona download do release latest via API do GitHub.
  - Em `CheckForUpdates`: quando o canal selecionado for `FSR4VK`, faz a query do release `dvj5411/fsr4vk` no GitHub e compara com a tag registrada em `goverlay.vars`.

## Risks / Trade-offs

- **[Mudança de índice do Custom Build de 2 para 3]** → Mitigação: Atualizar todas as ocorrências no código (`overlay_config.pas`, `optiscaler_update.pas`, `optiscaler_tab.pas`, e testes em `gui_test_cases.pas`). Adicionar teste de regressão específico.
- **[Taxa limite da API do GitHub no splash / update]** → Mitigação: Seguir o mesmo padrão já usado no download do OptiScaler, salvando a versão em `goverlay.vars` para nunca re-baixar se os arquivos já estiverem íntegros no disco.
- **[Sobrescrita de arquivos do jogo]** → Mitigação: O deploy para a pasta do jogo respeita o mecanismo existente do `bgmod` e do `CopyOptiScalerGameFiles`.
