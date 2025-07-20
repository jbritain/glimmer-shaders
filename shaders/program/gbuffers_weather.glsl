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

in vec2 mc_Entity;
in vec4 at_tangent;

out vec2 lmcoord;
out vec2 texcoord;
out vec4 glcolor;
out vec3 viewPos;
out vec3 normal;

void main() {
  texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
  lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
  glcolor = gl_Color;

  viewPos = (gl_ModelViewMatrix * gl_Vertex).xyz;
  vec3 feetPlayerPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;
  feetPlayerPos.xz += feetPlayerPos.y * 0.25;
  viewPos = (gbufferModelView * vec4(feetPlayerPos, 1.0)).xyz;

  gl_Position = gbufferProjection * vec4(viewPos, 1.0);
  normal = gl_NormalMatrix * gl_Normal;
}

#endif

// ===========================================================================================

#ifdef fsh
in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;
in vec3 viewPos;
in vec3 normal;

#include "/lib/lighting/shading.glsl"
#include "/lib/util/packing.glsl"
#include "/lib/lighting/directionalLightmap.glsl"
#include "/lib/voxel/voxelMap.glsl"
#include "/lib/voxel/voxelData.glsl"
#include "/lib/ipbr/blocklightColors.glsl"

/* RENDERTARGETS: 0,5 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 rainMask;

void main() {
  color = texture(gtexture, texcoord) * glcolor;

  if (color.a < alphaTestRef) {
    discard;
  }

  if (color.r == color.g) {
    // snow
    rainMask = vec4(0.0);

    Material material = materialFromSpecularMap(color.rgb, vec4(0.0));
    material.sss = 1.0;

    vec2 lightmap = lmcoord * 33.05 / 32.0 - 1.05 / 32.0;

    #ifdef FLOODFILL
    vec3 playerPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;

    vec3 voxelPosInterp = mapVoxelPosInterp(playerPos);

    vec3 blocklightColor;
    if (frameCounter % 2 == 0) {
      blocklightColor = texture(floodfillVoxelMapTex2, voxelPosInterp).rgb;
    } else {
      blocklightColor = texture(floodfillVoxelMapTex1, voxelPosInterp).rgb;
    }
    color.rgb = getShadedColor(
      material,
      normal,
      normal,
      blocklightColor,
      lightmap,
      viewPos,
      1.0,
      1.0
    );
    #else
    color.rgb = getShadedColor(
      material,
      normal,
      normal,
      lightmap,
      viewPos,
      1.0,
      1.0
    );

    #endif

    return;
  } else {
    color = vec4(0.0);
    rainMask = vec4(1.0);
  }

  rainMask = vec4(1.0);
}

#endif
