## 1. Packaging and Installation Updates

- [x] 1.1 Add `%{_prefix}/lib/bgmod-splash` to `%files` in `packaging/rpm/goverlay.spec`.
- [x] 1.2 Add `rm -f $(DESTDIR)$(prefix)$(datadir)/goverlay/bgmod/bgmod-splash` to `Makefile` `install:` target.
- [x] 1.3 Add `cp -pf /usr/lib/bgmod-splash ./AppDir/lib/bgmod-splash` to `appimage/goverlay-appimage.sh`.

## 2. Verification

- [x] 2.1 Test `make prefix=/tmp/test_install libexecdir=/lib install` and verify `bgmod-splash` exists in `/tmp/test_install/lib/` and does NOT exist in `/tmp/test_install/share/goverlay/bgmod/`.
- [x] 2.2 Run automated logic and GUI test suites (`make test-logic`, `make test-gui`) to verify zero regressions.
