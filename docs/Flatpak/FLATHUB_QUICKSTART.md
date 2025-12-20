# Flathub Submission - Quick Start

## Processo Correto (Atualizado)

O processo de submissão ao Flathub é feito via **Pull Request** no repositório `flathub/flathub`, **NÃO** criando uma issue primeiro!

## Comandos Rápidos

```bash
# 1. Fork https://github.com/flathub/flathub (IMPORTANTE: desmarcar "Copy master branch only")

# 2. Clone seu fork usando a branch new-pr
git clone --branch=new-pr git@github.com:SEU_USUARIO/flathub.git
cd flathub

# 3. Crie uma branch para sua submissão
git checkout -b add-goverlay new-pr

# 4. Crie o diretório do app e copie o manifest
mkdir io.github.benjamimgois.goverlay
cp ~/Documentos/goverlay/io.github.benjamimgois.goverlay.flathub.yml \
   io.github.benjamimgois.goverlay/io.github.benjamimgois.goverlay.yml

# 5. Commit e push
git add io.github.benjamimgois.goverlay/
git commit -m "Add io.github.benjamimgois.goverlay"
git push origin add-goverlay

# 6. Vá para https://github.com/SEU_USUARIO/flathub e crie o Pull Request
#    - Base branch: new-pr (NÃO master!)
#    - Title: Add io.github.benjamimgois.goverlay
```

## Checklist Antes de Submeter

- [ ] Manifest testado localmente com `flatpak-builder`
- [ ] AppStream metadata validado com `appstreamcli validate`
- [ ] Desktop file validado com `desktop-file-validate`
- [ ] Source usa Git tag/commit (não `type: dir`)
- [ ] Permissões justificadas no PR
- [ ] Screenshots estão em URLs permanentes
- [ ] Licença correta (GPL-3.0-or-later)

## Após Criar o PR

1. Aguarde revisão dos mantenedores do Flathub
2. Responda aos comentários (NÃO feche o PR!)
3. Faça commits adicionais na mesma branch se precisar de mudanças
4. Após aprovação, seu app será publicado automaticamente

## Diferenças Importantes

❌ **ERRADO**: Criar issue → Aguardar repo → Fork do repo do app
✅ **CORRETO**: Fork flathub/flathub → PR para branch new-pr

## Links Úteis

- Documentação oficial: https://docs.flathub.org/docs/for-app-authors/submission
- Requirements: https://docs.flathub.org/docs/for-app-authors/requirements
- Guia detalhado: Ver FLATHUB_SUBMISSION.md
