                                                                                                   # 2D entities: movement + naive circle-circle collisions (O(N^2))
# Data layout: SoA for better cache behavior.

N  = 1000
W  = 1024.0
H  = 768.0
DT = 1.0 / 60.0

x  = Array.new(N) { rand * W }
y  = Array.new(N) { rand * H }
vx = Array.new(N) { (rand * 2.0 - 1.0) * 100.0 }
vy = Array.new(N) { (rand * 2.0 - 1.0) * 100.0 }
r  = Array.new(N, 4.0)

def step!(x, y, vx, vy, r, n, w, h, dt)
  # integrate
  i = 0
  while i < n
    xi = x[i] + vx[i] * dt
    yi = y[i] + vy[i] * dt

    # wrap
    if xi < 0.0
      xi += w
    elsif xi >= w
      xi -= w
    end
    if yi < 0.0
      yi += h
    elsif yi >= h
      yi -= h
    end

    x[i] = xi
    y[i] = yi
    i += 1
  end

  # collisions (naive)
  i = 0
  while i < n
    xi = x[i]; yi = y[i]; ri = r[i]
    j = i + 1
    while j < n
      dx = x[j] - xi
      dy = y[j] - yi
      rr = ri + r[j]
      d2 = dx*dx + dy*dy
      if d2 < rr*rr
        d  = d2 > 0.0 ? Math.sqrt(d2) : 1e-6
        nx = dx / d
        ny = dy / d
        pen = rr - d

        # separate positions 50/50
        x[j] += nx * (pen * 0.5)
        y[j] += ny * (pen * 0.5)
        x[i] -= nx * (pen * 0.5)
        y[i] -= ny * (pen * 0.5)

        # crude velocity reflection along normal
        vdot_i = vx[i]*nx + vy[i]*ny
        vdot_j = vx[j]*nx + vy[j]*ny
        vx[i] -= 2.0 * vdot_i * nx
        vy[i] -= 2.0 * vdot_i * ny
        vx[j] -= 2.0 * vdot_j * nx
        vy[j] -= 2.0 * vdot_j * ny
      end
      j += 1
    end
    i += 1
  end
end

# micro benchmark
t0 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
steps = 10
steps.times { step!(x, y, vx, vy, r, N, W, H, DT) }
t1 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
puts "ruby: steps=#{steps}, N=#{N}, elapsed=#{(t1 - t0).round(3)}s"
