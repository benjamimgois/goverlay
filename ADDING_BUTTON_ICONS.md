# Como Adicionar Ícones aos Botões no Lazarus IDE

Este guia explica passo a passo como adicionar os ícones criados aos botões do Goverlay.

## 📋 Pré-requisitos

- Lazarus IDE instalado
- Projeto Goverlay aberto (`goverlay.lpi`)
- Ícones já criados em `data/icons/buttons/24x24/`

## 🎨 Passo 1: Adicionar Ícones ao ImageList

1. **Abrir o form principal**:
   - No Lazarus, abra `overlayunit.lfm` (duplo-clique no arquivo ou F12)

2. **Selecionar o ImageList**:
   - Na árvore de objetos (Object Inspector), procure por `iconsImageList`
   - Se não existir, crie um novo:
     - Menu: Component → Standard → TImageList
     - Arraste para o form
     - Renomeie para `buttonIconsImageList`

3. **Configurar o ImageList**:
   - Clique em `iconsImageList` (ou `buttonIconsImageList`)
   - No Object Inspector, encontre a propriedade `Images`
   - Clique no botão `[...]` para abrir o editor de imagens

4. **Adicionar os ícones**:
   - Clique em "Add" para cada ícone
   - Navegue até `data/icons/buttons/24x24/`
   - Adicione na seguinte ordem (importante para os índices):
     ```
     Índice 0: save.png
     Índice 1: test.png
     Índice 2: update.png
     Índice 3: copy.png
     Índice 4: download.png
     Índice 5: folder.png
     Índice 6: help.png
     Índice 7: check.png
     ```
   - Clique em "OK" para salvar

## 🔧 Passo 2: Configurar os Botões

Para cada botão principal, siga estes passos:

### Botão de Salvar (saveBitBtn)

1. **Selecionar o botão**:
   - Clique em `saveBitBtn` no form ou na árvore de objetos

2. **Configurar propriedades**:
   - `Images`: Selecione `iconsImageList` (ou `buttonIconsImageList`)
   - `ImageIndex`: Digite `0` (ícone save.png)
   - `Layout`: Escolha `blGlyphLeft` (ícone à esquerda do texto)
   - `Spacing`: Digite `8` (espaçamento entre ícone e texto)
   - `Caption`: Mantenha "Save" ou ajuste conforme necessário

### Botão de Testar (popupBitBtn ou botões de teste)

1. Selecione o botão de teste
2. Configure:
   - `Images`: `iconsImageList`
   - `ImageIndex`: `1` (ícone test.png)
   - `Layout`: `blGlyphLeft`
   - `Spacing`: `8`

### Botão de Atualizar (updateBitBtn)

1. Selecione `updateBitBtn`
2. Configure:
   - `Images`: `iconsImageList`
   - `ImageIndex`: `2` (ícone update.png)
   - `Layout`: `blGlyphLeft`
   - `Spacing`: `8`

### Botão de Copiar (copyBitBtn)

1. Selecione `copyBitBtn`
2. Configure:
   - `Images`: `iconsImageList`
   - `ImageIndex`: `3` (ícone copy.png)
   - `Layout`: `blGlyphLeft`
   - `Spacing`: `8`

### Botão de Check Update (checkupdBitBtn)

1. Selecione `checkupdBitBtn`
2. Configure:
   - `Images`: `iconsImageList`
   - `ImageIndex`: `7` (ícone check.png)
   - `Layout`: `blGlyphLeft`
   - `Spacing`: `8`

### Botão de Download (gupdateBitBtn, reshaderefreshBitBtn)

1. Selecione o botão de download
2. Configure:
   - `Images`: `iconsImageList`
   - `ImageIndex`: `4` (ícone download.png)
   - `Layout`: `blGlyphLeft`
   - `Spacing`: `8`

### Botão de Log Folder (logfolderBitBtn)

1. Selecione `logfolderBitBtn`
2. Configure:
   - `Images`: `iconsImageList`
   - `ImageIndex`: `5` (ícone folder.png)
   - `Layout`: `blGlyphLeft`
   - `Spacing`: `8`

### Botão de Ajuda (howtoBitBtn)

1. Selecione `howtoBitBtn`
2. Configure:
   - `Images`: `iconsImageList`
   - `ImageIndex`: `6` (ícone help.png)
   - `Layout`: `blGlyphLeft`
   - `Spacing`: `8`

## 📊 Mapeamento Completo de Botões

| Botão (Nome) | Ícone Index | Ícone File | Descrição |
|-------------|-------------|------------|-----------|
| saveBitBtn | 0 | save.png | Salvar configuração |
| popupBitBtn | 1 | test.png | Testar overlay |
| updateBitBtn | 2 | update.png | Atualizar OptiScaler |
| copyBitBtn | 3 | copy.png | Copiar comando |
| gupdateBitBtn | 4 | download.png | Atualizar Goverlay |
| reshaderefreshBitBtn | 4 | download.png | Download ReShade |
| logfolderBitBtn | 5 | folder.png | Abrir pasta de logs |
| howtoBitBtn | 6 | help.png | Como usar |
| checkupdBitBtn | 7 | check.png | Verificar atualizações |

## 🎨 Dicas de Layout

### Layouts Disponíveis:
- `blGlyphLeft`: Ícone à esquerda do texto (recomendado)
- `blGlyphRight`: Ícone à direita do texto
- `blGlyphTop`: Ícone acima do texto
- `blGlyphBottom`: Ícone abaixo do texto

### Spacing Recomendado:
- `8`: Espaçamento padrão (recomendado)
- `4`: Espaçamento compacto
- `12`: Espaçamento espaçoso

### Ajuste de Tamanho do Botão:
Se os botões ficarem muito pequenos com os ícones:
1. Selecione o botão
2. Ajuste `Width` e `Height` conforme necessário
3. Ou use `AutoSize: True` para ajuste automático

## 🔄 Passo 3: Testar as Mudanças

1. **Salvar o form**:
   - Ctrl+S ou File → Save

2. **Compilar o projeto**:
   - F9 ou Run → Run
   - Ou use o Makefile: `make clean && make`

3. **Executar e verificar**:
   - Os ícones devem aparecer nos botões
   - Verifique se o alinhamento está correto
   - Teste a funcionalidade dos botões

## 🐛 Troubleshooting

### Ícones não aparecem:
- Verifique se o `ImageIndex` está correto
- Confirme que `Images` aponta para o ImageList correto
- Certifique-se de que os arquivos PNG existem em `data/icons/buttons/24x24/`

### Ícones muito grandes/pequenos:
- Use tamanho diferente: 16x16 ou 32x32
- Ajuste `Width` e `Height` do ImageList

### Ícones cortados:
- Aumente o `Width` do botão
- Reduza o texto do `Caption`
- Use `AutoSize: True`

## 📝 Nota sobre Versionamento

Após fazer as mudanças no Lazarus:
1. O arquivo `overlayunit.lfm` será modificado
2. Possivelmente `goverlay.lpr` ou outros arquivos de projeto
3. Faça commit das mudanças:
   ```bash
   git add overlayunit.lfm goverlay.lpr
   git commit -m "Add icons to main buttons"
   git push
   ```

## 🎯 Próximos Passos

Após adicionar os ícones básicos, considere:

1. **Adicionar mais ícones**:
   - Criar ícones para botões de preset
   - Ícones para botões de configuração
   - Ícones de status (sucesso, erro, aviso)

2. **Tooltips melhorados**:
   - Adicionar `Hint` aos botões
   - Ativar `ShowHint: True`

3. **Estados dos botões**:
   - Considerar ícones para estados disabled
   - Hover effects (se suportado pelo widget)

## 📚 Recursos Adicionais

- [Lazarus ImageList Documentation](https://wiki.lazarus.freepascal.org/TImageList)
- [TBitBtn Documentation](https://wiki.lazarus.freepascal.org/TBitBtn)
- Ícones originais: `data/icons/buttons/README.md`
