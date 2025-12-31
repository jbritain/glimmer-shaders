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

#include "/lib/material/material.glsl"
#include "/lib/lighting/ssao.glsl"

in vec2 texcoord;

/* RENDERTARGETS: 3 */

layout(location = 0) out float occlusion;

void main() {
  occlusion = 1.0;
  float depth = texture(depthtex0, texcoord).r;
  vec3 viewPos = screenSpaceToViewSpace(vec3(texcoord, depth));

  Gbuffer gbuffer = unpackGbuffer(texture(colortex1, texcoord).rgb);

  if (depth == 1.0) {
    return;
  }

  occlusion = SSAO(viewPos, gbuffer.geometryNormal);
  show(occlusion);
}

#endif
