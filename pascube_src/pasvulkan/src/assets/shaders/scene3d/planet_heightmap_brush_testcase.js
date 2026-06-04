
/*
vec2 squareToCircle(vec2 p) {
  return p * sqrt(fma((p * p).yx, vec2(-0.5), vec2(1.0)));
}

vec2 circleToSquare(vec2 uv) {
  return vec2(
    ((sqrt((((2.0 + (2.0 * sqrt(2.0) * uv.x)) + (uv.x * uv.x)) - (uv.y * uv.y)))) - (sqrt((((2.0 - (2.0 * sqrt(2.0) * uv.x)) + (uv.x * uv.x)) - (uv.y * uv.y))))) * 0.5,
    ((sqrt((((2.0 + (2.0 * sqrt(2.0) * uv.y)) + (uv.y * uv.y)) - (uv.x * uv.x)))) - (sqrt((((2.0 - (2.0 * sqrt(2.0) * uv.y)) + (uv.y * uv.y)) - (uv.x * uv.x))))) * 0.5
  );
}
  */

class vec2 {
  constructor(x, y) {
    this.x = x;
    this.y = y;
  }

  add(v) {
    return new vec2(this.x + v.x, this.y + v.y);
  }

  sub(v) {
    return new vec2(this.x - v.x, this.y - v.y);
  }

  mul(s) {
    return new vec2(this.x * s, this.y * s);
  }

  div(s) {
    return new vec2(this.x / s, this.y / s);
  }

  dot(v) {
    return this.x * v.x + this.y * v.y;
  }

  length() {
    return Math.sqrt(this.x * this.x + this.y * this.y);
  }

  normalize() {
    return this.div(this.length());
  }
}

function squareToCircle(p) {
  let result = new vec2();
  result.x = p.x * Math.sqrt(1.0 - ((p.y * p.y) * 0.5));
  result.y = p.y * Math.sqrt(1.0 - ((p.x * p.x) * 0.5));
  return result;
}

function circleToSquare(uv) {
  let result = new vec2();
  result.x = ((Math.sqrt((((2.0 + (2.0 * Math.sqrt(2.0) * uv.x)) + (uv.x * uv.x)) - (uv.y * uv.y)))) - (Math.sqrt((((2.0 - (2.0 * Math.sqrt(2.0) * uv.x)) + (uv.x * uv.x)) - (uv.y * uv.y))))) * 0.5;
  result.y = ((Math.sqrt((((2.0 + (2.0 * Math.sqrt(2.0) * uv.y)) + (uv.y * uv.y)) - (uv.x * uv.x)))) - (Math.sqrt((((2.0 - (2.0 * Math.sqrt(2.0) * uv.y)) + (uv.y * uv.y)) - (uv.x * uv.x))))) * 0.5;
  return result;
}

let testPoints = [
/*new vec2(0.0, 0.0),
  new vec2(0.5, 0.0),
  new vec2(0.0, 0.5),
  new vec2(0.5, 0.5),
  new vec2(0.25, 0.25),
  new vec2(0.75, 0.25),
  new vec2(0.25, 0.75),
  new vec2(0.75, 0.75),
  new vec2(1.0, 0.0),
  new vec2(0.0, 1.0),
  new vec2(1.0, 1.0),
  new vec2(-0.5, 0.0),
  new vec2(0.0, -0.5),
  new vec2(-0.5, -0.5),
  new vec2(-0.25, -0.25),
  new vec2(-0.75, -0.25),
  new vec2(-0.25, -0.75),
  new vec2(-0.75, -0.75),
  new vec2(-1.0, 0.0),
  new vec2(0.0, -1.0),
  new vec2(-1.0, -1.0),
  new vec2(0.5, -0.5),
  new vec2(-0.5, 0.5),
  new vec2(-0.5, 0.25),
  new vec2(-0.5, -0.25)*/
  new vec2(0.9, 0.9)
]; 

for (let i = 0; i < testPoints.length; i++) {

  let p = testPoints[i];
  let c = squareToCircle(p);
  let p2 = circleToSquare(c);

  let c2 = circleToSquare(p);
  let p3 = squareToCircle(c2);

  console.log("p = " + p.x + ", " + p.y);
  console.log(" ");
  console.log("c = " + c.x + ", " + c.y);
  console.log("p2 = " + p2.x + ", " + p2.y);
  console.log(" ");
  console.log("c2 = " + c2.x + ", " + c2.y);
  console.log("p3 = " + p3.x + ", " + p3.y);
  console.log(" ");
}

