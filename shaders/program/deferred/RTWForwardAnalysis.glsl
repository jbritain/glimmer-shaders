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
const vec2 workGroupsRender = vec2(1.0, 1.0);

layout(r32ui) uniform uimage2D shadowImportanceMap;

#include "/lib/common.glsl"

void main() {
  ivec2 texelCoord = ivec2(gl_GlobalInvocationID.xy);
  if (any(greaterThanEqual(texelCoord, ivec2(resolution)))) {
    return;
  }

  vec2 texcoord = texelCoord / (resolution * workGroupsRender);
  float depth = textureLod(depthtex0, texcoord, 0).r;

  if(depth == 1.0){
    return;
  }

  vec3 viewPos = screenSpaceToViewSpace(vec3(texcoord, depth));
  vec3 shadowViewPos = transformView(
    transformView(viewPos, gbufferModelViewInverse),
    shadowModelView
  );
  vec3 shadowScreenPos = viewSpaceToScreenSpaceOrtho(
    shadowViewPos,
    shadowProjection
  );

  uint weight = uint(1000);
  weight += uint((1.0 - depth) * 1000);

  imageAtomicAdd(shadowImportanceMap, ivec2(shadowScreenPos.xy * 256), weight);
}
