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
#include "/lib/lighting/shading.glsl"
#include "/lib/post/bilateralFilter.glsl"

/* RENDERTARGETS: 0,6 */

layout(location = 0) out vec4 color;
layout(location = 1) out vec3 colorWithNoSSGI;

const bool colortex5MipmapEnabled = true;

void main() {
  color = texture(colortex0, texcoord);

  float depth = texture(depthtex0, texcoord).r;
  if (depth == 1.0) {
    return;
  }

  vec3 viewPos = screenSpaceToViewSpace(vec3(texcoord, depth));
  dhOverride(depth, viewPos, false);

  float parallaxShadow;
  vec2 lightmap;
  Material material = unpackMaterialData(
      texture(colortex1, texcoord).rg,
      lightmap,
      parallaxShadow
    );

  vec4 normalData = texture(colortex2, texcoord);
  vec3 worldFaceNormal = normalize(decodeNormal(normalData.rg));
  vec3 worldMappedNormal = normalize(decodeNormal(normalData.ba));
  vec3 faceNormal = mat3(gbufferModelView) * worldFaceNormal;
  vec3 mappedNormal = mat3(gbufferModelView) * worldMappedNormal;

  vec4 ssgi = bilateralFilter(colortex5, texcoord, 4, 1);
  // show(ssgi * 100);
  // show(texture(shadowtex0, texcoord).r);
  // show(ssgi.a);

  // if (texcoord.x < 0.5) {
  //   ssgi = vec4(vec3(0.0), 1.0);
  // }

  color.rgb = getShadedColor(
      material,
      mappedNormal,
      faceNormal,
      lightmap,
      viewPos,
      parallaxShadow,
      ssgi.a
    );
  color.rgb += material.albedo * ssgi.rgb;

  colorWithNoSSGI = color.rgb;
}

#endif
