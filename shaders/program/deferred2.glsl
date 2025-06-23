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

#define RSM_SAMPLE_RADIUS 0.1
#define RSM_SAMPLES 8

#ifdef fsh
    in vec2 texcoord;

    #include "/lib/util/packing.glsl"
    #include "/lib/shadowSpace.glsl"

    /* RENDERTARGETS: 8 */
    layout(location = 0) out vec3 GI;

    void main() {
      float depth = texture(depthtex0, texcoord).r;
      GI = vec3(0.0);
      if(depth == 1.0) {
        return;
      }

      vec3 viewPos = screenSpaceToViewSpace(vec3(texcoord, depth));
      vec3 feetPlayerPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;

      vec3 albedo = texture(colortex8, texcoord).rgb;
      vec3 worldNormal = decodeNormal(texture(colortex1, texcoord).xy);
      vec3 shadowViewNormal = mat3(shadowModelView) * worldNormal;

      vec3 shadowViewPos = (shadowModelView * vec4(feetPlayerPos, 1.0)).xyz;
	    vec4 shadowClipPos = shadowProjection * vec4(shadowViewPos, 1.0);
      vec3 shadowScreenPos = getShadowScreenPos(shadowClipPos);

      // show(texture(shadowcolor1, shadowScreenPos.xy));

      

      const float sqrtSamples = sqrt(float(RSM_SAMPLES));

      for(int i = 0; i < RSM_SAMPLES; i++){
        vec2 noise = blueNoise(texcoord, i + frameCounter * RSM_SAMPLES).xy;
        vec2 offset = RSM_SAMPLE_RADIUS * noise.x * vec2(sin(2.0 * PI * noise.y), cos(2.0 * PI * noise.y));

        float sampleWeight = pow2(noise.x) * shadowDistance * pow2(RSM_SAMPLE_RADIUS);

        vec3 sampleShadowScreenPos = shadowScreenPos + vec3(offset, 0.0);

        float sampleDepth = texture(shadowtex0, sampleShadowScreenPos.xy).r;
        vec3 sampleColor = texture(shadowcolor0, sampleShadowScreenPos.xy).rgb;
        vec3 sampleNormal = texture(shadowcolor1, sampleShadowScreenPos.xy).rgb;
        vec3 sampleShadowViewPos = texture(shadowcolor2, sampleShadowScreenPos.xy).rgb;
        
        vec3 GISample = sampleColor * sampleWeight;
        GISample *= max0(dot(sampleNormal, shadowViewPos - sampleShadowViewPos));
        GISample *= max0(dot(shadowViewNormal, sampleShadowViewPos - shadowViewPos));
        GISample /= pow4(distance(shadowViewPos, sampleShadowViewPos));
        GI += GISample;
      }

      GI *= 100.0;

      GI /= float(RSM_SAMPLES);

      // show(GI * 1000.0);

      GI *= weatherSunlightColor * albedo;

      // GI *= pow2(RSM_SAMPLE_RADIUS) * weatherSunlightColor;




    }

#endif