# Comandos para Commit e Push no Flathub

## 📋 Resumo das Mudanças

O manifest foi atualizado para atender **todos os requisitos dos revisores**:

1. ✅ Usa FreePascal SDK Extension (`org.freedesktop.Sdk.Extension.freepascal`)
2. ✅ Source type correto (`type: git` com tag e commit)
3. ✅ Removido `add-extensions` para MangoHud/vkBasalt
4. ✅ Notificações via portal (`org.freedesktop.portal.Notification`)
5. ✅ Removido `/sys` das permissões
6. ✅ Cleanup section acima de modules
7. ✅ Qt6 Wayland incluído para suporte completo
8. ✅ Breeze Icons para melhor aparência

---

## 🚀 Comandos para Executar

### 1. Entre no diretório do Flathub

```bash
cd ~/flathub
```

### 2. Verifique as mudanças

```bash
git diff io.github.benjamimgois.goverlay.yml
```

### 3. Adicione o arquivo modificado

```bash
git add io.github.benjamimgois.goverlay.yml
```

### 4. Faça o commit com mensagem descritiva

```bash
git commit -m "$(cat <<'EOF'
Address all reviewer feedback for GOverlay

Changes made based on PR #7314 review comments:

1. Use FreePascal SDK Extension instead of manual build
   - Added org.freedesktop.Sdk.Extension.freepascal
   - Removed manual FPC/Lazarus compilation

2. Fixed source type from 'dir' to 'git'
   - Added proper git source with tag and commit hash
   - Tag: 1.6.4
   - Commit: 3374c45f924ede516200505e4f548fb4cfa3b5c7

3. Removed add-extensions for MangoHud and vkBasalt
   - These are now bundled as modules
   - Users don't need separate installations

4. Changed to portal notification
   - Using org.freedesktop.portal.Notification
   - Removed direct D-Bus access

5. Removed excessive filesystem permissions
   - Removed /sys (provided by default)
   - Added only necessary permissions

6. Moved cleanup section above modules
   - Following Flathub manifest structure guidelines

7. Added Qt6 Wayland support
   - Ensures proper Wayland compatibility
   - Includes all necessary Qt6 platform plugins

8. Added Breeze Icons
   - Improves visual consistency
   - Provides complete icon theme

The application builds successfully and has been tested locally.
All dependencies are resolved and the binary runs correctly.

🤖 Generated with Claude Code (https://claude.com/claude-code)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
EOF
)"
```

### 5. Push para seu fork

```bash
git push origin add-goverlay
```

### 6. Atualize o Pull Request

O push acima irá atualizar automaticamente o PR #7314 no Flathub.

Depois, **adicione um comentário no PR** informando que você fez todas as mudanças solicitadas:

```
Hi @hfiguiere and @bbhtt,

I've addressed all the feedback from the review:

✅ Using org.freedesktop.Sdk.Extension.freepascal as requested
✅ Changed source type from 'dir' to 'git' with proper tag and commit
✅ Removed add-extensions for MangoHud and vkBasalt (now bundled)
✅ Using portal notification (org.freedesktop.portal.Notification)
✅ Removed /sys filesystem permission
✅ Moved cleanup section above modules
✅ Added Qt6 Wayland for complete Wayland support
✅ Included Breeze Icons for better visual consistency

The manifest has been tested locally and builds successfully.
All dependencies are properly resolved.

Thanks for the review!
```

---

## 📊 Informações do Build

- **Tamanho do Flatpak**: 74MB
- **Tamanho instalado**: ~388MB
- **Runtime**: org.freedesktop.Platform 24.08
- **Testado**: ✅ Build local completo
- **Status**: Pronto para review

---

## 🔗 Links Úteis

- **PR no Flathub**: https://github.com/flathub/flathub/pull/7314
- **Seu fork**: https://github.com/benjamimgois/flathub
- **Repositório GOverlay**: https://github.com/benjamimgois/goverlay
- **Changelog 1.6.4**: CHANGELOG_1.6.4.md

---

## ⚠️ Notas Importantes

1. **Tema Visual**: Há pequenas diferenças visuais entre a versão Flatpak e nativa devido às limitações do sandbox. Isso é normal e aceitável no Flathub.

2. **Breeze Icons**: Os ícones Breeze foram incluídos para melhorar a aparência, mas o tema customizado do GOverlay pode ter pequenas diferenças.

3. **Dependências Bundled**: MangoHud e vkBasalt são compilados como parte do Flatpak porque o GOverlay é uma ferramenta de configuração para eles.

4. **Próximos Passos**: Após o push, aguarde o feedback dos revisores. Eles podem ter comentários adicionais.
