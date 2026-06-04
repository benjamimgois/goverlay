# 2D entities: movement + naive circle-circle collisions (O(N^2))
# Data layout: SoA for better cache behavior compared to AoS in Python lists.

import time, math, random

N = 1000
W, H = 1024.0, 768.0
DT = 1.0 / 60.0

x  = [random.random() * W for _ in range(N)]
y  = [random.random() * H for _ in range(N)]
vx = [(random.random() * 2.0 - 1.0) * 100.0 for _ in range(N)]
vy = [(random.random() * 2.0 - 1.0) * 100.0 for _ in range(N)]
r  = [4.0 for _ in range(N)]

def step():
    # integrate
    for i in range(N):
        x[i] += vx[i] * DT
        y[i] += vy[i] * DT
        # wrap
        if x[i] < 0.0: x[i] += W
        elif x[i] >= W: x[i] -= W
        if y[i] < 0.0: y[i] += H
        elif y[i] >= H: y[i] -= H
    # collisions (naive)
    for i in range(N):
        xi, yi, ri = x[i], y[i], r[i]
        for j in range(i + 1, N):
            dx = x[j] - xi
            dy = y[j] - yi
            rr = ri + r[j]
            d2 = dx*dx + dy*dy
            if d2 < rr*rr:
                d = math.sqrt(d2) if d2 > 0.0 else 1e-6
                nx = dx / d
                ny = dy / d
                pen = rr - d
                # separate positions 50/50
                x[j] += nx * (pen * 0.5)
                y[j] += ny * (pen * 0.5)
                x[i] -= nx * (pen * 0.5)
                y[i] -= ny * (pen * 0.5)
                # simple velocity reflection along normal (very crude)
                vdot_i = vx[i]*nx + vy[i]*ny
                vdot_j = vx[j]*nx + vy[j]*ny
                vx[i] -= 2.0 * vdot_i * nx
                vy[i] -= 2.0 * vdot_i * ny
                vx[j] -= 2.0 * vdot_j * nx
                vy[j] -= 2.0 * vdot_j * ny

# micro benchmark
t0 = time.time()
steps = 10
for _ in range(steps):
    step()
t1 = time.time()
print(f"python: steps={steps}, N={N}, elapsed={t1 - t0:.3f}s")
