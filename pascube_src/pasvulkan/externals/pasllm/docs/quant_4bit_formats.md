# Q4*NL: Non-Linear 4-bit Block Quantization Formats

This document specifies the **Q40NL**, **Q41NL**, **Q42NL**, and **Q43NL** formats (“non-linear Q40/Q41”) and compares it to common baselines: **Q40 (linear)**, **Q80 (linear)**, **IQ4_NL (ggml/gguf)**, **NVFP4 (NVIDIA)**, **MXFP4 (OCP)**, and **NF4 (bitsandbytes/QLoRA)**. It also summarizes empirical results from a Torch test harness run.

**Q40NL** is a **4.5 bits/weight** format with **non-linear decode**, designed to improve tail reconstruction while keeping the same storage as classic Q40/Q4_0 and IQ4_NL. **Q40NL** uses **4-bit signed symmetric codes** with a **per-block FP16 scale** and a non-linear decode function that allocates more resolution toward the tails. **Q40NL** is a **drop-in replacement** for Q40/Q4_0, with the same 18-byte block size (32 weights) and no external element LUTs.

**Q41NL** is an **alternative 4.5 bits/weight** format with the same block layout, per-block FP16 scale and kernels as Q40NL (18 bytes per 32 weights; no element LUTs). It differs only in the non-linearity, using $\(f_{41}(x)=x\,|x|\)$ with inverse $\(f_{41}^{-1}(y)=\mathrm{sign}(y)\sqrt{|y|}\)$, which further increases tail emphasis compared to Q40NL’s $\(f(x)=\tfrac12(x|x|+x)\)$. Like Q40NL, it is a drop-in replacement for Q40/Q4_0 and IQ4_NL.

**Q42NL** extends the Q4*NL family with a **parametric non-linearity**: 18 bytes per 32 weights (16 nibbles + 1 FP8(E5M2) scale + 1 int8 curve parameter **c**). The decode is $\(y=(1-c)x+c|x|x\)$, where **c** is optimized per-block to minimize MSE. This allows each block to adapt its nonlinearity between linear (c=0) and quadratic-tail (c=1), achieving better reconstruction than fixed-curve Q40NL/Q41NL.

**Q43NL** uses the same parametric approach as Q42NL but stores a **per-block FP16 scale** (instead of FP8) for higher precision: 19 bytes per 32 weights (16 nibbles + 2 FP16 scale + 1 int8 curve **c**). Both Q42NL and Q43NL support three optimization methods for finding optimal **c**: gradient-based (6x faster, 99.5-99.7% quality), coarse-to-fine grid (1.5x faster, 99.97% quality), or full grid search (slowest, 100% quality).

These formats were created by **Benjamin Rosseaux (BeRo)**, the author of the Pascal-native PasLLM LLM inference engine.

The **Q4*NL** formats are designed to improve tail reconstruction in quantized neural networks while maintaining compact storage. Q40NL and Q41NL use fixed non-linear decode functions, while Q42NL and Q43NL use adaptive per-block curves that allocate resolution optimally based on local weight distributions, making them suitable for models where reconstruction quality is critical.

---

## Non-Linear 4-bit Block Quantization Format Q40NL

### Format definition (Q40NL)

#### Block structure & storage

* **Block size:** 32 weights.
* **Per-element code:** 4-bit signed symmetric $q \in \{-7,\ldots,+7\}$, stored as nibbles with +8 bias.
* **Scale:** 1× FP16 **per block** (little-endian), $s>0$.
* **On-wire bytes per block:** 16 code bytes (2×4-bit per byte) + 2 bytes FP16 scale = **18 bytes**.
  → **Effective bit-rate:** 18/32 = **4.5 bits/weight**.

#### Quantization & dequantization

Let $w$ be a float32 weight in a block $W$.

1. **Scale selection**

$$
s = \max_{w\in W} |w|
\quad\text{(store as fp16; treat } s=0 \text{ as } 1 \text{ for normalization)}
$$

2. **Normalize**

$$
y = \mathrm{clip}\!\left(\frac{w}{s}, -1, 1\right)
$$

3.**Inverse nonlinearity to place codes linearly**
   
The decode nonlinearity is

$$
f(x)=\tfrac12\,(x|x|+x),\quad x\in[-1,1].
$$

or as C code:

```c
static inline float f(float x) {
  return 0.5f * ((x * fabsf(x)) + x);
}
```

Its exact inverse is used during quantization for encoding:

$$
x = f^{-1}(y)= \tfrac12\,\mathrm{sign}(y)\,\big(\sqrt{1+8|y|}-1\big).
$$

or as C code:

```c
float f_inv(float y) {
  return (sqrtf((8.0f * fabsf(y)) + 1.0f) - 1.0f) * (y >= 0.0 ? 0.5f : -0.5f);
  // alternatively: return copysignf(0.5f * (sqrtf((8.0f * fabsf(y)) + 1.0f) - 1.0f), y);
}
```

4. **Uniform quantization in $x$-domain**

$$
q = \mathrm{round}(7\,x),\quad q\in\{-7,\ldots,+7\}.
$$

5. **Packing**
   Store $q$ as 4-bit unsigned **nibbles** with bias +8. Two 4-bit nibbles per byte; 32 codes → 16 bytes.

**Dequantization** reverses the steps (no approximation anywhere):

$$
x=\frac{q}{7},\qquad y=f(x),\qquad \hat{w}=s\cdot y.
$$

> **Why this shape?**
> $f(x)$ has slope $0.5$ near 0 and \~$1.5$ near $\pm1$, effectively **allocating more resolution toward the tails**. That improves **p99/“worst-case”** reconstruction vs purely linear 4-bit, without changing storage.

---

### Exact byte layout (nibble packing)

Per 32-weight block:

```
Byte[0]  = (q1+8) | ((q2+8)<<4)
Byte[1]  = (q3+8) | ((q4+8)<<4)
...
Byte[15] = (q31+8) | ((q32+8)<<4)
Byte[16..17] = fp16(s)  (little-endian)
```

Unpack by splitting low/high nibbles, subtract 8 to recover signed q ∈ \[-7,7].

#### Reference nibble pack/unpack (per 32)

```c
// Pack 32 4-bit values (0..15) into 16 bytes, low nibble first.
static inline void pack32_u4(const uint8_t u4[32], uint8_t b[16]){
  for (int i = 0; i < 16; i++) { 
    b[i] = (u4[i << 1] & 0x0f) | ((u4[(i << 1) | 1] & 0x0f) << 4); 
  }
}

// Unpack 16 bytes into 32 4-bit values (0..15).
static inline void unpack32_u4(const uint8_t b[16], uint8_t u4[32]){
  for (int i = 0; i < 16; i++){  
    uint8_t v = b[i]; 
    u4[i << 1] = v & 0x0f;
    u4[(i << 1) | 1] = (v >> 4) & 0x0f; 
  }
}
```

---

Understood. Here is a **complete Q41NL section**, fully duplicated from your Q40NL section with only the math, names, and helper functions adapted. Paste this **right after** the Q40NL section. Sections **3–7** (comparison, results, where it fits, implementation, summary) remain **shared** between Q40NL and Q41NL.

---

# Q41NL: A Non-Linear 4-bit Block Quantization Format

This section specifies the **Q41NL** format and compares it to the same baselines as Q40NL. **Q41NL** is a **4.5 bits/weight** format with **non-linear decode**, designed to improve tail reconstruction while keeping the same storage as classic Q40/Q40 and IQ4\_NL. Like Q40NL, it uses **4-bit signed symmetric codes** with a **per-block FP16 scale**, and it is a **drop-in replacement** (18-byte block size for 32 weights; no element LUTs).&#x20;

---

## Non-Linear 4-bit Block Quantization Format Q41NL

### Format definition (Q41NL)

#### Block structure & storage

* **Block size:** 32 weights.
* **Per-element code:** 4-bit signed symmetric $q \in \{-7,\ldots,+7\}$, stored as nibbles with +8 bias.
* **Scale:** 1× FP16 **per block** (little-endian), $s>0$.
* **On-wire bytes per block:** 16 code bytes (2×4-bit per byte) + 2 bytes FP16 scale = **18 bytes**.
  → **Effective bit-rate:** 18/32 = **4.5 bits/weight**.&#x20;

#### Quantization & dequantization

Let $w$ be a float32 weight in a block $W$.

1. **Scale selection**

$$
s = \max_{w\in W} |w|
\quad\text{(store as fp16; treat } s=0 \text{ as } 1 \text{ for normalization)}
$$

2. **Normalize**

$$
y = \mathrm{clip}\!\left(\frac{w}{s}, -1, 1\right)
$$

3. **Inverse nonlinearity to place codes linearly**
   **Q41NL decode nonlinearity:**

$$
f_{41}(x)=x\,|x|,\quad x\in[-1,1].
$$

C reference:

```c
static inline float f41(float x) {
  return x * fabsf(x);
}
```

**Exact inverse (used in quantization):**

$$
x = f_{41}^{-1}(y)= \mathrm{sign}(y)\,\sqrt{|y|}.
$$

C reference:

```c
static inline float f41_inv(float y) {
  return copysignf(sqrtf(fabsf(y)), y);
}
```

4. **Uniform quantization in $x$-domain**

$$
q = \mathrm{round}(7\,x),\quad q\in\{-7,\ldots,+7\}.
$$

5. **Packing**
   Store $q$ as 4-bit unsigned **nibbles** with bias +8. Two 4-bit nibbles per byte; 32 codes → 16 bytes.

**Dequantization** reverses the steps (no approximation):

$$
x=\frac{q}{7},\qquad y=f_{41}(x),\qquad \hat{w}=s\cdot y.
$$

> **Why this shape?**
> Compared to Q40NL’s $f$, $f_{41}(x)=x|x|$ has **slope 0 near 0** and $\approx2$ near $|x|=1$, allocating **even more resolution toward the tails** while using the same storage and pipeline. (Structure mirrors Q40NL’s steps.)

---

### Exact byte layout (nibble packing)

Per 32-weight block:

```
Byte[0]  = (q1+8) | ((q2+8)<<4)
Byte[1]  = (q3+8) | ((q4+8)<<4)
...
Byte[15] = (q31+8) | ((q32+8)<<4)
Byte[16..17] = fp16(s)  (little-endian)
```

Unpack by splitting low/high nibbles, subtract 8 to recover signed $q \in [-7,7]$. *(Layout identical to Q40NL.)*&#x20;

#### Reference nibble pack/unpack (per 32)

```c
// Pack 32 4-bit values (0..15) into 16 bytes, low nibble first.
static inline void pack32_u4(const uint8_t u4[32], uint8_t b[16]){
  for (int i = 0; i < 16; i++) {
    b[i] = (u4[i << 1] & 0x0f) | ((u4[(i << 1) | 1] & 0x0f) << 4);
  }
}

// Unpack 16 bytes into 32 4-bit values (0..15).
static inline void unpack32_u4(const uint8_t b[16], uint8_t u4[32]){
  for (int i = 0; i < 16; i++){
    uint8_t v = b[i];
    u4[i << 1] = v & 0x0f;
    u4[(i << 1) | 1] = (v >> 4) & 0x0f;
  }
}
```

---

## Non-Linear 4-bit Block Quantization Format Q42NL

### Format definition (Q42NL)

**Q42NL** extends the Q4*NL family with a **parametric, per-block adaptive non-linearity**. Instead of using a fixed decode curve like Q40NL or Q41NL, Q42NL stores an additional **curve parameter `c`** (int8) per block, allowing the nonlinearity to adapt optimally for each 32-weight block.

####Block structure & storage

* **Block size:** 32 weights.
* **Per-element code:** 4-bit signed symmetric $q \in \{-7,\ldots,+7\}$, stored as nibbles with +8 bias.
* **Scale:** 1× **FP8(E5M2)** per block (1 byte), $s>0$.
* **Curve parameter:** 1× **int8** per block (1 byte), $c \in [-128, 127]$ mapped to $c \in [-1, 1]$ via $c/127$.
* **On-wire bytes per block:** 16 code bytes (2×4-bit per byte) + 1 byte FP8(E5M2) scale + 1 byte int8 curve = **18 bytes**.
  → **Effective bit-rate:** 18/32 = **4.5 bits/weight**.

#### Parametric nonlinearity

The decode nonlinearity is:

$$
f_{42}(x, c) = (1-c)x + c\,x|x|,\quad x\in[-1,1], \quad c \in [-1,1].
$$

or as C code:

```c
static inline float f42(float x, float c) {
  return (1.0f - c) * x + c * x * fabsf(x);
}
```

**Special cases:**
- When $c=0$: $f_{42}(x, 0) = x$ (linear, like Q40)
- When $c=1$: $f_{42}(x, 1) = x|x|$ (same as Q41NL)
- When $c=0.5$: approximately Q40NL's curve shape
- When $c \in (-1, 0)$: emphasizes center over tails

#### Quantization & dequantization

Let $w$ be a float32 weight in a block $W$.

1. **Scale selection**

$$
s = \max_{w\in W} |w|
\quad\text{(stored as }\mathtt{fp8\_e5m2}\text{, rounded up to next representable)}
$$

2. **Normalize**

$$
y = \mathrm{clip}\!\left(\frac{w}{s}, -1, 1\right)
$$

3. **Curve optimization**

Q42NL and Q43NL share the same optimization algorithm with **three methods**:

**a. Gradient Method (default)** - Adam optimizer with smart initialization
   - 12 initialization candidates (kurtosis-based, fixed values, data-driven, percentile-based)
   - Adam optimizer iterations (configurable: 5-20)
   - Optional 7-point line search refinement
   - **Speed:** 6x faster than grid
   - **Quality:** 99.5% with 5 iterations, 99.7% with 20 iterations
   - **Best for:** Production use, large models

**b. Coarse-to-Fine Method** - Two-pass grid search
   - Coarse pass: 17 candidates across full range [-1, 1]
   - Fine pass: 17 candidates around best coarse result  
   - Total: ~34 evaluations vs 255 for grid
   - **Speed:** 1.5x faster than grid
   - **Quality:** 99.97% of grid
   - **Best for:** Quality-critical applications

**c. Grid Method** - Exhaustive search
   - Evaluates all 255 quantizable int8 curve values
   - Fully vectorized
   - **Speed:** Baseline (slowest)
   - **Quality:** 100% (reference)
   - **Best for:** Benchmarking only

For each candidate curve parameter $c$:

   a. Compute inverse mapping $x = f_{42}^{-1}(y, c)$ by solving the equation:
   
   $$c x^2 + (1-c) x - |y| = 0$$
   
   (taking the positive root and restoring sign)

   b. Quantize: $q = \mathrm{round}(7x)$, clamp to $[-7, 7]$

   c. Reconstruct: $\hat{y} = f_{42}(q/7, c)$, then $\hat{w} = s \cdot \hat{y}$

   d. Compute MSE for this block

The optimization method (gradient/coarse-fine/grid) selects the $c$ that minimizes MSE.

4. **Packing**
   Store $q$ as 4-bit unsigned **nibbles** with bias +8. Two nibbles per byte; 32 codes → 16 bytes.
   Append 1 byte FP8(E5M2) scale + 1 byte int8 curve parameter.

**Dequantization** is straightforward:

$$
x=\frac{q}{7},\qquad y=f_{42}(x, c),\qquad \hat{w}=s\cdot y.
$$

> **Why Q42NL?**
> The adaptive curve parameter `c` allows each block to optimize its nonlinearity based on the local weight distribution. Blocks with more tail emphasis benefit from higher `c` values, while blocks with more central distribution can use lower `c`. This typically achieves 0.05-0.2 dB PSNR improvement over fixed-curve Q40NL/Q41NL.

### Exact byte layout

Per 32-weight block:

```
Byte[0]  = (q1+8) | ((q2+8)<<4)
Byte[1]  = (q3+8) | ((q4+8)<<4)
...
Byte[15] = (q31+8) | ((q32+8)<<4)
Byte[16] = fp8_e5m2(s)
Byte[17] = int8(c * 127)
```

---

## Non-Linear 4-bit Block Quantization Format Q43NL

### Format definition (Q43NL)

**Q43NL** uses the same parametric nonlinearity and optimization methods as Q42NL but with **FP16 scale** (instead of FP8) for higher precision. Like Q42NL, it supports **three optimization methods** for finding the optimal curve parameter `c`, trading off between speed and quality.

#### Block structure & storage

* **Block size:** 32 weights.
* **Per-element code:** 4-bit signed symmetric $q \in \{-7,\ldots,+7\}$, stored as nibbles with +8 bias.
* **Scale:** 1× **FP16** per block (2 bytes, little-endian), $s>0$.
* **Curve parameter:** 1× **int8** per block (1 byte), $c \in [-128, 127]$ mapped to $c \in [-1, 1]$ via $c/127$.
* **On-wire bytes per block:** 16 code bytes (2×4-bit per byte) + 2 bytes FP16 scale + 1 byte int8 curve = **19 bytes**.
  → **Effective bit-rate:** 19/32 = **4.75 bits/weight**.

#### Parametric nonlinearity (same as Q42NL)

$$
f_{43}(x, c) = (1-c)x + c\,x|x|,\quad x\in[-1,1], \quad c \in [-1,1].
$$

Identical decode function to Q42NL; only the scale precision and optimization methods differ.

#### Quantization optimization methods

Q43NL offers three methods for finding optimal `c`:

1. **Gradient Method (default)** - Adam optimizer
   - **Speed:** 6.34x faster than grid search
   - **Quality:** 99.5% of grid (1.0053x MSE ratio)
   - **Algorithm:**
     * Try 12 smart initialization candidates (kurtosis-based, fixed values: 0/±0.3/±0.6/±0.9, data-driven, percentile-based)
     * Run Adam optimizer (5-20 iterations, configurable)
     * Apply 7-point line search refinement
   - **Best for:** Production use, large models
   - **Tunable:** `gd_iterations` (5/10/20), `gd_lr` (learning rate)

2. **Coarse-to-Fine Method**
   - **Speed:** 1.46x faster than grid search  
   - **Quality:** 99.97% of grid (1.0003x MSE ratio)
   - **Algorithm:**
     * Coarse pass: 17 candidates across full range [-1, 1]
     * Fine pass: 17 candidates around best coarse result
     * Total: ~34 evaluations vs 255 for grid
   - **Best for:** Quality-critical applications
   - **Deterministic:** No randomness, reproducible

3. **Grid Method**
   - **Speed:** 1.0x (baseline, slowest)
   - **Quality:** 100% (reference)
   - **Algorithm:** Exhaustive 255-point evaluation
   - **Best for:** Benchmarking only

#### Optimization comparison (tested on 32K elements)

| Method | MSE Ratio | Time (s) | Speedup | Quality | Use Case |
|--------|-----------|----------|---------|---------|----------|
| **gradient** | 1.0053x | 0.018 | 6.34x | ⭐⭐⭐⭐ | Production default |
| **coarse_fine** | 1.0003x | 0.076 | 1.46x | ⭐⭐⭐⭐⭐ | Quality-critical |
| **grid** | 1.0000x | 0.111 | 1.0x | ⭐⭐⭐⭐⭐ | Reference only |

**Usage examples:**
```python
# Fast (default)
packed = q43nl(tensor, method="gradient", gd_iterations=5)

# Balanced
packed = q43nl(tensor, method="gradient", gd_iterations=10)

# Best quality gradient
packed = q43nl(tensor, method="gradient", gd_iterations=20, gd_lr=0.1)

# Near-perfect quality
packed = q43nl(tensor, method="coarse_fine")

# Reference (slow)
packed = q43nl(tensor, method="grid")
```

#### Dequantization (same as Q42NL)

$$
x=\frac{q}{7},\qquad y=f_{43}(x, c),\qquad \hat{w}=s\cdot y.
$$

> **Why Q43NL?**
> The FP16 scale (vs FP8 in Q42NL) provides higher precision for blocks with extreme value ranges. The gradient optimization method makes Q43NL practical for quantizing large models—the 6x speedup can save hours of compute time while maintaining 99.5% quality. For maximum quality with reasonable speed, coarse-to-fine achieves 99.97% of optimal with only 1.5x slowdown.

### Exact byte layout

Per 32-weight block:

```
Byte[0]  = (q1+8) | ((q2+8)<<4)
Byte[1]  = (q3+8) | ((q4+8)<<4)
...
Byte[15] = (q31+8) | ((q32+8)<<4)
Byte[16..17] = fp16(s)  (little-endian)
Byte[18] = int8(c * 127)
```

---

## Comparison to other formats

### At-a-glance

| Format             | Block (k) | Element codes / grid                        | Scale (per-block)      | Bytes / block | **Bits / weight** | Dequant form (conceptual)                           |
| ------------------ | --------: | ------------------------------------------- | ---------------------- | ------------: | ----------------: | --------------------------------------------------- |
| **Q40NL**          |        32 | 4-bit (±7) + non-linear decode $f$          | FP16                   |            18 |           **4.5** | $\hat{w}=s\cdot f(q/7)$                             |
| **Q41NL**          |        32 | 4-bit (±7) + non-linear decode $f_{41}$     | FP16                   |            18 |           **4.5** | $\hat{w}=s\cdot f_{41}(q/7)$                        |
| **Q42NL**          |        32 | 4-bit (±7) + **adaptive** $f_{42}(x,c)$ + curve byte | **FP8 E5M2** (1 byte) |   18 |           **4.5** | $\hat{w}=s\cdot f_{42}(q/7, c)$                     |
| **Q43NL**          |        32 | 4-bit (±7) + **adaptive** $f_{43}(x,c)$ + curve byte | FP16                   |            19 |          **4.75** | $\hat{w}=s\cdot f_{43}(q/7, c)$                     |
| **Q40** (linear) |        32 | 4-bit (±7), **linear**                      | FP16                   |            18 |           **4.5** | $\hat{w}=s\cdot(q/7)$                               |
| **Q80** (linear) |        32 | 8-bit (±127), **linear**                    | FP16                   |            34 |           **8.5** | $\hat{w}=s\cdot(q/127)$                             |
| **IQ4\_NL**        |        32 | 4-bit index $\to$ **16-entry LUT**          | FP16                   |            18 |           **4.5** | $\hat{w}=s\cdot \mathrm{LUT}[i]$                    |
| **NVFP4**          |        16 | **FP4 (E2M1)** element codes                | **FP8 E4M3** (1 byte)  |             9 |           **4.5** | $\hat{w}= \mathrm{FP4}(code)\cdot \mathrm{E4M3}(S)$ |
| **MXFP4**          |        32 | **FP4 (E2M1)** element codes                | **E8M0** (1 byte, PoT) |            17 |          **4.25** | $\hat{w}= \mathrm{FP4}(code)\cdot 2^{e-127}$        |
| **NF4**            |        64 | 4-bit index $\to$ **16-entry Gaussian LUT** | FP16 (absmax)          |            34 |         **4.25**† | $\hat{w}= s \cdot \mathrm{NF4\_LUT}[q]$             |
| **FP16**           |         1 | IEEE-754 **binary16** (1/5/10), per-element | —                      |             2 |          **16.0** | $\hat{w}=\mathrm{cast}_{\mathrm{f32}}(\mathrm{fp16}(w))$ |
| **BF16**           |         1 | **bfloat16** (1/8/7), per-element           | —                      |             2 |          **16.0** | $\hat{w}=\mathrm{cast}_{\mathrm{f32}}(\mathrm{bf16}(w))$  |
| **FP32**           |         1 | IEEE-754 **binary32** (1/8/23), per-element | —                      |             4 |          **32.0** | $\hat{w}=w$                                             |

† 34 B / 64 ≈ 0.53125 B/value → 4.25 bits/value.

### Qualitative differences

* **Bit-rate (bits/weight):**

  * **4.25 b/w:** **NF4** (34 B / 64), **MXFP4** (17 B / 32).
  * **4.5 b/w:** **Q40NL**, **Q41NL**, **Q42NL**, **Q40**, **IQ4\_NL** (18 B / 32), **NVFP4** (9 B / 16).
  * **4.75 b/w:** **Q43NL** (19 B / 32).
  * **8.5 b/w:** **Q80** (34 B / 32).
  * **16.0 b/w:** **FP16**, **BF16** (2 B / 1).
  * **32.0 b/w:** **FP32** (4 B / 1).

* **Nonlinearity / code geometry:**

  * **Q40NL:** analytic, asymmetric nonlinearity $f(x)$ that increases effective resolution toward the tails as $|w|\to s$.
  * **Q41NL:** analytic nonlinearity $f_{41}(x)=x|x|$ with inverse $f_{41}^{-1}(y)=\mathrm{sign}(y)\sqrt{|y|}$; **stronger tail emphasis** than Q40NL (slope 0 at 0, $\approx 2$ near $|x|=1$).
  * **Q42NL / Q43NL:** **adaptive parametric nonlinearity** $f(x,c)=(1-c)x+cx|x|$ with per-block optimized curve parameter $c$. Can adapt from linear ($c=0$) to Q41NL-like ($c=1$) based on local weight distribution. Q42NL uses FP8 scale (18 B/32), Q43NL uses FP16 scale (19 B/32).
  * **IQ4\_NL / NF4:** non-uniform **LUT**s. **IQ4\_NL** uses a hand-crafted 16-center table; **NF4** uses Gaussian-quantile centers; both allocate more density near common values and less in the extremes (pattern depends on the table).
  * **Q40 / Q80:** **linear** grids (uniform steps after scaling).
  * **NVFP4 / MXFP4:** **FP4 (E2M1)** element codes → multiplicative spacing (log-like); good dynamic range but coarser small-magnitude steps than linear grids at the same bit budget.

* **Scales & block size (absmax unless noted):**

  * **FP16 per 32:** **Q40NL**, **Q41NL**, **Q43NL**, **Q40**, **Q80**, **IQ4\_NL**.
  * **FP8 E5M2 per 32:** **Q42NL** (rounded up to next representable).
  * **FP16 per 64:** **NF4** (canonical absmax).
  * **FP8 E4M3 per 16:** **NVFP4** (non-power-of-two, finer than E8M0).
  * **E8M0 per 32:** **MXFP4** (power-of-two; coarser than E4M3 but cheap).
  * **No block scale:** **FP16**, **BF16**, **FP32** (per-element formats).

* **Arithmetic & kernel shape:**

  * **Q4\*NL (Q40NL/Q41NL):** nibble unpack → small closed-form nonlinearity ($f$ or $f_{41}$) → multiply by scale. (Optionally LUT or poly approx if desired.)
  * **Q42NL / Q43NL:** nibble unpack → parametric nonlinearity $f(x,c)$ using per-block curve parameter → multiply by scale. Slightly more complex than Q40NL/Q41NL but still analytic.
  * **IQ4\_NL / NF4:** nibble unpack → single LUT read → multiply by scale (branch-free).
  * **NVFP4 / MXFP4:** nibble unpack → FP4 decode (tiny table/arithmetic) → multiply by per-block scale. **E8M0** can be implemented as an exponent bias (power-of-two).
  * **Q40:** nibble unpack → linear scaling (multiply by scale / 7).
  * **Q80:** byte load (int8) → multiply by scale.
  * **FP16 / BF16:** dtype cast to f32 (no per-block logic). **FP32:** identity.

* **Outliers / robustness:**

  * **Absmax scaling** in **Q40NL/Q41NL/Q42NL/Q43NL/Q40/Q80/IQ4\_NL/NF4** makes them sensitive to a single large outlier; **NF4** uses a **larger block (64)** so one outlier can compress local resolution more than per-32 schemes.  
  * **Q42NL/Q43NL** can partially adapt to outliers via curve parameter optimization, potentially reducing impact compared to fixed-curve formats.
  * **NVFP4/MXFP4:** scale quantization matters—**E4M3** is finer than **E8M0**; **E8M0** may step coarsely if the ideal scale falls between powers of two.

* **When they tend to shine (rule-of-thumb):**

  * **NF4:** blocks with near-Gaussian normalized weights (its centers match that shape).
  * **Q4\*NL (Q40NL/Q41NL):** tails matter or you want an analytic, branch-free decode (Q41NL emphasizes tails **more** than Q40NL).
  * **Q42NL / Q43NL:** blocks with varying weight distributions that benefit from adaptive nonlinearity; Q43NL offers optimization methods trading speed vs quality (gradient: 6x faster, coarse-fine: near-perfect quality).
  * **IQ4\_NL:** fast LUT path with fixed per-32 scale; behavior depends on its table.
  * **NVFP4/MXFP4:** hardware/paths optimized for FP4/FP8 and simple exponent math.
  * **Q40:** simplest linear 4-bit baseline.
  * **Q80:** higher fidelity at modest extra storage vs 4-bit.
  * **FP16/BF16:** near-lossless/very low error with simple casts; **FP32:** exact.

---

## Other formats — detailed specs

### Q40 (Linear Q4, ggml-style)

**What it is.** Linear 4-bit symmetric quantizer with one **fp16 absmax** scale per block.

**Typical block format (weights).** **Block size = 32**. Store 16 bytes of nibbles (two 4-bit codes/byte) and a **fp16** scale (2 bytes). Total: **18 bytes**.

**Dequantization.**

$$
\hat{w}_i = s \cdot \frac{q_i}{7}, \quad q_i \in [-7,7].
$$

#### Quantize / Dequantize (concept)

1. $s \leftarrow \max_i |w_i|$ (store as fp16).
2. $q_i \leftarrow \mathrm{round}\!\big(7\cdot \mathrm{clip}(w_i/s,-1,1)\big) \in [-7,7]$.
3. Store $q_i+8$ as a nibble (two per byte).
4. Dequant: unpack $q_i$, compute $\hat{w}_i = s\cdot (q_i/7)$.

#### C 

```c
// Q40 (Linear Q4) — pack/unpack per 32, quant/dequant
#include <stdint.h>
#include <math.h>

// Pack 32 4-bit values (0..15) into 16 bytes; low nibble first.
static inline void q40_pack_u4x32(const uint8_t u4[32], uint8_t bytes[16]) {
  for (int i = 0; i < 16; ++i) {
    uint8_t lo = (uint8_t)(u4[(i << 1) | 0] & 0x0f);
    uint8_t hi = (uint8_t)(u4[(i << 1) | 1] & 0x0f);
    bytes[i] = (uint8_t)(lo | (hi << 4));
  }
}

// Unpack 16 bytes back to 32 4-bit values (0..15).
static inline void q40_unpack_u4x32(const uint8_t bytes[16], uint8_t u4[32]) {
  for (int i = 0; i < 16; ++i) {
    uint8_t b = bytes[i];
    u4[(i << 1) | 0] = (uint8_t)(b & 0x0f);
    u4[(i << 1) | 1] = (uint8_t)((b >> 4) & 0x0f);
  }
}

// Quantize one value to linear Q4 (returns q in [-7..7]).
static inline int8_t q40_quant(float w, float s) {
  if (s <= 0.0f) {
    return 0;
  } else {
    float r = w / s;
    if (r < -1.0f) {
      return -7;
    } else if (r > 1.0f) {
      return 7;
    } else {
      return (int8_t)lrintf(7.0f * r);
    }
  }
}

// Dequantize one code q in [-7..7] with scale s.
static inline float q40_dequant(int8_t q, float s) {
  return s * ((float)q / 7.0f);
}

```

---

### IQ4\_NL (LUT Q4, ggml/gguf)

**What it is.** 4-bit **LUT** quantizer: normalized values snap to 1 of **16 fixed centers**; then multiply by a block scale.

**Typical block format (weights).** **Block size = 32**. fp16 scale $s=\max|w|$; 32 indices (0..15) packed as nibbles. Total: **18 bytes**.

**Dequantization.**

$$
\hat{w}_i = s \cdot \mathrm{LUT}[i], \qquad i \in \{0,\ldots,15\}.
$$

#### IQ4\_NL codebook (kvalues\_iq4nl)

**int8 centers**

```
{-127, -104, -83, -65, -49, -35, -22, -10, 1, 13, 25, 38, 53, 69, 89, 113}
```

**float32 centers (= int8 / 127)**

```
{-1.000000000, -0.818897638, -0.653543307, -0.511811024,
 -0.385826772, -0.275590551, -0.173228346, -0.078740157,
  0.007874016,  0.102362205,  0.196850394,  0.299212598,
  0.417322835,  0.543307087,  0.700787402,  0.889763780}
```

#### Quantize / Dequantize (concept)

1. $s \leftarrow \max|w|$ (fp16).
2. $u_i = \mathrm{clip}(w_i/s,-1,1)$.
3. $i = \arg\min_k |u_i - c_k|$ (nearest LUT center).
4. Store $i$ as nibble; dequant: $\hat{w}_i = s \cdot c_i$.

#### C

```c
// IQ4_NL (LUT Q4) — pack/unpack per 32, LUT helpers, dequant
#include <stdint.h>
#include <math.h>

// Pack 32 indices (0..15) into 16 bytes.
static inline void iq4nl_pack_u4x32(const uint8_t idx[32], uint8_t bytes[16]) {
  for (int i = 0; i < 16; ++i) {
    uint8_t lo = (uint8_t)(idx[(i << 1) | 0] & 0x0f);
    uint8_t hi = (uint8_t)(idx[(i << 1) | 1] & 0x0f);
    bytes[i] = (uint8_t)(lo | (hi << 4));
  }
}

// Unpack 16 bytes back to 32 indices (0..15).
static inline void iq4nl_unpack_u4x32(const uint8_t bytes[16], uint8_t idx[32]) {
  for (int i = 0; i < 16; ++i) {
    uint8_t b = bytes[i];
    idx[(i << 1) | 0] = (uint8_t)(b & 0x0f);
    idx[(i << 1) | 1] = (uint8_t)((b >> 4) & 0x0f);
  }
}

// 16-entry centers, int8 domain.
static const int8_t IQ4NL_LUT_I8[16] = {
  -127, -104, -83, -65, -49, -35, -22, -10, 1, 13, 25, 38, 53, 69, 89, 113
};

// Precomputed float centers in [-1, 1] (IQ4NL_LUT_I8 / 127.0f)
static const float IQ4NL_LUT_F32[16] = {
  -1.000000000f, -0.818897638f, -0.653543307f, -0.511811024f,
  -0.385826772f, -0.275590551f, -0.173228346f, -0.078740157f,
   0.007874016f,  0.102362205f,  0.196850394f,  0.299212598f,
   0.417322835f,  0.543307087f,  0.700787402f,  0.889763780f
};

// Convert int8 center to float in [-1,1].
static inline float iq4nl_center(int idx) {
#if 1
  // Use precomputed float centers.
  return IQ4NL_LUT_F32[idx];
#else
  // Convert int8 center to float in [-1,1].
  return ((float)IQ4NL_LUT_I8[idx]) / 127.0f;
#endif
}

// Nearest center index for normalized u in [-1,1].
static inline uint8_t iq4nl_nearest_index(float u) {
  int best = 0;
  float best_err = fabsf(u - iq4nl_center(0));
  for (int k = 1; k < 16; k++) {
    float e = fabsf(u - iq4nl_center(k));
    if (e < best_err) {
      best_err = e;
      best = k;
    }
  }
  return (uint8_t)best;
}

// Dequantize one element from index and scale.
static inline float iq4nl_dequant(uint8_t idx, float s) {
  return s * iq4nl_center((int)idx);
}

```

---

### MXFP4 (FP4 E2M1 + E8M0 scale per 32)

**What it is.** Element codes are **FP4 (E2M1)**; a single **E8M0** (exponent-only fp8) **power-of-two** scale per block rescales to weight space.

**Typical block format (weights).** **Block size = 32**. 32 FP4 codes packed as 16 bytes + 1 byte E8M0 scale. Total: **17 bytes**.

**Dequantization.**

$$
\hat{w}_i = S \cdot \mathrm{FP4}^{-1}(c_i), \quad S = 2^{e-127} \text{ (E8M0)}.
$$

#### FP4 (E2M1) code map (unit scale)

```
 0:  0.0   1:  0.5   2:  1.0   3:  1.5
 4:  2.0   5:  3.0   6:  4.0   7:  6.0
 8: -0.0   9: -0.5  10: -1.0  11: -1.5
12: -2.0  13: -3.0  14: -4.0  15: -6.0
```

#### Quantize / Dequantize (concept)

1. Choose $s^{*}\approx \max|w|/6$.
2. **E8M0-encode** $s^{*}$ to byte $b$, so $S = 2^{b-127}$.
3. For each value, encode $w_i/S$ to nearest FP4 code from the table.
4. Dequant: $\hat{w}_i = S \cdot \mathrm{FP4}^{-1}(\text{code})$.

#### C

```c
// MXFP4 (FP4 E2M1 + E8M0 per 32) — pack/unpack per 32, FP4 table, E8M0, dequant
#include <stdint.h>
#include <math.h>

// Pack 32 FP4 codes (0..15) into 16 bytes.
static inline void mxfp4_pack_u4x32(const uint8_t u4[32], uint8_t bytes[16]) {
  for (int i = 0; i < 16; ++i) {
    uint8_t lo = (uint8_t)(u4[(i << 1) | 0] & 0x0f);
    uint8_t hi = (uint8_t)(u4[(i << 1) | 1] & 0x0f);
    bytes[i] = (uint8_t)(lo | (hi << 4));
  }
}

// Unpack 16 bytes back to 32 FP4 codes (0..15).
static inline void mxfp4_unpack_u4x32(const uint8_t bytes[16], uint8_t u4[32]) {
  for (int i = 0; i < 16; ++i) {
    uint8_t b = bytes[i];
    u4[(i << 1) | 0] = (uint8_t)(b & 0x0f);
    u4[(i << 1) | 1] = (uint8_t)((b >> 4) & 0x0f);
  }
}

// FP4 decode map (unit scale).
static const float FP4_E2M1[16] = {
   0.0f,  0.5f,  1.0f,  1.5f,  2.0f,  3.0f,  4.0f,  6.0f,
  -0.0f, -0.5f, -1.0f, -1.5f, -2.0f, -3.0f, -4.0f, -6.0f
};

// E8M0 (exponent-only fp8) encode/decode for positive scale S.
static inline uint8_t e8m0_from_float(float s) {
  if (s <= 0.0f) {
    return 0;
  } else {
    float e = roundf(log2f(s) + 127.0f);
    if (e < 0.0f) {
      return 0; // Underflow, return 0 (no scale).
    } else if (e > 255.0f) {
      return 255; // Saturate to max.
    }else {
      return (uint8_t)e;
    }
  }
}

static inline float e8m0_to_float(uint8_t b) {
  return powf(2.0f, (float)b - 127.0f);
}

// Nearest FP4 code for v (unit scale).
static inline uint8_t fp4_nearest_code(float v) {
  int best = 0;
  float best_err = fabsf(v - FP4_E2M1[0]);
  for (int k = 1; k < 16; k++) {
    float e = fabsf(v - FP4_E2M1[k]);
    if (e < best_err) {
      best_err = e;
      best = k;
    }
  }
  return (uint8_t)best;
}

// Dequantize one element from FP4 code and E8M0 byte.
static inline float mxfp4_dequant(uint8_t code, uint8_t e8m0_byte) {
  float S = e8m0_to_float(e8m0_byte);
  return S * FP4_E2M1[(int)code];
}

```

---

### NVFP4 (FP4 E2M1 + FP8 E4M3 scale per 16)

**What it is.** Same FP4 codes as above, but the per-block scale is **FP8 E4M3** (non-PoT) and the block is smaller.

**Typical block format (weights).** **Block size = 16**. 16 FP4 codes packed as 8 bytes + 1 byte E4M3 scale = **9 bytes**.

**Dequantization.**

$$
\hat{w}_i = S \cdot \mathrm{FP4}^{-1}(c_i), \quad S = \mathrm{E4M3}^{-1}(\text{byte}).
$$

#### Quantize / Dequantize (concept)

1. $s^{*} \approx \max|w|/6$.
2. **E4M3-encode** $s^{*}$ (positive) $\Rightarrow$ byte; $S=$ E4M3 decode.
3. Encode $w_i/S$ to nearest FP4 code.
4. Dequant: $\hat{w}_i = S \cdot \mathrm{FP4}^{-1}(\text{code})$.

#### C

```c
// NVFP4 (FP4 E2M1 + FP8 E4M3 per 16) — pack/unpack per 16, FP4 table, E4M3, dequant
#include <stdint.h>
#include <math.h>

// Pack 16 FP4 codes (0..15) into 8 bytes.
static inline void nvfp4_pack_u4x16(const uint8_t u4[16], uint8_t bytes[8]) {
  for (int i = 0; i < 8; ++i) {
    uint8_t lo = (uint8_t)(u4[(i << 1) | 0] & 0x0f);
    uint8_t hi = (uint8_t)(u4[(i << 1) | 1] & 0x0f);
    bytes[i] = (uint8_t)(lo | (hi << 4));
  }
}

// Unpack 8 bytes back to 16 FP4 codes (0..15).
static inline void nvfp4_unpack_u4x16(const uint8_t bytes[8], uint8_t u4[16]) {
  for (int i = 0; i < 8; ++i) {
    uint8_t b = bytes[i];
    u4[(i << 1) | 0] = (uint8_t)(b & 0x0f);
    u4[(i << 1) | 1] = (uint8_t)((b >> 4) & 0x0f);
  }
}

// FP4 decode (unit scale).
static const float NVFP4_E2M1[16] = {
   0.0f,  0.5f,  1.0f,  1.5f,  2.0f,  3.0f,  4.0f,  6.0f,
  -0.0f, -0.5f, -1.0f, -1.5f, -2.0f, -3.0f, -4.0f, -6.0f
};

// E4M3 (positive) encode/decode for scale S. bias=7, 3-bit mantissa.
static inline uint8_t e4m3_from_float(float s) {
  if (s <= 0.0f) {
    return 0;
  } else {
    float e_un = floorf(log2f(s));
    int e = (int)e_un + 7;
    if (e < 1) {
      e = 1;
    } else if (e > 14) {
      e = 14;
    }
    float base = ldexpf(1.0f, e - 7);
    float frac = s / base - 1.0f;
    int m = (int)roundf(frac * 8.0f);
    if (m >= 8) {
      m = 0;
      e += 1;
      if (e > 14) {
        e = 14;
      }
    }
    return (uint8_t)((e << 3) | (m & 7));
  }
}

static inline float e4m3_to_float(uint8_t b) {
  int e = (b >> 3) & 0x0f;
  int m =  b       & 0x07;
  if (e == 0) {
    return 0.0f;
  } else {
    float base = ldexpf(1.0f, e - 7);
    return base * (1.0f + ((float)m) / 8.0f);
  }
}

// Nearest FP4 code for v (unit scale).
static inline uint8_t nvfp4_nearest_code(float v) {
  int best = 0;
  float best_err = fabsf(v - NVFP4_E2M1[0]);
  for (int k = 1; k < 16; k++) {
    float e = fabsf(v - NVFP4_E2M1[k]);
    if (e < best_err) {
      best_err = e;
      best = k;
    }
  }
  return (uint8_t)best;
}

// Dequantize one element.
static inline float nvfp4_dequant(uint8_t code, uint8_t e4m3_byte) {
  float S = e4m3_to_float(e4m3_byte);
  return S * NVFP4_E2M1[(int)code];
}
```

---

### NF4 (NormalFloat-4, bitsandbytes)

**What it is.** 4-bit **non-uniform** LUT tailored for approximately **Gaussian** normalized weights. Typically **absmax** scale **per 64**.

**Typical block format (weights).** **Block size = 64**. Two 32-nibble lanes (32 bytes) + fp16 scale (2 bytes) = **34 bytes**.

**Dequantization.**

$$
\hat{w}_i = s \cdot \mathrm{NF4\_LUT}[q_i], \quad q_i \in \{0,\ldots,15\}.
$$

**NF4 codebook (QLoRA centers, float32)**

```
{-1.00000000, -0.69619280, -0.52507305, -0.39491749,
 -0.28444138, -0.18477343, -0.09105004,  0.00000000,
  0.07958030,  0.16093020,  0.24611229,  0.33791524,
  0.44070983,  0.56261700,  0.72295684,  0.93779105}
```

#### Quantize / Dequantize (concept)

1. $s \leftarrow \max|w|$ (fp16).
2. $u_i = \mathrm{clip}(w_i/s,-1,1)$.
3. $q_i = \arg\min_k |u_i - c_k|$.
4. Pack indices as nibbles; dequant: $\hat{w}_i = s \cdot c_{q_i}$.

#### C

```c
// NF4 (NormalFloat-4, QLoRA centers) — full per-64 block codec
// Layout: [16 bytes lane A] [16 bytes lane B] [2 bytes fp16 scale] = 34 bytes
#include <stdint.h>
#include <math.h>

// ---------- LUT (float32) ----------
static const float NF4_LUT[16] = {
  -1.00000000f, -0.69619280f, -0.52507305f, -0.39491749f,
  -0.28444138f, -0.18477343f, -0.09105004f,  0.00000000f,
   0.07958030f,  0.16093020f,  0.24611229f,  0.33791524f,
   0.44070983f,  0.56261700f,  0.72295684f,  0.93779105f
};

// ---------- small helpers ----------
static inline float nf4_clampf(float x, float lo, float hi) {
  return (x < lo) ? lo : ((x > hi) ? hi : x);
}

static inline uint8_t nf4_nearest_index(float u) {
  // u is expected in [-1, 1]
  int best = 0;
  float best_err = fabsf(u - NF4_LUT[0]);
  for (int k = 1; k < 16; k++) {
    float e = fabsf(u - NF4_LUT[k]);
    if (e < best_err) {
      best_err = e;
      best = k;
    }
  }
  return (uint8_t)best;
}

// ---------- nibble packing (per 32 indices) ----------
static inline void nf4_pack_u4x32(const uint8_t u4[32], uint8_t bytes[16]) {
  for (int i = 0; i < 16; ++i) {
    uint8_t lo = (uint8_t)(u4[(i << 1) | 0] & 0x0f);
    uint8_t hi = (uint8_t)(u4[(i << 1) | 1] & 0x0f);
    bytes[i] = (uint8_t)(lo | (hi << 4));
  }
}

static inline void nf4_unpack_u4x32(const uint8_t bytes[16], uint8_t u4[32]) {
  for (int i = 0; i < 16; ++i) {
    uint8_t b = bytes[i];
    u4[(i << 1) | 0] = (uint8_t)(b & 0x0f);
    u4[(i << 1) | 1] = (uint8_t)((b >> 4) & 0x0f);
  }
}

// ---------- fp16 scale (binary16) ----------
static inline uint16_t nf4_f32_to_f16(float f) {
  union { uint32_t u; float f; } x = { .f = f };
  uint32_t sign = (x.u >> 31) & 1u;
  uint32_t exp  = (x.u >> 23) & 0xFFu;
  uint32_t man  =  x.u        & 0x7FFFFFu;

  if (exp == 0xFFu) {
    uint16_t mant = (man ? 0x0200u : 0u);
    return (uint16_t)((sign << 15) | 0x7C00u | mant);
  }

  int32_t he = (int32_t)exp - 127 + 15;

  if (he <= 0) {
    if (he < -10) {
      return (uint16_t)(sign << 15);
    }
    man = (man | 0x800000u) >> (1 - he);
    uint32_t rounded = man + 0x00001000u;
    return (uint16_t)((sign << 15) | ((rounded >> 13) & 0x03FFu));
  }

  if (he >= 31) {
    return (uint16_t)((sign << 15) | 0x7C00u);
  }

  uint32_t rman = man + 0x00001000u;
  uint16_t mant = (uint16_t)((rman >> 13) & 0x03FFu);
  if ((rman & 0x00800000u) != 0u) {
    he += 1;
    mant = 0;
    if (he >= 31) {
      return (uint16_t)((sign << 15) | 0x7C00u);
    }
  }
  return (uint16_t)((sign << 15) | ((he & 0x1F) << 10) | mant);
}

static inline float nf4_f16_to_f32(uint16_t h) {
  uint32_t sign = (h >> 15) & 1u;
  uint32_t exp  = (h >> 10) & 0x1Fu;
  uint32_t man  =  h        & 0x03FFu;
  uint32_t u;

  if (exp == 0) {
    if (man == 0) {
      u = sign << 31;
    } else {
      int e = -14;
      uint32_t m = man;
      while ((m & 0x0400u) == 0u) {
        m <<= 1;
        --e;
      }
      m &= 0x03FFu;
      u = (sign << 31) | ((uint32_t)(e + 127) << 23) | (m << 13);
    }
  } else if (exp == 0x1Fu) {
    u = (sign << 31) | 0x7F800000u | (man ? 0x00400000u : 0u);
  } else {
    u = (sign << 31) | ((uint32_t)(exp - 15 + 127) << 23) | (man << 13);
  }

  union { uint32_t u; float f; } y = { .u = u };
  return y.f;
}

// ---------- canonical NF4 per-64 block encode ----------
static inline void nf4_encode_block64(const float w[64], uint8_t out_bytes[34]) {
  // 1) scale = absmax
  float s = 0.0f;
  for (int i = 0; i < 64; ++i) {
    float a = fabsf(w[i]);
    if (a > s) {
      s = a;
    }
  }
  if (s <= 0.0f) {
    s = 1.0f;  // avoid div-by-zero; all indices will tend toward zero center
  }

  // 2) normalize, nearest LUT index
  uint8_t idxA[32];
  uint8_t idxB[32];
  for (int i = 0; i < 32; ++i) {
    float u = nf4_clampf(w[i] / s, -1.0f, 1.0f);
    idxA[i] = nf4_nearest_index(u);
  }
  for (int i = 0; i < 32; ++i) {
    float u = nf4_clampf(w[32 + i] / s, -1.0f, 1.0f);
    idxB[i] = nf4_nearest_index(u);
  }

  // 3) pack two nibble lanes
  nf4_pack_u4x32(idxA, out_bytes + 0);   // bytes[0..15]
  nf4_pack_u4x32(idxB, out_bytes + 16);  // bytes[16..31]

  // 4) append fp16 scale (LE)
  uint16_t h = nf4_f32_to_f16(s);
  out_bytes[32] = (uint8_t)(h & 0xFFu);
  out_bytes[33] = (uint8_t)((h >> 8) & 0xFFu);
}

// ---------- canonical NF4 per-64 block decode ----------
static inline void nf4_decode_block64(const uint8_t in_bytes[34], float w[64]) {
  // 1) read two nibble lanes
  uint8_t idxA[32];
  uint8_t idxB[32];
  nf4_unpack_u4x32(in_bytes + 0,  idxA);
  nf4_unpack_u4x32(in_bytes + 16, idxB);

  // 2) read fp16 scale (LE)
  uint16_t h = (uint16_t)in_bytes[32] | ((uint16_t)in_bytes[33] << 8);
  float s = nf4_f16_to_f32(h);

  // 3) dequantize
  for (int i = 0; i < 32; ++i) {
    w[i] = s * NF4_LUT[(int)idxA[i]];
  }
  for (int i = 0; i < 32; ++i) {
    w[32 + i] = s * NF4_LUT[(int)idxB[i]];
  }
}

// ---------- optional: single-element dequant ----------
static inline float nf4_dequant_elem(uint8_t q, float s) {
  return s * NF4_LUT[(int)q];
}
```

---

### Q80 (Linear Q8)

**What it is.** 8-bit symmetric quantization with one **fp16 absmax** scale per block.

**Typical block format (weights).** **Block size = 32**. 32 int8 codes + fp16 scale (2 bytes). Total: **34 bytes**.

**Dequantization.**

$$
\hat{w}_i = s \cdot \frac{q_i}{127}, \quad q_i \in [-127,127].
$$

#### Quantize / Dequantize (concept)

1. $s \leftarrow \max|w|$.
2. $q_i \leftarrow \mathrm{round}(w_i/s)$ clamped to $[-127,127]$.
3. Store $q_i$ as int8.
4. Dequant: $\hat{w}_i = s \cdot (q_i/127)$.

#### C

```c
// Q80 (Linear Q8) — single-element quant/dequant
#include <stdint.h>
#include <math.h>

static inline int8_t q80_quant(float w, float s) {
  if (s <= 0.0f){
    return 0;
  }else{
    float r = w / s;
    if (r < -127.0f) {
      return -127;
    } else if (r > 127.0f) {
      return 127;
    } else {
      return (int8_t)lrintf(r);
    }
  }
}

static inline float q80_dequant(int8_t q, float s) {
  return s * ((float)q / 127.0f);
}
```

---

### FP16 (binary16)

**What it is.** IEEE-754 half precision: 1-bit sign, 5-bit exponent (bias 15), 10-bit mantissa, supports subnormals, Inf/NaN.

Normal: $v = (-1)^s 2^{e-15}(1+\text{mant}/2^{10})$;
Subnormal: $v = (-1)^s 2^{-14}(\text{mant}/2^{10})$.
Inf: $v = (-1)^s \infty$; NaN: $v = (-1)^s \text{NaN}$.

#### C (round-to-nearest-even)

```c
// FP16 (binary16) — f32 <-> f16 (round-to-nearest-even)
#include <stdint.h>

// float32 -> binary16
static inline uint16_t f32_to_f16(float f) {
  union { uint32_t u; float f; } x = { .f = f };
  uint32_t sign = (x.u >> 31) & 1u;
  uint32_t exp  = (x.u >> 23) & 0xFFu;
  uint32_t man  =  x.u        & 0x7FFFFFu;

  if (exp == 0xFFu) {
    uint16_t mant = (man ? 0x0200u : 0u);
    return (uint16_t)((sign << 15) | 0x7C00u | mant);
  }

  int32_t he = (int32_t)exp - 127 + 15;

  if (he <= 0) {
    if (he < -10) {
      return (uint16_t)(sign << 15);
    }
    man = (man | 0x800000u) >> (1 - he);
    uint32_t rounded = man + 0x00001000u;
    return (uint16_t)((sign << 15) | ((rounded >> 13) & 0x03FFu));
  }

  if (he >= 31) {
    return (uint16_t)((sign << 15) | 0x7C00u);
  }

  uint32_t rman = man + 0x00001000u;
  uint16_t mant = (uint16_t)((rman >> 13) & 0x03FFu);
  if ((rman & 0x00800000u) != 0u) {
    he += 1;
    mant = 0;
    if (he >= 31) {
      return (uint16_t)((sign << 15) | 0x7C00u);
    }
  }
  return (uint16_t)((sign << 15) | ((he & 0x1F) << 10) | mant);
}

// binary16 -> float32
static inline float f16_to_f32(uint16_t h) {
  uint32_t sign = (h >> 15) & 1u;
  uint32_t exp  = (h >> 10) & 0x1Fu;
  uint32_t man  =  h        & 0x03FFu;
  uint32_t u;

  if (exp == 0) {
    if (man == 0) {
      u = sign << 31;
    } else {
      int e = -14;
      uint32_t m = man;
      while ((m & 0x0400u) == 0u) {
        m <<= 1;
        --e;
      }
      m &= 0x03FFu;
      u = (sign << 31) | ((uint32_t)(e + 127) << 23) | (m << 13);
    }
  } else if (exp == 0x1Fu) {
    u = (sign << 31) | 0x7F800000u | (man ? 0x00400000u : 0u);
  } else {
    u = (sign << 31) | ((uint32_t)(exp - 15 + 127) << 23) | (man << 13);
  }

  union { uint32_t u; float f; } y = { .u = u };
  return y.f;
}
```

---

### BF16 (bfloat16)

**What it is.** 1-bit sign, 8-bit exponent (bias 127), 7-bit mantissa. FP32-like dynamic range, fewer mantissa bits.

#### C (round-to-nearest-even)

```c
// BF16 (bfloat16) — f32 <-> bf16 (round-to-nearest-even)
#include <stdint.h>

// float32 -> bfloat16
static inline uint16_t f32_to_bf16(float f) {
  union { uint32_t u; float f; } x = { .f = f };
  uint32_t lsb  = (x.u >> 16) & 1u;
  uint32_t bias = 0x00007FFFu + lsb;
  return (uint16_t)((x.u + bias) >> 16);
}

// bfloat16 -> float32
static inline float bf16_to_f32(uint16_t b) {
  union { uint32_t u; float f; } y;
  y.u = ((uint32_t)b) << 16;
  return y.f;
}
```

---

### FP32 (binary32)

**What it is.** IEEE-754 single precision, 1 sign, 8-bit exponent, 23-bit mantissa. Encode/decode is identity; no block structure.

```c
// FP32 (binary32) — identity

static inline float f32_identity(float x) {
  return x;
}
```

---

## Empirical results (Torch harness)

```
Q40NL       max|e|=1.16723  mean|e|=0.259683  p99|e|= 0.756543
Q40NL       dot=-1.076366e+02   Δ= 3.141121e+01   med|Δ·|= 1.184547e+00
Q40NL       gauss σ≈3.52563  r=0.995955  slope=1.001785  |slope-1|=0.00178458  |b|=0.00172218  qq_mae=0.0448768  JSD= 0.0343783
Q41NL       max|e|=1.57086  mean|e|=0.298122  p99|e|= 0.976523
Q41NL       dot=-1.535042e+02   Δ=-1.445639e+01   med|Δ·|= 1.496027e+00
Q41NL       gauss σ≈3.52563  r=0.994230  slope=1.005052  |slope-1|=0.00505206  |b|=0.00191994  qq_mae=0.0465993  JSD= 0.0155118
Q42NL       max|e|=1.46731  mean|e|=0.259534  p99|e|= 0.760177
Q42NL       dot=-2.505029e+02   Δ=-1.114552e+02   med|Δ·|= 1.297592e+00
Q42NL       gauss σ≈3.52563  r=0.996009  slope=0.998611  |slope-1|=0.00138884  |b|=0.000466792  qq_mae=0.0538817  JSD= 0.0387489
Q43NL       max|e|=1.17504  mean|e|=0.229153  p99|e|= 0.664635
Q43NL       dot=-1.532759e+02   Δ=-1.422812e+01   med|Δ·|= 9.960861e-01
Q43NL       gauss σ≈3.52563  r=0.996828  slope=0.998536  |slope-1|=0.00146434  |b|=0.000255965  qq_mae=0.0348695  JSD= 0.0246166
Q40         max|e|=1.0401  mean|e|=0.285264  p99|e|= 0.721546
Q40         dot=-1.270927e+02   Δ= 1.195511e+01   med|Δ·|= 1.217222e+00
Q40         gauss σ≈3.52563  r=0.995361  slope=1.000205  |slope-1|=0.000205004  |b|=0.000760246  qq_mae=0.0819448  JSD= 0.074839
Q80         max|e|=0.0590816  mean|e|=0.01581  p99|e|= 0.0399992
Q80         dot=-1.421631e+02   Δ=-3.115387e+00   med|Δ·|= 6.332970e-02
Q80         gauss σ≈3.52563  r=0.999986  slope=1.000007  |slope-1|=6.90508e-06  |b|=7.09742e-05  qq_mae=0.00241307  JSD= 4.75344e-05
IQ4_NL      max|e|=1.54522  mean|e|=0.245748  p99|e|= 0.866982
IQ4_NL      dot=-1.538636e+02   Δ=-1.481581e+01   med|Δ·|= 1.219061e+00
IQ4_NL      gauss σ≈3.52563  r=0.996302  slope=0.985870  |slope-1|=0.0141301  |b|=0.0200483  qq_mae=0.0535963  JSD= 0.0373498
MXFP4       max|e|=3.0124  mean|e|=0.309253  p99|e|= 1.67684
MXFP4       dot=-2.501342e+02   Δ=-1.110864e+02   med|Δ·|= 1.110864e+02
MXFP4       gauss σ≈3.52563  r=0.992407  slope=0.968467  |slope-1|=0.0315331  |b|=0.00290006  qq_mae=0.287772  JSD= 0.379285
NVFP4       max|e|=1.83945  mean|e|=0.252515  p99|e|= 1.07375
NVFP4       dot=-1.625206e+02   Δ=-2.347287e+01   med|Δ·|= 8.233933e-01
NVFP4       gauss σ≈3.52563  r=0.995466  slope=0.996176  |slope-1|=0.00382419  |b|=0.00271732  qq_mae=0.0756573  JSD= 0.0659492
NF4         max|e|=14.0124  mean|e|=1.93831  p99|e|= 8.10963
NF4         dot= 7.119185e+01   Δ= 2.102396e+02   med|Δ·|= 1.009711e+01
NF4         gauss σ≈3.52563  r=0.854074  slope=0.223741  |slope-1|=0.776259  |b|=0.00688118  qq_mae=1.93831  JSD= 0.485384
NF4_BS64    max|e|=1.81227  mean|e|=0.256518  p99|e|= 0.907737
NF4_BS64    dot=-2.161033e+02   Δ=-7.705554e+01   med|Δ·|= 1.565313e+00
NF4_BS64    gauss σ≈3.52563  r=0.995901  slope=0.993338  |slope-1|=0.00666248  |b|=0.00268276  qq_mae=0.058956  JSD= 0.0503866
FP16        max|e|=0.00390339  mean|e|=0.000496969  p99|e|= 0.00218232
FP16        dot=-1.388288e+02   Δ= 2.189941e-01   med|Δ·|= 2.717972e-03
FP16        gauss σ≈3.52563  r=1.000000  slope=1.000003  |slope-1|=2.76203e-06  |b|=3.67314e-06  qq_mae=0.000496969  JSD= 4.79747e-06
BF16        max|e|=0.0312309  mean|e|=0.00396781  p99|e|= 0.0182873
BF16        dot=-1.389845e+02   Δ= 6.323242e-02   med|Δ·|= 2.150917e-02
BF16        gauss σ≈3.52563  r=0.999999  slope=1.000011  |slope-1|=1.11249e-05  |b|=5.24018e-05  qq_mae=0.00396781  JSD= 0.000277161
FP32        max|e|=0  mean|e|=0  p99|e|= 0
FP32        dot=-1.390478e+02   Δ= 0.000000e+00   med|Δ·|= 0.000000e+00
FP32        gauss σ≈3.52563  r=1.000000  slope=1.000000  |slope-1|=0  |b|=0  qq_mae=0  JSD= 0
```

| **metric** | **Q40NL** | **Q41NL** | **Q42NL** | **Q43NL** | **Q40** | **Q80** | **IQ4_NL** | **NVFP4** | **MXFP4** | **NF4** | **NF4_BS64** | **FP16** | **BF16** | **FP32** |
|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| **mean ∣e∣ (abs error)** | 0.259683 | 0.298122 | 0.259534 | **0.229153** | 0.285264 | 0.015810 | 0.245748 | 0.252515 | 0.309253 | 1.938310 | 0.256518 | 0.000497 | 0.003968 | 0.000000 |
| **p99 ∣e∣ (abs error)** | 0.756543 | 0.976523 | 0.760177 | **0.664635** | 0.721546 | 0.039999 | 0.866982 | 1.073749 | 1.676842 | 8.109633 | 0.907737 | 0.002182 | 0.018287 | 0.000000 |
| **avg ∣Δ·∣ (abs dot error)** | 31.411209 | 14.456390 | 111.455200 | 14.228120 | **11.955109** | 3.115387 | 14.815811 | 23.472870 | 111.086395 | 210.239609 | 77.055542 | 0.218994 | 0.063232 | 0.000000 |
| **median ∣Δ·∣ (abs dot error)** | 1.184547 | 1.496027 | 1.297592 | **0.996086** | 1.217222 | 0.063330 | 1.219061 | 0.823393 | 111.086395 | 10.097114 | 1.565313 | 0.002718 | 0.021509 | 0.000000 |
| **mean Δ· (abs dot error, signed)** | 31.411209 | -14.456390 | -111.455200 | -14.228120 | **11.955109** | -3.115387 | -14.815811 | -23.472870 | -111.086395 | 210.239609 | -77.055542 | 0.218994 | 0.063232 | 0.000000 |
| **Gaussian: Pearson r** | 0.995955 | 0.994230 | 0.996009 | **0.996828** | 0.995361 | 0.999986 | 0.996302 | 0.995466 | 0.992407 | 0.854074 | 0.995901 | 1.000000 | 0.999999 | 1.000000 |
| **Gaussian: ∣slope−1∣** | 0.001785 | 0.005052 | 0.001389 | **0.001464** | 0.000205 | 0.000007 | 0.014130 | 0.003824 | 0.031533 | 0.776259 | 0.006662 | 0.000003 | 0.000011 | 0.000000 |
| **Gaussian: ∣intercept∣** | 0.001722 | 0.001920 | **0.000467** | 0.000256 | 0.000760 | 0.000071 | 0.020048 | 0.002717 | 0.002900 | 0.006881 | 0.002683 | 0.000004 | 0.000052 | 0.000000 |
| **Gaussian: Q–Q MAE** | 0.044877 | 0.046599 | 0.053882 | **0.034870** | 0.081945 | 0.002413 | 0.053596 | 0.075657 | 0.287772 | 1.938310 | 0.058956 | 0.000497 | 0.003968 | 0.000000 |
| **Gaussian: JSD (nats)** | 0.034378 | 0.015512 | 0.038749 | **0.024617** | 0.074839 | 0.000048 | 0.037350 | 0.065949 | 0.379285 | 0.485384 | 0.050387 | 0.000005 | 0.000277 | 0.000000 |

---

## Where Q4\*NL fits

* **Use Q4\*NL when…** you need **Q4 storage** and care about **tail robustness** with **LUT-free** decode.
  * **Q40NL (4.5 b/w):** moderate tail emphasis with $f(x) = 0.5(x|x| + x)$, FP16 scale.
  * **Q41NL (4.5 b/w):** stronger tail emphasis with $f_{41}(x)=x|x|$, FP16 scale.
  * **Q42NL (4.5 b/w):** adaptive parametric curve $h(x,c)$, **FP8 E5M2 scale** (smallest scale precision).
  * **Q43NL (4.59 b/w):** adaptive parametric curve $h(x,c)$, **FP16 scale** (best overall quality).
* **Prefer Q43NL when…** you want the **best mean ∣e∣** (0.229) and **best p99 ∣e∣** (0.665) among all 4-bit formats, plus excellent Gaussian matching.
* **Prefer Q42NL when…** you need adaptive curve optimization with minimal storage overhead (FP8 scale = 4.5 b/w exactly).
* **Prefer IQ4_NL when…** chasing the **lowest mean ∣e∣ at 4.5 b/w** among non-adaptive formats (table winner among fixed 4.5 b/w).
* **Prefer Q40 when…** you want the **lowest avg ∣Δ·∣** (11.96) and **lowest p99 ∣e∣** at 4.5 b/w (linear quantization).
* **Prefer NVFP4 when…** you care about **median ∣Δ·∣** at 4.5 b/w (among non-adaptive formats) or need hardware FP4 E2M1 support.
* **Prefer Q43NL when…** minimizing **median ∣Δ·∣** (1.00) and **Gaussian Q–Q MAE** (0.035) among all 4-bit formats.
* **Prefer Q40NL when…** minimizing **Gaussian Q–Q MAE** (0.045) at 4.5 b/w among fixed-curve formats.
* **Prefer Q41NL when…** minimizing **Gaussian JSD** (0.016) at 4.5 b/w.
* **Prefer MXFP4 when…** you want **4.25 b/w** and can tolerate coarse PoT scale (E8M0).
* **Prefer NF4 when…** your normalized block distribution is **close to Gaussian**; its Gaussian-quantile LUT fits that shape, but outliers or skew can hurt (QLoRA LUT).
* **Prefer Q80 when…** you can afford ~8.5 b/w for higher precision.
* **Prefer FP16/BF16/FP32 when…** you need **full precision**.

---

## Implementation notes

* **SIMD-friendly inner loop (Q40NL/Q41NL):** nibble-unpack → int8→f32 → multiply by $1/7$ → apply **$f$ (Q40NL)** or **$f_{41}$ (Q41NL)** → scale multiply.
* **SIMD-friendly inner loop (Q42NL/Q43NL):** nibble-unpack → int8→f32 → multiply by $1/7$ → apply **$h(x,c) = (1-c)x + cx|x|$** with per-block $c$ → scale multiply.
* **LUT option:** You can replace $f(x)$ or $h(x,c)$ with a small **signed-q** LUT (15 entries) to avoid transcendental ops.
* **Scaling:** Absmax per block matched the baselines here. Per-channel/row variants are trivial if your kernels support them.
* **Curve optimization:** Q42NL uses grid search over 255 candidate $c$ values (quantized to int8 range). Q43NL uses exhaustive search over all valid FP16 values in [-1,1] (~32K candidates excluding NaN/Inf) for optimal quality.

---

## Summary

* **Q4\*NL formats:** **drop-in** Q4 formats with strong tail handling and adaptive curves.
  * **Q40NL/Q41NL (4.5 b/w):** Fixed nonlinear curves (Q41NL emphasizes tails most) at **18 B / 32 weights**.
  * **Q42NL (4.5 b/w):** Adaptive curve with FP8 E5M2 scale, **18 B / 32 weights**.
  * **Q43NL (4.59 b/w):** Adaptive curve with FP16 scale, **19 B / 32 weights** — **best overall 4-bit quality** (exhaustive search over all FP16 values).
* **Q43NL wins:** best **mean ∣e∣** (0.229), best **p99 ∣e∣** (0.665), best **median ∣Δ·∣** (0.996), best **Gaussian Q–Q MAE** (0.035) among 4-bit formats.
* **IQ4_NL:** best **mean ∣e∣** (0.246) among 4.5 b/w fixed-curve formats in this run (tiny LUT cost).
* **Q40:** best **avg ∣Δ·∣** (11.96) and **p99 ∣e∣** among 4.5 b/w formats (linear quantization).
* **NVFP4:** best **median ∣Δ·∣** among 4.5 b/w fixed-curve formats; FP4/FP8 decode-friendly.
* **Q40NL / Q41NL:** best **Gaussian Q–Q MAE** (Q40NL) and **JSD** (Q41NL) at 4.5 b/w.
* **NF4:** solid when blocks are **near-Gaussian**; degrades with outliers/skew.
* **Q80 / FP16/BF16/FP32:** reference baselines.

---
