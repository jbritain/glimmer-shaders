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
#include "/lib/atmosphere/sky.glsl"
#include "/lib/lighting/brdf.glsl"

in vec2 texcoord;

/* RENDERTARGETS: 0 */

layout(location = 0) out vec4 color;

void main() {
    float depth = texture(depthtex0, texcoord).r;
    vec3 viewPos = screenSpaceToViewSpace(vec3(texcoord, depth));

  Material material = unpackMaterial(texture(colortex2, texcoord).rg);
  Gbuffer gbuffer = unpackGbuffer(texture(colortex1, texcoord).rgb);

  if (depth == 1.0) {
    color.rgb = getSky(
      mat3(gbufferModelViewInverse) * normalize(viewPos),
      true
    );
    return;
  }

  vec3 shadowViewPos = transformView(
    transformView(viewPos, gbufferModelViewInverse),
    shadowModelView
  );

  vec3 shadowViewNormal = mat3(shadowModelView) * gbuffer.geometryNormal;
  shadowViewPos += shadowViewNormal * 0.1 * (dot(gbuffer.geometryNormal, worldLightDir) * 0.5 + 0.5);

  vec3 shadowScreenPos = viewSpaceToScreenSpaceOrtho(
    shadowViewPos,
    shadowProjection
  );
  vec2 warp = vec2(
    textureLod(colortex4, vec2(shadowScreenPos.x, 0.0), 0).r,
    textureLod(colortex4, vec2(shadowScreenPos.y, 1.0), 0).r
  );
  float shadow = texture(shadowtex0HW, shadowScreenPos + vec3(warp, 0.0)).r;

  color = texture(shadowtex0, texcoord);
  color.rgb =
    brdf(
      material,
      mat3(gbufferModelView) * gbuffer.surfaceNormal,
      mat3(gbufferModelView) * gbuffer.geometryNormal,
      viewPos
    ) *
    sunlightColor * shadow;

}

#endif
