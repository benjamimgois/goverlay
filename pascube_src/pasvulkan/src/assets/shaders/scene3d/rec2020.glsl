#ifndef REC2020_GLSL
#define REC2020_GLSL

const mat3 LinearRec2020ToLinearSRGBMatrix = mat3(
#if 1
  // Calculated from XYZToSRGBMatrix * Rec2020ToXYZMatrix (for greater precision than the values from the ITU document) 
	1.6602135, -0.12455204, -0.018155023,
	-0.5875643, 1.1329461, -0.100604795,
	-0.07282758, -0.008348331, 1.1188319
#else
  // From https://www.itu.int/dms_pub/itu-r/opb/rep/R-REP-BT.2407-2017-PDF-E.pdf
	vec3(1.6605, -0.1246, -0.0182),
	vec3(-0.5876, 1.1329, -0.1006),
	vec3(-0.0728, -0.0083, 1.1187)
#endif
);

const mat3 LinearSRGBToLinearRec2020Matrix = mat3(	
#if 1
  // Calculated from XYZToRec2020Matrix * SRGBToXYZMatrix (for greater precision than the values from the ITU document) 
	0.6275074, 0.069107726, 0.01639648,
	0.32927772, 0.91950446, 0.08802433,
	0.043303847, 0.011359092, 0.8955135
#else
  // From https://www.itu.int/dms_pub/itu-r/opb/rep/R-REP-BT.2407-2017-PDF-E.pdf
	vec3(0.6274, 0.0691, 0.0164),
	vec3(0.3293, 0.9195, 0.0880),
	vec3(0.0433, 0.0113, 0.8956)
#endif
);

const vec3 LinearRec2020LuminanceWeights = vec3(0.2627002, 0.6779981, 0.0593017);

#endif