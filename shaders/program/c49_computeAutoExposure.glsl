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

#include "/lib/common.glsl"

#ifdef vsh

out vec2 texcoord;

void main() {
  gl_Position = ftransform();
  texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}

#endif

// ===========================================================================================

#ifdef fsh
in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

const bool colortex0MipmapEnabled = true;
layout(std430, binding = 2) buffer frameData {
    float averageLuminanceSmooth;
};

void main() {
  if(gl_FragCoord.xy == vec2(0.5)){
      int maxMipLevel = int(floor(log2(max(viewWidth, viewHeight))));
      float averageLuminance = textureLod(colortex0, vec2(0.5), maxMipLevel).a;
      averageLuminanceSmooth = mix(averageLuminance, averageLuminanceSmooth, clamp01(exp2(frameTime * -1)));
  
      averageLuminanceSmooth = max(averageLuminanceSmooth, 0.0001);
  }

  color = texture(colortex0, texcoord) * 100.0;
  if (any(isinf(color)) || any(isnan(color))) {
    color = vec4(0.0);
  }
  color.a = luminance(color.rgb);

}

#endif
