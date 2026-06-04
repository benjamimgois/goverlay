# Maintainer: Benjamim Gois <benjamim dot gois at gmail dot com>
# Co-Maintainer: Mark Wagie <mark dot wagie at proton dot me>
pkgname=pascube
pkgver=1.6.1
pkgrel=2
pkgdesc="A simple Vulkan spinning cube written in Pascal (Lazarus/Qt6)"
arch=('x86_64')
url="https://github.com/benjamimgois/pascube"
license=('GPL-2.0-or-later')
depends=(
  'qt6-base'            # Qt6 runtime
  'qt6pas'              # Pascal bindings for Qt6
  'mesa'                # OpenGL/Vulkan drivers
  'glu'                 # OpenGL Utility Library
  'sdl2-compat'         # SDL2 compatibility layer
  'hicolor-icon-theme'  # Freedesktop.org Hicolor icon theme
)
makedepends=(
  'fpc'
  'fpc-src'
  'lazarus'    # provides lazbuild on Arch
  'clang'      # for compiling PasVulkan lzma_c
)
provides=("pascube")
conflicts=("pascube-git")
source=("${url}/archive/${pkgver}.tar.gz")
sha256sums=('a16f483c4288261f2972236cd46e1d418eb0b92a36e7b472446d2845cbf646c2')

prepare() {
  cd "${pkgname}-${pkgver}"

  # Use an isolated Lazarus config dir for reproducible builds
  mkdir -p build

  # FIX: Patch pascube.lpi to include pasvulkan/src in library paths
  # The 1.6.1 tag was released before this fix was committed.
  sed -i '/<UnitOutputDirectory/a \      <Libraries Value="pasvulkan/src"/>' pascube.lpi
}

build() {

  cd "${pkgname}-${pkgver}"

  # Compile missing PasVulkan LZMA object file
  msg "Compiling lzmadec_linux_x86_64.o..."
  clang -c -target x86_64-linux -g -gdwarf-2 -masm=intel -O3 -D linux -fverbose-asm -fno-builtin \
        "pasvulkan/src/lzma_c/LzmaDec.c" -o "pasvulkan/src/lzma_c/lzmadec_linux_x86_64.o"

  # Build using LCL Qt6
  lazbuild --lazarusdir=/usr/lib/lazarus --widgetset=qt6 --primary-config-path=build "${pkgname}.lpi"

  # Detect the resulting binary location
  BIN_CANDIDATE=""
  # Common release locations
  if [[ -f "src/pascube/bin/pascube" ]]; then
     BIN_CANDIDATE="src/pascube/bin/pascube"
  elif [[ -f "pascube" ]]; then
     BIN_CANDIDATE="pascube"
  elif [[ -f "bin/pascube" ]]; then
     BIN_CANDIDATE="bin/pascube"
  fi

  if [[ -z "${BIN_CANDIDATE}" ]]; then
    echo "Error: Could not find compiled binary 'pascube'."
    find . -type f -executable -print
    exit 1
  fi

  echo "Found compiled binary at: ${BIN_CANDIDATE}"
  # Store the path for package()
  printf '%s' "${BIN_CANDIDATE}" > .built_binary_path
}

package() {
  cd "${pkgname}-${pkgver}"

  # Read binary path detected during build()
  BIN_PATH="$(< .built_binary_path)"
  [[ -x "${BIN_PATH}" ]] || { echo "Error: built binary not executable: ${BIN_PATH}"; exit 1; }

  # Install the real binary under /usr/lib/pascube/bin
  install -Dm755 "${BIN_PATH}" "${pkgdir}/usr/lib/${pkgname}/bin/${pkgname}"

  # Install assets into /usr/lib/pascube/assets
  # We assume 'assets' is a directory in the build root
  cp -a assets "${pkgdir}/usr/lib/${pkgname}/"

  # Wrapper: force X11 via xcb
  install -Dm755 /dev/stdin "${pkgdir}/usr/bin/${pkgname}" <<'EOF'
#!/bin/sh
export QT_QPA_PLATFORM=xcb
exec /usr/lib/pascube/bin/pascube "$@"
EOF

  # Create and install desktop file
  cat <<EOF2 > pascube.desktop
[Desktop Entry]
Name=pasCube
Comment=A simple vulkan spinning cube in pascal
Exec=pascube
Icon=pascube
StartupWMClass=pascube
Terminal=false
Type=Application
Categories=Game;
Keywords=pascube;cube;test;vulkan;
EOF2
  install -Dm644 pascube.desktop "${pkgdir}/usr/share/applications/pascube.desktop"

  # Install license
  install -Dm644 LICENSE "${pkgdir}/usr/share/licenses/${pkgname}/LICENSE"

  # ---- Icons (from data/icons/{128x128,256x256,512x512}/pascube.png) ----
  for sz in 128x128 256x256 512x512; do
    if [[ -f "data/icons/${sz}/pascube.png" ]]; then
      install -Dm644 "data/icons/${sz}/pascube.png" \
        "${pkgdir}/usr/share/icons/hicolor/${sz}/apps/pascube.png"
    fi
  done
  # Fallback to pixmaps
  if [[ -f "data/icons/512x512/pascube.png" ]]; then
      install -Dm644 "data/icons/512x512/pascube.png" "${pkgdir}/usr/share/pixmaps/pascube.png"
  fi
}
