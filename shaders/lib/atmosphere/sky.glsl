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

#ifndef SKY_GLSL
#define SKY_GLSL

#include "/lib/atmosphere/atmosphere.glsl"

vec3 getSky(vec3 dir, bool includeSun){
  vec3 sky = getValFromSkyLUT(dir);

  if(includeSun && dot(dir, worldSunDir) > cos(sunAngularRadius)){
    sky += sunRadiance * getValFromTLUT(sunTransmittanceLUTTex, tLUTRes, atmospherePos, dir);
  }

  return sky;
}

#endif