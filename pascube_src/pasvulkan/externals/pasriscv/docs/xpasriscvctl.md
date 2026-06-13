# `Xpasriscvctl` — PasRISCV Emulator Control Extension

**Extension name:** `xpasriscvctl`  
**Version:** 1.0  
**Status:** Non-standard, PasRISCV-specific  
**Privilege level:** Machine (M-mode)  
**ISA string token:** `xpasriscvctl`  

---

## 1. Introduction

The `Xpasriscvctl` extension defines a single machine-mode read/write Control and Status Register (CSR), `mpasriscvctl` (address `0x7D0`), which exposes runtime control over PasRISCV-specific emulator features to guest software running at M-mode privilege.

The first defined feature is **per-HART IEEE 754-2008 strict-compliant FPU mode** (`StrictCompliantFPU`). When this mode is active on a given HART, all scalar and vector floating-point operations are executed via a software IEEE 754-2008 compliant implementation (SoftFloat) rather than the host processor's FPU. This guarantees exact compliance with the RISC-V floating-point specification, including correct NaN propagation, denormal handling, rounding modes, and exception flag generation, at the cost of reduced performance.

This extension is intentionally minimal: it occupies one CSR in the vendor-reserved machine-mode range (`0x7C0`–`0x7FF`) and adds no new instructions.

### Rationale

Different guest workloads have different FPU compliance requirements:

- **General-purpose software** (operating systems, applications, games): host-FPU execution is sufficient and provides maximum performance including JIT code generation and hardware acceleration, even if it may not be fully IEEE 754-2008 compliant.
- **Numerically sensitive software** (scientific computing, financial calculations, reproducible builds, compliance test suites): strict IEEE 754-2008 behaviour is required, including exact exception flags and deterministic results across platforms.

The `Xpasriscvctl` extension allows guest firmware or an operating system to select the appropriate mode per HART at runtime, without requiring a full emulator restart or recompilation.

---

## 2. CSR Summary

| CSR Name       | Address | Privilege | Access | Reset Value |
|----------------|---------|-----------|--------|-------------|
| `mpasriscvctl` | `0x7D0` | M-mode    | R/W    | `0x0`       |

---

## 3. CSR Definition: `mpasriscvctl`

**Address:** `0x7D0`  
**Full name:** Machine PasRISCV Control Register  
**Privilege:** Machine-mode only. Any access from S-mode or U-mode raises an `IllegalInstruction` exception.

### 3.1 Bit Fields

```
 63                              3   2        1          0
┌───────────────────────────────────┬──────────┬──────────┐
│             WPRI (reserved, 0)    │ BROADCAST│  SFPU    │
└───────────────────────────────────┴──────────┴──────────┘
```

| Bit | Name        | Access | Description |
|-----|-------------|--------|-------------|
| 0   | `SFPU`      | R/W    | **StrictCompliantFPU** — When `1`, all FP operations on this HART use the software IEEE 754-2008 compliant soft-float implementation. When `0`, the host FPU is used and JIT host native code generation may be employed for maximum performance, but with potentially non-compliant behaviour (e.g., flush-to-zero for denormals, differing NaN payloads). |
| 1   | `BROADCAST` | W-only | **Broadcast** — Write-only control bit. When `1` on a write, the new value of `SFPU` (bit 0) is propagated atomically to all HARTs in the machine. Always reads as `0`. |
| 63:2 | —          | WPRI   | Reserved. Must be written as zero, reads as zero. |

### 3.2 Reset Behaviour

On reset, `mpasriscvctl` is `0x0`: `SFPU=0` (host FPU), `BROADCAST=0`. The emulator may be started with `SFPU=1` pre-set on all HARTs via the `-strictcompliantfpu` command-line option, in which case the reset value reads as `0x1`.

### 3.3 WARL Behaviour

Bits 63:2 are WARL (Write Any, Read Legal) and always return `0`. Bit 1 (`BROADCAST`) always reads `0` regardless of what was written. Only bit 0 (`SFPU`) is persistent and readable.

---

## 4. Functional Description

### 4.1 StrictCompliantFPU Mode (SFPU)

When `SFPU=1` on a HART, every scalar and vector floating-point instruction executed by that HART is handled by a software IEEE 754-2008 compliant implementation. This affects:

- All scalar FP instructions: `fadd`, `fsub`, `fmul`, `fdiv`, `fsqrt`, `fmadd`, `fmsub`, `fnmadd`, `fnmsub`, `fmin`, `fmax`, `fcmp`, `fcvt`, `fmv`
- All vector FP instructions: `vfadd`, `vfsub`, `vfmul`, `vfdiv`, `vfsqrt`, `vfmadd` (and variants), `vfmin`, `vfmax`, `vmfeq`, `vmflt`, `vmfle`, `vmfne`, `vmfgt`, `vmfge`, `vfwadd`, `vfwsub`, `vfwmul`, `vfwmacc` (and widening variants), `vfredusum`, `vfredosum`, `vfredmin`, `vfredmax`

Instructions that do not perform arithmetic (e.g., `vfsgnj`, `vfmv`, `vfmerge`, `vfclass`, `vfslide1up`, `vfslide1down`, `vfcvt.*`) are unaffected by this mode.

When `SFPU=0`, all FP instructions use the host processor's FPU and are subject to host-FPU behaviour, which may not be fully IEEE 754-2008 compliant (e.g., flush-to-zero for denormals, differing NaN payloads).

### 4.2 Broadcast Semantics

Writing `mpasriscvctl` with `BROADCAST=1` sets `SFPU` on the writing HART **and** propagates the new `SFPU` value to all other HARTs in the machine. This allows a single `csrw` from the boot HART to apply a consistent FPU policy globally.

The broadcast is performed synchronously within the CSR write. No inter-HART synchronisation fences are required by the writer; however, other HARTs will observe the updated value no later than their next FP instruction execution.

### 4.3 Per-HART Independence

Without `BROADCAST`, each HART maintains an independent `SFPU` value. Mixed configurations are valid (e.g., one HART in strict mode, others in host-FPU mode), which may be useful for isolation or testing purposes.

---

## 5. Discovery

Guest software detects `Xpasriscvctl` support via the ISA string. In the device tree, the CPU node's `riscv,isa` or `riscv,isa-extensions` property includes the token `xpasriscvctl`:

```
cpu@0 {
    compatible = "riscv";
    riscv,isa = "rv64imafdc_zicsr_zifencei_..._xpasriscvctl";
    riscv,isa-extensions = "...", "xpasriscvctl";
};
```

Software should probe for the extension before accessing `mpasriscvctl`. On implementations that do not support this extension, a `csrr`/`csrw` to `0x7D0` will raise `IllegalInstruction`.

---

## 6. Programming Examples

### 6.1 Enable StrictCompliantFPU on all HARTs (global)

```asm
/* Enable SFPU on all HARTs (BROADCAST=1, SFPU=1 → value=3) */
li   a0, 3
csrw 0x7d0, a0
```

### 6.2 Disable StrictCompliantFPU on all HARTs (global)

```asm
/* Disable SFPU on all HARTs (BROADCAST=1, SFPU=0 → value=2) */
li   a0, 2
csrw 0x7d0, a0
```

### 6.3 Enable StrictCompliantFPU on this HART only

```asm
/* Set SFPU=1 on this HART only */
csrsi 0x7d0, 1
```

### 6.4 Disable StrictCompliantFPU on this HART only

```asm
/* Clear SFPU on this HART only */
csrci 0x7d0, 1
```

### 6.5 Read current SFPU state

```asm
/* Read SFPU state into a0; bit 0 = StrictCompliantFPU */
csrr  a0, 0x7d0
andi  a0, a0, 1
```

### 6.6 Save and restore

```asm
/* Save */
csrr  s0, 0x7d0

/* Enable strict FPU for sensitive computation */
csrsi 0x7d0, 1
/* ... floating-point work ... */

/* Restore previous state */
csrw  0x7d0, s0
```

---

## 7. Interaction with Other Extensions

| Extension | Interaction |
|-----------|-------------|
| F, D, Q   | `SFPU=1` replaces host-FPU scalar operations with SoftFloat. All rounding modes (`frm`) and exception flags (`fflags`) are handled correctly by the software implementation. |
| Zfh / Zvfh | Half-precision (F16) operations are also covered by the software implementation when `SFPU=1`. |
| V (Vector) | All vector FP instructions listed in §4.1 are handled by per-element SoftFloat loops when `SFPU=1`. |
| Zicsr | Required. `mpasriscvctl` is accessed via standard `csrrw`/`csrrs`/`csrrc` instructions. |
| `-strictcompliantfpu` CLI | Sets `SFPU=1` on all HARTs at machine startup. Guest can override at runtime via `mpasriscvctl`. |

---

## 8. Version History

| Version | Changes |
|---------|---------|
| 1.0     | Initial definition. CSR `mpasriscvctl` at `0x7D0`. Bits: `SFPU` (bit 0), `BROADCAST` (bit 1). |
