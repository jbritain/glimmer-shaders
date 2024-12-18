#ifndef COMMON_GLSL
#define COMMON_GLSL

#include "/lib/common/syntax.glsl"
#include "/lib/common/uniforms.glsl"
#include "/lib/common/util.glsl"
#include "/lib/common/spaceConversions.glsl"
#include "/lib/common/material.glsl"

vec3 sunDir = normalize(sunPosition);
vec3 worldSunDir = mat3(gbufferModelViewInverse) * sunDir;

vec3 lightDir = normalize(shadowLightPosition);
vec3 worldLightDir = mat3(gbufferModelViewInverse) * lightDir;

const float sunPathRotation = -40.0;

layout(std430, binding = 0) buffer lightColors {
    vec3 sunlightColor;
    vec3 skylightColor;
};

// BUFFER FORMATS
/*
    const int colortex0Format = RGB16F;
*/

#endif // COMMON_GLSL