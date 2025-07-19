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

    #ifdef AUTO_EXPOSURE
    const bool colortex0MipmapEnabled = true;
    layout(std430, binding = 2) buffer frameData {
        float averageLuminanceSmooth;
    };
    #endif

    void main() {
        color = texture(colortex0, texcoord);
        #ifdef AUTO_EXPOSURE
        
        
        if(gl_FragCoord.xy == vec2(0.5)){
            int maxMipLevel = int(floor(log2(max(viewWidth, viewHeight))));
            float averageLuminance = textureLod(colortex0, vec2(0.5), maxMipLevel).a;
            averageLuminanceSmooth = mix(averageLuminance, averageLuminanceSmooth, clamp01(exp2(frameTime * -1)));
        
            averageLuminanceSmooth = max(averageLuminanceSmooth, 0.0001);
        }



        #ifdef WORLD_OVERWORLD

        const float dayAverageLuminance = pow(118.0/255.0, 2.2);
        const float nightAverageLuminance = pow(33.0/255.0, 2.2);
        float targetAverageLuminance = mix(nightAverageLuminance, dayAverageLuminance, clamp01(smoothstep(-0.1, 0.1, worldSunDir.y)));

        targetAverageLuminance = mix(targetAverageLuminance, targetAverageLuminance * 0.7, wetness);
        
        // really shitty purkinje
        color.rgb = hsv(color.rgb);
        color.g *= smoothstep(-0.1, 0.1, worldSunDir.y) * 0.3 + 0.7;
        color.rgb = rgb(color.rgb);
        #else
        float targetAverageLuminance = 1.0;
        #endif


        float exposure = targetAverageLuminance / averageLuminanceSmooth;


        color.rgb *= exposure;
        #else
        color.rgb *= EXPOSURE;
        #endif
    }

#endif