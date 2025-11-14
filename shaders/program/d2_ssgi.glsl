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

#include "/lib/dh.glsl"
#include "/lib/util/packing.glsl"
#include "/lib/lighting/ssdo.glsl"
#include "/lib/lighting/ssptgi.glsl"
#include "/lib/lighting/gtao.glsl"
#include "/lib/lighting/rsm.glsl"

/* RENDERTARGETS: 5 */

layout(location = 0) out vec4 ssgi;

void main() {
  float depth = texture(depthtex0, texcoord).r;
  if (depth == 1.0) {
    ssgi = vec4(0.0);
    return;
  }

  vec3 viewPos = screenSpaceToViewSpace(vec3(texcoord, depth));
  dhOverride(depth, viewPos, false);

  vec4 normalData = texture(colortex2, texcoord);
  vec3 worldFaceNormal = normalize(decodeNormal(normalData.ba));
  // ssgi = RSM(viewPos, worldFaceNormal);
  // ssgi = vec4(vec3(0.0), 1.0);
  // if (texcoord.x < 0.33) {
  // ssgi = SSDO(viewPos, worldFaceNormal);
  // } else if (texcoord.x < 0.66) {
  // ssgi = GTAO(viewPos, mat3(gbufferModelView) * worldFaceNormal, texcoord);
  // } else {
  ssgi = SSPTGI(viewPos, mat3(gbufferModelView) * worldFaceNormal);
  // }

  //
  //
  // show(ssgi.rgb * 100);
  // ssgi = RSM(viewPos, worldFaceNormal);

  vec3 feetPlayerPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;
  feetPlayerPos += cameraPosition;
  feetPlayerPos -= previousCameraPosition;
  vec3 previousViewPos = (gbufferPreviousModelView *
      vec4(feetPlayerPos, 1.0)).xyz;
  vec4 previousClipPos = gbufferPreviousProjection * vec4(previousViewPos, 1.0);
  vec3 previousScreenPos = previousClipPos.xyz / previousClipPos.w * 0.5 + 0.5;

  if (previousScreenPos.xy == clamp01(previousScreenPos.xy)) {
    vec4 previousSSGI = texture(colortex5, previousScreenPos.xy);

    ssgi = mix(ssgi, previousSSGI, 0.9);
  }
}

#endif
