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

#ifndef SHADOWS_GLSL
#define SHADOWS_GLSL

#include "/lib/atmosphere/clouds.glsl"
#include "/lib/shadowSpace.glsl"


vec3 sampleShadow(vec3 shadowScreenPos) {
  float transparentShadow = texture(shadowtex0HW, shadowScreenPos).r;

  if (transparentShadow >= 1.0 - 1e-6) {
    return vec3(transparentShadow);
  }

  float opaqueShadow = texture(shadowtex1HW, shadowScreenPos).r;

  if (opaqueShadow <= 1e-6) {
    return vec3(opaqueShadow);
  }

  vec4 shadowColorData = texture(shadowcolor0, shadowScreenPos.xy);
  vec3 shadowColor =
      pow(shadowColorData.rgb, vec3(2.2)) * (1.0 - shadowColorData.a);
  return mix(shadowColor * opaqueShadow, vec3(1.0), transparentShadow);
}

float getCaustics(vec3 pos) {
  vec2 causticCoord = fract(
      pos.xz / 4.0 + vec2(frameTimeCounter * 0.1, frameTimeCounter * 0.1));
  float caust1 = texture(causticsTex, causticCoord).r;

  causticCoord = fract(pos.xz / 4.0 - vec2(frameTimeCounter * 0.1, 0.0));

  float caust2 = texture(causticsTex, causticCoord).g;

  return clamp01(min(caust1, caust2) * 2.0) * 4.0;
}

vec3 getShadowing(vec3 feetPlayerPos, vec3 faceNormal, vec2 lightmap,
                  Material material, float vanillaAO, out vec3 scatter) {
#ifdef PIXEL_LOCKED_LIGHTING
  feetPlayerPos += cameraPosition;
  feetPlayerPos = floor(feetPlayerPos * PIXEL_SIZE) / PIXEL_SIZE;
  feetPlayerPos -= cameraPosition;
#endif

  scatter = vec3(0.0);
  if (EBS.y == 0.0 && lightmap.y < 0.1 && constantMood > 0.2) {
    return vec3(0.0);
  }

  vec3 cloudShadow = vec3(1.0);

#ifdef CLOUD_SHADOWS
  cloudShadow = getCloudShadow(feetPlayerPos);
#endif

#ifdef WORLD_THE_NETHER
  return vec3(0.0);
#endif

  float fakeShadow = clamp01(smoothstep(13.5 / 15.0, 14.5 / 15.0, lightmap.y));

  float faceNoL = dot(faceNormal, lightDir);
  float sampleRadius = SHADOW_SOFTNESS * 0.003;

  if (faceNoL <= 1e-6 && material.sss > 1e-6) {
    scatter = vec3(material.sss);
    sampleRadius *= 1.0 + 16.0 * material.sss;

    float VoL = abs(dot(normalize(feetPlayerPos), worldSunDir));
    scatter *= henyeyGreenstein(0.3, VoL) * 1.5;
    // scatter *= mix(henyeyGreenstein(0.0, 0.0), henyeyGreenstein(0.7, VoL),
    // 0.3);
  }

#if (!defined SHADOWS) || (defined GBUFFERS_DISTANT)
  scatter *= 0.2;
  return vec3(fakeShadow) * cloudShadow;
#else

  vec3 worldNormal = mat3(gbufferModelViewInverse) * faceNormal;

  vec3 lightleakFeetPlayerPos = mix(
      floor(feetPlayerPos + worldNormal * 0.1 + cameraPositionFract) -
          cameraPositionFract + vec3(0.5),
      feetPlayerPos,
      isEyeInWater == 1 ? 1.0 : smoothstep(0.0, 1.0, lightmap.y) * 0.5 + 0.5);

  vec4 shadowClipPos = getShadowClipPos(lightleakFeetPlayerPos);

  vec3 bias = getShadowBias(shadowClipPos.xyz, worldNormal, faceNoL);
  shadowClipPos.xyz += bias;

  vec3 shadowScreenPos = getShadowScreenPos(shadowClipPos);

  float distFade =
      pow5(max(clamp01(maxVec2(abs(shadowClipPos.xy))),
               mix(1.0, 0.55, smoothstep(0.33, 0.8, worldLightDir.y)) *
                   (dot(feetPlayerPos.xz, feetPlayerPos.xz) *
                    rcp(pow2(shadowDistance)))));

  scatter *= (1.0 - distFade) * 0.5 + 0.5;

  vec3 shadow = vec3(0.0);

  if (distFade < 1.0) {
    float noise =
        interleavedGradientNoise(floor(gl_FragCoord.xy), frameCounter * 2);

    // scatter falloff
    float scatterSampleAngle = noise * 2 * PI;
    vec2 scatterSampleOffset =
        vec2(sin(scatterSampleAngle), cos(scatterSampleAngle)) * 0.01 /
        (shadowMapResolution / 2048.0) *
        interleavedGradientNoise(floor(gl_FragCoord.xy), frameCounter * 2 + 1);
    float blockerDepthDifference =
        max0(shadowScreenPos.z -
             texture(shadowtex0, shadowScreenPos.xy + scatterSampleOffset).r);
    float blockerDistance = blockerDepthDifference * 512;

    // thanks to sixthsurge and fozy style for suggesting I use the albedo as a
    // factor for the transmittance and quirkyplague for inspiring me to fix it
    // because it was ass for a good while
    scatter *= mix(vec3(exp(-blockerDistance *
                            rcp(material.albedo /
                                max(0.1, sqrt(luminance(material.albedo)))))),
                   vec3(1.0), distFade) *
               EBS.y;

    if (faceNoL > 1e-6) {
      for (int i = 0; i < SHADOW_SAMPLES; i++) {
        vec3 offset =
            vec3(vogelDiscSample(i, SHADOW_SAMPLES, noise), 0.0) * sampleRadius;
        shadow += sampleShadow(shadowScreenPos + offset);
      }

      shadow /= float(SHADOW_SAMPLES);
    }

#ifdef CAUSTICS
    if (
        // water mask
        textureLod(shadowcolor1, shadowScreenPos.xy, 2).r > 0.0 &&
        maxVec3(shadow) < 0.99) {
      vec3 causticsSamplePos =
          feetPlayerPos + cameraPosition + worldLightDir * blockerDistance;
      float caustics = getCaustics(causticsSamplePos);
      caustics =
          mix(caustics, pow3(caustics), clamp01(blockerDepthDifference * 4));
      shadow *= caustics;
    }
#endif
  }

  scatter *=
      maxVec3(cloudShadow); // since the cloud shadows are so blurry anyway, if
                            // something is shadowed by a cloud, it's probably
                            // not getting any sunlight
  shadow = mix(shadow, vec3(fakeShadow), clamp01(distFade));
  return shadow * cloudShadow;

#endif
}

#endif // SHADOWS_GLSL
