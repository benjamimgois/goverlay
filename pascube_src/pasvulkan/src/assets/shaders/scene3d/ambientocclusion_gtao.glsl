#ifndef AMBIENTOCCLUSION_GTAO_GLSL
#define AMBIENTOCCLUSION_GTAO_GLSL

const float GTAO_DEFAULT_RADIUS_MULTIPLIER = 1.457; // allows us to use different value as compared to ground truth radius to counter inherent screen space biases
const float GTAO_DEFAULT_FALLOFF_RANGE = 0.615; // distant samples contribute less
const float GTAO_DEFAULT_SAMPLE_DISTRIBUTION_POWER = 2.0;  // small crevices more important than big surfaces
const float GTAO_DEFAULT_THIN_OCCLUDER_COMPENSATION = 0.0; // the new 'thickness heuristic' approach
const float GTAO_DEFAULT_FINAL_VALUE_POWER = 2.2; // modifies the final ambient occlusion value using power function - this allows some of the above heuristics to do different things
const float GTAO_DEFAULT_DEPTH_MIP_SAMPLING_OFFSET = 3.30; // main trade-off between performance (memory bandwidth) and quality (temporal stability is the first affected, thin objects next)
const float GTAO_OCCLUSION_TERM_SCALE = 1.5;
const float GTAO_RADIUS = 0.5;
const float GTAO_RADIUS_FALLOFF_RANGE = 0.25;
 
#endif // AMBIENTOCCLUSION_GTAO_GLSL