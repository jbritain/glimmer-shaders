#ifndef GTAO_GLSL
#define GTAO_GLSL

#define GTAO_SLICE_COUNT 8
#define GTAO_DIRECTION_SAMPLE_COUNT 4
#define GTAO_RADIUS 4.0
#define GTAO_THICKNESS 0.5

// https://graphics.stanford.edu/%7Eseander/bithacks.html
uint bitCount(uint value) {
  value = value - ((value >> 1u) & 0x55555555u);
  value = (value & 0x33333333u) + ((value >> 2u) & 0x33333333u);
  return ((value + (value >> 4u)) & 0xF0F0F0Fu) * 0x1010101u >> 24u;
}

// https://cdrinmatane.github.io/posts/ssaovb-code/
const uint sectorCount = 32u;
uint updateSectors(float minHorizon, float maxHorizon, uint outBitfield) {
  uint startBit = uint(minHorizon * float(sectorCount));
  uint horizonAngle = uint(
    ceil((maxHorizon - minHorizon) * float(sectorCount))
  );
  uint angleBit =
    horizonAngle > 0u
      ? uint(0xFFFFFFFFu >> sectorCount - horizonAngle)
      : 0u;
  uint currentBitfield = angleBit << startBit;
  return outBitfield | currentBitfield;
}

vec2 screenSize = vec2(viewWidth, viewHeight);
const float twoPi = 2.0 * PI;
const float halfPi = PI / 2.0;

// get indirect lighting and ambient occlusion
vec4 GTAO(vec3 position, vec3 normal, vec2 fragUV) {
  uint indirect = 0u;
  uint occlusion = 0u;

  float visibility = 0.0;
  vec3 lighting = vec3(0.0);
  vec2 frontBackHorizon = vec2(0.0);
  vec2 aspect = screenSize.yx / screenSize.x;
  vec3 camera = normalize(-position);

  float sliceRotation = twoPi / (GTAO_SLICE_COUNT - 1.0);
  float sampleScale = -GTAO_RADIUS * gbufferProjection[0][0] / position.z;
  float sampleOffset = 0.01;
  vec2 jitter = blueNoise(floor(gl_FragCoord.xy), frameCounter).rg;

  for (float slice = 0.0; slice < GTAO_SLICE_COUNT + 0.5; slice += 1.0) {
    float phi = sliceRotation * (slice + jitter.r) + PI;
    vec2 omega = vec2(cos(phi), sin(phi));
    vec3 direction = vec3(omega.x, omega.y, 0.0);
    vec3 orthoDirection = direction - dot(direction, camera) * camera;
    vec3 axis = cross(direction, camera);
    vec3 projNormal = normal - axis * dot(normal, axis);
    float projLength = length(projNormal);

    float signN = sign(dot(orthoDirection, projNormal));
    float cosN = clamp(dot(projNormal, camera) / projLength, 0.0, 1.0);
    float n = signN * acos(cosN);

    for (
      float currentSample = 0.0;
      currentSample < GTAO_DIRECTION_SAMPLE_COUNT + 0.5;
      currentSample += 1.0
    ) {
      float sampleStep =
        (currentSample + jitter.g) / GTAO_DIRECTION_SAMPLE_COUNT + sampleOffset;
      vec2 sampleUV = fragUV - sampleStep * sampleScale * omega * aspect;
      vec3 samplePosition = screenSpaceToViewSpace(
        vec3(sampleUV, texture(depthtex0, sampleUV).r)
      );
      vec3 sampleNormal = decodeNormal(texture(colortex2, sampleUV).rg);
      vec3 sampleLight = texture(colortex6, sampleUV).rgb;
      vec3 sampleDistance = samplePosition - position;
      float sampleLength = length(sampleDistance);
      vec3 sampleHorizon = sampleDistance / sampleLength;

      frontBackHorizon.x = dot(sampleHorizon, camera);
      frontBackHorizon.y = dot(
        normalize(sampleDistance - camera * GTAO_THICKNESS),
        camera
      );

      frontBackHorizon = acos(frontBackHorizon);
      frontBackHorizon = clamp((frontBackHorizon + n + halfPi) / PI, 0.0, 1.0);

      indirect = updateSectors(frontBackHorizon.x, frontBackHorizon.y, 0u);
      lighting +=
        (1.0 - float(bitCount(indirect & ~occlusion)) / float(sectorCount)) *
        sampleLight *
        clamp(dot(normal, sampleHorizon), 0.0, 1.0) *
        clamp(dot(sampleNormal, -sampleHorizon), 0.0, 1.0);
      occlusion |= indirect;
    }
    visibility += 1.0 - float(bitCount(occlusion)) / float(sectorCount);
  }

  visibility /= GTAO_SLICE_COUNT;
  lighting /= GTAO_SLICE_COUNT;

  return vec4(lighting, visibility);
}

#endif
