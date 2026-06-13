#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
bench_quants.py — Compare Q40NL/Q41NL/Q42NL/Q43NL vs (hooks for) llama.cpp IQ4_NL/Q4_K_S
Author: Benjamin Rosseaux (setup consolidated by ChatGPT)
"""

import argparse, math, time
import torch

# ===============================================================
# FP16 (IEEE Float16) + dequant
# ===============================================================

def fp16_quant(t: torch.Tensor) -> torch.Tensor:
    """Simple FP16 (IEEE 754 half-precision) quantization - just cast to float16."""
    return t.to(torch.float16).view(torch.uint8)

def fp16_dequant(packed: torch.Tensor) -> torch.Tensor:
    """Dequantize FP16 back to float32."""
    # Reinterpret bytes as float16
    return packed.view(torch.float16).to(torch.float32)

# ===============================================================
# BF16 (BrainFloat16) + dequant
# ===============================================================

def bf16_quant(t: torch.Tensor) -> torch.Tensor:
    """BF16 (BrainFloat16, 16-bit truncated FP32) quantization - just cast to bfloat16."""
    return t.to(torch.bfloat16).view(torch.uint8)

def bf16_dequant(packed: torch.Tensor) -> torch.Tensor:
    """Dequantize BF16 back to float32."""
    # Reinterpret bytes as bfloat16
    return packed.view(torch.bfloat16).to(torch.float32)

# ===============================================================
# FP8 (float8_e5m2) + dequant
# ===============================================================

def fp8_quant(t: torch.Tensor) -> torch.Tensor:
    """Simple FP8 E5M2 quantization - just cast to float8_e5m2."""
    return t.to(torch.float8_e5m2).view(torch.uint8)

def fp8_dequant(packed: torch.Tensor) -> torch.Tensor:
    """Dequantize FP8 E5M2 back to float32."""
    return packed.view(torch.float8_e5m2).to(torch.float32)

# ===============================================================
# Q80 quantization: 32 values -> 34 bytes (32×int8 + 1×fp16 scale)
# ===============================================================

def q80(t: torch.Tensor) -> torch.Tensor:
    """
    Q80: 32 values get quantized to 34 bytes, 32×int8 + 1×fp16 scale (LE)
    """
    group_size = 32
    assert t.numel() % group_size == 0
    T = t.to(torch.float32).view(-1, group_size)
    # find the max in each group
    tmax = T.abs().max(dim=1).values
    # calculate the scaling factor such that float = quant * scale
    scale = tmax / 127.0
    # Convert scale to float16
    scale16 = scale.to(torch.float16)
    # Convert scale back to float32 for quantization
    scale = scale16.to(torch.float32)
    # scale into range [-127, 127]
    quant = T / scale[:,None]
    # round to nearest integer
    int8val = torch.round(quant).to(torch.int8)
    
    # Pack data in 34-byte chunks: 32×int8 + 1×fp16 scale (LE)
    qbytes = int8val.contiguous().view(torch.uint8).reshape(-1, group_size)  # [G,32]
    s16_i  = scale16.contiguous().view(torch.uint16).to(torch.int32)         # [G]
    lo     = (s16_i & 0x00FF).to(torch.uint8).unsqueeze(1)                   # [G,1]
    hi     = ((s16_i >> 8) & 0x00FF).to(torch.uint8).unsqueeze(1)            # [G,1]
    sbytes = torch.cat([lo, hi], dim=1)                                      # [G,2]
    packed = torch.cat([qbytes, sbytes], dim=1)                              # [G,34]
    data   = packed.contiguous().reshape(-1).to(torch.uint8)
    return data

def q80_dequant(packed: torch.Tensor) -> torch.Tensor:
    """Dequantize Q80: 34 bytes -> 32 float32 values."""
    G = packed.numel() // 34
    buf = packed.view(G, 34)
    qbytes = buf[:, :32]  # [G,32] uint8
    # Convert uint8 to int8, then to float32
    qbytes_i8 = qbytes.view(torch.int8).view(G, 32).to(torch.float32)  # [G,32]
    # Reconstruct fp16 scale from LE bytes
    sbytes = buf[:, 32:34]
    # Reconstruct uint16 from two uint8 bytes (little endian)
    scale16_u8 = sbytes.reshape(-1)  # [G*2]
    scale16_u16 = scale16_u8.view(torch.uint16)  # Reinterpret bytes as uint16
    scale = scale16_u16.view(torch.float16).to(torch.float32)  # [G]
    out = qbytes_i8 * scale.view(-1, 1)
    return out.view(-1)

# ===============================================================
# Q40 quantization: 32 values -> 18 bytes (16×nibbles + 1×fp16 scale)
# ===============================================================

def q40(t: torch.Tensor) -> torch.Tensor:
    """
    Q40: 32 values get quantized to 18 bytes, 16×uint8 (packed nibbles) + 1×fp16 scale (LE)
    Simple tmax-based quantization without nonlinear mapping.
    """
    group_size = 32
    assert t.numel() % group_size == 0
    T = t.to(torch.float32).view(-1, group_size)
    # find the max in each group
    tmax = T.abs().max(dim=1).values
    # calculate the scaling factor such that float = quant * scale
    scale = tmax / 7.0
    # scale into range [-7, 7]
    quant = T / scale[:,None]
    # round to nearest integer
    int4val = torch.round(quant).to(torch.int8)
    int4val = torch.clamp(int4val, -7, 7)
    
    # Pack int4 values into uint8 using vectorized operations
    # Convert int4 from int8 to uint8, shift to [0, 15] range
    uint4val = ((int4val + 8) & 0x0F).view(-1).to(torch.uint8)
    padded_size = (uint4val.shape[0] + 1) // 2 * 2
    padded_uint4 = torch.nn.functional.pad(uint4val, (0, padded_size - uint4val.shape[0]))
    lower_nibble = padded_uint4[0::2] & 0x0F
    upper_nibble = (padded_uint4[1::2] & 0x0F) << 4
    uint8val = lower_nibble | upper_nibble
    
    # 16×uint8 (packed nibbles) + 1×fp16 scale (LE) => 18 bytes/group
    qbytes = uint8val.contiguous().view(torch.uint8).reshape(-1, 16)         # [G,16]
    scale16_i = scale.to(torch.float16).contiguous().view(torch.uint16).to(torch.int32)
    lo = (scale16_i & 0x00FF).to(torch.uint8).unsqueeze(1)                   # [G,1]
    hi = ((scale16_i >> 8) & 0x00FF).to(torch.uint8).unsqueeze(1)            # [G,1]
    sbytes = torch.cat([lo, hi], dim=1)                                      # [G,2]
    packed = torch.cat([qbytes, sbytes], dim=1)                              # [G,18]
    data = packed.contiguous().reshape(-1).to(torch.uint8)
    return data

def q40_dequant(packed: torch.Tensor) -> torch.Tensor:
    """Dequantize Q40: 18 bytes -> 32 float32 values."""
    G = packed.numel() // 18
    buf = packed.view(G, 18)
    qbytes = buf[:, :16]
    # Reconstruct fp16 scale from LE bytes
    sbytes = buf[:, 16:18]
    # Reconstruct uint16 from two uint8 bytes (little endian)
    scale16_u8 = sbytes.reshape(-1)  # [G*2]
    scale16_u16 = scale16_u8.view(torch.uint16)  # Reinterpret bytes as uint16
    scale = scale16_u16.view(torch.float16).to(torch.float32)  # [G]
    # Unpack nibbles
    u4 = torch.empty(G, 32, dtype=torch.uint8, device=packed.device)
    u4[:, 0::2] = qbytes & 0x0F
    u4[:, 1::2] = (qbytes >> 4) & 0x0F
    q = (u4.to(torch.int16) - 8).to(torch.float32)
    out = q * scale.view(-1, 1)
    return out.view(-1)

# ===============================================================
# Q3F8 quantization: 8 values -> 4 bytes (8×3-bit + 1×fp8 scale)
# ===============================================================

def q3f8(t: torch.Tensor) -> torch.Tensor:
    """
    Q3F8: 8 values get quantized to 32 bits (4 bytes), 3-bit normalized int per value + shared fp8 scale factor
    int range is asymmetric; we use this fact to encode the max value as -4 to expand the range a little bit
    """
    assert t.numel() % 8 == 0, "Tensor size must be divisible by 8"
    # groups of 8 values
    gt = t.unflatten(-1, (-1, 8))
    # max (abs) of each group
    _, gmaxi = gt.abs().max(-1)
    gmax = gt.gather(-1, gmaxi.unsqueeze(-1))
    # round gmax to fp8 to make sure we're quantizing to the right range
    gmax = gmax.to(torch.float8_e5m2).to(gmax.dtype)
    # normalize gt; note that gmax may be zero
    gt = gt / gmax
    torch.nan_to_num(gt, nan=0.0, posinf=0.0, neginf=0.0, out=gt)
    # normalize each group by -max ([-1, 1]) and quantize to [0, 8)
    # note that 8 needs to be clamped to 7 since positive half of the range is shorter
    gtq = (gt.to(torch.float16) * -4 + 4).clamp(0, 7).round().to(torch.int32)
    # assemble the results
    gtq = gtq << torch.tensor([8 + i * 3 for i in range(8)], dtype=torch.int32, device=gtq.device)
    gtr = gtq.sum(-1, dtype=torch.int32)
    gtr = gtr + gmax.squeeze(-1).to(torch.float8_e5m2).view(torch.uint8).to(torch.int32)
    # Convert to bytes (little endian)
    return gtr.view(torch.uint8)

def q3f8_dequant(packed: torch.Tensor) -> torch.Tensor:
    """Dequantize Q3F8: 4 bytes -> 8 float32 values."""
    # Reshape to 32-bit integers
    gtr = packed.view(torch.uint8).view(-1, 4)
    gtr_i32 = (gtr[:, 0].to(torch.int32) | 
               (gtr[:, 1].to(torch.int32) << 8) |
               (gtr[:, 2].to(torch.int32) << 16) |
               (gtr[:, 3].to(torch.int32) << 24))
    
    # Extract fp8 scale (lowest 8 bits)
    scale_u8 = (gtr_i32 & 0xFF).to(torch.uint8)
    gmax = scale_u8.view(torch.float8_e5m2).to(torch.float32)
    
    # Extract 3-bit values
    G = gtr_i32.shape[0]
    gt = torch.zeros(G, 8, dtype=torch.float32, device=packed.device)
    for i in range(8):
        shift = 8 + i * 3
        gt[:, i] = ((gtr_i32 >> shift) & 0x7).to(torch.float32)
    
    # Dequantize: reverse the encoding
    gt = (gt - 4.0) / -4.0  # reverse: (gt * -4 + 4)
    out = gt * gmax.view(-1, 1)
    return out.view(-1)

# ===============================================================
# Q40NL (with LS rescale) + dequant
# ===============================================================

def q40nl(
    t: torch.Tensor,
    ls_rescale: bool = True,
    eps: float = 1e-12,
    allow_negative_scale: bool = False
) -> torch.Tensor:
    """
    Pack per 32: 16 nibbles + fp16 scale (LE).
    Dequant path: y = f(q/7), out = scale * y

    If ls_rescale=True, after choosing q from tmax-based normalization,
    refine the stored fp16 scale with the least-squares solution:
        scale_ls = (T·y) / (y·y + eps)
    where T is the original float block and y = f(q/7).
    """
    def _f_decode(x: torch.Tensor) -> torch.Tensor:
        """y = (x*|x| + x) * 0.5, x in [-1,1]."""
        return (x.abs() * x + x) * 0.5

    def _f_inv(y: torch.Tensor) -> torch.Tensor:
        """x = (sqrt((8 * |y|) + 1) - 1) * sign(y) * 0.5."""
        return (torch.sqrt((8.0 * y.abs()) + 1.0) - 1.0) * torch.sign(y) * 0.5

    assert t.numel() % 32 == 0
    T = t.to(torch.float32).view(-1, 32)
    tmax = T.abs().amax(dim=1)                        # [G]
    scale = tmax.clone()                              # fp16 stored
    scale_safe = torch.where(tmax > 0, tmax, torch.ones_like(tmax))
    Y = torch.clamp(T / scale_safe[:,None], -1.0, 1.0)

    X = _f_inv(Y)
    q = torch.round(7.0 * X).to(torch.int8).clamp_(-7, 7)         # [G,32]

    if ls_rescale:
        y   = _f_decode(q.to(torch.float32) / 7.0)          # [G,32] in [-1,1]
        num = (T * y).sum(dim=1)                            # [G]
        den = (y * y).sum(dim=1) + eps                      # [G]
        s_ls = num / den                                    # [G]
        if not allow_negative_scale:
            s_ls = torch.where(s_ls > 0, s_ls, scale)
        scale = s_ls

    # pack nibbles + fp16 scale (LE), byte layout unchanged
    u4 = ((q + 8) & 0x0F).to(torch.uint8)
    lo = u4[:, 0::2] & 0x0F
    hi = (u4[:, 1::2] & 0x0F) << 4
    qbytes = (lo | hi)                                            # [G,16]
    sbytes = scale.to(torch.float16).view(torch.uint8).view(-1,2) # [G,2]
    packed = torch.cat([qbytes, sbytes], dim=1).reshape(-1)  # [G,18] -> bytes
    data = packed.contiguous().reshape(-1).to(torch.uint8)
    return data

def q40nl_dequant(packed: torch.Tensor) -> torch.Tensor:
    G = packed.numel() // 18
    buf = packed.view(G,18)
    qbytes = buf[:,:16]
    sbytes = buf[:,16:18].reshape(-1).view(torch.float16).to(torch.float32)  # [G]
    u4 = torch.empty(G,32, dtype=torch.uint8, device=packed.device)
    u4[:,0::2]  = qbytes & 0x0F
    u4[:,1::2]  = (qbytes >> 4) & 0x0F
    q = (u4.to(torch.int16) - 8).to(torch.float32) / 7.0
    y = (q.abs()*q + q) * 0.5
    out = y * sbytes.view(-1,1)
    return out.view(-1)

# ===============================================================
# Q41NL (with LS rescale) + dequant
# ===============================================================

def q41nl(
    t: torch.Tensor,
    ls_rescale: bool = True,
    eps: float = 1e-12,
    allow_negative_scale: bool = False
) -> torch.Tensor:
    """
    Pack per 32: 16 nibbles + fp16 scale (LE).
    Dequant path: y = f(q/7), out = scale * y

    If ls_rescale=True, after choosing q from tmax-based normalization,
    refine the stored fp16 scale with the least-squares solution:
        scale_ls = (T·y) / (y·y + eps)
    where T is the original float block and y = f(q/7).
    """
    def _f_decode(x: torch.Tensor) -> torch.Tensor:
        """y = x * |x|, x in [-1,1]."""
        return x.abs() * x

    def _f_inv(y: torch.Tensor) -> torch.Tensor:
        """x = sign(y) * sqrt(|y|)."""
        return torch.sign(y) * torch.sqrt(y.abs())

    assert t.numel() % 32 == 0
    T = t.to(torch.float32).view(-1, 32)
    tmax = T.abs().amax(dim=1)                        # [G]
    scale = tmax.clone()                              # fp16 stored
    scale_safe = torch.where(tmax > 0, tmax, torch.ones_like(tmax))
    Y = torch.clamp(T / scale_safe[:,None], -1.0, 1.0)

    X = _f_inv(Y)
    q = torch.round(7.0 * X).to(torch.int8).clamp_(-7, 7)         # [G,32]

    if ls_rescale:
        y   = _f_decode(q.to(torch.float32) / 7.0)          # [G,32] in [-1,1]
        num = (T * y).sum(dim=1)                            # [G]
        den = (y * y).sum(dim=1) + eps                      # [G]
        s_ls = num / den                                    # [G]
        if not allow_negative_scale:
            s_ls = torch.where(s_ls > 0, s_ls, scale)
        scale = s_ls

    u4 = ((q + 8) & 0x0F).to(torch.uint8)
    lo = u4[:, 0::2] & 0x0F
    hi = (u4[:, 1::2] & 0x0F) << 4
    qbytes = (lo | hi)                                            # [G,16]
    sbytes = scale.to(torch.float16).view(torch.uint8).view(-1,2) # [G,2]
    packed = torch.cat([qbytes, sbytes], dim=1).reshape(-1)       # [G,18]
    return packed.contiguous().to(torch.uint8)

def q41nl_dequant(packed: torch.Tensor) -> torch.Tensor:
    G = packed.numel() // 18
    buf = packed.view(G,18)
    qbytes = buf[:,:16]
    sbytes = buf[:,16:18].reshape(-1).view(torch.float16).to(torch.float32)  # [G]
    u4 = torch.empty(G,32, dtype=torch.uint8, device=packed.device)
    u4[:,0::2] = qbytes & 0x0F
    u4[:,1::2] = (qbytes >> 4) & 0x0F
    q = (u4.to(torch.int16)-8).to(torch.float32)/7.0
    y = q.abs()*q
    return (y * sbytes.view(-1,1)).view(-1)

# ===============================================================
# Q42NL / Q43NL (vectorized) + dequant
# ===============================================================

def q42nl(
    t: torch.Tensor,
    eps_scale: float = 1e-6,      # 32-bit safe tiny for scale
    grid_size: int = 255           # number of candidate c values in [-1, 1]
) -> torch.Tensor:
    """
    Q42NL: 32 -> 18 bytes: 16×nibbles + 1×fp8(e5m2) scale + 1×int8 curve
    Dequant: y = (1-c)*x + c*|x|*x  with x=q/7; out = scale * y
    """
    assert t.numel() % 32 == 0, "Tensor size must be divisible by 32"
    T = t.to(torch.float32).view(-1, 32)              # [G,32]
    G = T.shape[0]
    dev = T.device

    # per-group tmax and fp8(e5m2) "round up to next representable"
    tmax = T.abs().amax(dim=1)                        # [G]
    scale = tmax.clone()                              # [G] (float32)

    scale_fp8 = scale.to(torch.float8_e5m2)
    scale_rounded = scale_fp8.to(torch.float32)
    is_finite = torch.isfinite(scale_rounded) & torch.isfinite(scale)
    needs_up = (scale_rounded < scale) & (scale > 0) & is_finite
    scale_bytes = scale_fp8.view(torch.uint8)
    scale_bytes_up = (scale_bytes + 1).clamp(max=255)
    scale_up = scale_bytes_up.view(torch.float8_e5m2).to(torch.float32)
    safe_to_up = needs_up & torch.isfinite(scale_up)
    scale_bytes = torch.where(safe_to_up, scale_bytes_up, scale_bytes)
    scale = scale_bytes.view(torch.float8_e5m2).to(torch.float32)        # [G]

    # normalization
    scale_safe = torch.where(scale > 0, scale, torch.ones_like(scale))
    Y = torch.clamp(T / scale_safe[:, None], -1.0, 1.0)                  # [G,32]

    # ---- vectorized curve search over fixed grid ----
    K = int(grid_size)
    C = torch.linspace(-1.0, 1.0, K, device=dev, dtype=torch.float32)    # [K]
    if K == 255:
        C = torch.clamp(torch.round(C * 127.0), min=-128, max=127).to(torch.int8).to(torch.float32) / 127.0
    Cb = C.view(K, 1, 1)                                                 # [K,1,1]

    # broadcasted per-candidate tensors
    A = Y.abs().unsqueeze(0)                                             # [1,G,32]
    S = Y.sign().unsqueeze(0)                                            # [1,G,32]
    A_b = A.expand(K, G, 32)                                             # [K,G,32]
    S_b = S.expand(K, G, 32)                                             # [K,G,32]

    tiny = 1e-6
    mask_id = (Cb.abs() < tiny)                                          # [K,1,1]
    mask_sq = (Cb >= 1.0)                                                # [K,1,1]
    mask_qc = (Cb <= -1.0)                                               # [K,1,1]
    mask_gen = ~(mask_id | mask_sq | mask_qc)                            # [K,1,1]

    # expand masks to [K,G,32] once
    m_id  = mask_id.expand(K, G, 32)
    m_sq  = mask_sq.expand(K, G, 32)
    m_qc  = mask_qc.expand(K, G, 32)
    m_gen = mask_gen.expand(K, G, 32)

    # branch results (all [K,G,32])
    x_id  = A_b                                                          # identity: x = |y|
    x_sq  = torch.sqrt(A_b)                                              # c>=1:    x = sqrt(|y|)
    x_qc  = 1.0 - torch.sqrt(torch.clamp(1.0 - A_b, min=0.0))            # c<=-1:   x = 1 - sqrt(1-|y|)

    # general quadratic: c x^2 + (1-c) x - a = 0, '+' root
    b = (1.0 - Cb)                                                       # [K,1,1]
    disc = torch.clamp(b * b + 4.0 * Cb * A_b, min=0.0)                  # [K,G,32]
    denom = (2.0 * Cb).expand_as(A_b)
    denom_safe = torch.where(m_gen, denom, torch.ones_like(denom))
    x_gen = (-b.expand_as(A_b) + torch.sqrt(disc)) / denom_safe
    x_gen = torch.clamp(x_gen, 0.0, 1.0)

    # blend branches
    x_nonneg = torch.where(m_id, x_id, torch.where(m_sq, x_sq, torch.where(m_qc, x_qc, x_gen)))
    X = x_nonneg * S_b                                                   # restore sign, [K,G,32]

    # quantize and reconstruct for each c
    q_all = torch.round(7.0 * X).clamp_(-7, 7).to(torch.int8)            # [K,G,32]
    xq = q_all.to(torch.float32) / 7.0                                    # [K,G,32]
    yhat = (1.0 - Cb) * xq + Cb * (xq.abs() * xq)                         # [K,G,32]

    # SSE vs original with per-group scale
    Terr = T.unsqueeze(0) - (yhat * scale.view(1, G, 1))                  # [K,G,32]
    err = (Terr * Terr).sum(dim=-1)                                       # [K,G]
    best_idx = err.argmin(dim=0)                                          # [G]
    best_c = C[best_idx]                                                  # [G]

    # select q for best c
    idx = best_idx.view(1, G, 1).expand(1, G, 32)                         # [1,G,32]
    q_best = q_all.gather(dim=0, index=idx).squeeze(0)                    # [G,32]

    # degenerate groups
    zero_mask = (scale <= eps_scale)                                      # [G]

    # pack 32×4-bit -> 16 bytes
    u4 = ((q_best + 8) & 0x0F).to(torch.uint8)                            # [G,32]
    lo = (u4[:, 0::2] & 0x0F)
    hi = ((u4[:, 1::2] & 0x0F) << 4)
    qbytes = (lo | hi)                                                    # [G,16]
    qbytes[zero_mask] = 0

    # fp8(e5m2) scale byte
    sbytes = scale.to(torch.float8_e5m2).view(torch.uint8).view(-1, 1)    # [G,1]
    sbytes[zero_mask] = 0

    # curve byte
    cbytes_i8 = torch.clamp(torch.round(best_c * 127.0), min=-128, max=127).to(torch.int8)
    cbytes = cbytes_i8.view(torch.uint8).view(-1, 1)                      # [G,1]
    cbytes[zero_mask] = 0

    packed = torch.cat([qbytes, sbytes, cbytes], dim=1).reshape(-1)       # [G,18] -> bytes
    return packed.contiguous().to(torch.uint8)

def q42nl_chunked(t: torch.Tensor, chunk_elems: int = 32*8192, **kw) -> torch.Tensor:
    """Quantize Q42NL in chunks to avoid large [K,G,32] temporaries."""
    assert chunk_elems % 32 == 0
    out = []
    flat = t.view(-1)
    for i in range(0, flat.numel(), chunk_elems):
        out.append(q42nl(flat[i:i+chunk_elems], **kw))
    return torch.cat(out, dim=0)

def q42nl_dequant(packed: torch.Tensor) -> torch.Tensor:
    G = packed.numel() // 18
    buf = packed.view(G,18)
    qbytes = buf[:,:16]
    s = buf[:,16].view(torch.float8_e5m2).to(torch.float32)     # [G]
    c = buf[:,17].view(torch.int8).to(torch.float32)/127.0      # [G]
    u4 = torch.empty(G,32, dtype=torch.uint8, device=packed.device)
    u4[:,0::2]=qbytes & 0x0F
    u4[:,1::2]=(qbytes>>4) & 0x0F
    q = (u4.to(torch.int16)-8).to(torch.float32)/7.0
    y = (1.0 - c.view(-1,1))*q + c.view(-1,1)*(q.abs()*q)
    return (y * s.view(-1,1)).view(-1)

# ===============================================================
# Q43NL (vectorized) + dequant
# ===============================================================

def q43nl(
    t: torch.Tensor,
    eps_scale: float = 1e-6,      # 32-bit safe tiny for scale
    grid_size: int = 255           # number of candidate c values in [-1, 1]
) -> torch.Tensor:
    """
    Q43NL: 32 -> 19 bytes: 16×nibbles + 1×fp16 scale + 1×int8 curve
    Dequant: y = (1-c)*x + c*|x|*x  with x=q/7; out = scale * y
    """
    assert t.numel() % 32 == 0, "Tensor size must be divisible by 32"
    T = t.to(torch.float32).view(-1, 32)              # [G,32]
    G = T.shape[0]
    dev = T.device

    # per-group tmax and fp16 "round up to next representable"
    tmax = T.abs().amax(dim=1)                        # [G]
    scale = tmax.clone()                              # [G] (float32)

    scale_fp16 = scale.to(torch.float16)
    scale_rounded = scale_fp16.to(torch.float32)
    is_finite = torch.isfinite(scale_rounded) & torch.isfinite(scale)
    needs_up = (scale_rounded < scale) & (scale > 0) & is_finite
    scale_words = scale_fp16.view(torch.uint16)
    scale_words_up = ((scale_words.to(torch.int32) + 1).clamp(max=0xFFFF)).to(torch.uint16)
    scale_up = scale_words_up.view(torch.float16).to(torch.float32)
    safe_to_up = needs_up & torch.isfinite(scale_up)
    scale_words = torch.where(safe_to_up, scale_words_up.to(torch.int32), scale_words.to(torch.int32)).to(torch.uint16)
    scale = scale_words.view(torch.float16).to(torch.float32)          # [G]

    # normalization
    scale_safe = torch.where(scale > 0, scale, torch.ones_like(scale))
    Y = torch.clamp(T / scale_safe[:, None], -1.0, 1.0)                  # [G,32]

    # ---- vectorized curve search over fixed grid ----
    K = int(grid_size)
    C = torch.linspace(-1.0, 1.0, K, device=dev, dtype=torch.float32)    # [K]
    if K == 255:
        C = torch.clamp(torch.round(C * 127.0), min=-128, max=127).to(torch.int8).to(torch.float32) / 127.0
    Cb = C.view(K, 1, 1)                                                 # [K,1,1]

    # broadcasted per-candidate tensors
    A = Y.abs().unsqueeze(0)                                             # [1,G,32]
    S = Y.sign().unsqueeze(0)                                            # [1,G,32]
    A_b = A.expand(K, G, 32)                                             # [K,G,32]
    S_b = S.expand(K, G, 32)                                             # [K,G,32]

    tiny = 1e-6
    mask_id = (Cb.abs() < tiny)                                          # [K,1,1]
    mask_sq = (Cb >= 1.0)                                                # [K,1,1]
    mask_qc = (Cb <= -1.0)                                               # [K,1,1]
    mask_gen = ~(mask_id | mask_sq | mask_qc)                            # [K,1,1]

    # expand masks to [K,G,32] once
    m_id  = mask_id.expand(K, G, 32)
    m_sq  = mask_sq.expand(K, G, 32)
    m_qc  = mask_qc.expand(K, G, 32)
    m_gen = mask_gen.expand(K, G, 32)

    # branches
    x_id  = A_b
    x_sq  = torch.sqrt(A_b)
    x_qc  = 1.0 - torch.sqrt(torch.clamp(1.0 - A_b, min=0.0))

    b = (1.0 - Cb)
    disc = torch.clamp(b * b + 4.0 * Cb * A_b, min=0.0)
    denom = (2.0 * Cb).expand_as(A_b)
    denom_safe = torch.where(m_gen, denom, torch.ones_like(denom))
    x_gen = (-b.expand_as(A_b) + torch.sqrt(disc)) / denom_safe
    x_gen = torch.clamp(x_gen, 0.0, 1.0)

    x_nonneg = torch.where(m_id, x_id, torch.where(m_sq, x_sq, torch.where(m_qc, x_qc, x_gen)))
    X = x_nonneg * S_b

    q_all = torch.round(7.0 * X).clamp_(-7, 7).to(torch.int8)
    xq = q_all.to(torch.float32) / 7.0
    yhat = (1.0 - Cb) * xq + Cb * (xq.abs() * xq)

    Terr = T.unsqueeze(0) - (yhat * scale.view(1, G, 1))
    err = (Terr * Terr).sum(dim=-1)
    best_idx = err.argmin(dim=0)
    best_c = C[best_idx]

    idx = best_idx.view(1, G, 1).expand(1, G, 32)
    q_best = q_all.gather(dim=0, index=idx).squeeze(0)

    zero_mask = (scale <= eps_scale)

    u4 = ((q_best + 8) & 0x0F).to(torch.uint8)
    lo = (u4[:, 0::2] & 0x0F)
    hi = ((u4[:, 1::2] & 0x0F) << 4)
    qbytes = (lo | hi)
    qbytes[zero_mask] = 0

    sbytes = scale.to(torch.float16).view(torch.uint8).view(-1, 2)
    sbytes[zero_mask] = 0

    cbytes_i8 = torch.clamp(torch.round(best_c * 127.0), min=-128, max=127).to(torch.int8)
    cbytes = cbytes_i8.view(torch.uint8).view(-1, 1)
    cbytes[zero_mask] = 0

    packed = torch.cat([qbytes, sbytes, cbytes], dim=1).reshape(-1)
    return packed.contiguous().to(torch.uint8)

def q43nl_chunked(t: torch.Tensor, chunk_elems: int = 32*8192, **kw) -> torch.Tensor:
    """Quantize Q43NL in chunks to avoid large [K,G,32] temporaries."""
    assert chunk_elems % 32 == 0
    out = []
    flat = t.view(-1)
    for i in range(0, flat.numel(), chunk_elems):
        out.append(q43nl(flat[i:i+chunk_elems], **kw))
    return torch.cat(out, dim=0)

def q43nl_dequant(packed: torch.Tensor) -> torch.Tensor:
    G = packed.numel() // 19
    buf = packed.view(G,19)
    qbytes = buf[:,:16]
    s = buf[:,16:18].reshape(-1).view(torch.float16).to(torch.float32)
    c = buf[:,18].view(torch.int8).to(torch.float32)/127.0
    u4 = torch.empty(G,32, dtype=torch.uint8, device=packed.device)
    u4[:,0::2]=qbytes & 0x0F
    u4[:,1::2]=(qbytes>>4) & 0x0F
    q = (u4.to(torch.int16)-8).to(torch.float32)/7.0
    y = (1.0 - c.view(-1,1))*q + c.view(-1,1)*(q.abs()*q)
    return (y * s.view(-1,1)).view(-1)

# ===============================================================
# Q44NL (Q42NL + global FP32 root scale header) WITHOUT reusing q42nl code
# ===============================================================

def _q44nl_pack_payload(
    t: torch.Tensor,
    eps_scale: float = 1e-6,
    grid_size: int = 255,
    chunk_elems: int = 32*8192,
) -> torch.Tensor:
    """
    Encode per 32 values to 18 bytes:
      - 16×4-bit nibbles (q in [-7,7] biased by +8)
      - 1×fp8(e5m2) scale (tmax rounded up to next representable)
      - 1×int8 curve (c in [-1,1] mapped to int8)
    Returns only the payload bytes (no global root). OOM-safe via chunking.
    """
    assert t.numel() % 32 == 0, "Q44NL pack: tensor size must be divisible by 32"
    dev = t.device
    flat = t.view(-1).to(torch.float32)
    N = flat.numel()
    assert chunk_elems % 32 == 0

    # Buffers for packed bytes
    payload_chunks = []

    for i in range(0, N, chunk_elems):
        T = flat[i:i+chunk_elems]
        G = T.numel() // 32
        Tb = T.view(G, 32)

        # per-group tmax and fp8(e5m2) "round up to next representable"
        tmax = Tb.abs().amax(dim=1)                  # [G]
        scale = tmax.clone()                         # [G]
        scale_fp8 = scale.to(torch.float8_e5m2)
        scale_rounded = scale_fp8.to(torch.float32)
        is_finite = torch.isfinite(scale_rounded) & torch.isfinite(scale)
        needs_up = (scale_rounded < scale) & (scale > 0) & is_finite
        scale_bytes = scale_fp8.view(torch.uint8)
        scale_bytes_up = (scale_bytes + 1).clamp(max=255)
        scale_up = scale_bytes_up.view(torch.float8_e5m2).to(torch.float32)
        safe_to_up = needs_up & torch.isfinite(scale_up)
        scale_bytes = torch.where(safe_to_up, scale_bytes_up, scale_bytes)
        scale = scale_bytes.view(torch.float8_e5m2).to(torch.float32)   # [G]

        # Normalize
        scale_safe = torch.where(scale > 0, scale, torch.ones_like(scale))
        Y = torch.clamp(Tb / scale_safe[:, None], -1.0, 1.0)            # [G,32]

        # Curve grid
        K = int(grid_size)
        C = torch.linspace(-1.0, 1.0, K, device=dev, dtype=torch.float32)    # [K]
        if K == 255:
            C = torch.clamp(torch.round(C * 127.0), min=-128, max=127).to(torch.int8).to(torch.float32) / 127.0
        Cb = C.view(K, 1, 1)                                                 # [K,1,1]

        # Broadcasts
        A = Y.abs().unsqueeze(0)                                             # [1,G,32]
        S = Y.sign().unsqueeze(0)                                            # [1,G,32]
        A_b = A.expand(K, G, 32)                                             # [K,G,32] |Y|
        S_b = S.expand(K, G, 32)                                             # [K,G,32] sign(Y)

        tiny = 1e-6
        mask_id = (Cb.abs() < tiny)
        mask_sq = (Cb >= 1.0)
        mask_qc = (Cb <= -1.0)
        mask_gen = ~(mask_id | mask_sq | mask_qc)

        m_id  = mask_id.expand(K, G, 32)
        m_sq  = mask_sq.expand(K, G, 32)
        m_qc  = mask_qc.expand(K, G, 32)
        m_gen = mask_gen.expand(K, G, 32)

        # Branch results
        x_id = A_b
        x_sq = torch.sqrt(A_b)
        x_qc = 1.0 - torch.sqrt(torch.clamp(1.0 - A_b, min=0.0))

        b = (1.0 - Cb)
        disc = torch.clamp(b * b + 4.0 * Cb * A_b, min=0.0)
        denom = (2.0 * Cb).expand_as(A_b)
        denom_safe = torch.where(m_gen, denom, torch.ones_like(denom))
        x_gen = (-b.expand_as(A_b) + torch.sqrt(disc)) / denom_safe
        x_gen = torch.clamp(x_gen, 0.0, 1.0)

        x_nonneg = torch.where(m_id, x_id, torch.where(m_sq, x_sq, torch.where(m_qc, x_qc, x_gen)))
        X = x_nonneg * S_b

        # Quantize for all c
        q_all = torch.round(7.0 * X).clamp_(-7, 7).to(torch.int8)            # [K,G,32]
        xq = q_all.to(torch.float32) / 7.0                                    # [K,G,32]
        yhat = (1.0 - Cb) * xq + Cb * (xq.abs() * xq)                         # [K,G,32]

        Terr = Tb.unsqueeze(0) - (yhat * scale.view(1, G, 1))                 # [K,G,32]
        err = (Terr * Terr).sum(dim=-1)                                       # [K,G]
        best_idx = err.argmin(dim=0)                                          # [G]
        best_c = C[best_idx]                                                  # [G]

        idx = best_idx.view(1, G, 1).expand(1, G, 32)                         # [1,G,32]
        q_best = q_all.gather(dim=0, index=idx).squeeze(0)                    # [G,32]

        # Pack
        u4 = ((q_best + 8) & 0x0F).to(torch.uint8)                            # [G,32]
        lo = (u4[:, 0::2] & 0x0F)
        hi = ((u4[:, 1::2] & 0x0F) << 4)
        qbytes = (lo | hi)                                                    # [G,16]

        # Scale: fp8 e5m2
        sbytes = scale.to(torch.float8_e5m2).view(torch.uint8).view(-1, 1)    # [G,1]

        # Curve: int8(round(c*127)) interpreted as uint8 for storage
        cbytes_i8 = torch.clamp(torch.round(best_c * 127.0), min=-128, max=127).to(torch.int8)
        cbytes = cbytes_i8.view(torch.uint8).view(-1, 1)                      # [G,1]

        zero_mask = (scale <= eps_scale)                                      # [G]
        qbytes[zero_mask] = 0
        sbytes[zero_mask] = 0
        cbytes[zero_mask] = 0

        packed = torch.cat([qbytes, sbytes, cbytes], dim=1).reshape(-1)       # [G,18]
        payload_chunks.append(packed)

    return torch.cat(payload_chunks, dim=0).contiguous().to(torch.uint8)

def _q44nl_dequant_payload(payload: torch.Tensor) -> torch.Tensor:
    """Dequant path (no root): y = f_curve(q/7, c), out = scale * y"""
    assert payload.numel() % 18 == 0, "Q44NL dequant payload: size must be multiple of 18"
    G = payload.numel() // 18
    buf = payload.view(G, 18)
    qbytes = buf[:, :16]
    s = buf[:, 16].view(torch.float8_e5m2).to(torch.float32)                 # [G]
    c = buf[:, 17].view(torch.int8).to(torch.float32) / 127.0                # [G]

    u4 = torch.empty(G, 32, dtype=torch.uint8, device=payload.device)
    u4[:, 0::2] = qbytes & 0x0F
    u4[:, 1::2] = (qbytes >> 4) & 0x0F
    q = (u4.to(torch.int16) - 8).to(torch.float32) / 7.0                     # [G,32]

    y = (1.0 - c.view(-1,1)) * q + c.view(-1,1) * (q.abs() * q)              # [G,32]
    return (y * s.view(-1,1)).view(-1)

def q44nlold(
    t: torch.Tensor,
    eps_scale: float = 1e-6,
    grid_size: int = 255,
    chunk_elems: int = 32*8192,
    eps_ls: float = 1e-12
) -> torch.Tensor:
    """
    Two-pass Q44NL:
      1) Pack payload (per-block nonlinear fp8+curve) without root (OOM-safe).
      2) Dequant payload bytes back to Y exactly as stored.
      3) Compute global LS root: root = (T·Y) / (Y·Y + eps_ls).
      4) Prepend 4-byte FP32 root header to payload.
    Output layout: [root:4B | payload: G*18B].
    """
    assert t.numel() % 32 == 0, "Q44NL: tensor size must be divisible by 32"

    payload = _q44nl_pack_payload(t, eps_scale=eps_scale, grid_size=grid_size, chunk_elems=chunk_elems)
    Y = _q44nl_dequant_payload(payload).to(torch.float32)
    T = t.to(torch.float32).view(-1)
    num = torch.dot(T, Y).item()
    den = torch.dot(Y, Y).item() + eps_ls
    root = num / den if den > 0 else 1.0
    if not math.isfinite(root):
        root = 1.0
    root_bytes = torch.tensor([root], dtype=torch.float32).view(torch.uint8).to(torch.uint8)
    return torch.cat([root_bytes, payload], dim=0).contiguous()

def q44nl2(
    t: torch.Tensor,
    eps_scale: float = 1e-6,
    grid_size: int = 255,
    chunk_elems: int = 32*8192,
    eps_ls: float = 1e-12
) -> torch.Tensor:
    """
    True two-pass Q44NL:
      Pass 1: Scan for global |t| max -> globalabsmax.
      Pass 2: Rescale tensor by (1/globalabsmax) and quantize Q42NL-style.
      Root header (FP32) rescales back to original range.
      Output: [root:4B | payload: G*18B]
    """
    assert t.numel() % 32 == 0, "Q44NL: tensor size must be divisible by 32"
    T = t.to(torch.float32)
    
    # === PASS 1: Scan for global abs max ===
    globalabsmax = T.abs().max().item()
    if globalabsmax <= 0 or not math.isfinite(globalabsmax):
        globalabsmax = 1.0

    # === PASS 2: Rescale to 1.0 and encode payload ===
    T_norm = T / globalabsmax
    payload = _q44nl_pack_payload(T_norm, eps_scale=eps_scale, grid_size=grid_size, chunk_elems=chunk_elems)

    # Store root as the globalabsmax (to restore full scale)
    root = float(globalabsmax)
    root_bytes = torch.tensor([root], dtype=torch.float32).view(torch.uint8).to(torch.uint8)
    return torch.cat([root_bytes, payload], dim=0).contiguous()

def q44nl(
    t: torch.Tensor,
    eps_scale: float = 1e-6,
    grid_size: int = 255,
    chunk_elems: int = 32*8192,
    eps_ls: float = 1e-12
) -> torch.Tensor:
    """
    Two-pass Q44NL:
      1) Scan for global |t| max → globalabsmax.
      2) Rescale tensor by (1/globalabsmax) and pack payload (per-block nonlinear fp8+curve) without root (OOM-safe).
      3) Dequant payload bytes back to Y exactly as stored.
      4) Compute global LS root: root = (T·Y) / (Y·Y + eps_ls).
      5) Prepend 4-byte FP32 root header to payload.
    Output layout: [root:4B | payload: G*18B].
    """

    # Pass 1: Calculate/Find global absolute |t| maximum
    T = t.to(torch.float32).view(-1)
    globalabsmax = T.abs().max().item()
    if not math.isfinite(globalabsmax) or globalabsmax <= 0.0:
        globalabsmax = 1.0

    # Pass 2: Normalize by globalabsmax and pack payload

    # Normalize by globalabsmax
    T_norm = (T / globalabsmax).contiguous()

    # Encode payload (OOM-safe) in chunks
    payload = _q44nl_pack_payload(T_norm, eps_scale=eps_scale, grid_size=grid_size, chunk_elems=chunk_elems)

    # Reconstruct stored Y (per-block y*s) by dequantizing payload to recover Y exactly as stored
    Y = _q44nl_dequant_payload(payload).to(torch.float32)   # == y*s for normalized input

    # Fit *global* LS root
    num = torch.dot(T, Y).item()
    den = torch.dot(Y, Y).item() + eps_ls
    root = num/den if den > 0.0 and math.isfinite(num) else 1.0

    # Pack 4B root header + payload bytes
    root_bytes = torch.tensor([root], dtype=torch.float32).view(torch.uint8)
    return torch.cat([root_bytes, payload], dim=0).contiguous()

def q44nl_dequant(packed: torch.Tensor) -> torch.Tensor:
    """Dequant: read FP32 root header, dequant payload, multiply by root."""
    assert packed.numel() >= 4, "Q44NL: buffer too small"
    root = packed[:4].view(torch.float32).item()
    payload = packed[4:].contiguous()
    y = _q44nl_dequant_payload(payload).to(torch.float32)
    return y * float(root)

# ===============================================================
# Q45NL (Q43NL + global FP32 root scale header) WITHOUT reusing q43nl code
# ===============================================================

def _q45nl_pack_payload(
    t: torch.Tensor,
    grid_size: int = 255,
    chunk_elems: int = 32*8192,
) -> torch.Tensor:
    """
    Encode per 32 values to 19 bytes:
      - 16×4-bit nibbles (q in [-7,7] biased by +8)
      - 1×fp16 scale (tmax rounded up to next representable)
      - 1×int8 curve (c in [-1,1] mapped to int8)
    Returns only the payload bytes (no global root). OOM-safe via chunking.
    """

    assert t.numel() % 32 == 0, "Q45NL pack: tensor size must be divisible by 32"
    dev = t.device
    flat = t.view(-1).to(torch.float32)
    N = flat.numel()
    assert chunk_elems % 32 == 0

    # Buffers for packed bytes
    payload_chunks = []

    for i in range(0, N, chunk_elems):

        Tb = flat[i:i+chunk_elems]
        G = Tb.numel() // 32
        T = Tb.view(G, 32)

        # per-group tmax and fp16 "round up to next representable"
        tmax = T.abs().amax(dim=1)                        # [G]
        scale = tmax.clone()                              # [G] (float32)

        scale_fp16 = scale.to(torch.float16)
        scale_rounded = scale_fp16.to(torch.float32)
        is_finite = torch.isfinite(scale_rounded) & torch.isfinite(scale)
        needs_up = (scale_rounded < scale) & (scale > 0) & is_finite
        scale_words = scale_fp16.view(torch.uint16)
        scale_words_up = ((scale_words.to(torch.int32) + 1).clamp(max=0xFFFF)).to(torch.uint16)
        scale_up = scale_words_up.view(torch.float16).to(torch.float32)
        safe_to_up = needs_up & torch.isfinite(scale_up)
        scale_words = torch.where(safe_to_up, scale_words_up.to(torch.int32), scale_words.to(torch.int32)).to(torch.uint16)
        scale = scale_words.view(torch.float16).to(torch.float32)          # [G]

        # normalization
        scale_safe = torch.where(scale > 0, scale, torch.ones_like(scale))
        Y = torch.clamp(T / scale_safe[:, None], -1.0, 1.0)                  # [G,32]

        # ---- vectorized curve search over fixed grid ----
        K = int(grid_size)
        C = torch.linspace(-1.0, 1.0, K, device=dev, dtype=torch.float32)    # [K]
        if K == 255:
            C = torch.clamp(torch.round(C * 127.0), min=-128, max=127).to(torch.int8).to(torch.float32) / 127.0
        Cb = C.view(K, 1, 1)                                                 # [K,1,1]

        # broadcasted per-candidate tensors
        A = Y.abs().unsqueeze(0)                                             # [1,G,32]
        S = Y.sign().unsqueeze(0)                                            # [1,G,32]
        A_b = A.expand(K, G, 32)                                             # [K,G,32]
        S_b = S.expand(K, G, 32)                                             # [K,G,32]

        tiny = 1e-6
        mask_id = (Cb.abs() < tiny)                                          # [K,1,1]
        mask_sq = (Cb >= 1.0)                                                # [K,1,1]
        mask_qc = (Cb <= -1.0)                                               # [K,1,1]
        mask_gen = ~(mask_id | mask_sq | mask_qc)                            # [K,1,1]

        # expand masks to [K,G,32] once
        m_id  = mask_id.expand(K, G, 32)
        m_sq  = mask_sq.expand(K, G, 32)
        m_qc  = mask_qc.expand(K, G, 32)
        m_gen = mask_gen.expand(K, G, 32)

        # branches
        x_id  = A_b                                                          # identity: x = |y|
        x_sq  = torch.sqrt(A_b)                                              # c>=1:    x = sqrt(|y|)
        x_qc  = 1.0 - torch.sqrt(torch.clamp(1.0 - A_b, min=0.0))            # c<=-1:   x = 1 - sqrt(1-|y|)

        b = (1.0 - Cb)
        disc = torch.clamp(b * b + 4.0 * Cb * A_b, min=0.0)
        denom = (2.0 * Cb).expand_as(A_b)
        denom_safe = torch.where(m_gen, denom, torch.ones_like(denom))
        x_gen = (-b.expand_as(A_b) + torch.sqrt(disc)) / denom_safe
        x_gen = torch.clamp(x_gen, 0.0, 1.0)

        # blend branches
        x_nonneg = torch.where(m_id, x_id, torch.where(m_sq, x_sq, torch.where(m_qc, x_qc, x_gen)))
        X = x_nonneg * S_b                                                   # restore sign, [K,G,32]

        # quantize and reconstruct for each c
        q_all = torch.round(7.0 * X).clamp_(-7, 7).to(torch.int8)            # [K,G,32]
        xq = q_all.to(torch.float32) / 7.0                                   # [K,G,32]
        yhat = (1.0 - Cb) * xq + Cb * (xq.abs() * xq)                        # [K,G,32]

        # SSE vs original with per-group scale
        Terr = Tb.view(G, 32).unsqueeze(0) - (yhat * scale.view(1, G, 1))    # [K,G,32]
        err = (Terr * Terr).sum(dim=-1)                                      # [K,G]
        best_idx = err.argmin(dim=0)                                         # [G]
        best_c = C[best_idx]                                                 # [G]

        # select q for best c
        idx = best_idx.view(1, G, 1).expand(1, G, 32)                         # [1,G,32]
        q_best = q_all.gather(dim=0, index=idx).squeeze(0)                    # [G,32]

        # pack 32×4-bit -> 16 bytes
        u4 = ((q_best + 8) & 0x0F).to(torch.uint8)                            # [G,32]
        lo = (u4[:, 0::2] & 0x0F)
        hi = ((u4[:, 1::2] & 0x0F) << 4)
        qbytes = (lo | hi)                                                    # [G,16]

        # fp16 scale bytes
        sbytes = scale.to(torch.float16).view(torch.uint8).view(-1, 2)        # [G,2]

        # curve byte
        cbytes_i8 = torch.clamp(torch.round(best_c * 127.0), min=-128, max=127).to(torch.int8)
        cbytes = cbytes_i8.view(torch.uint8).view(-1, 1)                      # [G,1]

        # concatenate block
        packed = torch.cat([qbytes, sbytes, cbytes], dim=1).reshape(-1)       # [G,19]
        payload_chunks.append(packed)

    return torch.cat(payload_chunks, dim=0).contiguous().to(torch.uint8)

def _q45nl_dequant_payload(payload: torch.Tensor) -> torch.Tensor:
    """
    Decode 19-byte blocks produced by _q45nl_pack_payload.
    Returns Y (float32 tensor) = per-block dequantized values.
    """

    assert payload.numel() % 19 == 0, "Q45NL payload size invalid"
    G = payload.numel() // 19
    buf = payload.view(G, 19)

    qbytes = buf[:, :16]
    s = buf[:, 16:18].reshape(-1).view(torch.float16).to(torch.float32)
    c = buf[:, 18].view(torch.int8).to(torch.float32) / 127.0

    # unpack 4-bit codes
    u4 = torch.empty(G, 32, dtype=torch.uint8, device=payload.device)
    u4[:, 0::2] = qbytes & 0x0F
    u4[:, 1::2] = (qbytes >> 4) & 0x0F

    # dequantize per block
    q = (u4.to(torch.int16) - 8).to(torch.float32) / 7.0
    y = (1.0 - c.view(-1,1)) * q + c.view(-1,1) * (q.abs() * q)
    return (y * s.view(-1,1)).reshape(-1)

def q45nl(
    t: torch.Tensor,
    grid_size: int = 255,
    chunk_elems: int = 32*8192,
) -> torch.Tensor:
    """
    Two-pass Q45NL:
      1) Scan for global |t| max → globalabsmax.
      2) Rescale tensor by (1/globalabsmax) and pack payload (per-block nonlinear fp16+curve) without root (OOM-safe).
      3) Dequant payload bytes back to Y exactly as stored.
      4) Compute global LS root: root = (T·Y) / (Y·Y + eps_ls).
      5) Prepend 4-byte FP32 root header to payload.
    Output layout: [root:4B | payload: G*19B].
    """

    # Pass 1: Calculate/Find global absolute |t| maximum
    T = t.to(torch.float32).view(-1)
    globalabsmax = T.abs().max().item()
    if not math.isfinite(globalabsmax) or globalabsmax <= 0.0:
        globalabsmax = 1.0

    # Pass 2: Normalize by globalabsmax and pack payload

    # Normalize by globalabsmax
    T_norm = (T / globalabsmax).contiguous()

    # Encode payload (OOM-safe) in chunks
    payload = _q45nl_pack_payload(T_norm, grid_size=grid_size, chunk_elems=chunk_elems)

    # Reconstruct stored Y (per-block y*s) by dequantizing payload to recover Y exactly as stored
    Y = _q45nl_dequant_payload(payload).to(torch.float32)   # == y*s for normalized input

    # Fit *global* LS root
    num = torch.dot(T, Y).item()
    den = torch.dot(Y, Y).item() + 1e-12
    root = num/den if den > 0.0 and math.isfinite(num) else 1.0

    # Pack 4B root header + payload bytes
    root_bytes = torch.tensor([root], dtype=torch.float32).view(torch.uint8)
    return torch.cat([root_bytes, payload], dim=0).contiguous()

def q45nl_dequant(packed: torch.Tensor) -> torch.Tensor:
    """Dequant: read FP32 root header, dequant payload, multiply by root."""
    assert packed.numel() >= 4, "Q45NL: buffer too small"
    root = packed[:4].view(torch.float32).item()
    payload = packed[4:].contiguous()
    y = _q45nl_dequant_payload(payload).to(torch.float32)
    return y * float(root)

# ===============================================================
# Real IQ4_NL (llama.cpp-style) + dequant
# ===============================================================

# Fixed 16-entry LUT (signed 8-bit codes), from llama.cpp IQ4_NL (kvalues_iq4nl)
_KVALUES_IQ4NL_INT8 = torch.tensor(
    [-127, -104,  -83,  -65,  -49,  -35,  -22,  -10,
        1,   13,   25,   38,   53,   69,   89,  113],
    dtype=torch.int16
)
_KVALUES_IQ4NL = _KVALUES_IQ4NL_INT8.to(torch.float32) / 127.0  # map to [-1..1]ish

def _pack_nibbles_u4(u4: torch.Tensor) -> torch.Tensor:
    lo = (u4[:, 0::2] & 0x0F)
    hi = (u4[:, 1::2] & 0x0F) << 4
    return (lo | hi).to(torch.uint8)

def _unpack_nibbles_u4(qbytes: torch.Tensor) -> torch.Tensor:
    lo = (qbytes & 0x0F).to(torch.uint8)
    hi = ((qbytes >> 4) & 0x0F).to(torch.uint8)
    out = torch.empty((qbytes.shape[0], 32), dtype=torch.uint8, device=qbytes.device)
    out[:, 0::2] = lo
    out[:, 1::2] = hi
    return out

def iq4nl_quant(
    t: torch.Tensor,
    ls_rescale: bool = False,
    eps: float = 1e-12
) -> torch.Tensor:
    """
    IQ4_NL quantization per 32:
      - 16×nibbles (codes 0..15) selecting from fixed LUT
      - 2 bytes FP16 per-block scale (LE)
    18 bytes / 32 weights → 4.5 bpw.
    """
    assert t.numel() % 32 == 0
    T = t.to(torch.float32).view(-1, 32)        # [G,32]
    G = T.shape[0]
    dev = T.device

    # per-block scale = max-abs
    tmax = T.abs().amax(dim=1)                  # [G]
    scale = tmax.clone()
    scale_safe = torch.where(scale > 0, scale, torch.ones_like(scale))
    Yn = torch.clamp(T / scale_safe[:, None], -1.0, 1.0)   # normalized

    LUT = _KVALUES_IQ4NL.to(dev)                               # [16]
    # nearest neighbor in LUT per element
    diff = (Yn.unsqueeze(-1) - LUT.view(1,1,16)).abs()         # [G,32,16]
    idx = diff.argmin(dim=-1).to(torch.uint8)                  # [G,32]

    if ls_rescale:
        idx_long = idx.to(torch.long)
        y = LUT[idx_long].to(torch.float32)
        num = (T * y).sum(dim=1)
        den = (y * y).sum(dim=1) + eps
        s_ls = num / den
        scale = torch.where(s_ls > 0, s_ls, scale)

    qbytes = _pack_nibbles_u4(idx)                              # [G,16]
    sbytes = scale.to(torch.float16).view(torch.uint8).view(-1, 2)  # [G,2]

    return torch.cat([qbytes, sbytes], dim=1).reshape(-1).contiguous().to(torch.uint8)

def iq4nl_dequant(packed: torch.Tensor) -> torch.Tensor:
    data = packed.view(-1).to(torch.uint8)
    assert data.numel() % 18 == 0
    G = data.numel() // 18
    dev = data.device

    blocks = data.view(G, 18)
    qbytes = blocks[:, :16]
    sbytes = blocks[:, 16:]

    idx = _unpack_nibbles_u4(qbytes).to(torch.long)             # [G,32]
    scale = sbytes.view(torch.float16).to(torch.float32).view(-1,1)  # [G,1]

    LUT = _KVALUES_IQ4NL.to(dev)
    y = LUT[idx]                                                # [G,32]
    out = (y * scale).to(torch.float32)                         # [G,32]
    return out.view(-1)

# ===============================================================
# Q4_K_S (reference-style) + dequant (256 super-block, ~4.5 bpw)
# ===============================================================

def _pack_6bit_pairs(vals_u6: torch.Tensor) -> torch.Tensor:
    assert vals_u6.numel() == 16
    v = vals_u6.to(torch.uint8).cpu().tolist()
    bits = 0
    bitcount = 0
    out = []
    for x in v:
        bits |= (int(x) & 0x3F) << bitcount
        bitcount += 6
        while bitcount >= 8:
            out.append(bits & 0xFF)
            bits >>= 8
            bitcount -= 8
    if bitcount > 0:
        out.append(bits & 0xFF)
    return torch.tensor(out[:12], dtype=torch.uint8)

def _unpack_6bit_pairs(buf12: torch.Tensor) -> torch.Tensor:
    data = buf12.to(torch.uint8).cpu().tolist()
    bits = 0
    bitcount = 0
    out = []
    i = 0
    while len(out) < 16:
        while bitcount < 6:
            bits |= (data[i] << bitcount)
            bitcount += 8
            i += 1
        out.append(bits & 0x3F)
        bits >>= 6
        bitcount -= 6
    return torch.tensor(out, dtype=torch.uint8)

def q4k_s_quant(t: torch.Tensor) -> torch.Tensor:
    assert t.numel() % 256 == 0, "Q4_K_S expects multiples of 256"
    T = t.to(torch.float32).view(-1, 256)  # [S,256]
    S = T.shape[0]
    out_chunks = []
    for s in range(S):
        sb = T[s]
        D = sb.abs().max().item()
        if D == 0.0:
            D = 1.0
        meta_pairs = []
        qbytes_blocks = []
        for b in range(8):
            blk = sb[b*32:(b+1)*32]
            mn = blk.min().item()
            mx = blk.max().item()
            scl = 0.0 if mx == mn else (mx - mn) / 15.0
            idx_m = int(round((mn + D) * 63.0 / (2.0 * D)))
            idx_m = max(0, min(63, idx_m))
            scl_max = (2.0 * D) / 15.0
            idx_s = int(round(scl * 63.0 / max(1e-30, scl_max)))
            idx_s = max(0, min(63, idx_s))
            meta_pairs.extend([idx_m, idx_s])
            mn_q = -D + (2.0 * D) * (idx_m / 63.0)
            scl_q = scl_max * (idx_s / 63.0)
            if scl_q == 0.0:
                q = torch.zeros(32, dtype=torch.int8, device=T.device)
            else:
                q = torch.round((blk - mn_q) / scl_q).to(torch.int16).clamp_(0, 15).to(torch.int8)
            u4 = (q & 0x0F).to(torch.uint8)
            lo = u4[0::2] & 0x0F
            hi = (u4[1::2] & 0x0F) << 4
            qbytes_blocks.append((lo | hi))
        qbytes = torch.cat(qbytes_blocks, dim=0)                   # 128 B
        meta_u6 = torch.tensor(meta_pairs, dtype=torch.uint8)      # 16×6-bit -> 12 B
        meta12 = _pack_6bit_pairs(meta_u6)
        Dbytes = torch.tensor(list(torch.tensor([D], dtype=torch.float32).view(torch.uint8).cpu().numpy()), dtype=torch.uint8)
        out_chunks.append(torch.cat([qbytes, meta12, Dbytes], dim=0))  # 144 B
    return torch.cat(out_chunks, dim=0).contiguous().to(torch.uint8)

def q4k_s_dequant(packed: torch.Tensor) -> torch.Tensor:
    S = packed.numel() // 144
    buf = packed.view(S, 144)
    out = torch.empty(S, 256, dtype=torch.float32, device=packed.device)
    for s in range(S):
        row = buf[s]
        qbytes = row[:128]
        meta12 = row[128:140]
        D = row[140:144].view(torch.float32).item()
        if D == 0.0:
            D = 1.0
        scl_max = (2.0 * D) / 15.0
        vals = _unpack_6bit_pairs(meta12)
        for b in range(8):
            idx_m = int(vals[2*b+0].item())
            idx_s = int(vals[2*b+1].item())
            mn_q = -D + (2.0 * D) * (idx_m / 63.0)
            scl_q = scl_max * (idx_s / 63.0)
            qb = qbytes[b*16:(b+1)*16]
            u4 = torch.empty(32, dtype=torch.uint8, device=packed.device)
            u4[0::2] = qb & 0x0F
            u4[1::2] = (qb >> 4) & 0x0F
            q = u4.to(torch.float32)
            out[s, b*32:(b+1)*32] = mn_q + scl_q * q
    return out.view(-1)

# ===============================================================
# Benchmark utilities
# ===============================================================

def psnr(x: torch.Tensor, y: torch.Tensor):
    mse = torch.mean((x - y)**2)
    if mse <= 0:
        return float('inf'), 0.0
    peak = torch.max(x.abs()).item()
    return 20.0*math.log10(peak) - 10.0*math.log10(mse.item()), mse.item()


# ===============================================================
# MXFP4 (OCP MX spec: FP4 E2M1 elements, E8M0 scale, k=32) + dequant
#   Encoding notes (per OCP MX v1.0):
#     - Elements: FP4 E2M1 with exponent bias = 1, m = 1; values in {±0, ±0.5, ±1, ±1.5, ±2, ±3, ±4, ±6}.
#     - Scale X (E8M0): unsigned exponent-only with bias 127; represents X = 2^(E-127).
#     - Recommended scale choice (Sec. 6.3): X = 2^{floor(log2(max|V|))} / 4 so elements fit without overflow.
#   Packing:
#     - Block of 32 elems → 32 * 4 bits = 16 bytes for nibbles; +1 byte scale (E8M0) = 17 bytes per block (4.25 bpw).
# ===============================================================

# --- FP helpers ---
def _round_ties_to_even(x: torch.Tensor) -> torch.Tensor:
    # emulate banker's rounding for positive/negative values
    floor = torch.floor(x)
    diff = x - floor
    up = (diff > 0.5) | ((diff == 0.5) & ((floor % 2) == 1))
    return floor + up.to(x.dtype)

def _encode_E8M0_from_scale(s: torch.Tensor) -> torch.Tensor:
    # s > 0, scalar tensor; encode to uint8 E8M0 (X = 2^(E-127))
    # choose integer exponent e = round_ties_to_even(log2(s))
    e = torch.log2(s).round() + 127.0
    e = torch.clamp(e, 0.0, 254.0)  # 255 reserved for NaN
    return e.to(torch.uint8)

def _decode_E8M0(e: torch.Tensor) -> torch.Tensor:
    # e: uint8, 255 is NaN (we ignore), return positive float32 scale
    e32 = e.to(torch.float32)
    return torch.pow(2.0, e32 - 127.0)

def _e2m1_decode(n: torch.Tensor) -> torch.Tensor:
    # n: uint8 nibble [0..15], layout: s e1 e0 m (bits 3..0)
    s = (n >> 3) & 0x1
    e = (n >> 1) & 0x3
    m = n & 0x1
    bias = 1
    is_sub = (e == 0)
    # normal: (-1)^s * 2^(e-bias) * (1 + m/2)
    normal = torch.pow(2.0, (e.to(torch.int16) - bias).to(torch.float32)) * (1.0 + (m.to(torch.float32) * 0.5))
    # subnormal: (-1)^s * 2^(1-bias) * (m/2)  (zero when m==0)
    sub = (float(2.0 ** (1 - bias)) * (m.to(torch.float32) * 0.5))
    val = torch.where(is_sub, sub, normal)
    sign = torch.where(s == 1, -1.0, 1.0)
    return sign * val

def _e2m1_encode(vals: torch.Tensor) -> torch.Tensor:
    # Map real vals to nearest representable E2M1 value (ties to even by preferring lower code).
    # Positive codebook (magnitudes): [0.0, 0.5, 1.0, 1.5, 2.0, 3.0, 4.0, 6.0]
    # Corresponding nibbles for positive values: 0000(0), 0001(0.5), 0010(1.0), 0011(1.5), 0110(2.0), 0111(3.0), 1010(4.0), 1011(6.0)
    # We'll build full signed set, then argmin distance.
    device = vals.device
    mags = torch.tensor([0.0, 0.5, 1.0, 1.5, 2.0, 3.0, 4.0, 6.0], device=device, dtype=torch.float32)
    pos_codes = torch.tensor([0x0, 0x1, 0x2, 0x3, 0x6, 0x7, 0xA, 0xB], device=device, dtype=torch.uint8)
    # negative uses sign bit = 1 (add 0b1000)
    neg_codes = pos_codes | 0x8
    # Build codebook
    code_vals = torch.cat([mags, -mags])
    codes = torch.cat([pos_codes, neg_codes])
    # distances
    v = vals.to(torch.float32).unsqueeze(-1)
    d = torch.abs(v - code_vals)
    idx = torch.argmin(d, dim=-1)
    chosen = codes[idx]
    return chosen.to(torch.uint8)

def mxfp4_quant(t: torch.Tensor) -> torch.Tensor:
    t = t.to(torch.float32).contiguous().view(-1)
    n = t.numel()
    k = 32
    pad = (k - (n % k)) % k
    if pad:
        t = torch.cat([t, torch.zeros(pad, device=t.device, dtype=t.dtype)], dim=0)
    t_blocks = t.view(-1, k)
    # scale per OCP 6.3: X = 2^{floor(log2(max|V|))} / 4 ; protect zero
    vmax = torch.max(t_blocks.abs(), dim=1).values.clamp_min(1e-30)
    X = torch.pow(2.0, torch.floor(torch.log2(vmax))) * 0.25
    # Normalize and encode
    y = t_blocks / X.unsqueeze(1)
    nibbles = _e2m1_encode(y)
    # Pack two nibbles per byte
    lo = nibbles[:, 0::2]
    hi = nibbles[:, 1::2]
    packed_q = (lo | (hi << 4)).contiguous().view(-1).to(torch.uint8)
    # Encode scale to E8M0
    scale_e = _encode_E8M0_from_scale(X)
    out = torch.cat([scale_e.view(-1,1), packed_q.view(-1,16)], dim=1).contiguous().view(-1)
    # Attach meta for bpw computation: 17 bytes per 32 elems
    return out

def mxfp4_dequant(packed: torch.Tensor) -> torch.Tensor:
    p = packed.view(-1, 17).contiguous()
    scale_e = p[:,0]
    X = _decode_E8M0(scale_e)
    qbytes = p[:,1:17].contiguous().view(-1,16)
    lo = (qbytes & 0x0F).view(-1,16)
    hi = (qbytes >> 4).view(-1,16)
    nibbles = torch.empty((qbytes.shape[0], 32), dtype=torch.uint8, device=packed.device)
    nibbles[:, 0::2] = lo
    nibbles[:, 1::2] = hi
    vals = _e2m1_decode(nibbles)
    out = (vals * X.unsqueeze(1)).contiguous().view(-1)
    return out

# ===============================================================
# NVFP4 (NVIDIA Blackwell): FP4 E2M1 elements, E4M3 scale, k=16  (≈4.5 bpw)
#   Sources indicate per-16 block scaling with an FP8 E4M3 scale and values in ±6 range.
#   We choose X = max|V| / 6, then encode X as E4M3; elements are E2M1.
# ===============================================================

def _encode_E4M3_from_scale(s: torch.Tensor) -> torch.Tensor:
    # Encode positive float32 s into FP8 E4M3 (no Inf/NaN handling here; clamp)
    # Layout: sign(1)=0, exp(4) bias=7, mant(3)
    s = s.clamp_min(2.0**(-7))  # avoid zero; minimal normal/subnormal boundaries handled crudely
    e = torch.floor(torch.log2(s))
    mant = s / torch.pow(2.0, e) - 1.0
    m = _round_ties_to_even(mant * 8.0).clamp(0.0, 7.0)
    # handle carry
    over = (m == 8.0)
    e = torch.where(over, e + 1.0, e)
    m = torch.where(over, torch.zeros_like(m), m)
    eb = (e + 7.0).clamp(0.0, 14.0)  # 15 reserved
    byte = ((eb.to(torch.uint8) << 3) | m.to(torch.uint8))
    return byte

def _decode_E4M3(e8: torch.Tensor) -> torch.Tensor:
    eb = (e8 >> 3) & 0x0F
    m = e8 & 0x07
    e = eb.to(torch.float32) - 7.0
    mant = 1.0 + (m.to(torch.float32) / 8.0)
    return torch.pow(2.0, e) * mant

def nvfp4_quant(t: torch.Tensor) -> torch.Tensor:
    t = t.to(torch.float32).contiguous().view(-1)
    n = t.numel()
    k = 16
    pad = (k - (n % k)) % k
    if pad:
        t = torch.cat([t, torch.zeros(pad, device=t.device, dtype=t.dtype)], dim=0)
    tb = t.view(-1, k)
    vmax = torch.max(tb.abs(), dim=1).values.clamp_min(1e-30)
    X = vmax / 6.0
    y = tb / X.unsqueeze(1)
    nibbles = _e2m1_encode(y)
    # pack: 16 elems -> 8 bytes
    lo = nibbles[:, 0::2]
    hi = nibbles[:, 1::2]
    qbytes = (lo | (hi << 4)).contiguous().view(-1).to(torch.uint8)
    scale_e = _encode_E4M3_from_scale(X)
    out = torch.cat([scale_e.view(-1,1), qbytes.view(-1,8)], dim=1).contiguous().view(-1)
    return out

def nvfp4_dequant(packed: torch.Tensor) -> torch.Tensor:
    p = packed.view(-1, 9).contiguous()
    scale_e = p[:,0]
    X = _decode_E4M3(scale_e)
    qbytes = p[:,1:9].contiguous().view(-1,8)
    lo = (qbytes & 0x0F).view(-1,8)
    hi = (qbytes >> 4).view(-1,8)
    nibbles = torch.empty((qbytes.shape[0], 16), dtype=torch.uint8, device=packed.device)
    nibbles[:, 0::2] = lo
    nibbles[:, 1::2] = hi
    vals = _e2m1_decode(nibbles)
    out = (vals * X.unsqueeze(1)).contiguous().view(-1)
    return out

# ===============================================================
# Benchmarking
# ===============================================================

def bench_one(name, enc, dec, t: torch.Tensor):
    t_f32 = t.to(torch.float32)
    t0 = time.perf_counter()
    packed = enc(t)
    t1 = time.perf_counter()
    rec = dec(packed).to(torch.float32)
    t2 = time.perf_counter()
    p, m = psnr(t_f32, rec)
    mae = torch.mean((t_f32-rec).abs()).item()
    mx  = torch.max((t_f32-rec).abs()).item()
    bits = packed.numel() * 8
    bpw  = bits / t.numel()
    return dict(
        name=name, bpw=bpw, psnr_db=p, mse=m, mae=mae, maxerr=mx,
        t_encode_ms=(t1-t0)*1000.0, t_decode_ms=(t2-t1)*1000.0
    )

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--shape", type=str, default="256x256", help="rowsxcols or 'randN' (e.g., 1024)")
    parser.add_argument("--seed", type=int, default=1)
    parser.add_argument("--device", type=str, default="cpu")
    parser.add_argument("--grid", type=int, default=255, help="grid size for Q42NL/Q43NL")
    parser.add_argument("--no-ls", action="store_true", help="disable LS rescale for Q40NL/Q41NL")
    args = parser.parse_args()
    torch.manual_seed(args.seed)

    if "x" in args.shape:
        r,c = map(int, args.shape.lower().split("x"))
        t = torch.randn(r*c, device=args.device)
    else:
        n = int(args.shape.replace("rand",""))
        t = torch.randn(n, device=args.device)

    results = []
    # New quantization methods from convert.py
    results.append(bench_one("FP16", fp16_quant, fp16_dequant, t))
    results.append(bench_one("BF16", bf16_quant, bf16_dequant, t))
    results.append(bench_one("FP8", fp8_quant, fp8_dequant, t))
    results.append(bench_one("Q80", q80, q80_dequant, t))
    results.append(bench_one("Q40", q40, q40_dequant, t))
    results.append(bench_one("Q3F8", q3f8, q3f8_dequant, t))
    
    # Your four:
    results.append(bench_one("Q40NL", lambda x: q40nl(x, ls_rescale=not args.no_ls), q40nl_dequant, t))
    results.append(bench_one("Q41NL", lambda x: q41nl(x, ls_rescale=not args.no_ls), q41nl_dequant, t))
    results.append(bench_one("Q42NL", lambda x: q42nl_chunked(x, grid_size=args.grid), q42nl_dequant, t))
    results.append(bench_one("Q43NL", lambda x: q43nl_chunked(x, grid_size=args.grid), q43nl_dequant, t))
    results.append(bench_one("Q44NL", lambda x: q44nl(x, grid_size=args.grid), q44nl_dequant, t))
    results.append(bench_one("Q45NL", lambda x: q45nl(x, grid_size=args.grid), q45nl_dequant, t))

    # llama.cpp baselines
    results.append(bench_one("IQ4_NL", iq4nl_quant, iq4nl_dequant, t))
    results.append(bench_one("Q4_K_S", q4k_s_quant, q4k_s_dequant, t))
    results.append(bench_one("MXFP4", mxfp4_quant, mxfp4_dequant, t))
    results.append(bench_one("NVFP4", nvfp4_quant, nvfp4_dequant, t))

    # ---------- Extended report (q42nl_comparison.c style) ----------
    print("\n========== BENCHMARK RESULTS ==========")
    for r in results:
        print(f"{r['name']}:")
        print(f"  Encode: {r['t_encode_ms']:.3f} ms   Decode: {r['t_decode_ms']:.3f} ms")
        print(f"  bpw: {r['bpw']:.3f}   PSNR: {r['psnr_db']:.3f} dB   MSE: {r['mse']:.6e}")
        print(f"  MAE: {r['mae']:.6e}   MAXERR: {r['maxerr']:.6e}")
        print()

    # Summary: best PSNR (quality) and fastest (encode+decode)
    best_quality = max(results, key=lambda r: r["psnr_db"])
    fastest = min(results, key=lambda r: r["t_encode_ms"] + r["t_decode_ms"])

    print("---------- COMPARISON SUMMARY ----------")
    print(f"Best Quality: {best_quality['name']}  ({best_quality['psnr_db']:.3f} dB, MSE {best_quality['mse']:.6e})")
    print(f"Fastest:      {fastest['name']}        (Encode {fastest['t_encode_ms']:.3f} ms, Decode {fastest['t_decode_ms']:.3f} ms)")
    print("----------------------------------------\n")

    # -------- Pretty table with CR metrics (always printed) --------
    rows = results
    for r in rows:
        r["cr32"] = 32.0 / r["bpw"] if r["bpw"] > 0 else float("inf")
        r["cr16"] = 16.0 / r["bpw"] if r["bpw"] > 0 else float("inf")
    name_w = max(6, max(len(r["name"]) for r in rows))
    header = (
        f'{"name":<{name_w}}  '
        f'{"bpw":>6}  '
        f'{"CR32×":>6}  '
        f'{"CR16×":>6}  '
        f'{"PSNR(dB)":>9}  '
        f'{"MSE":>12}  '
        f'{"MAE":>10}  '
        f'{"MAXERR":>10}'
    )
    sep = "-" * len(header)
    print(header)
    print(sep)
    for r in rows:
        print(
            f'{r["name"]:<{name_w}}  '
            f'{r["bpw"]:>6.3f}  '
            f'{r["cr32"]:>6.2f}  '
            f'{r["cr16"]:>6.2f}  '
            f'{r["psnr_db"]:>9.3f}  '
            f'{r["mse"]:>12.6e}  '
            f'{r["mae"]:>10.6e}  '
            f'{r["maxerr"]:>10.6e}'
        )
    print()

    # ---------- Original CSV output (kept intact) ----------
    print("name,bpw,psnr_db,mse,mae,maxerr")
    for r in results:
        print(f"{r['name']},{r['bpw']:.3f},{r['psnr_db']:.3f},{r['mse']:.6e},{r['mae']:.6e},{r['maxerr']:.6e}")

if __name__ == "__main__":
    main()
