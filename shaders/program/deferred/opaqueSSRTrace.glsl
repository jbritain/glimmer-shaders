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

#include "/lib/util/screenSpaceRayTrace.glsl"
#include "/lib/material/material.glsl"
#include "/lib/util/dither.glsl"

in vec2 texcoord;

/* RENDERTARGETS: 7 */

layout(location = 0) out vec3 rayPos;

void main() {
  rayPos = vec3(-1.0);
  float depth = texture(depthtex0, texcoord).r;
  if (depth == 1.0) {
    return;
  }
  vec3 viewPos = screenSpaceToViewSpace(vec3(texcoord, depth));

  float jitter = interleavedGradientNoise(floor(gl_FragCoord.xy), frameCounter);

  Gbuffer gbuffer = unpackGbuffer(texture(colortex1, texcoord).rgb);
  vec3 dir = normalize(viewPos);
  vec3 reflectedDir = reflect(
    dir,
    mat3(gbufferModelView) * gbuffer.surfaceNormal
  );

  if(!rayIntersects(
    viewPos,
    reflectedDir,
    16,
    jitter,
    true,
    rayPos,
    depthtex0,
    gbufferProjection
  )){
    rayPos = vec3(-1.0);
  }
}

#endif
