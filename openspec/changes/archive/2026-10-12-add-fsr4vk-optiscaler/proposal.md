# Proposal

## Why

O OptiScaler oferece suporte experimental a modelos FSR 4 (4.1.1 e 4.0.2) via DirectX 12, mas jogos baseados nativamente em Vulkan (ou que utilizam rotas Vulkan diretas) não dispunham de um provedor FFX nativo integrado no GOverlay. O projeto da comunidade `fsr4vk` (dvj5411/fsr4vk) disponibiliza uma implementação nativa em Vulkan (INT8) acompanhada de um build especializado do OptiScaler.

Integrar este build como um canal dedicado no seletor de versão do OptiScaler ("FSR4VK") e oferecer um toggle de atalho direto ("FSR4 Vulkan") no grupo "Upscaler" torna o recurso altamente acessível e amigável para o usuário comum, sem quebrar os canais Stable, Bleeding-edge e Custom Build existentes.

## What Changes

- **Novo canal no Software Status (`optversionComboBox`)**:
  - Adiciona o canal `FSR4VK` entre `Bleeding-edge` e `Custom Build` (índice 2).
  - Atualiza o índice do `Custom Build` para 3.
  - O canal `FSR4VK` opera em diretório de cache dedicado: `~/.local/share/goverlay/optiscaler-fsr4vk/`.
- **Toggle de Descoberta Rápida ("FSR4 Vulkan")**:
  - Adiciona um toggle na sub-seção Spatial Upscaler do OptiScaler ("FSR4 Vulkan").
  - Ao ativar: salva o canal anterior e comuta o `optversionComboBox` para `FSR4VK`.
  - Ao desativar: restaura o canal anterior salvo (ex: `Stable Channel`).
  - Sincronização bi-direcional: alterar o canal no `optversionComboBox` para `FSR4VK` liga o toggle; mudar para outro canal desliga o toggle.
- **Download e Verificação na Splash Screen**:
  - Verifica a presença de `optiscaler-fsr4vk/OptiScaler.dll` e `optiscaler-fsr4vk/OptiScaler/amd_fidelityfx_upscaler_vk.dll` durante a inicialização (splash screen).
  - Se ausente, realiza o download e extração automática do release mais recente de `dvj5411/fsr4vk`.
- **Verificação de Atualizações**:
  - Quando o canal ativo for `FSR4VK`, a checagem de atualizações consulta a API do GitHub (`dvj5411/fsr4vk/releases/latest`) e compara com a tag gravada em `goverlay.vars`.
  - Notifica o usuário e permite atualizar via botão de atualização.
- **Deploy de Arquivos para o Jogo**:
  - Quando o jogo estiver configurado para o canal `FSR4VK`, copia os binários do cache `optiscaler-fsr4vk` (incluindo `OptiScaler/amd_fidelityfx_upscaler_vk.dll`).

## Capabilities

### Modified Capabilities
- `upscaler-channel-persistence`: Expande os canais suportados de OptiScaler para incluir `FSR4VK` (`OPT_CHANNEL = 2`, movendo Custom para `3`), com persistência por perfil e deploy a partir de `optiscaler-fsr4vk/`.
- `startup-libraries-verification`: Inclui a verificação e auto-download dos binários do release `fsr4vk` durante a rotina de inicialização na splash screen.
- `optiscaler-options-layout`: Adiciona o toggle "FSR4 Vulkan" na seção Spatial Upscaler e conecta o atalho bidirecional com o seletor de canal.

## Impact

- **Código modificado**:
  - `overlayunit.lfm`, `overlayunit.pas`: inclusão do novo item no combobox de canais, toggle visual, thread de splash.
  - `optiscaler_tab.pas`: layout do novo toggle, handlers de sincronização, atualização dos índices de canal.
  - `optiscaler_update.pas`: rotinas de download e verificação de release do `fsr4vk`, sincronização com `goverlay.vars`, atualização do status card.
  - `overlay_config.pas`: salvamento e carregamento de `OPT_CHANNEL`, caminhos de cópia para o diretório do jogo.
  - `bgmod_resources.pas`: funções auxiliares de caminho `GetBGModOriginalFsr4vkPath`.
- **Testes**:
  - `tests/gui/gui_test_cases.pas` e `tests/logic/logic_test_cases.pas`: ajuste de índices para `Custom Build` (índice 3) e novos testes para o canal `FSR4VK`.
