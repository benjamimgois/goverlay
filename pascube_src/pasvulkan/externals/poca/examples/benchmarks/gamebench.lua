-- 2D entities: movement + naive circle-circle collisions (O(N^2))
-- Data layout: SoA; numeric arrays (tables with numeric keys).

local N = 1000
local W, H = 1024.0, 768.0
local DT = 1.0 / 60.0

local x, y, vx, vy, r = {}, {}, {}, {}, {}
for i = 1, N do
  x[i]  = math.random() * W
  y[i]  = math.random() * H
  vx[i] = (math.random() * 2.0 - 1.0) * 100.0
  vy[i] = (math.random() * 2.0 - 1.0) * 100.0
  r[i]  = 4.0
end

local function step()
  -- integrate
  for i = 1, N do
    local xi = x[i] + vx[i] * DT
    local yi = y[i] + vy[i] * DT
    if xi < 0.0 then xi = xi + W elseif xi >= W then xi = xi - W end
    if yi < 0.0 then yi = yi + H elseif yi >= H then yi = yi - H end
    x[i] = xi; y[i] = yi
  end
  -- collisions (naive)
  for i = 1, N do
    local xi, yi, ri = x[i], y[i], r[i]
    for j = i + 1, N do
      local dx = x[j] - xi
      local dy = y[j] - yi
      local rr = ri + r[j]
      local d2 = dx*dx + dy*dy
      if d2 < rr*rr then
        local d = (d2 > 0.0) and math.sqrt(d2) or 1e-6
        local nx = dx / d
        local ny = dy / d
        local pen = rr - d
        x[j] = x[j] + nx * (pen * 0.5)
        y[j] = y[j] + ny * (pen * 0.5)
        x[i] = x[i] - nx * (pen * 0.5)
        y[i] = y[i] - ny * (pen * 0.5)
        local vdot_i = vx[i]*nx + vy[i]*ny
        local vdot_j = vx[j]*nx + vy[j]*ny
        vx[i] = vx[i] - 2.0 * vdot_i * nx
        vy[i] = vy[i] - 2.0 * vdot_i * ny
        vx[j] = vx[j] - 2.0 * vdot_j * nx
        vy[j] = vy[j] - 2.0 * vdot_j * ny
      end
    end
  end
end

-- micro benchmark
local t0 = os.clock()
local steps = 10
for _ = 1, steps do step() end
local t1 = os.clock()
print(string.format("lua: steps=%d, N=%d, elapsed=%.3fs", steps, N, t1 - t0))
