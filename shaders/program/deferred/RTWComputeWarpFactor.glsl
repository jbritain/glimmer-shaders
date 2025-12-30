/*
    Copyright (c) 2025 Josh Britain (jbritain)
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

// ==============================================================================================

#ifdef fsh

in vec2 texcoord;

/* RENDERTARGETS: 4,3 */

layout(location = 0) out float warp;
layout(location = 1) out float warpAccum;

// TODO: REPLACE THIS WITH AN ACTUALLY GOOD PREFIX SUM ALGORITHM
// this is an affront to optimisation

void main() {
  int k = int(gl_FragCoord.x);
  int n = 256;

  float totalWeightToK = 0.0;
  int j = 0;
  for(; j < k; j++){
    totalWeightToK += texelFetch(colortex4, ivec2(j, gl_FragCoord.y), 0).r + 100;
  }
  float totalWeightToN = totalWeightToK;
  for(; j < n; j++){
    totalWeightToN += texelFetch(colortex4, ivec2(j, gl_FragCoord.y), 0).r + 100;
  }

  warp = totalWeightToK / totalWeightToN - float(k) / float(n);

  float previousWarp = texture(colortex3, texcoord).r;
  // warp = mix(warp, previousWarp, 0.5);
  warpAccum = warp;
}

#endif
