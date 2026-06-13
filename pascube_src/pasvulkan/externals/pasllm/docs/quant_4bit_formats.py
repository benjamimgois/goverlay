#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Torch-only evaluator for several 4-bit/8-bit and float baselines:
- Q40NL   : Non-linear Q4 (/7), fp16 block scale per 32. f(x) = 0.5*(x*|x| + x)
- IQ4_NL  : ggml/gguf 4-bit with LUT (kvalues_iq4nl), fp16 block scale per 32
- MXFP4   : OCP 4-bit E2M1 per element + E8M0 (power-of-two) scale per 32
- NVFP4   : NVIDIA 4-bit E2M1 per element + FP8 E4M3 scale per 16
- Q40     : Linear Q4 (/7), fp16 block scale per 32
- Q80     : Linear Q8 (/127), fp16 block scale per 32
- NF4     : Simple codebook-only NF4 (no scale) packed per 32 (kept for backward-compat with earlier drafts)
- NF4_BS64: Canonical NF4 (QLoRA centers) with absmax fp16 scale per 64 (two 32-nibble lanes + fp16)
- FP16    : Per-element fp16 cast baseline
- BF16    : Per-element bfloat16 cast baseline
- FP32    : Identity baseline

Metrics printed:
- max |e|, mean |e|, median |e|, p99 |e|  against float32 truth
- Dot(T̂, X) vs truth (absolute Δ and signed Δ)

"""

import argparse
import math
import sys
from typing import Tuple, Optional, Dict
try:
    import torch
    import torch.nn.functional as F
except Exception as e:
    print("[fatal] This harness requires PyTorch. Please install torch to run it.")
    raise

# -------- Core nonlinearity (Q40NL) --------

def _f_decode(x: torch.Tensor) -> torch.Tensor:
    """y = 0.5 * (x*|x| + x), x in [-1,1]."""
    return 0.5 * (x.abs() * x + x)

def _f_inv(y: torch.Tensor) -> torch.Tensor:
    """x = 0.5 * sign(y) * (sqrt(1 + 8*|y|) - 1)."""
    ay = y.abs()
    return 0.5 * torch.sign(y) * (torch.sqrt(1.0 + 8.0 * ay) - 1.0)


# -------- IQ4_NL LUT centers (int8) --------
# Source: llama.cpp IQ4_NL PR (kvalues_iq4nl) — embed as int8 centers in [-127..127]
_IQ4NL_LUT_INT8 = torch.tensor(
    [-127,-104, -83, -65, -49, -35, -22, -10,   1,  13,  25,  38,  53,  69,  89, 113],
    dtype=torch.int16)  # keep in int16 to avoid overflow in ops


def _nearest_lut_index(norm: torch.Tensor, lut_vals: torch.Tensor) -> torch.Tensor:
    """
    Given normalized targets in [-1,1], pick nearest LUT index (0..15) for values in lut_vals/127.
    norm: [G, N]
    lut_vals: [16] int (centers in int8 space)
    """
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
    """
    dev = vals.device
    v = vals.to(torch.float32)
    s = (v < 0).to(torch.int8)

    av = v.abs()
    pos = _FP4_POS.to(dev)  # [8]
    d = (av.unsqueeze(-1) - pos).abs()
    k = d.argmin(dim=-1)  # [*], 0..7

    # map k -> (exp, mant)
    exp = torch.clamp((k - 2) // 2 + 1, 0)
    mant = ((k % 2) & 1)
    exp = torch.where(k < 2, torch.zeros_like(exp), exp)
    mant = torch.where(k == 0, torch.zeros_like(mant), mant)

    code = (s.to(torch.int8) << 3) | (exp.to(torch.int8) << 1) | mant.to(torch.int8)
    return code.to(torch.uint8)

def _fp4_e2m1_decode(codes: torch.Tensor) -> torch.Tensor:
    """Decode 4-bit codes (uint8 0..15) to float32."""
    c = codes.to(torch.uint8)
    s   = ((c >> 3) & 0x1).to(torch.int32)
    exp = ((c >> 1) & 0x3).to(torch.int32)
    m   = (c & 0x1).to(torch.int32)

    is_sub = (exp == 0)
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
    s = torch.clamp(s, 2.0**-6, 2.0**7 * 1.75)  # min normal to approx max
    e_unbiased = torch.floor(torch.log2(s))
    e = torch.clamp(e_unbiased + 7.0, 1.0, 14.0)  # 0 reserved for zero
    base = torch.pow(2.0, e - 7.0)
    frac = s / base - 1.0
    m = torch.round(frac * 8.0)
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


# -------- Nibble pack/unpack helpers --------

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


# -------- Q40NL --------

def q40nl_quantize(t: torch.Tensor):
    """Pack per 32: 16 nibbles + fp16 scale (LE). Dequant path: y = f(q/7), out = scale * y"""
    assert t.numel() % 32 == 0
    T = t.to(torch.float32).view(-1, 32)
    tmax = T.abs().amax(dim=1)
    scale = tmax
    scale_safe = torch.where(tmax > 0, tmax, torch.ones_like(tmax))
    Y = torch.clamp(T / scale_safe[:,None], -1.0, 1.0)
    X = _f_inv(Y)
    q = torch.round(7.0 * X).to(torch.int8).clamp_(-7, 7)
    u4 = ((q + 8) & 0x0F).to(torch.uint8)
    qbytes = _pack_nibbles32(u4)
    sbytes = scale.to(torch.float16).view(torch.uint8).view(-1,2)
    return torch.cat([qbytes, sbytes], dim=1).reshape(-1), scale

def q40nl_dequantize(packed: torch.Tensor, out_shape=None):
    P = packed.view(-1,18)
    qbytes, sbytes = P[:,:16], P[:,16:18]
    scale = sbytes.view(torch.float16).to(torch.float32).view(-1)
    u4 = _unpack_nibbles32(qbytes).to(torch.int8)
    q = (u4 - 8).clamp(-7,7).to(torch.float32)
    y = _f_decode(q/7.0)
    out = (scale[:,None] * y).reshape(-1)
    return out.reshape(out_shape) if out_shape is not None else out


# -------- Q41NL (variant: f(x) = x*|x|) --------

def _f41_decode(x: torch.Tensor) -> torch.Tensor:
    """y = x * |x|, x in [-1,1]. Stronger tail emphasis than Q40NL."""
    return x * x.abs()

def _f41_inv(y: torch.Tensor) -> torch.Tensor:
    """x = sign(y) * sqrt(|y|), exact inverse for y in [-1,1]."""
    ay = y.abs()
    return torch.sign(y) * torch.sqrt(ay)

def q41nl_quantize(t: torch.Tensor):
    """Same block structure as Q40NL (per-32, fp16 absmax); nonlinearity f41."""
    assert t.numel() % 32 == 0
    T = t.to(torch.float32).view(-1, 32)
    tmax = T.abs().amax(dim=1)
    scale = tmax
    scale_safe = torch.where(tmax > 0, tmax, torch.ones_like(tmax))
    Y = torch.clamp(T / scale_safe[:,None], -1.0, 1.0)
    X = _f41_inv(Y)
    q = torch.round(7.0 * X).to(torch.int8).clamp_(-7, 7)
    u4 = ((q + 8) & 0x0F).to(torch.uint8)
    qbytes = _pack_nibbles32(u4)
    sbytes = scale.to(torch.float16).view(torch.uint8).view(-1,2)
    return torch.cat([qbytes, sbytes], dim=1).reshape(-1), scale

def q41nl_dequantize(packed: torch.Tensor, out_shape=None):
    P = packed.view(-1,18)
    qbytes, sbytes = P[:,:16], P[:,16:18]
    scale = sbytes.view(torch.float16).to(torch.float32).view(-1)
    u4 = _unpack_nibbles32(qbytes).to(torch.int8)
    q = (u4 - 8).clamp(-7,7).to(torch.float32)
    y = _f41_decode(q/7.0)
    out = (scale[:,None] * y).reshape(-1)
    return out.reshape(out_shape) if out_shape is not None else out


# -------- Q42NL (adaptive curve, FP8 E5M2 scale) --------

def q42nl_quantize(t: torch.Tensor, grid_size: int = 255):
    """Q42NL: 18 bytes/32 = 16 nibbles + 1 FP8 E5M2 scale + 1 int8 curve parameter."""
    assert t.numel() % 32 == 0
    T = t.to(torch.float32).view(-1, 32)
    G = T.shape[0]
    dev = T.device
    
    # FP8 E5M2 scale with round-up
    tmax = T.abs().amax(dim=1)
    scale = tmax.clone()
    scale_fp8 = scale.to(torch.float8_e5m2)
    scale_rounded = scale_fp8.to(torch.float32)
    is_finite = torch.isfinite(scale_rounded) & torch.isfinite(scale)
    needs_up = (scale_rounded < scale) & (scale > 0) & is_finite
    scale_bytes = scale_fp8.view(torch.uint8)
    scale_bytes_up = (scale_bytes + 1).clamp(max=255)
    scale_up = scale_bytes_up.view(torch.float8_e5m2).to(torch.float32)
    safe_to_up = needs_up & torch.isfinite(scale_up)
    scale_bytes = torch.where(safe_to_up, scale_bytes_up, scale_bytes)
    scale = scale_bytes.view(torch.float8_e5m2).to(torch.float32)
    
    # Normalize
    scale_safe = torch.where(scale > 0, scale, torch.ones_like(scale))
    Y = torch.clamp(T / scale_safe[:, None], -1.0, 1.0)
    
    # Grid search for optimal curve parameter c
    K = int(grid_size)
    C = torch.linspace(-1.0, 1.0, K, device=dev, dtype=torch.float32)
    if K == 255:
        C = torch.clamp(torch.round(C * 127.0), min=-128, max=127).to(torch.int8).to(torch.float32) / 127.0
    Cb = C.view(K, 1, 1)
    
    A = Y.abs().unsqueeze(0)
    S = Y.sign().unsqueeze(0)
    A_b = A.expand(K, G, 32)
    S_b = S.expand(K, G, 32)
    
    tiny = 1e-6
    mask_id = (Cb.abs() < tiny)
    mask_sq = (Cb >= 1.0)
    mask_qc = (Cb <= -1.0)
    mask_gen = ~(mask_id | mask_sq | mask_qc)
    
    m_id = mask_id.expand(K, G, 32)
    m_sq = mask_sq.expand(K, G, 32)
    m_qc = mask_qc.expand(K, G, 32)
    m_gen = mask_gen.expand(K, G, 32)
    
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
    
    q_all = torch.round(7.0 * X).clamp_(-7, 7).to(torch.int8)
    xq = q_all.to(torch.float32) / 7.0
    yhat = (1.0 - Cb) * xq + Cb * (xq.abs() * xq)
    
    Terr = T.unsqueeze(0) - (yhat * scale.view(1, G, 1))
    err = (Terr * Terr).sum(dim=-1)
    best_idx = err.argmin(dim=0)
    best_c = C[best_idx]
    
    idx = best_idx.view(1, G, 1).expand(1, G, 32)
    q_best = q_all.gather(dim=0, index=idx).squeeze(0)
    
    # Pack
    u4 = ((q_best + 8) & 0x0F).to(torch.uint8)
    lo = (u4[:, 0::2] & 0x0F)
    hi = ((u4[:, 1::2] & 0x0F) << 4)
    qbytes = (lo | hi)
    sbytes = scale.to(torch.float8_e5m2).view(torch.uint8).view(-1, 1)
    cbytes_i8 = torch.clamp(torch.round(best_c * 127.0), min=-128, max=127).to(torch.int8)
    cbytes = cbytes_i8.view(torch.uint8).view(-1, 1)
    
    packed = torch.cat([qbytes, sbytes, cbytes], dim=1).reshape(-1)
    return packed.contiguous().to(torch.uint8), scale

def q42nl_dequantize(packed: torch.Tensor, out_shape=None):
    G = packed.numel() // 18
    buf = packed.view(G, 18)
    qbytes = buf[:, :16]
    s = buf[:, 16].view(torch.float8_e5m2).to(torch.float32)
    c = buf[:, 17].view(torch.int8).to(torch.float32) / 127.0
    u4 = torch.empty(G, 32, dtype=torch.uint8, device=packed.device)
    u4[:, 0::2] = qbytes & 0x0F
    u4[:, 1::2] = (qbytes >> 4) & 0x0F
    q = (u4.to(torch.int16) - 8).to(torch.float32) / 7.0
    y = (1.0 - c.view(-1, 1)) * q + c.view(-1, 1) * (q.abs() * q)
    out = (y * s.view(-1, 1)).view(-1)
    return out.reshape(out_shape) if out_shape is not None else out


# -------- Q43NL (adaptive curve, FP16 scale) --------

def q43nl_quantize(t: torch.Tensor, grid_size: int = 65536):
    """Q43NL: 19 bytes/32 = 16 nibbles + 1 FP16 scale + 1 int8 curve parameter.
    Default grid_size=65536 searches ALL FP16 values in [-1,1] in GPU chunks of 256."""
    assert t.numel() % 32 == 0
    T = t.to(torch.float32).view(-1, 32)
    G = T.shape[0]
    dev = T.device
    
    # FP16 scale with round-up
    tmax = T.abs().amax(dim=1)
    scale = tmax.clone()
    scale_fp16 = scale.to(torch.float16)
    scale_rounded = scale_fp16.to(torch.float32)
    is_finite = torch.isfinite(scale_rounded) & torch.isfinite(scale)
    needs_up = (scale_rounded < scale) & (scale > 0) & is_finite
    scale_words = scale_fp16.view(torch.uint16)
    scale_words_up = ((scale_words.to(torch.int32) + 1).clamp(max=0xFFFF)).to(torch.uint16)
    scale_up = scale_words_up.view(torch.float16).to(torch.float32)
    safe_to_up = needs_up & torch.isfinite(scale_up)
    scale_words = torch.where(safe_to_up, scale_words_up.to(torch.int32), scale_words.to(torch.int32)).to(torch.uint16)
    scale = scale_words.view(torch.float16).to(torch.float32)
    
    # Normalize
    scale_safe = torch.where(scale > 0, scale, torch.ones_like(scale))
    Y = torch.clamp(T / scale_safe[:, None], -1.0, 1.0)
    
    # Grid search for optimal curve parameter c
    K = int(grid_size)
    if K == 65536:
        # Exhaustive search over ALL 65536 FP16 values in chunks of 256
        all_u16 = torch.arange(0, 65536, dtype=torch.int32, device='cpu')
        C_cpu = all_u16.to(torch.uint16).view(torch.float16).to(torch.float32)
        # Filter to valid range [-1, 1] and remove NaN/Inf
        valid_mask = (C_cpu >= -1.0) & (C_cpu <= 1.0) & torch.isfinite(C_cpu)
        C_all = C_cpu[valid_mask]
        K_total = C_all.shape[0]
        
        # Process in chunks of 256
        chunk_size = 256
        best_err = torch.full((G,), float('inf'), device=dev)
        best_c = torch.zeros(G, device=dev)
        best_q = torch.zeros((G, 32), dtype=torch.int8, device=dev)
        
        for chunk_start in range(0, K_total, chunk_size):
            chunk_end = min(chunk_start + chunk_size, K_total)
            C = C_all[chunk_start:chunk_end].to(dev)
            K_chunk = C.shape[0]
            Cb = C.view(K_chunk, 1, 1)
            
            A = Y.abs().unsqueeze(0)
            S = Y.sign().unsqueeze(0)
            A_b = A.expand(K_chunk, G, 32)
            S_b = S.expand(K_chunk, G, 32)
            
            tiny = 1e-6
            mask_id = (Cb.abs() < tiny)
            mask_sq = (Cb >= 1.0)
            mask_qc = (Cb <= -1.0)
            mask_gen = ~(mask_id | mask_sq | mask_qc)
            
            m_id = mask_id.expand(K_chunk, G, 32)
            m_sq = mask_sq.expand(K_chunk, G, 32)
            m_qc = mask_qc.expand(K_chunk, G, 32)
            m_gen = mask_gen.expand(K_chunk, G, 32)
            
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
            X_chunk = x_nonneg * S_b
            
            q_all = torch.round(7.0 * X_chunk).clamp_(-7, 7).to(torch.int8)
            xq = q_all.to(torch.float32) / 7.0
            yhat = (1.0 - Cb) * xq + Cb * (xq.abs() * xq)
            
            Terr = T.unsqueeze(0) - (yhat * scale.view(1, G, 1))
            err = (Terr * Terr).sum(dim=-1)
            
            # Update best
            chunk_best_idx = err.argmin(dim=0)
            chunk_best_err = err.gather(0, chunk_best_idx.unsqueeze(0)).squeeze(0)
            improve_mask = chunk_best_err < best_err
            best_err = torch.where(improve_mask, chunk_best_err, best_err)
            best_c = torch.where(improve_mask, C[chunk_best_idx], best_c)
            idx = chunk_best_idx.view(1, G, 1).expand(1, G, 32)
            chunk_q = q_all.gather(dim=0, index=idx).squeeze(0)
            best_q = torch.where(improve_mask.unsqueeze(1), chunk_q, best_q)
        
        q_best = best_q
    else:
        C = torch.linspace(-1.0, 1.0, K, device=dev, dtype=torch.float32)
        if K == 255:
            C = torch.clamp(torch.round(C * 127.0), min=-128, max=127).to(torch.int8).to(torch.float32) / 127.0
        Cb = C.view(K, 1, 1)
    
        A = Y.abs().unsqueeze(0)
        S = Y.sign().unsqueeze(0)
        A_b = A.expand(K, G, 32)
        S_b = S.expand(K, G, 32)
        
        tiny = 1e-6
        mask_id = (Cb.abs() < tiny)
        mask_sq = (Cb >= 1.0)
        mask_qc = (Cb <= -1.0)
        mask_gen = ~(mask_id | mask_sq | mask_qc)
        
        m_id = mask_id.expand(K, G, 32)
        m_sq = mask_sq.expand(K, G, 32)
        m_qc = mask_qc.expand(K, G, 32)
        m_gen = mask_gen.expand(K, G, 32)
        
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
        
        q_all = torch.round(7.0 * X).clamp_(-7, 7).to(torch.int8)
        xq = q_all.to(torch.float32) / 7.0
        yhat = (1.0 - Cb) * xq + Cb * (xq.abs() * xq)
        
        Terr = T.unsqueeze(0) - (yhat * scale.view(1, G, 1))
        err = (Terr * Terr).sum(dim=-1)
        best_idx = err.argmin(dim=0)
        best_c = C[best_idx]
        
        idx = best_idx.view(1, G, 1).expand(1, G, 32)
        q_best = q_all.gather(dim=0, index=idx).squeeze(0)
    
    # Common packing for both paths
    zero_mask = (scale <= 1e-6)
    
    # Pack
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
    return packed.contiguous().to(torch.uint8), scale

def q43nl_dequantize(packed: torch.Tensor, out_shape=None):
    G = packed.numel() // 19
    buf = packed.view(G, 19)
    qbytes = buf[:, :16]
    s = buf[:, 16:18].reshape(-1).view(torch.float16).to(torch.float32)
    c = buf[:, 18].view(torch.int8).to(torch.float32) / 127.0
    u4 = torch.empty(G, 32, dtype=torch.uint8, device=packed.device)
    u4[:, 0::2] = qbytes & 0x0F
    u4[:, 1::2] = (qbytes >> 4) & 0x0F
    q = (u4.to(torch.int16) - 8).to(torch.float32) / 7.0
    y = (1.0 - c.view(-1, 1)) * q + c.view(-1, 1) * (q.abs() * q)
    out = (y * s.view(-1, 1)).view(-1)
    return out.reshape(out_shape) if out_shape is not None else out


# -------- Q40 (linear) --------

def q40_quantize(t: torch.Tensor):
    """Linear Q4 per 32 with fp16 scale (like ggml Q4_0)."""
    assert t.numel() % 32 == 0
    T = t.to(torch.float32).view(-1, 32)
    tmax = T.abs().amax(dim=1)
    scale = tmax
    scale_safe = torch.where(tmax > 0, tmax, torch.ones_like(tmax))
    X = torch.clamp(T / scale_safe[:,None], -1.0, 1.0)
    q = torch.round(7.0 * X).to(torch.int8).clamp_(-7, 7)
    u4 = ((q + 8) & 0x0F).to(torch.uint8)
    qbytes = _pack_nibbles32(u4)
    sbytes = scale.to(torch.float16).view(torch.uint8).view(-1,2)
    return torch.cat([qbytes, sbytes], dim=1).reshape(-1), scale

def q40_dequantize(packed: torch.Tensor, out_shape=None):
    P = packed.view(-1,18)
    qbytes, sbytes = P[:,:16], P[:,16:18]
    scale = sbytes.view(torch.float16).to(torch.float32).view(-1)
    u4 = _unpack_nibbles32(qbytes).to(torch.int8)
    q = (u4 - 8).clamp(-7,7).to(torch.float32)
    y = q / 7.0
    out = (scale[:,None] * y).reshape(-1)
    return out.reshape(out_shape) if out_shape is not None else out


# -------- Q80 (linear 8-bit) --------

def q80_quantize(t: torch.Tensor):
    """Linear Q8 per 32 with fp16 scale."""
    assert t.numel() % 32 == 0
    T = t.to(torch.float32).view(-1, 32)
    tmax = T.abs().amax(dim=1)
    scale = tmax / 127.0
    scale_safe = torch.where(scale > 0, scale, torch.ones_like(scale))
    q = torch.round(T / scale_safe[:,None]).to(torch.int16).clamp_(-127, 127).to(torch.int8)  # [G,32]
    qbytes = q.view(torch.uint8).view(-1,32)   # reinterpret as bytes
    sbytes = scale.to(torch.float16).view(torch.uint8).view(-1,2)
    return torch.cat([qbytes, sbytes], dim=1).reshape(-1), scale

def q80_dequantize(packed: torch.Tensor, out_shape=None):
    P = packed.view(-1,34)             # 32 codes + 2 scale bytes
    qbytes, sbytes = P[:,:32], P[:,32:34]
    q = qbytes.view(torch.int8).to(torch.float32)
    scale = sbytes.view(torch.float16).to(torch.float32).view(-1,1)
    out = (q * scale).reshape(-1)
    return out.reshape(out_shape) if out_shape is not None else out


# -------- IQ4_NL (ggml/gguf) --------

def iq4_nl_quantize(t: torch.Tensor):
    """Per 32: fp16 scale = max|t|; quantize normalized values to nearest LUT entry. Pack 16 nibbles + fp16 scale (LE)."""
    assert t.numel() % 32 == 0
    T = t.to(torch.float32).view(-1, 32)
    tmax = T.abs().amax(dim=1)
    scale = tmax
    scale_safe = torch.where(tmax > 0, tmax, torch.ones_like(tmax))
    Y = torch.clamp(T / scale_safe[:,None], -1.0, 1.0)
    idx = _nearest_lut_index(Y, _IQ4NL_LUT_INT8)  # [G,32] 0..15
    qbytes = _pack_nibbles32(idx)
    sbytes = scale.to(torch.float16).view(torch.uint8).view(-1,2)
    return torch.cat([qbytes, sbytes], dim=1).reshape(-1), scale

def iq4_nl_dequantize(packed: torch.Tensor, out_shape=None):
    P = packed.view(-1,18)
    idx = _unpack_nibbles32(P[:,:16])
    lut = _IQ4NL_LUT_INT8.to(packed.device).to(torch.float32) / 127.0
    y = lut[idx.to(torch.long)]
    scale = P[:,16:18].view(torch.float16).to(torch.float32).view(-1,1)
    out = (scale * y).reshape(-1)
    return out.reshape(out_shape) if out_shape is not None else out


# -------- MXFP4 (k=32, E8M0 scale) --------

def mxfp4_quantize(t: torch.Tensor):
    """Per 32: choose E8M0 scale S to map values into FP4(E2M1). Return codes [G*32] (0..15) and scale bytes [G] (E8M0)."""
    assert t.numel() % 32 == 0
    T = t.to(torch.float32).view(-1,32)
    tmax = T.abs().amax(dim=1)
    ideal = torch.clamp(tmax / 6.0, min=1e-30)
    sb = _e8m0_from_float(ideal)
    S = _e8m0_to_float(sb)
    Y = (T / S[:,None])
    codes = _fp4_e2m1_encode(Y)
    return codes.reshape(-1), sb

def mxfp4_pack(codes: torch.Tensor, sb: torch.Tensor) -> torch.Tensor:
    """Pack: 16 nibble bytes + 1 scale byte per block (17 bytes)."""
    G = sb.numel()
    C = codes.view(G,32)
    b16 = _pack_nibbles32(C)
    return torch.cat([b16, sb.view(-1,1)], dim=1).reshape(-1).to(torch.uint8)

def mxfp4_unpack(packed: torch.Tensor):
    P = packed.view(-1,17)
    b16, sb = P[:,:16], P[:,16]
    codes = _unpack_nibbles32(b16)
    return codes.reshape(-1), sb.contiguous()

def mxfp4_dequantize_packed(packed: torch.Tensor, out_shape=None):
    P = packed.view(-1,17)
    b16, sb = P[:,:16], P[:,16]
    codes = _unpack_nibbles32(b16)
    vals  = _fp4_e2m1_decode(codes)
    S = _e8m0_to_float(sb).to(vals.dtype).view(-1,1)
    out = (vals * S).reshape(-1)
    return out.reshape(out_shape) if out_shape is not None else out


# -------- NVFP4 (k=16, E4M3 scale) --------

def nvfp4_quantize(t: torch.Tensor):
    """Per 16: FP4(E2M1) codes + E4M3 scale byte (unpacked return)."""
    assert t.numel() % 16 == 0
    T = t.to(torch.float32).view(-1,16)
    tmax = T.abs().amax(dim=1)
    ideal = torch.clamp(tmax / 6.0, min=2.0**-6)
    sb = _e4m3_from_float(ideal)
    S = _e4m3_to_float(sb)
    codes = _fp4_e2m1_encode(T / S[:,None])
    return codes.reshape(-1), sb

def nvfp4_pack(codes: torch.Tensor, sb: torch.Tensor) -> torch.Tensor:
    """Pack: 8 nibble bytes + 1 E4M3 scale byte per block (9 bytes)."""
    G = sb.numel()
    C = codes.view(G,16)
    b8 = _pack_nibbles16(C)
    return torch.cat([b8, sb.view(-1,1)], dim=1).reshape(-1).to(torch.uint8)

def nvfp4_unpack(packed: torch.Tensor):
    P = packed.view(-1,9)
    b8, sb = P[:,:8], P[:,8]
    codes = _unpack_nibbles16(b8)
    return codes.reshape(-1), sb.contiguous()

def nvfp4_dequantize_packed(packed: torch.Tensor, out_shape=None):
    P = packed.view(-1,9)
    b8, sb = P[:,:8], P[:,8]
    codes = _unpack_nibbles16(b8)
    vals  = _fp4_e2m1_decode(codes)
    S = _e4m3_to_float(sb).to(vals.dtype).view(-1,1)
    out = (vals * S).reshape(-1)
    return out.reshape(out_shape) if out_shape is not None else out


# -------- NF4 (Simple: codebook only, no scale; kept for backward compatibility) --------

NF4_K = torch.tensor([
    -1.0000, -0.6962, -0.5253, -0.3949,
    -0.2845, -0.1882, -0.1007, -0.0185,
     0.0185,  0.1007,  0.1882,  0.2845,
     0.3949,  0.5253,  0.6962,  1.0000
], dtype=torch.float32)

def nf4_quantize(t: torch.Tensor) -> torch.Tensor:
    """Blockless NF4 using a fixed 16-value codebook NF4_K (uint8 indices packed into nibbles)."""
    T = t.to(torch.float32).view(-1,32)  # group to 32 for consistent packing/printing
    dev = T.device
    cb = NF4_K.to(dev)
    idx = (T.unsqueeze(-1) - cb.view(1,1,-1)).abs().argmin(dim=-1).to(torch.uint8)  # [G,32]
    return _pack_nibbles32(idx).reshape(-1)  # no scale

def nf4_dequantize_packed(packed: torch.Tensor, out_shape=None) -> torch.Tensor:
    b16 = packed.view(-1,16)
    idx = _unpack_nibbles32(b16).to(torch.long)  # [G,32]
    cb  = NF4_K.to(packed.device)
    out = cb[idx].reshape(-1)
    return out.reshape(out_shape) if out_shape is not None else out


# -------- NF4 (Canonical QLoRA centers + absmax fp16 scale per 64) --------

# Centers from QLoRA Appendix E
NF4_QLORA = torch.tensor([
    -1.00000000, -0.69619280, -0.52507305, -0.39491749,
    -0.28444138, -0.18477343, -0.09105004,  0.00000000,
     0.07958030,  0.16093020,  0.24611229,  0.33791524,
     0.44070983,  0.56261700,  0.72295684,  0.93779105
], dtype=torch.float32)

def nf4_bs64_quantize(t: torch.Tensor):
    """
    Canonical NF4: per 64 values, store 32 nibble bytes (two lanes of 16) + fp16 scale (absmax of the block).
    Returns packed [G*34] bytes (uint8) and the fp32 scales for reference.
    """
    assert t.numel() % 64 == 0
    T = t.to(torch.float32).view(-1,64)
    s = T.abs().amax(dim=1)
    s_safe = torch.where(s > 0, s, torch.ones_like(s))
    Y = torch.clamp(T / s_safe[:,None], -1.0, 1.0)
    cb = NF4_QLORA.to(T.device)
    idx = (Y.unsqueeze(-1) - cb.view(1,1,-1)).abs().argmin(dim=-1).to(torch.uint8)  # [G,64]
    idxA, idxB = idx[:,:32], idx[:,32:]
    bA = _pack_nibbles32(idxA)
    bB = _pack_nibbles32(idxB)
    sbytes = s.to(torch.float16).view(torch.uint8).view(-1,2)
    packed = torch.cat([bA, bB, sbytes], dim=1).reshape(-1).to(torch.uint8)  # 16+16+2 = 34
    return packed, s

def nf4_bs64_dequantize_packed(packed: torch.Tensor, out_shape=None):
    P = packed.view(-1,34)
    bA, bB, sbytes = P[:,:16], P[:,16:32], P[:,32:34]
    idxA = _unpack_nibbles32(bA)
    idxB = _unpack_nibbles32(bB)
    idx = torch.cat([idxA, idxB], dim=1)  # [G,64]
    cb = NF4_QLORA.to(packed.device)
    y = cb[idx.to(torch.long)]
    s = sbytes.view(torch.float16).to(torch.float32).view(-1,1)
    out = (s * y).reshape(-1)
    return out.reshape(out_shape) if out_shape is not None else out


# -------- Float baselines --------

def fp16_cast(t: torch.Tensor) -> torch.Tensor:
    """Per-element float16 cast baseline (quantize to fp16, then dequant to fp32)."""
    return t.to(torch.float16).to(torch.float32)

def bf16_cast(t: torch.Tensor) -> torch.Tensor:
    """Per-element bfloat16 cast baseline (quantize to bf16, then dequant to fp32)."""
    return t.to(torch.bfloat16).to(torch.float32)

def fp32_identity(t: torch.Tensor) -> torch.Tensor:
    """Identity baseline (should produce ~zero error vs truth aside from dtype)."""
    return t.to(torch.float32)


# -------- Pretty dumps --------

def dump_q40nl_block(packed: torch.Tensor, block_idx: int):
    P = packed.view(-1, 18)
    G = P.size(0)
    if block_idx < 0: block_idx += G
    pb = P[block_idx]
    b16 = pb[:16]; sbytes = pb[16:18]
    scale = sbytes.view(torch.float16).item()
    print(f"\n[Q40NL] block {block_idx}/{G-1}")
    print(f"bytes (16 nibbles + fp16 scale): {_hex_bytes(pb)}")
    print(f"fp16 scale bytes: {_hex_bytes(sbytes)}  => scale={scale:.6g}")
    u4 = _unpack_nibbles32(b16)
    q  = (u4.to(torch.int8) - 8).clamp(-7, 7)
    x  = q.to(torch.float32) / 7.0
    y  = _f_decode(x)
    w  = y * float(scale)
    print(f"u4[0:8]:  {u4[0,:8].tolist()}")
    print(f"q[0:8]:   {q[0,:8].tolist()}")
    print(f"y[0:8]:   {[float(v) for v in y[0,:8]]}")
    print(f"w[0:8]:   {[float(v) for v in w[0,:8]]}")

def dump_iq4nl_block(packed: torch.Tensor, block_idx: int):
    P = packed.view(-1, 18)
    G = P.size(0)
    if block_idx < 0: block_idx += G
    pb = P[block_idx]
    b16 = pb[:16]; sbytes = pb[16:18]
    scale = sbytes.view(torch.float16).item()
    print(f"\n[IQ4_NL] block {block_idx}/{G-1}")
    print(f"bytes (16 nibbles + fp16 scale): {_hex_bytes(pb)}")
    print(f"fp16 scale bytes: {_hex_bytes(sbytes)}  => scale={scale:.6g}")
    idx = _unpack_nibbles32(b16)
    lut = (_IQ4NL_LUT_INT8.to(packed.device).to(torch.float32) / 127.0).view(1, -1)
    y   = lut[0, idx[0].to(torch.long)]
    w   = y * float(scale)
    print(f"idx[0:8]: {idx[0,:8].tolist()}")
    print(f"lut[0:8]: {[float(v) for v in y[:8]]}")
    print(f"w[0:8]:   {[float(v) for v in w[:8]]}")

def dump_mxfp4_block(packed: torch.Tensor, block_idx: int):
    P = packed.view(-1,17)
    G = P.size(0)
    if block_idx < 0: block_idx += G
    pb = P[block_idx]; b16 = pb[:16]; sb = pb[16]
    print(f"\n[MXFP4] block {block_idx}/{G-1}")
    print(f"bytes (16 nibbles + E8M0 scale): {_hex_bytes(pb)}")
    print(f"E8M0 scale byte: {int(sb)}  => S={float(_e8m0_to_float(sb)):.6g}")
    codes = _unpack_nibbles32(b16); vals  = _fp4_e2m1_decode(codes)
    print(f"codes[0:8]: {codes[0,:8].tolist()}  vals[0:8]: {[float(x) for x in vals[0,:8]]}")

def dump_nvfp4_block(packed: torch.Tensor, block_idx: int):
    P = packed.view(-1,9)
    G = P.size(0)
    if block_idx < 0: block_idx += G
    pb = P[block_idx]; b8 = pb[:8]; sb = pb[8]
    print(f"\n[NVFP4] block {block_idx}/{G-1}")
    print(f"bytes (8 nibbles + E4M3 scale): {_hex_bytes(pb)}")
    print(f"E4M3 scale byte: {int(sb)}  => S={float(_e4m3_to_float(sb)):.6g}")
    codes = _unpack_nibbles16(b8); vals  = _fp4_e2m1_decode(codes)
    print(f"codes[0:8]: {codes[0,:8].tolist()}  vals[0:8]: {[float(x) for x in vals[0,:8]]}")

def dump_nf4_bs64_block(packed: torch.Tensor, block_idx: int):
    P = packed.view(-1,34)
    G = P.size(0)
    if block_idx < 0: block_idx += G
    pb = P[block_idx]
    bA, bB, sbytes = pb[:16], pb[16:32], pb[32:34]
    scale = sbytes.view(torch.float16).item()
    idxA = _unpack_nibbles32(bA)[0]
    idxB = _unpack_nibbles32(bB)[0]
    print(f"\n[NF4_BS64] block {block_idx}/{G-1}")
    print(f"bytes (32 nibbles + fp16): {_hex_bytes(pb)}")
    print(f"scale bytes: {_hex_bytes(sbytes)}  => scale={scale:.6g}")
    print(f"idxA[0:8]: {idxA[:8].tolist()}  idxB[0:8]: {idxB[:8].tolist()}")


# -------- Metrics --------

def _metrics(name: str, rec: torch.Tensor, ref: torch.Tensor) -> Dict[str, float]:
    diff = (rec - ref).abs()
    maxe = float(diff.max())
    meane = float(diff.mean())
    p99 = float(torch.quantile(diff, 0.99))
    print(f"{name:10s}  max|e|={maxe:.6g}  mean|e|={meane:.6g}  p99|e|={p99: .6g}")
    return {"max": maxe, "mean": meane, "p99": p99}

def _dot_stats(
    name: str,
    rec: torch.Tensor,
    ref: torch.Tensor,
    X: torch.Tensor,
    block_size: Optional[int] = None,
) -> Dict[str, float]:
    """
    Dot stats vs truth. If block_size is given, also compute the median absolute
    per-block dot error (|Δ·|) over contiguous blocks of that size.
    """
    # Full-vector dot
    truth = float((ref * X).sum())
    got   = float((rec * X).sum())
    d = got - truth

    # Default: median |Δ·| equals the full absolute error
    median_abs = abs(d)

    # Optional per-block median |Δ·|
    if block_size is not None and block_size > 0:
        n = rec.numel()
        usable = (n // block_size) * block_size
        if usable > 0:
            rb = rec.view(-1)[:usable].view(-1, block_size)
            fb = ref.view(-1)[:usable].view(-1, block_size)
            xb = X.view(-1)[:usable].view(-1, block_size)
            got_b   = (rb * xb).sum(dim=1)     # [#blocks]
            truth_b = (fb * xb).sum(dim=1)     # [#blocks]
            d_b = got_b - truth_b              # [#blocks]
            median_abs = float(d_b.abs().median())

    print(f"{name:10s}  dot={got: .6e}   Δ={d: .6e}   med|Δ·|={median_abs: .6e}")
    return {
        "dot": got,
        "delta": d,
        "absdelta": abs(d),
        "median_absdelta": median_abs
    }

# -------- Gaussian-distribution mapping diagnostics --------
def _gaussian_eval(
    name: str,
    rec: torch.Tensor,
    ref: torch.Tensor,
    bins: int = 201,
) -> Dict[str, float]:
    """
    Diagnostics tailored for Gaussian-distributed `ref` data.
    Quantifies how well `rec` maps a N(0, σ²)-like `ref`:

      - pearson_r: Pearson correlation between ref and rec (higher is better)
      - slope/intercept: linear fit rec ≈ slope*ref + intercept
      - slope_err: |slope-1| (lower is better)
      - intercept_abs: |intercept| (lower is better)
      - qq_mae: mean absolute difference between sorted(rec) and sorted(ref)
      - jsd: Jensen–Shannon divergence (nats) between histograms over ±6σ
    """
    with torch.no_grad():
        # Moments and Pearson r
        xm = ref.mean()
        ym = rec.mean()
        vx = ref - xm
        vy = rec - ym

        nx = vx.pow(2).sum().sqrt()
        ny = vy.pow(2).sum().sqrt()
        denom = nx * ny + 1e-30
        pearson_r = float((vx * vy).sum() / denom)

        varx = float((vx * vx).mean())
        cov  = float((vx * vy).mean())
        slope = cov / (varx + 1e-30)
        intercept = float(ym - slope * xm)

        slope_err = float(abs(slope - 1.0))
        intercept_abs = float(abs(intercept))

        # σ estimate from ref
        sigma = float(ref.std(unbiased=False))

        # Q–Q MAE (empirical quantiles)
        xs = torch.sort(ref.flatten()).values
        ys = torch.sort(rec.flatten()).values
        # If lengths differ, interpolate the shorter to the longer
        if xs.numel() != ys.numel():
            n = max(xs.numel(), ys.numel())
            def _interp(a, n):
                idx = torch.linspace(0, a.numel() - 1, n, device=a.device)
                i0 = idx.floor().long()
                i1 = (i0 + 1).clamp_max(a.numel() - 1)
                t = (idx - i0).to(a.dtype)
                return a[i0] * (1 - t) + a[i1] * t
            xsq = _interp(xs, n)
            ysq = _interp(ys, n)
        else:
            xsq, ysq = xs, ys
        qq_mae = float((ysq - xsq).abs().mean())

        # Jensen–Shannon divergence over ±6σ (histogram-based)
        lo, hi = -6.0 * sigma, 6.0 * sigma
        if not (hi > lo):  # degenerate σ
            lo, hi = -1e-3, 1e-3
        p = torch.histc(ref, bins=bins, min=lo, max=hi).to(torch.float64)
        q = torch.histc(rec, bins=bins, min=lo, max=hi).to(torch.float64)
        p = (p + 1e-12) / (p.sum() + 1e-12)
        q = (q + 1e-12) / (q.sum() + 1e-12)
        m = 0.5 * (p + q)
        jsd = 0.5 * float((p * (p / m).log()).sum() + (q * (q / m).log()).sum())

        print(
            f"{name:10s}  gauss σ≈{sigma:.6g}  r={pearson_r:.6f}  "
            f"slope={slope:.6f}  |slope-1|={slope_err:.6g}  "
            f"|b|={intercept_abs:.6g}  qq_mae={qq_mae:.6g}  JSD={jsd: .6g}"
        )
        return {
            "sigma": sigma,
            "pearson_r": pearson_r,
            "slope": slope,
            "intercept": intercept,
            "slope_err": slope_err,
            "intercept_abs": intercept_abs,
            "qq_mae": qq_mae,
            "jsd": jsd,
        }
   
# -------- Runner --------

def run(device: Optional[str] = None, groups32: int = 1024, seed: int = 1234, dump: bool = False, emit_md: bool = False):
    if device is None:
        device = "cuda" if torch.cuda.is_available() else "cpu"
    print(f"Device: {device}")
    torch.manual_seed(seed)

    # build test tensor: random + edgey tails
    G32 = groups32
    T = (torch.randn(G32*32, device=device) * 3.5)
    edges = torch.tensor([0.0, 1e-8, -1e-8, 1.0, -1.0, 6.0, -6.0, 10.0, -10.0,
                          0.5, -0.5, 2.0, -2.0, 3.0, -3.0, 4.0, -4.0], device=device)
    pad = (-edges.numel()) % 32
    if pad: edges = F.pad(edges, (0, pad))
    T = torch.cat([T[:-32], edges], dim=0)  # keep total multiple of 32

    # Ensure we have a multiple of 64 slice for NF4_BS64
    T64 = T[: (T.numel() // 64) * 64]
    if T64.numel() == 0:
        # If groups32 < 2, extend T minimally
        extra = torch.zeros(64, device=device)
        T = torch.cat([T, extra], dim=0)
        T64 = T[: (T.numel() // 64) * 64]

    X = torch.randn_like(T)
    X64 = X[:T64.numel()]

    # Evaluate
    results = {}

    def add_variant_results(name: str, rec: torch.Tensor, ref: torch.Tensor, X: torch.Tensor, block_size: Optional[int] = None):
        results[name] = {
            "metrics": _metrics(name, rec, ref),
            "dot": _dot_stats(name, rec, ref, X, block_size=block_size),
            "gauss": _gaussian_eval(name, rec, ref),
        }

    # Q40NL
    q40_packed, _ = q40nl_quantize(T)
    Q40_rec = q40nl_dequantize(q40_packed, out_shape=T.shape)
    add_variant_results("Q40NL", Q40_rec, T, X, block_size=32)

    # Q41NL
    q41_packed, _ = q41nl_quantize(T)
    Q41_rec = q41nl_dequantize(q41_packed, out_shape=T.shape)
    add_variant_results("Q41NL", Q41_rec, T, X, block_size=32)

    # Q42NL
    q42_packed, _ = q42nl_quantize(T)
    Q42_rec = q42nl_dequantize(q42_packed, out_shape=T.shape)
    add_variant_results("Q42NL", Q42_rec, T, X, block_size=32)

    # Q43NL
    q43_packed, _ = q43nl_quantize(T)
    Q43_rec = q43nl_dequantize(q43_packed, out_shape=T.shape)
    add_variant_results("Q43NL", Q43_rec, T, X, block_size=32)

    # Q40
    q40lin_packed, _ = q40_quantize(T)
    Q40LIN_rec = q40_dequantize(q40lin_packed, out_shape=T.shape)
    add_variant_results("Q40", Q40LIN_rec, T, X, block_size=32)

    # Q80
    q80_packed, _ = q80_quantize(T)
    Q80_rec = q80_dequantize(q80_packed, out_shape=T.shape)
    add_variant_results("Q80", Q80_rec, T, X, block_size=32)

    # IQ4_NL
    iq_packed, _ = iq4_nl_quantize(T)
    IQ_rec = iq4_nl_dequantize(iq_packed, out_shape=T.shape)
    add_variant_results("IQ4_NL", IQ_rec, T, X, block_size=32)

    # MXFP4
    mxfp4_codes, mxfp4_sb = mxfp4_quantize(T)
    mxfp4_packed = mxfp4_pack(mxfp4_codes, mxfp4_sb)
    MX_rec = mxfp4_dequantize_packed(mxfp4_packed, out_shape=T.shape)
    add_variant_results("MXFP4", MX_rec, T, X)  # no block_size

    # NVFP4
    NV_codes, NV_sb = nvfp4_quantize(T.view(-1))  # multiple of 16
    nvfp4_packed = nvfp4_pack(NV_codes, NV_sb)
    NV_rec = nvfp4_dequantize_packed(nvfp4_packed, out_shape=T.shape)
    add_variant_results("NVFP4", NV_rec, T, X, block_size=16)

    # NF4 (simple codebook-only, no scale; length equals T)
    try:
        nf4_packed = nf4_quantize(T)
        NF4_rec = nf4_dequantize_packed(nf4_packed, out_shape=T.shape)
        add_variant_results("NF4", NF4_rec, T, X, block_size=32)
    except Exception as e:
        print(f"[NF4] skipped: {e}")
        results["NF4"] = None

    # NF4_BS64 (canonical absmax+fp16 per 64) — evaluated on the 64-multiple slice
    nf4b_packed, _ = nf4_bs64_quantize(T64)
    NF4B_rec = nf4_bs64_dequantize_packed(nf4b_packed, out_shape=T64.shape)
    add_variant_results("NF4_BS64", NF4B_rec, T64, X64, block_size=64)

    # Float baselines
    FP16_rec = fp16_cast(T)
    add_variant_results("FP16", FP16_rec, T, X, block_size=32)

    BF16_rec = bf16_cast(T)
    add_variant_results("BF16", BF16_rec, T, X, block_size=32)

    FP32_rec = fp32_identity(T)
    add_variant_results("FP32", FP32_rec, T, X, block_size=32)

    if dump:
        dump_q40nl_block(q40_packed, 0)
        dump_q40nl_block(q40_packed, -1)
        dump_iq4nl_block(iq_packed, 0)
        dump_iq4nl_block(iq_packed, -1)
        dump_mxfp4_block(mxfp4_packed, 0)
        dump_mxfp4_block(mxfp4_packed, -1)
        dump_nvfp4_block(nvfp4_packed, 0)
        dump_nvfp4_block(nvfp4_packed, -1)
        dump_nf4_bs64_block(nf4b_packed, 0)
        dump_nf4_bs64_block(nf4b_packed, -1)

    if emit_md:
        # Make a compact Markdown table
        def fmt(v):
            return "—" if v is None else f"{v:.6f}"

        order = ["Q40NL", "Q41NL", "Q42NL", "Q43NL", "Q40", "Q80", "IQ4_NL", "NVFP4", "MXFP4", "NF4", "NF4_BS64", "FP16", "BF16", "FP32"]

        orderWithBold = ["**" + k + "**" for k in order]

        eligible_idx = [i for i,k in enumerate(order) if k not in ("Q80", "FP16", "BF16", "FP32")]  # ignore these for "best"
    
        def _pick_best(vals, consider_idx, best="min", use_abs=False, eps=1e-12):
            cand = []
            for i in consider_idx:
                v = vals[i]
                if v is None or (isinstance(v, float) and v != v):  # None or NaN
                    continue
                cand.append((i, abs(v) if use_abs else v))
            if not cand:
                return set()
            target_val = (min if best == "min" else max)(c for _, c in cand)
            return {i for i, c in cand if abs(c - target_val) <= eps * (1.0 + abs(target_val))}

        def _add_row(rows, title, getter, best="min", use_abs=False):
            vals = [getter(results.get(k)) if results.get(k) else None for k in order]
            winners = _pick_best(vals, eligible_idx, best=best, use_abs=use_abs)
            cells = []
            for i, v in enumerate(vals):
                s = fmt(v)
                if i in winners and s != "—":
                    s = f"**{s}**"
                cells.append(s)
            rows.append(f"| {title} | " + " | ".join(cells) + " |")

        header = "| **metric** | " + " | ".join(orderWithBold) + " |"
        sep    = "|---:|"+ "|".join(["---:"]*len(orderWithBold)) + "|"
        rows = [header, sep]

        _add_row(rows, "**mean ∣e∣ (abs error)**",              lambda r: r.get("metrics",{}).get("mean") if r else None,  best="min")
        _add_row(rows, "**p99 ∣e∣ (abs error)**",               lambda r: r.get("metrics",{}).get("p99")  if r else None,  best="min")
        _add_row(rows, "**avg ∣Δ·∣ (abs dot error)**",          lambda r: r.get("dot",{}).get("absdelta") if r else None,  best="min")
        _add_row(rows, "**median ∣Δ·∣ (abs dot error)**",       lambda r: r.get("dot",{}).get("median_absdelta") if r else None, best="min")
        _add_row(rows, "**mean Δ· (abs dot error, signed)**",   lambda r: r.get("dot",{}).get("delta")    if r else None,  best="min", use_abs=True)

        _add_row(rows, "**Gaussian: Pearson r**",             lambda r: r.get("gauss",{}).get("pearson_r")     if r else None, best="max")
        _add_row(rows, "**Gaussian: ∣slope−1∣**",             lambda r: r.get("gauss",{}).get("slope_err")     if r else None, best="min")
        _add_row(rows, "**Gaussian: ∣intercept∣**",           lambda r: r.get("gauss",{}).get("intercept_abs") if r else None, best="min")
        _add_row(rows, "**Gaussian: Q–Q MAE**",               lambda r: r.get("gauss",{}).get("qq_mae")        if r else None, best="min")
        _add_row(rows, "**Gaussian: JSD (nats)**",            lambda r: r.get("gauss",{}).get("jsd")           if r else None, best="min")

        print("\n".join(rows))

        #rows.append("| **mean ∣e∣ (abs error)** | " + " | ".join([fmt(results.get(k,{}).get("metrics",{}).get("mean") if results.get(k) else None) for k in order]) + " |")
        #rows.append("| **p99 ∣e∣ (abs error)** | " + " | ".join([fmt(results.get(k,{}).get("metrics",{}).get("p99") if results.get(k) else None) for k in order]) + " |")
        #rows.append("| **avg ∣Δ·∣ (abs dot error)** | " + " | ".join([fmt(results.get(k,{}).get("dot",{}).get("absdelta") if results.get(k) else None) for k in order]) + " |")
        #rows.append("| **median ∣Δ·∣ (abs dot error)** | " + " | ".join([fmt(results.get(k,{}).get("dot",{}).get("median_absdelta") if results.get(k) else None) for k in order]) + " |")
        #rows.append("| **mean Δ· (abs dot error, signed)** | " + " | ".join([fmt(results.get(k,{}).get("dot",{}).get("delta") if results.get(k) else None) for k in order]) + " |")

    return results


def parse_args():
    ap = argparse.ArgumentParser(description="Quantization format evaluator (Torch-only).")
    ap.add_argument("--device", type=str, default=None, help="cpu|cuda (default: auto)")
    ap.add_argument("--groups32", type=int, default=1024, help="# of 32-wide groups")
    ap.add_argument("--seed", type=int, default=1234, help="PRNG seed")
    ap.add_argument("--dump", action="store_true", help="dump first/last block bytes for each format")
    ap.add_argument("--fmt", type=str, default="text", choices=["text","md"], help="output metrics as text or markdown table")
    return ap.parse_args()


def main():
    args = parse_args()
    emit_md = (args.fmt == "md")
    run(device=args.device, groups32=args.groups32, seed=args.seed, dump=args.dump, emit_md=emit_md)


if __name__ == "__main__":
    main()
