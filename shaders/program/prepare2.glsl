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

#ifdef csh

layout (local_size_x = 1, local_size_y = 1) in;
const ivec3 workGroups = ivec3(1, 1, 1);

layout (r32ui) uniform uimage3D voxelMap;

#include "/lib/atmosphere/sky/sky.glsl"

void main()
{
    #define SKYLIGHT_SAMPLES 8
    int samples = 0;
    for(int x = 0; x < SKYLIGHT_SAMPLES; x++){
        for(int y = 0; y < SKYLIGHT_SAMPLES; y++){
            vec2 noise = vec2(x, y) / SKYLIGHT_SAMPLES;
            

            float cosTheta = sqrt(noise.x);
            float sinTheta = sqrt(1.0 - noise.x);
            float phi = 2.0 * PI * noise.y;

            skylightColor += getSky(vec3(
                cos(phi) * sinTheta,
                sin(phi) * sinTheta,
                cosTheta
            ), false);
            samples++;
        }
    }

    skylightColor /= float(samples);


    if(lightningBoltPosition.w > 0.5){
        skylightColor += vec3(20.0, 20.0, 40.0) * 0.0001;
        sunlightColor += vec3(20.0, 20.0, 40.0) * 0.0001;
    }

    weatherFrameTimeCounter += frameTime * (wetness + thunderStrength) * 2.0;

    // skylightColor = mix(skylightColor, exp(-1.0 * 10 * skylightColor), wetness);
    // sunlightColor = mix(sunlightColor, exp(-1.0 * 10 * sunlightColor), wetness);
}

#endif

#ifdef vsh
    void main(){

    }
#endif

#ifdef fsh
#ifdef ROUGH_SKY_REFLECTIONS
    const bool colortex7MipmapEnabled = true;
#endif
    void main(){
        
    }

#endif