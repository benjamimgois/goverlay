# Maintainer: Benjamim Gois <benjamim dot gois at gmail dot com>
# Co-Maintainer: Mark Wagie <mark dot wagie at proton dot me>
pkgname=pascube-git
pkgver=1.6.1.r4.g534a4db
pkgrel=1
pkgdesc="A simple Vulkan spinning cube written in Pascal (Lazarus/Qt6)"
arch=('x86_64')
url="https://github.com/benjamimgois/pascube"
license=('GPL-2.0-or-later')
depends=(
  'qt6-base'   # Qt6 runtime
  'qt6pas'     # Lazarus Qt6 bindings (LCL Qt6)
  'mesa'       # libGL
  'glu'        # libGLU
  'sdl2-compat'
  'hicolor-icon-theme' # Icon theme hierarchy
)
makedepends=(
  'git'
  'fpc'
  'fpc-src'
  'lazarus'    # provides lazbuild on Arch
  'clang'      # for compiling PasVulkan lzma_c
)
provides=("${pkgname%-git}")
conflicts=("${pkgname%-git}")
source=("git+${url}.git")
sha256sums=('SKIP')

pkgver() {
  cd "${pkgname%-git}"
  # Prefer tags; fallback to commitcount+short hash
  git describe --long --tags --abbrev=7 2>/dev/null \
    | sed 's/\([^-]*-g\)/r\1/;s/-/./g' \
  || printf "0.r%s.g%s" "$(git rev-list --count HEAD)" "$(git rev-parse --short HEAD)"
}

prepare() {
  cd "${pkgname%-git}"
  # Use an isolated Lazarus config dir for reproducible builds
  mkdir -p build
}

build() {

  cd "${pkgname%-git}"
  
  # Compile missing PasVulkan LZMA object file
  msg "Compiling lzmadec_linux_x86_64.o..."
  clang -c -target x86_64-linux -g -gdwarf-2 -masm=intel -O3 -D linux -fverbose-asm -fno-builtin \
        "pasvulkan/src/lzma_c/LzmaDec.c" -o "pasvulkan/src/lzma_c/lzmadec_linux_x86_64.o"

  # Build using LCL Qt6
  lazbuild --lazarusdir=/usr/lib/lazarus --widgetset=qt6 --primary-config-path=build "${pkgname%-git}.lpi"

  # Detect the resulting binary location
  BIN_CANDIDATE=""
  for p in \
    "./${pkgname%-git}" \
    "./bin/${pkgname%-git}" \
    ./lib/*/"${pkgname%-git}" \
    ./lib/"${pkgname%-git}"; do
    [[ -x "$p" ]] && { BIN_CANDIDATE="$p"; break; }
  done
  [[ -n "${BIN_CANDIDATE}" ]] || BIN_CANDIDATE="$(find . -maxdepth 3 -type f -name "${pkgname%-git}" -perm -111 | head -n1 || true)"
  [[ -n "${BIN_CANDIDATE}" ]] || { echo "Error: could not find built binary '${pkgname%-git}'"; exit 1; }

  printf '%s' "${BIN_CANDIDATE}" > .built_binary_path
}

package() {
  cd "${pkgname%-git}"

  # Read binary path detected during build()
  BIN_PATH="$(<.built_binary_path)"
  [[ -x "${BIN_PATH}" ]] || { echo "Error: built binary not executable: ${BIN_PATH}"; exit 1; }

  # Install binary directly to /usr/bin (no wrapper needed)
  install -Dm755 "${BIN_PATH}" "${pkgdir}/usr/bin/${pkgname%-git}"

  # Install assets into /usr/share/pascube/assets
  # The app looks for assets at: <exe_dir>/../share/pascube/assets
  # When exe is in /usr/bin, this resolves to /usr/share/pascube/assets
  install -dm755 "${pkgdir}/usr/share/${pkgname%-git}"
  cp -a assets "${pkgdir}/usr/share/${pkgname%-git}/"

  # ---- Desktop entry ----
  # If data/pascube.desktop exists, normalize Icon and Exec and install it
  if [[ -f "data/pascube.desktop" ]]; then
    sed -E \
      -e 's/^Icon=.*/Icon=pascube/' \
      -e 's/^Exec=.*/Exec=pascube/' \
      "data/pascube.desktop" > "${srcdir}/pascube.desktop"
    install -Dm644 "${srcdir}/pascube.desktop" \
      "${pkgdir}/usr/share/applications/pascube.desktop"
  else
    # Fallback desktop file
    install -Dm644 /dev/stdin "${pkgdir}/usr/share/applications/pascube.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=pasCube
Comment=A simple OpenGL spinning cube written in Pascal
Exec=pascube
Icon=pascube
Terminal=false
Categories=Graphics;Education;Qt;
EOF
  fi

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

  # ---- Shared resources (skybox stays only under /usr/share/pascube) ----
  if [[ -f "skybox.png" ]]; then
    install -Dm644 "skybox.png" "${pkgdir}/usr/share/pascube/skybox.png"
  elif [[ -f "data/skybox.png" ]]; then
    install -Dm644 "data/skybox.png" "${pkgdir}/usr/share/pascube/skybox.png"
  fi

  # License (if present)
  [[ -f LICENSE ]] && install -Dm644 "LICENSE" "${pkgdir}/usr/share/licenses/${pkgname}/LICENSE"
}
