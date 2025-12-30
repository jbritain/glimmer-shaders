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
layout(local_size_x = 8, local_size_y = 16) in;
const ivec3 workGroups = ivec3(32, 16);

layout(r32ui) uniform uimage2D shadowImportanceMap;

#include "/lib/common.glsl"

void main() {
  ivec2 texelCoord = ivec2(gl_GlobalInvocationID.xy);
  
  float depth = texelFetch(undistortedShadowMapTex, texelCoord, 0).r;

  imageAtomicAdd(shadowImportanceMap, texelCoord, weight);
}
