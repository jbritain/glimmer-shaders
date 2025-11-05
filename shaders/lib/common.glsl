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


#ifdef VOXY
#define dhRenderDistance vxRenderDistance
#define dhProjection vxProj
#define dhProjectionInverse vxProjInv

#define dhDepthTex0 vxDepthTexTrans
#define dhDepthTex1 vxDepthTexOpaque
#endif

#ifndef GBUFFERS_VOXY
#include "/lib/common/uniforms.glsl"
#endif


vec2 EB = vec2(eyeBrightness) / 240.0;
vec2 EBS = vec2(eyeBrightnessSmooth) / 240.0;
vec2 resolution = vec2(viewWidth, viewHeight);

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

#ifndef GBUFFERS_VOXY
layout(std430, binding = 0) buffer environmentData {
    vec3 sunlightColor;
    vec3 skylightColor;
    float weatherFrameTimeCounter; // only increments when it is raining
    uint encodedHeldLightColor;
};

layout(std430, binding = 1) buffer smoothedData {
    float sunVisibilitySmooth;
};
#endif



#define weatherSunlightColor mix(sunlightColor, sunlightColor * 0.005, pow(wetness, rcp(5.0)))
#define weatherSkylightColor mix(skylightColor, sunlightColor * 0.04, pow(wetness, rcp(5.0)))

#ifdef CAVE_SKY_DARKENING
float skyMultiplier = clamp01(constantMood > 0.9 ? 0.0 : 1.0) * EBS.y;
#else
float skyMultiplier = 1.0;
#endif

const bool colortex3Clear = false;

// BUFFER FORMATS
/*

    const int colortex0Format = RGBA16F;
    const int colortex1Format = RG32UI;
    const int colortex5Format = RGBA16F;
    const int colortex6Format = RGB16F;
    const int shadowcolor1Format = R8;
*/
const bool colortex0Clear = false; // only so we can keep mipmaps from the previous frame
const bool colortex5Clear = false;
const bool colortex6Clear = false;

#ifdef BLOOM
/*
    const int colortex4Format = RGB16F;
*/
#endif

#ifdef TEMPORAL_FILTER
/*
    const int colortex3Format = RGB16F;
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

#ifdef MOTION_BLUR
#endif

#endif // COMMON_GLSL