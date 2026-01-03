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
#include "/lib/common.glsl"

#ifdef vsh
out vec2 texcoord;

void main() {
  gl_Position = ftransform();
  texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}
#endif

// ==============================================================================================

#ifdef fsh

#include "/lib/util/screenSpaceRayTrace.glsl"
#include "/lib/material/material.glsl"
#include "/lib/util/dither.glsl"
#include "/lib/atmosphere/sky.glsl"
#include "/lib/util/misc.glsl"
#include "/lib/lighting/brdf.glsl"

in vec2 texcoord;

/* RENDERTARGETS: 7 */

layout(location = 0) out vec3 SSRColor;

vec3 SSRSample(
  inout vec3 origin,
  vec3 dir,
  vec3 normal,
  float skyLightmap,
  float jitter,
  int samples,
  bool refine,
  out float hitLength
) {
  vec3 rayPos;
  vec3 reflectedDir = reflect(dir, normal);
  if (
    rayIntersects(
      origin,
      reflectedDir,
      samples,
      jitter,
      refine,
      rayPos,
      depthtex0,
      gbufferProjection
    )
  ) {
    rayPos = screenSpaceToViewSpace(rayPos);
    hitLength = distance(rayPos, origin);
    rayPos = transformView(rayPos, gbufferModelViewInverse);
    rayPos += cameraPosition - previousCameraPosition;
    rayPos = transformView(rayPos, gbufferPreviousModelView);
    rayPos = viewSpaceToScreenSpace(rayPos, gbufferPreviousProjection);
    return texture(colortex5, rayPos.xy).rgb;
  } else {
    hitLength = 0.0;
    rayPos = viewSpaceToScreenSpace(origin);
    return getSky(mat3(gbufferModelViewInverse) * reflectedDir, false) * skyLightmap;
  }
}

void main() {
  SSRColor = vec3(0.0);
  float depth = texture(depthtex0, texcoord).r;
  if (depth == 1.0) {
    return;
  }
  vec3 viewPos = screenSpaceToViewSpace(vec3(texcoord, depth));

  Gbuffer gbuffer = unpackGbuffer(texture(colortex1, texcoord).rgb);
  Material material = unpackMaterial(texture(colortex2, texcoord).rg);

  vec3 viewNormal = mat3(gbufferModelView) * gbuffer.surfaceNormal;
  vec3 viewDir = normalize(viewPos);

  if (material.roughness < 0.01) {
    float h;
    SSRColor = SSRSample(
      viewPos,
      viewDir,
      viewNormal,
      gbuffer.lightmap.y,
      interleavedGradientNoise(floor(gl_FragCoord.xy), frameCounter),
      SMOOTH_SSR_STEPS,
      true,
      h
    );
  } else {
    mat3 tbn = generateTBN(viewNormal);
    vec3 tangentViewDir = normalize(-viewDir * tbn);
    vec3 f = fresnelRoughness(
      material,
      dot(tangentViewDir, vec3(0.0, 1.0, 0.0))
    );

    if (maxVec3(f) > ROUGH_SSR_THRESHOLD || material.metalID != NO_METAL) {
      float averageHitLength = 0.0;

      for (int i = 0; i < ROUGH_SSR_SAMPLES; i++) {
        vec3 noise = blueNoise(gl_FragCoord.xy, frameCounter, i);
        vec3 roughNormal =
          tbn *
          SampleVNDFGGX(tangentViewDir, vec2(material.roughness), noise.xy);

        float hitLength;
        SSRColor += SSRSample(
          viewPos,
          viewDir,
          roughNormal,
          gbuffer.lightmap.y,
          noise.z,
          ROUGH_SSR_STEPS,
          true,
          hitLength
        );
        averageHitLength += hitLength;
      }
      SSRColor /= float(ROUGH_SSR_SAMPLES);
      averageHitLength /= float(ROUGH_SSR_SAMPLES);

      vec3 reflectDir = reflect(viewDir, viewNormal);
      vec3 projectedPos = viewPos + viewDir * averageHitLength;
      projectedPos = transformView(projectedPos, gbufferModelViewInverse);
      projectedPos += cameraPosition - previousCameraPosition;
      vec3 projectedViewPos = transformView(
        projectedPos,
        gbufferPreviousModelView
      );
      projectedViewPos -= normalize(projectedViewPos) * averageHitLength;
      projectedPos = viewSpaceToScreenSpace(
        projectedViewPos,
        gbufferPreviousProjection
      );

      vec3 actualProjectedPos = projectedViewPos;
      actualProjectedPos.z = texture(colortex5, projectedPos.xy).a;

      if (
        clamp01(projectedPos) == projectedPos &&
        distance(projectedViewPos, actualProjectedPos) < 0.1
      ) {
        vec3 previousSSR = texture(colortex7, projectedPos.xy).rgb;
        SSRColor = mix(SSRColor, previousSSR, 0.5);
      }

    }
  }

}

#endif
