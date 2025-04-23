#!/bin/sh

set -ex

sed -i 's/DownloadUser/#DownloadUser/g' /etc/pacman.conf

if [ "$(uname -m)" = 'x86_64' ]; then
	PKG_TYPE='x86_64.pkg.tar.zst'
else
	PKG_TYPE='aarch64.pkg.tar.xz'
fi

LLVM_URL="https://github.com/pkgforge-dev/llvm-libs-debloated/releases/download/continuous/llvm-libs-nano-$PKG_TYPE"
QT6_URL="https://github.com/pkgforge-dev/llvm-libs-debloated/releases/download/continuous/qt6-base-iculess-$PKG_TYPE"
LIBXML_URL="https://github.com/pkgforge-dev/llvm-libs-debloated/releases/download/continuous/libxml2-iculess-$PKG_TYPE"
MESA_URL="https://github.com/pkgforge-dev/llvm-libs-debloated/releases/download/continuous/mesa-mini-$PKG_TYPE"

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

if [ "$(uname -m)" = 'x86_64' ]; then
	pacman -Syu --noconfirm vulkan-intel
else
	pacman -Syu --noconfirm \
		vulkan-freedreno vulkan-panfrost vulkan-broadcom
fi


echo "Building mangohud..."
echo "---------------------------------------------------------------"
sed -i 's|EUID == 0|EUID == 69|g' /usr/bin/makepkg
mkdir -p /usr/local/bin
cp /usr/bin/makepkg /usr/local/bin

sed -i -e 's|-O2|-Os|' \
	-e 's|MAKEFLAGS=.*|MAKEFLAGS="-j$(nproc)"|' \
	-e 's|#MAKEFLAGS|MAKEFLAGS|' \
	/etc/makepkg.conf

cat /etc/makepkg.conf

git clone https://gitlab.archlinux.org/archlinux/packaging/packages/mangohud.git ./mangohud
( cd ./mangohud
	sed -i -e "s|x86_64|$(uname -m)|" \
		-e 's|-Dmangohudctl=true|-Dmangohudctl=true -Dwith_xnvctrl=disabled|' \
		-e '/libxnvctrl/d' ./PKGBUILD
	makepkg -f
	ls -la .
	pacman --noconfirm -U *.pkg.tar.*
)
rm -rf ./mangohud


echo "Installing debloated pckages..."
echo "---------------------------------------------------------------"
wget --retry-connrefused --tries=30 "$LLVM_URL"   -O  ./llvm.pkg.tar.zst
wget --retry-connrefused --tries=30 "$LIBXML_URL" -O  ./libxml2.pkg.tar.zst
wget --retry-connrefused --tries=30 "$QT6_URL"    -O  ./qt6-base.pkg.tar.zst
wget --retry-connrefused --tries=30 "$MESA_URL"   -O  ./mesa.pkg.tar.zst

pacman -U --noconfirm ./*.pkg.tar.zst
rm -f ./*.pkg.tar.zst


echo "All done!"
echo "---------------------------------------------------------------"
