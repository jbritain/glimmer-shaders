#ifndef END_PORTAL_GLSL
#define END_PORTAL_GLSL

// fades values around a sliding window of width 0.1 through time, wrapping around 1.0
float thresholdRange(float val) {
  float threshold = fract(frameTimeCounter * 0.01);
  float width = 0.025;

  float dist = min(abs(val - threshold), 1.0 - abs(val - threshold));
  float fade = smoothstep(width, 0.0, dist);
  return fade;
}

vec3 endPortal(vec3 dir, vec3 normal, vec3 playerPos) {
  vec3 col = vec3(0.0);

  vec3 pos;
  vec3 noise;

  const float rot_factor = PI / 5.0 + PI;

  for (int i = 0; i < 5; i++) {
    rayPlaneIntersection(
      cameraPosition,
      dir,
      cameraPosition.y + playerPos.y - (i * 10.0 + 1),
      pos
    );

    noise = texelFetch(
      noisetex,
      ivec2(
        mod(
          (pos.xz +
            vec2(sin(rot_factor * i), cos(rot_factor * i)) *
              frameTimeCounter *
              0.1) *
            5.0,
          vec2(64)
        )
      ),
      0
    ).rgb;
    col +=
      noise *
      thresholdRange(fract(luminance(noise) + i / 10)) *
      exp(-length(pos.xz - cameraPosition.xz + playerPos.xz) * 0.2);
  }

  col *= vec3(0.2, 0.1, 1.0) * 10.0;

  return col;
}

#endif
