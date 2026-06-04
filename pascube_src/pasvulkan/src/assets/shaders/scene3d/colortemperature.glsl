#ifndef COLOR_TEMPERATURE_GLSL
#define COLOR_TEMPERATURE_GLSL

// Valid from 1000 to 40000 K (and additionally 0 for pure full white)
#if 1
vec3 colorTemperatureToRGB(const in float temperature){
  // Values from: http://blenderartists.org/forum/showthread.php?270332-OSL-Goodness&p=2268693&viewfull=1#post2268693   
  mat3 m = (temperature <= 6500.0) ? mat3(vec3(0.0, -2902.1955373783176, -8257.7997278925690),
	                                      vec3(0.0, 1669.5803561666639, 2575.2827530017594),
	                                      vec3(1.0, 1.3302673723350029, 1.8993753891711275)) : 
	 								 mat3(vec3(1745.0425298314172, 1216.6168361476490, -8257.7997278925690),
   	                                      vec3(-2666.3474220535695, -2173.1012343082230, 2575.2827530017594),
	                                      vec3(0.55995389139931482, 0.70381203140554553, 1.8993753891711275)); 
  return mix(clamp(vec3(m[0] / (vec3(clamp(temperature, 1000.0, 40000.0)) + m[1]) + m[2]), vec3(0.0), vec3(1.0)), vec3(1.0), smoothstep(1000.0, 0.0, temperature));
}
#else
vec3 colorTemperatureToRGB(float temperature){
  temperature = clamp(temperature, 1000.0, 40000.0) / 100.0;
  return vec3((temperature <= 66.0) 
                ? vec2(1.0, clamp(0.39008157876901960784 * log(temperature) - 0.63184144378862745098, 0.0, 1.0))
                : clamp(vec2(1.29293618606274509804, 1.12989086089529411765) * pow(vec2(temperature - 60.0), vec2(-0.1332047592, -0.0755148492)), vec2(0.0), vec2(1.0)),
              (temperature >= 66.0) 
                ? 1.0
                : ((temperature <= 19.0) 
                    ? 0.0
                    : clamp(0.54320678911019607843 * log(temperature - 10.0) - 1.19625408914, 0.0, 1.0)));
}
#endif

#endif