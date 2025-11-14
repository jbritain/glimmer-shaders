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

/* RENDERTARGETS: 6 */

layout(location = 0) out vec3 reprojectedColor;

void main() {
  float depth = texture(depthtex0, texcoord).r;
  vec3 pos = vec3(texcoord, depth);
  pos = screenSpaceToViewSpace(pos);
  pos = (gbufferModelViewInverse * vec4(pos, 1.0)).xyz;
  pos += cameraPosition - previousCameraPosition;
  pos = (gbufferPreviousModelView * vec4(pos, 1.0)).xyz;
  pos = viewSpaceToScreenSpace(pos, gbufferPreviousProjection);

  reprojectedColor = vec3(0.0);

  if (pos.xy == clamp01(pos.xy)) {
    reprojectedColor = texture(colortex6, pos.xy).rgb;
    show(reprojectedColor * 100.0);
  }
}

#endif
