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

#ifndef WATER_FOG_GLSL
#define WATER_FOG_GLSL

#define WATER_ABSORPTION (vec3(0.3, 0.06, 0.04) * WATER_ABSORPTION_MOD)
#define WATER_SCATTERING (vec3(0.01, 0.05, 0.03) * 0.1 * WATER_SCATTERING_MOD)
#define WATER_DENSITY 1.0

vec3 waterExtinction = clamp01(WATER_ABSORPTION + WATER_SCATTERING);

vec3 waterFog(vec3 color, vec3 a, vec3 b, float dhFactor, vec3 scatterFactor) {
  if (distance(a, b) < 0.01) {
    return color;
  }

  if (dhFactor > 0.0) {
    vec3 sunTransmittance = exp(-waterExtinction * WATER_DENSITY * dhFactor);
    color.rgb *= sunTransmittance;
  }

  vec3 opticalDepth = waterExtinction * WATER_DENSITY * distance(a, b);
  vec3 transmittance = exp(-opticalDepth);

  vec3 scatter =
    weatherSunlightColor *
      henyeyGreenstein(0.4, dot(normalize(b - a), lightDir)) +
    EBS.y * weatherSkylightColor;

  #if GODRAYS == 0
  scatter *= sunVisibilitySmooth;
  #endif

  scatter *= (1.0 - transmittance) * (WATER_SCATTERING / waterExtinction);
  scatter *= scatterFactor;

  return color * transmittance + scatter;
}

vec3 waterFog(vec3 color, vec3 a, vec3 b, vec3 scatterFactor) {
  return waterFog(color, a, b, 0.0, scatterFactor);
}

#endif
