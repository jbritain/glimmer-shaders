#ifndef BILATERAL_FILTER_GLSL
#define BILATERAL_FILTER_GLSL

#include "/lib/util/packing.glsl"

vec4 bilateralFilter(sampler2D sampleTex, vec2 coord, int radius, int lod) {
  vec3 targetNormal = decodeNormal(texture(colortex2, coord).ba);
  float targetDepth = screenSpaceToViewSpace(texture(depthtex0, texcoord).r);

  vec2 samplerScale = rcp(textureSize(sampleTex, lod).xy);

  vec4 samples = vec4(0.0);
  float totalWeight = 0.0;

  for (int x = -radius; x < radius; x++) {
    for (int y = -radius; y < radius; y++) {
      vec2 offsetCoord = coord + vec2(x, y) * samplerScale;
      float sampleDepth = texture(depthtex0, offsetCoord).r;
      if (sampleDepth == 1.0) continue;
      sampleDepth = screenSpaceToViewSpace(sampleDepth);

      vec4 sampleColor = textureLod(sampleTex, offsetCoord, lod);
      vec3 sampleNormal = decodeNormal(texture(colortex2, offsetCoord).ba);

      float weight =
        max(0, abs(dot(sampleNormal, targetNormal)) - 0.9) * rcp(0.9); // normal weight
      weight *= 1.0 - smoothstep(0.0, 0.5, abs(targetDepth - sampleDepth)); // depth weight
      weight *= exp(-pow2(abs(length(vec2(x, y)) / radius))); // spatial weight
      samples += sampleColor * weight;
      totalWeight += weight;
    }
  }

  return samples / totalWeight;
}

#endif // BILATERAL_FILTER_GLSL
