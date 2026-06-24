## 1. Implement resolution restore in NextPhase

- [x] 1.1 In `UnitPasCubeScreen.pas` `NextPhase`, inside `bpGPU_1080p:` case (line 2229), add `if fGPU360pFallback then begin fRenderWidth := 1920; fRenderHeight := 1080; end;` before `fBenchmarkPhase := bpResults`

## 2. Build and verify

- [x] 2.1 Compile pascube with `make`
- [x] 2.2 Verify code: resolution restore runs only when fallback was active, aligns with score downscaling at line 2274
