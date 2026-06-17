#!/bin/sh

set -ex

EXTRA_PACKAGES="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/get-debloated-pkgs.sh"

echo "Installing build dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
	appstream \
	base-devel \
	cmake \
	cmocka \
	curl \
	dbus \
	fmt \
	git \
	glew \
	glfw \
	glslang \
	glu \
	hicolor-icon-theme \
	lazarus \
	libx11 \
	libxkbcommon \
	meson \
	nlohmann-json \
	patchelf \
	pciutils \
	python \
	python-mako \
	python-matplotlib \
	python-numpy \
	qt6ct \
	qt6pas \
	sdl2 \
	sudo \
	ttf-nerd-fonts-symbols \
	vulkan-tools \
	wayland \
	wget \
	xorg-server-xvfb \
	zsync \
	dpkg \
	rpm-org


pacman-key --init
pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
pacman-key --lsign-key 3056513887B78AEB
pacman --noconfirm -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
pacman --noconfirm -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
echo '[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist' >> /etc/pacman.conf
pacman -Syu --noconfirm vkbasalt

echo "Building and installing vksumi from AUR..."
echo "---------------------------------------------------------------"
useradd -m builder || true
echo 'builder ALL=(ALL) NOPASSWD: /usr/bin/pacman' >> /etc/sudoers
git clone https://aur.archlinux.org/vksumi.git /tmp/vksumi
chown -R builder:builder /tmp/vksumi
(cd /tmp/vksumi && su builder -c "makepkg -si --noconfirm")

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
wget --retry-connrefused --tries=30 "$EXTRA_PACKAGES" -O ./get-debloated-pkgs.sh
chmod +x ./get-debloated-pkgs.sh
./get-debloated-pkgs.sh --add-common --prefer-nano mangohud-mini
