#ifndef SUBSURFACE_SCATTERING_GLSL
#define SUBSURFACE_SCATTERING_GLSL

#include "/lib/util/phaseFunctions.glsl"

vec3 getSubsurfaceScattering(vec3 albedo, float factor, float blockerDistance, float shadow, vec3 playerDir, vec3 playerNormal){
  if(factor < 0.01){
    return vec3(0.0);
  }
  
  if(blockerDistance < 1e-6){
    return 0.25 * isotropicPhase * albedo / PI;
  }

  float VoL = dot(playerDir, worldLightDir);

  float sz = blockerDistance * 250 / factor;
  vec3 scatter = 0.25 * isotropicPhase * albedo * (exp(-sz) + 3.0 * exp(-sz / 3.0)) / PI;

  // if(dot(playerNormal, worldLightDir) > 0.0){
  //   scatter *= shadow;
  // }

  return scatter;
}

#endif // SUBSURFACE_SCATTERING_GLSL