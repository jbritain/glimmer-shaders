/*
    Copyright (c) 2025 Josh Britain (jbritain)
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

// ==============================================================================================

#ifdef fsh

#include "/lib/material/material.glsl"

in vec2 texcoord;

uniform sampler2D depthtex0;
uniform usampler2D colortex1;
uniform usampler2D colortex2;

/* RENDERTARGETS: 0 */

layout(location = 0) out vec4 color;

void main(){
  float depth = texture(depthtex0, texcoord).r;
  color.rgb = vec3(0.0);

  if(depth == 1.0){
    return;
  }

  Material material = unpackMaterial(texture(colortex2, texcoord).rg);
  Gbuffer gbuffer = unpackGbuffer(texture(colortex1, texcoord).rgb);

  color.rg = gbuffer.lightmap;
}

#endif