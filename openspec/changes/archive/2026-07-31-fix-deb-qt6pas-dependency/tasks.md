## 1. Debian Package Control & Build Script

- [x] 1.1 Remove `(>= 6.2.0)` minimum version constraint for `libqt6pas6` in `packaging/deb/control`.
- [x] 1.2 Update sed substitution in `packaging/deb/build-deb.sh` to match `libqt6pas6` without version restriction.

## 2. Verification

- [x] 2.1 Test building a local `.deb` package using `packaging/deb/build-deb.sh 1.8.10` and inspect `DEBIAN/control` inside the generated package.
