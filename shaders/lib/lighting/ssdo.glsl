#ifndef SSDO_GLSL
#define SSDO_GLSL

#define SSDO_SAMPLES 8
#define SSDO_RADIUS 2.0

vec4 SSDO(vec3 viewPos, vec3 worldNormal) {
  vec3 normal = mat3(gbufferModelView) * worldNormal;

  mat3 tbn;
  tbn[2] = normal;
  tbn[0] = normal.yzx;
  tbn[1] = cross(tbn[0], tbn[2]);

  float occlusion = 0.0;
  vec3 radiance = vec3(0.0);

  for (int i = 0; i < SSDO_SAMPLES; i++) {
    vec3 noise = blueNoise(floor(gl_FragCoord.xy), frameCounter, i);

    float cosTheta = sqrt(noise.x);
    float sinTheta = sqrt(1.0 - noise.x);
    float phi = 2.0 * PI * noise.y;

    vec3 sampleDir =
      tbn * vec3(cos(phi) * sinTheta, sin(phi) * sinTheta, cosTheta);
    vec3 worldSampleDir = mat3(gbufferModelViewInverse) * sampleDir;
    float radius = noise.z;

    vec3 offset = sampleDir * radius * SSDO_RADIUS;

    vec3 sampleViewPos = viewPos + offset;
    vec3 sampleScreenPos = viewSpaceToScreenSpace(sampleViewPos);
    float sampleDepth = screenSpaceToViewSpace(
        texture(depthtex0, sampleScreenPos.xy).r
      );

    float sampleOcclusion =
      float(sampleDepth >= sampleViewPos.z + 0.025) *
        smoothstep(0.0, 1.0, SSDO_RADIUS / abs(sampleDepth - sampleViewPos.z));
    occlusion += 1.0 - sampleOcclusion;

    vec3 sampleNormal = decodeNormal(texture(colortex2, sampleScreenPos.xy).rg);
    vec3 sampleRadiance =
      texture(colortex6, sampleScreenPos.xy).rgb * sampleOcclusion;

    sampleRadiance *=
      max0(dot(sampleNormal, -worldSampleDir)) * max0(dot(worldNormal, worldSampleDir));
    sampleRadiance /= SSDO_RADIUS * radius + 1.0;
    radiance += sampleRadiance;
  }

  radiance *= PI * pow2(SSDO_RADIUS);

  return vec4(radiance, occlusion) / SSDO_SAMPLES;
}

#endif // SSDO_GLSL
