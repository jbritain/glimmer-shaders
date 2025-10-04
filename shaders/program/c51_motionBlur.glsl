/*
    Copyright (c) 2024 Josh Britain (jbritain)
    Licensed under the MIT license

      _____   __   _                          
     / ___/  / /  (_)  __ _   __ _  ___   ____
    / (_ /  / /  / /  /  ' \ /  ' \/ -_) / __/
    \___/  /_/  /_/  /_/_/_//_/_/_/\__/ /_/   
    
    By jbritain
    https://jbritain.net
                                            
*/

#include "/lib/common.glsl"

#ifdef vsh

out vec2 texcoord;

void main() {
  gl_Position = ftransform();
  texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}

#endif

// ===========================================================================================

#ifdef fsh
in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
  float depth = texture(depthtex0, texcoord).r;
  color = texture(colortex0, texcoord);
  if (depth < MC_HAND_DEPTH * 0.5 + 0.5) {
    // hand

    return;
  }

  vec3 screenPos = vec3(texcoord, depth);
  vec4 clipPos = vec4(screenPos * 2.0 - 1.0, 1.0);
  vec3 viewPos = screenSpaceToViewSpace(screenPos);
  vec3 previousPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz; // player space
  previousPos += cameraPosition; // world space
  previousPos -= previousCameraPosition; // previous player space
  previousPos = (gbufferPreviousModelView * vec4(previousPos, 1.0)).xyz; // previous view space
  vec4 previousClipPos = gbufferProjection * vec4(previousPos, 1.0);

  float jitter = interleavedGradientNoise(floor(gl_FragCoord.xy), frameCounter);

  vec4 velocity = clipPos - previousClipPos;

  // sample along line along the velocity
  int i;
  float weight = 1.0;

  for (i = 0; i < 8; i++) {
    vec4 samplePos = mix(
      clipPos - velocity / 2,
      clipPos + velocity / 2,
      clamp01((float(i) + (jitter * 2.0 - 1.0)) / 8.0)
    );
    vec3 sampleCoord = samplePos.xyz / samplePos.w * 0.5 + 0.5;

    float sampleDepth = texture(depthtex0, sampleCoord.xy).r;
    if (sampleDepth < MC_HAND_DEPTH * 0.5 + 0.5) continue;

    float sampleWeight =
      1.0 -
      smoothstep(0.9, 1.0, maxVec2(abs(sampleCoord - 0.5)) * 2) *
        float(sampleDepth > MC_HAND_DEPTH * 0.5 + 0.5);

    color += texture(colortex0, sampleCoord.xy) * sampleWeight;
    weight += sampleWeight;
  }
  color /= weight;

}

#endif
