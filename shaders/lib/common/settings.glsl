#ifndef SETTINGS_GLSL
#define SETTINGS_GLSL

const bool shadowHardwareFiltering = true;

// #define DEBUG_ENABLE

#define EXPOSURE 40 // [0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80]
#define CONTRAST 1.0 // [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
#define SATURATION 1.0 // [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]

#define DYNAMIC_HANDLIGHT
#define DIRECTIONAL_LIGHTMAPS

#define WAVING_BLOCKS

#define SHADOWS
const float shadowDistance = 64.0; // [16.0 32.0 48.0 64.0 80.0 96.0 112.0 128.0 144.0 160.0 176.0 192.0 208.0 224.0 240.0 256.0 272.0 288.0 304.0 320.0 336.0 352.0 368.0 384.0 400.0 416.0 432.0 448.0 464.0 480.0 496.0 512.0]
const int shadowMapResolution = 512; // [128 256 512 1024 2048 4096 8192]
const float sunPathRotation = -40.0; // [-90.0 -85.0 -80.0 -75.0 -70.0 -65.0 -60.0 -55.0 -50.0 -45.0 -40.0 -35.0 -30.0 -25.0 -20.0 -15.0 -10.0 -5.0 0.0 5.0 10.0 15.0 20.0 25.0 30.0 35.0 40.0 45.0 50.0 55.0 60.0 65.0 70.0 75.0 80.0 85.0 90.0]
#define SHADOW_DISTORTION 0.85
#define SHADOW_SOFTNESS 1.0 // [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
#define SHADOW_SAMPLES 4 // [1 2 4 8 16 32]

#define PBR_MODE 1 // [0 1]

#define TEMPORAL_FILTER

#define BLOOM
#define BLOOM_RADIUS 1.0 // [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
#define BLOOM_STRENGTH 1.0 // [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]

#define CLOUDS
// #define BLOCKY_CLOUDS

#define ATMOSPHERIC_FOG
#define CLOUDY_FOG

#define SSR_STEPS 4 // [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16]
#define REFLECTION_MODE 2 // [0 1 2]
#define FADE_REFLECTIONS

#define REFRACTION
// #define CAUSTICS

// #define INFINITE_OCEAN

#define DH_AO
#ifdef DH_AO
#endif
#define DH_AO_BIAS 0.025
#define DH_AO_RADIUS 4.0
#define DH_AO_SAMPLES 32 // [4 8 16 32 64]

#define GLIMMER_SHADERS 1 // [1 2]
#define WEBSITE 1 // [1 2]


#endif // SETTINGS_GLSL