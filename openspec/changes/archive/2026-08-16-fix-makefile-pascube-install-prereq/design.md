## Context

Currently in `Makefile`:
```makefile
all: goverlay start_goverlay.sh bgmod bgmod-uninstaller pascube_bin

pascube_bin:
	lazbuild -B pascube_src/pascube.lpi $(LAZBUILDOPTS)
	cp pascube_src/pascube ./pascube

install: goverlay data/goverlay.sh bgmod bgmod-uninstaller
	install -D -m=755 goverlay $(DESTDIR)$(prefix)$(libexecdir)/goverlay
	install -D -m=755 pascube $(DESTDIR)$(prefix)$(libexecdir)/pascube
...
```

Because `install` depends on `goverlay data/goverlay.sh bgmod bgmod-uninstaller` and ignores `pascube`, running `make install` without running `make` first causes `install: cannot stat 'pascube': No such file or directory`.
Additionally, `pascube_bin` was a non-file target, causing `lazbuild -B` to re-execute every time `pascube_bin` was invoked.

## Goals / Non-Goals

**Goals:**
- Make `pascube` a concrete file target in `Makefile` with dependencies on its source tree (`pascube_src/pascube.lpi`, `pascube_src/pascube.lpr`, and `pascube_src/src/*.pas`).
- Update `all:` to depend on `pascube`.
- Update `install:` to depend on `pascube` (along with `goverlay`, `data/goverlay.sh`, `bgmod`, `bgmod-uninstaller`).
- Verify that `make install` works cleanly from a clean tree (e.g. into a temporary DESTDIR).

**Non-Goals:**
- Changing package configurations or binary destination directories.

## Decisions

### 1. File Target for pascube
- **Choice**:
  ```makefile
  pascube: pascube_src/pascube.lpi pascube_src/pascube.lpr $(wildcard pascube_src/src/*.pas)
  	lazbuild -B pascube_src/pascube.lpi $(LAZBUILDOPTS)
  	cp pascube_src/pascube ./pascube
  ```
  And include `pascube` in `all` and `install`.
- **Rationale**: Standard Makefile idiom. Provides dependency tracking and avoids unconditional rebuilds on subsequent `make install` calls.

## Risks / Trade-offs

- None identified.
