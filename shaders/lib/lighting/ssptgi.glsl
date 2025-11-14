#ifndef SSPTGI_GLSL
#define SSPTGI_GLSL

#include "/lib/util/screenSpaceRayTrace.glsl"
#include "/lib/voxel/voxelMap.glsl"

#define SSPTGI_SAMPLES 8

vec4 SSPTGI(vec3 viewPos, vec3 normal) {
  mat3 tbn;
  tbn[2] = normal;
  tbn[0] = normal.yzx;
  tbn[1] = cross(tbn[0], tbn[2]);

  float occlusion = 0.0;
  vec3 radiance = vec3(0.0);
  vec3 feetPlayerPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;
  vec3 voxelPos = mapVoxelPosInterp(feetPlayerPos);
  vec3 blocklightColor;
  #ifdef FLOODFILL
  if (frameCounter % 2 == 0) {
    blocklightColor = texture(floodfillVoxelMapTex2, voxelPos).rgb;
  } else {
    blocklightColor = texture(floodfillVoxelMapTex1, voxelPos).rgb;
  }
  blocklightColor *= 0.001;
  #else
  blocklightColor = vec3(EMISSION_STRENGTH);
  #endif

  for (int i = 0; i < SSPTGI_SAMPLES; i++) {
    vec3 noise = blueNoise(floor(gl_FragCoord.xy), frameCounter, i);

    float cosTheta = sqrt(noise.x);
    float sinTheta = sqrt(1.0 - noise.x);
    float phi = 2.0 * PI * noise.y;

    vec3 sampleDir =
      tbn * vec3(cos(phi) * sinTheta, sin(phi) * sinTheta, cosTheta);
    // vec3 sampleDir = reflect(normalize(viewPos), normal);

    vec3 samplePos;
    if (
      rayIntersects(
        viewPos,
        sampleDir,
        4,
        noise.z,
        false,
        samplePos,
        depthtex0,
        gbufferProjection
      ) &&
        dot(decodeNormal(texture(colortex2, samplePos.xy).rg), sampleDir) < 0.0
    ) {
      radiance += texture(colortex6, samplePos.xy).rgb;
    } else {
      occlusion += 1.0;
      // radiance += blocklightColor;
    }
  }

  return vec4(radiance, occlusion) / SSPTGI_SAMPLES;
}

#endif // SSPTGI_GLSL
