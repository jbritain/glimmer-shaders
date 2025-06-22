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
        int maxMipLevel = int(floor(log2(max(viewWidth, viewHeight))));
        float averageLuminance = textureLod(colortex0, vec2(0.5), maxMipLevel).a;

        averageLuminance = exp2(averageLuminance);
        
        averageLuminanceSmooth = mix(averageLuminance, averageLuminanceSmooth, clamp01(exp2(frameTime * -0.1)));
        averageLuminanceSmooth = max(averageLuminanceSmooth, 0.0001);

        float exposure = rcp(2.0 * averageLuminance);

        // exposure = clamp(exposure, 0.001, 100.0);

        color.rgb *= exposure;
        #else
        color.rgb *= EXPOSURE;
        #endif
    }

#endif