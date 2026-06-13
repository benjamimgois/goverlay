#ifndef PLANET_GRASSFLAGSMAP_GLSL
#define PLANET_GRASSFLAGSMAP_GLSL

// GrassFlagsMap flag bit definitions (stored in R32UI texture, set 2 binding 2 in planet descriptors)

#define GRASS_FLAG_MANUALLY_PLACED   (1u << 0u)  // Grass was placed manually by the player; age was reset to 0 on first placement
#define GRASS_FLAG_SIMULATION_PLACED (1u << 1u)  // Grass was placed by the planet simulation
#define GRASS_FLAG_FERTILIZED        (1u << 2u)  // Fertilized: growth rate is multiplied by 10 (growthDuration * 0.1)
#define GRASS_FLAG_MOWED             (1u << 3u)  // Mowed: blade height capped at 15% of maximum
#define GRASS_FLAG_BURNED            (1u << 4u)  // Burned: albedo tinted dark brown
#define GRASS_FLAG_FROZEN            (1u << 5u)  // Frozen: age growth skipped; albedo tinted white-blue

#endif
