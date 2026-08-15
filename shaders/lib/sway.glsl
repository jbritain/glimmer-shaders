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

#ifndef SWAY_GLSL
#define SWAY_GLSL

#include "/lib/water/waveNormals.glsl"

#ifdef MCWIND
#include "/mcwind/mcwind_field.glsl"

vec3 getSway(int materialID, vec3 worldPos, vec3 midblock) {
  vec3 blockCentre = worldPos + midblock / 64;
  #if MCWR_NO_MOTION == 1
  return vec3(0.0);
  #else
  vec3 delta = vec3(0.0);

  if (isGrass(materialID)) {
    float upper = isTopHalf(materialID) ? 1.0 : 0.0;
    float w = mcw_grassHeight(worldPos, blockCentre, upper);
    delta.xz = mcw_grassPush(blockCentre, w);

    delta.xz += mcw_draftPush(blockCentre, cameraPosition, w);
  } else if (isLeaves(materialID) || isHanging(materialID)) {
    float weld = mcw_leafWeld(worldPos, blockCentre);
    delta = mcw_leafSway(worldPos, blockCentre, weld);
    if (isHanging(materialID)) {
      delta.xz += mcw_vineSwing(worldPos, blockCentre, weld);
    }

  } else if (isFire(materialID)) {
    delta = mcw_fireLean(blockCentre, step(blockCentre.y, worldPos.y));
  }
  #endif

  return worldPos + delta;
}
#else
#error The WindLink mod is not installed !
#endif

#endif // SWAY_GLSL
