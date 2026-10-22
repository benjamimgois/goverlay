# Tasks

## 1. Suporte a Canais e Cache FSR4VK

- [x] 1.1 Atualizar `optversionComboBox` em `overlayunit.lfm` e constantes para incluir `FSR4VK` (índice 2) e mover `Custom Build` para índice 3, verificando a renderização dos itens.
- [x] 1.2 Implementar helpers de caminho `GetBGModOriginalFsr4vkPath` em `bgmod_resources.pas` apontando para `~/.local/share/goverlay/optiscaler-fsr4vk/`.
- [x] 1.3 Atualizar a lógica de persistência e carregamento de `OPT_CHANNEL` em `overlay_config.pas` para suportar `2` (FSR4VK) e `3` (Custom Build), verificando a gravação correta em `bgmod.conf`.
- [x] 1.4 Atualizar a cópia de binários para o jogo (`CopyOptiScalerGameFiles` e `GetFGModPath`) para sincronizar `optiscaler-fsr4vk/` (incluindo `OptiScaler/amd_fidelityfx_upscaler_vk.dll` e `OptiScaler.dll`) quando o perfil estiver configurado com `OPT_CHANNEL=2`.

## 2. Toggle de Atalho "FSR4 Vulkan"

- [x] 2.1 Adicionar o toggle switch `fsr4vkToggle` (ou `fsr4vkCheckBox`) na seção "Spatial Upscaler" do OptiScaler em `optiscaler_tab.pas` com hint descritivo.
- [x] 2.2 Implementar sincronização bidirecional entre o toggle e `optversionComboBox` (ativar o toggle comuta para `FSR4VK` guardando o canal anterior; desativar restaura o canal anterior; mudanças diretas no combobox sincronizam o toggle).
- [x] 2.3 Ajustar o layout responsivo/reflow da seção Spatial Upscaler em `optiscaler_tab.pas` para acomodar o novo toggle mantendo a altura da sub-seção alinhada.

## 3. Download no Splash e Verificação de Atualizações

- [x] 3.1 Implementar rotina de download e extração do release de `dvj5411/fsr4vk` em `optiscaler_update.pas` (`CheckAndInstallFsr4vk`), copiando arquivos de apoio da instalação estável.
- [x] 3.2 Integrar a verificação de `optiscaler-fsr4vk` na splash screen (`TStartupDownloadThread.Execute` em `overlayunit.pas` e `HasMissingMandatoryLibraries`).
- [x] 3.3 Adicionar checagem de atualizações para `FSR4VK` no `CheckForUpdates` / `TOptiUpdateThread` consultando a API do GitHub e atualizando `goverlay.vars`.

## 4. Testes e Validação

- [x] 4.1 Atualizar testes existentes em `tests/gui/gui_test_cases.pas` e `tests/logic/logic_test_cases.pas` que referenciam o índice de Custom Build.
- [x] 4.2 Adicionar testes automatizados para round-trip de `OPT_CHANNEL=2`, sincronização do toggle "FSR4 Vulkan", e inicialização do cache `optiscaler-fsr4vk/`.
- [x] 4.3 Executar bateria de testes com `./build_tests.sh` e `./run_tests.sh` e verificar 100% de aprovação.
