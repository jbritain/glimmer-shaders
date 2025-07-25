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

#ifndef SHADING_GLSL
#define SHADING_GLSL

#include "/lib/lighting/brdf.glsl"
#include "/lib/lighting/shadows.glsl"
#include "/lib/util/spheremap.glsl"

vec3 getShadedColor(
  Material material,
  vec3 mappedNormal,
  vec3 faceNormal,
  vec3 blocklight,
  vec2 lightmap,
  vec3 viewPos,
  float shadowFactor,
  float ambientOcclusion
) {
  #ifdef GBUFFERS_ARMOR_GLINT
  return material.albedo * EMISSION_STRENGTH * 0.0002;
  #endif

  vec3 feetPlayerPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;

  vec3 scatter;
  vec3 shadow =
    shadowFactor > 1e-6
      ? getShadowing(
        feetPlayerPos,
        faceNormal,
        lightmap,
        material,
        ambientOcclusion,
        scatter
      ) *
      shadowFactor
      : vec3(0.0);

  vec3 color =
    brdf(material, mappedNormal, faceNormal, viewPos, shadow, scatter) *
    weatherSunlightColor;

  float ambient = AMBIENT_STRENGTH * 0.1;
  #ifdef WORLD_THE_NETHER
  ambient *= 4.0;
  #endif

  ambient += nightVision * 0.1;

  ambient *= 1.0 - darknessLightFactor * 2.5;

  vec3 diffuse =
    material.albedo *
    (weatherSkylightColor *
      pow2(lightmap.y) *
      (material.ao * 0.5 + 0.5) *
      ambientOcclusion +
      blocklight *
        (material.ao * 0.5 + 0.5) *
        BLOCKLIGHT_STRENGTH *
        0.002 *
        clamp01(1.0 - darknessLightFactor * 2.5) +
      vec3(ambient) * material.ao * ambientOcclusion);

  vec3 fresnel = fresnelRoughness(
    material,
    dot(mappedNormal, normalize(-viewPos))
  );

  // max mip samples the whole sphere
  // therefore max mip minus 1 samples a hemisphere
  // so we blend with that based on roughness
  float mipLevel = log2(
    1.0 + material.roughness * (maxVec2(textureSize(colortex7, 0)) - 1.0)
  );

  vec3 reflected = reflect(normalize(viewPos), mappedNormal);

  #ifdef ROUGH_SKY_REFLECTIONS
  vec3 specular = textureLod(colortex7, mapSphere(reflected), mipLevel).rgb;
  fresnel *= clamp01(smoothstep(13.5 / 15.0, 1.0, lightmap.y));
  fresnel *= 1.0 - max0(dot(mappedNormal, -normalize(upPosition)));

  if (material.metalID != NO_METAL) {
    diffuse *= 1.0 - clamp01(smoothstep(13.5 / 15.0, 1.0, lightmap.y));
  }

  color += mix(diffuse, specular, fresnel);
  #else
  color += diffuse;
  #endif

  color +=
    material.emission *
    material.albedo *
    EMISSION_STRENGTH *
    clamp01(1.0 - darknessLightFactor * 2.5) *
    0.001;

  return max0(color);
}

vec3 getShadedColor(
  Material material,
  vec3 mappedNormal,
  vec3 faceNormal,
  vec2 lightmap,
  vec3 viewPos,
  float shadowFactor,
  float ambientOcclusion
) {
  vec3 blocklight =
    vec3(1.0, 0.3, 0.03) * 5e-3 * max0(exp(-(1.0 - lightmap.x * 10.0)));
  return getShadedColor(
    material,
    mappedNormal,
    faceNormal,
    blocklight,
    lightmap,
    viewPos,
    shadowFactor,
    ambientOcclusion
  );
}

#endif // SHADING_GLSL
