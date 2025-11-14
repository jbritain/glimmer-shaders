#ifndef RSM_GLSL
#define RSM_GLSL

#include "/lib/shadowSpace.glsl"

#define RSM_SAMPLES 1
#define RSM_RADIUS 2.0

vec4 RSM(vec3 viewPos, vec3 worldNormal) {
  vec3 normal = mat3(shadowModelView) * worldNormal;
  vec3 feetPlayerPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;
  vec3 shadowViewPos = (shadowModelView * vec4(feetPlayerPos, 1.0)).xyz;

  mat3 tbn;
  tbn[2] = normal;
  tbn[0] = normal.yzx;
  tbn[1] = cross(tbn[0], tbn[2]);

  float occlusion = 0.0;
  vec3 radiance = vec3(0.0);

  for (int i = 0; i < RSM_SAMPLES; i++) {
    vec3 noise = blueNoise(floor(gl_FragCoord.xy), frameCounter, i);

    float cosTheta = sqrt(noise.x);
    float sinTheta = sqrt(1.0 - noise.x);
    float phi = 2.0 * PI * noise.y;

    vec3 sampleDir =
      tbn * vec3(cos(phi) * sinTheta, sin(phi) * sinTheta, cosTheta);
    vec3 offset = sampleDir * noise.z * RSM_RADIUS;

    vec3 sampleShadowViewPos = shadowViewPos + offset;
    vec4 sampleShadowClipPos = shadowProjection * vec4(sampleShadowViewPos, 1.0);
    vec3 sampleShadowScreenPos = getShadowScreenPos(sampleShadowClipPos);

    if (clamp01(sampleShadowScreenPos.xy) != sampleShadowScreenPos.xy) {
      continue;
    }

    float sampleDepth = screenSpaceToViewSpace(
        texture(shadowtex0, sampleShadowScreenPos.xy).r,
        shadowProjectionInverse
      );

    sampleShadowViewPos.z = sampleDepth;

    vec3 sampleNormal =
      texture(shadowcolor2, sampleShadowScreenPos.xy).rgb * 2.0 - 1.0;

    vec3 sampleRadiance =
      texture(shadowcolor0, sampleShadowScreenPos.xy).rgb;

    sampleRadiance *= max0(dot(sampleNormal, normalize(shadowViewPos - sampleShadowViewPos)));
    sampleRadiance *= max0(dot(normal, normalize(sampleShadowViewPos - shadowViewPos)));
    sampleRadiance /= distance(sampleShadowViewPos, shadowViewPos) + 1.0;
    radiance += sampleRadiance;
  }

  radiance *= PI * pow2(RSM_RADIUS);
  radiance *= sunlightColor;
  // show(radiance * 100 / RSM_SAMPLES);

  return vec4(radiance / RSM_SAMPLES, 1.0);
}

#endif // RSM_GLSL
