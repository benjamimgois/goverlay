## Why

Cards de jogos no grid da aba Games que não possuem capa de arte (do Steam ou busca web) exibem uma imagem gerada como fallback. Atualmente, o fallback é gerado usando o ícone legado de sobreposições em vez da identidade visual moderna do GOverlay (o novo símbolo arredondado com detalhes azuis usado na barra lateral e ícones do app). Além disso, capas salvas anteriormente em cache continuam exibindo o ícone antigo.

## What Changes

- Atualizar o gerador de capas padrão (`GenerateFallbackCover`) em `games_tab.pas` para carregar e renderizar o novo logotipo oficial do GOverlay (`assets/icons/goverlay.png` ou `data/icons/256x256/goverlay.png`) centralizado sobre um fundo escuro elegante (`#20242C`).
- Ajustar a resolução dos caminhos do ícone em `GenerateFallbackCover` para priorizar os assets internos do aplicativo antes das pastas do sistema operacional.
- Permitir que capas de fallback existentes em cache (marcadas pelo arquivo `.fallback`) sejam regeneradas na inicialização ou quando necessário, garantindo que o usuário veja o novo visual imediatamente.
- Adicionar testes automatizados para validar a criação correta do fallback com o novo ícone e dimensões.

## Capabilities

### New Capabilities
- `game-card-fallback-covers`: Geração e renderização de capas de placeholder modernas com o novo logotipo do GOverlay para jogos sem arte.

### Modified Capabilities
<!-- None -->

## Impact

- Código afetado: `games_tab.pas` (`GenerateFallbackCover`, `TNonSteamCoverThread`, `InitGamesTab`).
- Assets: `assets/icons/goverlay.png`, `data/icons/256x256/goverlay.png`.
- Testes: `tests/gui/gui_test_cases.pas`.
