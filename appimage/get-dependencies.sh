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
	gcc-libs \
	git \
	glew \
	glfw \
	glslang \
	glu \
	hicolor-icon-theme \
	lazarus \
	libglvnd \
	libx11 \
	libxkbcommon \
	mesa \
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
	qt6-wayland \
	strace \
	vulkan-headers \
	vulkan-icd-loader \
	vulkan-nouveau \
	vulkan-radeon \
	vulkan-tools \
	wayland \
	wget \
	xorg-server-xvfb \
	zsync

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
wget --retry-connrefused --tries=30 "$EXTRA_PACKAGES" -O ./get-debloated-pkgs.sh
chmod +x ./get-debloated-pkgs.sh
./get-debloated-pkgs.sh --add-common mangohud-mini
