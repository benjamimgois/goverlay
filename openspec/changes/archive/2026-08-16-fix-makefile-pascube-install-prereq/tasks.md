## 1. Makefile Targets & Dependency Adjustments

- [x] 1.1 In `Makefile`, replace `pascube_bin` with file target `pascube:` tracking source prerequisites (`pascube_src/pascube.lpi`, `pascube_src/pascube.lpr`, and `$(wildcard pascube_src/src/*.pas)`).
- [x] 1.2 In `Makefile`, update `all:` and `install:` targets to include `pascube` in their prerequisite lists.
- [x] 1.3 In `Makefile`, update `.PHONY:` list to remove `pascube_bin`.

## 2. Verification & Testing

- [x] 2.1 Run `make clean` followed by `make install DESTDIR=/tmp/goverlay_test_install prefix=/usr` and verify that all binaries (including `pascube`) are built and installed without errors.
- [x] 2.2 Run `make install DESTDIR=/tmp/goverlay_test_install prefix=/usr` a second time to verify that `pascube` is not rebuilt needlessly.
- [x] 2.3 Run unit tests with `make test-logic`.
