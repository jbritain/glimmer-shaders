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

#define GBUFFERS_VOXY

#define gbufferProjection vxProj
#define gbufferProjectionInverse vxProjInv
#define gbufferPreviousProjection vxProjPrev
#define gbufferModelView vxModelView
#define gbufferModelViewInverse vxModelViewInv
#define vxModelView vxModelViewPrev

#define fogColor vec3(1.0)

#include "/lib/common.glsl"

#include "/lib/lighting/shading.glsl"
#include "/lib/util/packing.glsl"

layout(location = 0) out vec4 color;
layout(location = 1) out vec4 outData1;

/*
struct VoxyFragmentParameters {
  vec4 sampledColour;
  vec2 tile;
  vec2 uv;
  uint face;
  uint modelId;
  vec2 lightMap;
  vec4 tinting;
  uint customId;//Same as iris's modelId
};
*/

void voxy_emitFragment(VoxyFragmentParameters params) {
  if (texture(depthtex0, gl_FragCoord.xy / resolution).r < 1.0) {
    discard;
  }

  vec3 viewPos = screenSpaceToViewSpace(
    gl_FragCoord.xyz / vec3(viewWidth, viewHeight, 1.0)
  );
  vec3 playerPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;

  vec2 lightmap = params.lightMap;

  #ifdef WORLD_THE_END
  lightmap.y = 1.0;
  #endif

  vec4 albedo = params.sampledColour * params.tinting;
  albedo.rgb = pow(albedo.rgb, vec3(2.2));

  int materialID = int(params.customId);

  Material material;
  material.albedo = albedo.rgb;
  material.roughness = 1.0;
  material.f0 = vec3(0.0);
  material.metalID = NO_METAL;
  material.porosity = 0.0;
  material.sss = 0.0;
  material.emission = 0.0;
  material.ao = 1.0;

  if (materialIsPlant(materialID)) {
    material.sss = 1.0;
    material.f0 = vec3(0.04);
    material.roughness = 0.5;
  }

  if (materialIsLava(materialID)) {
    material.emission = 1.0;
  }

  #ifdef PATCHY_LAVA
  if (materialIsLava(materialID)) {
    vec3 worldPos = playerPos + cameraPosition;
    float noise = texture(
      perlinNoiseTex,
      mod(worldPos.xz / 100 + vec2(0.0, frameTimeCounter * 0.005), 1.0)
    ).r;
    noise *= texture(
      perlinNoiseTex,
      mod(worldPos.xz / 200 + vec2(frameTimeCounter * 0.005, 0.0), 1.0)
    ).r;
    material.albedo.rgb *= noise;
    material.albedo.rgb *= 4.0;
  }
  #endif

  vec3 worldNormal =
    vec3(
      uint(params.face >> 1 == 2),
      uint(params.face >> 1 == 0),
      uint(params.face >> 1 == 1)
    ) *
    (float(int(params.face) & 1) * 2 - 1);
  vec3 normal = mat3(gbufferModelView) * worldNormal;

  if (materialIsWater(materialID)) {
    material.f0 = vec3(0.02);
    material.roughness = 0.0;
    color = vec4(0.0);
  } else {
    color.rgb = getShadedColor(
      material,
      normal,
      normal,
      lightmap,
      viewPos,
      1.0,
      1.0
    );
    color.a = albedo.a;
  }

  outData1.xy = encodeNormal(worldNormal);
  outData1.z = lightmap.y;
  outData1.a = clamp01(float(materialID - 1000) * rcp(255.0));

}
