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

#ifndef COMMON_GLSL
#define COMMON_GLSL

#include "/lib/common/settings.glsl"

#include "/lib/common/debug.glsl"

#include "/lib/common/syntax.glsl"
#include "/lib/common/uniforms.glsl"
#include "/lib/common/util.glsl"

#include "/lib/common/material.glsl"
#include "/lib/common/spaceConversions.glsl"
#include "/lib/common/materialIDs.glsl"

#define worldTimeCounter ((worldTime / 20.0) + (worldDay * 1200.0))

const float wetnessHalflife = 50.0;
const float drynessHalflife = 25.0;

#ifdef IS_MONOCLE
monocle_not_supported
#endif

vec3 sunDir = normalize(sunPosition);
vec3 worldSunDir = mat3(gbufferModelViewInverse) * sunDir;

vec3 lightDir = normalize(shadowLightPosition);
vec3 worldLightDir = mat3(gbufferModelViewInverse) * lightDir;

bool isDay = sunDir == lightDir;
#define isNight !isDay

layout(std430, binding = 0) buffer environmentData {
    vec3 sunlightColor;
    vec3 skylightColor;
    float weatherFrameTimeCounter; // only increments when it is raining
    uint encodedHeldLightColor;
};

layout(std430, binding = 1) buffer smoothedData {
    float sunVisibilitySmooth;
};

#define weatherSunlightColor mix(sunlightColor, sunlightColor * 0.005, pow(wetness, rcp(5.0)))
#define weatherSkylightColor mix(skylightColor, sunlightColor * 0.04, pow(wetness, rcp(5.0)))

float skyMultiplier = clamp01(constantMood > 0.9 ? 0.0 : 1.0);

const bool colortex3Clear = false;

// BUFFER FORMATS
/*

    const int colortex0Format = RGBA16F;
    const int colortex5Format = R8;
    const int shadowcolor1Format = RG32F;
*/
const bool colortex0Clear = false; // only so we can keep mipmaps from the previous frame

#ifdef BLOOM
/*
    const int colortex2Format = RGB16F;
*/
#endif

#ifdef TEMPORAL_FILTER
/*
    const int colortex3Format = RGB16F;
*/
#endif

const vec4 colortex4ClearColor = vec4(1.0, 1.0, 1.0, 1.0);

/*
    const int colortex4Format = RGB8;
*/

#ifdef DISTANT_HORIZONS
/*
    const int colortex6Format = R16;
*/
#endif

#ifdef ROUGH_SKY_REFLECTIONS
/*
    const int colortex7Format = R11F_G11F_B10F;
*/
const bool colortex7Clear = false;
#endif

#ifdef INFINITE_OCEAN
#endif

#endif // COMMON_GLSL