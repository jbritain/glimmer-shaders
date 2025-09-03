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
#include "/lib/shadowSpace.glsl"
#include "/lib/water/waterFog.glsl"

#ifdef vsh
layout(r32ui) uniform uimage3D voxelMap;

#include "/lib/sway.glsl"
#include "/lib/voxel/voxelMap.glsl"
#include "/lib/voxel/voxelData.glsl"
#include "/lib/ipbr/blocklightColors.glsl"

in vec2 mc_Entity;
in vec4 at_tangent;
in vec4 at_midBlock;
in vec2 mc_midTexCoord;

out vec2 texcoord;
out vec3 normal;
flat out int materialID;
out vec3 feetPlayerPos;
out vec3 shadowViewPos;

void main() {
  texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
  normal = gl_NormalMatrix * gl_Normal; // shadow view space

  materialID = int(mc_Entity.x + 0.5);

  shadowViewPos = (gl_ModelViewMatrix * gl_Vertex).xyz;
  feetPlayerPos = (shadowModelViewInverse * vec4(shadowViewPos, 1.0)).xyz;

  #ifdef FLOODFILL
  ivec3 voxelPos = mapVoxelPos(
    feetPlayerPos + vec3(at_midBlock.xyz * rcp(64.0))
  );
  if (isWithinVoxelBounds(voxelPos)) {
    VoxelData data;
    vec4 averageTextureData = textureLod(gtexture, mc_midTexCoord, 4);

    data.color = getBlocklightColor(materialID);
    if (data.color == vec3(0.0)) {
      data.color = pow(averageTextureData.rgb, vec3(2.2));
    }
    data.opacity = pow(averageTextureData.a, rcp(3));
    data.emission = pow2(at_midBlock.w / 15.0);
    data.emission = pow2(at_midBlock.w / 15.0);

    uint encodedVoxelData = encodeVoxelData(data);
    imageAtomicMax(voxelMap, voxelPos, encodedVoxelData);
  }
  #endif

  gl_Position = gl_ProjectionMatrix * vec4(shadowViewPos, 1.0);
  gl_Position.xyz = distort(gl_Position.xyz);
}

#endif

// ===========================================================================================

#ifdef fsh
in vec2 lmcoord;
in vec2 texcoord;
in mat3 tbnMatrix;
in vec3 normal;
flat in int materialID;
in vec3 shadowViewPos;
in vec3 feetPlayerPos;

#include "/lib/dh.glsl"
#include "/lib/lighting/shading.glsl"
#include "/lib/water/waterFog.glsl"
#include "/lib/water/waveNormals.glsl"

/* RENDERTARGETS: 0*/
layout(location = 0) out vec4 color;

void main() {
  color = texture(gtexture, texcoord);
  vec2 lmcoord;
  float ao;
  vec4 overlayColor;

  clrwl_computeFragment(color, color, lmcoord, ao, overlayColor);
}

#endif
