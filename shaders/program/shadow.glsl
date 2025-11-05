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

out vec2 lmcoord;
out vec2 texcoord;
out vec4 glcolor;
out vec3 normal;
flat out int materialID;
out vec3 feetPlayerPos;
out vec3 shadowViewPos;

void main() {
  texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
  lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
  glcolor = gl_Color;
  normal = gl_NormalMatrix * gl_Normal; // shadow view space

  materialID =
    renderStage == MC_RENDER_STAGE_BLOCK_ENTITIES
      ? blockEntityId
      : int(mc_Entity.x + 0.5);

  shadowViewPos = (gl_ModelViewMatrix * gl_Vertex).xyz;
  feetPlayerPos = (shadowModelViewInverse * vec4(shadowViewPos, 1.0)).xyz;
  vec3 worldNormal = mat3(shadowModelViewInverse) * normal;

  #ifdef FLOODFILL
  ivec3 voxelPos = mapVoxelPos(
    feetPlayerPos +
      (renderStage == MC_RENDER_STAGE_BLOCK_ENTITIES
        ? -worldNormal * 0.2
        : vec3(at_midBlock.xyz * rcp(64.0)))
  );
  if (
    isWithinVoxelBounds(voxelPos) &&
    gl_VertexID % 4 == 0 &&
    (renderStage == MC_RENDER_STAGE_TERRAIN_SOLID ||
      // renderStage == MC_RENDER_STAGE_BLOCK_ENTITIES ||
      renderStage == MC_RENDER_STAGE_TERRAIN_TRANSLUCENT ||
      renderStage == MC_RENDER_STAGE_BLOCK_ENTITIES)
  ) {
    VoxelData data;
    vec4 averageTextureData =
      textureLod(gtexture, mc_midTexCoord, 4) * gl_Color;

    data.color = getBlocklightColor(materialID);

    if (data.color == vec3(0.0)) {
      data.color = pow(averageTextureData.rgb, vec3(2.2));
    }
    data.opacity = pow(averageTextureData.a, rcp(3));
    data.emission = pow2(at_midBlock.w / 15.0);

    if (isEndPortal(blockEntityId)) {
      data.emission = 1.0;
    }

    // data.emission = textureLod(specular, mc_midTexCoord, 4).a;
    // if(data.emission == 1.0){
    //     data.emission = 0.0;
    // }

    if (isTintedGlass(materialID)) {
      data.opacity = 1.0;
    }

    if (isLetsLightThrough(materialID)) {
      data.opacity = 0.0;
    }

    if (isWater(materialID)) {
      data.color = 1.0 - WATER_SCATTERING;
    }

    uint encodedVoxelData = encodeVoxelData(data);
    imageAtomicMax(voxelMap, voxelPos, encodedVoxelData);
  }
  #endif

  #ifdef WAVING_BLOCKS
  feetPlayerPos =
    getSway(materialID, feetPlayerPos + cameraPosition, at_midBlock.xyz) -
    cameraPosition;
  shadowViewPos = (shadowModelView * vec4(feetPlayerPos, 1.0)).xyz;
  #endif
  gl_Position = gl_ProjectionMatrix * vec4(shadowViewPos, 1.0);

  gl_Position.xyz = distort(gl_Position.xyz);
}

#endif

// ===========================================================================================

#ifdef fsh
in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;
in mat3 tbnMatrix;
in vec3 normal;
flat in int materialID;
in vec3 shadowViewPos;
in vec3 feetPlayerPos;

#include "/lib/dh.glsl"
#include "/lib/lighting/shading.glsl"
#include "/lib/water/waterFog.glsl"
#include "/lib/water/waveNormals.glsl"

/* RENDERTARGETS: 0,1 */
layout(location = 0) out vec4 color;
layout(location = 1) out float waterMask;

void main() {
  waterMask = 0.0;
  color = texture(gtexture, texcoord) * glcolor;

  if (color.a < alphaTestRef) {
    discard;
  }

  const float avgWaterExtinction = sumVec3(waterExtinction) / 3.0;

  if (isWater(materialID)) {
    waterMask = 1.0;
    float opaqueDepth = texture(
      shadowtex1,
      gl_FragCoord.xy / shadowMapResolution
    ).r;
    float opaqueDistance = getShadowDistanceZ(opaqueDepth); // how far away from the sun is the opaque fragment shadowed by the water?
    float waterDepth = abs(shadowViewPos.z - opaqueDistance);

    color.rgb = 1.0 - waterExtinction;
    color.a = 1.0 - exp(-avgWaterExtinction * waterDepth);
  }
}

#endif
