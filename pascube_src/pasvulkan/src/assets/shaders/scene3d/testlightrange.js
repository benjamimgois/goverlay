

let lightIntensity = 100000.0;

// calculate the light range based on the light intensity ( lightAttenuation *= 1.0 / (currentDistance * currentDistance) )

let lightRange = Math.sqrt(lightIntensity / 1e-3);

console.log("lightRange: ", lightRange);