// 2D entities: movement + naive circle-circle collisions (O(N^2))
// Data layout: SoA for predictable access; avoid objects in hot loops.
// No semicolons in Wren; each statement ends by newline.

var N  = 1000
var W  = 1024.0
var H  = 768.0
var DT = 1.0 / 60.0

class RNG {
  construct new(seed) { _s = seed }
  next() {
    _s = (_s * 1664525 + 1013904223) % 4294967296
    return _s
  }
  float01() { next() / 4294967296 }          // [0,1)
  float(max) { float01() * max }             // [0,max)
  floatRange(min, max) { float01() * (max - min) + min }
}

// Pre-allocate numeric arrays (SoA)
var x  = List.filled(N, 0.0)
var y  = List.filled(N, 0.0)
var vx = List.filled(N, 0.0)
var vy = List.filled(N, 0.0)
var r  = List.filled(N, 4.0)

// Init
var rng = RNG.new(1234567)
var i = 0
while (i < N) {
  x[i]  = rng.float(W)
  y[i]  = rng.float(H)
  vx[i] = rng.floatRange(-1.0, 1.0) * 100.0
  vy[i] = rng.floatRange(-1.0, 1.0) * 100.0
  i = i + 1
}

// Top-level step function (can access module variables x,y,vx,vy,r,W,H,DT)
var step = Fn.new {
  // integrate
  var i = 0
  while (i < N) {
    var xi = x[i] + vx[i] * DT
    var yi = y[i] + vy[i] * DT

    // wrap-around with explicit blocks
    if (xi < 0.0) {
      xi = xi + W
    } else if (xi >= W) {
      xi = xi - W
    }
    if (yi < 0.0) {
      yi = yi + H
    } else if (yi >= H) {
      yi = yi - H
    }

    x[i] = xi
    y[i] = yi
    i = i + 1
  }

  // collisions (naive)
  i = 0
  while (i < N) {
    var xi = x[i]
    var yi = y[i]
    var ri = r[i]
    var j = i + 1
    while (j < N) {
      var dx = x[j] - xi
      var dy = y[j] - yi
      var rr = ri + r[j]
      var d2 = dx*dx + dy*dy
      if (d2 < rr*rr) {
        // guard zero distance
        var d = 1e-6
        if (d2 > 0.0) {
          d = d2.sqrt
        }
        var nx = dx / d
        var ny = dy / d
        var pen = rr - d

        // separate positions 50/50
        x[j] = x[j] + nx * (pen * 0.5)
        y[j] = y[j] + ny * (pen * 0.5)
        x[i] = x[i] - nx * (pen * 0.5)
        y[i] = y[i] - ny * (pen * 0.5)

        // crude velocity reflection along collision normal
        var vdotI = vx[i]*nx + vy[i]*ny
        var vdotJ = vx[j]*nx + vy[j]*ny
        vx[i] = vx[i] - 2.0 * vdotI * nx
        vy[i] = vy[i] - 2.0 * vdotI * ny
        vx[j] = vx[j] - 2.0 * vdotJ * nx
        vy[j] = vy[j] - 2.0 * vdotJ * ny
      }
      j = j + 1
    }
    i = i + 1
  }
}

// micro benchmark (your VM exposes System.clock as a property, no parentheses)
var t0 = System.clock
var steps = 10
var s = 0
while (s < steps) {
  step.call()
  s = s + 1
}
var t1 = System.clock
System.print("wren: steps=%(steps), N=%(N), elapsed=%(t1 - t0)s")
