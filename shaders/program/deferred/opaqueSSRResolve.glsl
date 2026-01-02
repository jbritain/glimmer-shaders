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
#include "/lib/atmosphere/sky.glsl"

in vec2 texcoord;

/* RENDERTARGETS: 7 */

layout(location = 0) out vec3 hitColor;

void main() {
  float depth = texture(depthtex0, texcoord).r;
  if (depth == 1.0) {
    return;
  }

  hitColor = vec3(0.0);
  vec3 hitPos = texture(colortex7, texcoord).xyz;
  if(hitPos.x > 0.0){

    hitPos = screenSpaceToViewSpace(hitPos);
    float hitLength = length(hitPos);
    hitPos = transformView(hitPos, gbufferModelViewInverse);
    hitPos += cameraPosition - previousCameraPosition;
    hitPos = transformView(hitPos, gbufferPreviousModelView);
    hitPos = viewSpaceToScreenSpace(hitPos, gbufferPreviousProjection);

    hitColor = texture(colortex5, hitPos.xy).rgb;
  } else {
    vec3 viewPos = screenSpaceToViewSpace(vec3(texcoord, depth));
    Gbuffer gbuffer = unpackGbuffer(texture(colortex1, texcoord).rgb);
    vec3 dir = normalize(viewPos);
    vec3 reflectedDir = reflect(
      mat3(gbufferModelViewInverse) * dir,
      gbuffer.surfaceNormal
    );
    hitColor = getSky(reflectedDir, false);
  }
  
  // show(hitColor);
  
}

#endif
