#ifndef TAA_GLSL
#define TAA_GLSL

// https://extremelearning.com.au/unreasonable-effectiveness-of-quasirandom-sequences/
vec2 getTAAJitter() {
  int n = frameCounter % 8;
  const float g = 1.32471795724474602596;
  const float a1 = 1.0 / g;
  const float a2 = 1.0 / (g * g);
  return vec2(fract(0.5 + a1 * n), fract(0.5 + a2 * n));
}

#endif // TAA_GLSL
