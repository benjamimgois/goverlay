## Why

The `pascube_src/pasvulkan/externals/` directory contains several libraries that are not compiled or used by `pascube`, occupying significant disk space (~11.3MB out of 14MB). Removing these unused external dependencies simplifies maintenance and significantly reduces the size of the repository.

## What Changes

- Remove unused external directories from `pascube_src/pasvulkan/externals/`:
  - `kraft/`
  - `pasgltf/`
  - `rnl/`
  - `pasterm/`
  - `pinja/`

## Capabilities

### New Capabilities
- `pasvulkan-externals-cleanup`: Remove unused third-party/external library source code directories from the pasvulkan workspace.

### Modified Capabilities

## Impact

- `pascube_src/pasvulkan/externals/kraft/` will be deleted.
- `pascube_src/pasvulkan/externals/pasgltf/` will be deleted.
- `pascube_src/pasvulkan/externals/rnl/` will be deleted.
- `pascube_src/pasvulkan/externals/pasterm/` will be deleted.
- `pascube_src/pasvulkan/externals/pinja/` will be deleted.
