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
#include "/lib/post/tonemap.glsl"
#include "/lib/post/processing.glsl"
#include "/lib/util/textRenderer.glsl"

in vec2 texcoord;

uniform sampler2D debugtex;

layout(location = 0) out vec4 color;

void main() {
  color = texture(colortex0, texcoord);

  #ifdef BLOOM

  vec3 bloom = texture(colortex2, texcoord).rgb;

  float rain = texture(colortex5, texcoord).r;
  color.rgb = mix(
    color.rgb,
    bloom,
    clamp01(
      0.01 * BLOOM_STRENGTH + rain * 0.1 + wetness * 0.1 * EBS.y + blindness
    )
  );
  color.rgb *= 1.0 - 0.8 * blindness;
  #endif

  color.rgb *= 1.0 - 0.95 * blindness;

  color.rgb *= 2.0;
  color.rgb = tonemap(color.rgb);

  color = postProcess(color);

  #ifdef DEBUG_ENABLE
  if (hideGUI) {
    color = texture(debugtex, texcoord);
  }

  beginText(ivec2(gl_FragCoord.xy / 2.0), ivec2(0, viewHeight / 2.0) + ivec2(8, -8));
  printString((_D,_e,_b,_u,_g,_space,_m,_o,_d,_e,_space,_i,_s,_space,_a,_c,_t,_i,_v,_e));
  printLine();
  printString((_F,_r,_a,_m,_e,_colon,_space));
  printInt(frameCounter);
  printLine();

  if(!hideGUI){
    printString((_P,_r,_e,_s,_s,_space,_F,_1,_space,_a,_n,_d,_space,_c,_a,_l,_l,_space,_s,_h,_o,_w,_opprn,_clprn));
  }




  endText(color.rgb);

  #endif
}

#endif
