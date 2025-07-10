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

#include "/lib/util/blur.glsl"

/* RENDERTARGETS: 1 */
layout(location = 0) out vec4 blurredDepth;

void main() {
  blurredDepth = blur9(
    shadowcolor1,
    texcoord,
    textureSize(shadowcolor1, 0),
    DIRECTION,
    0
  );

  blurredDepth.a = 1.0; // iris bug where blending is enabled in shadowcomp
}

#endif
