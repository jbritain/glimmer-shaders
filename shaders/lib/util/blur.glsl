#ifndef BLUR_GLSL
#define BLUR_GLSL

/*
"GLSL Fast Gaussian Blur" by experience-monks
https://github.com/Experience-Monks/glsl-fast-gaussian-blur

The MIT License (MIT) Copyright (c) 2015 Jam3

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

vec4 blur5(
  sampler2D image,
  vec2 uv,
  vec2 resolution,
  vec2 direction,
  float lod
) {
  vec4 color = vec4(0.0);
  vec2 off1 = vec2(1.3333333333333333) * direction;
  color += textureLod(image, uv, lod) * 0.29411764705882354;
  color += textureLod(image, uv + off1 / resolution, lod) * 0.35294117647058826;
  color += textureLod(image, uv - off1 / resolution, lod) * 0.35294117647058826;
  return color;
}

vec4 blur9(
  sampler2D image,
  vec2 uv,
  vec2 resolution,
  vec2 direction,
  float lod
) {
  vec4 color = vec4(0.0);
  vec2 off1 = vec2(1.3846153846) * direction;
  vec2 off2 = vec2(3.2307692308) * direction;
  color += textureLod(image, uv, lod) * 0.227027027;
  color += textureLod(image, uv + off1 / resolution, lod) * 0.3162162162;
  color += textureLod(image, uv - off1 / resolution, lod) * 0.3162162162;
  color += textureLod(image, uv + off2 / resolution, lod) * 0.0702702703;
  color += textureLod(image, uv - off2 / resolution, lod) * 0.0702702703;
  return color;
}

vec4 blur13(
  sampler2D image,
  vec2 uv,
  vec2 resolution,
  vec2 direction,
  float lod
) {
  vec4 color = vec4(0.0);
  vec2 off1 = vec2(1.411764705882353) * direction;
  vec2 off2 = vec2(3.2941176470588234) * direction;
  vec2 off3 = vec2(5.176470588235294) * direction;
  color += textureLod(image, uv, lod) * 0.1964825501511404;
  color += textureLod(image, uv + off1 / resolution, lod) * 0.2969069646728344;
  color += textureLod(image, uv - off1 / resolution, lod) * 0.2969069646728344;
  color += textureLod(image, uv + off2 / resolution, lod) * 0.09447039785044732;
  color += textureLod(image, uv - off2 / resolution, lod) * 0.09447039785044732;
  color +=
    textureLod(image, uv + off3 / resolution, lod) * 0.010381362401148057;
  color +=
    textureLod(image, uv - off3 / resolution, lod) * 0.010381362401148057;
  return color;
}

#endif // BLUR_GLSL
