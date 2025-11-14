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

#ifndef SHADOW_SPACE_GLSL
#define SHADOW_SPACE_GLSL

float cubeLength(vec2 v) {
  vec2 t = abs(pow3(v));
  return pow(t.x + t.y, 1.0 / 3.0);
}

float getShadowDistanceZ(float depth) {
  depth = depth * 2.0 - 1.0;
  depth /= 0.5; // for distortion
  vec4 shadowHomPos = shadowProjectionInverse * vec4(0.0, 0.0, depth, 1.0);
  return shadowHomPos.z / shadowHomPos.w;
}

// Fernández-Guasti squircle shadow map distortion by Luracasmus
// https://gist.github.com/Luracasmus/7ef1602bc9bdc14c95e3e1f98c9c4dd0
vec3 distort(vec3 pos) {
  vec2 clip_pos_xy = pos.xy;
  const float distortion = 0.95;

  // Not sure if this actually scales correctly to always prevent artifacts but it seems to.
  const float s = 1.0 - 2.0 / shadowDistance;

  vec2 pos2 = clip_pos_xy * clip_pos_xy;
  float fg_squircle_r =
    sqrt(
      pos2.x +
        pos2.y +
        sqrt(
          pos2.x * pos2.x +
            (2.0 - 4.0 * s * s) * pos2.x * pos2.y +
            pos2.y * pos2.y
        )
    ) *
    inversesqrt(2.0);

  return vec3(
    clip_pos_xy / fma(fg_squircle_r, distortion, 1.0 - distortion),
    pos.z
  );

}

// bias also by Luracasmus
vec3 getShadowBias(vec3 worldNormal, float face_n_dot_l) {
  float cosine = saturate(face_n_dot_l); // this can probably just be max(0.0, face_n_dot_l)
  float sine = sqrt(fma(cosine, -cosine, 1.0)); // using the Pythagorean identity
  float tangent = sine / cosine;

  return (vec2(vec2(-1.0, 380.0) / shadowMapResolution) *
    vec2(sine, min(2.0, tangent))).y *
  worldNormal;
}

vec4 getShadowClipPos(vec3 playerPos) {
  vec4 shadowViewPos = shadowModelView * vec4(playerPos, 1.0);
  vec4 shadowClipPos = shadowProjection * shadowViewPos;
  return shadowClipPos;
}

vec3 getShadowScreenPos(vec4 shadowClipPos) {
  vec3 shadowScreenPos = distort(shadowClipPos.xyz); //apply shadow distortion
  shadowScreenPos.xyz = shadowScreenPos.xyz * 0.5 + 0.5; //convert from -1 ~ +1 to 0 ~ 1

  return shadowScreenPos;
}

vec4 getUndistortedShadowScreenPos(vec4 shadowClipPos) {
  vec4 shadowScreenPos = shadowClipPos; //convert to shadow ndc space.
  shadowScreenPos.xyz = shadowScreenPos.xyz * 0.5 + 0.5; //convert from -1 ~ +1 to 0 ~ 1

  return shadowScreenPos;
}

#endif
