# Frame Pacing, Frame Rate Limiting, and Present Frame Latency in PasVulkan

This document describes the frame timing system in `TpvApplication`, implemented in `PasVulkan.Application.pas`. The system governs three orthogonal concerns:

1. **Present Frame Latency** — GPU-CPU synchronization to control input-to-display latency
2. **Frame Pacing Mode** — where the target frame interval comes from (the interval source)
3. **Frame Pacing Strategy** — how the waiting/sleeping at frame end is performed (the timing method)

All three are independently configurable and interact through a well-defined pipeline within the frame loop.

## Overview

The frame timing system is split into three orthogonal axes:

- **Present Frame Latency** (`TpvApplicationPresentFrameLatencyMode`) — GPU-CPU synchronization (present wait and/or fence wait) to control input-to-display latency. Runs at frame start.
- **Frame Pacing Mode** (`TpvApplicationFramePacingMode`) — *where* the target frame interval comes from (the interval source). Also runs at frame start, producing `fFramePacingEffectiveInterval`.
- **Frame Pacing Strategy** (`TpvApplicationFramePacingStrategy`) — *how* the waiting/sleeping is performed (the timing method). Runs at frame end in `FramePacingAndFrameRateLimiter`, consuming the interval.

All three are independently configurable and can be combined freely. For example, one can use a monitor refresh rate query as the interval source together with an absolute time raster strategy for the sleeping, while using combined present+fence wait for latency control. Additionally, `MaximumFramesPerSecond` provides an explicit FPS cap that overrides the pacing interval when set.

## Properties

| Property | Type | Default | Description |
|---|---|---|---|
| `PresentFrameLatencyMode` | `TpvApplicationPresentFrameLatencyMode` | `CombinedWait` | GPU-CPU synchronization / latency reduction |
| `PresentFrameLatency` | `TpvUInt64` | `0` | Number of present IDs to lag behind for PresentWait (0 = disabled) |
| `FramePacingMode` | `TpvApplicationFramePacingMode` | `None` | Selects the interval source |
| `FramePacingStrategy` | `TpvApplicationFramePacingStrategy` | `AbsoluteTimeRaster` | Selects the sleep/wait method |
| `MaximumFramesPerSecond` | `TpvDouble` | `0.0` | Explicit FPS cap (overrides pacing interval when > 0) |

## Frame Loop Architecture

The three subsystems run at different points in the frame loop:

```
WaitForSwapChainLatency          ← (1) Present Frame Latency + (2) Interval Estimation
  │
  ├─ Present Wait phase          ← vkWaitForPresentKHR (latency control)
  ├─ Fence Wait phase            ← Pre-previous frame fence (latency control)
  └─ Interval Estimation         ← Computes fFramePacingEffectiveInterval
  │
AcquireVulkanBackBuffer
  │
Update → Draw → Present → PostPresent → inc(FrameCounter)
  │
FramePacingAndFrameRateLimiter   ← (3) Sleep at frame end using Strategy + Interval
```

`WaitForSwapChainLatency` runs at frame **start** (before CPU work begins) and handles both latency management and interval estimation. `FramePacingAndFrameRateLimiter` runs at frame **end** (after Present) and performs the actual sleep using the interval computed earlier. This "late pacing" pattern is more accurate than sleeping at frame start because the full frame duration is already known.

Both the `Strict` and `Flexible` processing modes call `FramePacingAndFrameRateLimiter` at the same position.

---

## TpvApplicationPresentFrameLatencyMode — GPU-CPU Synchronization

Controls how the engine synchronizes with the GPU to manage input-to-display latency and frame throughput. This is the first thing that happens each frame, inside `WaitForSwapChainLatency`.

The mode combines two independent synchronization mechanisms:

### Part 1: Present Wait (vkWaitForPresentKHR)

Uses `VK_KHR_present_wait` / `VK_KHR_present_id` to wait until a previously submitted frame has actually been presented on screen. This is the most direct way to control output latency.

**Requirements:** `VK_KHR_present_id` + `VK_KHR_present_wait` device support, VSync (FIFO) present mode, `PresentFrameLatency > 0`.

The wait target is: `fVulkanPresentLastID - fPresentFrameLatency`. So with `PresentFrameLatency = 2`, the engine waits until the frame submitted 2 presents ago has been shown.

### Part 2: Frame Fence Wait (Pre-Previous Frame Fence)

A GPU fence-based synchronization point based on [Sebastian Aaltonen's approach](https://twitter.com/SebAaltonen/status/1569608367618011136). Instead of waiting for the immediately previous frame's fence (N-1), the code waits for the frame *before* the previous one (N-2).

**Rationale:** Waiting for the N-2 fence gives lower overall latency than waiting for N-InFlightFrameCount, while still allowing up to 3 frames in flight. The simulation can write directly to GPU buffer data pointers since two frames of buffering are guaranteed. This is the best compromise between latency and throughput for most scenarios.

**Edge case:** Spiky CPU frames near 100% CPU+GPU utilization can cause GPU blast effects, but normally there is enough headroom to absorb this.

### Enum Values

| Value | Ordinal | Present Wait | Fence Wait | Description |
|---|---|---|---|---|
| `None` | -1 | No | No | No latency management. The fence wait is skipped entirely — the CPU runs ahead unconstrained. |
| `Auto` | 0 | Yes (if available) | Yes (if PresentWait unavailable) | Uses PresentWait when the driver supports it, falls back to fence wait otherwise. |
| `PresentWait` | 1 | Yes | No | Only vkWaitForPresentKHR. If supported, the fence wait is skipped (PresentWait already constrains the pipeline). |
| `FenceWait` | 2 | No | Yes | Only the pre-previous frame fence wait. Does not use vkWaitForPresentKHR. |
| `CombinedWait` | 3 | Yes | Yes | Both mechanisms active. PresentWait runs first, then the fence wait. Maximum latency control. |

### Decision Logic in WaitForSwapChainLatency

```
1. Present Wait phase:
   if mode in [Auto, PresentWait, CombinedWait]
      AND device supports PresentID + PresentWait
      AND PresentFrameLatency > 0
      AND VSync mode active
   then:
     vkWaitForPresentKHR(lastPresentID - PresentFrameLatency)

2. Fence Wait phase:
   if mode = None
      OR (mode in [Auto, PresentWait] AND PresentWait is available)
   then:
     Skip fence wait (already synchronized or no sync wanted)
   else:
     Wait for pre-previous frame fence (N-2 index)
```

### Interaction with Frame Pacing

`WaitForSwapChainLatency` also contains the frame pacing interval estimation logic (the `repeat...break` block). This means the interval source estimation and the latency management both happen in the same function, before the frame's CPU work begins. The estimated interval is then consumed later by `FramePacingAndFrameRateLimiter` at the end of the frame.

## TpvApplicationFramePacingMode — Interval Source

Determines how the target frame interval is obtained. The estimation runs inside `WaitForSwapChainLatency`, immediately after the latency synchronization phases. The result is stored in `fFramePacingEffectiveInterval` and consumed later by `FramePacingAndFrameRateLimiter`.

### Enum Values

| Value | Ordinal | Description |
|---|---|---|
| `None` | 0 | No frame pacing. Only the explicit FPS limiter (`MaximumFramesPerSecond`) is active, if set. |
| `Auto` | 1 | Tries all sources in priority order: VulkanPresentTiming → MonitorRefreshRate → PresentIntervalEstimation → 60 Hz fallback. Falls through automatically on failure. |
| `MonitorRefreshRate` | 2 | Queries the OS/windowing system for the monitor's refresh rate via `GetNativeRefreshRate` (SDL2 display mode query or Win32 API). No fallback if the query fails. |
| `PresentIntervalEstimation` | 3 | Estimates the display refresh interval from a running median of recent present-to-present frame intervals. Requires at least 4 history samples. No OS query. |
| `VulkanPresentTiming` | 4 | Uses `VK_EXT_present_timing` hardware data reported by the Vulkan driver. Most accurate when available. |

### Auto Mode Fallthrough

When `Auto` is selected, the estimation logic uses a `repeat...break...until false` pattern to try each source in order:

1. **VulkanPresentTiming** — if the extension is available and reports a refresh duration, use it and stop.
2. **MonitorRefreshRate** — query `GetNativeRefreshRate`. If it returns a valid rate (>= 1.0 Hz), use it and stop.
3. **PresentIntervalEstimation** — if at least 4 history samples exist, compute the trimmed median. If the result is within the sanity range (8 ms–50 ms, i.e. 20–125 Hz), use it and stop.
4. **60 Hz fallback** — if nothing else worked, assume 60 Hz to avoid uncapped frame rates.

### Present Interval Estimation Details

The software estimation collects frame-to-frame intervals in a ring buffer of 16 samples. It computes a robust interval estimate by:

1. Copying and sorting the recent samples (insertion sort, max 16 elements).
2. Computing the trimmed mean over the interquartile range (discarding the lowest and highest quartiles).
3. Applying a sanity check: only accepting the result if it falls between 8 ms (125 Hz) and 50 ms (20 Hz).

This runs inside `WaitForSwapChainLatency`, before the frame loop reaches `FramePacingAndFrameRateLimiter`.

## TpvApplicationFramePacingStrategy — Wait Method

Determines how the actual sleeping is performed in `FramePacingAndFrameRateLimiter` at the end of each frame.

### Enum Values

| Value | Ordinal | Description |
|---|---|---|
| `DeviationCompensation` | 0 | Reactive per-frame sleep with cumulative deviation tracking. |
| `AbsoluteTimeRaster` | 1 | Fixed absolute deadline grid with catch-up skip logic. **Default.** |

### DeviationCompensation Strategy

The reactive frame rate limiter. For each frame:

1. Compute `FrameTime = NowTime - LastTime`.
2. Compute `SleepDuration = TargetInterval - (FrameTime + AccumulatedDeviation)`.
3. If `SleepDuration > 0`, sleep via `TpvHighResolutionTimerSleepWithDriftCompensation`.
4. After waking, recalculate the actual frame time and update the deviation: `Deviation := min(TargetInterval/16, Deviation + (ActualFrameTime - TargetInterval))`.
5. If a frame was slow (> ~103% of target adjusted for deviation), reset the deviation to 0 to avoid compensating for genuinely slow frames later.

**Characteristics:**
- Adapts to varying frame times reactively.
- Can accumulate small drift over long periods since the time base is relative (frame-to-frame).
- Good for scenarios where frame times fluctuate moderately.

### AbsoluteTimeRaster Strategy

A fixed-grid temporal schedule. Instead of sleeping for a relative duration, the code maintains an absolute deadline (`fFramePacingNextPresentTarget`) that advances by exactly `TargetInterval` each frame.

For each frame:

1. Advance the deadline: `NextDeadline := NextDeadline + TargetInterval`.
2. **Frame finished early** (`NowTime < NextDeadline`): Sleep until the absolute deadline via `fFramePacingSleepWithDriftCompensation`.
3. **Frame finished late** (`NowTime >= NextDeadline`): Compute how many deadline slots were missed: `Skipped := (LateAmount div TargetInterval) + 1`. Jump the deadline forward: `NextDeadline := NextDeadline + (Skipped * TargetInterval)`. No catch-up bursts.
4. On first frame or after a reset (swapchain recreate), initialize the deadline to `NowTime + TargetInterval`.

**Characteristics:**
- No cumulative drift — the deadline is anchored to an absolute time base.
- Provides a stable long-term frame cadence.
- Gracefully handles slow frames by skipping missed slots rather than accumulating debt.
- The deadline resets automatically when `fFramePacingNextPresentTarget` is set to 0 (constructor, swapchain recreate).

## Target Interval Priority

`FramePacingAndFrameRateLimiter` determines the `TargetInterval` in this priority order:

1. **`MaximumFramesPerSecond`** — if > 0, compute `TargetInterval := 1.0 / MaximumFramesPerSecond`. This always takes priority.
2. **`fFramePacingEffectiveInterval`** — if > 0, use the interval estimated by the frame pacing mode logic in `WaitForSwapChainLatency`.
3. **Neither** — `TargetInterval := 0`, no throttling occurs.

## Call Position in the Frame Loop

`FramePacingAndFrameRateLimiter` is called at the **end** of each frame, after `PresentVulkanBackBuffer` and `PostPresent`:

```
Update → Draw → PresentVulkanBackBuffer → PostPresent → inc(FrameCounter) → FramePacingAndFrameRateLimiter
```

This is the "late pacing" pattern. Because the call happens after Present, the code already knows the full duration of the current frame before deciding how long to sleep. This is more accurate than sleeping at the frame start, where one would have to estimate based on the previous frame.

Both the `Strict` and `Flexible` processing modes call `FramePacingAndFrameRateLimiter` at the same position.

## Relevant Fields

### Frame Rate Limiter State

| Field | Type | Description |
|---|---|---|
| `fFrameRateLimiterLastTime` | `TpvHighResolutionTime` | Timestamp of the previous frame's limiter call |
| `fFrameRateLimiterDeviation` | `TpvHighResolutionTime` | Accumulated deviation for DeviationCompensation strategy |
| `fFrameLimiterHighResolutionTimerSleepWithDriftCompensation` | `TpvHighResolutionTimerSleepWithDriftCompensation` | Sleep helper for DeviationCompensation (Welford + busy-wait tail) |

### Frame Pacing State

| Field | Type | Description |
|---|---|---|
| `fFramePacingMode` | `TpvApplicationFramePacingMode` | Current interval source mode |
| `fFramePacingStrategy` | `TpvApplicationFramePacingStrategy` | Current wait method |
| `fFramePacingEffectiveInterval` | `TpvInt64` | Computed pacing interval, consumed by `FramePacingAndFrameRateLimiter` |
| `fFramePacingNextPresentTarget` | `TpvInt64` | Absolute deadline for AbsoluteTimeRaster strategy |
| `fFramePacingLastPresentTime` | `TpvInt64` | Last present timestamp for history recording |
| `fFramePacingHistory` | `array[0..15] of TpvInt64` | Ring buffer of recent present-to-present intervals |
| `fFramePacingHistoryIndex` | `TpvInt32` | Write index into the history ring buffer |
| `fFramePacingHistoryCount` | `TpvInt32` | Number of valid samples in the history (max 16) |
| `fFramePacingSleepWithDriftCompensation` | `TpvHighResolutionTimerSleepWithDriftCompensation` | Sleep helper for AbsoluteTimeRaster strategy |
| `fFramePacingPresentTimingRefreshDuration` | `TpvUInt64` | Refresh duration from `VK_EXT_present_timing` (nanoseconds) |
| `fFramePacingPresentTimingAvailable` | `boolean` | Whether VK_EXT_present_timing data is available |

### MaximumFramesPerSecond

| Field | Type | Description |
|---|---|---|
| `fMaximumFramesPerSecond` | `TpvDouble` | Explicit FPS cap. 0.0 = disabled. Takes priority over pacing interval. |

### Present Frame Latency State

| Field | Type | Description |
|---|---|---|
| `fPresentFrameLatencyMode` | `TpvApplicationPresentFrameLatencyMode` | Current latency management mode |
| `fPresentFrameLatency` | `TpvUInt64` | Number of present IDs to lag behind for PresentWait. 0 = disabled. |
| `fVulkanPresentLastID` | `TpvUInt64` | Monotonically increasing present ID, incremented on each vkQueuePresentKHR |
| `fVulkanFrameFences` | `array[0..3] of TpvVulkanFence` | Ring buffer of 4 frame fences for fence-based latency management |
| `fVulkanFrameFenceCounter` | `TpvUInt32` | Write index into the frame fence ring buffer |
| `fVulkanFrameFencesReady` | `TpvUInt32` | Bitmask tracking which fences have been signaled |

## Reset Behavior

The frame pacing state is reset in these situations:

- **Constructor** (`TpvApplication.Create`): All fields initialized to zero/default. `fFramePacingStrategy` defaults to `AbsoluteTimeRaster`. `fPresentFrameLatencyMode` defaults to `CombinedWait`.
- **Swapchain recreate** (`CreateVulkanSwapChain`): `fFramePacingNextPresentTarget`, `fFramePacingLastPresentTime`, history counters, and `fFramePacingDriftAccumulator` are reset to 0. `fFramePacingSleepWithDriftCompensation` is reset. This forces the AbsoluteTimeRaster strategy to re-anchor its deadline on the next frame.

## Typical Configurations

| Use Case | PresentFrameLatencyMode | FramePacingMode | FramePacingStrategy | MaximumFramesPerSecond |
|---|---|---|---|---|
| No pacing, no cap, no latency control | `None` | `None` | (ignored) | `0` |
| Low-latency VSync | `CombinedWait` | `Auto` | `AbsoluteTimeRaster` | `0` |
| Explicit 60 FPS cap | `CombinedWait` | `None` | `AbsoluteTimeRaster` | `60` |
| Auto-detect refresh, stable grid | `CombinedWait` | `Auto` | `AbsoluteTimeRaster` | `0` |
| VSync + monitor Hz pacing | `FenceWait` | `MonitorRefreshRate` | `AbsoluteTimeRaster` | `0` |
| Legacy reactive pacing | `FenceWait` | `Auto` | `DeviationCompensation` | `0` |
| Fixed 144 FPS cap, reactive | `CombinedWait` | `None` | `DeviationCompensation` | `144` |
| Uncapped (benchmark) | `None` | `None` | (ignored) | `0` |
