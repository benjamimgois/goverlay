#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
q43nl_testcase.py — self-contained tests for Q43NL quantization (with FP16 scale)
- Encodes random tensors with q43nl using FP16 scale (vs FP8 in Q42NL)
- Verifies byte size/layout (32 vals -> 19 bytes: 16 nibbles + 2 FP16 + 1 curve)
- Decodes back and reports MSE/PSNR
- Benchmarks grid sizes and optional chunking
Usage:
  python q43nl_testcase.py                # quick small test
  python q43nl_testcase.py --cuda         # run on GPU if available
  python q43nl_testcase.py --shape 65536 32
  python q43nl_testcase.py --grid 33
  python q43nl_testcase.py --chunk 262144 # process elements per chunk (multiple of 32)
"""
import os
import time
import math
import argparse
from typing import Tuple

import torch

# ------------------------- Q43NL implementation -------------------------

# Q43NL quantization: 32 values -> 19 bytes: 16×nibbles + 1×fp16 scale + 1×int8 curve
# Dequant path: y = f_curve(q/7, c), out = scale * y
def q43nl(
    t: torch.Tensor,
    eps_scale: float = 1e-6,      # 32-bit safe tiny for scale
    grid_size: int = 255           # number of candidate c values in [-1, 1]
) -> torch.Tensor:
    """
    Quantize a tensor using the Q43NL method (with FP16 scale).
    """
    assert t.numel() % 32 == 0, "Tensor size must be divisible by 32"
    T = t.to(torch.float32).view(-1, 32)              # [G,32]
    G = T.shape[0]
    dev = T.device

    # per-group tmax using FP16 scale instead of FP8
    tmax = T.abs().amax(dim=1)                        # [G]
    scale = tmax.to(torch.float16).to(torch.float32)  # [G] (float32) - quantized through FP16

    # normalization
    scale_safe = torch.where(scale > 0, scale, torch.ones_like(scale))
    Y = torch.clamp(T / scale_safe[:, None], -1.0, 1.0)                  # [G,32]

    # ---- vectorized curve search over fixed grid ----
    K = int(grid_size)
    C = torch.linspace(-1.0, 1.0, K, device=dev, dtype=torch.float32)    # [K]
    if K == 255:
        # Ensure it is quantized to int8 exactly
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

    # general quadratic: c x^2 + (1-c) x - a = 0, '+' root, safe for c∈(-1,1)\{0}
    b = (1.0 - Cb)                                                       # [K,1,1]
    disc = torch.clamp(b * b + 4.0 * Cb * A_b, min=0.0)                  # [K,G,32]
    # avoid div-by-zero by replacing C==0 with tiny in denominator; but masked out by m_gen anyway
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

    # handle degenerate groups (scale ~ 0)
    zero_mask = (scale <= eps_scale)                                      # [G]

    # pack 32×4-bit -> 16 bytes
    u4 = ((q_best + 8) & 0x0F).to(torch.uint8)                            # [G,32]
    lo = (u4[:, 0::2] & 0x0F)
    hi = ((u4[:, 1::2] & 0x0F) << 4)
    qbytes = (lo | hi)                                                    # [G,16]
    qbytes[zero_mask] = 0

    # fp16 scale bytes (2 bytes, little-endian)
    sbytes = scale.to(torch.float16).view(torch.uint8).view(-1, 2)       # [G,2]
    sbytes[zero_mask] = 0

    # curve byte
    cbytes_i8 = torch.clamp(torch.round(best_c * 127.0), min=-128, max=127).to(torch.int8)
    cbytes = cbytes_i8.view(torch.uint8).view(-1, 1)                      # [G,1]
    cbytes[zero_mask] = 0

    packed = torch.cat([qbytes, sbytes, cbytes], dim=1).reshape(-1)       # [G,19] -> bytes
    return packed.contiguous().to(torch.uint8)

# Process large tensors in chunks to save memory, otherwise there is a risk of out-of-memory and/or slowdowns
# due to too big temporary tensors.
def q43nl_chunked(t: torch.Tensor, chunk_elems: int = 32*8192, **kw) -> torch.Tensor:
    """Quantize in chunks to cap memory. chunk_elems must be a multiple of 32."""
    assert chunk_elems % 32 == 0
    out = []
    flat = t.view(-1)
    for i in range(0, flat.numel(), chunk_elems):
        out.append(q43nl(flat[i:i+chunk_elems], **kw))
    return torch.cat(out, dim=0)

# ------------------------- Dequantizer (for testing) -------------------------

def q43nl_dequant(packed: torch.Tensor, device=None) -> Tuple[torch.Tensor, torch.Tensor, torch.Tensor]:
    """
    Unpack q43nl bytes -> (q:int8 [G,32], scale:float32 [G], curve:float32 [G])
    Returns tensors on 'device' (defaults to packed.device).
    """
    if device is None:
        device = packed.device
    packed = packed.view(-1, 19).to(torch.uint8)                  # [G,19]
    G = packed.shape[0]

    qbytes = packed[:, :16]                                       # [G,16]
    sbytes = packed[:, 16:18]                                     # [G,2]
    cbyte  = packed[:, 18]                                        # [G]

    lo = (qbytes & 0x0F)
    hi = (qbytes >> 4) & 0x0F
    u4 = torch.empty((G, 32), dtype=torch.uint8, device=device)
    u4[:, 0::2] = lo
    u4[:, 1::2] = hi
    q = (u4.to(torch.int16) - 8).to(torch.int8)                   # [G,32] in [-8..7], we used [-7..7] in encode

    # Reconstruct FP16 scale from 2 bytes (little-endian)
    # Need to reshape to [G, 2] then view as [G] of float16
    scale = sbytes.reshape(-1).view(torch.float16).to(torch.float32)  # [G]
    curve = (cbyte.view(torch.int8).to(torch.float32) / 127.0).clamp(-1.0, 1.0)  # [G]

    return q, scale, curve

def q43nl_dequant_reconstruct(packed: torch.Tensor, device=None) -> torch.Tensor:
    """Full reconstruction to float32 values using stored q, scale, curve."""
    q, scale, curve = q43nl_dequant(packed, device=device)        # [G,32], [G], [G]
    xq = q.to(torch.float32) / 7.0                                # [G,32]
    y = (1.0 - curve[:, None]) * xq + curve[:, None] * (xq.abs() * xq)
    out = y * scale[:, None]                                      # [G,32]
    return out.view(-1)

# ------------------------- Utilities -------------------------

def mse_psnr(a: torch.Tensor, b: torch.Tensor):
    mse = torch.mean((a - b) ** 2).item()
    maxv = max(a.abs().max().item(), b.abs().max().item(), 1e-8)
    psnr = 20.0 * math.log10(maxv) - 10.0 * math.log10(max(mse, 1e-12))
    return mse, psnr

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--cuda", action="store_true", help="Use CUDA if available")
    ap.add_argument("--shape", nargs="+", type=int, default=[32768, 32],
                    help="Tensor shape; product must be divisible by 32 (default: 32768 32)")
    ap.add_argument("--grid", type=int, default=255, help="Grid size for curve search (default: 255)")
    ap.add_argument("--chunk", type=int, default=0, help="Chunk elements (multiple of 32); 0=disabled")
    ap.add_argument("--seed", type=int, default=1234, help="Random seed")
    args = ap.parse_args()

    torch.manual_seed(args.seed)

    device = torch.device("cpu")
    if args.cuda and torch.cuda.is_available():
        device = torch.device("cuda")

    shape = tuple(args.shape)
    numel = 1
    for s in shape:
        numel *= s
    assert numel % 32 == 0, "Total number of elements must be divisible by 32"

    print(f"Q43NL Test (FP16 Scale)")
    print(f"Device: {device}")
    print(f"Shape: {shape}  (numel={numel})")
    print(f"Grid size: {args.grid}")
    print(f"Chunk: {args.chunk if args.chunk>0 else 'disabled'}")
    print(f"Seed: {args.seed}")

    # generate test tensor with dynamic range and some zeros
    t = (torch.randn(shape, device=device) * 3.0)
    t *= torch.linspace(0.1, 1.0, steps=shape[-1], device=device) if len(shape) >= 1 else 1.0

    # quantize
    t_flat = t.view(-1)
    t0 = time.time()
    if args.chunk and args.chunk > 0:
        packed = q43nl_chunked(t_flat, chunk_elems=args.chunk, grid_size=args.grid)
    else:
        packed = q43nl(t_flat, grid_size=args.grid)
    torch.cuda.synchronize() if device.type == "cuda" else None
    t1 = time.time()

    # checks
    expected_bytes = (numel // 32) * 19  # 19 bytes per group (16 nibbles + 2 FP16 + 1 curve)
    print(f"Packed bytes: {packed.numel()} (expected {expected_bytes})")
    assert packed.numel() == expected_bytes, "Packed size mismatch"
    assert packed.dtype == torch.uint8 and packed.is_contiguous()

    # reconstruct
    t2 = time.time()
    recon = q43nl_dequant_reconstruct(packed, device=device)
    torch.cuda.synchronize() if device.type == "cuda" else None
    t3 = time.time()

    mse, psnr = mse_psnr(t_flat.float().cpu(), recon.float().cpu())
    print(f"Quantize time: {(t1 - t0)*1000:.2f} ms")
    print(f"Dequant  time: {(t3 - t2)*1000:.2f} ms")
    print(f"MSE: {mse:.6e}  PSNR: {psnr:.2f} dB")
    # sanity bounds (very loose; chiefly to catch NaNs/inf or wild errors)
    assert math.isfinite(mse) and mse >= 0.0
    assert psnr > 10.0, "Unusually low PSNR; check implementation"

    # spot-check decode components
    q, scale, curve = q43nl_dequant(packed, device=device)
    print(f"Groups: {q.shape[0]}  (each 32 values)")
    print(f"Scale stats: min={scale.min().item():.6g} max={scale.max().item():.6g} mean={scale.mean().item():.6g}")
    print(f"Curve stats: min={curve.min().item():.6g} max={curve.max().item():.6g} mean={curve.mean().item():.6g}")
    print("OK.")

if __name__ == "__main__":
    main()
