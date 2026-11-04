## 1. Shader Modernization

- [x] 1.1 Update `assets/shaders/cube/cube.frag` with Cyber Edge neon borders and Iridescent electrochemical Fresnel reflection for idle mode.
- [x] 1.2 Compile `cube.frag` to `assets/shaders/cube/cube_frag.spv` using `glslangValidator -V`.

## 2. Hardware Specifications Pill Typography & Dimensions

- [x] 2.1 Update `subtitle` scale to 1.30 and expand pill card bounds in `pascube_src/src/UnitPasCubeScreen.pas`.
- [x] 2.2 Recompile PasCube binary using `lazbuild pascube_src/pascube.lpi`.

## 3. Verification

- [x] 3.1 Verify clean compilation of both shader SPIR-V and PasCube executable.
- [x] 3.2 Run PasCube test/launch check and verify appearance.
