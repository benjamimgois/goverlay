# Torch-only comparison: Q40NL vs IQ4_NL vs MXFP4 vs NVFP4
# - Q40NL   : your non-linear 4-bit (/7), fp16 block scale per 32 (dequant uses y = 0.5*(x*|x|+x))
# - IQ4_NL  : ggml/gguf non-linear LUT (kvalues_iq4nl), fp16 block scale per 32
# - MXFP4   : OCP MX, FP4(E2M1) per element, block size 32, 1-byte E8M0 scale (power-of-two)
# - NVFP4   : NVIDIA, FP4(E2M1) per element, block size 16, 1-byte E4M3 scale (FP8)
#
# Metrics: max/mean/median/99th abs error, and dot(Ŵ, X) vs truth for a random X

import math
import torch
import torch.nn.functional as F

# -------- Core nonlinearity (your Q40NL) --------

def _f_decode(x: torch.Tensor) -> torch.Tensor:
    """y = 0.5 * (x*|x| + x), x in [-1,1]."""
    return 0.5 * (x.abs() * x + x)

def _f_inv(y: torch.Tensor) -> torch.Tensor:
    """x = 0.5 * sign(y) * (sqrt(1 + 8*|y|) - 1)."""
    ay = y.abs()
    return 0.5 * torch.sign(y) * (torch.sqrt(1.0 + 8.0 * ay) - 1.0)

# -------- Q40NL (your format) LUT centers (int8), repeated to 32 entries per block --------

_Q40NL_LUT_INT8 = torch.tensor(
    [-127, -127, -101,  -78,  -57,  -39,  -23,  -10,
        0,    10,   23,   39,   57,   78,  101,  127],
    dtype=torch.int16
)

# -------- IQ4_NL (ggml) LUT centers (int8), repeated to 32 entries per block --------
# Source: ggml/llama.cpp IQ4_NL PR (kvalues_iq4nl)
_IQ4NL_LUT_INT8 = torch.tensor(
    [-127,-104, -83, -65, -49, -35, -22, -10,   1,  13,  25,  38,  53,  69,  89, 113],
    dtype=torch.int16)  # keep in int16 to avoid overflow in ops

def _nearest_lut_index(norm: torch.Tensor, lut_vals: torch.Tensor) -> torch.Tensor:
    """
    Given normalized targets in [-1,1], pick nearest LUT index (0..15) for values in lut_vals/127.
    norm: [G, N]
    lut_vals: [16] int (centers in int8 space)
    """
    # distance to each codebook entry
    # shape: [G, N, 16], but we compute as [1,1,16] broadcast
    targets = (lut_vals.to(norm.device).to(torch.float32) / 127.0).view(1,1,-1)
    diff = (norm.unsqueeze(-1) - targets).abs()
    idx = diff.argmin(dim=-1)  # [G, N]
    return idx.to(torch.uint8)

# -------- FP4 (E2M1) helpers (encode/decode positive set) --------

# Positives representable in E2M1 (including subnormal 0.5)
_FP4_POS = torch.tensor([0.0, 0.5, 1.0, 1.5, 2.0, 3.0, 4.0, 6.0], dtype=torch.float32)

def _fp4_e2m1_encode(vals: torch.Tensor) -> torch.Tensor:
    """
    Encode to 4-bit E2M1. Returns codes in [0..15] with layout: (sign<<3)|(exp<<1)|mant
      exp: 0 => {0, 0.5}, 1 => {1,1.5}, 2 => {2,3}, 3 => {4,6}
    Rounding: nearest (ties to even via standard round-to-nearest-even on the candidates).
    """
    dev = vals.device
    v = vals.to(torch.float32)
    s = (v < 0).to(torch.int8)
    av = v.abs()

    # choose nearest from the positive grid
    pos = _FP4_POS.to(dev)  # [8]
    # broadcast |v| to [*, 8]
    d = (av.unsqueeze(-1) - pos).abs()
    # pick index into _FP4_POS
    k = d.argmin(dim=-1)  # [*], 0..7
    # rebuild (exp, mant) from k
    # mapping table for k -> (exp, mant)
    # k : 0 -> (0,0) -> 0.0
    #     1 -> (0,1) -> 0.5
    #     2 -> (1,0) -> 1.0
    #     3 -> (1,1) -> 1.5
    #     4 -> (2,0) -> 2.0
    #     5 -> (2,1) -> 3.0
    #     6 -> (3,0) -> 4.0
    #     7 -> (3,1) -> 6.0
    exp = torch.clamp((k - 2) // 2 + 1, 0)   # works for k>=2; for k<2 becomes 0
    mant = ((k % 2) & 1)
    exp = torch.where(k < 2, torch.zeros_like(exp), exp)
    mant = torch.where(k == 0, torch.zeros_like(mant), mant)
    # assemble 4-bit code
    code = (s.to(torch.int8) << 3) | (exp.to(torch.int8) << 1) | mant.to(torch.int8)
    return code.to(torch.uint8)

def _fp4_e2m1_decode(codes: torch.Tensor) -> torch.Tensor:
    """
    Decode 4-bit codes (uint8 0..15) to float32.
    """
    c = codes.to(torch.uint8)
    s   = ((c >> 3) & 0x1).to(torch.int32)
    exp = ((c >> 1) & 0x3).to(torch.int32)
    m   = (c & 0x1).to(torch.int32)

    # subnormals / zero
    is_sub = (exp == 0)
    # normal: 2^(exp-1) * (1 + m/2)
    base = torch.pow(2.0, (exp - 1).to(torch.float32))
    val = torch.where(is_sub,
                      (m.to(torch.float32) * 0.5),
                      base * (1.0 + 0.5 * m.to(torch.float32)))
    return torch.where(s.bool(), -val, val).to(torch.float32)

# -------- FP8 scales --------

def _e8m0_from_float(scale: torch.Tensor) -> torch.Tensor:
    """Quantize positive float scale to E8M0 byte (round to nearest exponent)."""
    s = torch.clamp(scale.to(torch.float32), min=1e-30)
    e = torch.round(torch.log2(s) + 127.0)
    return torch.clamp(e, 0.0, 255.0).to(torch.uint8)

def _e8m0_to_float(b: torch.Tensor) -> torch.Tensor:
    """Decode E8M0 byte to float scale (2^(e-127))."""
    e = b.to(torch.float32)
    return torch.pow(2.0, e - 127.0)

def _e4m3_from_float(scale: torch.Tensor) -> torch.Tensor:
    """
    Quantize positive float to FP8 E4M3 byte (no subnormals). bias=7.
    Rounds mantissa to 3 bits; clamps to range.
    """
    s = torch.clamp(scale.to(torch.float32), min=0.0)
    zero = (s == 0.0)
    # min normal = 2^-6, max normal approx = 2^7 * 1.75
    s = torch.clamp(s, 2.0**-6, 2.0**7 * 1.75)
    # choose exponent so that 1 <= s/base < 2
    e_unbiased = torch.floor(torch.log2(s))
    e = torch.clamp(e_unbiased + 7.0, 1.0, 14.0)  # 0 reserved for zero
    base = torch.pow(2.0, e - 7.0)
    frac = s / base - 1.0  # in [0, <1.75)
    m = torch.round(frac * 8.0)
    # carry if m==8
    carry = (m >= 8.0)
    m = torch.where(carry, torch.zeros_like(m), m)
    e = torch.where(carry, torch.clamp(e + 1.0, 1.0, 14.0), e)
    byte = ((e.to(torch.int32) & 0xF) << 3) | (m.to(torch.int32) & 0x7)
    byte = torch.where(zero, torch.zeros_like(byte), byte)
    return byte.to(torch.uint8)

def _e4m3_to_float(b: torch.Tensor) -> torch.Tensor:
    """Decode FP8 E4M3 byte to float (sign=0 assumed)."""
    bb = b.to(torch.int32)
    e = (bb >> 3) & 0xF
    m = bb & 0x7
    is_zero = (e == 0)
    base = torch.pow(2.0, (e.to(torch.float32) - 7.0))
    val = base * (1.0 + (m.to(torch.float32) / 8.0))
    return torch.where(is_zero, torch.zeros_like(val), val).to(torch.float32)

# -------- Nibble pack/unpack helpers (exact byte layout) --------

def _pack_nibbles32(u4: torch.Tensor) -> torch.Tensor:
    """[G,32] uint4 (0..15) -> [G,16] uint8, codes 0..31 packed as (low,high)."""
    U = (u4 & 0x0F).to(torch.uint8)
    lo = U[:, 0::2] & 0x0F
    hi = (U[:, 1::2] & 0x0F) << 4
    return (lo | hi)

def _unpack_nibbles32(b16: torch.Tensor) -> torch.Tensor:
    """[G,16] or [16] uint8 -> [G,32] uint4 in 0..15."""
    B = b16 if b16.dim() == 2 else b16.view(1, -1)
    low  = B & 0x0F
    high = (B >> 4) & 0x0F
    return torch.stack((low, high), dim=2).reshape(B.size(0), 32)

def _pack_nibbles16(u4: torch.Tensor) -> torch.Tensor:
    """[G,16] uint4 -> [G,8] uint8."""
    U = (u4 & 0x0F).to(torch.uint8)
    lo = U[:, 0::2] & 0x0F
    hi = (U[:, 1::2] & 0x0F) << 4
    return (lo | hi)

def _unpack_nibbles16(b8: torch.Tensor) -> torch.Tensor:
    """[G,8] or [8] uint8 -> [G,16] uint4."""
    B = b8 if b8.dim() == 2 else b8.view(1, -1)
    low  = B & 0x0F
    high = (B >> 4) & 0x0F
    return torch.stack((low, high), dim=2).reshape(B.size(0), 16)

def _hex_bytes(tu8: torch.Tensor) -> str:
    return " ".join(f"{int(x):02x}" for x in tu8.reshape(-1).tolist())

# -------- Q40NL (your format) --------

def q40nl_quantize(
    t: torch.Tensor,
    ls_rescale: bool = True,          # optional least-squares rescale of the block scale
    eps: float = 1e-12,                # numerical epsilon for denom
    allow_negative_scale: bool = False # keep scales positive unless explicitly allowed
):
    """
    Pack per 32: 16 nibbles + fp16 scale (LE).
    Dequant path: y = f(q/7), out = scale * y

    If ls_rescale=True, after choosing q from tmax-based normalization,
    refine the stored fp16 scale with the least-squares solution:
        scale_ls = (T·y) / (y·y + eps)
    where T is the original float block and y = f(q/7).
    """
    assert t.numel() % 32 == 0
    T = t.to(torch.float32).view(-1, 32)
    tmax = T.abs().amax(dim=1)                        # [G]
    scale = tmax                                      # fp16 stored
    scale_safe = torch.where(tmax > 0, tmax, torch.ones_like(tmax))
    Y = torch.clamp(T / scale_safe[:,None], -1.0, 1.0)
    if True:
        X = _f_inv(Y)
        q = torch.round(7.0 * X).to(torch.int8).clamp_(-7, 7)         # [G,32]

        if ls_rescale:
            y   = _f_decode(q.to(torch.float32) / 7.0)          # [G,32] in [-1,1]
            num = (T * y).sum(dim=1)                            # [G]
            den = (y * y).sum(dim=1) + eps                      # [G]
            s_ls = num / den                                    # [G]
            if not allow_negative_scale:
                # fall back to tmax if LS went non-positive (rare)
                s_ls = torch.where(s_ls > 0, s_ls, scale)
            scale = s_ls
            
        # pack nibbles + fp16 scale (LE), byte layout unchanged
        u4 = ((q + 8) & 0x0F).to(torch.uint8)
        lo = u4[:, 0::2] & 0x0F
        hi = (u4[:, 1::2] & 0x0F) << 4
    else:
        # Pick nibble codes (0..15) by nearest neighbor on the Q40NL grid.
        idx = _nearest_lut_index(Y, _Q40NL_LUT_INT8)       # [G,32] uint8
        # Pack nibbles and append fp16 scale bytes (LE).
        lo = idx[:, 0::2] & 0x0F
        hi = (idx[:, 1::2] & 0x0F) << 4
    qbytes = (lo | hi)                                            # [G,16]
    sbytes = scale.to(torch.float16).view(torch.uint8).view(-1,2) # [G,2]
    return torch.cat([qbytes, sbytes], dim=1).reshape(-1), scale

def q40nl_dequantize(packed: torch.Tensor, out_shape=None):
    P = packed.view(-1,18)
    qbytes, sbytes = P[:,:16], P[:,16:18]
    scale = sbytes.view(torch.float16).to(torch.float32).view(-1)     # [G]
    low  = (qbytes & 0x0F); high = (qbytes >> 4) & 0x0F
    u4 = torch.stack((low, high), dim=2).reshape(-1,32).to(torch.int8)
    q = (u4 - 8).clamp(-7,7).to(torch.float32)
    y = _f_decode(q/7.0)
    out = (scale[:,None] * y).reshape(-1)
    return out.reshape(out_shape) if out_shape is not None else out

# -------- IQ4_NL (ggml/gguf) --------

def iq4_nl_quantize(t: torch.Tensor):
    """
    Per 32: choose fp16 scale = max|t|; quantize normalized values to nearest LUT entry.
    Store 16 nibbles + fp16 scale (LE). Dequant: scale * (lut[idx]/127).
    """
    assert t.numel() % 32 == 0
    T = t.to(torch.float32).view(-1, 32)
    tmax = T.abs().amax(dim=1)
    scale = tmax
    scale_safe = torch.where(tmax > 0, tmax, torch.ones_like(tmax))
    Y = torch.clamp(T / scale_safe[:,None], -1.0, 1.0)             # [G,32] in [-1,1]
    idx = _nearest_lut_index(Y, _IQ4NL_LUT_INT8)                   # [G,32], uint8 0..15
    lo = idx[:, 0::2] & 0x0F
    hi = (idx[:, 1::2] & 0x0F) << 4
    qbytes = (lo | hi)                                             # [G,16]
    sbytes = scale.to(torch.float16).view(torch.uint8).view(-1,2)
    return torch.cat([qbytes, sbytes], dim=1).reshape(-1), scale

def iq4_nl_dequantize(packed: torch.Tensor, out_shape=None):
    P = packed.view(-1,18)
    idx = torch.stack(((P[:,:16] & 0x0F), ((P[:,:16] >> 4) & 0x0F)), dim=2).reshape(-1,32)
    lut = _IQ4NL_LUT_INT8.to(packed.device).to(torch.float32) / 127.0
    y = lut[idx.to(torch.long)]                                     # [G,32]
    scale = P[:,16:18].view(torch.float16).to(torch.float32).view(-1)
    out = (scale[:,None] * y).reshape(-1)
    return out.reshape(out_shape) if out_shape is not None else out

# -------- MXFP4 (k=32, E8M0 scale) --------

def mxfp4_quantize(t: torch.Tensor):
    """
    Per 32: choose E8M0 scale S ~ power-of-two to map values into FP4(E2M1) grid.
    Store: 32×fp4 codes (we keep as uint8 0..15) + 1×uint8 scale byte.
    """
    assert t.numel() % 32 == 0
    T = t.to(torch.float32).view(-1,32)
    tmax = T.abs().amax(dim=1)                             # [G]
    # We aim to map max to ~6.0 (max normal of E2M1)
    ideal = torch.clamp(tmax / 6.0, min=1e-30)
    sb = _e8m0_from_float(ideal)                           # [G] E8M0 byte
    S = _e8m0_to_float(sb)                                 # decoded float scale
    # quantize elements to nearest FP4(E2M1) after dividing by S
    Y = (T / S[:,None])
    codes = _fp4_e2m1_encode(Y)                            # [G,32] uint8
    return codes.reshape(-1), sb

def mxfp4_pack(codes: torch.Tensor, sb: torch.Tensor) -> torch.Tensor:
    """Pack MXFP4 to bytes: 16 nibble bytes + 1 scale byte per block (17 bytes)."""
    G = sb.numel()
    C = codes.view(G,32)
    b16 = _pack_nibbles32(C)
    return torch.cat([b16, sb.view(-1,1)], dim=1).reshape(-1).to(torch.uint8)

def mxfp4_unpack(packed: torch.Tensor):
    """Unpack MXFP4 bytes back to codes+scale."""
    P = packed.view(-1,17)
    b16, sb = P[:,:16], P[:,16]
    codes = _unpack_nibbles32(b16)
    return codes.reshape(-1), sb.contiguous()

def mxfp4_dequantize_packed(packed: torch.Tensor, out_shape=None):
    P = packed.view(-1,17)
    b16, sb = P[:,:16], P[:,16]
    codes = _unpack_nibbles32(b16)                         # [G,32] 0..15
    vals  = _fp4_e2m1_decode(codes)                        # [G,32] float
    S = _e8m0_to_float(sb).to(vals.dtype).view(-1,1)
    out = (vals * S).reshape(-1)
    return out.reshape(out_shape) if out_shape is not None else out

# -------- NVFP4 (k=16, E4M3 scale) --------

def nvfp4_quantize(t: torch.Tensor):
    """
    Per 16: FP4(E2M1) codes + E4M3 scale byte.
    """
    assert t.numel() % 16 == 0
    T = t.to(torch.float32).view(-1,16)
    tmax = T.abs().amax(dim=1)
    ideal = torch.clamp(tmax / 6.0, min=2.0**-6)          # at least min-normal of E4M3
    sb = _e4m3_from_float(ideal)                           # [G] E4M3 byte
    S = _e4m3_to_float(sb)
    codes = _fp4_e2m1_encode(T / S[:,None])                # [G,16] uint8
    return codes.reshape(-1), sb

def nvfp4_pack(codes: torch.Tensor, sb: torch.Tensor) -> torch.Tensor:
    """Pack NVFP4 to bytes: 8 nibble bytes + 1 E4M3 scale byte per block (9 bytes)."""
    G = sb.numel()
    C = codes.view(G,16)
    b8 = _pack_nibbles16(C)
    return torch.cat([b8, sb.view(-1,1)], dim=1).reshape(-1).to(torch.uint8)

def nvfp4_unpack(packed: torch.Tensor):
    """Unpack NVFP4 bytes to codes+scale."""
    P = packed.view(-1,9)
    b8, sb = P[:,:8], P[:,8]
    codes = _unpack_nibbles16(b8)
    return codes.reshape(-1), sb.contiguous()

def nvfp4_dequantize_packed(packed: torch.Tensor, out_shape=None):
    P = packed.view(-1,9)
    b8, sb = P[:,:8], P[:,8]
    codes = _unpack_nibbles16(b8)                          # [G,16]
    vals  = _fp4_e2m1_decode(codes)
    S = _e4m3_to_float(sb).to(vals.dtype).view(-1,1)
    out = (vals * S).reshape(-1)
    return out.reshape(out_shape) if out_shape is not None else out

# -------- Byte dumps --------

def dump_q40nl_block(packed: torch.Tensor, block_idx: int):
    """Pretty-print one Q40NL block: 16 nibble bytes + fp16 scale, and a few decoded samples."""
    P = packed.view(-1, 18)
    G = P.size(0)
    if block_idx < 0:
        block_idx += G
    pb = P[block_idx]                       # [18] uint8
    b16   = pb[:16]                         # 16 nibble bytes
    sbytes= pb[16:18]                       # 2B fp16 (LE)
    scale = sbytes.view(torch.float16).item()

    print(f"\n[Q40NL] block {block_idx}/{G-1}")
    print(f"bytes (16 nibbles + fp16 scale): {_hex_bytes(pb)}")
    print(f"fp16 scale bytes: {_hex_bytes(sbytes)}  => scale={scale:.6g}")

    u4 = _unpack_nibbles32(b16)             # [1,32] uint4
    q  = (u4.to(torch.int8) - 8).clamp(-7, 7)       # signed q in [-7,7]
    x  = q.to(torch.float32) / 7.0
    y  = _f_decode(x)                        # non-linear decoded in [-1,1]
    w  = y * float(scale)                    # dequantized weights

    # show first 8 entries
    print(f"u4[0:8]:  {u4[0,:8].tolist()}")
    print(f"q[0:8]:   {q[0,:8].tolist()}")
    print(f"y[0:8]:   {[float(v) for v in y[0,:8]]}")
    print(f"w[0:8]:   {[float(v) for v in w[0,:8]]}")

def dump_iq4nl_block(packed: torch.Tensor, block_idx: int):
    """Pretty-print one IQ4_NL block: 16 nibble bytes + fp16 scale, LUT values, and samples."""
    P = packed.view(-1, 18)
    G = P.size(0)
    if block_idx < 0:
        block_idx += G
    pb = P[block_idx]                       # [18] uint8
    b16   = pb[:16]
    sbytes= pb[16:18]
    scale = sbytes.view(torch.float16).item()

    print(f"\n[IQ4_NL] block {block_idx}/{G-1}")
    print(f"bytes (16 nibbles + fp16 scale): {_hex_bytes(pb)}")
    print(f"fp16 scale bytes: {_hex_bytes(sbytes)}  => scale={scale:.6g}")

    idx = _unpack_nibbles32(b16)            # [1,32] indices 0..15
    lut = (_IQ4NL_LUT_INT8.to(packed.device).to(torch.float32) / 127.0).view(1, -1)
    y   = lut[0, idx[0].to(torch.long)]     # [32] normalized value from LUT
    w   = y * float(scale)

    print(f"idx[0:8]: {idx[0,:8].tolist()}")
    print(f"lut[0:8]: {[float(v) for v in y[:8]]}")
    print(f"w[0:8]:   {[float(v) for v in w[:8]]}")
    
def dump_mxfp4_block(packed: torch.Tensor, block_idx: int):
    P = packed.view(-1,17)
    G = P.size(0)
    if block_idx < 0: block_idx += G
    pb = P[block_idx]
    b16 = pb[:16]
    sb  = pb[16]
    print(f"\n[MXFP4] block {block_idx}/{G-1}")
    print(f"bytes (16 nibbles + E8M0 scale): {_hex_bytes(pb)}")
    print(f"E8M0 scale byte: {int(sb)}  => S={float(_e8m0_to_float(sb)):.6g}")
    codes = _unpack_nibbles32(b16)
    vals  = _fp4_e2m1_decode(codes)
    print(f"codes[0:8]: {codes[0,:8].tolist()}  vals[0:8]: {[float(x) for x in vals[0,:8]]}")

def dump_nvfp4_block(packed: torch.Tensor, block_idx: int):
    P = packed.view(-1,9)
    G = P.size(0)
    if block_idx < 0: block_idx += G
    pb = P[block_idx]
    b8 = pb[:8]
    sb = pb[8]
    print(f"\n[NVFP4] block {block_idx}/{G-1}")
    print(f"bytes (8 nibbles + E4M3 scale): {_hex_bytes(pb)}")
    print(f"E4M3 scale byte: {int(sb)}  => S={float(_e4m3_to_float(sb)):.6g}")
    codes = _unpack_nibbles16(b8)
    vals  = _fp4_e2m1_decode(codes)
    print(f"codes[0:8]: {codes[0,:8].tolist()}  vals[0:8]: {[float(x) for x in vals[0,:8]]}")

# -------- Evaluation / self-test --------

def _metrics(name, rec, ref):
    diff = (rec - ref).abs()
    print(f"{name:10s}  max|e|={float(diff.max()):.6g}  mean|e|={float(diff.mean()):.6g}  "
          f"p99|e|={float(torch.quantile(diff, 0.99)): .6g}")

def main(device=None):
    if device is None:
        device = "cuda" if torch.cuda.is_available() else "cpu"
    print(f"Device: {device}")
    # torch.manual_seed(12345321)  # for reproducibility

    # build test tensor: random + edgey tails
    G32 = 1024  # groups for 32-block schemes
    T = (torch.randn(G32*32, device=device) * 3.5)  # wider spread
    edges = torch.tensor([0.0, 1e-8, -1e-8, 1.0, -1.0, 6.0, -6.0, 10.0, -10.0,
                          0.5, -0.5, 2.0, -2.0, 3.0, -3.0, 4.0, -4.0], device=device)
    pad = (-edges.numel()) % 32
    if pad: edges = F.pad(edges, (0, pad))
    T = torch.cat([T[:-32], edges], dim=0)  # keep total multiple of 32

    # a random X for dot test
    X = torch.randn_like(T)

    # --- Q40NL ---
    q40_packed, q40_scale = q40nl_quantize(T)
    Q40_rec = q40nl_dequantize(q40_packed, out_shape=T.shape)

    # --- IQ4_NL ---
    iq_packed, iq_scale = iq4_nl_quantize(T)
    IQ_rec = iq4_nl_dequantize(iq_packed, out_shape=T.shape)

    # --- MXFP4 (unpacked -> packed -> dequant packed) ---
    mxfp4_codes, mxfp4_sb = mxfp4_quantize(T)
    mxfp4_packed = mxfp4_pack(mxfp4_codes, mxfp4_sb)
    MX_rec = mxfp4_dequantize_packed(mxfp4_packed, out_shape=T.shape)

    # --- NVFP4 (unpacked -> packed -> dequant packed) ---
    NV_codes, NV_sb = nvfp4_quantize(T.view(-1))  # works for multiple of 16
    nvfp4_packed = nvfp4_pack(NV_codes, NV_sb)
    NV_rec = nvfp4_dequantize_packed(nvfp4_packed, out_shape=T.shape)

    # metrics
    print("\nErrors vs float32 truth:")
    _metrics("Q40NL", Q40_rec, T)
    _metrics("IQ4_NL", IQ_rec, T)
    _metrics("MXFP4", MX_rec, T)
    _metrics("NVFP4", NV_rec, T)

    # dot products
    truth = float((T * X).sum())
    d_q40 = float((Q40_rec * X).sum())
    d_iq  = float((IQ_rec  * X).sum())
    d_mx  = float((MX_rec  * X).sum())
    d_nv  = float((NV_rec  * X).sum())

    def dline(n, v):
        print(f"{n:10s}  dot={v: .6e}   Δ={v-truth: .6e}")
    print("\nDot(T̂, X) vs truth:")
    print(f"{'truth':10s}  dot={truth: .6e}")
    dline("Q40NL", d_q40)
    dline("IQ4_NL", d_iq)
    dline("MXFP4", d_mx)
    dline("NVFP4", d_nv)

    # byte-level dumps for Q40NL/IQ4_NL/MXFP4/NVFP4 (first & last blocks)
    if False:  # set to True to enable dumps
        dump_q40nl_block(q40_packed, 0)
        dump_q40nl_block(q40_packed, -1)
        dump_iq4nl_block(iq_packed, 0)
        dump_iq4nl_block(iq_packed, -1)    
        dump_mxfp4_block(mxfp4_packed, 0)
        dump_mxfp4_block(mxfp4_packed, -1)
        dump_nvfp4_block(nvfp4_packed, 0)
        dump_nvfp4_block(nvfp4_packed, -1)

# run
if __name__ == "__main__":
    main()
