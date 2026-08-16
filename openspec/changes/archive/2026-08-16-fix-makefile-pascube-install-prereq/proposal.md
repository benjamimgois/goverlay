## Why

In `Makefile`, `install` copies `pascube` to `$(DESTDIR)$(prefix)$(libexecdir)/pascube`, but `pascube` is omitted from `install:` prerequisites. Furthermore, the pascube build rule is defined under a phony-like target `pascube_bin:` rather than a file target `pascube:`. When executing `make install` on a clean tree (or via `packaging/deb/build-deb.sh`), the install command fails with `install: cannot stat 'pascube': No such file or directory` (as reported in issue #386).

## What Changes

- **Convert `pascube` to a File Target**: In `Makefile`, replace `pascube_bin:` with a concrete file target `pascube:` dependent on its source files (`pascube_src/pascube.lpi`, `pascube_src/pascube.lpr`, and `pascube_src/src/*.pas`).
- **Add `pascube` to `all:` and `install:` Prerequisites**: Include `pascube` in both `all` and `install` target dependency lists so running `make install` on a clean tree compiles `pascube` before attempting to install it.
- **Maintain Incremental Build Behavior**: By making `pascube` a concrete file target, subsequent invocations of `make install` will skip recompiling `pascube` if `./pascube` is already up to date relative to its sources.

## Capabilities

### New Capabilities

*(None)*

### Modified Capabilities

- `build-and-packaging`: Requirements for `Makefile` targets and prerequisites ensuring clean-tree installation support.

## Impact

- `Makefile`: `all` and `install` targets reliably build and install `pascube` on fresh and existing source trees.
- `packaging/deb/build-deb.sh`: Can run `make install` directly without requiring a prior manual `make` step.
