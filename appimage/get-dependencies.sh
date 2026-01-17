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
	pciutils \
	python \
	python-mako \
	python-matplotlib \
	python-numpy \
	qt6ct \
	qt6pas \
	sdl2 \
	vulkan-tools \
	wayland \
	wget \
	xorg-server-xvfb \
	zsync

# temp solution until pascube can be built in CI
pacman-key --init
pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
pacman-key --lsign-key 3056513887B78AEB
pacman --noconfirm -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
pacman --noconfirm -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
echo '[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist' >> /etc/pacman.conf
pacman -Syu --noconfirm vkbasalt

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
wget --retry-connrefused --tries=30 "$EXTRA_PACKAGES" -O ./get-debloated-pkgs.sh
chmod +x ./get-debloated-pkgs.sh
./get-debloated-pkgs.sh --add-common --prefer-nano mangohud-mini

echo "Getting pascube..."
echo "---------------------------------------------------------------"
tarball=$(wget --retry-connrefused --tries=30 https://api.github.com/repos/benjamimgois/pascube/releases -O - \
		| sed 's/[()",{} ]/\n/g' | grep -oi "https.*/pascube_.*.tar.gz$" | head -1
)
wget --retry-connrefused --tries=30 "$tarball" -O /tmp/pascube.tar.gz
tar xvf /tmp/pascube.tar.gz
chmod +x ./pascube
mv -v ./pascube /usr/bin
mkdir -p /usr/share/pascube 
mv -v ./assets /usr/share/pascube
