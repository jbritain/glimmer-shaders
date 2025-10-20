#ifndef WATER_PARALLAX_GLSL
#define WATER_PARALLAX_GLSL

#define WATER_PARALLAX_SAMPLES 8

#include "/lib/water/waveNormals.glsl"

// the following was a statement I made when I wrote this code for glint probably a year or so again
//    this code worked first try
//    the scope of my engineering genius literally knows no bounds
// it did not work first try in glimmer
// in fact it still doesn't work

vec3 getWaterParallaxNormal(
  vec3 playerPos,
  vec3 worldNormal,
  float jitter,
  float heightmapFactor
) {
  #ifdef WATER_PARALLAX
  // we know no wave is ever more than WAVE_DEPTH above the surface
  // so we shift the ray forwards until it is WAVE_DEPTH above the surface
  float fractionalDistance;
  fractionalDistance = (abs(playerPos.y) - WAVE_DEPTH) / abs(playerPos.y);
  vec3 origin = playerPos * fractionalDistance;

  vec3 increment = (playerPos - origin) / float(WATER_PARALLAX_SAMPLES);

  bool intersect = false;

  vec3 rayPos = origin;

  rayPos += increment * jitter;

  for (int i = 0; i < WATER_PARALLAX_SAMPLES; i++) {
    float waveHeight = waveHeight(rayPos.xz + cameraPosition.xz) + playerPos.y;

    // turns out you can just build binary refinement into the loop this is goated
    bool intersect = playerPos.y < 0 == rayPos.y < waveHeight;
    if (intersect) {
      increment /= 2;
    }

    rayPos += increment * (intersect ? -1 : 1);

  }

  return waveNormal(rayPos.xz + cameraPosition.xz, worldNormal, 1.0);

  #endif

  return waveNormal(
    playerPos.xz + cameraPosition.xz,
    worldNormal,
    heightmapFactor
  );
}

#endif // WATER_PARALLAX_GLSL
