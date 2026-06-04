// 2D entities: movement + naive circle-circle collisions (O(N^2))
// Class-based layout: everything lives as static fields on Bench.
// No semicolons in Wren; each statement ends by newline.

class RNG {
  construct new(seed) { _s = seed }
  next() {
    // _s = (_s * 1664525 + 1013904223) % 2^32
    _s = (_s * 1664525 + 1013904223) % 4294967296
    return _s
  }
  float01() { next() / 4294967296 }          // [0,1)
  float(max) { float01() * max }             // [0,max)
  floatRange(min, max) { float01() * (max - min) + min }
}

class Bench {
  // simulation constants
  static N  { 1000 }
  static W  { 1024.0 }
  static H  { 768.0 }
  static DT { 1.0 / 60.0 }

  // SoA numeric arrays
  static x { __x }
  static x=(v) { __x = v }
  static y { __y }
  static y=(v) { __y = v }
  static vx { __vx }
  static vx=(v) { __vx = v }
  static vy { __vy }
  static vy=(v) { __vy = v }
  static r { __r }
  static r=(v) { __r = v }

  // PRNG
  static rng { __rng }
  static rng=(v) { __rng = v }

  // Allocate and initialize arrays
  static setup() {
    Bench.x  = List.filled(Bench.N, 0.0)
    Bench.y  = List.filled(Bench.N, 0.0)
    Bench.vx = List.filled(Bench.N, 0.0)
    Bench.vy = List.filled(Bench.N, 0.0)
    Bench.r  = List.filled(Bench.N, 4.0)

    Bench.rng = RNG.new(1234567)

    var i = 0
    while (i < Bench.N) {
      Bench.x[i]  = Bench.rng.float(Bench.W)
      Bench.y[i]  = Bench.rng.float(Bench.H)
      Bench.vx[i] = Bench.rng.floatRange(-1.0, 1.0) * 100.0
      Bench.vy[i] = Bench.rng.floatRange(-1.0, 1.0) * 100.0
      i = i + 1
    }
  }

  // One simulation step (integrate + naive collisions)
  static step() {
    // integrate
    var i = 0
    while (i < Bench.N) {
      var xi = Bench.x[i] + Bench.vx[i] * Bench.DT
      var yi = Bench.y[i] + Bench.vy[i] * Bench.DT

      // wrap-around with explicit blocks
      if (xi < 0.0) {
        xi = xi + Bench.W
      } else if (xi >= Bench.W) {
        xi = xi - Bench.W
      }
      if (yi < 0.0) {
        yi = yi + Bench.H
      } else if (yi >= Bench.H) {
        yi = yi - Bench.H
      }

      Bench.x[i] = xi
      Bench.y[i] = yi
      i = i + 1
    }

    // collisions (naive O(N^2))
    i = 0
    while (i < Bench.N) {
      var xi = Bench.x[i]
      var yi = Bench.y[i]
      var ri = Bench.r[i]
      var j = i + 1
      while (j < Bench.N) {
        var dx = Bench.x[j] - xi
        var dy = Bench.y[j] - yi
        var rr = ri + Bench.r[j]
        var d2 = dx*dx + dy*dy
        if (d2 < rr*rr) {
          // guard zero distance; no ternary in Wren
          var d = 1e-6
          if (d2 > 0.0) {
            d = d2.sqrt
          }
          var nx = dx / d
          var ny = dy / d
          var pen = rr - d

          // separate positions 50/50
          Bench.x[j] = Bench.x[j] + nx * (pen * 0.5)
          Bench.y[j] = Bench.y[j] + ny * (pen * 0.5)
          Bench.x[i] = Bench.x[i] - nx * (pen * 0.5)
          Bench.y[i] = Bench.y[i] - ny * (pen * 0.5)

          // crude velocity reflection along collision normal
          var vdotI = Bench.vx[i]*nx + Bench.vy[i]*ny
          var vdotJ = Bench.vx[j]*nx + Bench.vy[j]*ny
          Bench.vx[i] = Bench.vx[i] - 2.0 * vdotI * nx
          Bench.vy[i] = Bench.vy[i] - 2.0 * vdotI * ny
          Bench.vx[j] = Bench.vx[j] - 2.0 * vdotJ * nx
          Bench.vy[j] = Bench.vy[j] - 2.0 * vdotJ * ny
        }
        j = j + 1
      }
      i = i + 1
    }
  }
}

// run
Bench.setup()

// micro benchmark (System.clock is a property in your VM)
var t0 = System.clock
var steps = 10
var s = 0
while (s < steps) {
  Bench.step()
  s = s + 1
}
var t1 = System.clock
System.print("wren: steps=%(steps), N=%(Bench.N), elapsed=%(t1 - t0)s")
