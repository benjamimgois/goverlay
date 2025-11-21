#!/bin/bash
# Script para construir e testar o pacote Flatpak do Goverlay

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Goverlay Flatpak Build Script ===${NC}\n"

# Verificar dependências
echo -e "${YELLOW}Verificando dependências...${NC}"

if ! command -v flatpak &> /dev/null; then
    echo -e "${RED}Erro: Flatpak não está instalado${NC}"
    echo "Instale com: sudo pacman -S flatpak"
    exit 1
fi

if ! command -v flatpak-builder &> /dev/null; then
    echo -e "${RED}Erro: flatpak-builder não está instalado${NC}"
    echo "Instale com: sudo pacman -S flatpak-builder"
    exit 1
fi

echo -e "${GREEN}✓ Flatpak instalado: $(flatpak --version)${NC}"

# Verificar runtime
echo -e "\n${YELLOW}Verificando runtime do Flatpak...${NC}"
if ! flatpak list --runtime | grep -q "org.freedesktop.Platform.*23.08"; then
    echo -e "${YELLOW}Runtime org.freedesktop.Platform 23.08 não encontrado${NC}"
    echo "Instalando runtime..."
    flatpak install -y flathub org.freedesktop.Platform//23.08 org.freedesktop.Sdk//23.08
else
    echo -e "${GREEN}✓ Runtime org.freedesktop.Platform 23.08 já instalado${NC}"
fi

# Criar diretório de build
BUILD_DIR="flatpak-build"
REPO_DIR="flatpak-repo"

echo -e "\n${YELLOW}Preparando diretórios de build...${NC}"
rm -rf "$BUILD_DIR" "$REPO_DIR"
mkdir -p "$BUILD_DIR" "$REPO_DIR"

# Construir o Flatpak
echo -e "\n${GREEN}=== Iniciando build do Flatpak ===${NC}\n"

# Nota: Alguns checksums no manifesto podem estar incorretos e precisarão ser atualizados
# Para teste rápido, podemos usar --disable-download-validation mas isso não é recomendado para produção

flatpak-builder \
    --force-clean \
    --repo="$REPO_DIR" \
    --disable-rofiles-fuse \
    --ccache \
    --state-dir=".flatpak-builder" \
    "$BUILD_DIR" \
    io.github.benjamimgois.goverlay.yml \
    || {
        echo -e "\n${RED}Erro no build do Flatpak${NC}"
        echo -e "${YELLOW}Se o erro for relacionado a checksums, você precisará atualizá-los no manifesto${NC}"
        echo -e "${YELLOW}Para calcular checksums: sha256sum <arquivo>${NC}"
        exit 1
    }

echo -e "\n${GREEN}✓ Build concluído com sucesso!${NC}"

# Instalar localmente
echo -e "\n${YELLOW}Deseja instalar o Flatpak localmente? (s/N)${NC}"
read -r -n 1 INSTALL
echo

if [[ $INSTALL =~ ^[Ss]$ ]]; then
    echo -e "${YELLOW}Instalando Goverlay...${NC}"

    # Add local repo temporarily
    flatpak --user remote-add --no-gpg-verify --if-not-exists goverlay-local "$REPO_DIR" || true

    # Install from local repo
    flatpak --user install -y goverlay-local io.github.benjamimgois.goverlay

    # Remove local repo (optional, keep for updates)
    # flatpak --user remote-delete goverlay-local

    echo -e "\n${GREEN}✓ Goverlay instalado com sucesso!${NC}"
    echo -e "${GREEN}Execute com: flatpak run io.github.benjamimgois.goverlay${NC}"
fi

echo -e "\n${GREEN}=== Processo concluído ===${NC}"
echo -e "\nPara exportar o bundle:"
echo -e "  flatpak build-bundle $REPO_DIR goverlay.flatpak io.github.benjamimgois.goverlay"
echo -e "\nPara desinstalar:"
echo -e "  flatpak uninstall io.github.benjamimgois.goverlay"
