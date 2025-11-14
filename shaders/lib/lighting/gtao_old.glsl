#ifndef GTAO_GLSL
#define GTAO_GLSL

#define GTAO_SLICE_COUNT 4
#define GTAO_DIRECTION_SAMPLE_COUNT 8
#define GTAO_RADIUS 0.1

float GTAO(vec2 cTexcoord, vec3 cPosV, vec3 normalV) {
  vec3 viewV = normalize(-cPosV);
  float visibility = 0.0;

  float sampleScale = -SSDO_RADIUS * gbufferProjection[0][0];

  for (int slice = 0; slice < GTAO_SLICE_COUNT; slice++) {
    vec2 jitter = blueNoise(floor(gl_FragCoord.xy), frameCounter).rg;
    float phi = (slice + jitter.x) * PI / GTAO_SLICE_COUNT;
    vec2 omega = vec2(cos(phi), -sin(phi));

    vec3 directionV = vec3(omega, 0.0);
    vec3 orthoDirectionV = directionV - dot(directionV, viewV) * viewV;
    vec3 axisV = cross(directionV, viewV);
    vec3 projNormalV = normalV - axisV * dot(normalV, axisV);

    float sgnN = sign(dot(orthoDirectionV, projNormalV));
    float cosN = clamp01(dot(projNormalV, viewV) / length(projNormalV));
    float n = sgnN * acos(cosN);

    vec2 h;
    for (int side = 0; side < 2; side++) {
      float cHorizonCos = -1;
      for (int sampl = 0; sampl < GTAO_DIRECTION_SAMPLE_COUNT; sampl++) {
        float s = (sampl + jitter.y) / float(GTAO_DIRECTION_SAMPLE_COUNT);
        vec2 sTexCoord =
          cTexcoord +
          (-1 + 2 * side) * s * sampleScale * vec2(omega.x, -omega.y);
        float sDepth = texture(depthtex0, sTexCoord).r;
        vec3 sPosV = screenSpaceToViewSpace(vec3(sTexCoord, sDepth));
        vec3 sHorizonV = normalize(sPosV - cPosV);

        float horizonCos = dot(sHorizonV, viewV);
        cHorizonCos = max(cHorizonCos, horizonCos);
      }

      h[side] =
        n + clamp((-1 + 2 * side) * acos(cHorizonCos) - n, -PI / 2, PI / 2);
      visibility +=
        length(projNormalV) *
        (cosN + 2 * h[side] * sin(n) - cos(2 * h[side] - n)) /
        4;
    }
  }

  visibility /= GTAO_SLICE_COUNT;
  return visibility;
}

#endif // GTAO_GLSL
